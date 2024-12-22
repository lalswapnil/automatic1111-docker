# Use an Ubuntu 22.04 base image with CUDA 12.6 support
FROM nvidia/cuda:12.6.0-base-ubuntu22.04

# Install dependencies and Python 3.10.6
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    bash \
    sudo \
    git \
    curl \
    sed \
    libgoogle-perftools-dev \
    python3.10-venv \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes repository to install Python 3.10
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update && apt-get install -y \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.10
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3.10 get-pip.py && \
    rm get-pip.py

# Create a non-root user and set a password as "default"
RUN useradd -ms /bin/bash appuser && \
    echo "appuser:default" | chpasswd

# Create a symlink for python3.10 as python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Set working directory
WORKDIR /app

# Get latest automatic1111 release
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /app

# Modify the webui-user.sh file to add COMMANDLINE_ARGS
RUN sed -i 's|#export COMMANDLINE_ARGS=""|export COMMANDLINE_ARGS="--listen --api --allow-code --administrator"|' /app/webui-user.sh

# Grant sudo privileges to appuser
RUN echo "appuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/appuser

# Ensure webui.sh is executable as root
RUN chmod +x /app/webui.sh

# Change ownership of the application files to the non-root user
RUN chown -R appuser:appuser /app

# Set the PATH for appuser to include Python binaries
RUN echo "export PATH=/usr/bin/python3.10:/usr/local/bin:$PATH" >> /home/appuser/.bashrc

# Switch to the non-root user
USER appuser

# Set the default command to run your script
CMD ["bash", "webui.sh"]
