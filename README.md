# Google Cloud Run docker deploy example

In this example we will deploy a simple Flask app to Google Cloud Run using Docker and 
the Google Arrifact Registry (which could be easily replaced by another container 
regigistry like Dockerhub).


## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) 
- [Docker](https://docs.docker.com/get-docker/)
- [Enable the Google Cloud Run API](https://console.cloud.google.com/apis/library/run.googleapis.com)
- [Enable the Google Artifact Registry API](https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com)
- Set the appropriate IAM permissions


## Test run app locally

Run the following commands in the root directory of the project to configure the virtual environment. Note that other versions of python should work as well, but this is what I'm using.

```
virtualenv -p python3.10 venv
source venv/bin/activate
pip install -r requirements.txt
```

The following line will start the Flask app.

```
python main.py
```


## Variables

The following variables are used throughout this README and should be replaced with the appropriate values for your project.

| Variable | Explanation | Example |
| :- | :- | :- |
| `LOCATION` | The region of the Artifact Registry you created in the previous steps | `us-central1` |
| `PROJECT_NAME` | The name of the project you are deploying to | `my-project` |
| `REPOSITORY_NAME` | The name of the repository you created in the previous steps | `my-repository` |
| `IMAGE_NAME` | The name of the image you are building | `hello-world` |
| `TAG` | The version of the image | `0.0.1` |


## Create Artifact Registry repository

Do either of the following, where `REPOSITORY_NAME` is the name of the repository you want to create.

### Command line
```
gcloud artifacts repositories create REPOSITORY_NAME --location=us-central1
```

### Console
Click "+CREATE REPOSITORY" in the [Artifact Registry console](https://console.cloud.google.com/artifacts).


## Build docker image

Now we will build the docker image. We will set the name in such way that the image can be pushed to the Artifact Registry in the next steps. MacOS M1 users will need to use a different command.

### All other operating systems
```
docker build -t LOCATION-docker.pkg.dev/PROJECT_NAME/REPOSITORY_NAME/IMAGE_NAME:TAG .
```

### MacOS M1
```
docker build -platform linux/amd64 -t LOCATION-docker.pkg.dev/PROJECT_NAME/REPOSITORY_NAME/IMAGE_NAME:TAG .
```
For users that are working on a MacOS M1, the `-platform linux/amd64` flag is required to build the image for the x86_64 architecture, otherwise you'll get the "Failed to start and then listen on the port defined by the PORT environment variable" error when creating a Cloud Run service later on. ([reference](https://stackoverflow.com/questions/66127933/cloud-run-failed-to-start-and-then-listen-on-the-port-defined-by-the-port-envi))


## Run docker container of the image locally

This command will run a docker container of the image locally:
```
docker run --env PORT=8080 -p 8080:8080 LOCATION-docker.pkg.dev/PROJECT_NAME/REPOSITORY_NAME/IMAGE_NAME:TAG
```
The `--env` flag is used to set the environment variables for the container. Because in the `Dockerfile` we use the `$PORT` environment variable, we need to pass the `PORT` environment variable when running the container. When creating a Cloud Run service, the `PORT` environment variable is set by the Cloud Run service.
The `-p` flag is used to map the port 8080 of the container to the port 8080 of the host.

## Push docker image to Artifact Registry

This command will push the docker image to the Artifact Registry:
```
docker push LOCATION-docker.pkg.dev/PROJECT_NAME/REPOSITORY_NAME/IMAGE_NAME:TAG
```

## Deploy to Cloud Run

### Command line
This command will deploy the docker image to Cloud Run:
```
gcloud run deploy SERVICE_NAME --image LOCATION-docker.pkg.dev/PROJECT_NAME/REPOSITORY_NAME/IMAGE_NAME:TAG --platform managed --region LOCATION
```

gcloud run deploy qqq --image europe-west4-docker.pkg.dev/all-my-lovely-experiments/whatapp-bot/yyy --platform managed --region europe-west4

### Console
Click "+CREATE SERVICE" in the [Cloud Run console](https://console.cloud.google.com/run). Fill in the appropriate values for the service and make sure to check the "Allow unauthenticated invocations" checkbox.
