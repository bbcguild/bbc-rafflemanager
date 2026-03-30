# Docker Build Strategy

This project uses a multi-stage Docker build strategy with a base image to optimize build times and reduce redundancy.

## Images

### rafflebase
- **File**: `Dockerfile.base`
- **Purpose**: Contains the base Python environment with all system dependencies and Python packages installed
- **Includes**:
  - Python 3.11 runtime
  - System packages (gcc, curl, sqlite3)
  - All Python dependencies from requirements.txt
  - Non-root user (app:app)
  - Data directory setup

### bbc-rafflemanager:dev (Development)
- **File**: `Dockerfile`
- **Purpose**: Development image that extends rafflebase with application code
- **Includes**:
  - Application source code
  - Development-friendly configuration
  - Exposes port 8080

### bbc-rafflemanager:latest (Production)
- **File**: `Dockerfile.production`
- **Purpose**: Production-ready image that extends rafflebase with application code
- **Includes**:
  - Application source code
  - Database initialization
  - Startup scripts
  - Health check configuration
  - Exposes port 80

## Building Images

### Option 1: Use the build script
```bash
./build-images.sh
```

### Option 2: Manual build
```bash
# Build base image first
docker build -f Dockerfile.base -t rafflebase:latest .

# Build development image (depends on rafflebase)
docker build -f Dockerfile -t bbc-rafflemanager:dev .

# Build production image (depends on rafflebase)
docker build -f Dockerfile.production -t bbc-rafflemanager:latest .
```

## Benefits

1. **Faster Development Builds**: The base image can be cached and reused, only rebuilding when dependencies change
2. **Consistent Environment**: All deployments use the same base environment
3. **Smaller Layer Changes**: Application code changes don't require rebuilding the entire dependency stack
4. **Better CI/CD**: Base image can be built once and reused across multiple builds

## Usage

```bash
# Run the development container
docker run -p 8080:8080 bbc-rafflemanager:dev

# Run the production container
docker run -p 80:80 bbc-rafflemanager:latest

# For development with volume mounting (live code updates)
docker run -p 8080:8080 -v $(pwd):/app bbc-rafflemanager:dev
```

## Updating Dependencies

When you need to update Python dependencies:

1. Modify `requirements.txt`
2. Rebuild the base image: `docker build -f Dockerfile.base -t rafflebase:latest .`
3. Rebuild the production image: `docker build -f Dockerfile.production -t bbc-rafflemanager:latest .`

The base image should be rebuilt and pushed to your registry when dependencies change, allowing all team members and deployment environments to use the updated base.
