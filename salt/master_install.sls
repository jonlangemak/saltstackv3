#Calulcate Source has for files
{% set source_hash1 = salt['cmd.shell']('echo "md5=`curl -s "https://pkg.cfssl.org/R1.2/cfssl_linux-amd64" | md5sum | cut -c -32`"') %}
{% set source_hash2 = salt['cmd.shell']('echo "md5=`curl -s "https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64" | md5sum | cut -c -32`"') %}
{% set source_hash3 = salt['cmd.shell']('echo "md5=`curl -s -L "https://github.com/coreos/etcd/releases/download/v3.0.10/etcd-v3.0.10-linux-amd64.tar.gz" | md5sum | cut -c -32`"') %}
{% set source_hash4 = salt['cmd.shell']('echo "md5=`curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kube-apiserver" | md5sum | cut -c -32`"') %}
{% set source_hash5 = salt['cmd.shell']('echo "md5=`curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kube-controller-manager" | md5sum | cut -c -32`"') %}
{% set source_hash6 = salt['cmd.shell']('echo "md5=`curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kube-scheduler" | md5sum | cut -c -32`"') %}
{% set source_hash7 = salt['cmd.shell']('echo "md5=`curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl" | md5sum | cut -c -32`"') %}
{% set source_hash8 = salt['cmd.shell']('echo "md5=`curl -s -L "https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/token.csv" | md5sum | cut -c -32`"') %}
{% set source_hash9 = salt['cmd.shell']('echo "md5=`curl -s -L "https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/authorization-policy.jsonl" | md5sum | cut -c -32`"') %}

#Make any required directories
/etc/etcd/:
  file.directory:
    - user: user
    - group: user
    - dir_mode: 755
    - file_mode: 755

/var/lib/etcd/:
  file.directory:
    - user: user
    - group: user
    - dir_mode: 755
    - file_mode: 755

/var/lib/kube_certs/:
  file.directory:
    - user: user
    - group: user 
    - dir_mode: 755
    - file_mode: 755

/var/lib/kubernetes/:
  file.directory:
    - user: user
    - group: user
    - dir_mode: 755
    - file_mode: 755

/var/lib/kubernetes/pod_defs:
  file.directory:
    - user: user
    - group: user
    - dir_mode: 755
    - file_mode: 755

/srv/salt/kube_certs:
  file.directory:
    - user: user
    - group: user
    - dir_mode: 755
    - file_mode: 755

cfssl_binary:
  file.managed:
    - name: /usr/local/bin/cfssl
    - source: https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
    - mode: 755
    - source_hash: {{ source_hash1 }}

cfssl_json_binary:
  file.managed:
    - name: /usr/local/bin/cfssljson
    - source: https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
    - mode: 755
    - source_hash: {{ source_hash2 }}

etcd_binary:
  archive.extracted:
    - name: /tmp/
    - source: https://github.com/coreos/etcd/releases/download/v3.0.10/etcd-v3.0.10-linux-amd64.tar.gz
    - mode: 755
    - source_hash: {{ source_hash3 }}

move_etcd_to_usr_bin_dir:
  file.copy:
    - name: /usr/bin/etcd
    - source: /tmp/etcd-v3.0.10-linux-amd64/etcd
    - user: user
    - group: user
    - mode: 755

move_etcdctl_to_usr_bin_dir:
  file.copy:
    - name: /usr/bin/etcdctl
    - source: /tmp/etcd-v3.0.10-linux-amd64/etcdctl
    - user: user
    - group: user
    - mode: 755

pki_ca_config:
  file.managed:
    - name: /var/lib/kube_certs/pki_ca_config.json
    - source: salt://json_templatez/pki_ca_config.json
    - mode: 755
    - template: jinja

pki_ca_csr:
  file.managed:
    - name: /var/lib/kube_certs/pki_ca_csr.json
    - source: salt://json_templatez/pki_ca_csr.json
    - mode: 755
    - template: jinja

pki_crt_csr:
  file.managed:
    - name: /var/lib/kube_certs/pki_crt_csr.json
    - source: salt://json_templatez/pki_crt_csr.json
    - mode: 755
    - template: jinja

gen_pki_ca:
  cmd:
    - run
    - cwd: /var/lib/kube_certs
    - name: cfssl gencert -initca pki_ca_csr.json | cfssljson -bare ca
    - onchanges:
        - file: /var/lib/kube_certs/pki_ca_config.json
        - file: /var/lib/kube_certs/pki_ca_csr.json

gen_pki_cert:
  cmd:
    - run
    - cwd: /var/lib/kube_certs
    - name: cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=pki_ca_config.json -profile={{ pillar['pki_info']['cert_name'] }} pki_crt_csr.json | cfssljson -bare {{ pillar['pki_info']['cert_name'] }}
    - onchanges:
        - file: /var/lib/kube_certs/pki_crt_csr.json

