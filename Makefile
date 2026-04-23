up:
	kind create cluster --config kind/cluster.yaml
	kubectl apply -f platform/namespaces/
	kubectl apply -f platform/limits/
	kubectl apply -f platform/quotas/
	$(MAKE) label-nodes

label-nodes:
	kubectl label node devops-lab-worker node-role.kubernetes.io/worker-1=true --overwrite
	kubectl label node devops-lab-worker2 node-role.kubernetes.io/worker-2=true --overwrite

down:
	kind delete cluster --name devops-lab

status:
	kubectl get nodes -L node-role.kubernetes.io/worker-1,node-role.kubernetes.io/worker-2

reset: down up
