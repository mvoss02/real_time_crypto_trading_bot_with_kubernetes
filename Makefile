########################################################
# Kubernetes Setup
########################################################



########################################################
# ML engineering operations
########################################################

# Start a service in development mode
dev:
	uv run services/$(service)/src/$(service)/main.py

# Build Docker image for a service
build:
	docker build -t $(service):dev -f docker/$(service).Dockerfile .

# Deploy a service to the kind cluster
deploy: build
	kind load docker-image $(service):dev --name rwml-34fa
	kubectl apply -f deployments/$(service).yaml

# Linting
lint:
	uv run ruff check . --fix

# Formatting
format:
	uv run ruff format .

########################################################
# ML platfrom operations
########################################################

# Start Cluster
create-dev-cluster:
	cd deployments/dev/kind/ && chmod +x ./create_cluster.sh &&  ./create_cluster.sh

delete-cluster:
	kind delete cluster --name rwml-34fa
	
install-ingress-nginx:
	cd rwml-k8s-workloads && \
	kubectl apply --recursive -f manifests/ingress-nginx-all-in-one.yaml

install-strimzi:
	cd rwml-k8s-workloads && \
	kubectl create namespace kafka && \
	kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka && \
	kubectl apply -f manifests/kafka-e11b.yaml && \

install-kafka-ui:
	cd rwml-k8s-workloads && \
	kubectl apply -f manifests/kafka-ui-all-in-one.yaml && \
	tmux new-session -d -s kafka-ui-forward 'kubectl -n kafka port-forward svc/kafka-ui 8182:8080'
	
install-risingwave:
	# cd rwml-k8s-workloads && \ # not needed
	helm repo add risingwavelabs https://risingwavelabs.github.io/helm-charts/ --force-update && \
	helm repo update && \
	helm upgrade --install --create-namespace --wait risingwave risingwavelabs/risingwave --namespace=risingwave -f kind/manifests/risingwave-values.yaml && \
	tmux new-session -d -s risingwave-forward 'kubectl -n risingwave port-forward svc/risingwave 4567:4567'

install-uv:
	curl -LsSf https://astral.sh/uv/install.sh | sh