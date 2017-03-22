#Calulcate Source has for files
{% set source_hash1 = salt['cmd.run']('echo "md5=`curl -s "https://get.docker.com/builds/Linux/x86_64/docker-1.12.1.tgz" | md5sum | cut -c -32`"') %}
{% set source_hash2 = salt['cmd.run']('echo "md5=`curl -s "https://storage.googleapis.com/kubernetes-release/network-plugins/cni-07a8a28637e97b22eb8dfe710eeae1344f69d16e.tar.gz" | md5sum | cut -c -32`"') %}
{% set source_hash3 = salt['cmd.run']('echo "md5=`curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl" | md5sum | cut -c -32`"') %}
{% set source_hash4 = salt['cmd.run']('echo "md5=`curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kube-proxy" | md5sum | cut -c -32`"') %}
{% set source_hash5 = salt['cmd.run']('echo "md5=`curl -s -L "https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubelet" | md5sum | cut -c -32`"') %}

/var/lib/kubelet:
  file.directory:
    - user: user
    - group: user
    - dir_mode: 755
    - file_mode: 755

/opt/cni:
  file.directory:
    - user: user
    - group: user
    - dir_mode: 755
    - file_mode: 755

/var/lib/kube_certs:
  file.directory:
    - user: user
    - group: user
    - dir_mode: 755
    - file_mode: 755

ca_pem:
  file.managed:
    - name: /var/lib/kube_certs/ca.pem
    - source: salt://kube_certs/ca.pem
    - mode: 755

k8skey_pem:
  file.managed:
    - name: /var/lib/kube_certs/kubernetes-key.pem
    - source: salt://kube_certs/kubernetes-key.pem
    - mode: 755

k8s_pem:
  file.managed:
    - name: /var/lib/kube_certs/kubernetes.pem
    - source: salt://kube_certs/kubernetes.pem
    - mode: 755


docker_service_def:
  file.managed:
    - name: /etc/systemd/system/docker.service
    - source: salt://systemd/docker.service
    - mode: 755
    - template: jinja

docker_binary:
  archive.extracted:
    - name: /tmp/
    - source: https://get.docker.com/builds/Linux/x86_64/docker-1.12.1.tgz
    - mode: 755
    - source_hash: {{ source_hash1 }}

move_docker_containerd_ctr_to_usr_bin_dir:
  file.copy:
    - name: /usr/bin/docker-containerd-ctr
    - source: /tmp/docker/docker-containerd-ctr
    - user: user
    - group: user
    - mode: 755

move_docker_to_usr_bin_dir:
  file.copy:
    - name: /usr/bin/docker
    - source: /tmp/docker/docker
    - user: user
    - group: user
    - mode: 755

move_docker_containerd_to_usr_bin_dir:
  file.copy:
    - name: /usr/bin/docker-containerd
    - source: /tmp/docker/docker-containerd
    - user: user
    - group: user
    - mode: 755

move_dockerd_to_usr_bin_dir:
  file.copy:
    - name: /usr/bin/dockerd
    - source: /tmp/docker/dockerd
    - user: user
    - group: user
    - mode: 755

move_docker_proxy_to_usr_bin_dir:
  file.copy:
    - name: /usr/bin/docker-proxy
    - source: /tmp/docker/docker-proxy
    - user: user
    - group: user
    - mode: 755

move_docker_runc_to_usr_bin_dir:
  file.copy:
    - name: /usr/bin/docker-runc
    - source: /tmp/docker/docker-runc
    - user: user
    - group: user
    - mode: 755

move_docker_conatinerd_shim_to_usr_bin_dir:
  file.copy:
    - name: /usr/bin/docker-containerd-shim
    - source: /tmp/docker/docker-containerd-shim
    - user: user
    - group: user
    - mode: 755

docker:
  service.running:
    - enable: True

cni_binary:
  archive.extracted:
    - name: /opt/cni/
    - source: https://storage.googleapis.com/kubernetes-release/network-plugins/cni-07a8a28637e97b22eb8dfe710eeae1344f69d16e.tar.gz
    - mode: 755
    - source_hash: {{ source_hash2 }}

k8s_kubectl_binary:
  file.managed:
    - name: /usr/bin/kubectl
    - source: https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl
    - mode: 755
    - source_hash: {{ source_hash3 }}

k8s_kubeproxy_binary:
  file.managed:
    - name: /usr/bin/kube-proxy
    - source: https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kube-proxy
    - mode: 755
    - source_hash: {{ source_hash4 }}

k8s_kubelet_binary:
  file.managed:
    - name: /usr/bin/kubelet
    - source: https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubelet
    - mode: 755
    - source_hash: {{ source_hash5 }}

kubelet_service_def:
  file.managed:
    - name: /etc/systemd/system/kubelet.service
    - source: salt://systemd/kubelet.service
    - mode: 755
    - template: jinja

kube_proxy_service_def:
  file.managed:
    - name: /etc/systemd/system/kube-proxy.service
    - source: salt://systemd/kube-proxy.service
    - mode: 755
    - template: jinja

kubeconfig_def:
  file.managed:
    - name: /var/lib/kubelet/kubeconfig
    - source: salt://yaml_templatez/kubeconfig
    - mode: 755
    - template: jinja

kubelet:
  service.running:
    - enable: True

kube-proxy:
  service.running:
    - enable: True