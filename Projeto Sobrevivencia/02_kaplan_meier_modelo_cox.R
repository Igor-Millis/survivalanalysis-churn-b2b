# 03_analise_sobrevivencia.R

# Kaplan-Meier geral
km_fit <- survfit(Surv(tempo, morreu) ~ 1, data = base)
summary(km_fit, times = c(365, 730, 1095))
ggsurvplot(km_fit, data = base, risk.table = TRUE, 
           xlab = "Tempo (dias)", ylab = "Probabilidade de Sobrevivência")

# Comparar por canal de entrada
km_canal <- survfit(Surv(tempo, morreu) ~ canal_entrada, data = base)
ggsurvplot(km_canal, data = base, pval = TRUE)

# Comparar por nível da loja
km_nivel <- survfit(Surv(tempo, morreu) ~ nivel_loja, data = base)
ggsurvplot(km_nivel, data = base, pval = TRUE)

# 4. Modelo de Risco (Cox)
# 04_modelo_risco.R

# Tratar fatores
base$canal_entrada <- as.factor(base$canal_entrada)
base$nivel_loja <- as.factor(base$nivel_loja)
base$regiao <- as.factor(base$regiao)

# Modelo Cox
cox_model <- coxph(Surv(tempo, morreu) ~ 
                     canal_entrada + nivel_loja + regiao +
                     total_pedidos + ticket_medio + colecoes_unicas +
                     tempo_medio_pagamento + atraso_medio +
                     total_interacoes + taxa_resposta,
                   data = base)

summary(cox_model)

# Visualizar hazard ratios
ggforest(cox_model, data = base)

# Predição de risco para lojas ativas
base_ativas <- base %>% filter(!morreu)
base_ativas$risco <- predict(cox_model, newdata = base_ativas, type = "risk")

# Top 10 lojas com maior risco de churn nos próximos meses
top_risco <- base_ativas %>%
  select(id_loja, nome, risco, ultima_compra, total_pedidos) %>%
  arrange(desc(risco)) %>%
  head(10)

print(top_risco)
