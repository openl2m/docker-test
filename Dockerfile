#
# Dockerfile for testing OpenL2M.
# Note: this is NOT meant to become a production setup!!!
#

FROM ubuntu:22.04

# install extra tools to run add-apt-repo, etc.
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# install Deadsnakes PPA to be able to load Python 3.11
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC add-apt-repository ppa:deadsnakes/ppa

# install required packages for python311 and a build environment
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
      python3.11 python3.11-distutils python3.11-venv python3.11-dev build-essential \
      libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev \
      libldap2-dev libsasl2-dev libssl-dev snmpd snmp libsnmp-dev git curl vim nano

# add PIP, not part of the distro:
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# create install dir
WORKDIR /opt/openl2m

# download the latest OpenL2M from git:
RUN git clone --depth 1 --no-single-branch https://github.com/openl2m/openl2m.git .

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install needed packages:
RUN pip3.11 install -r requirements.txt

# copy the startup script (a.k.a. entrypoint)
ADD entrypoint.sh /opt/openl2m
RUN chmod +x /opt/openl2m/entrypoint.sh

# and tell the contain what to run at boot
ENTRYPOINT ["/opt/openl2m/entrypoint.sh"]