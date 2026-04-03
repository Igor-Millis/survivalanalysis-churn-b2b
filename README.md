# Análise de Sobrevivência - Churn
### 📖 Introdução 
Este projeto tem como objetivo modelar o tempo até a interrupção do relacionamento comercial entre uma empresa do setor de moda (modelo B2B) e suas lojas parceiras. No contexto analisado, a empresa realiza vendas em atacado para lojas multimarcas, que revendem os produtos ao consumidor final. Observa-se, entretanto, que algumas lojas deixam de realizar novos pedidos ao longo do tempo, caracterizando um fenômeno de churn.

O problema central consiste em responder às seguintes questões:
1. Quais lojas apresentam maior risco de interromper o relacionamento comercial?
2. Quais variáveis estão associadas a um maior (ou menor) tempo de permanência?
3. É possível identificar sinais de deterioração antes da ocorrência do churn?

Para tratar esse problema, utilizei de Análise de Sobrevivência, que permite modelar o tempo até a ocorrência de um evento, considerando adequadamente a presença de censura.

### 🎯 Objetivos

Os principais objetivos do projeto são:

Modelar o tempo até o churn das lojas parceiras;
Identificar fatores associados ao risco de interrupção do relacionamento;
Construir métricas interpretáveis para apoio à tomada de decisão comercial;
Comparar abordagens estatísticas clássicas e métodos de machine learning para dados de sobrevivência.

### 🗂️ Estrutura dos Dados

O conjunto de dados estava disposto em diversas fontes, integrando informações de diferentes áreas da empresa.
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

### 🔄 Integração de Dados

#### Objetivo
Unificar quatro fontes de dados distintas (lojas, pedidos, pagamentos e interações) em uma única base para análise de sobrevivência.

#### Fontes de Dados

| Fonte | Conteúdo | Registros |
|-------|----------|-----------|
| **Lojas** | Cadastro (500 lojas) | 500 |
| **Pedidos** | Histórico de compras | 8.567 |
| **Pagamentos** | Quitação financeira | 8.567 |
| **Interações** | Comunicações marca-loja | 10.849 |

#### Principais Desafios

1. **Chaves inconsistentes** - `id_loja` em formatos diferentes (inteiro vs decimal)
2. **Datas em formatos mistos** - texto vs Date
3. **Dados faltantes** - lojas sem interações ou pagamentos
4. **Definição do evento** - o que caracteriza uma loja "morta"?

#### Soluções Adotadas

| Desafio | Solução |
|---------|---------|
| Chaves inconsistentes | Padronização para numérico inteiro |
| Datas mistas | Conversão com `as.Date()` em todas as colunas |
| Dados faltantes | Preenchido de acordo com a variável |
| Definição de "morte" | *n* dias sem compra = loja morta |

### 📅 Definição do Evento e Censura

Em um modelo B2B de lojas parceiras, não existe um "cancelamento formal". Uma loja pode simplesmente parar de comprar sem aviso, mas também pode ficar meses sem pedidos por questões sazonais ou de estoque e depois retornar normalmente.

Para definir o que caracteriza a "morte" de uma loja, foi analisada a distribuição do intervalo entre pedidos das lojas ativas. Identificou-se que 90% dos intervalos são inferiores a *n* dias.

Portanto, adotou-se o seguinte critério: Uma loja é considerada "morta" quando fica *n* dias ou mais sem realizar nenhum pedido e não retoma as compras até o final do período analisado.

### ⚙️ Engenharia de Variáveis

Transformar os dados brutos das quatro fontes (lojas, pedidos, pagamentos e interações) em um conjunto de variáveis preditoras que capturem diferentes dimensões do comportamento da loja parceira.

#### 1. Dados Cadastrais (origem: lojas)

| Variável | Descrição | Tipo |
|----------|-----------|------|
| `regiao` | Região geográfica da loja (Sul, Sudeste, Nordeste) | Categórica |
| `canal_entrada` | Como a loja foi adquirida (Prospecção, Evento, Indicação) | Categórica |
| `nivel_loja` | Classificação da loja (A, B ou C) | Categórica |

#### 2. Comportamento de Compra (origem: pedidos)

| Variável | Descrição | Cálculo |
|----------|-----------|---------|
| `total_pedidos` | Número total de pedidos realizados | Contagem por loja |
| `ticket_medio` | Valor médio gasto por pedido | Média do `valor_total` |
| `colecoes_unicas` | Quantas coleções diferentes a loja já comprou | Contagem de `colecao` distintas |
| `primeira_compra` | Data do primeiro pedido | Mínimo de `data_pedido` |
| `ultima_compra` | Data do último pedido | Máximo de `data_pedido` |

#### 3. Saúde Financeira (origem: pagamentos)

| Variável | Descrição | Cálculo |
|----------|-----------|---------|
| `tempo_medio_pagamento` | Dias médios entre pedido e quitação | Média de `dias_para_quitar` |
| `atraso_medio` | Dias médios de atraso no pagamento | Média de `atraso_somado` |

#### 4. Engajamento (origem: interações)

| Variável | Descrição | Cálculo |
|----------|-----------|---------|
| `total_interacoes` | Número total de contatos com a marca | Contagem de registros |
| `total_visitas` | Quantas visitas comerciais recebeu | Contagem onde `tipo = "Visita"` |
| `total_eventos` | Quantos eventos participou | Contagem onde `tipo = "Evento"` |
| `total_emails` | Quantos e-mails foram enviados | Contagem onde `tipo = "Email"` |
| `taxa_resposta` | Percentual de interações com resposta positiva | Média de `respondeu = "Sim"` |

