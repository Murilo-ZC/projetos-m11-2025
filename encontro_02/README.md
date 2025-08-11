# Encontro 02 - Iniciando com Kubernetes

Nosso objetivo neste encontro é compreender o que é o Kubernetes e qual sua importância no mundo dos containers e orquestração. Vamos explorar como o Kubernetes facilita a gestão de aplicações em containers, oferecendo recursos avançados de escalabilidade, resiliência e automação.

Para isso, vamos primeiro utilizar o Kubernetes em um único nó local, para iniciarmos nossa interação com ele. Vamos utilizar o `Kind` (Kubernetes in Docker) e o `kubectl` para gerenciar nosso cluster local.

- Instalação do `Kind`:
- Instalação do `kubectl`:


Principais comandos que vamos utilizar hoje:

- `kind create cluster --name nome-do-cluster`: Cria um cluster Kubernetes local usando Kind.
- `kubectl cluster-info --context nome-do-cluster`: Exibe informações sobre o cluster Kubernetes.
- `kubectl get nodes`: Lista os nós do cluster.
- `kubectl get pods`: Lista os pods em execução no cluster.
- `kubectl get pods --all-namespaces`: Lista todos os pods em todos os namespaces.
- `kubectl describe pod nome-do-pod`: Exibe detalhes sobre um pod específico.
- `kubectl logs nome-do-pod`: Exibe os logs de um pod específico.
- `kubectl exec -it nome-do-pod -- /bin/sh`: Acessa o shell de um pod específico.
- `kubectl create deplyment nome-do-deployment --image=nome-da-imagem`: Cria um deployment com a imagem especificada.
- `kubectl get deployments`: Lista os deployments no cluster.
- `kubectl expose deployment nome-do-deployment --type=NodePort --port=80`: Expõe um deployment como um serviço acessível externamente.
- `kubectl get services`: Lista os serviços no cluster.
- `kubectl get svc nome-do-servico`: Exibe detalhes sobre um serviço específico.
- `kubectl get nodes -o wide`: Exibe informações detalhadas sobre os nós do cluster.
- `kubectl scale deployment nome-do-deployment --replicas=3`: Escala um deployment para ter 3 réplicas.
- `kubectl delete deployment nome-do-deployment`: Exclui um deployment do cluster.
- `kubectl delete service nome-do-servico`: Exclui um serviço do cluster.
- `kubectl delete pod nome-do-pod`: Exclui um pod específico do cluster.
- `kind get clusters`: Lista os clusters criados com Kind.
- `kind delete cluster --name nome-do-cluster`: Exclui o cluster Kubernetes criado com Kind.
