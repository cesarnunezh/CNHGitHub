library(tidyverse)
library(openxlsx)

# Importación y limpieza de base de datos ----

dir <- 'C:/Users/User/OneDrive - Universidad del Pacífico/2. La Casa de Sammy/1. Finanzas/2. Ventas'
setwd(dir)

df <- read.xlsx('ReporteVentas_2024-01-01_2024-07-05.xlsx', startRow = 9) 

names(df) <- c("idVenta", "nDocumento", "fecha", "nombreCliente" , "dirCliente", "idCliente", "emailCliente",
               "moneda", "tipoCambio", "igv", "montoTotal", "descTotal", "estado", "vendedor" , "observaciones",
               "notas", "ordenCompra", "codItem", "descripcion", "catItem", "tipoImpuesto", "valorUnitarioItem", "precioUnitarioItem",
               "cantItem", "descItem", "totalItem", "aliasItem")

df <- df %>% 
  subset(select = -c(emailCliente, dirCliente, moneda, tipoCambio, vendedor,observaciones,notas,ordenCompra, aliasItem)) %>% 
  filter(estado != "Anulado") 

replace_special_chars <- function(text) {
  text <- gsub("&#243;", "ó", text)
  text <- gsub("&#241;", "ñ", text)
  text <- gsub("&#193;", "Á", text)
  text <- gsub("&#205;", "Í", text)
  text <- gsub("&#209;", "Ñ", text)
  text <- gsub("&#250;", "ú", text)
  text <- gsub("&#233;", "é", text)
  text <- gsub("&#237;", "í", text)
  
  return(text)
}

# Aplicar la función a todas las columnas del data frame usando un bucle
for (col in names(df)) {
  df[[col]] <- replace_special_chars(df[[col]])
}

df <- df %>% 
  mutate(montoTotal = as.numeric(montoTotal),
         descTotal = as.numeric(descTotal),
         valorUnitarioItem = as.numeric(valorUnitarioItem),
         precioUnitarioItem = as.numeric(precioUnitarioItem),
         descItem = as.numeric(descItem),
         totalItem = as.numeric(totalItem),
         cantItem = as.numeric(cantItem))

df3 <- df %>% 
  filter(str_detect(descripcion, "y corte|\\+ cort|\\+ reto|\\y retoque|\\y recort"))

df3 <- df3 %>% 
  mutate(precioUnitarioItem = case_when(str_detect(descripcion, "cort") ~ precioUnitarioItem - 25,
                                        str_detect(descripcion, "retoque") | str_detect(descripcion, "recort") ~ precioUnitarioItem - 15,
                                        TRUE ~ precioUnitarioItem),
         totalItem = case_when(str_detect(descripcion, "cort") ~ totalItem - 25*cantItem,
                               str_detect(descripcion, "retoque") | str_detect(descripcion, "recort") ~ totalItem - 15*cantItem,
                               TRUE ~ totalItem),
         valorUnitarioItem = case_when(str_detect(descripcion, "cort") ~ valorUnitarioItem - 25*cantItem/1.18,
                                       str_detect(descripcion, "retoque") | str_detect(descripcion, "recort") ~ valorUnitarioItem - 15*cantItem/1.18,
                                       TRUE ~ valorUnitarioItem)) %>%
  mutate(descripcion = case_when(str_detect(descripcion, "Baño premiu") ~ "Baño premium",
                                 str_detect(descripcion, "Baño diaman") ~ "Baño diamante",
                                 str_detect(descripcion, "Baño med") ~ "Baño medicado",
                                 str_detect(descripcion, "Baño y") ~ "Baño premium")) %>% 
  rbind(df3) %>% 
  mutate(descripcion = case_when(str_detect(descripcion, "cort") ~ "Corte",
                                 str_detect(descripcion, "retoque") | str_detect(descripcion, "recort") ~ "Retoque",
                                 TRUE ~ descripcion),
         precioUnitarioItem = case_when(descripcion == "Corte" ~ 25,
                                        descripcion == "Retoque" ~ 15,
                                        TRUE ~ precioUnitarioItem),
         totalItem = case_when(descripcion == "Corte" ~ 25*cantItem,
                               descripcion == "Retoque" ~ 15*cantItem,
                               TRUE ~ totalItem),
         valorUnitarioItem = case_when(descripcion == "Corte" ~ 25*cantItem/1.18,
                                       descripcion == "Retoque" ~ 15*cantItem/1.18,
                                       TRUE ~ valorUnitarioItem))


