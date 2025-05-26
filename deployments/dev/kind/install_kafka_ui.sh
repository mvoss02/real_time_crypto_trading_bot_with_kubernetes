#!/bin/bash

kubectl apply -f manifests/kafka-ui-all-in-one.yaml

# Port-forwarding the UI:
# kubectl -n kafka port-forward svc/kafka-ui 8182:8080
