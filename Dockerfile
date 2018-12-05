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
    ansible==2.6.0 \
    appdirs==1.4.3 \
    avimigrationtools==${avi_version} \
    avisdk==${avi_version} \
    bigsuds \
    ConfigParser==3.5.0 \
    ecdsa==0.13 \
    f5-sdk \
    flask==0.12.2 \
    jinja2==2.10 \
    jsondiff \
    netaddr \
    networkx==2.0 \
    nose-html-reporting==0.2.3 \
    nose-testconfig==0.10 \
    openpyxl==2.4.9 \
    pandas==0.21.0 \
    paramiko==2.4.1 \
    pexpect==4.3.0 \
    pycrypto==2.6.1 \
    pyOpenssl==17.5.0 \
    pyparsing==2.2.0 \
    pytest-cov==2.5.1 \
    pytest-xdist==1.22.0 \
    pytest==3.2.5 \
    pyvmomi \
    pyyaml==3.12 \
    requests-toolbelt==0.8.0 \
    requests==2.18.4 \
    unittest2==1.1.0 \
    vcrpy==1.11.1 \
    xlrd==1.1.0 \
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