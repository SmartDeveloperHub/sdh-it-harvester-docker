# SDH IT Harvester Docker

Deploying and executing the __IT Harvester__ of the *Smart Developer Hub* project with Docker.

## Usage instructions

### Building the Docker images

The first step consists in building the image for the __IT Harvester Frontend__ defined by `Dockerfile` in the repository's root directory:

```bash
docker build -t sdh/it-harvester-frontend .
```

If the *IT Harvester Frontend*  is to use a local data-based backend, it will require a local data file to run. This file can be added to the image, so that it will always use the same, or it might be bound at runtime (see example in the following section).
In order to include the file as part of the image, it will be necessary to edit the `Dockerfile` configuration, and add a couple of lines:

```bash
ENV LOCAL_DATA=$HARVESTER_HOME/data/local-data.json
COPY files/local-data.json $HARVESTER_HOME/data/local-data.json
```

The first line specifies the required environment variable that points to the local data file. The second line copies the local data file from the host to its expected location within the container.

The first step consists in building the image for the __IT Harvester Backend (Jira Collector)__ defined by `Dockerfile` in the repository's `collector` directory:

```bash
docker build -t sdh/it-harvester-backend collector
```

The *IT Harvester Backend*  requires a couple of configuration files to run. These files can be added to the image, so that it will always use the same, or they might be bound at runtime (see example in the following section). In order to include the files as part of the image, it will be necessary to edit the `Dockerfile` configuration, and add a couple of lines:

```bash
ENV CONFIG=$HARVESTER_HOME/collector.cfg
COPY files/collector.cfg $HARVESTER_HOME/collector.cfg
COPY files/contributor.mails $HARVESTER_HOME/contributor.mails
```

The first line specifies the required environment variable that points to the configuration file. The second line copies the configuration file from the host to its expected location within the container. The third line copies the contributors configuration file specified in the main configuration file from the host to its expected location within the container.

### Running the containers

In order to run the *IT Harvester Frontend* it is necessary to define several environment variables:

* __HTTP_HOST__: the fully qualified domain name to be used by the *IT Harvester Frontend*, so that proper dereferenciable URLs are generated. It is worth nothing that this domain name should point to the host where the container is to be run, either directly or via a reverse proxy.

* __HTTP_PORT__: the port to be used by the *IT Harvester Frontend*. This port will have to be exposed by the container. 

