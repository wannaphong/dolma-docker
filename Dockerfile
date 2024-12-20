FROM ubuntu:noble
SHELL ["/bin/bash", "-c"]
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    nano \
    build-essential \
    libtool \
    autoconf \
    unzip \
    wget \
    pkg-config \
    libssl-dev \
    git \
    locales \
    make \
    sudo \
    protobuf-compiler \
    cargo \
    && apt -y install --reinstall ca-certificates \
    && update-ca-certificates -f \
    && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
RUN wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
ENV DEBIAN_FRONTEND noninteractive
RUN bash Miniforge3-$(uname)-$(uname -m).sh -b

RUN mkdir -p /workspaces/
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# RUN echo "source activate base" >> ~/.bashrc
# RUN echo "echo 'Happy hacking!\n'" >> ~/.bashrc
ENV PATH "/root/miniforge3/bin:${PATH}"
RUN source ~/.bashrc
WORKDIR /workspaces/
RUN conda create -n dolma_env python=3.12.8 pyicu=2.11 make=4.4.1 cmake=3.31.2
RUN echo "source activate dolma_env" > ~/.bashrc
ENV PATH /opt/conda/envs/dolma_env/bin:$PATH
ENV CONDA_DEFAULT_ENV dolma_env
RUN conda init bash
ENV BASH_ENV ~/.bashrc
SHELL ["/bin/bash", "-c"]
RUN source ~/.bashrc
RUN conda activate dolma_env
RUN pip install "maturin[patchelf]>=1.1,<2.0"
RUN pip install --upgrade pip
ENV PATH /root/.cargo/bin:$PATH
RUN git clone https://github.com/allenai/dolma.git dolma_build
WORKDIR /workspaces/dolma_build
RUN git checkout a8242205733d6df988b2fa04a96ac0779f277972
RUN apt-get update
RUN make
RUN make develop
RUN pip install -e .
RUN pip show dolma
RUN pip uninstall -y dolma
WORKDIR /workspaces/
