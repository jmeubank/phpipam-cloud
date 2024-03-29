This is a project to run the phpIPAM software for Secom in a hybrid cloud deployment,
using Docker containers and a clustered mySQL-compatible database.

The design specifies two homogenous stacks:

   PRIVATE CLOUD ---------------- PUBLIC CLOUD
[phpIPAM container]           [phpIPAM container]
[database container]          [database container]

The database containers are multi-master members of a 2-node cluster such that
each can perform synchronous reads and writes during normal operation. In the case
of partitioning, the private cloud side loses its synchronous view of the cluster,
and enters read-only mode until communication is restored.

TODO:
 * Database auto-clustering - if a node is rebuilt from scratch it should be
   able to automatically rejoin the existing cluster and suck down the database
 * Database snapshots - take daily snapshots of the database files, preferably
   in a quiesced state, so that new containers can boot straight up from
   an existing snapshot
    * Do a scheduled mysqldump into backup directory
    * Rdiff-backup the backup directory
    * Startup code for the database should import from the backup directory if
      the app is booting from scratch and can't join an existing cluster
 * Infrastructure as code via Terraform, Saltstack, or similar
    * Shared infra:
       * ContainerHost1
       * AWS VPC
       * DNS hosting service
    * Instantiated for the app:
       * ECS service
       * EC2 t2.micro instance
       * EC2 security group
       * DNS record(s)
