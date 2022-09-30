# docker-nf

This is a netflow/sflow collector/analyzer using nfdump and nfsen. 

You need to set the volume in the docker-compose.yml file to a valid location on the docker host.  (You can create a "test" directory in the same path as this repo to try it out)

By default, it will begin collecting netflow on port 9996 and sflow on port 9997.  Make changes for your environment in the conf directory or the ARGs of the Dockerfile  

To start -
docker compose up -d

To stop - 
docker compose down

View nfsen graphs - 
http://127.0.0.1/nfsen/nfsen.php

If you need to organize flows by source IP then install the conntrack package and run the following on Docker host after container startup (docker bug https://github.com/moby/moby/issues/8795) -

sudo conntrack -D -p udp


