#!/bin/bash

# Prompt for sudo password at the start so script is not interrupted when docker commands execute
sudo -v

# Clone the repository
git clone https://github.com/lalswapnil/automatic1111-docker

# Navigate into the cloned directory
cd automatic1111-docker

# Run build and start for container
sudo docker-compose up --build
