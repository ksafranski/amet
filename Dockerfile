FROM ubuntu:18.04

# SETUP, CONFIG
ARG username
ARG password
ARG shell
ARG timezone
ARG lang

ENV DEV_USERNAME $username
ENV DEV_PASSWORD $password
ENV DEV_SHELL /bin/$shell
ENV TZ $timezone

EXPOSE 3000

# REQUIRED FOR RUNNING CODE-SERVER AND OTHER AMET FEATURES
RUN apt-get update && apt-get install -y \
    git zsh apt-transport-https \
    ca-certificates curl software-properties-common \
    build-essential wget openssl net-tools locales \
    sudo openssh-server && \
    echo "AuthorizedKeysFile %h/.ssh/authorized_keys %h/.ssh/authorized_keys2 /etc/ssh/%u/authorized_keys" >> /etc/ssh/sshd_config && \
    mkdir -p /etc/ssh/$username && \
    locale-gen $lang && \
    ln -snf /usr/share/zoneinfo/$timezone /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get install tzdata

# INSTALL CODE-SERVER
RUN wget https://github.com/codercom/code-server/releases/download/1.691-vsc1.33.0/code-server1.691-vsc1.33.0-linux-x64.tar.gz && \
    tar -xvzf code-server1.691-vsc1.33.0-linux-x64.tar.gz -C /tmp && \
    mv /tmp/code-server1.691-vsc1.33.0-linux-x64/code-server /bin/code-server

# INSTALL DOCKER
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install -y docker-ce && service docker start

# INSTALL OTHER PACKAGES
RUN apt-get update && apt-get install -y \
    vim

# CREATE USER
RUN groupadd $username && \
   useradd \
      -ms $DEV_SHELL \
      -g root \
      -p "$(openssl passwd -1 $DEV_PASSWORD)" \
      $username && \
   usermod -a -G docker $username && \
   echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nopasswd && \
   chmod 400 /etc/sudoers.d/nopasswd && \
   chown -R $username:root /etc/ssh/$username
WORKDIR /home/$username
USER $username

# STARTUP
COPY ./entrypoint.sh /
ENTRYPOINT [ "sh", "/entrypoint.sh" ]
CMD code-server /home/$DEV_USERNAME/workspace \
   -p 3000 \
   -d /home/$DEV_USERNAME/code-server \
   --password=$DEV_PASSWORD
