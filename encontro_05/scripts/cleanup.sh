#!/bin/bash

echo "🧹 Iniciando limpeza do ambiente de demonstração..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Função para aguardar confirmação do usuário
confirm_action() {
    echo ""
    read -p "Tem certeza que deseja continuar? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operação cancelada."
        exit 0
    fi
}

# Verificar se o cluster existe
if ! kind get clusters | grep -q aula-escalabilidade; then
    log_warning "Cluster 'aula-escalabilidade' não encontrado."
    exit 0
fi

echo "🔍 Encontrando recursos para limpeza..."

# Listar recursos existentes
echo ""
echo "📊 Recursos encontrados:"
echo "========================"

# Namespaces
echo "📁 Namespaces:"
kubectl get namespaces | grep -E "(aula-k8s|monitoring|ingress-nginx)" || echo "   Nenhum namespace encontrado"

# Deployments
echo ""
echo "🚀 Deployments:"
kubectl get deployments --all-namespaces | grep -E "(aula-k8s|monitoring|ingress-nginx)" || echo "   Nenhum deployment encontrado"

# Services
echo ""
echo "🔌 Services:"
kubectl get services --all-namespaces | grep -E "(aula-k8s|monitoring|ingress-nginx)" || echo "   Nenhum service encontrado"

# HPA
echo ""
echo "📈 HPA:"
kubectl get hpa --all-namespaces | grep -E "(aula-k8s)" || echo "   Nenhum HPA encontrado"

# ConfigMaps
echo ""
echo "⚙️  ConfigMaps:"
kubectl get configmaps --all-namespaces | grep -E "(aula-k8s|monitoring)" || echo "   Nenhum ConfigMap encontrado"

echo ""
echo "⚠️  ATENÇÃO: Esta operação irá remover TODOS os recursos listados acima!"
confirm_action

# Limpeza por namespace
log_info "Iniciando limpeza dos namespaces..."

# Limpar namespace aula-k8s
if kubectl get namespace aula-k8s &> /dev/null; then
    log_info "Removendo namespace aula-k8s..."
    kubectl delete namespace aula-k8s --wait=true --timeout=300s
    if [ $? -eq 0 ]; then
        log_success "Namespace aula-k8s removido com sucesso!"
    else
        log_warning "Timeout ao remover namespace aula-k8s. Forçando remoção..."
        kubectl delete namespace aula-k8s --force --grace-period=0
    fi
fi

# Limpar namespace monitoring
if kubectl get namespace monitoring &> /dev/null; then
    log_info "Removendo namespace monitoring..."
    kubectl delete namespace monitoring --wait=true --timeout=300s
    if [ $? -eq 0 ]; then
        log_success "Namespace monitoring removido com sucesso!"
    else
        log_warning "Timeout ao remover namespace monitoring. Forçando remoção..."
        kubectl delete namespace monitoring --force --grace-period=0
    fi
fi

# Limpar namespace ingress-nginx
if kubectl get namespace ingress-nginx &> /dev/null; then
    log_info "Removendo namespace ingress-nginx..."
    kubectl delete namespace ingress-nginx --wait=true --timeout=300s
    if [ $? -eq 0 ]; then
        log_success "Namespace ingress-nginx removido com sucesso!"
    else
        log_warning "Timeout ao remover namespace ingress-nginx. Forçando remoção..."
        kubectl delete namespace ingress-nginx --force --grace-period=0
    fi
fi

# Verificar se ainda existem recursos órfãos
log_info "Verificando recursos órfãos..."

# Verificar CRDs do Prometheus
if kubectl get crd | grep -q prometheus; then
    log_warning "CRDs do Prometheus ainda existem. Removendo..."
    kubectl delete crd --selector=app.kubernetes.io/name=prometheus
fi

# Verificar CRDs do VPA
if kubectl get crd | grep -q verticalpodautoscaler; then
    log_warning "CRDs do VPA ainda existem. Removendo..."
    kubectl delete crd verticalpodautoscalers.autoscaling.k8s.io
fi

# Verificar se ainda existem recursos
echo ""
echo "🔍 Verificação final de recursos..."
kubectl get all --all-namespaces | grep -E "(aula-k8s|monitoring|ingress-nginx)" || echo "   ✅ Nenhum recurso encontrado!"

# Perguntar se deve remover o cluster
echo ""
read -p "Deseja remover o cluster Kind 'aula-escalabilidade'? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Removendo cluster Kind..."
    kind delete cluster --name aula-escalabilidade
    
    if [ $? -eq 0 ]; then
        log_success "Cluster removido com sucesso!"
    else
        log_error "Erro ao remover cluster"
    fi
else
    log_info "Cluster mantido. Use 'kind delete cluster --name aula-escalabilidade' para removê-lo manualmente."
fi

# Limpeza de arquivos temporários
log_info "Limpando arquivos temporários..."

# Remover arquivos de configuração local
if [ -f ~/.kube/config-kind-aula-escalabilidade ]; then
    rm ~/.kube/config-kind-aula-escalabilidade
    log_success "Configuração local removida"
fi

# Verificar se há outros clusters
echo ""
echo "🔍 Clusters Kind restantes:"
kind get clusters

echo ""
log_success "Limpeza concluída!"
echo ""
echo "💡 Para recriar o ambiente, execute:"
echo "   ./scripts/setup-cluster.sh"
echo ""
echo "🎯 Para uma nova demonstração, execute:"
echo "   ./scripts/demo-completa.sh"
