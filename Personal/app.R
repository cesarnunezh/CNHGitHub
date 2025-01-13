install.packages("shiny")
install.packages("ggplot2")
install.packages("dplyr")

library(tidyverse)
library(openxlsx)
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(shinythemes)
library(shinycssloaders)
library(bslib)
library(bsicons)
library(rsconnect)


#1. Importación y limpieza de base de datos ----

#dir <- 'D:/1. Documentos/0. Bases de datos/00. GitHub/CNH_rep/Personal'
#setwd(dir)

#df <- read.xlsx('ReporteVentas.xlsx', startRow = 9) 

df <- read.xlsx("https://github.com/cesarnunezh/CNH_rep/raw/refs/heads/main/Personal/ReporteVentas.xlsx", startRow = 9)

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
  filter(str_detect(descripcion, "y corte|//+ cort|//+ reto|//y retoque|//y recort"))

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
  filter(!str_detect(descripcion, "y corte|//+ cort|//+ reto|//y retoque|//y recort")) %>% 
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

#2.  Tablas y gráficos ----
df <- df %>%
  mutate(fecha = dmy_hm(fecha),
         anio = year(fecha),
         mes = month(fecha),
         dia = day(fecha)) %>% 
  mutate(lineaNegocio = case_when(catItem == "Pet Spa" | catItem =="Delivery" ~ "Pet spa",
                                  TRUE ~ "Pet shop")) 


tabla1 <- df %>%
  group_by(lineaNegocio, anio, mes,dia) %>% 
  summarise(montoDiario=sum(as.numeric(totalItem)))

# Tabla mensual que divide las ventas por linea de negocio
tabla2 <- tabla1 %>% 
  group_by(lineaNegocio,anio,mes) %>% 
  summarise(montoMensual=sum(as.numeric(montoDiario))) 


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


## PENDIENTE HACER ANÁLISIS POR CLIENTES, ANÁLISIS DE NUEVOS CLIENTES, ANÁLISIS DE ADICIONALES DE BAÑO, ETC
# Tabla de número de nuevos clientes por mes

lista <- c("Pet spa","Pet shop", "Total")

lista_anios <- c(2024, 2023)

lista_mes <-df %>%  
  select(mes) %>% 
  distinct() %>%  
  arrange(mes)  %>%  
  drop_na()

# 3. UI: USER INTERFACE -----
# UI (User Interface): La UI es la interfaz de usuario y es la primera parte que los usuarios ven 
# cuando utilizan la aplicaci??n. 
# La UI se define utilizando la funci??n ui.R y contiene los componentes gr??ficos, 
# como men??s, botones, gr??ficos y tablas.

