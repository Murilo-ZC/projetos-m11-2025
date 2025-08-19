# Encontro 04 - Escalando, Testando e Monitorando Aplicações

## 1. Escalando Aplicações

Até aqui, já fizemos a escala manual de nossas aplicações. Isso foi realizado com o comando `kubectl scale`, onde definimos o número de réplicas desejadas para nossa aplicação. No entanto, essa abordagem não é a mais eficiente, pois não responde automaticamente às variações de carga.

Para resolver isso, podemos utilizar dois tipos de escalonamento automático:

1. **Horizontal Pod Autoscaler (HPA)**: Este recurso ajusta automaticamente o número de réplicas de um pod com base na carga de trabalho. Ele monitora métricas como uso de CPU ou memória e escala os pods conforme necessário.
2. **Vertical Pod Autoscaler (VPA)**: Este recurso ajusta automaticamente os recursos (CPU e memória) alocados para os pods, com base no uso real. Ele é útil quando a carga de trabalho varia significativamente ao longo do tempo.

Vamos agora:

- Configuração do HPA
- Teste de carga para demonstrar auto-scaling
- Análise das métricas



## 🚀 Preparação do Ambiente

### Pré-requisitos
- Docker instalado
- Kind instalado
- kubectl instalado
- curl ou similar para testes de carga

### Comandos de Setup
```bash
# Criar cluster Kind
./scripts/00_setup-cluster.sh

# Deploy da aplicação
kubectl apply -f yamls_exemplo/00_servico_base.yaml

# Configurar HPA
kubectl apply -f yamls_exemplo/01_hpa_base.yaml

# Instalar monitoramento - ainda não!
./scripts/01_install-monitoring.sh
```

## 📊 Aplicação de Exemplo

A aplicação `php-apache` é uma aplicação web simples que:
- Consome CPU baseado na carga
- Permite testes de escalabilidade
- Inclui health checks
- Configuração de recursos otimizada

## 🔧 Configurações de Escalabilidade

### HPA Configurado para:
- **CPU**: 50% de utilização média
- **Replicas**: Mínimo 1, máximo 10
- **Métricas**: Baseadas em recursos

### Recursos da Aplicação:
- **CPU Request**: 200m
- **CPU Limit**: 500m
- **Memory Request**: 64Mi
- **Memory Limit**: 256Mi

## 📈 Monitoramento

### Métricas Disponíveis:
- Número de pods
- Utilização de CPU e memória
- Tempo de resposta
- Taxa de requisições

### Dashboards:
- Visão geral da aplicação
- Métricas de escalabilidade
- Alertas de performance

## 🧪 Testes de Carga

### Scripts Disponíveis:
- `scripts/load-test.sh` - Teste básico de carga
- `scripts/stress-test.sh` - Teste intensivo
- `scripts/monitor-scaling.sh` - Monitoramento em tempo real

---

## 🍜 Utilizando o ambiente

Pessoal vamos agora ver algumas coisas aqui. Ao executar o 