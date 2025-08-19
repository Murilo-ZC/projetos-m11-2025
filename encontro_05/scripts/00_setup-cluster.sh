#!/bin/bash

echo "🚀 Configurando cluster Kind para demonstração de escalabilidade..."

# Verificar se o Kind está instalado
if ! command -v kind &> /dev/null; then
    echo "❌ Kind não está instalado. Por favor, instale o Kind primeiro."
    exit 1
fi

# Verificar se o Docker está rodando
if ! docker info &> /dev/null; then
    echo "❌ Docker não está rodando. Por favor, inicie o Docker primeiro."
    exit 1
fi

# Criar cluster Kind com configurações otimizadas
echo "📦 Criando cluster Kind..."
kind create cluster --name aula-escalabilidade --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF

# Aguardar cluster estar pronto
echo "⏳ Aguardando cluster estar pronto..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Verificar status do cluster
echo "✅ Cluster criado com sucesso!"
echo "📊 Status dos nós:"
kubectl get nodes

# Verificar componentes do sistema
echo "🔍 Verificando componentes do sistema..."
kubectl get pods -n kube-system

# Configurar contexto
echo "🎯 Configurando contexto..."
kubectl config use-context kind-aula-escalabilidade

echo "🎉 Cluster configurado e pronto para demonstração!"
echo "💡 Use 'kubectl cluster-info' para ver informações do cluster"
