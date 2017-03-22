#!/bin/bash

#KubeDNS
kubectl create -f /var/lib/kubernetes/pod_defs/kubedns-svc.yaml
kubectl create -f /var/lib/kubernetes/pod_defs/kubedns.yaml
