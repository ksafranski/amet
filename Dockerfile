FROM ubuntu:18.04

# SETUP, CONFIG
ARG username
ARG password
ARG shell

ENV DEV_USERNAME $username
ENV DEV_PASSWORD $password
ENV DEV_SHELL /bin/$shell

EXPOSE 3000

# REQUIRED FOR RUNNING CODE-SERVER
RUN apt update && apt install -y \
    git zsh apt-transport-https \
    ca-certificates curl software-properties-common \
    build-essential wget openssl net-tools locales sudo

# INSTALL CODE-SERVER
RUN wget https://github.com/codercom/code-server/releases/download/1.32.0-310/code-server-1.32.0-310-linux-x64.tar.gz && \
    tar -xvzf code-server-1.32.0-310-linux-x64.tar.gz -C /tmp && \
    mv /tmp/code-server-1.32.0-310-linux-x64/code-server /bin/code-server

# INSTALL DOCKER
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install -y docker-ce && service docker start

# INSTALL OTHER PACKAGES
RUN apt-get update && apt install -y \
    vim

# CREATE USER
RUN useradd -ms $DEV_SHELL $username && \
    adduser $username root && \
    usermod -a -G docker $username && \
    echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopasswd && \
    chmod 400 /etc/sudoers.d/nopasswd
WORKDIR /home/$username
USER $username

# STARTUP
COPY ./entrypoint.sh /
ENTRYPOINT [ "sh", "/entrypoint.sh" ]
