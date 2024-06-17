# syntax=docker/dockerfile:1

FROM python:3.10-slim-bullseye

# Allow statements and log messages to immediately appear in the logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
WORKDIR /app
COPY . ./

# Install production dependencies.
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Not required, but useful for letting other developers which 
# ports are intended to be published.
# https://docs.docker.com/reference/dockerfile/#expose
EXPOSE 8080

CMD exec gunicorn --bind :$PORT main:app
