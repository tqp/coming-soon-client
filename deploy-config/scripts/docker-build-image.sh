#!/bin/bash

export IMAGE_TAG=coming-soon-client
export IMAGE_VERSION=latest

echo "IMAGE: ${IMAGE_TAG}:${IMAGE_VERSION}"

pushd ../..
rm -rf dist
docker build -f Dockerfile -t ${IMAGE_TAG}:${IMAGE_VERSION} .
