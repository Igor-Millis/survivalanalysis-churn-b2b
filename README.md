# Análise de Sobrevivência de Lojas Parceiras (B2B)
### Introdução
Este projeto tem como objetivo modelar o tempo até a interrupção do relacionamento comercial entre uma empresa do setor de vestuário (modelo B2B) e suas lojas parceiras. No contexto analisado, a empresa realiza vendas em atacado para lojas multimarcas, que revendem os produtos ao consumidor final. Observa-se, entretanto, que algumas lojas deixam de realizar novos pedidos ao longo do tempo, caracterizando um fenômeno de churn.

O problema central consiste em responder às seguintes questões:
1. Quais lojas apresentam maior risco de interromper o relacionamento comercial?
2. Quais variáveis estão associadas a um maior (ou menor) tempo de permanência?
3. É possível identificar sinais de deterioração antes da ocorrência do churn?

Para tratar esse problema, utiliza-se o arcabouço de Análise de Sobrevivência, que permite modelar o tempo até a ocorrência de um evento, considerando adequadamente a presença de censura.

### Objetivos

Os principais objetivos do projeto são:

Modelar o tempo até o churn das lojas parceiras;
Identificar fatores associados ao risco de interrupção do relacionamento;
Construir métricas interpretáveis para apoio à tomada de decisão comercial;
Comparar abordagens estatísticas clássicas e métodos de machine learning para dados de sobrevivência.

### Estrutura dos Dados

O conjunto de dados é sintético, porém foi construído para reproduzir a complexidade de um ambiente real, integrando informações de diferentes áreas da empresa.
Os dados estão organizados em quatro tabelas principais:

#### Tabela lojas
Contém informações cadastrais das lojas parceiras.\
Granularidade: uma linha por loja.

Variáveis:
*id_loja*: identificador único;\
*cidade*, *regiao*: localização;\
*data_entrada*: início da parceria;\
*canal_entrada*: origem da loja;\
*nivel_loja*: categorização qualitativa (A, B, C)

#### Tabela pedidos

Registra o histórico de compras realizadas pelas lojas.\
Granularidade: uma linha por pedido.

Variáveis:\
*id_pedido*: identificador do pedido;\
*id_loja*: referência à loja;\
*data_pedido*: data da compra;\
*valor_total*: valor do pedido;\
*colecao*: coleção associada.

Essa é a tabela central do projeto, pois permite reconstruir o comportamento temporal das lojas.

#### Tabela pagamentos

Contém informações sobre o comportamento financeiro associado aos pedidos.\
Granularidade: uma linha por pedido.

Variáveis:\
*id_pedido*: referência ao pedido
*dias_para_quitar*: tempo até o pagamento
*atraso_somado*: dias de atraso acumulado

Essas variáveis são utilizadas como proxies de risco financeiro.

#### Tabela interacoes

Registra as interações entre a empresa e as lojas.\
Granularidade: uma linha por interação.

Variáveis:\
*id_loja*: referência à loja;\
*data*: data da interação;\
*tipo*: tipo de contato (email, visita, evento);\
*respondeu*: indicador de engajamento.

### Integração dos Dados

### Definição do Evento e Censura

### Engenharia de Variáveis

### Metodologia

#### Análise Não Paramétrica

#### Modelo de Cox (Proportional Hazards)

#### Métodos de Machine Learning

### Métricas de Avaliação
