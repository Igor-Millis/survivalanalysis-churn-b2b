# 02_feature_engineering.R

# 2.1. Métricas de compra por loja
compra_resumo <- pedidos %>%
  group_by(id_loja) %>%
  summarise(
    primeira_compra = min(data_pedido),
    ultima_compra = max(data_pedido),
    total_pedidos = n(),
    ticket_medio = mean(valor_total, na.rm = TRUE),
    valor_total_vendido = sum(valor_total, na.rm = TRUE),
    colecoes_unicas = n_distinct(colecao),
    .groups = "drop"
  )

# 2.2. Tempo médio de pagamento
pagamento_resumo <- pagamentos %>%
  left_join(pedidos, by = "id_pedido") %>%
  group_by(id_loja) %>%
  summarise(
    tempo_medio_pagamento = mean(dias_para_quitar, na.rm = TRUE),
    atraso_medio = mean(atraso_somado, na.rm = TRUE),
    .groups = "drop"
  )

# 2.3. Interações
interacao_resumo <- interacoes %>%
  group_by(id_loja) %>%
  summarise(
    total_interacoes = n(),
    total_visitas = sum(tipo == "Visita", na.rm = TRUE),
    total_eventos = sum(tipo == "Evento", na.rm = TRUE),
    total_emails = sum(tipo == "Email", na.rm = TRUE),
    taxa_resposta = mean(respondeu == "Sim", na.rm = TRUE),
    .groups = "drop"
  )

# 2.4. Data de corte: última data do dataset (último pedido ou hoje)
data_corte <- max(pedidos$data_pedido, na.rm = TRUE)

# 2.5. Definir evento: loja morreu se ficou > 180 dias sem comprar
# e não comprou novamente até a data de corte
dias_sem_comprar <- 180

evento_por_loja <- pedidos %>%
  group_by(id_loja) %>%
  summarise(
    ultima_compra = max(data_pedido),
    .groups = "drop"
  ) %>%
  mutate(
    morreu = (data_corte - ultima_compra) > dias_sem_comprar,
    data_morte = ifelse(morreu, ultima_compra + dias_sem_comprar, as.Date(NA))
  )

# 2.6. Juntar tudo (VERSÃO CORRIGIDA)

# Garantir que as datas estão em formato Date
lojas$data_entrada <- as.Date(lojas$data_entrada)

# Garantir que data_corte é Date
data_corte <- as.Date(max(pedidos$data_pedido, na.rm = TRUE))

# Garantir que as datas no evento_por_loja são Date
evento_por_loja <- evento_por_loja %>%
  mutate(
    ultima_compra = as.Date(ultima_compra),
    data_morte = ifelse(morreu, as.Date(ultima_compra + dias_sem_comprar), as.Date(NA))
  )

# SOLUÇÃO DEFINITIVA - Converter TUDO explicitamente

# 1. Garantir que as colunas originais são Date
lojas$data_entrada <- as.Date(lojas$data_entrada)

# 2. Recriar evento_por_loja com datas garantidas
evento_por_loja <- pedidos %>%
  group_by(id_loja) %>%
  summarise(
    ultima_compra = max(data_pedido, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    ultima_compra = as.Date(ultima_compra),
    morreu = (data_corte - ultima_compra) > dias_sem_comprar,
    data_morte = as.Date(ifelse(morreu, ultima_compra + dias_sem_comprar, NA), origin = "1970-01-01")
  )

# Verificar os nomes das colunas em base
names(base)

# Verificar os nomes em evento_por_loja
names(evento_por_loja)

# SOLUÇÃO: Recriar o join incluindo ultima_compra
base <- lojas %>%
  left_join(compra_resumo, by = "id_loja") %>%
  left_join(pagamento_resumo, by = "id_loja") %>%
  left_join(interacao_resumo, by = "id_loja") %>%
  left_join(evento_por_loja, by = "id_loja")

# Verificar se ultima_compra está agora
names(base)

# Se ainda não estiver, recriar evento_por_loja com todas as colunas necessárias
evento_por_loja <- pedidos %>%
  group_by(id_loja) %>%
  summarise(
    ultima_compra = max(data_pedido, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    ultima_compra = as.Date(ultima_compra),
    morreu = (data_corte - ultima_compra) > dias_sem_comprar,
    data_morte = as.Date(ifelse(morreu, ultima_compra + dias_sem_comprar, NA), origin = "1970-01-01")
  )

# SOLUÇÃO: Usar a coluna correta (ultima_compra.y que vem do evento_por_loja)

# Garantir data_corte existe
data_corte <- max(pedidos$data_pedido, na.rm = TRUE)

# Converter datas corretamente
base$data_entrada <- as.Date(base$data_entrada)
base$ultima_compra <- as.Date(base$ultima_compra.y)  # usar a versão .y
base$data_morte <- as.Date(base$data_morte)

# Calcular tempo
base <- base %>%
  mutate(
    tempo = case_when(
      morreu == TRUE ~ as.numeric(data_morte - data_entrada),
      morreu == FALSE ~ as.numeric(data_corte - data_entrada),
      TRUE ~ NA_real_
    ),
    tempo = ifelse(tempo < 1, 1, tempo)
  ) %>%
  filter(!is.na(tempo))

# Verificar resultado
head(base[, c("id_loja", "data_entrada", "ultima_compra", "data_morte", "morreu", "tempo")])
summary(base$tempo)
table(base$morreu)

# Remover colunas duplicadas (opcional)
base <- base %>%
  select(-ultima_compra.x, -ultima_compra.y)

