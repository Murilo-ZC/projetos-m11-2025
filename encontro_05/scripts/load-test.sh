#!/bin/bash

echo "🧪 Iniciando testes de carga para demonstrar escalabilidade..."

# Verificar se a aplicação está rodando
if ! kubectl get pods -n aula-k8s -l app=php-apache | grep -q Running; then
    echo "❌ Aplicação não está rodando. Deploy primeiro a aplicação."
    exit 1
fi

# Obter porta do serviço
SERVICE_PORT=$(kubectl get svc php-apache -n aula-k8s -o jsonpath='{.spec.ports[0].port}')
SERVICE_IP=$(kubectl get svc php-apache -n aula-k8s -o jsonpath='{.spec.clusterIP}')

echo "🎯 Testando aplicação em: $SERVICE_IP:$SERVICE_PORT"
echo "📊 Status inicial dos pods:"
kubectl get pods -n aula-k8s -l app=php-apache

echo ""
echo "🚀 Iniciando teste de carga básico (30 segundos)..."
echo "   - 10 requisições simultâneas"
echo "   - Duração: 30 segundos"
echo "   - Monitorando escalabilidade..."

# Teste básico de carga
for i in {1..30}; do
    echo "📡 Teste $i/30 - $(date '+%H:%M:%S')"
    
    # Fazer 10 requisições simultâneas
    for j in {1..10}; do
        curl -s "http://$SERVICE_IP:$SERVICE_PORT/" > /dev/null &
    done
    
    # Aguardar todas as requisições
    wait
    
    # Mostrar status dos pods a cada 5 segundos
    if [ $((i % 5)) -eq 0 ]; then
        echo "📊 Status dos pods:"
        kubectl get pods -n aula-k8s -l app=php-apache -o wide
        echo ""
    fi
    
    sleep 1
done

echo ""
echo "✅ Teste de carga básico concluído!"
echo "📊 Status final dos pods:"
kubectl get pods -n aula-k8s -l app=php-apache -o wide

echo ""
echo "🔍 Verificando HPA:"
kubectl get hpa -n aula-k8s

echo ""
echo "📈 Métricas de CPU dos pods:"
kubectl top pods -n aula-k8s

echo ""
echo "💡 Para teste mais intensivo, execute: ./scripts/stress-test.sh"
