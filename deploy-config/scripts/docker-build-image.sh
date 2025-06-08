#!/bin/bash

# =============================================================================
# Configuration Variables
# =============================================================================

export IMAGE_TAG=coming-soon-client
export IMAGE_VERSION=latest

# Output configuration
IMAGES_DIR="deploy-config/images"
TAR_FILENAME="${IMAGE_TAG}.tar"

# =============================================================================
# Script Execution
# =============================================================================

echo "IMAGE: ${IMAGE_TAG}:${IMAGE_VERSION}"

# Navigate to project root and clean previous build
pushd ../..
rm -rf dist

# Build Docker image
echo "Building Docker image..."
docker build -f Dockerfile -t ${IMAGE_TAG}:${IMAGE_VERSION} .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Docker build completed successfully"

    # Create images directory if it doesn't exist
    mkdir -p "$IMAGES_DIR"

    # Save Docker image as TAR file
    echo "Saving Docker image to ${IMAGES_DIR}/${TAR_FILENAME}..."
    docker image save "${IMAGE_TAG}:${IMAGE_VERSION}" -o "${IMAGES_DIR}/${TAR_FILENAME}"

    if [ $? -eq 0 ]; then
        echo "Docker image saved successfully to ${IMAGES_DIR}/${TAR_FILENAME}"
    else
        echo "Error: Failed to save Docker image"
        popd
        exit 1
    fi
else
    echo "Error: Docker build failed"
    popd
    exit 1
fi

popd

echo "Build and save process completed successfully!"
