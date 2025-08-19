#!/bin/bash

echo "📊 Iniciando monitoramento contínuo da escalabilidade..."

# Verificar se a aplicação está rodando
if ! kubectl get pods -n aula-k8s -l app=php-apache | grep -q Running; then
    echo "❌ Aplicação não está rodando. Deploy primeiro a aplicação."
    exit 1
fi

# Verificar se o HPA está configurado
if ! kubectl get hpa -n aula-k8s | grep -q php-apache; then
    echo "❌ HPA não está configurado. Configure primeiro o HPA."
    exit 1
fi

echo "🎯 Monitorando aplicação: php-apache"
echo "📈 HPA configurado para CPU: 50%"
echo "🔄 Atualizando a cada 5 segundos..."
echo "⏹️  Pressione Ctrl+C para parar"
echo ""

# Função para limpar tela
clear_screen() {
    clear
    echo "📊 Monitoramento de Escalabilidade - $(date '+%H:%M:%S')"
    echo "========================================================"
    echo ""
}

# Função para mostrar status dos pods
show_pods_status() {
    echo "🔍 Status dos Pods:"
    echo "-------------------"
    kubectl get pods -n aula-k8s -l app=php-apache -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,READY:.status.conditions[?(@.type=='Ready')].status,CPU:.spec.containers[0].resources.requests.cpu,MEMORY:.spec.containers[0].resources.requests.memory" 2>/dev/null || kubectl get pods -n aula-k8s -l app=php-apache
    echo ""
}

# Função para mostrar HPA
show_hpa_status() {
    echo "📈 Status do HPA:"
    echo "-----------------"
    kubectl get hpa -n aula-k8s -o custom-columns="NAME:.metadata.name,TARGETS:.status.currentMetrics[0].resource.currentAverageUtilization%,MINPODS:.spec.minReplicas,MAXPODS:.spec.maxReplicas,REPLICAS:.status.currentReplicas" 2>/dev/null || kubectl get hpa -n aula-k8s
    echo ""
}

# Função para mostrar métricas
show_metrics() {
    echo "💻 Métricas de Recursos:"
    echo "------------------------"
    kubectl top pods -n aula-k8s 2>/dev/null || echo "Métricas não disponíveis ainda"
    echo ""
}

# Função para mostrar eventos
show_events() {
    echo "📝 Eventos Recentes:"
    echo "---------------------"
    kubectl get events -n aula-k8s --sort-by='.lastTimestamp' | tail -5
    echo ""
}

# Função para mostrar estatísticas
show_stats() {
    echo "📊 Estatísticas:"
    echo "----------------"
    TOTAL_PODS=$(kubectl get pods -n aula-k8s -l app=php-apache | grep -c Running)
    TOTAL_CPU=$(kubectl get pods -n aula-k8s -l app=php-apache -o jsonpath='{.items[*].spec.containers[0].resources.requests.cpu}' | tr ' ' '\n' | sed 's/m//g' | awk '{sum+=$1} END {print sum}')
    TOTAL_MEMORY=$(kubectl get pods -n aula-k8s -l app=php-apache -o jsonpath='{.items[*].spec.containers[0].resources.requests.memory}' | tr ' ' '\n' | sed 's/Mi//g' | awk '{sum+=$1} END {print sum}')
    
    echo "   Total de Pods: $TOTAL_PODS"
    echo "   CPU Total: ${TOTAL_CPU}m"
    echo "   Memória Total: ${TOTAL_MEMORY}Mi"
    echo ""
}

# Loop principal de monitoramento
while true; do
    clear_screen
    show_pods_status
    show_hpa_status
    show_metrics
    show_stats
    show_events
    
    echo "⏳ Próxima atualização em 5 segundos..."
    echo "💡 Dica: Execute ./scripts/load-test.sh em outro terminal para gerar carga"
    
    sleep 5
done
