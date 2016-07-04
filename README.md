# SDH IT Harvester Docker

Deploying and executing the __IT Harvester Frontend__ of the *Smart Developer Hub* project with Docker.

## Usage instructions

### Building the Docker image

The first step consists in building the image defined by `Dockerfile` in the repository's root directory:

```bash
docker build -t sdh/it-harvester .
```

### Running the container

In order to run the *IT Harvester Frontend* it is necessary to define several environment variables:

* __TARGET__: the Jira Collector endpoint to be used by the *IT Harvester Frontend*. The endpoint can be specified using an IP address (*i.e.*, http://192.168.1.33:8080/api) or a fully qualified domain name (*i.e.*,
http://collector.ith.smartdeveloperhub.org:8080/api)

* __HTTP_HOST__: the fully qualified domain name to be used by the *IT Harvester Frontend*, so that proper dereferenciable URLs are generated. It is worth nothing that this domain name should point to the host where the container is to be run, either directly or via a reverse proxy.

* __HTTP_PORT__: the port to be used by the *IT Harvester Frontend*. This port will have to be exposed by the container. 

Taking all of this into account a container could be executed as follows:

```bash
docker run -e "TARGET=http://collector.ith.smartdeveloperhub.org:8080/api" \ 
           -e "HTTP_PORT=8088" \
           -e "HTTP_HOST=frontend.ith.smartdeveloperhub.org" \
           -p 8088:8088 \
           --name sdh-it-harvester 
           sdh/it-harvester
```

## License

SDH-IT-Harvester-Docker is distributed under the Apache License, version 2.0.