#### 5. Variáveis Derivadas para Modelagem

| Variável | Descrição | Cálculo |
|----------|-----------|---------|
| `tempo` | Tempo de vida da loja (em dias) | `data_evento - data_entrada` |
| `morreu` | Indicador de evento (1 = morreu, 0 = censurada) | Baseado na regra dos *n* dias |

#### Tratamento de Dados Faltantes

| Variável | Estratégia |
|----------|-------------|
| Interações | Preenchido com 0 (loja sem interações registradas) |
| Taxa de resposta | Preenchido com 0 (loja nunca respondeu) |
| Tempo de pagamento | Preenchido com a mediana do setor (30 dias) |

Após a engenharia de variáveis, a base final continha **19 variáveis** para 500 lojas, prontas para alimentar o modelo de sobrevivência.

### 📐 Metodologia

#### Análise Exploratória

Antes da modelagem, foi realizada uma análise exploratória para compreender a distribuição das variáveis, identificar padrões iniciais e verificar a qualidade dos dados.

**Principais atividades:**
- Distribuição do tempo de vida das lojas
- Análise de sobrevivência não ajustada (Kaplan-Meier)
- Comparação entre grupos (região, canal de entrada, nível da loja)

#### Modelagem de Sobrevivência

**Modelo escolhido:** Regressão de Cox (Proportional Hazards Model)

**Justificativa:** O modelo de Cox é semiparamétrico, não exige distribuição específica do tempo de vida e permite incluir múltiplas variáveis preditoras simultaneamente, fornecendo interpretação direta via Hazard Ratios.

**Forma do modelo:**

$h(t) = h_0(t).exp(\beta_1 X_1+\beta_2 X_2 + ... + \beta_n X_n)$

Onde:
- $h(t)$ é o risco (hazard) de uma loja morrer no tempo t
- $h_0(t)$ é o risco basal (não especificado)
- $β$ são os coeficientes estimados
- $X$ são as variáveis preditoras

#### Variáveis Utilizadas no Modelo

| Grupo | Variáveis |
|-------|-----------|
| Cadastro | `canal_entrada`, `nivel_loja`, `regiao` |
| Comportamento | `total_pedidos`, `ticket_medio`, `colecoes_unicas` |
| Financeiro | `tempo_medio_pagamento`, `atraso_medio` |
| Relacionamento | `total_interacoes`, `taxa_resposta` |

#### Validação do Modelo

Para garantir a robustez dos resultados, foram aplicadas as seguintes técnicas de validação:

| Técnica | Descrição |
|---------|-----------|
| **C-index** | Avalia o poder de discriminação do modelo (capacidade de ordenar risco) |
| **Time-dependent AUC** | Mede a acurácia do modelo em diferentes horizontes de tempo |
| **Brier Score** | Avalia o erro quadrático médio das predições |
| **Calibration Plot** | Verifica se as probabilidades preditas se alinham com as observadas |
| **Validação Cruzada (k-fold)** | Avalia a estabilidade do modelo em diferentes amostras |

#### Interpretação dos Resultados

Os resultados do modelo de Cox são interpretados via **Hazard Ratio (HR)**:

- **HR > 1** → Variável aumenta o risco de morte (fator de risco)
- **HR = 1** → Variável não tem efeito no risco
- **HR < 1** → Variável reduz o risco de morte (fator protetor)

**Exemplo:** Um HR de 1,5 para `canal_entrada = Prospecção` significa que lojas adquiridas por prospecção têm 50% mais risco de morrer em comparação com a categoria de referência.

#### Ferramentas Utilizadas

| Ferramenta | Finalidade |
|------------|------------|
| **R** | Ambiente principal de análise |
| **survival** | Implementação do modelo de Cox |
| **survminer** | Visualização de curvas de sobrevivência |
| **survAUC** | Cálculo de AUC dependente do tempo |
| **pec** | Cálculo do Brier Score |
| **ggplot2** | Visualizações personalizadas |

#### Fluxo da Análise
Dados brutos (4 fontes) > Integração e engenharia de variáveis > análise exploratória > modelagem > validação > interpretação e recomendações

#### Premissas do Modelo

O modelo de Cox assume que os **Hazards são proporcionais** ao longo do tempo, ou seja, o efeito relativo de uma variável não muda com o tempo. Esta premissa foi testada e verificada para as variáveis do modelo final.

#### Limitações da Metodologia

1. **Dados de sell-out não disponíveis** – Variáveis como giro de estoque e velocidade de revenda não puderam ser incluídas
2. **Threshold de *n* dias** – A definição de morte é uma aproximação baseada em dados históricos
3. **Modelo assume proporcionalidade** – O efeito das variáveis é constante no tempo
4. **Validação externa pendente** – O modelo ainda não foi testado em uma coorte temporal futura

#### Próximos Passos Metodológicos

- [ ] Incluir dados de sell-out quando disponíveis
- [ ] Testar modelos alternativos (Random Survival Forests)
- [ ] Implementar validação em janela temporal (rolling window)
- [ ] Desenvolver dashboard de risco em Shiny
