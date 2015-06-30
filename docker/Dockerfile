FROM google/dart:1.11.0

WORKDIR /app

RUN apt-get update
RUN apt-get install git

CMD git clone https://github.com/cgarciae/garesco.git && sh garesco/docker/commands.sh