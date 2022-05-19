https://kubernetes.io/zh/docs/setup/production-environment/container-runtimes/#containerd

### Stop service

```sh
systemctl stop kubelet
systemctl stop docker
systemctl stop containerd
```

### Create containerd config folder

```sh
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
```

### Update default config

```sh
vi /etc/containerd/config.toml
sed -i s#k8s.gcr.io/pause:3.2#registry.aliyuncs.com/google_containers/pause:3.6#g /etc/containerd/config.toml
sed -i s#'SystemdCgroup = false'#'SystemdCgroup = true'#g /etc/containerd/config.toml
sudo sed -i s#registry-1.docker.io#mirrors.aliyun.com# /etc/containerd/config.toml

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

### Edit kubelet config and add extra args

```sh
vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.6"
```

### Restart

```sh
systemctl daemon-reload
systemctl restart containerd
systemctl restart kubelet
```

### Config crictl to set correct endpoint

```sh
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
EOF
```

### commands

```sh
crictl --version
ctr --version
```

## Refrences

[容器运行时](https://kubernetes.io/zh/docs/setup/production-environment/container-runtimes/#containerd)
