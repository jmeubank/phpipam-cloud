
node ${GALERA_CLUSTER_ADDRS}

master:
curl 10s timeouts
expose port 3309 in dockerfile
allow cluster size 2
fixes for clusters operating through NAT with respect to NODE_ADDRESS, bind addresses, listen addresses
when shutting down mysqld via script, make the shutdown clean by waiting up to 10s
use SSL for (1) clients and xtrabackup and (2) Galera wsrep protocol
create WSREP_PROVIDER_OPTS to allow script to extend any options that are passed in by user

start-smart:
Use a separate entrypoint script, start-smart.sh
provide for mysqld running in the background while establishing consensus
instead of starting mysqld after consensus, create a signal on the chosen node to bootstrap on next startup
instead of only trying to form consensus for a certain amount of time, wait indefinitely
save original grastate.dat in case it gets modified temporarily for bootstrapping into degraded mode operation



. dbnode gets started during boot up of Docker on host
. try to join healthy cluster that isn't in read-only degraded/partitioned state
. enter read-only degraded/partitioned state
. try to establish consensus, mark which node was chosen for master
    - each node is assumed to have an entire copy of the database, so safe to form
      consensus with as few as 2 nodes, right??? this could lead to loss of a few
      transactions that were committed before partition detected: uptime at the cost
      of data safety
. exit (and get restarted by swarm manager)


mysqld.sh:
. decide whether to start from clean state or existing persisted data
   - recover grastate.dat, GTID position
. look for healthy cluster, join if found

. [[[ start a read-only mysqld ]]]
. [TAKES A WHILE] form consensus
. [[[ kill the read-only mysqld ]]]

. start healthcheck server
. start mysqld with options that have been determined



docker build -t 146686453577.dkr.ecr.us-east-2.amazonaws.com/secom-phpipam:mariadb-galera-swarm . || docker container prune -f

GALERA_ENV_START_MODE=seed docker-compose up dbnode

ecs-cli up --keypair xms1-root --capability-iam --size 1 --instance-type t2.micro --vpc vpc-2c162544 \
 --subnets subnet-10b9e278,subnet-df1584a5,subnet-e6f109aa


docker build -t 146686453577.dkr.ecr.us-east-2.amazonaws.com/secom-phpipam:phpipam . || docker container prune -f



openssl genrsa 4096 > ca-key.pem && \
openssl req -new -x509 -nodes -days 3600 -key ca-key.pem -out ca-cert.pem -batch -subj "/CN=ca.local" && \
openssl req -newkey rsa:4096 -days 3600 -nodes -keyout server-key.pem -out server-req.pem -batch -subj "/CN=server.local" && \
openssl rsa -in server-key.pem -out server-key.pem && \
openssl x509 -req -in server-req.pem -days 3600 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem && \
openssl req -newkey rsa:4096 -days 3600 -nodes -keyout client-key.pem -out client-req.pem -batch -subj "/CN=client.local" && \
openssl rsa -in client-key.pem -out client-key.pem && \
openssl x509 -req -in client-req.pem -days 3600 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem && \
openssl verify -CAfile ca-cert.pem server-cert.pem client-cert.pem && \
echo "SSL_CA_CERT_B64=$(cat ca-cert.pem | base64 -w0)" >> ../.env && \
echo "SSL_SERVER_KEY_B64=$(cat server-key.pem | base64 -w0)" >> ../.env && \
echo "SSL_SERVER_CERT_B64=$(cat server-cert.pem | base64 -w0)" >> ../.env && \
echo "SSL_CLIENT_KEY_B64=$(cat client-key.pem | base64 -w0)" >> ../.env && \
echo "SSL_CLIENT_CERT_B64=$(cat client-cert.pem | base64 -w0)" >> ../.env



docker-compose run --rm --entrypoint /bin/sh phpipam -l
docker-compose exec phpipam /bin/bash -l
source .env && docker-compose exec dbnode mysql -u root --password=$MYSQL_ROOT_PASSWORD



--tmpfs /var/lib/mysql
-v /efs/mysql-data/aws1:/var/lib/mysql
-p 8081:8081
--wsrep-sync-wait=0

docker build -t 146686453577.dkr.ecr.us-east-2.amazonaws.com/secom-phpipam:mariadb-galera-swarm . || docker container prune -f
/
docker run --rm \
 -e NODE_ADDRESS=eth0 \
 -e XTRABACKUP_PASSWORD=1234 \
 -e SYSTEM_PASSWORD=1234 \
 -e GALERA_ENV_START_MODE=node \
 -e GALERA_CLUSTER_ADDRS=172.17.0.2:4577 \
 -e GALERA_GCOMM_OPTS=?gmcast.listen_addr=tcp://0.0.0.0:4567 \
 -v /root/phpipam-eb/mariadb-galera-swarm/testdata:/var/lib/mysql \
 146686453577.dkr.ecr.us-east-2.amazonaws.com/secom-phpipam:mariadb-galera-swarm \
 envmode \
 --wsrep-provider-options=gcache.size=128M \
 --wsrep-dirty-reads=ON
