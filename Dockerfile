FROM python:2.7

MAINTAINER alibaba-serverless-fc

# Server path.
ENV FC_SERVER_PATH=/var/fc/runtime/python2.7

# Create directory.
RUN mkdir -p ${FC_SERVER_PATH}
RUN mkdir -p ~/.pip 
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak

ENV FC_FUNC_CODE_PATH=/code/

COPY pip.conf ~/.pip/
COPY sources.list /etc/apt/ 

# Change work directory.
WORKDIR ${FC_SERVER_PATH}

# Install dev dependencies.
RUN pip install coverage

# Install common libraries
RUN apt-get update && apt-get install apt-transport-https &&\
  wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
  apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
  sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list' && \
  apt-get update && apt-get install -y \
                imagemagick=8:6.8.9.9-5+deb8u11 \
                libopencv-dev=2.4.9.1+dfsg-1+deb8u1 \
                fonts-wqy-zenhei=0.9.45-6 \
                fonts-wqy-microhei=0.2.0-beta-2 \
                intel-mkl-2018.1-03

# Suppress opencv error: "libdc1394 error: Failed to initialize libdc1394"
RUN ln /dev/null /dev/raw1394

# Install third party libraries for user function.
# aliyun-log-python-sdk and tablestore protobuf version has conflict,  don't change their installation sequence
RUN pip install \
    oss2==2.3.3 \
    wand==0.4.4 \
    opencv-python==3.3.0.10 \
    numpy==1.13.1 \
    scipy==0.19.1 \
    matplotlib==2.0.2 \
    scrapy==1.4.0 \
    cbor==1.0.0 \
    aliyun-fc==0.6 \
    aliyun-log-python-sdk==0.6.14 \
    tablestore==4.3.2 \
    aliyun-fc2==2.0.2

# Generate usernames
RUN for i in $(seq 10000 10999); do \
        echo "user$i:x:$i:$i::/tmp:/usr/sbin/nologin" >> /etc/passwd; \
    done

ENV LD_LIBRARY_PATH=/opt/intel/mkl/lib/intel64
# Start a shell by default
CMD ["bash"]
