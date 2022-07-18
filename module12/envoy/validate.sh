#!/bin/bash

ip=$(kubectl get nodes -o=jsonpath={.items[0].status.addresses[0].address})
port=$(kubectl get svc envoy -o=jsonpath='{.spec.ports[0].nodePort}')
curl http://$ip:$port/hello?user=Mike
