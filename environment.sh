#!/bin/bash

echo 'export ANSIBLE_LIBRARY=$HOME/.ansible/roles/avinetworks.avisdk/library' | tee -a /etc/bash.bashrc
echo 'export GOROOT=/usr/lib/go-1.9' | tee -a /etc/bash.bashrc
echo 'export GOPATH=$HOME/go' | tee -a /etc/bash.bashrc
echo 'export GOBIN=$GOPATH/bin' | tee -a /etc/bash.bashrc
echo 'export PATH=$PATH:$GOPATH/bin:$GOBIN' | tee -a /etc/bash.bashrc

echo "#!/bin/bash" | tee /usr/local/bin/avitools-list
echo "echo "The following Avi scripts are available in addition to ansible, terraform and other standard tools!"" | tee -a /usr/local/bin/avitools-list
echo "echo "f5_converter.py""  | tee -a /usr/local/bin/avitools-list
echo "echo "netscaler_converter.py""  | tee -a /usr/local/bin/avitools-list
echo "echo "gss_convertor.py""  | tee -a /usr/local/bin/avitools-list
echo "echo "f5_discovery.py""  | tee -a /usr/local/bin/avitools-list
echo "echo "avi_config_to_ansible.py""  | tee -a /usr/local/bin/avitools-list
echo "echo "ace_converter.py""  | tee -a /usr/local/bin/avitools-list
echo "echo "virtualservice_examples_api.py""  | tee -a /usr/local/bin/avitools-list
echo "echo "config_patch.py""  | tee -a /usr/local/bin/avitools-list
echo "echo "vs_filter.py""  | tee -a /usr/local/bin/avitools-list
echo "/usr/local/bin/avitools-list" | tee -a /etc/bash.bashrc
chmod +x /usr/local/bin/avitools-list