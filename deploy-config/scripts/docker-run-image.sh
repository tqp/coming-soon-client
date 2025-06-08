#!/bin/bash

export IMAGE_TAG=coming-soon-client
export IMAGE_VERSION=latest

echo "IMAGE: ${IMAGE_TAG}:${IMAGE_VERSION}"

## Detached (-d), interactive (-it), self-cleaning (--rm), on port 80 (-p)
docker run -it --rm -p 4200:80/tcp -p 443:443/tcp --name coming-soon-client ${IMAGE_TAG}:${IMAGE_VERSION}
#docker run -it -p 80:80 ${IMAGE_TAG}:${IMAGE_VERSION}
#docker run -it --rm -p 80:80 ${IMAGE_TAG}:${IMAGE_VERSION}
#docker run -d --rm -p 80:80 ${IMAGE_TAG}:${IMAGE_VERSION}

