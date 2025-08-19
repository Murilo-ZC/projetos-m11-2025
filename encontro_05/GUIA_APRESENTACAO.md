# 🎓 Guia de Apresentação - Escalabilidade no Kubernetes

## 📋 Visão Geral da Aula

**Duração:** 120 minutos  
**Objetivo:** Demonstrar conceitos de escalabilidade, configuração e monitoramento no Kubernetes  
**Público:** Estudantes/Profissionais com conhecimento básico de Kubernetes  
**Ferramentas:** Kind, kubectl, Helm, Prometheus, Grafana  

---

## 🎯 Estrutura da Aula

### **Minuto 0-20: Introdução e Conceitos**

#### Slides de Abertura
- **Título:** "Escalabilidade no Kubernetes: Do Manual ao Automático"
- **Subtítulo:** "Como configurar, testar e monitorar aplicações escaláveis"

#### Conceitos Fundamentais
1. **O que é Escalabilidade?**
   - Capacidade de um sistema de lidar com aumento de carga
   - Diferença entre escala horizontal e vertical
   - Por que é importante no mundo atual

2. **Escalabilidade no Kubernetes**
   - Arquitetura distribuída naturalmente escalável
   - Recursos nativos para escalabilidade
   - Vantagens sobre soluções tradicionais

3. **Tipos de Escalabilidade**
   - **Manual:** `kubectl scale`
   - **Automática:** HPA (Horizontal Pod Autoscaler)
   - **Inteligente:** VPA (Vertical Pod Autoscaler)

#### Demonstração Visual
- Mostrar cluster atual (se existir)
- Explicar a diferença entre nós e pods
- Conceito de réplicas e distribuição de carga

---

### **Minuto 20-35: Setup do Ambiente**

#### Preparação do Cluster
1. **Verificação de Pré-requisitos**
   ```bash
   # Verificar ferramentas instaladas
   kind --version
   kubectl version
   helm version
   ```

2. **Criação do Cluster**
   ```bash
   ./scripts/setup-cluster.sh
   ```
   
   **Explicar durante a execução:**
   - Por que 3 nós (1 control-plane + 2 workers)
   - Configurações de porta para acesso externo
   - Tempo de inicialização e verificação

3. **Verificação do Cluster**
   ```bash
   kubectl get nodes
   kubectl cluster-info
   ```

#### **Pontos de Atenção:**
- Explicar cada comando executado
- Mostrar a saída e interpretar os resultados
- Explicar o que cada componente representa

---

### **Minuto 35-55: Escala Manual**

#### Deploy da Aplicação
1. **Aplicar Configuração Base**
   ```bash
   kubectl apply -f yamls_exemplo/00_servico_base.yaml
   ```

2. **Explicar o YAML**
   - **Namespace:** Organização lógica
   - **Deployment:** Gerenciamento de réplicas
   - **Service:** Descoberta e balanceamento de carga
   - **Resources:** Limites e requisições de CPU/memória

3. **Verificar Status**
   ```bash
   kubectl get pods -n aula-k8s
   kubectl describe deployment php-apache -n aula-k8s
   ```

#### Demonstração de Escala Manual
1. **Escalar para 3 Réplicas**
   ```bash
   kubectl scale deployment php-apache -n aula-k8s --replicas=3
   ```

2. **Observar Comportamento**
   - Como os pods são criados
   - Distribuição entre nós
   - Tempo de inicialização

3. **Voltar para 1 Réplica**
   ```bash
   kubectl scale deployment php-apache -n aula-k8s --replicas=1
   ```

#### **Conceitos a Enfatizar:**
- Controle total sobre o número de réplicas
- Necessidade de monitoramento manual
- Limitações da abordagem manual
- Transição para automação

---

### **Minuto 55-85: HPA em Ação**

#### Configuração do HPA
1. **Aplicar Configuração do HPA**
   ```bash
   kubectl apply -f yamls_exemplo/01_hpa_base.yaml
   ```

