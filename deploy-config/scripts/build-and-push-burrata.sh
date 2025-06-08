#!/bin/bash

# =============================================================================
# Configuration Variables - Modify these as needed
# =============================================================================

# Docker configuration
DOCKER_IMAGE_NAME="coming-soon-client"
DOCKER_IMAGE_TAG="latest"
DOCKER_BUILD_SCRIPT="./docker-build-image.sh"

# Environment file configuration
ENVIRONMENT_FILE="../../src/environments/environment.prod.ts"
TIMESTAMP_PATTERN="buildTimestamp: '[0-9]*'"

# Output paths
IMAGES_DIR="./images"

# Default deployment target (can be overridden)
DEPLOY_TARGET="burrata"

REMOTE_PATH="/tmp/"

# =============================================================================
# Deployment Target Configurations
# =============================================================================

configure_aws() {
    SSH_KEY_PATH="../secrets/tims-analytics-v2.pem"
    SSH_HOST="ec2-user@ec2-54-174-219-218.compute-1.amazonaws.com"
    SSH_PORT=""
    DOCKER_BUILD_SCRIPT="./docker-build-image.sh"
    echo "Configured for AWS deployment"
}

configure_parrano() {
    SSH_KEY_PATH="$HOME/.ssh/id_ed25519_tim_parrano"
    SSH_HOST="tim@tqp.synology.me"
    SSH_PORT="23022"
    DOCKER_BUILD_SCRIPT="./docker-build-image.sh"
    echo "Configured for Burrata deployment"
}

configure_burrata() {
    SSH_KEY_PATH="$HOME/.ssh/id_ed25519_tim_burrata"
    SSH_HOST="tim@tqp.synology.me"
    SSH_PORT="22122"
    DOCKER_BUILD_SCRIPT="./docker-build-image.sh"
    echo "Configured for Burrata deployment"
}

# =============================================================================
# Usage Information
# =============================================================================

show_usage() {
    echo "Usage: $0 [target]"
    echo ""
    echo "Available targets:"
    echo "  aws      - Deploy to AWS EC2 (default)"
    echo "  burrata  - Deploy to Burrata server"
    echo ""
    echo "Examples:"
    echo "  $0           # Deploy to AWS (default)"
    echo "  $0 aws       # Deploy to AWS"
    echo "  $0 burrata   # Deploy to Burrata"
}

# =============================================================================
# Argument Processing
# =============================================================================

if [[ $# -gt 1 ]]; then
    echo "Error: Too many arguments"
    show_usage
    exit 1
fi

if [[ $# -eq 1 ]]; then
    case "$1" in
        aws|burrata)
            DEPLOY_TARGET="$1"
            ;;
        -h|--help|help)
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown target '$1'"
            show_usage
            exit 1
            ;;
    esac
fi

# =============================================================================
# Configure deployment target
# =============================================================================

case "$DEPLOY_TARGET" in
    aws)
        configure_aws
        ;;
    parrano)
        configure_parrano
        ;;
    burrata)
        configure_burrata
        ;;
    *)
        echo "Error: Unknown deployment target '$DEPLOY_TARGET'"
        exit 1
        ;;
esac

# Set derived variables
TAR_FILENAME="${DOCKER_IMAGE_NAME}.tar"
TAR_FILEPATH="${IMAGES_DIR}/${TAR_FILENAME}"

# =============================================================================
# Script Execution
# =============================================================================

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "This script uses docker, and it isn't running - please start docker and try again!"
    exit 1
fi

# Update build timestamp in environment file
echo "Adding deploy timestamp to ${ENVIRONMENT_FILE}..."
if [[ -f "$ENVIRONMENT_FILE" ]]; then
    sed -i "s/${TIMESTAMP_PATTERN}/buildTimestamp: '$(date +%s%3N)'/g" "$ENVIRONMENT_FILE"
else
    echo "Warning: Environment file not found at ${ENVIRONMENT_FILE}"
fi

# Build Docker image
echo "Building Docker Image..."
if [[ -f "$DOCKER_BUILD_SCRIPT" ]]; then
    "$DOCKER_BUILD_SCRIPT"
else
    echo "Warning: Docker build script not found at ${DOCKER_BUILD_SCRIPT}"
    echo "Building image directly..."
    docker build -t "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" .
fi

# Create images directory if it doesn't exist
mkdir -p "$IMAGES_DIR"

# Save Docker image as TAR file
echo "Saving Docker Image as a TAR file..."
docker image save "${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}" -o "$TAR_FILEPATH"

# Copy TAR file to target
echo "Copying TAR file to ${DEPLOY_TARGET^}..."
if [[ -f "$SSH_KEY_PATH" ]]; then
    if [[ -n "$SSH_PORT" ]]; then
        scp -i "$SSH_KEY_PATH" -P "$SSH_PORT" "$TAR_FILEPATH" "${SSH_HOST}:${REMOTE_PATH}"
    else
        scp -i "$SSH_KEY_PATH" "$TAR_FILEPATH" "${SSH_HOST}:${REMOTE_PATH}"
    fi
else
    echo "Error: SSH key not found at ${SSH_KEY_PATH}"
    exit 1
fi

echo "Deployment to ${DEPLOY_TARGET^} completed successfully!"
