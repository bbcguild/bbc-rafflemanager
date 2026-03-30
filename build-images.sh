#!/bin/bash

# Build script for BBC Raffle Manager Docker images

set -e

echo "Building rafflebase image..."
docker build -f Dockerfile.base -t rafflebase:latest .

echo "Building development image..."
docker build -f Dockerfile -t bbc-rafflemanager:dev .

echo "Building production image..."
docker build -f Dockerfile.production -t bbc-rafflemanager:latest .

echo "Build complete!"
echo ""
echo "Images created:"
echo "  rafflebase:latest              - Base image with Python environment and dependencies"
echo "  bbc-rafflemanager:dev          - Development image with application code"
echo "  bbc-rafflemanager:latest       - Production image with application code"
echo ""
echo "To run the development container:"
echo "  docker run -p 8080:8080 bbc-rafflemanager:dev"
echo ""
echo "To run the production container:"
echo "  docker run -p 80:80 bbc-rafflemanager:latest"
