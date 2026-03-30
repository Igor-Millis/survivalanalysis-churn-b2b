# 01_carregar_dados.R
library(readxl)
library(dplyr)
library(lubridate)
library(survival)
library(survminer)
library(ggplot2)
library(readxl)

# Converter datas
lojas$data_entrada <- as.Date(lojas$data_entrada)
pedidos$data_pedido <- as.Date(pedidos$data_pedido)
interacoes$data <- as.Date(interacoes$data)

# Ver estrutura
glimpse(lojas)
glimpse(pedidos)
glimpse(pagamentos)
glimpse(interacoes)