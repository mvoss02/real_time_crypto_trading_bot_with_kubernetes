#!/bin/bash

kubectl create namespace kafka
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

# Give CRDs time to be established
sleep 10

kubectl apply -f manifests/kafka-e11b.yaml

# Trick to check Kajka connectivity to the broker through TCP:
# ```sh
# nc -vvv localhost 31234
# ```
