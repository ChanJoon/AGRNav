FROM nvidia/cuda:12.8.0-devel-ubuntu20.04
ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compute,utility
ENV DEBIAN_FRONTEND noninteractive

# Install OpenGL libraries for visualization (replaces cudagl functionality)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libglu1-mesa \
    mesa-utils \
    && rm -rf /var/lib/apt/lists/*

# Basic dependencies and tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    less \
    emacs \
    tmux \
    bash-completion \
    command-not-found \
    software-properties-common \
    xsel \
    xdg-user-dirs \
    pcl-tools \
    libomp5 \
    curl \
    wget \
    bzip2 \
    locate \
    git \
    tree \
    ripgrep \
    ca-certificates \
    build-essential \
    cmake \
    unzip \
    fd-find \
    vulkan-utils


# ROS Noetic
RUN apt-get update
RUN apt-get install --assume-yes apt-utils
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN apt-get update
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-desktop-full \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    build-essential

# Additional ROS packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-derived-object-msgs \
    ros-noetic-ackermann-msgs \
    libarmadillo-dev \
    ros-noetic-pcl-conversions \
    ros-noetic-pcl-ros

ARG NLOPT_VERSION=2.7.1
RUN wget -q "https://github.com/stevengj/nlopt/archive/refs/tags/v${NLOPT_VERSION}.tar.gz" -O /tmp/nlopt.tar.gz && \
    tar -xzf /tmp/nlopt.tar.gz -C /tmp && \
    cmake -S /tmp/nlopt-${NLOPT_VERSION} -B /tmp/nlopt-build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DNLOPT_PYTHON=OFF \
      -DNLOPT_GUILE=OFF \
      -DNLOPT_MATLAB=OFF \
      -DNLOPT_OCTAVE=OFF \
      -DNLOPT_SWIG=OFF && \
    cmake --build /tmp/nlopt-build --parallel && \
    cmake --install /tmp/nlopt-build && \
    ldconfig && \
    rm -rf /tmp/nlopt.tar.gz /tmp/nlopt-${NLOPT_VERSION} /tmp/nlopt-build

RUN rosdep init
RUN rosdep update
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

# Install micromamba for Python environment management
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C / bin/micromamba
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV MAMBA_EXE=/bin/micromamba

# Create Python 3.10 environment with micromamba and install packages
RUN /bin/micromamba create -n agrnav python=3.10 -y -c conda-forge && \
    /bin/micromamba run -n agrnav pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128 && \
    /bin/micromamba run -n agrnav pip install pyyaml rospkg imageio numpy

# Install tmux, vim and git
RUN apt-get install -y tmux vim git libsdl-image1.2-dev libsdl-dev libpcl-dev pcl-tools

# Initialize micromamba for interactive shells
RUN /bin/micromamba shell init --shell bash --root-prefix=/opt/conda && \
    echo "micromamba activate agrnav" >> ~/.bashrc
# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["bash"]