move_capem_to_salt_dir:
  file.copy:
    - name: /srv/salt/kube_certs/ca.pem
    - source: /var/lib/kube_certs/ca.pem
    - user: user
    - group: user
    - mode: 755
    - force: True
    - unless: diff /srv/salt/kube_certs/ca.pem /var/lib/kube_certs/ca.pem

move_k8skeypem_to_salt_dir:
  file.copy:
    - name: /srv/salt/kube_certs/kubernetes-key.pem
    - source: /var/lib/kube_certs/kubernetes-key.pem
    - user: user
    - group: user
    - mode: 755
    - force: True
    - unless: diff /srv/salt/kube_certs/kubernetes-key.pem /var/lib/kube_certs/kubernetes-key.pem

move_k8spem_to_salt_dir:
  file.copy:
    - name: /srv/salt/kube_certs/kubernetes.pem
    - source: /var/lib/kube_certs/kubernetes.pem
    - user: user
    - group: user
    - mode: 755
    - force: True
    - unless: diff /srv/salt/kube_certs/kubernetes.pem /var/lib/kube_certs/kubernetes.pem

move_capem_to_etcd_dir:
  file.copy:
    - name: /etc/etcd/ca.pem
    - source: /var/lib/kube_certs/ca.pem
    - user: user
    - group: user
    - mode: 755
    - force: True
    - unless: diff /etc/etcd/ca.pem /var/lib/kube_certs/ca.pem

move_k8skeypem_to_etcd_dir:
  file.copy:
    - name: /etc/etcd/kubernetes-key.pem
    - source: /var/lib/kube_certs/kubernetes-key.pem
    - user: user
    - group: user
    - mode: 755
    - force: True
    - unless: diff /etc/etcd/kubernetes-key.pem /var/lib/kube_certs/kubernetes-key.pem

move_k8spem_to_etcd_dir:
  file.copy:
    - name: /etc/etcd/kubernetes.pem
    - source: /var/lib/kube_certs/kubernetes.pem
    - user: user
    - group: user
    - mode: 755
    - force: True
    - unless: diff /etc/etcd/kubernetes.pem /var/lib/kube_certs/kubernetes.pem

k8s_apiserver_binary:
  file.managed:
    - name: /usr/bin/kube-apiserver
    - source: https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kube-apiserver
    - mode: 755
    - source_hash: {{ source_hash4 }}

k8s_controller_binary:
  file.managed:
    - name: /usr/bin/kube-controller-manager
    - source: https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kube-controller-manager
    - mode: 755
    - source_hash: {{ source_hash5 }}

k8s_scheduler_binary:
  file.managed:
    - name: /usr/bin/kube-scheduler
    - source: https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kube-scheduler
    - mode: 755
    - source_hash: {{ source_hash6 }}

k8s_kubectl_binary:
  file.managed:
    - name: /usr/bin/kubectl
    - source: https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl
    - mode: 755
    - source_hash: {{ source_hash7 }}



example_token_file:
  file.managed:
    - name: /var/lib/kubernetes/token.csv
    - source: https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/token.csv
    - mode: 755
    - source_hash: {{ source_hash8 }}


example_authorization_policy:
  file.managed:
    - name: /var/lib/kubernetes/authorization-policy.jsonl
    - source: https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/authorization-policy.jsonl
    - mode: 755
    - source_hash: {{ source_hash9 }}

etcd_service_def:
  file.managed:
    - name: /etc/systemd/system/etcd.service
    - source: salt://systemd/etcd.service
    - mode: 755
    - template: jinja

k8s_apiserver_service_def:
  file.managed:
    - name: /etc/systemd/system/kube-apiserver.service
    - source: salt://systemd/kube-apiserver.service
    - mode: 755
    - template: jinja

k8s_controller_service_def:
  file.managed:
    - name: /etc/systemd/system/kube-controller-manager.service
    - source: salt://systemd/kube-controller-manager.service
    - mode: 755
    - template: jinja

k8s_scheduler_service_def:
  file.managed:
    - name: /etc/systemd/system/kube-scheduler.service
    - source: salt://systemd/kube-scheduler.service
    - mode: 755
    - template: jinja

etcd:
  service.running:
    - enable: True

kube-apiserver:
  service.running:
    - enable: True

kube-controller-manager:
  service.running:
    - enable: True

kube-scheduler:
  service.running:
    - enable: True

pod_script:
  file.managed:
    - name: /var/lib/kubernetes/pod_defs/pod_create.sh
    - source: salt://scriptz/pod_create.sh
    - mode: 755
    - template: jinja

pod_kubedns_svc:
  file.managed:
    - name: /var/lib/kubernetes/pod_defs/kubedns-svc.yaml
    - source: salt://pod_definitionz/kubedns-svc.yaml
    - mode: 755
    - template: jinja

pod_kubedns:
  file.managed:
    - name: /var/lib/kubernetes/pod_defs/kubedns.yaml
    - source: salt://pod_definitionz/kubedns.yaml
    - mode: 755
    - template: jinja



