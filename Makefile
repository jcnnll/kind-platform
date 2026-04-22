up:
	kind create cluster --config kind/cluster.yaml
	# kubectl apply -f ingress-nginx
	# kubectl apply -f platform/

down:
	kind delete cluster --name devops-lab

status:
	kubectl get nodes

reset: down up
