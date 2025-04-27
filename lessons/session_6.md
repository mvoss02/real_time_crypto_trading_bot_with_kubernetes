# Session 6

### Table of Contents

- [1. Goals](#1-goals)
- [2. Nuggets of wisdom](#2-nuggets-of-wisdom)
- [3. Video recordings and slides](#3-video-recordings-and-slides)
- [4. Homework](#4-homework)

## 1. Goals

- [x] Install RisingWave in dev cluster.
    - [x] Interact with RW using the psql client.
- [x] Push technical indicators from Kafka into RisingWave using Materialized views.
    - `query.sql`

- [x] Install Grafana
- [x] Add RisingWave as a data source in Grafana.
- [x] Create a dashboard in Grafana to visualize the data from RisingWave.
- [ ] Start building the backfill pipeline.
    - [ ] Ingest trades from Kraken REST API with historical trades.


## 2. Nuggets of wisdom

- To talk to RisingWave from a shell session you need to porforwards risingwave:4567

- There are 2 ways to move data from Kafka to RisingWave

    - Pull based -> define an SQL query like this
    ```sql
    CREATE TABLE technical_indicators (
        pair VARCHAR,
        open FLOAT,
        high FLOAT,
        low FLOAT,
        close FLOAT,
        volume FLOAT,
        window_start_ms BIGINT,
        window_end_ms BIGINT,
        candle_seconds INT,
        sma_7 FLOAT,
        sma_14 FLOAT,
        sma_21 FLOAT,
        sma_60 FLOAT,
        ema_7 FLOAT,
        ema_14 FLOAT,
        ema_21 FLOAT,
        ema_60 FLOAT,
        rsi_7 FLOAT,
        rsi_14 FLOAT,
        rsi_21 FLOAT,
        rsi_60 FLOAT,
        macd_7 FLOAT,
        macdsignal_7 FLOAT,
        macdhist_7 FLOAT,
        obv FLOAT,
        PRIMARY KEY (pair, window_start_ms, window_end_ms)
    ) WITH (
        connector='kafka',
        topic='technical_indicators',
        properties.bootstrap.server='kafka-e11b-kafka-bootstrap.kafka.svc.cluster.local:9092'
    ) FORMAT PLAIN ENCODE JSON;
    ```
    and RisingWave does the ingestion for us.

    - Push based -> use the RisingWave python SDK (`uv add risingwave-py`) and manually push data
    updates to whatever table you want.

- Transforming data on the fly is something we can do using MATERIALIZED VIEWS.
[ADD SLIDE WITH MODEL ERROR MONITORING]


## 3. Video recordings and slides

- [Video recordings]()

- [Slides]()

## 4. Homework

- Add the candles.json in a configmap so when we install grafana, we get the dashboard without
having to click-click-click again.

- Take a look at Metabase and use it instead of Grafana
    https://www.metabase.com/

- Add a dropdown to the Grafana dashboard to select which crypto to plot

- The sky is the limit. Make the coolest dashboard you can and we will add it to the course.

- Ingest historical for MANY crypto currencies, not just one. You can use cohort-3 code as an inspiration
    https://github.com/Real-World-ML/real-time-ml-system-cohort-3/blob/main/services/trades/kraken_api/rest.py


