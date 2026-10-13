MecaniQA Tech

Diagnóstico automotivo para oficinas mecânicas.

Migração de uma infraestrutura local instável, servidor físico legado, para uma fundação resiliente, conteinerizada e, futuramente, orquestrada em Kubernetes.

Sobre o projeto

A aplicação principal é escrita em Java, usa MySQL para dados transacionais e Redis para armazenamento em alta velocidade (cache/sessões).

No cenário atual, tudo roda em um único servidor físico legado, onde a API Java consome todos os recursos disponíveis e derruba o MySQL e o Redis simultaneamente. Este projeto resolve esse problema isolando cada serviço em containers Docker independentes, com redes, volumes e limites de recursos próprios.

| Papel | Nome 
| Nome do time | *São Paulo* 
| Orientador | *Lucas Almeida* 
| Integrante 1 | *Denilson Santos da Silva* 
| Integrante 2 | *Gabriel Arlisson de Souza Santos Torres* 
| Integrante 3 | *João Arthur Nascimento Mascarenhas* 
| Integrante 4 | *Tony Cleriston Oliveira dos Santos Junior* 
| Integrante 5 | *Vinicius Cerqueira Oliveira* 
| Integrante 6 | *Rodrigo Santos da Silva* 

Objetivos

- Compreender os conceitos da **Camada Virtual** e criar Dockerfiles isolados para a aplicação Java, MySQL e Redis.
- Implementar a orquestração local com **docker-compose.yml**, configurando rede interna (DNS entre containers) e persistência de dados.
- Desenhar a infraestrutura de forma declarativa com **Terraform** (Infraestrutura como Código).
- Introduzir a **Camada de Controle**: gestão de Pods, Deployments e Services com **Kubernetes (K8s)** e monitoramento com **K9s**.