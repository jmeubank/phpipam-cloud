This is a project to run the phpIPAM software for Secom in a hybrid cloud deployment,
using Docker containers and a clustered mySQL-compatible database.

The design specifies two homogenous stacks:

   PRIVATE CLOUD ---------------- PUBLIC CLOUD
[phpIPAM container]           [phpIPAM container]
[database container]          [database container]

The database containers are multi-master members of a 2-node cluster such that
each can perform synchronous reads and writes during normal operation. In the case
of partitioning, the private cloud side loses its synchronous view of the cluster,
being weighted lower than the public cloud, and the private cloud side enters
read-only mode until communication is restored.
