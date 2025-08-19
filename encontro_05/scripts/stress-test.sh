#!/bin/bash

echo "🔥 Iniciando teste de estresse para demonstrar escalabilidade máxima..."

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

# Obter porta do serviço
SERVICE_PORT=$(kubectl get svc php-apache -n aula-k8s -o jsonpath='{.spec.ports[0].port}')
SERVICE_IP=$(kubectl get svc php-apache -n aula-k8s -o jsonpath='{.spec.clusterIP}')

echo "🎯 Testando aplicação em: $SERVICE_IP:$SERVICE_PORT"
echo "📊 Status inicial:"
kubectl get pods -n aula-k8s -l app=php-apache
kubectl get hpa -n aula-k8s

echo ""
echo "🚀 Iniciando teste de estresse (60 segundos)..."
echo "   - 50 requisições simultâneas"
echo "   - Duração: 60 segundos"
echo "   - Monitorando escalabilidade máxima..."

# Função para monitorar em tempo real
monitor_scaling() {
    while true; do
        clear
        echo "📊 Monitoramento em Tempo Real - $(date '+%H:%M:%S')"
        echo "=================================================="
        echo ""
        echo "🔍 Status dos Pods:"
        kubectl get pods -n aula-k8s -l app=php-apache -o wide
        echo ""
        echo "📈 HPA Status:"
        kubectl get hpa -n aula-k8s
        echo ""
        echo "💻 Métricas de CPU:"
        kubectl top pods -n aula-k8s 2>/dev/null || echo "Métricas não disponíveis ainda"
        echo ""
        echo "⏳ Aguardando 3 segundos..."
        sleep 3
    done
}

# Iniciar monitoramento em background
monitor_scaling &
MONITOR_PID=$!

# Teste de estresse
for i in {1..60}; do
    echo "🔥 Estresse $i/60 - $(date '+%H:%M:%S')"
    
    # Fazer 50 requisições simultâneas
    for j in {1..50}; do
        curl -s "http://$SERVICE_IP:$SERVICE_PORT/" > /dev/null &
    done
    
    # Aguardar todas as requisições
    wait
    
    sleep 1
done

# Parar monitoramento
kill $MONITOR_PID 2>/dev/null

echo ""
echo "✅ Teste de estresse concluído!"
echo ""
echo "📊 Status final:"
kubectl get pods -n aula-k8s -l app=php-apache -o wide

echo ""
echo "🔍 HPA final:"
kubectl get hpa -n aula-k8s

echo ""
echo "📈 Métricas finais:"
kubectl top pods -n aula-k8s

echo ""
echo "🎯 Análise dos resultados:"
echo "   - Pods criados: $(kubectl get pods -n aula-k8s -l app=php-apache | grep -c Running)"
echo "   - CPU média: $(kubectl top pods -n aula-k8s | grep php-apache | awk '{sum+=$2} END {print sum/NR "m"}')"
echo "   - Memória média: $(kubectl top pods -n aula-k8s | grep php-apache | awk '{sum+=$3} END {print sum/NR "Mi"}')"

echo ""
echo "💡 Para ver histórico completo, acesse o Grafana ou Prometheus"
