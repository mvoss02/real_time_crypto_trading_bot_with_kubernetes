# Session 3

### Table of contents

- [1. Goals](#1-goals)
- [2. Nuggets of wisdom](#2-nuggets-of-wisdom)
- [3. Video recordings and slides](#3-video-recordings-and-slides)
- [4. Further materials](#4-further-materials)
- [5. Homework](#5-homework)


## 1. Goals

- [x] Build the `candles` service.
- [x] Deploy the `candles` service to the `dev` cluster.
- [x] Deploy the `trades` service to the `prod` cluster
- [x] Deploy the `candles` service to the `prod` cluster
    - [x] build and push the image to the github container registry
    - [x] deployments/prod/candles/candles.yaml
    - [x] set KUBECONFIG to point to the `prod` cluster
    - [x] trigger the deployment manually with `kubectl apply -f deployments/prod/candles/candles.yaml`

- [x] Build boilerlate for the `technical-indicators` service.
- [ ] Install talib C library inside the devcontainer.

    
## 2. Nuggets of wisdom

- How to manually update the image of a deployment:
    ```sh
    kubectl set image deployment/trades -n rwml trades=ghcr.io/real-world-ml/trades:0.1.5-beta.@sha256:1c4933acedfa3611903a1f7e2e6313e97ba7df1b84f4742f9e7368fb62cafd2e
    ```


- How to copy a file from one branch (for example `dev`) to another branch (for example `main`):
    ```sh
    git checkout dev -- deployments/prod/trades/trades.yaml
    ```

## 3. Video recordings and slides

- [Video recordings](https://www.realworldml.net/products/building-a-real-time-ml-system-together-cohort-4/categories/2157432311)

- [Slides](https://www.realworldml.net/products/building-a-real-time-ml-system-together-cohort-4/categories/2157432311/posts/2186755976)


## 4. Further materials

- [Kafka fundamentals](https://www.youtube.com/watch?v=-RDyEFvnTXI)

    Kafka topics, Kafka partitions, Kafka replication factor, Message keys.


- [The Kafka Schema Registry](https://risingwave.com/blog/comprehensive-guide-to-kafka-schema-registry/)

    Today we saw how an outdated version of the `trades` service was deployed to the `prod` cluster, producing messages with a different format expected by the `candles` service.

    To avoid this type of data issues, we can use a Kafka registry to validate the messages.

## 5. Homework

- Instead of having one Dockerfile for each service, write a single Dockerfile that builds both services, by using build arguments.

- Improve this build command with proper labeling (open containers labeling scheme)
    ```sh
    docker buildx build --push --platform linux/amd64 -t ghcr.io/real-world-ml/${service}:0.1.5-beta.${BUILD_DATE} -f docker/${service}.Dockerfile .
    ```




