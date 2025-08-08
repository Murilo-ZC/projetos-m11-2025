# Encontro 01 - Otimizando Builds de Imagens

Nosso objetivo neste encontro é discultir como podemos trabalhar com as builds das nossas imagens, com o objetivo de tornar elas:
- Mais enxutas;
- Mais seguras.

No contexto de uma aplicação Backend - como construir uma imagem docker?

- Uma imagem base;
- Da aplicação com nosso código.

Vamos iniciar pelo Dockerfile.

Criando uma API de PingPong.

Para buildar a imagem e rodar:

```sh
docker build -t proj01 .
docker run -d -p 8000:8000 proj01
```

