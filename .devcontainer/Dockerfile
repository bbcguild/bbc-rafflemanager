# Use Python 3.11 as base image
FROM python:3.11-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Essential build tools
    build-essential \
    curl \
    git \
    # Database clients
    sqlite3 \
    postgresql-client \
    # For crypto libraries
    libffi-dev \
    libssl-dev \
    # For potential image processing
    libjpeg-dev \
    libpng-dev \
    # Text processing
    gettext \
    # Network tools for debugging
    netcat \
    telnet \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up Python environment
RUN pip install --upgrade pip setuptools wheel

# Copy requirements first for better Docker layer caching
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies
RUN pip install -r /tmp/requirements.txt

# Install additional development dependencies
RUN pip install \
    black \
    pylint \
    pytest \
    pytest-cov \
    ipython \
    jupyter \
    waitress

# Set the working directory
WORKDIR /workspaces/bbc-rafflemanager

# Switch to the non-root user
USER $USERNAME

# Create necessary directories
RUN mkdir -p /tmp && \
    mkdir -p /home/$USERNAME/.local/bin

# Set PATH to include local bin
ENV PATH="/home/$USERNAME/.local/bin:$PATH"

# Expose the application port
EXPOSE 8080

# Keep container running for development
CMD ["tail", "-f", "/dev/null"]
