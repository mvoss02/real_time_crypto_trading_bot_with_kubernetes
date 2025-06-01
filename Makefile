# Runs the trades service as a standalone Pyton app (not Dockerized)
dev:
	uv run services/${service}/src/${service}/main.py

# Builds and pushes the docker image to the given environment
build-and-push:
	./scripts/build-and-push-image.sh ${image} ${env}

# Deploys a service to the given environment
deploy:
	./scripts/deploy.sh ${service} ${env}

lint:
	ruff check . --fix


# (Re-)Start Cluster
create-dev-cluster:
	cd deployments/dev/kind/ && chmod +x ./create_cluster.sh &&  ./create_cluster.sh