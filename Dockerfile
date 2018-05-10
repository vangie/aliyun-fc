FROM maven:3.5-jdk-8-slim

MAINTAINER alibaba-serverless-fc

# Environment variables can be overwritten by running
# $ docker run --env <key>=<value>
ENV FC_SERVER_PATH=/var/fc/runtime/java8

ENV FC_SERVER_PORT=9000 \
    FC_SERVER_LOG_PATH=${FC_SERVER_PATH}/var/log \
    FC_SERVER_LOG_LEVEL=debug \
    FC_FUNC_CODE_PATH=/code

ENV LD_LIBRARY_PATH=${FC_FUNC_CODE_PATH}:${FC_FUNC_CODE_PATH}/lib

RUN mkdir -p ${FC_SERVER_LOG_PATH}
RUN chmod 777 ${FC_SERVER_LOG_PATH}
RUN chmod -R 777 /tmp/

ENV MAVEN_REPOSITORY=/cache/maven.repository

# Change work directory.
WORKDIR ${FC_FUNC_CODE_PATH}

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
COPY sources.list /etc/apt/

# Install common libraries
RUN apt-get update && apt-get install -y \
        make=4.1-9.1 \
        imagemagick=8:6.9.7.4+dfsg-11+deb9u4 \
        libopencv-dev=2.4.9.1+dfsg1-2 \
        fonts-wqy-zenhei=0.9.45-6 \
        fonts-wqy-microhei=0.2.0-beta-2

# Suppress opencv error: "libdc1394 error: Failed to initialize libdc1394"
RUN ln /dev/null /dev/raw1394

# Copy all files to home directory.
COPY pom.xml .

# Generate usernames
RUN for i in $(seq 10000 10999); do \
        echo "user$i:x:$i:$i::/tmp:/usr/sbin/nologin" >> /etc/passwd; \
    done

#download all the dependencies
RUN ["mvn", "clean", "install"]
RUN ["mvn", "dependency:go-offline"]
