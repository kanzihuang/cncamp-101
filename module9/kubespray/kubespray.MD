## Prepare k8s vm

### Install 2 ubuntu20.04 vm

### Set network adapter

### Add a host only adaptor and add the following settings

node1

```sh
cat /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.34.10/24
  version: 2
```

```sh
netplan apply
```

node2

```sh
cat /etc/netplan/00-installer-config.yaml

network:
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.34.11/24
  version: 2
```

```sh
netplan apply
```

## Start k8s by kubespary

### Download kubespary docker image

```sh
docker pull quay.io/kubespray/kubespray:v2.19.0
```

### Clone kubespary source code

```sh
git clone https://github.com/kubernetes-sigs/kubespray.git
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub cadmin@192.168.34.10
ssh-copy-id -i ~/.ssh/id_rsa.pub cadmin@192.168.34.11
```

### Start kubespray

```sh
cd kubespray
nerdctl run --rm -it \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.19.0 bash
```

### Prepare no password login for server

### Build ansible inventory

```sh
cp -r /kubespray/inventory/sample /kubespray/inventory/mycluster
declare -a IPS=(192.168.1.3 192.168.1.4 192.168.1.5)
CONFIG_FILE=/kubespray/inventory/mycluster/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

### Change gcr.io to mirror

```sh
sed -i '/^# files_repo: "http:\/\/myprivatehttpd"/a ghproxy_repo: "https:\/\/ghproxy.com\/https:\/\/github.com"' /kubespray/inventory/mycluster/group_vars/all/offline.yml
sed -i 's/{{ files_repo }}\/github.com/{{ ghproxy_repo }}/g' /kubespray/inventory/mycluster/group_vars/all/offline.yml
sed -i '/{{ ghproxy_repo }}/s/^#\s*//' /kubespray/inventory/mycluster/group_vars/all/offline.yml
sed -i '/^# kube_image_repo:/{s/^#\s*//;s/{{ registry_host }}/registry.aliyuncs.com\/google_containers/}' /kubespray/inventory/mycluster/group_vars/all/offline.yml
sed -i '/^# gcr_image_repo:/{s/^#\s*//;s/{{ registry_host }}/registry.aliyuncs.com\/google_containers/}' /kubespray/inventory/mycluster/group_vars/all/offline.yml

cat > /kubespray/inventory/mycluster/group_vars/k8s_cluster/vars.yml << EOF
gcr_image_repo: "registry.aliyuncs.com/google_containers"
kube_image_repo: "registry.aliyuncs.com/google_containers"
ghproxy_repo: "https://ghproxy.com/https://github.com"

etcd_download_url: "{{ ghproxy_repo }}/coreos/etcd/releases/download/{{ etcd_version }}/etcd-{{ etcd_version }}-linux-{{ image_arch }}.tar.gz"
cni_download_url: "{{ ghproxy_repo }}/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
calicoctl_download_url: "{{ ghproxy_repo }}/projectcalico/calico/releases/download/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
calico_crds_download_url: "{{ ghproxy_repo }}/projectcalico/calico/archive/{{ calico_version }}.tar.gz"
crictl_download_url: "{{ ghproxy_repo }}/kubernetes-sigs/cri-tools/releases/download/{{ crictl_version }}/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
runc_download_url: "{{ ghproxy_repo }}/opencontainers/runc/releases/download/{{ runc_version }}/runc.{{ image_arch }}"
containerd_download_url: "{{ ghproxy_repo }}/containerd/containerd/releases/download/v{{ containerd_version }}/containerd-{{ containerd_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
nerdctl_download_url: "{{ ghproxy_repo }}/containerd/nerdctl/releases/download/v{{ nerdctl_version }}/nerdctl-{{ nerdctl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"

coredns_image_repo: "registry.aliyuncs.com/google_containers/coredns"
nodelocaldns_image_repo: "kanzihuang/registry.k8s.io_slash_dns_slash_k8s-dns-node-cache"
dnsautoscaler_image_repo: "kanzihuang/registry.k8s.io_slash_cpa_slash_cluster-proportional-autoscaler-{{ image_arch }}"
EOF
```

### Change remote user

#### On host src folder

```sh

ansible-playbook -i /kubespray/inventory/mycluster/hosts.yml cluster.yml -b -v \
 --private-key=~/.ssh/id_rsa --user wanli
```

### Troubleshooting

#### Error, the following error cause by slow network in China

```
Data could not be sent to remote host \"192.168.34.11\". Make sure this host can be reached over ssh:
```

> If you meet the same error when downloading image, you can pull the image before retry

#### dpkg: error: dpkg frontend lock is locked by another process

```sh
rm /var/lib/dpkg/lock
rm /var/lib/dpkg/lock-frontend
rm /var/cache/apt/archives/lock
```
