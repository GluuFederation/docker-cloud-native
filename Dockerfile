FROM python:3.8-slim-buster
# ===========================
# Cloud Native Python package
# ===========================

ENV GLUU_CLOUD_NATIVE_EDITION_VERSION=4.1
RUN apt update && apt-get install git tini make -y --no-install-recommends && pip3 install requests
RUN git clone --recursive --depth 1 --branch ${GLUU_CLOUD_NATIVE_EDITION_VERSION} https://github.com/GluuFederation/cloud-native-edition
RUN cd cloud-native-edition && cat setup.py &&  make install

# ================
# Install Kubectl
# ================
RUN apt-get update && apt-get install -y apt-transport-https gnupg2 curl --no-install-recommends
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN  apt-get update
RUN  apt-get install -y kubectl

# ================
# Install Helm V3
# ================
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh

EXPOSE 8080

# =======
# Cleanup
# =======

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# =======
# License
# =======

RUN mkdir -p /licenses
COPY LICENSE /licenses/

# =====================================
# Generate Random installation settings
# =====================================
RUN mkdir -p /scripts
COPY generate_settings.sh /scripts/
RUN chmod 700 /scripts/generate_settings.sh \
    && ./scripts/generate_settings.sh

WORKDIR /
# ==========
# misc stuff
# ==========

LABEL name="Gluu-CN-Installer" \
    maintainer="Gluu Inc. <support@gluu.org>" \
    vendor="Gluu Federation" \
    version="4.1.0" \
    release="dev" \
    summary="Gluu cloud native edition installer" \
    description="Gluu cloud native edition installer"

ENTRYPOINT ["tini", "-g", "--", "pygluu-kubernetes"]
CMD ["--help"]