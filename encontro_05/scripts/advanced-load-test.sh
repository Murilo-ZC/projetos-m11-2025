#!/bin/bash

echo "🚀 Iniciando Testes de Carga Avançados para Demonstração..."

# Verificar se a aplicação está rodando
if ! kubectl get pods -n aula-k8s -l app=php-apache | grep -q Running; then
    echo "❌ Aplicação não está rodando. Deploy primeiro a aplicação."
    exit 1
fi

# Obter porta do serviço
SERVICE_PORT=$(kubectl get svc php-apache -n aula-k8s -o jsonpath='{.spec.ports[0].port}')
SERVICE_IP=$(kubectl get svc php-apache -n aula-k8s -o jsonpath='{.spec.clusterIP}')

echo "🎯 Testando aplicação em: $SERVICE_IP:$SERVICE_PORT"
echo ""

# Função para mostrar status atual
show_status() {
    echo "📊 Status atual:"
    kubectl get pods -n aula-k8s -l app=php-apache -o wide
    echo ""
    kubectl get hpa -n aula-k8s
    echo ""
}

# Função para teste de carga gradual
gradual_load_test() {
    echo "📈 Teste 1: Carga Gradual (5 minutos)"
    echo "   - Iniciando com 5 requisições/s"
    echo "   - Aumentando para 50 requisições/s"
    echo "   - Observando comportamento do HPA"
    echo ""
    
    for i in {1..300}; do
        # Calcular requisições baseado no tempo
        if [ $i -le 60 ]; then
            requests=5
        elif [ $i -le 120 ]; then
            requests=10
        elif [ $i -le 180 ]; then
            requests=25
        elif [ $i -le 240 ]; then
            requests=40
        else
            requests=50
        fi
        
        echo "⏱️  Minuto $((i/60 + 1)):$((i%60)) - $requests req/s"
        
        # Fazer requisições
        for j in $(seq 1 $requests); do
            curl -s "http://$SERVICE_IP:$SERVICE_PORT/" > /dev/null &
        done
        
        wait
        
        # Mostrar status a cada 30 segundos
        if [ $((i % 30)) -eq 0 ]; then
            show_status
        fi
        
        sleep 1
    done
    
    echo "✅ Teste de carga gradual concluído!"
}

# Função para teste de picos
spike_load_test() {
    echo "🔥 Teste 2: Picos de Carga (3 minutos)"
    echo "   - Períodos de baixa carga (5 req/s)"
    echo "   - Picos súbitos (100 req/s por 30s)"
    echo "   - Observando tempo de resposta do HPA"
    echo ""
    
    for i in {1..180}; do
        # Definir padrão de picos
        if [ $((i % 60)) -ge 45 ]; then
            requests=100
            echo "🚀 PICO DE CARGA - $requests req/s"
        else
            requests=5
            echo "😴 Carga baixa - $requests req/s"
        fi
        
        # Fazer requisições
        for j in $(seq 1 $requests); do
            curl -s "http://$SERVICE_IP:$SERVICE_PORT/" > /dev/null &
        done
        
        wait
        
        # Mostrar status a cada 15 segundos
        if [ $((i % 15)) -eq 0 ]; then
            show_status
        fi
        
        sleep 1
    done
    
    echo "✅ Teste de picos de carga concluído!"
}

# Função para teste de carga constante
constant_load_test() {
    echo "⚡ Teste 3: Carga Constante (2 minutos)"
    echo "   - 30 requisições/s constantes"
    echo "   - Verificando estabilização"
    echo "   - Observando distribuição de carga"
    echo ""
    
    for i in {1..120}; do
        echo "🔄 Carga constante - 30 req/s ($i/120)"
        
        # Fazer 30 requisições simultâneas
        for j in {1..30}; do
            curl -s "http://$SERVICE_IP:$SERVICE_PORT/" > /dev/null &
        done
        
        wait
        
        # Mostrar status a cada 20 segundos
        if [ $((i % 20)) -eq 0 ]; then
            show_status
        fi
        
        sleep 1
    done
    
    echo "✅ Teste de carga constante concluído!"
}

# Função para teste de recuperação
recovery_test() {
    echo "🔄 Teste 4: Teste de Recuperação (2 minutos)"
    echo "   - Carga alta (80 req/s) por 1 minuto"
    echo "   - Carga baixa (5 req/s) por 1 minuto"
    echo "   - Observando escala down do HPA"
    echo ""
    
    # Fase 1: Carga alta
    echo "📈 Fase 1: Carga alta (80 req/s)"
    for i in {1..60}; do
        echo "🔥 Carga alta - 80 req/s ($i/60)"
        
        for j in {1..80}; do
            curl -s "http://$SERVICE_IP:$SERVICE_PORT/" > /dev/null &
        done
        
        wait
        sleep 1
    done
    
    show_status
    
    # Fase 2: Carga baixa
    echo "📉 Fase 2: Carga baixa (5 req/s)"
    for i in {1..60}; do
        echo "😴 Carga baixa - 5 req/s ($i/60)"
        
        for j in {1..5}; do
            curl -s "http://$SERVICE_IP:$SERVICE_PORT/" > /dev/null &
        done
        
        wait
        
        # Mostrar status a cada 15 segundos
        if [ $((i % 15)) -eq 0 ]; then
            show_status
        fi
        
        sleep 1
    done
    
    echo "✅ Teste de recuperação concluído!"
}

# Menu principal
echo "🎯 Escolha o tipo de teste:"
echo "1. Carga Gradual (5 min)"
echo "2. Picos de Carga (3 min)"
echo "3. Carga Constante (2 min)"
echo "4. Teste de Recuperação (2 min)"
echo "5. Todos os Testes (12 min)"
echo ""

read -p "Digite sua escolha (1-5): " choice

case $choice in
    1)
        gradual_load_test
        ;;
    2)
        spike_load_test
        ;;
    3)
        constant_load_test
        ;;
    4)
        recovery_test
        ;;
    5)
        echo "🚀 Executando todos os testes..."
        gradual_load_test
        echo ""
        spike_load_test
        echo ""
        constant_load_test
        echo ""
        recovery_test
        ;;
    *)
        echo "❌ Escolha inválida"
        exit 1
        ;;
esac

echo ""
echo "🎉 Todos os testes concluídos!"
echo ""
echo "📊 Status final:"
show_status

echo ""
echo "📈 Análise dos resultados:"
echo "   - Pods criados: $(kubectl get pods -n aula-k8s -l app=php-apache | grep -c Running)"
echo "   - CPU média: $(kubectl top pods -n aula-k8s | grep php-apache | awk '{sum+=$2} END {print sum/NR "m"}')"
echo "   - Memória média: $(kubectl top pods -n aula-k8s | grep php-apache | awk '{sum+=$3} END {print sum/NR "Mi"}')"

echo ""
echo "💡 Para análise detalhada, acesse o Grafana ou execute:"
echo "   kubectl get events -n aula-k8s --sort-by='.lastTimestamp'"
