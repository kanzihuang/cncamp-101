
infra0="152.136.201.177"
infra1="123.57.247.175"
infra2="124.70.63.239"
member_name="infra1"
member_ip=$infra1

nohup etcd --name $member_name \
--data-dir=/data/etcd/$member_name.etcd \
--listen-peer-urls https://0.0.0.0:2380 \
--listen-client-urls https://0.0.0.0:2379 \
--advertise-client-urls https://$member_ip:2379 \
--client-cert-auth --trusted-ca-file=/data/etcd/certs/ca.pem \
--cert-file=/data/etcd/certs/$member_ip.pem \
--key-file=/data/etcd/certs/$member_ip-key.pem \
--peer-client-cert-auth --peer-trusted-ca-file=/data/etcd/certs/ca.pem \
--peer-cert-file=/data/etcd/certs/$member_ip.pem \
--peer-key-file=/data/etcd/certs/$member_ip-key.pem 2>&1 > /data/etcd/log/$member_name.log &
