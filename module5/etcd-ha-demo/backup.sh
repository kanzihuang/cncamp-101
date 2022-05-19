
member_ip=152.136.201.177

etcdctl snapshot save snapshot.db \
--endpoints https://$member_ip:3379 \
--cert /data/etcd/certs/$member_ip.pem \
--key /data/etcd/certs/$member_ip-key.pem \
--cacert /data/etcd/certs/ca.pem