ui <- fluidPage(
  theme = bs_theme(
    bg = "white",    # Background color
    fg = "black",    # Foreground (text) color
    primary = "#54B6B5",
    secondary = "#E8BB82",
    success = "#031B6A",
    base_font = font_google("Inter"),
    code_font = font_google("JetBrains Mono"),
    font_scale = 1.5
  ),
  tags$head(
    tags$style(HTML("
      /* Custom Navbar Colors */
      .navbar {
        background-color: #54B6B5 !important; /* Force Navbar background color */
        color: #FFFFFF !important; /* Force Navbar text color */
      }
      .navbar .navbar-nav > li > a {
        background-color: #54B6B5 
        color: #FFFFFF !important; /* Force Navbar link color */
      }
      .navbar .navbar-brand {
        background-color: #54B6B5 
        color: #FFFFFF !important; /* Force Navbar brand color */
      }
      .navbar .navbar-nav > li > a:hover,
      .navbar .navbar-nav > li > a:focus {
        background-color: #54B6B5 !important; /* Navbar link hover color */
      }
    "))
  ),
  navbarPage("Dashboard de La Casa de Sammy", theme = shinytheme("lumen"),
             tabPanel("Ingresos", fluid = TRUE, icon = icon("dog"),
                      fluidRow(
                        column(offset = 2,
                               width = 3,
                               selectInput(inputId = "Year",
                                           label = "Año",
                                           choices = lista_anios,
                                           selected = year(now()),
                                           width = "220px")),
                        column(width = 3,
                               selectInput(inputId = "Mes",
                                           label = "Mes",
                                           choices = lista_mes,
                                           selected = month(now()),
                                           width = "220px")),
                        column(width = 3,
                               selectInput(inputId = "lineaNegocio",
                                           label = "Línea de Negocio",
                                           choices = lista,
                                           selected = "Total",
                                           width = "220px"))),
                      fluidRow(
                        column(offset = 2,
                               width = 12,
                               mainPanel(
                                 layout_columns(
                                   value_box(
                                     textOutput("dato1"),
                                     title = "Total ventas",
                                     showcase = bs_icon("coin", size = 100, style = "fill: white;"),
                                     showcase_layout = "left center",
                                     style = "background-color: #54B6B5; color: white; font-size: 2vw;"),
                                   value_box(
                                     textOutput("dato2"),
                                     title = "Número de clientes",
                                     showcase = bs_icon("people", size = 100),
                                     showcase_layout = "left center",
                                     style = "background-color: #54B6B5; color: white;"),
                                   value_box(
                                     textOutput("dato3"),
                                     title = "Nuevos clientes",
                                     showcase = bs_icon("bar-chart-fill", size = 100),
                                     showcase_layout = "left center",
                                     style = "background-color: #54B6B5; color: white;")
                                 ),
                                 hr(),
                                 layout_columns(
                                   value_box(
                                     textOutput("dato4"),
                                     title = "Ticket promedio",
                                     showcase = bs_icon("ticket", size = 100),
                                     showcase_layout = "left center",
                                     style = "background-color: #54B6B5; color: white;"),
                                   value_box(
                                     textOutput("dato5"),
                                     title = "Ticket promedio Mixto",
                                     showcase = bs_icon("ticket", size = 100),
                                     showcase_layout = "left center",
                                     style = "background-color: #54B6B5; color: white;"),
                                   value_box(
                                     textOutput("dato6"),
                                     title = "Ticket máximo",
                                     showcase = bs_icon("wallet", size = 100),
                                     showcase_layout = "left center",
                                     style = "background-color: #54B6B5; color: white;")
                                 ),
                                 hr(),
                                 layout_columns(
                                   card(
                                     full_screen = TRUE,
                                     max_height = 350,
                                     card_header("Evolución mensual"),
                                     useShinyjs(),
                                     plotOutput("graph1")
                                     ),
                                   card(
                                     full_screen = TRUE,
                                     max_height = 350,
                                     card_header("Evolución diaria"),
                                     plotOutput("graph2")
                                   )
                                   ),
                                 hr(),
                                 layout_columns(
                                   card(
                                     full_screen = TRUE,
                                     max_height = 350,
                                     card_header("Top productos y servicios"),
                                     plotOutput("graph3")
                                   )
                                 )
                                 )
                               )
                        )
                      )
             ))


# 4. SERVIDOR ----- 
# El servidor maneja la l??gica de la aplicaci??n, 
# procesa los datos y crea la salida que se muestra en la UI. 

server <- function(input, output) {
  
  output$graph1 <- renderPlot({
    
    # Tabla diaria que divide las ventas por linea de negocio
    
    nuevasLineas  <- df %>%
      group_by(lineaNegocio, anio, mes) %>% 
      summarise(montoMensual=sum(as.numeric(totalItem))) %>% 
      group_by(anio, mes) %>%
      summarise(montoMensual = sum(montoMensual), .groups = 'drop') %>% 
      mutate(lineaNegocio = "Total")
    
    
    df %>%
      group_by(lineaNegocio, anio, mes) %>% 
      summarise(montoMensual=sum(as.numeric(totalItem))) %>% 
      bind_rows(nuevasLineas) %>%  
      mutate(mes = as.Date(paste0(anio, "-", mes, "-01"))) %>%  
      ggplot() +
      aes(x = mes, y = montoMensual, fill = lineaNegocio) +
      geom_bar(stat = "identity", position = "dodge") +
      geom_smooth(aes(color = lineaNegocio), method = "lm", se = FALSE, linewidth = 0.5) + 
      labs(x = "Mes",
           y = "Monto (en soles)") +
      labs(title = "Evolución de ventas mensuales 2024", 
           color = "Línea de negocio",
           fill = "Línea de negocio") +
      scale_x_date(date_labels = "%m-%y", date_breaks = "1 month") +
      scale_fill_manual(values = c("Pet shop" = "#54B6B5", "Pet spa" = "#E8BB82", "Total" = "#031B6A")) +
      scale_color_manual(values = c("Pet shop" = "#54B6B5", "Pet spa" = "#E8BB82", "Total" = "#031B6A"))
    
  }) 
  
  output$graph2 <- renderPlot({
    
    if (input$lineaNegocio == "Total"){
      tabla1 <- df %>%
        group_by(anio, mes,dia) %>% 
        summarise(montoDiario=sum(as.numeric(totalItem)))
      
      tablaAlterna <- tabla1 %>% 
        filter(mes == input$Mes) %>% 
        group_by(anio, mes) %>% 
        mutate(montoAcum = cumsum(montoDiario)) %>% 
        ungroup() %>% 
        mutate(categoria = "Mes actual")
      
      alterna <- tabla1 %>% 
        group_by(anio, mes) %>% 
        arrange(anio,mes,dia) %>%
        mutate(acumulado_ventas = cumsum(montoDiario)) %>% 
        ungroup() %>% 
        group_by(anio, dia) %>% 
        summarise(montoAcum = mean(acumulado_ventas)) %>%
        mutate(categoria = "Promedio")
      
      alterna2 <- tabla1 %>% 
        group_by(anio, mes) %>% 
        arrange(anio,mes,dia) %>%
        mutate(acumulado_ventas = cumsum(montoDiario)) %>% 
        ungroup() %>% 
        group_by(anio, dia) %>% 
        summarise(montoAcum = max(acumulado_ventas)) %>%
        mutate(categoria = "Máximo")
      
      tablaAlterna <- tablaAlterna %>% 
        select(anio,dia,montoAcum, categoria) %>% 
        rbind(alterna %>% select(anio,dia,montoAcum, categoria), alterna2) 
      
      tablaAlterna %>%
        ggplot() +
        aes(x = dia, y = montoAcum, color = categoria) +
        stat_summary(aes(y=montoAcum), fun ="mean", geom="point") +
        stat_summary(aes(y=montoAcum), fun ="mean", geom="line") +
        labs(x = "Mes",
             y = "Monto (en soles)") +
        labs(title = "Evolución de ventas mensuales a la fecha", 
             color = "Línea de negocio") +
        scale_color_manual(values = c("Máximo" = "#54B6B5", "Promedio" = "#E8BB82", "Mes actual" = "#031B6A")) 
      
    }
    else {
      tabla1 <- df %>%
        group_by(lineaNegocio, anio, mes,dia) %>% 
        summarise(montoDiario=sum(as.numeric(totalItem)))
      
      tablaAlterna <- tabla1 %>% 
        filter(mes == input$Mes) %>% 
        group_by(lineaNegocio, anio, mes) %>% 
        mutate(montoAcum = cumsum(montoDiario)) %>% 
        ungroup() %>% 
        mutate(categoria = "Mes actual")
      
      alterna <- tabla1 %>% 
        group_by(lineaNegocio, anio, mes) %>% 
        arrange(anio,mes,dia) %>%
        mutate(acumulado_ventas = cumsum(montoDiario)) %>% 
        ungroup() %>% 
        group_by(lineaNegocio, anio, dia) %>% 
        summarise(montoAcum = mean(acumulado_ventas)) %>%
        mutate(categoria = "Promedio")
      
      alterna2 <- tabla1 %>% 
        group_by(lineaNegocio, anio, mes) %>% 
        arrange(anio,mes,dia) %>%
        mutate(acumulado_ventas = cumsum(montoDiario)) %>% 
        ungroup() %>% 
        group_by(lineaNegocio, anio, dia) %>% 
        summarise(montoAcum = max(acumulado_ventas)) %>%
        mutate(categoria = "Máximo")
      
      tablaAlterna <- tablaAlterna %>% 
        select(lineaNegocio,anio,dia,montoAcum, categoria) %>% 
        rbind(alterna, alterna2)
      
      tablaAlterna %>%
        filter(lineaNegocio == input$lineaNegocio) %>% 
        ggplot() +
        aes(x = dia, y = montoAcum, color = categoria) +
        stat_summary(aes(y=montoAcum), fun ="mean", geom="point") +
        stat_summary(aes(y=montoAcum), fun ="mean", geom="line") +
        labs(x = "Día",
             y = "Monto (en soles)") +
        labs(title = "Evolución de ventas mensuales a la fecha", 
             color = "Línea de negocio") +
        scale_color_manual(values = c("Máximo" = "#54B6B5", "Promedio" = "#E8BB82", "Mes actual" = "#031B6A")) 
    }
    
    
  }) 
  
  output$graph3 <- renderPlot({
    
    # Tabla diaria que divide las ventas por linea de negocio

    productos <- df %>%
      group_by(anio, mes, codItem, descripcion) %>% 
      summarise(cantidadMensual=n()) %>% 
      filter(anio == input$Year, mes == input$Mes) %>% 
      arrange(desc(cantidadMensual)) 
    
    productos[1:10,] %>% ggplot() +
      aes(x = reorder(descripcion, -cantidadMensual), y = cantidadMensual) +
      geom_bar(stat = "identity", position = "dodge", fill = "#54B6B5") +  
      geom_text(aes(label = round(cantidadMensual)), vjust = -0.5, size = 4) +
      labs(x = "Producto o servicio",
           y = "Cantidad vendida") +
      labs(title = "Top 10 productos y servicios vendidos en el mes") +
      scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) 
    
  }) 
  
  output$dato1 <- renderPrint({
    
    if (input$lineaNegocio == "Total"){
      valor <- df %>% 
        filter(anio == input$Year & mes == input$Mes ) %>% 
        select(totalItem) %>% 
        sum() %>% 
        round(digits = 2)
      
      formatted_value <- paste("S/", format(valor, big.mark = ",", decimal.mark = ".", nsmall = 2))
      cat(formatted_value)
    }
    else{
      valor <- df %>% 
        filter(anio == input$Year & mes == input$Mes & lineaNegocio == input$lineaNegocio) %>% 
        select(totalItem) %>% 
        sum() %>% 
        round(digits = 2)
      
      formatted_value <- paste("S/", format(valor, big.mark = ",", decimal.mark = ".", nsmall = 2))
      cat(formatted_value) 
    }

  })
    
  output$dato2 <- renderPrint({

    if (input$lineaNegocio == "Total"){
      
      tabla6 <- df %>% 
        filter(!is.na(idCliente)) %>% 
        arrange(idVenta) %>% 
        group_by(idCliente) %>% 
        mutate(clienteNuevo = if_else(row_number() == 1, 1, 0)) %>% 
        ungroup() %>% 
        group_by(mes, idCliente) %>% 
        mutate(nClientes = if_else(row_number() == 1, 1, 0)) %>% 
        group_by(anio, mes) %>% 
        summarise(nuevosClientes = sum(clienteNuevo),
                  totalClientes = sum(nClientes))
      
      valor <- tabla6 %>% 
        ungroup %>% 
        filter(anio == input$Year & mes == input$Mes) %>% 
        summarise(total = sum(totalClientes)) %>% 
        select(total) %>% 
        sum() %>% 
        round(digits = 0)
      cat(valor)
    }
    else{
      tabla6 <- df %>% 
        filter(!is.na(idCliente)) %>% 
        arrange(idVenta) %>% 
        group_by(idCliente, lineaNegocio) %>% 
        mutate(clienteNuevo = if_else(row_number() == 1, 1, 0)) %>% 
        ungroup() %>% 
        group_by(mes, idCliente, lineaNegocio) %>% 
        mutate(nClientes = if_else(row_number() == 1, 1, 0)) %>% 
        group_by(anio, mes, lineaNegocio) %>% 
        summarise(nuevosClientes = sum(clienteNuevo),
                  totalClientes = sum(nClientes))
      
      valor <- tabla6 %>% 
        ungroup %>% 
        filter(anio == input$Year & mes == input$Mes & lineaNegocio == input$lineaNegocio) %>% 
        select(totalClientes) %>% 
        sum() %>% 
        round(digits = 0)
    
      cat(valor)
    }
    
  })
  
  output$dato3 <- renderPrint({
    
    if (input$lineaNegocio == "Total"){
      tabla6 <- df %>% 
        filter(!is.na(idCliente)) %>% 
        arrange(idVenta) %>% 
        group_by(idCliente) %>% 
        mutate(clienteNuevo = if_else(row_number() == 1, 1, 0)) %>% 
        ungroup() %>% 
        group_by(mes, idCliente) %>% 
        mutate(nClientes = if_else(row_number() == 1, 1, 0)) %>% 
        group_by(anio, mes) %>% 
        summarise(nuevosClientes = sum(clienteNuevo),
                  totalClientes = sum(nClientes))
      
      valor <- tabla6 %>% 
        ungroup %>% 
        filter(anio == input$Year & mes == input$Mes) %>% 
        summarise(total = sum(nuevosClientes)) %>% 
        select(total) %>% 
        sum() %>% 
        round(digits = 0)
      cat(valor)
    }
    else {
      tabla6 <- df %>% 
        filter(!is.na(idCliente)) %>% 
        arrange(idVenta) %>% 
        group_by(idCliente, lineaNegocio) %>% 
        mutate(clienteNuevo = if_else(row_number() == 1, 1, 0)) %>% 
        ungroup() %>% 
        group_by(mes, idCliente, lineaNegocio) %>% 
        mutate(nClientes = if_else(row_number() == 1, 1, 0)) %>% 
        group_by(anio, mes, lineaNegocio) %>% 
        summarise(nuevosClientes = sum(clienteNuevo),
                  totalClientes = sum(nClientes))
      
      valor <- tabla6 %>% 
      ungroup %>% 
      filter(anio == input$Year & mes == input$Mes & lineaNegocio == input$lineaNegocio) %>% 
      select(nuevosClientes) %>% 
      sum() %>% 
      round(digits = 0)
    cat(valor)
    }
    
  })
  
  output$dato4 <- renderPrint({
    
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
                                   spa > 0 & shop == 0 ~ "Pet spa",
                                   spa == 0 & shop > 0 ~ "Pet shop"))
    
    if (input$lineaNegocio == "Total"){
      tabla5 <- df2 %>% 
        group_by(anio, mes) %>% 
        summarise(ticketPromedio = mean(montoVenta),
                  numero = n()) 
      
      dfvalor <- tabla5 %>% 
        filter(anio == input$Year & mes == input$Mes )
      
      valor <- dfvalor$ticketPromedio %>% 
        round(digits = 2)
      
      formatted_value <- paste("S/", format(valor, big.mark = ",", decimal.mark = ".", nsmall = 2))
      cat(formatted_value)
    }
    else {
      tabla5 <- df2 %>% 
        group_by(tipoVenta, anio, mes) %>% 
        summarise(ticketPromedio = mean(montoVenta),
                  numero = n()) 
    
      dfvalor <- tabla5 %>% 
        filter(anio == input$Year & mes == input$Mes & tipoVenta == input$lineaNegocio)
      
      valor <- dfvalor$ticketPromedio %>% 
        round(digits = 2)
      
      formatted_value <- paste("S/", format(valor, big.mark = ",", decimal.mark = ".", nsmall = 2))
      cat(formatted_value)
    }
  })
  
  output$dato5 <- renderPrint({
    
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
                                   spa > 0 & shop == 0 ~ "Pet spa",
                                   spa == 0 & shop > 0 ~ "Pet shop"))
    
    tabla5 <- df2 %>% 
      group_by(tipoVenta, anio, mes) %>% 
      summarise(ticketPromedio = mean(montoVenta),
                numero = n()) 
    
    dfvalor <- tabla5 %>% 
      filter(anio == input$Year & mes == input$Mes & tipoVenta == "Mixta")
    
    valor <- dfvalor$ticketPromedio %>% 
      round(digits = 2)
    
    formatted_value <- paste("S/", format(valor, big.mark = ",", decimal.mark = ".", nsmall = 2))
    cat(formatted_value)
    
  })
  
  output$dato6 <- renderPrint({
   
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
                                   spa > 0 & shop == 0 ~ "Pet spa",
                                   spa == 0 & shop > 0 ~ "Pet shop"))
     
    if (input$lineaNegocio == "Total"){

    dfvalor <- df2 %>% 
      ungroup() %>% 
      filter(anio == input$Year & mes == input$Mes) %>% 
      group_by(anio, mes) %>% 
      summarise(maximo = max(montoVenta))
    
    valor <- dfvalor$maximo %>% 
      round(digits = 2)
    
    formatted_value <- paste("S/", format(valor, big.mark = ",", decimal.mark = ".", nsmall = 2))
    cat(formatted_value)
    
    }
    else {
      dfvalor <- df2 %>% 
        ungroup() %>% 
        filter(anio == input$Year & mes == input$Mes & tipoVenta == input$lineaNegocio) %>% 
        group_by(anio, mes) %>% 
        summarise(maximo = max(montoVenta))
      
      valor <- dfvalor$maximo %>% 
        round(digits = 2)
      
      formatted_value <- paste("S/", format(valor, big.mark = ",", decimal.mark = ".", nsmall = 2))
      cat(formatted_value)
    }

    
  })
}

# 5. EJECUCI??N DE APLICACI??N ----- 
shinyApp(ui = ui, server = server)