df <- df %>% 
  filter(!str_detect(descripcion, "y corte|\\+ cort|\\+ reto|\\y retoque|\\y recort")) %>% 
  rbind(df3)


df <- df %>% 
  mutate(descripcion = case_when(descripcion == "Limpieza dental" ~ "Lavado de dientes",
                                 descripcion == "Baño" ~ "Baño premium",
                                 descripcion == "Stripping" | descripcion == "stripping" | descripcion == "Carding" ~ "Deslanado",
                                 TRUE ~ descripcion),
         codItem = case_when(str_detect(descripcion, "elivery") | str_detect(descripcion, "traslado") ~ "DELIVERY",
                             str_detect(descripcion, "premiu") & str_detect(descripcion, "año") ~ "SPA-001",
                             str_detect(descripcion, "diamante") & str_detect(descripcion, "año") ~ "SPA-002",
                             str_detect(descripcion, "medicado") & str_detect(descripcion, "año") ~ "SPA-003",
                             str_detect(descripcion, "orte") & str_detect(descripcion, "uña") ~ "SPA-008",
                             str_detect(descripcion, "etoque")  ~ "SPA-006",
                             str_detect(descripcion, "desmotado") | str_detect(descripcion, "Desmotado") ~ "SPA-010",
                             str_detect(descripcion, "deslanado") | str_detect(descripcion, "Deslanado") ~ "SPA-009",
                             descripcion == "Corte" ~ "SPA-005",
                             str_detect(descripcion, "higiénico") & str_detect(descripcion, "orte") ~ "SPA-004",
                             str_detect(descripcion, "Depilación de oídos") ~ "SPA-011",
                             descripcion == "Lavado de dientes" | descripcion == "Cepillado de dientes" ~ "SPA-007",
                             TRUE ~ codItem)) %>% 
  mutate(catItem = case_when(str_detect(codItem, "DELIVERY") ~ "Delivery",
                             str_detect(codItem, "SPA") ~ "Pet Spa",
                             str_detect(descripcion, "parasit") ~ "Medicamentos",
                             str_detect(descripcion, "Canbo Dog") ~ "Alimentos - Seco",
                             str_detect(descripcion, "Pet Care") ~ "Alimentos - Snacks",
                             str_detect(descripcion, "Canbo Cat") ~ "Gatos - Alimentos",
                             str_detect(descripcion, "Canbo Cat") ~ "Gatos - Alimentos",
                             str_detect(descripcion, "Polo") ~ "Ropa - Verano",
                             str_detect(descripcion, "Ropa de perro - C. Salmon") ~ "Ropa - Invierno",
                             str_detect(descripcion, "elota") ~ "Peluches Y Juguetes juguetes de goma",
                             str_detect(descripcion, "mordedor") ~ "Peluches Y Juguetes interactivos y cognitivos",
                             str_detect(descripcion, "ujetador") ~ "Accesorios - Collares",
                             TRUE ~ catItem))
rm(df3)

## ARREGLAR LO DEL DESCUENTO TOTAL
df2 <- df %>% 
  filter(descTotal >0) %>% 
  arrange(idVenta, nDocumento, fecha) %>% 
  mutate(descItem = case_when(str_detect(descripcion,"Baño") & (descTotal <= 5 & descTotal > 1) ~ descTotal,
                              descTotal == 25 & str_detect(descripcion,"Corte") ~ descTotal,
                              descTotal == 45 & (str_detect(descripcion,"Desmotado") | str_detect(descripcion,"Depilación de oídos")) ~ precioUnitarioItem,
                              descTotal == 30 | descTotal == 20 ~ descTotal,
                              descTotal == 24 & str_detect(descripcion,"Baño") ~ descTotal/3,
                              (descTotal >=6 & descTotal <= 13) & str_detect(descripcion,"Baño") ~ descTotal/2,
                              descTotal == 15 & str_detect(descripcion,"Delivery") ~ descTotal,
                              descTotal == 0.9 ~ descTotal,
                              TRUE ~ descItem),
         descTotal = case_when((descTotal <= 5 & descTotal > 1) ~ 0,
                              descTotal == 25 ~ 0,
                              descTotal == 45 ~ 0,
                              descTotal == 30 | descTotal == 20 ~ 0,
                              descTotal == 24 ~ 0,
                              (descTotal >=6 & descTotal <= 13) ~ 0,
                              descTotal == 15 ~ 0,
                              descTotal == 0.9 ~ 0,
                              TRUE ~ descTotal)) %>% 
  mutate(descItem = case_when(descTotal != 0 & descItem != 0 & descItem > 8 ~ descItem + descTotal,
                              TRUE ~ descItem),
         descTotal = case_when(descTotal != 0 & descItem != 0 & descItem > 8 ~ 0,
                               TRUE ~ descTotal)) %>% 
  mutate(totalItem = round(cantItem*precioUnitarioItem - cantItem*descItem, 2))

