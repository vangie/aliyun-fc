FROM python:3.6

MAINTAINER alibaba-serverless-fc

ENV FC_SERVER_PATH=/var/fc/runtime/python3

ENV FC_FUNC_CODE_PATH=/code/ \
    FC_FUNC_LOG_PATH=/var/log/fc/

# Create directory.
RUN mkdir -p ${FC_SERVER_PATH}
RUN mkdir -p ${FC_FUNC_CODE_PATH}
RUN mkdir -p ${FC_FUNC_LOG_PATH}

# Change work directory.
WORKDIR ${FC_FUNC_CODE_PATH}

# Install imagemagick
RUN apt-get install -y imagemagick

# Install third party libraries for user function.
RUN pip install \
    oss2 \
    tablestore \
    wand

# Start a shell by default
CMD ["bash"]

