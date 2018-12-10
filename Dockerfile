FROM ubuntu:16.04 as builder

ARG tf_version="0.11.10"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    golang-1.9-go \
    unzip

RUN curl https://releases.hashicorp.com/terraform/${tf_version}/terraform_${tf_version}_linux_amd64.zip -o terraform_${tf_version}_linux_amd64.zip && \
    unzip terraform_${tf_version}_linux_amd64.zip

RUN curl -L https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz -o openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz && \
    tar xzvf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz && \
    chmod +x ./openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc

RUN mkdir $HOME/go && \
    export GOROOT=/usr/lib/go-1.9 && \
    export GOPATH=$HOME/go && \
    export GOBIN=$GOPATH/bin && \
    export PATH=$PATH:$GOROOT/bin && \
    go get github.com/avinetworks/sdk/go/session && \
    cd $GOPATH/src/github.com/avinetworks && \
    git clone https://github.com/avinetworks/terraform-provider-avi.git && \
    cd $GOPATH/src/github.com/avinetworks/terraform-provider-avi && \
    make build

FROM ubuntu:16.04

ARG avi_version

RUN apt-get update && apt-get install -y \
    apache2-utils \
    apt-transport-https \
    curl \
    dnsutils \
    git \
    golang-1.9-go \
    httpie \
    inetutils-ping \
    iproute2 \
    jq \
    libffi-dev \
    libssl-dev \
    lua5.3 \
    make \
    netcat \
    nmap \
    unzip \
    python \
    python-cffi \
    python-dev \
    python-pip \
    python-virtualenv \
    slowhttptest \
    sshpass \
    tree \
    vim \
    wget

RUN pip install --no-cache-dir -U \
    ansible \
    appdirs \
    avimigrationtools==${avi_version} \
    avisdk==${avi_version} \
    'https://avinetworks.com/software-downloads/Version-18.1.5/avi_shell-18.1.5-9248.tar.gz?Signature=Cw2NlK6ZiocdezWhqe9j9f%2Bz%2F5c%3D&Expires=1544432886&AWSAccessKeyId=AKIAIXO5A5YMNLOVWNBQ' \
    aws-google-auth \
    bigsuds \
    ConfigParser \
    ecdsa \
    f5-sdk \
    flask \
    jinja2 \
    jsondiff \
    kubernetes \
    netaddr \
    networkx \
    nose-html-reporting \
    nose-testconfig \
    openpyxl \
    openshift \
    git+https://github.com/openshift/openshift-restclient-python.git \
    pandas \
    paramiko \
    pexpect \
    pycrypto \
    pyOpenssl \
    pyparsing \
    pytest-cov \
    pytest-xdist \
    pytest \
    pyvmomi \
    pyyaml \
    requests-toolbelt \
    requests \
    unittest2 \
    vcrpy \
    xlrd \
    xlsxwriter

RUN ansible-galaxy -c install \
    avinetworks.aviconfig \
    avinetworks.avicontroller \
    avinetworks.avicontroller_csp \
    avinetworks.avicontroller-azure \
    avinetworks.avicontroller_vmware \
    avinetworks.avimigrationtools \
    avinetworks.avisdk \
    avinetworks.avise \
    avinetworks.avise_csp \
    avinetworks.docker \
    avinetworks.network_interface 

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubectl

# RUN mkdir -p /root/.terraform.d/plugins

COPY --from=builder terraform /usr/local/bin/terraform
COPY --from=builder /root/go/bin/terraform-provider-avi /root/.terraform.d/plugins/terraform-provider-avi
COPY --from=builder /openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/bin/oc

# RUN git config --global http.sslverify false

RUN cd $HOME && git clone https://github.com/avinetworks/sdk.git && cd sdk && git checkout ${avi_version}

COPY environment.sh /root
RUN chmod a+x /root/environment.sh && /root/environment.sh

CMD /usr/local/bin/avitools-list