df <- df %>% 
  filter(descTotal == 0) %>% 
  rbind(df2)

rm(df2)

# Tablas y gráficos ----
df <- df %>%
  mutate(fecha = dmy_hm(fecha),
         anio = year(fecha),
         mes = month(fecha),
         dia = day(fecha))

# Tabla diaria que divide las ventas mensuales por linea de negocio
tabla1 <- df %>% 
  mutate(lineaNegocio = case_when(catItem == "Pet Spa" ~ "Pet spa",
                                  TRUE ~ "Pet shop")) %>% 
  group_by(lineaNegocio, anio, mes,dia) %>% 
  summarise(montoDiario=sum(as.numeric(totalItem)))

# Tabla mensual que divide las ventas mensuales por linea de negocio
tabla2 <- tabla1 %>% 
  group_by(lineaNegocio,anio,mes) %>% 
  summarise(montoMensual=sum(as.numeric(montoDiario))) 


# Tabla mensual de ventas hasta el día de hoy
tabla1 %>% 
  filter(dia <= day(now())) %>% 
  group_by(lineaNegocio,anio,mes) %>% 
  summarise(montoMensual=sum(as.numeric(montoDiario))) %>% 
  ggplot() +
  aes(x = mes, y = montoMensual, color = lineaNegocio) +
  stat_summary(aes(y=montoMensual), fun ="mean", geom="point") +
  stat_summary(aes(y=montoMensual), fun ="mean", geom="line") +
  labs(x = "Mes",
       y = "Monto (en soles)") +
  labs(title = "Evolución de ventas mensuales a la fecha", 
       color = "Línea de negocio")

# Tabla de ventas anuales por producto 
tabla3 <- df %>% 
  group_by(codItem,descripcion,catItem,anio) %>% 
  summarise(montoMensual=sum(as.numeric(totalItem)),
            cantMensual = n()) %>% 
  ungroup()
  
  
# Tabla de ventas anuales por categoría 
tabla4 <- df %>% 
  group_by(catItem,anio) %>% 
  summarise(montoMensual=sum(as.numeric(totalItem)),
            cantMensual = n()) %>% 
  ungroup()

# Gráfico de ticket promedio 

df2 <- df %>% 
  mutate(spa = case_when(catItem == "Pet Spa" ~ 1,
                         TRUE ~ 0),
         shop = case_when(catItem != "Pet Spa" & catItem != "Delivery" ~ 1,
                          TRUE ~ 0),
         delivery = case_when(catItem == "Delivery" ~ 1,
                              TRUE ~ 0)) %>% 
  group_by(idVenta, anio, mes, nombreCliente, idCliente) %>% 
  summarise(montoVenta = mean(montoTotal),
            spa = sum(spa),
            shop = sum(shop),
            delivery = sum(delivery)) %>% 
  ungroup() %>% 
  mutate(tipoVenta = case_when(spa > 0 & shop > 0 ~ "Mixta",
                               spa > 0 & shop == 0 ~ "Solo spa",
                               spa == 0 & shop > 0 ~ "Solo shop"))

tabla5 <- df2 %>% 
  group_by(tipoVenta, anio, mes) %>% 
  summarise(ticketPromedio = mean(montoVenta),
            numero = n())


## PENDIENTE HACER ANÁLISIS POR CLIENTES, ANÁLISIS DE NUEVOS CLIENTES, ANÁLISIS DE ADICIONALES DE BAÑO, ETC
