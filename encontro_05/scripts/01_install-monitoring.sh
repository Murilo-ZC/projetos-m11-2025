#!/bin/bash

echo "📊 Instalando stack de monitoramento para demonstração..."

# Verificar se o cluster está rodando
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cluster não está acessível. Execute setup-cluster.sh primeiro."
    exit 1
fi

# Criar namespace para monitoramento
echo "🏗️ Criando namespace para monitoramento..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Instalar Prometheus Operator (Helm)
echo "📦 Instalando Prometheus Operator..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --set grafana.enabled=true \
    --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
    --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
    --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false \
    --set prometheus.prometheusSpec.probeSelectorNilUsesHelmValues=false \
    --wait

# Aguardar pods estarem prontos
echo "⏳ Aguardando componentes de monitoramento..."
kubectl wait --for=condition=Ready pods -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s
kubectl wait --for=condition=Ready pods -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s

# Configurar ServiceMonitor para nossa aplicação
echo "🔍 Configurando monitoramento da aplicação..."
kubectl apply -f yamls_exemplo/monitoring/servicemonitor.yaml

# Configurar dashboards personalizados
echo "📈 Configurando dashboards..."
kubectl apply -f yamls_exemplo/monitoring/grafana-dashboards.yaml

# Expor serviços
echo "🌐 Expondo serviços de monitoramento..."
kubectl patch svc prometheus-operated -n monitoring -p '{"spec":{"type":"NodePort"}}'
kubectl patch svc grafana -n monitoring -p '{"spec":{"type":"NodePort"}}'

# Obter portas
PROMETHEUS_PORT=$(kubectl get svc prometheus-operated -n monitoring -o jsonpath='{.spec.ports[0].nodePort}')
GRAFANA_PORT=$(kubectl get svc grafana -n monitoring -o jsonpath='{.spec.ports[0].nodePort}')

# Obter credenciais do Grafana
GRAFANA_PASSWORD=$(kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

echo "✅ Monitoramento instalado com sucesso!"
echo ""
echo "🔗 Acessos:"
echo "   Prometheus: http://localhost:$PROMETHEUS_PORT"
echo "   Grafana: http://localhost:$GRAFANA_PORT"
echo "   Usuário: admin"
echo "   Senha: $GRAFANA_PASSWORD"
echo ""
echo "📊 Dashboards disponíveis:"
echo "   - Kubernetes Cluster Monitoring"
echo "   - HPA Metrics"
echo "   - Application Performance"
echo ""
echo "💡 Use 'kubectl get pods -n monitoring' para verificar status"
