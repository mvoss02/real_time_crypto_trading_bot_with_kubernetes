# Session 1

### Table of contents

- [1. Goals](#1-goals)
- [2. Your questions](#2-your-questions)
- [3. Nuggets of wisdom](#3-nuggets-of-wisdom)
- [4. Video recordings and slides](#4-video-recordings-and-slides)
- [5. Further materials](#5-further-materials)
- [6. Homework](#6-homework)

## 1. Goals

- [x] ML system architecture
- [x] Deploy Kafka in our dev kubernetes cluster.
- [x] Deploy the Kafka UI in our dev kubernetes cluster.
- [x] Push some fake data to Kafka
- [x] Push some real data to Kafka
- [x] Explain basics of Docker

## 2. Your questions

- *How do we notify to ML algo to retrain with new features?*

    We will implement hourly or daily automatic model retraining using Kubernetes cron jobs.
    If you are interested in the details, check out [this article](https://refine.dev/blog/kubernetes-cron-jobs/#yaml-configuration-walkthrough-with-a-screenshot-of-the-yaml-file-and-command-line-execution).

- *Is the feature pipeline different the data pipeline?*

    A feature pipeline is a special case of a data pipeline, whose output is a set of reusable features used to train ML models, that are pushed to a feature store. Think of feature pipelines as data pipelines that transform raw data into ML model features that can be reused accross different models.

    For example, let's say you work in e-commerce and you ingest product data. One of the parameters
    of every product is the category, which more often than not, does not follow a consistent
    naming scheme.

    ```
    {
        "product_type": "shoe":
        "brand": "Adidas"
    },
    {
        "product_type": "shoes",
        "brand": "Nike"
    }
    ```

    Both products are essentially `shoes`, but the category name is not consistent. In this case,
    your feature pipeline can transform the `product_type` into a consistent category name, for example `SHOE`, and save it to the feature store.

    Now, when it comes to using this feature, depending on the model you might need to encode it,
    for example, one-hot encoding, or label encoding.

    This encoding operation is model-dependent, and depends on the specific slice of training data you used to generate the encodings. In other words, it is not reusable accross different models.

    I don't recommend you save encoded features in the feature store, but rather generate them on the fly as part of the training and inference pipelines.
    

- *Do we make predictions with the same features used to train the models?*

    Yes, our inference pipeline will generate predictions using the same set of features used to train the models.

    For example, let's say our features are:
    - `current_price`
    - `volume_last_10_minutes`
    - `moving_average_last_10_minutes`

    and the target we want to predict is: `price_in_10_minutes`.

    When we train the model, we will use historical data for these 3 features and the target. This means we will use a dataset of
    - N * 3 features
    - N targets
    where N is a large number, for example 10,000.

    The model will be a (hopefully accurate) mapping `f` between these 3 features and the target.

    `f: (current_price, volume_last_10_minutes, moving_average_last_10_minutes) -> price_in_10_minutes`

    This mapping `f` depends on a bunch of parameters that we will need to find (this is called "training" the model).

    Now, when we deploy the model, we will fetch the most recent values for each of these 3 features, and use them to generate a prediction.

    `f(current_price, volume_last_10_minutes, moving_average_last_10_minutes) -> price_in_10_minutes`

    Using the same features both at training and at inference is a MUST. Otherwise, your deployed model will always perform worse than the one you trained.

    
- *Where does the correction of unexpected missing values happen: in the feature store or during inference in the inference pipeline? unexpected missing values designate deviation from the training dataset.*

    It depends whether the data is missing because of a data collection issue or because it is simply not available.

    For example:

    - If the data is missing because of a data collection issue, you should correct it upstream in your feature pipelines. For example, if your feature pipeline is fetching data from an outdaded table in the datawarehouse, that has lots of missing values, you should first fix that outdated table in the datawarehouse, and the re-run your feature pipeline to backfill the missing values in the feature store.

    - If the data is missing because it is simply not available, you should impute in in your training pipeline, and use THE EXACT SAME IMPUTATION METHOD in your inference pipeline. Otherwise, you will introduce [online-offline feature skew](https://www.hopsworks.ai/dictionary/online-offline-feature-skew). For example, if you want to do product demand prediction using daily time series data, and you have a product with very low historical sales, you will need to do some form of imputation.

- *We use features with data that is arriving all the time. Ideally, this new data should have similarity to the features that you trained the model on*

    Yes. If the data used for inference is too different from the data used for training, the model will perform poorly.

- *Can we deploy everywhere we want with kuberrnetees?*

    If by "everywhere" you mean "on any cloud provider", then yes.
    Kubernetes is an open-source platform for container orchestration, and it is available on any cloud provider: AWS, GCP, Azure, Digital Ocean. You can also
    run Kubernetes on-premise, on your own servers (aka bare metal). This something Marius is an expert in, so if you want to learn how to do it, you can ask him.

- *Do we need GPU for this project locally?*

    No, you don't need a GPU for this project.
    We will rent a GPU instance in the cloud and use it to fine-tune and deploy our LLM.

- *Can you tell us about the pros and cons for kafka in case of batch or real time problems?*

    Kafka is a tool to move data from one place to another in real-time.
    
    If you build batch systems, you don't need Kafka.

    If you need to move data from one place to another in real-time, Kafka is a great tool.

    On the cons side, adding Kafka means you need to manage another service.

    So again, you need to see if the benefits of using Kafka outweigh the complexity it adds to your system.
    
- *First time trying out Kubernetes and Docker, any resources before jumping onto?*

    Yes. In the last section of this document you will find a couple of resources that Marius has found.

- *Can we imagine outliers detection in this project? If yes, in what step will they be treated?*

    Yes. For example, we can have an outlier detection service that periodially checks for outliers in the feature store.

    If these outliers are a deal breaker, you can also perform this detection as part of the feature pipeline. So, if the feature pipeline generates something that is an outlier, you can discard it, and not push it to the feature store.
    
- *Give us some equivalent tools of kafka, with prons and cons?*
    3 alternatives you can try:
    * [Redpanda](https://github.com/redpanda-data/redpanda/)
    * [RabbitMQ](https://github.com/rabbitmq/rabbitmq-server)
    * [NATS](https://github.com/nats-io/nats-server)


- *Cons and pros for kafka vs alternatives ?*
    **Redpanda**

    Pros:
    * Compatible with Kafka API (drop-in replacement) so you can interact using the exact same API (for example using the Quixstreams Python library)
    * No ZooKeeper dependency, simpler architecture
    * Better performance with lower resource usage, as it is written in C++, as opposed to Kafka's Java.

    Cons:
    * Newer, less mature ecosystem. Marius had problems installing it in the cluster, so we ended up using Strimzi Kafka.

    **RabbitMQ**
    
    Pros:
    * Easier setup and management for small workloads

    Cons:
    * Less scalable for high-throughput scenarios

    **NATS**
    Pros:

    * Extremely lightweight and simple
    * Easy to deploy to k8s. See [this](https://github.com/nats-io/k8s). Marius Rugan proposed it, as he has used it successfully in the past.

    Cons:
    * Fewer guarantees for message delivery


- *Suppose your API is producing data fastly and your service is down. Does kafka have live limits for keeping data ?*

    Yes, these are called Kafka retention limits. These retention limits can be

    - Time-based -> for example, drop messages that are older than 30 days. 
    - Size-based -> for example, drop older messages as soon as the topic size exceeds XGB of data.

    In practice, what happens in many companies is that they
    end up having time-based retentions periods of months, turning their Kafka cluster as a distributed database, with the Kafka topics
    working as tables.

    If you use time-based limits you also need to monitor the volume of the topic, to avoid running out of disk space in your cluster.
    

- *Does kafka handle retries in case of failures?*

    Kafka does not handle retries in case of failures of producers or consumer apps. Kafka topics are places where you can push data (aka produce)
    and read data (aka consume) with low-latency. They also persist the data, so if for whatever reason your consumer app is down, once you spin it up
    again it can continue processing messages without data loss.

- *Do we need the port forwarding command in the install_kafka_ui.sh script*

    When working in the dev cluster, the easiest way to access the UI is with port forwarding. The command that does the port forwarding is
    ```sh
    kubectl -n kafka port-forward svc/kafka-ui 8182:8080
    ```
    This is a command that blocks the terminal, so if you want to add it to the `install_kafka_ui.sh` script you need to spaw in the background, for example using nohup
    ```sh
    nohup kubectl -n kafka port-forward svc/kafka-ui 8182:8080 > kafka-ui.log 2>&1 &
    ```

- *For installing kafka into kubernetes cluster, are these standard scripts or do we need to modify sometimes?*
    The installation script does 3 things:

    ```sh
    #!/bin/bash

    # 1. Creates a namespace called `kafka` (standard)
    kubectl create namespace kafka

    # 2. Downloads and applies Strimzi manifests to set up the Kafka operator (standard)
    kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
    
    # 3. Deploys the Kafka cluster given the configuration in the yaml file
    kubectl apply -f manifests/kafka-e11b.yaml
    ```
    Steps 1 and 2 are standard. Step 3 is the part you customzie. In this case, Marius put together a simple configuration in `kafka-e11b.yaml` with 1 kafka broker that is enough for our dev cluster.

- *Are topic in kafka contains images ?*

    Yes, you can push images to Kafka topics but you first need to encode them
    into a string, for example using base64 encoding.

    Images (e.g. JPGEG) are binary files, meaning they contain data that is not human-readable.
    
    For example, a JPEG image looks like this:
    ```
    Binary JPEG file:
    FF D8 FF E0 00 10 4A 46 49 46 00 01 01 01 00 48 00 48 00 00 ...
    ```
    
    If you want to push a JPEG image into a Kafka topic, you can something like this:

    ```python
    import base64
    from pathlib import Path

    def encode_image_to_base64(image_path: Path) -> str:
        """Encode an image file to base64 string."""
        with open(image_path, 'rb') as image_file:
            # Read the image file
            image_data = image_file.read()
            # Encode to base64
            base64_string = base64.b64encode(image_data).decode('utf-8')
        return base64_string

    from quixstreams import Application

    producer = Application(...).get_producer()

    producer.produce(
        topic="my_image_topic",
        value=encode_image_to_base64(Path("path/to/image.jpg")),
        key="my_image_key"
    )
    ```

    Having said this, be aware that Kafka messages have a default maximum size of 1MB.
    This means that you should either/and

    - Increase the message size limit
    - Split large images into smaller chunks

    All in all, this is not a good idea, so I would recommend you to find a better solution.

    For example, you can store the actual images on cloud storage (e.g. AWS S3 or a Minio bucket in your Kubernetes cluster) and push only URL of the image into a Kafka topic.


- *Great Pau, can you generate algorithm (step by step ) for websocket.py micro service with all methods you defined to build ,, It will helpful to understand and build ourselves ( basically low level design )?*

    Sure. To build Python service that consumes data from a websocket you can do the following:

    1. `uv add websocket-client`
    2. Get the websocket URL for the API you want to consume data from. For example,
    for Kraken websocket API it is `wss://ws.kraken.com`.
    3. Create a pydantic object that will be used to store the data from the websocket.
        ```python
        from pydantic import BaseModel

        class Data(BaseModel):
            """
            This is the object that will be used to store the data from you get from the websocket
            """
            field_1: str
            field_2: int
            field_3: float
        ```
    4. Build a Python object to encapsulate the websocket connection and the data parsing logic. For example:

        ```python
        from websocket import create_connection
        class MyWebsocketClient:
            URL = "wss://ws.kraken.com"
            def __init__(self):
                self._ws = create_connection(self.URL)

            def get_data(self) -> list[Data]:
                """
                This method will be called by the main loop of your service.
                """
                data = self._ws.recv()

                # validate the data is a valid JSON object
                
                # parse the JSON object into the Data object

                # return the list of Data objects
                return [Data(field_1="value_1", field_2=1, field_3=1.0)]

            def _subscribe(self):
                """
                Check the documentation of the websocket API you are using to find out
                what you need to send to the server to subscribe to the data you want.
                """
                #For example:
                self._ws.send(json.dumps({"event": "subscribe", "pair": ["BTC/USD"]}))  
        ```

- @Pau, how do you suggest to utilize Tuesdays or learn effectively after the each session?

    I suggest you first try to run the code yourself. If you get stuck, ask questions on the discord channel.

    After that try to complete the challenges that I add at the end of each session.

    If you have any questions, you can ask them on the discord channel.


## 3. Nuggets of wisdom

1. How to make the Kafka UI available on your local machine:
    ```sh
    kubectl -n kafka port-forward svc/kafka-ui 8182:8080
    ```

    This will make the Kafka UI available at `http://localhost:8182`.


2. How to check connectivity to the Kafka broker on TCP:
    
    ```sh
    nc -vvv localhost 31234
    ```

    The kind configuration that Marius put together (see `kind-with-portmapping.yaml`) already sets up the port forwarding to the kafka broker, so there is no need to do it manually in this case.
    ```
    # kind-with-portmapping.yaml
    - containerPort: 31234
        hostPort: 31234
        listenAddress: "127.0.0.1"
        protocol: TCP
    ```

## 4. Video recordings and slides

- [Video recordings](https://www.realworldml.net/products/building-a-real-time-ml-system-together-cohort-4/categories/2157410971)

- [Slides](https://www.realworldml.net/products/building-a-real-time-ml-system-together-cohort-4/categories/2157410971/posts/2186660860)


## 5. Further materials

- [Learn Kubernetes basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Kubernetes overview](https://kubernetes.io/docs/concepts/overview/)

## 6. Homework

- [Ingest trades in real time from Binance](https://developers.binance.com/docs/derivatives/usds-margined-futures/market-data/websocket-api/Symbol-Price-Ticker)

