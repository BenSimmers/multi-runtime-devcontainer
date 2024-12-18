ARG VARIANT="noble"
FROM buildpack-deps:${VARIANT}-curl

# Label the image to describe its features
LABEL dev.containers.features="common"

# Check and delete the 'ubuntu' user if the variant is 'noble'
ARG VARIANT
RUN if [ "$VARIANT" = "noble" ]; then \
        if id "ubuntu" &>/dev/null; then \
            echo "Deleting user 'ubuntu' for $VARIANT" && userdel -f -r ubuntu || echo "Failed to delete ubuntu user for $VARIANT"; \  
        else \
            echo "User 'ubuntu' does not exist for $VARIANT"; \
        fi; \
    fi


ARG user_id=1000
ARG group_id=${user_id}
ARG usr=bensimmersdev
ARG workspace_env_name=workspace

# Set environment variables for package installation and locale
ENV FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV SHELL /bin/bash

# Update package list, install necessary packages, and clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  bash-completion \
  sudo \
  git \
  ssh \
  vim \
  wget \
  curl \
  dpkg \
  gnupg \
  apt-transport-https \
  ca-certificates \
  build-essential \
  software-properties-common \
  libicu-dev \
  unzip \
  jq \
  htop \
  less \
  man \
  net-tools \
  iputils-ping \
  dnsutils \
  iproute2 \
  man-db \
  manpages \
  nano \
  tmux \
  locales \
  neofetch \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8


RUN groupadd --gid ${group_id} ${usr} && \
  useradd --uid ${user_id} --gid ${group_id} -m ${usr} && \
  echo "${usr} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${usr} && \
  chmod 0440 /etc/sudoers.d/${usr} && \
  mkdir -p /${workspace_env_name} && \
  chown -R ${user_id}:${group_id} /home/${usr} /${workspace_env_name} || { echo "Failed to create user or workspace"; exit 1; }

USER ${usr}
WORKDIR /${workspace_env_name}

RUN mkdir -p ~/bin ~/scripts
