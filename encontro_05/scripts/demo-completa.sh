#!/bin/bash

echo "🎬 Iniciando Demonstração Completa de Escalabilidade no Kubernetes"
echo "=================================================================="
echo ""

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
wait_for_user() {
    echo ""
    read -p "Pressione Enter para continuar... "
    echo ""
}

# Função para mostrar progresso
show_progress() {
    echo -e "${BLUE}🔄 $1${NC}"
}

# Verificar pré-requisitos
log_info "Verificando pré-requisitos..."
if ! command -v kind &> /dev/null; then
    log_error "Kind não está instalado"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    log_error "kubectl não está instalado"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    log_warning "Helm não está instalado. Instalando..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

log_success "Pré-requisitos verificados!"

echo ""
echo "🎯 Esta demonstração irá mostrar:"
echo "   1. Criação do cluster Kind"
echo "   2. Deploy da aplicação de exemplo"
echo "   3. Configuração do HPA"
echo "   4. Testes de escalabilidade"
echo "   5. Monitoramento em tempo real"
echo ""

wait_for_user

# Etapa 1: Setup do Cluster
log_info "Etapa 1: Configurando cluster Kind..."
show_progress "Criando cluster com 3 nós..."
./scripts/setup-cluster.sh

if [ $? -ne 0 ]; then
    log_error "Falha ao criar cluster"
    exit 1
fi

log_success "Cluster criado com sucesso!"
wait_for_user

# Etapa 2: Deploy da Aplicação
log_info "Etapa 2: Deploy da aplicação de exemplo..."
show_progress "Aplicando configurações base..."

kubectl apply -f yamls_exemplo/00_servico_base.yaml
kubectl wait --for=condition=Ready pods -l app=php-apache -n aula-k8s --timeout=120s

if [ $? -ne 0 ]; then
    log_error "Falha ao deploy da aplicação"
    exit 1
fi

log_success "Aplicação deployada com sucesso!"
echo ""
echo "📊 Status da aplicação:"
kubectl get pods -n aula-k8s -l app=php-apache

wait_for_user

# Etapa 3: Demonstração de Escala Manual
log_info "Etapa 3: Demonstração de escala manual..."
show_progress "Mostrando escala manual..."

echo "📈 Escalando para 3 réplicas..."
kubectl scale deployment php-apache -n aula-k8s --replicas=3

echo "⏳ Aguardando pods estarem prontos..."
kubectl wait --for=condition=Ready pods -l app=php-apache -n aula-k8s --timeout=120s

echo "📊 Status após escala manual:"
kubectl get pods -n aula-k8s -l app=php-apache

echo ""
echo "🔄 Voltando para 1 réplica..."
kubectl scale deployment php-apache -n aula-k8s --replicas=1

log_success "Escala manual demonstrada!"
wait_for_user

# Etapa 4: Configuração do HPA
log_info "Etapa 4: Configuração do HPA..."
show_progress "Aplicando configuração do HPA..."

kubectl apply -f yamls_exemplo/01_hpa_base.yaml

echo "⏳ Aguardando HPA estar ativo..."
sleep 10

echo "📊 Status do HPA:"
kubectl get hpa -n aula-k8s

log_success "HPA configurado com sucesso!"
wait_for_user

# Etapa 5: Teste de Escalabilidade
log_info "Etapa 5: Teste de escalabilidade automática..."
show_progress "Iniciando teste de carga..."

echo "🧪 Executando teste de carga básico..."
./scripts/load-test.sh

log_success "Teste de carga concluído!"
wait_for_user

# Etapa 6: Monitoramento
log_info "Etapa 6: Instalação do stack de monitoramento..."
show_progress "Instalando Prometheus e Grafana..."

./scripts/install-monitoring.sh

if [ $? -ne 0 ]; then
    log_warning "Falha na instalação do monitoramento. Continuando..."
else
    log_success "Monitoramento instalado com sucesso!"
fi

wait_for_user

# Etapa 7: Demonstração Final
log_info "Etapa 7: Demonstração final de escalabilidade..."
show_progress "Executando teste de estresse..."

echo "🔥 Executando teste de estresse intensivo..."
./scripts/stress-test.sh

log_success "Demonstração concluída!"

echo ""
echo "🎉 Demonstração de Escalabilidade Concluída!"
echo ""
echo "📚 Resumo do que foi demonstrado:"
echo "   ✅ Cluster Kind com múltiplos nós"
echo "   ✅ Aplicação web de exemplo"
echo "   ✅ Escala manual com kubectl scale"
echo "   ✅ HPA com escalabilidade automática"
echo "   ✅ Testes de carga e estresse"
echo "   ✅ Stack de monitoramento"
echo ""
echo "🔗 Próximos passos:"
echo "   - Explore os dashboards do Grafana"
echo "   - Experimente diferentes configurações de HPA"
echo "   - Teste com diferentes cargas de trabalho"
echo "   - Configure alertas e notificações"
echo ""
echo "💡 Para limpar o ambiente:"
echo "   kind delete cluster --name aula-escalabilidade"