2. **Explicar Configuração**
   - **Target:** Deployment a ser escalado
   - **Métricas:** CPU como gatilho (50%)
   - **Limites:** Mínimo 1, máximo 10 réplicas
   - **Comportamento:** Políticas de escala

3. **Verificar Status**
   ```bash
   kubectl get hpa -n aula-k8s
   kubectl describe hpa php-apache -n aula-k8s
   ```

#### Teste de Escalabilidade
1. **Executar Teste de Carga**
   ```bash
   ./scripts/load-test.sh
   ```

2. **Observar em Tempo Real**
   - Abertura de novo terminal para monitoramento
   ```bash
   ./scripts/monitor-scaling.sh
   ```

3. **Análise dos Resultados**
   - Como o HPA detecta aumento de CPU
   - Tempo de resposta para criar novos pods
   - Distribuição da carga entre réplicas

#### **Conceitos Avançados:**
- **Stabilization Window:** Evita oscilação
- **Cooldown:** Período entre escalas
- **Métricas Customizadas:** Além de CPU/memória
- **Políticas de Escala:** Comportamentos personalizados

---

### **Minuto 85-110: Monitoramento e Observabilidade**

#### Instalação do Stack de Monitoramento
1. **Prometheus + Grafana**
   ```bash
   ./scripts/install-monitoring.sh
   ```

2. **Explicar Componentes**
   - **Prometheus:** Coleta e armazenamento de métricas
   - **Grafana:** Visualização e dashboards
   - **ServiceMonitor:** Descoberta automática de serviços

3. **Configuração de Dashboards**
   - Dashboard de HPA
   - Métricas de aplicação
   - Alertas de performance

#### Demonstração dos Dashboards
1. **Acessar Grafana**
   - Usuário: admin
   - Senha: mostrada no script
   - Porta: NodePort atribuída

2. **Navegar pelos Dashboards**
   - **Kubernetes Cluster:** Visão geral
   - **HPA Metrics:** Escalabilidade em tempo real
   - **Application Performance:** Métricas da aplicação

3. **Interpretar Métricas**
   - CPU e memória por pod
   - Taxa de requisições
   - Tempo de resposta
   - Número de réplicas ao longo do tempo

#### **Conceitos de Observabilidade:**
- **Métricas:** Dados quantitativos
- **Logs:** Histórico de eventos
- **Traces:** Rastreamento de requisições
- **Alertas:** Notificações automáticas

---

### **Minuto 110-120: Encerramento e Próximos Passos**

#### Resumo dos Conceitos
1. **Escalabilidade Manual vs Automática**
   - Controle vs Conveniência
   - Casos de uso para cada abordagem

2. **HPA como Solução**
   - Vantagens da automação
   - Configurações recomendadas
   - Melhores práticas

3. **Monitoramento Contínuo**
   - Importância da observabilidade
   - Ferramentas disponíveis
   - Integração com CI/CD

#### Cenários Práticos
1. **Quando Usar HPA?**
   - Aplicações com carga variável
   - Ambientes de produção
   - Otimização de custos

2. **Configurações Avançadas**
   - Múltiplas métricas
   - Comportamentos personalizados
   - Integração com métricas customizadas

3. **Troubleshooting Comum**
   - HPA não escala
   - Métricas não disponíveis
   - Configurações incorretas

#### **Recursos Adicionais**
- Documentação oficial do Kubernetes
- Comunidade e fóruns
- Cursos e certificações
- Projetos open-source relacionados

---

## 🛠️ Preparação Técnica

### **Antes da Aula:**
1. **Verificar Ferramentas**
   - Docker rodando
   - Kind instalado
   - kubectl configurado
   - Helm disponível

2. **Testar Scripts**
   - Executar setup-cluster.sh
   - Verificar conectividade
   - Testar comandos básicos

3. **Preparar Slides**
   - Conceitos teóricos
   - Screenshots de dashboards
   - Diagramas de arquitetura

### **Durante a Aula:**
1. **Terminal Principal**
   - Execução dos comandos
   - Explicação dos resultados
   - Demonstração visual

