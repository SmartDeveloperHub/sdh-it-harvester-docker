# SDH IT Harvester Docker

Deploying and executing the __IT Harvester Frontend__ of the *Smart Developer Hub* project with Docker.

## Usage instructions

### Building the Docker image

The first step consists in building the image defined by `Dockerfile` in the repository's root directory:

```bash
docker build -t sdh/it-harvester .
```

If the *IT Harvester Frontend* distribution relies on a local data-based consumer, it will require a local data file to run. This file can be added to the image, so that it will always use the same, or it might be bound at runtime (see example in the following section).
In order to include the file as part of the image, it will be necessary to edit the `Dockerfile` configuration, and add a couple of lines:

```bash
ENV LOCAL_DATA=$HARVESTER_HOME/data/local-data.json
COPY files/local-data.json $HARVESTER_HOME/data/local-data.json
```

The first line specifies the required environment variable that points to the local data file. The second line copies the local data file from the host to its expected location within the container.

### Running the container

In order to run the *IT Harvester Frontend* it is necessary to define several environment variables:

* __TARGET__: the Jira Collector endpoint to be used by the *IT Harvester Frontend*. The endpoint can be specified using an IP address (*i.e.*, http://192.168.1.33:8080/api) or a fully qualified domain name (*i.e.*,
http://collector.ith.smartdeveloperhub.org:8080/api)

* __HTTP_HOST__: the fully qualified domain name to be used by the *IT Harvester Frontend*, so that proper dereferenciable URLs are generated. It is worth nothing that this domain name should point to the host where the container is to be run, either directly or via a reverse proxy.

* __HTTP_PORT__: the port to be used by the *IT Harvester Frontend*. This port will have to be exposed by the container. 

* __LOCAL_DATA__: the path of a file with local data if the *IT Harvester Frontend* to be run uses a local data-based backend. This file may be directly included in the image (see previous section), or made it available at runtime by mounting a host directory in the container (see example below).

Taking all of this into account a container which reuses an external data file could be executed as follows:

```bash
docker run -e "TARGET=http://collector.ith.smartdeveloperhub.org:8080/api" \ 
           -e "HTTP_PORT=8088" \
           -e "HTTP_HOST=frontend.ith.smartdeveloperhub.org" \
           -e "LOCAL_DATA=/opt/it-harvester/data/local-data.json" \
           -v $(pwd)/files/local-data.json:/opt/it-harvester/data/local-data.json \
           -p 8088:8088 \
           --name sdh-it-harvester 
           sdh/it-harvester
```

In the example above, the external data file should be located in the `files/local-data.json` directory of the current working directory, and is made available in the container at `/opt/it-harvester/data/local-data.json`, which is exactly the path that the Frontend will use at runtime.

## License

SDH-IT-Harvester-Docker is distributed under the Apache License, version 2.0.