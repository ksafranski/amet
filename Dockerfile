FROM ubuntu:18.04

ARG username
ARG password

RUN apt update && apt install -y \
      git zsh apt-transport-https \
      ca-certificates curl software-properties-common \
      build-essential wget openssl net-tools locales \
      vim

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

RUN apt-key fingerprint 0EBFCD88

RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Docker
RUN apt-get update && \
    apt-get install -y docker-ce

# Code Server
RUN wget https://github.com/codercom/code-server/releases/download/1.32.0-310/code-server-1.32.0-310-linux-x64.tar.gz && \
    tar -xvzf code-server-1.32.0-310-linux-x64.tar.gz -C /tmp && \
    mv /tmp/code-server-1.32.0-310-linux-x64/code-server /bin/code-server

RUN useradd -ms /bin/zsh $username && \
    adduser $username root && \
    usermod -a -G docker $username
WORKDIR /home/$username
USER $username

ENV DEV_USERNAME $username
ENV DEV_PASSWORD $password

EXPOSE 3000

ENTRYPOINT code-server /home/$DEV_USERNAME/workspace -p 3000 -d /home/$DEV_USERNAME/code-server --password=$DEV_PASSWORD
