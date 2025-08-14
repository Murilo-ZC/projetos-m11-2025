# Encontro 03 - Avançando com o uso do Kubernetes

No encontro de hoje vamos explorar mais como utilizar o Kubernetes. Até aqui, utilizamos o Kubernetes utilizando o `kind` para criar um cluster local e o `kubectl` para interagir com ele diretamente. Agora vamos trabalhar com scripts e ferramentas que permitem automatizar e facilitar o uso destas interações.

## Namespaces

O formato mais comum de interagir com o Kubernetes é através de arquivos YAML. Esses arquivos descrevem os recursos que queremos criar ou modificar no cluster. Vamos ver como criar um arquivo YAML básico.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: aula-k8s
```

O que temos aqui é um arquivo YAML que define um Namespace chamado `aula-k8s`. Para aplicar esse arquivo no cluster, usamos o comando:

```bash
kubectl apply -f nome_do_arquivo.yaml
```

> `Mas Murilo, eu rodei esse comando e nada aconteceu!`

Vocês lembram que o `kind` cria um cluster local, certo? Então, para ver o que aconteceu, precisamos verificar os recursos criados. Podemos fazer isso com o comando:

```bash
kubectl get namespaces
```

> `Mas Murilo só aparareceu um monte de erros!`

Vocês criaram o cluster com o `kind`? Lembrando que o comando para criar o cluster é:

```bash
kind create cluster --name aula-k8s
```

Beleza agora deve estar tudo certo! Vamos continuar. Para isso, vamos analisar o que é um Namespace. No Kubernetes, um namespace é como um “compartimento lógico” dentro do cluster que serve para organizar e isolar recursos. Ele permite dividir um mesmo cluster em ambientes ou áreas separadas, cada uma com seus próprios objetos (Pods, Services, ConfigMaps etc.), evitando conflitos de nomes e facilitando a gestão.

Principais funções:
- Organização – separa recursos por projeto, time ou ambiente (ex.: dev, homolog, prod).
- Isolamento lógico – um recurso chamado web pode existir no namespace marketing e no namespace vendas sem conflito.
- Controle de acesso – integra com RBAC para aplicar permissões específicas por namespace.
- Gerenciamento de recursos – permite aplicar ResourceQuota e LimitRange por namespace, controlando consumo de CPU, memória, número de Pods, etc.

Legal, conseguimos ver que esses caras são úteis! Vamos analisar um detalhe de um comando que vai ser útil para nós daqui para frente. O comando `kubectl get` pode receber o parâmetro `-n` ou `--namespace` para especificar o namespace que queremos consultar. Por exemplo:

```bash
kubectl get pods -n aula-k8s
```

Estamos pedindo os recursos do tipo Pod dentro do namespace `aula-k8s`. Se não especificarmos o namespace, o Kubernetes assume o namespace padrão (`default`). Vale testar nos demais namespaces que já estão criados com o `kind` para verificar o que acontece quando este comando é utilizado com e sem o parâmetro `-n`.

> `Pô Murilo, mas e esse metadata?`

Boa pergunta! O `metadata` é uma seção do YAML que contém informações adicionais sobre o recurso, como nome, rótulos (labels) e anotações (annotations). Essas informações ajudam a identificar e organizar os recursos dentro do Kubernetes. Vamos explorar mais sobre ele logo menos!

## Deploy mais serviço

Agora que já sabemos como criar um namespace, vamos criar um serviço dentro dele. Vamos criar um arquivo YAML para um Pod simples que roda um servidor web Nginx.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: aula-k8s
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: aula-k8s
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: ClusterIP
```

Este arquivo cria dois recursos para nós no nosso cluster:

- Um **Deployment** chamado `web` que roda dois Pods com o Nginx. Repare que este Deployment está dentro do namespace `aula-k8s`. Além disso, ele possui um seletor (`selector`) que identifica os Pods com o rótulo `app: web`. Isso é importante para que o Kubernetes saiba quais Pods gerenciar. Além disso, também é especificado o número de réplicas e qual imagem do Nginx deve ser utilizada. Por fim, o `containerPort` indica a porta que o Nginx estará escutando dentro do Pod.
- Um **Service** chamado `web-svc` que expõe os Pods do Deployment. O Service também está no namespace `aula-k8s` e utiliza o seletor `app: web` para direcionar o tráfego para os Pods corretos. Ele escuta na porta 80 e encaminha o tráfego para a mesma porta nos Pods.

Vamos salvar esse arquivo como `01_deploy_servico.yaml` e aplicar no cluster:

```bash
kubectl apply -f 01_deploy_servico.yaml
```

Para verificar se tudo foi criado corretamente, podemos usar os seguintes comandos:

```bash
kubectl get deployments -n aula-k8s
kubectl get pods -n aula-k8s
kubectl get services -n aula-k8s
```

> `Mas Murilo, quando eu utilizei esse comando de serviços, apareceu um IP e eu não consegui acessar ele pelo meu computador. O que aconteceu?`

Isso acontece porque o tipo de Service que criamos é do tipo `ClusterIP`, que só é acessível dentro do cluster Kubernetes. Para acessar esse serviço de fora do cluster, precisamos criar um Service do tipo `NodePort`, um. `LoadBalancer` ou ainda precisamos pedir ao `kubectl` para redirecionar as requisições para o cluster. Vamos fazer isso agora!

```bash
kubectl port-forward service/web-svc 8080:80 -n aula-k8
```

Agora, se você abrir o navegador e acessar `http://localhost:8080`, deve conseguir ver a página padrão do Nginx!

Vamos editar nosso sistema para permitir que esse serviço possa ser acessado de fora do cluster.

> `Mas calma Murilo, eu preciso matar o serviço antigo para criar o novo?`

Não necessariamente, podemos editar o YAML e apenas atualizar o serviço, ou ainda criar outro YAML apontando para o mesmo Deployment. Vamos fazer isso criando um novo arquivo chamado `02_deploy_servico_nodeport.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: aula-k8s
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - name: http
      port: 80        # porta do Service dentro do cluster
      targetPort: 80  # porta do container
      nodePort: 30080 # porta publicada no nó (externa)
```
Agora, vamos aplicar esse novo arquivo:

```bash
kubectl apply -f 02_deploy_servico_nodeport.yaml
```

Aqui pessoal podemos ter um problema referente ao Docker Desktop. O Docker Desktop não expõe as portas do NodePort diretamente, então precisamos usar o `kubectl port-forward` novamente para acessar o serviço. Uma alternativa é utilizar o `extraPortMappings` no `kind` para mapear a porta e permitir o acesso direto. Vamos aproveitar e fazer isso utilizando um arquivo `kind-config.yaml`, assim podemos criar nosso cluster já com um arquivo de configuração:

```yaml
# kind-cluster.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
```

Vamos destruir o cluster atual e recriar ele com essa nova configuração. Primeiro, para destruir o cluster:

```bash
kind delete cluster --name aula-k8s
```

Agora, vamos criar o cluster utilizando o arquivo de configuração:

```bash
kind create cluster --config kind-cluster.yaml
```

Um detalhe importante mas que vale a pena chamar a atenção, quando nós destruímos o cluster, todos os recursos dentro dele também foram destruídos. Então, precisamos reaplicar os arquivos YAML que criamos anteriormente para restaurar nosso ambiente.

```bash
kubectl apply -f 00_criando_namespace.yaml
kubectl apply -f 01_deploy_servico.yaml
kubectl apply -f 02_deploy_servico_nodeport.yaml
```

E agora nosso serviço deve estar acessível na porta 30080 do seu computador! Basta acessar `http://localhost:30080` no navegador.