* __TARGET__: the Jira Collector endpoint to be used by the *IT Harvester Frontend*. The endpoint can be specified using an IP address (*e.g.*, http://192.168.1.33:8080/api) or a fully qualified domain name (*e.g.*, http://collector.ith.smartdeveloperhub.org:8080/api). This parameter is required regardless the *BACKEND_FACTORY* specified.

* __BACKEND_FACTORY [OPTIONAL]:__ the class name of the BackendControllerFactory to use for creating the backend that the *IT Harvester Frontend* will use for retrieving the data. The first version of the *IT Harvester Frontend* includes to candidates:
  * *org.smartdeveloperhub.harvesters.it.frontend.controller.RemoteBackendControllerFactory*: the factory will create a controller that will use the Jira Collector Remote REST API to retrieve data from the collector endpoint specified using the *TARGET* environment variable.
  * *org.smartdeveloperhub.harvesters.it.frontend.controller.LocalBackendControllerFactory*: the factory will create a local data-based backend that will obtain the data from a local data file specified using the *LOCAL_DATA* environment variable.

  If this environment variable is not specified the *IT Harvester Frontend* will try them in order.

* __LOCAL_DATA [OPTIONAL]:__ the path of a file with local data if the *IT Harvester Frontend* to be run uses a local data-based backend. This file may be directly included in the image (see previous section), or made available at runtime by mounting a host directory in the container (see example below).

Taking all of this into account a container which reuses an external data file could be executed as follows:

```bash
docker run -e "HTTP_HOST=frontend.ith.smartdeveloperhub.org" \
           -e "HTTP_PORT=8088" \
           -e "TARGET=http://collector.ith.smartdeveloperhub.org:8080/api" \ 
           -e "BACKEND_FACTORY=org.smartdeveloperhub.harvesters.it.frontend.controller.LocalBackendControllerFactory" \
           -e "LOCAL_DATA=/opt/it-harvester/data/local-data.json" \
           -v $(pwd)/files/local-data.json:/opt/it-harvester/data/local-data.json \
           -p 8088:8088 \
           --name sdh-it-harvester-frontend \
           sdh/it-harvester-frontend
```

In the example above, the external data file should be located in the `files/local-data.json` directory of the current working directory, and is made available in the container at `/opt/it-harvester/data/local-data.json`, which is exactly the path that the *IT Harvester Frontend* will use at runtime.

In order to run the *IT Harvester Backend* it is necessary to define several environment variables:

* __VERSION__: the version of the Jira Collector to use. It must be a stable version (*e.g.*, 0.1.0), not a snapshot one (*e.g.*, 0.1.0-SNAPSHOT). 

* __CONFIG__: the path to the configuration file. This file may be directly included in the image (see previous section), or made available at runtime by mounting a host directory in the container (see example below). The configuration file specifies, among other details, the port to be used by the *Jira Collector*. This port will have to be exposed by the container. 

Bearing this in mind, a container which reuses an external configuration file could be executed as follows:

```bash
docker run -e "VERSION=0.1.0" \
           -e "CONFIG=/opt/it-harvester-backend/collector.cfg" \
           -v $(pwd)/config:/opt/it-harvester-backend \
           -p 8088:8088 \
           --name sdh-it-harvester-backend \
           sdh/it-harvester-backend
```

In the example above, the container will run version `0.1.0` of the *IT Harvester Backend*, which will use the configuration file at `/opt/it-harvester-backend/collector.cfg`. This file will be linked from the host, in particular from the `config` directory of the current working directory. The example assumes that the *IT Harvester Backend* is configured to use port `8088`, and thus this port is exposed by the container as is.

### Creating local data files

Local data files include data for each one of the entities returned by the *REST API* of the __IT Collector__, that is: *contributors*, *commits*, *projects*, *components*, *versions*, and *issues*. Contributors, commits, and projects are stored in *arrays*, whereas components, versions, and issues are stored in *arrays indexed* by __project identifier__. In particular, local data files must conform to the following *JSON Schema* ([see here](https://tools.ietf.org/html/draft-zyp-json-schema-04)):

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "id": "http://www.smartdeveloperhub.org/harvesters/it/local-data#",
  "type": "object",
  "properties": {
    "collector": { "$ref": "#/definitions/collector" },
    "contributors": {
      "type": "array",
      "items": { "$ref": "#/definitions/contributor" },
      "uniqueItems": true
    },
    "commits": {
      "type": "array",
      "items": { "$ref": "#/definitions/commit" },
      "uniqueItems": true
    },
    "projects": {
      "type": "array",
      "items": { "$ref": "#/definitions/project" },
      "uniqueItems": true
    },
    "projectComponents": {
      "type": "object",
      "patternProperties": {
        "^[a-fA-F0-9]+$": { 
          "type": "array",
          "items": { "$ref": "#/definitions/component" },
          "uniqueItems": true
        }
      }
    },
    "projectVersions": {
      "type": "object",
      "patternProperties": {
        "^[a-fA-F0-9]+$": { 
          "type": "array",
          "items": { "$ref": "#/definitions/version" },
          "uniqueItems": true
        }
      }
    },
    "projectIssues": {
      "type": "object",
      "patternProperties": {
        "^[a-fA-F0-9]+$": { 
          "type": "array",
          "items": { "$ref": "#/definitions/issue" },
          "uniqueItems": true
        }
      }
    }
  },
  "additionalProperties": false,
  "required": [ "collector", "contributors", "commits", "projects", "projectComponents", "projectVersions", "projectIssues" ],
  "definitions": {
    "collector": {
      "type": "object",
      "properties": {
        "version": {
          "type": "string",
          "minLength": 1
        }
      },
      "additionalProperties": false,
      "required": [ "version" ]
    },
    "contributor": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "name": {
          "type": "string",
          "minLength": 1
        },
        "emails": {
          "type": "array",
          "items": { 
            "type": "string",
            "format": "email"
          },
          "minItems": 1,
          "uniqueItems": true
        }
      },
      "additionalProperties": false,
      "required": [ "id", "name", "emails" ]
    },
    "commit": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "repository": {
          "type": "string",
          "minLength": 1
        },
        "branch": {
          "type": "string",
          "minLength": 1
        },
        "hash": {
          "type": "string",
          "minLength": 1
        }
      },
      "additionalProperties": false,
      "required": [ "id", "repository", "branch", "hash" ]
    },
    "project": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "name": {
          "type": "string",
          "minLength": 1
        },
        "versions": { "$ref" : "#/definitions/stringArray" },
        "components": { "$ref" : "#/definitions/stringArray" },
        "topIssues": { "$ref" : "#/definitions/stringArray" },
        "issues": { "$ref" : "#/definitions/stringArray" }
      },
      "additionalProperties": false,
      "required": [ "id", "name", "versions", "components", "topIssues", "issues" ]
    },
    "component": {
      "type": "object",
      "properties": {
        "projectId": {
          "type": "string",
          "minLength": 1
        },
        "id": {
          "type": "string",
          "minLength": 1
        },
        "name": {
          "type": "string",
          "minLength": 1
        }
      },
      "additionalProperties": false,
      "required": [ "projectId", "id", "name" ]
    },
    "version": {
      "type": "object",
      "properties": {
        "projectId": {
          "type": "string",
          "minLength": 1
        },
        "id": {
          "type": "string",
          "minLength": 1
        },
        "name": {
          "type": "string",
          "minLength": 1
        }
      },
      "additionalProperties": false,
      "required": [ "projectId", "id", "name" ]
    },
    "issue": {
      "type": "object",
      "properties": {
        "projectId": {
          "type": "string",
          "minLength": 1
        },
        "id": {
          "type": "string",
          "minLength": 1
        },
        "name": {
          "type": "string",
          "minLength": 1
        },
        "description": {
          "type": "string"
        },
        "type":     { "enum": [ "BUG", "IMPROVEMENT", "TASK" ] },
        "status":   { "enum": [ "OPEN", "IN_PROGRESS", "CLOSED" ] },
        "severity": { "enum": [ "BLOCKER", "CRITICAL", "SEVERE", "LOW", "TRIVIAL" ] },
        "priority": { "enum": [ "VERY_HIGH", "HIGH", "MEDIUM", "LOW" ] },
        "creationDate": {
          "type": "string",
          "format": "date-time"
        },
        "opened": {
          "type": "string",
          "format": "date-time"
        },
        "closed": {
          "type": "string",
          "format": "date-time"
        },
        "dueTo": {
          "type": "string",
          "format": "date-time"
        },
        "estimatedTime": {
          "type": "string",
          "format": "duration"
        },
        "reporter": {
          "type": "string",
          "minLength": 1
        },
        "assignee": {
          "type": "string",
          "minLength": 1
        },
        "versions":      { "$ref": "#/definitions/stringArray" },
        "components":    { "$ref": "#/definitions/stringArray" },
        "tags":          { "$ref": "#/definitions/stringArray" },
        "commits":       { "$ref": "#/definitions/stringArray" },
        "childIssues":   { "$ref": "#/definitions/stringArray" },
        "blockedIssues": { "$ref": "#/definitions/stringArray" },
        "changes":       { "$ref": "#/definitions/changeLog" }
      },
      "additionalProperties": false,
      "required": [ "projectId", "status", "severity", "priority", "creationDate", "opened", "reporter", "assignee", "id", "name" ]
    },
    "changeLog": {
      "type": "object",
      "properties": {
        "entries": {
          "type": "array",
          "items": { "$ref": "#/definitions/changeLogEntry" },
          "uniqueItems": true
        }
      },
      "additionalProperties": false,
      "required": [ "entries" ]
    },
    "changeLogEntry": {
      "type": "object",
      "properties": {
        "author": {
          "type": "string",
          "minLength": 1
        },
        "timeStamp": {
          "type": "string",
          "format": "date-time"
        },
        "items": {
          "type": "array",
          "items": {
            "type": "object",
            "oneOf": [
              { "$ref": "#/definitions/valueAdded" },
              { "$ref": "#/definitions/valueDeleted" },
              { "$ref": "#/definitions/valueModified" }
            ]
          },
          "uniqueItems": true
        }
      },
      "additionalProperties": false,
      "required": [ "author", "timeStamp", "items"]
    },
    "valueAdded": {
      "type": "object",
      "properties": {
        "property": {
          "type": "string",
          "minLength": 1
        },
        "newValue": {
          "type": "string",
          "minLength": 1
        }
      },
      "additionalProperties": false,
      "required": [ "property", "newValue" ]
    },
    "valueDeleted": {
      "type": "object",
      "properties": {
        "property": {
          "type": "string",
          "minLength": 1
        },
        "oldValue": {
          "type": "string",
          "minLength": 1
        }
      },
      "additionalProperties": false,
      "required": [ "property", "oldValue" ]
    },
    "valueModified": {
      "type": "object",
      "properties": {
        "property": {
          "type": "string",
          "minLength": 1
        },
        "oldValue": {
          "type": "string",
          "minLength": 1
        },
        "newValue": {
          "type": "string",
          "minLength": 1
        }
      },
      "additionalProperties": false,
      "required": [ "property", "oldValue", "newValue" ]
    },
    "stringArray": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1
      },
      "uniqueItems": true
    }
  }
}
```

Example local data files can be created using the *Project Data Generator* available in the *IT Harvester Frontend distribution* __testing-utils__ bundle [available at Sonatype's OSS Nexus Repository](https://repo.maven.apache.org/maven2/org/smartdeveloperhub/harvesters/it/frontend/it-frontend-dist/0.1.0/it-frontend-dist-0.1.0-testing-utils.zip).

The generator requires Java 7 to be available in the path. Once unzipped, for example in the current working directory, the generator can be run like this:

```bash
./testing-utils-0.1.0/bin/generator.sh <path-to-file>
```

Where `<path-to-file>` is the name of the file where the local data will be written to.


The IT Harvester Backend configuration file __collector.cfg__ it must follow the next structure:

```bash
# Jira Credentials
jiraUrl=www.example.jira.instance.com
JiraUsername=jira_username # Username used in jira instance
JiraPassword=j1r4_p4ssw0rd # Password for jira user

# RabbitAMQ Configuration
brokerHost=server.rabbit.com
brokerPort=5672
virtualHost=/
exchangeName=itcollector

# Redis Server Configuration
redisServer=server.redis.com
redisPort=6379

# Collector service parameters
softwareVersion=1.0.0
instance=www.host.url.com:8088 # For identifying Collector instance
servletPort=8088
servletPath=/*
collectorPeriodicity = 60 # time in seconds for crawling

# File with additional contributor mails
contributorsFile = /opt/it-harvester-backend/contributor.mails
```

The __contributor.mails__ file must contains one line for contributor with the following schema:
```bash
jira_nick name@domain.com
```
## License

SDH-IT-Harvester-Docker is distributed under the Apache License, version 2.0.