2. **Terminal Secundário**
   - Monitoramento em tempo real
   - Verificação de status
   - Troubleshooting se necessário

3. **Navegador**
   - Dashboards do Grafana
   - Documentação online
   - Exemplos práticos

---

## 🎭 Dicas de Apresentação

### **Engajamento da Audiência:**
1. **Perguntas Interativas**
   - "O que acontece se aumentarmos a carga?"
   - "Por que o HPA escolheu esse número de réplicas?"
   - "Como podemos otimizar essa configuração?"

2. **Demonstrações Visuais**
   - Mostrar dashboards em tempo real
   - Comparar antes/depois das operações
   - Usar gráficos e diagramas

3. **Casos Reais**
   - Exemplos de empresas que usam HPA
   - Problemas comuns e soluções
   - ROI da automação

### **Gerenciamento de Tempo:**
1. **Cronograma Flexível**
   - Ajustar tempo baseado no interesse
   - Pular seções se necessário
   - Manter tempo para perguntas

2. **Pontos de Pausa**
   - Após cada etapa principal
   - Para perguntas da audiência
   - Para demonstrações interativas

3. **Material de Apoio**
   - Scripts disponíveis para download
   - Documentação de referência
   - Contatos para dúvidas

---

## 🚨 Solução de Problemas

### **Problemas Comuns:**

#### **Cluster não inicia:**
```bash
# Verificar Docker
docker info

# Limpar clusters antigos
kind delete cluster --name aula-escalabilidade

# Verificar recursos disponíveis
docker system df
```

#### **HPA não escala:**
```bash
# Verificar métricas
kubectl top pods -n aula-k8s

# Verificar configuração
kubectl describe hpa php-apache -n aula-k8s

# Verificar eventos
kubectl get events -n aula-k8s
```

#### **Monitoramento não funciona:**
```bash
# Verificar pods
kubectl get pods -n monitoring

# Verificar serviços
kubectl get svc -n monitoring

# Verificar logs
kubectl logs -n monitoring deployment/prometheus-operator
```

### **Comandos de Emergência:**
```bash
# Reset completo
kind delete cluster --name aula-escalabilidade
./scripts/setup-cluster.sh

# Verificar status geral
kubectl get all --all-namespaces
kubectl get events --all-namespaces
```

---

## 📚 Material de Referência

### **Documentação Oficial:**
- [Kubernetes HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Prometheus Operator](https://github.com/prometheus-operator/kube-prometheus)

### **Artigos e Tutoriais:**
- "HPA Best Practices"
- "Monitoring Kubernetes at Scale"
- "Autoscaling Strategies"

### **Ferramentas Relacionadas:**
- KEDA (Event-driven autoscaling)
- VPA (Vertical Pod Autoscaler)
- Cluster Autoscaler

---

## 🎯 Objetivos de Aprendizado

### **Ao Final da Aula, os Alunos Devem:**
1. **Entender** os conceitos de escalabilidade no Kubernetes
2. **Configurar** HPA para aplicações simples
3. **Monitorar** o comportamento de escalabilidade
4. **Aplicar** as melhores práticas em seus projetos
5. **Troubleshoot** problemas comuns de HPA

### **Competências Desenvolvidas:**
- **Técnicas:** Configuração de HPA, monitoramento
- **Conceituais:** Arquitetura de escalabilidade
- **Práticas:** Resolução de problemas reais
- **Analíticas:** Interpretação de métricas

---

## 🚀 Próximos Passos

### **Para os Alunos:**
1. **Experimentar** com diferentes configurações de HPA
2. **Implementar** em seus próprios projetos
3. **Explorar** métricas customizadas
4. **Contribuir** para a comunidade

### **Para o Instrutor:**
1. **Coletar** feedback dos alunos
2. **Atualizar** material baseado em perguntas
3. **Preparar** próximas sessões
4. **Compartilhar** experiências com colegas

---

**🎉 Boa sorte com sua apresentação!**  
**Lembre-se: A prática é a melhor forma de aprender Kubernetes!**
