FROM python:3.8-slim-buster
# ===========================
# Cloud Native Python package
# ===========================
ENV GLUU_CLOUD_NATIVE_EDITION_VERSION=4.2
ENV GLUU_CLOUD_NATIVE_EDITION_TAG="v1.2.12"
ENV SECRET_KEY="e768fcc1f3451e86d0asdaskljd8293242ab83d4b0e6cac64ab5b7894sdfsdfv1"
RUN apt update \
    && apt-get install git tini make -y --no-install-recommends && pip3 install requests shiv \
    &&  git clone --recursive --depth 1 --branch ${GLUU_CLOUD_NATIVE_EDITION_TAG} https://github.com/GluuFederation/cloud-native-edition \
    && cd cloud-native-edition \
    &&  make install guizipapp

# ================
# Install Kubectl
# ================
RUN apt-get update \
    && apt-get install -y apt-transport-https gnupg2 curl --no-install-recommends \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    &&  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl

# ================
# Install Helm V3
# ================
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

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


# ==========
# misc stuff
# ==========

LABEL name="Gluu-CN-Installer" \
    maintainer="Gluu Inc. <support@gluu.org>" \
    vendor="Gluu Federation" \
    version="4.2.1" \
    release="a1" \
    summary="Gluu cloud native edition installer" \
    description="Gluu cloud native edition installer"

ENTRYPOINT ["tini", "-g", "--", "./pygluu-kubernetes-gui.pyz"]
CMD ["--help"]