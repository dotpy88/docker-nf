# docker-nf

This is a netflow/sflow collector using nfdump and nfsen. 

You need to set the volume in the docker-compose.yml file to a valid location on the docker host.  (You can create a "test" directory in the same path as this repo to try it out)

By default, it will begin collecting netflow on port 9996 and sflow on port 9997.  Make changes to the confs in the conf directory if needed.  

To start -
docker compose up -d

To stop - 
docker compose down

