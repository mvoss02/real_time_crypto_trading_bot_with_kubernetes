# Session 5

### Table of Contents

- [1. Goals](#1-goals)
- [2. Nuggets of wisdom](#2-nuggets-of-wisdom)
- [3. Video recordings and slides](#3-video-recordings-and-slides)
- [4. Homework](#4-homework)

## 1. Goals

- [x] Build the technical indicators service.
- [ ] Dockerize the technical indicators service by installing the talib library.
## 2. Questions and answers

```
How is it (meaning quixstreams) different them Apache Structured Streaming?
```

QuixStreams + NATS is used for IoT data volumes.
NATS is an alternative to Kafka which has less overhead and is more performant.
https://quix.io/templates/speed-up-operational-insights-on-industrial-machinery


## 2. Nuggets of wisdom

- How to install talib in your local computer?
    https://ta-lib.org/install/

- How to install it in the Docker image?
    2 options:
    - Single stage docker bild -> `docker/technical_indicators.Dockerfile`
    - 2 stage docker build -> `docker/technical_indicators.Dockerfile.2stage`
        The idea is that we need `gcc` at build stage, but once the talib library is installed, and properly linked,
        we no longer need `gcc`. Same applies for `uv`. We need as a build tool for Python (because it generates the exact
        same Python libraries we used when developing, `uv.lock`), but we don't need it at runtime.

        We saw that a naive 1-stage docker build generates an image of 1.7GB.
        A 2-stage build generates an image of 500MB (60% less)


Today I went back to VSCode, because of its new AI coding agent. To make sure you use VSCode to write
your commit messages do

```sh
git config --global core.editor "code --wait"
```

## 3. Video recordings and slides

- [Video recordings](https://www.realworldml.net/products/building-a-real-time-ml-system-together-cohort-4/categories/2157509247)

- [Slides](https://www.realworldml.net/products/building-a-real-time-ml-system-together-cohort-4/categories/2157509247/posts/2187103413)

## 4. Homework

- [ ] Move the `ta-lib` dependency from the workspace `pyproject.toml` to the `pyproject.toml` of the `technical_indicators` service.
- [ ] Extract the hard-coded `sma_7`, `sma_14`, `sma_21` and `sma_50` indicators to a configuration file.

    I suggest you extract them to a `config.yaml` file that you load into the `config.py`. You can use a @classmethod for that.
    

