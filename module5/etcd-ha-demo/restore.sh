export ETCDCTL_API=3

member_name="infra0"
member_ip="152.136.201.177"
sudo etcdutl snapshot restore snapshot.db \
  --name $member_name \
  --data-dir=/data/etcd/$member_name.etcd \
  --initial-cluster infra0=https://152.136.201.177:2380,infra1=https://123.57.247.175:2380,infra2=https://124.70.63.239:2380 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-advertise-peer-urls https://$member_ip:2380
