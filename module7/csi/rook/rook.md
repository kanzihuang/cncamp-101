### Resetup rook

```sh
rm -rf /var/lib/rook
```

### Add a new raw device

Create a raw disk from virtualbox console and attach to the vm (must > 5G).

### Clean env for next demo

```sh
delete ns rook-ceph
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found -n rook-ceph
```

### Checkout rook

```sh
git clone --single-branch --branch master https://github.com/rook/rook.git
cd rook/cluster/examples/kubernetes/ceph
```

### Create rook operator

```sh
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
```

### Create ceph cluster

```sh
kubectl get po -n rook-ceph
```

Wait for all pod to be running, and:

```sh
kubectl create -f cluster-test.yaml
```

### Create storage class

```sh
kubectl get po -n rook-ceph
```

Wait for all pod to be running, and:

```sh
kubectl create -f csi/rbd/storageclass-test.yaml
```

### Check configuration

```sh
k get configmap -n rook-ceph rook-ceph-operator-config -oyaml
ROOK_CSI_ENABLE_RBD: "true"
```

### Check csidriver

```sh
k get csidriver rook-ceph.rbd.csi.ceph.com
```

### Check csi plugin configuration

```yaml
    name: csi-rbdplugin
    args:
    - --drivername=rook-ceph.rbd.csi.ceph.com
    - hostPath:
      path: /var/lib/kubelet/plugins/rook-ceph.rbd.csi.ceph.com
      type: DirectoryOrCreate
      name: plugin-dir
    - hostPath:
      path: /var/lib/kubelet/plugins
      type: Directory
      name: plugin-mount-dir

    name: driver-registrar
    args:
    - --csi-address=/csi/csi.sock
    - --kubelet-registration-path=/var/lib/kubelet/plugins/rook-ceph.rbd.csi.ceph.com/csi.sock
    - hostPath:
      path: /var/lib/kubelet/plugins_registry/
      type: Directory
      name: registration-dir
    - hostPath:
      path: /var/lib/kubelet/plugins/rook-ceph.rbd.csi.ceph.com
      type: DirectoryOrCreate
      name: plugin-dir
```

```sh
k get po csi-rbdplugin-j4s6c -n rook-ceph -oyaml
/var/lib/kubelet/plugins/rook-ceph.rbd.csi.ceph.com
```

### Create toolbox when required

```sh
kubectl create -f cluster/examples/kubernetes/ceph/toolbox.yaml
```

### Test networkstorage

```sh
kubectl create -f pvc.yaml
kubectl create -f pod.yaml
```

### Enter pod and write some data

```sh
kubeclt exec -it task-pv-pod sh
cd /mnt/ceph
echo hello world > hello.log
```

### Exit pod and delete the pod

```sh
kubectl create -f pod.yaml
```

### Recreate the pod and check /mnt/ceph again, and you will find the file is there

```sh
kubectl delete -f pod.yaml
kubectl create -f pod.yaml
kubeclt exec -it task-pv-pod sh
cd /mnt/ceph
ls
```

### Expose dashboard

```sh
kubectl get svc rook-ceph-mgr-dashboard -n rook-ceph -oyaml>svc1.yaml
vi svc1.yaml
```

Rename the svc and set service type as NodePort:

```sh
k create -f svc1.yaml
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
```

Login to the console with `admin/<password>`.

### Clean up

```sh
cd ~/go/src/github.com/rook/cluster/examples/kubernetes/ceph
kubectl delete -f csi/rbd/storageclass-test.yaml
kubectl delete -f cluster-test.yaml
kubectl delete -f crds.yaml -f common.yaml -f operator.yaml
kubectl delete ns rook-ceph
```

编辑下面四个文件，将finalizer的值修改为null, 例如

```txt
finalizers:
    - ceph.rook.io/disaster-protection/
```

修改为

```txt
finalizers：null
```

```sh
for CRD in $(kubectl get crd -n rook-ceph | awk '/ceph.rook.io/ {print $1}'); do
    kubectl get -n rook-ceph "$CRD" -o name | \
    xargs -I {} kubectl patch -n rook-ceph {} --type merge -p '{"metadata":{"finalizers": [null]}}'
done

```

### 执行下面循环，直至找不到任何rook关联对象。

```sh
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get --show-kind --ignore-not-found -n rook-ceph

rm -rf /var/lib/rook
```


## Referances

[Cleaning up a Cluster](https://rook.github.io/docs/rook/v1.7/ceph-teardown.html)