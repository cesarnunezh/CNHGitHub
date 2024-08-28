#*******************************************************************************
# Proyecto: Personal
# Objetivo: Propuesta de NSE urbanos 
# Autores: CN
#*******************************************************************************

# 1. Librerías y direcciones ---------------------------------------------------
dirEnaho <- "C:/Users/canun/OneDrive - The University of Chicago/2. Trabajo/Análisis NSE/Data"
dirOutput <- "C:/Users/canun/OneDrive - The University of Chicago/2. Trabajo/Análisis NSE/Output"
library(haven)
library(dplyr)
library(writexl)
library(openxlsx)
library(pacman)
p_load(rio, cluster, factoextra, tidyverse, ggrepel, scatterplot3d, 
       tictoc, NbClust, dbscan)

# 2. Carga de bases de datos ---------------------------------------------------

## 2.1. A nivel de hogar -----
setwd(dirEnaho)
sumaria <- read_dta("sumaria-2023-12g.dta") %>%
  mutate(p=12) %>% 
  mutate(
    gpgru2 = (gru21hd + gru22hd + gru23hd + gru24hd + gru25hd + gru26hd + gru21hd1 + gru22hd1 + gru25hd1 + gru26hd1 + gru27hd1 + gru20hd) / p, ## "G02. Bebidas alcohólicas y estupefacientes"
    gpgru3 = (gru31hd + gru32hd + gru33hd + gru34hd + gru35hd + gru36hd + gru37hd) / p, ##"G03. Vestido y calzado"
    gpgru4 = (gru41hd + gru42hd + gru43hd + gru44hd + gru45hd + gru46hd + gru47hd + gru41hd1 + gru45hd1 + gru46hd1 + gru47hd1) / p, ## "G04. Alojamiento , agua, electricidad, gas y otros combustibles"
    gpgru5 = (gru51hd + gru52hd + gru53hd + gru54hd + gru55hd + gru56hd + gru57hd + gru51hd1 + gru52hd1 + gru53hd1 + gru55hd1 + gru56hd1 + gru57hd1 + sg421 + sg42d1) / p, ## "G05. Muebles, enseres y mantenimiento de la vivienda"
    gpgru6 = (gru61hd + gru62hd + gru64hd + gru65hd + gru66hd + gru67hd + gru60hd) / p, ## "G06. Salud"
    gpgru7 = (gru71hd + gru72hd + gru73hd + gru74hd + gru75hd + gru76hd + gru77hd + gru71hd1 + gru72hd1 + gru73hd1 + gru74hd1 + gru75hd1 + gru76hd1 + gru71hd2 + gru72hd2 + gru75hd2 + gru76hd2 + gru77hd2 + g07hd1 + g07hd2 + ig08hd1 + ig08hd2 + sg422 + sg42d2) / p, ## "G07. Transporte"
    gpgru8 = (gru81hd + gru82hd + gru83hd + gru84hd + gru85hd + gru86hd + gru87hd + sg42d) / p, ## "G08. Comunicaciones"
    gpgru9 = (gru91hd + gru92hd + gru93hd + gru94hd + gru95hd + gru96hd + gru97hd + gru91hd1 + gru92hd1 + gru93hd1 + gru94hd1 + gru95hd1 + gru96hd1 + gru97hd1 + gru91hd3 + gru92hd3 + gru93hd3 + gru94hd3 + gru95hd3 + gru96hd3 + gru90hd + sg42 + sg42d) / p, ## "G09. Recreación y cultura, Otros bienes y servicios"
    gpgru10 = (gru101hd + gru102hd + gru103hd + gru104hd + gru105hd + gru106hd) / p, ## "G10. Educación"
    gpgru11 = (gru111hd + gru112hd + gru113hd + gru114hd + gru115hd + gru116hd + gru110hd + gru111hd2 + gru112hd2 + gru113hd2 + gru114hd2 + gru115hd2 + gru116hd2 + gru110hd2 + gru111hd1 + gru112hd1 + gru115hd1 + gru116hd1 + gru117hd1 + g05hd + g05hd1 + g05hd2 + g05hd3 + g05hd4 + g05hd5 +g05hd6 +ig06hd + sg23 + sig24 + sg25 + sig26) / p, ## "G11. Restaurantes y hoteles, alimentos fuera del hogar"
    gpgru12 = (gru121hd + gru122hd + gru123hd + gru124hd + gru125hd + gru126hd + gru127hd + gru121hd3 + gru122hd3 + gru123hd3 + gru124hd3 + gru125hd3 + gru126hd3 + gru121hd2 + gru121hd4 + gru122hd4 + gru125hd4 + gru126hd4 + gru127hd4) / p, ## "G12. Bienes y servicios diversos, cuidado personal"
    gpgru1 = (gru11hd + gru12hd + gru13hd + gru14hd + gru15hd + gru16hd + gru10hd) / p, ##"G01. Alimentos dentro del hogar"
    gpgru0 = gpgru1 + gpgru2 + gpgru3 + gpgru4 + gpgru5 + gpgru6 + gpgru7 + gpgru8 + gpgru9 + gpgru10 + gpgru11 + gpgru12
  )

mod1 <- read_dta("enaho01-2023-100.dta",
                 col_select = c(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato,
                                fecent, result, p103, p111a, p114b1, p114b2, p114b3, p1144, p1143))

mod605 <- read_dta("enaho01-2023-605.dta",
                   col_select = c(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato, p605n, p605, p605a1))

mod605 <- mod605 %>%
  mutate(p605 = case_when(p605 == 2 | (p605 == 1 & p605a1 == 1 & p605n == 3) ~ 0,
                          is.na(p605) ~ NA,
                          TRUE ~ 1))
mod605h <- mod605 %>%
  group_by(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato) %>%
  pivot_wider(
    names_from = p605n,
    values_from = p605,
    names_prefix = "service_") %>% 
  rename(servicioDomestico = "service_3") %>% 
  ungroup() %>% 
  select(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato, servicioDomestico) %>% 
  group_by(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato) %>% 
  summarise(servicioDomestico = sum(servicioDomestico, na.rm = TRUE))

mod18 <- read_dta("enaho01-2023-612.dta",
                  col_select = c(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato, p612n, p612, p612b))

mod18 <- mod18 %>% 
  mutate(p612= case_when(p612 == 2 | (p612 == 1 & p612b == 1 & p612n == 17) ~ 0,
                         is.na(p612) ~ NA,
                         TRUE ~ 1))

mod18h <- mod18 %>%
  group_by(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato) %>%
  pivot_wider(
    names_from = p612n,
    values_from = p612,
    names_prefix = "equipment_") %>% 
  rename(computadora = "equipment_7",
         refrigerador = "equipment_12",
         lavadora = "equipment_13",
         auto = "equipment_17") %>% 
  select(-starts_with("equipment")) %>% 
  ungroup() %>% 
  group_by(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato) %>% 
  summarise(computadora = sum(computadora, na.rm = TRUE),
            refrigerador = sum(refrigerador, na.rm = TRUE),
            lavadora = sum(lavadora, na.rm = TRUE),
            auto = sum(auto, na.rm = TRUE))
rm(mod18)


baseHogares <- sumaria %>% 
  left_join(mod18h, by = c("aÑo", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", "estrato"))
rm(sumaria, mod18h)

baseHogares <- baseHogares %>% 
  left_join(mod1, by = c("aÑo", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", "estrato"))
rm(mod1)

baseHogares <- baseHogares %>% 
  left_join(mod605h, by = c("aÑo", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", "estrato"))
rm(mod605h)

baseHogares <- baseHogares %>% 
  mutate(area = case_when(estrato < 6 ~ 1,
                          TRUE ~ 0)) 

setwd(dirEnaho)
write_dta(data = baseHogares, "baseHogares.dta")

## 2.2. A nivel de hogar -----

setwd(dirEnaho)
mod2 <- read_dta("enaho01-2023-200.dta",
                 col_select = c(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato, codperso, p203, facpob07,
                                p207, p208a, p204, p205, p206))

mod3 <- read_dta("enaho01a-2023-300.dta", 
                 col_select = c(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato, codperso, p301a))

mod4 <- read_dta("enaho01a-2023-400.dta", 
                 col_select = c(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato, codperso,
                                p4191, p4192, p4193, p4194, p4195, p4196, p4197, p4198))

basePersonas <- mod2 %>% 
  left_join(mod3, by = c("aÑo", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", "estrato", "codperso")) %>% 
  left_join(mod4, by = c("aÑo", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", "estrato", "codperso")) 

rm(mod2, mod3, mod4, mod77, mod851, mod852)

basePersonas <- basePersonas %>% 
  mutate(area = case_when(estrato < 6 ~ 1,
                          TRUE ~ 0)) 

setwd(dirEnaho)
write_dta(data = basePersonas, "basePersonas.dta")

## 2.3. Generación de base de datos final -----

#Variables del jefe de hogar
setwd(dirEnaho)
basePersonas <- read_dta("basePersonas.dta")
baseJefesHogar <- basePersonas %>% 
  filter(p203 == 1) %>% 
  mutate(nivEducJH = case_when(p301a <= 4 ~ 1, # Hasta primaria completa
                               p301a == 5 ~ 2, # Secundaria incompleta
                               p301a == 6 ~ 3, # Secundaria completa
                               p301a == 7 | p301a == 8 ~ 4, # Superior no universitaria
                               p301a == 9 ~ 5, #Universitaria incompleta
                               p301a == 10 ~ 6, #Universitaria completa
                               p301a == 11 ~ 7, # Hasta postgrado 
                               is.na(p301a) ~ NA,
                               TRUE ~ NA),
         segJH = case_when(p4195 == 1 ~ 1, #SIS
                           p4191 == 1 | p4194 == 1 ~ 2, #EsSalud y FFAA
                           p4196 == 1 | p4197 == 1 | p4198 == 1 | p4192 == 1 | p4193 == 1 ~ 3, #SegPriv y EPS
                           is.na(p4191) ~ NA,
                           TRUE ~ NA))

baseHogares <- read_dta("baseHogares.dta")

baseHogares <-  baseHogares %>% 
  left_join(baseJefesHogar, by= c("aÑo", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", "estrato")) %>% 
  mutate(internet = case_when(p114b1 ==1 | p114b2 ==1 ~ 1,
                              p1144 == 0 | (p114b3 == 1 & p114b1 == 0 & p114b2 == 0) ~ 0,
                              is.na(p114b1) ~ NA,
                              TRUE ~ 0),
         tvcable = case_when(p1143 == 1 ~ 1,
                             is.na(p1143) ~ NA,
                             TRUE ~ 0),
         piso = case_when(p103 == 6 | p103 == 7 ~ 1,
                          p103 == 5 ~ 2,
                          p103 == 4 ~ 3,
                          p103 == 3 | p103 == 2 | p103 == 1 ~ 4,
                          TRUE ~ NA),
         saneamiento = case_when(p111a == 7 | p111a == 9 ~ 1,
                                 p111a == 6 ~ 2,
                                 p111a == 5 | p111a == 4 | p111a == 3 ~ 3,
                                 p111a == 2 ~ 4 ,
                                 p111a == 1 ~ 5,
                                 TRUE ~ NA)) 

# Selecciono únicamente las variables que utiliza la última versión del APEIM 2023
baseHogares <- baseHogares %>% 
  mutate(nse = rowSums(select(., nivEducJH, segJH, piso, saneamiento, auto, servicioDomestico,
                              computadora, refrigerador, lavadora, tvcable, internet), na.rm = TRUE),
         gasPC = gpgru0/mieperho,
         gastoMensual = gpgru0,
         contador = 1) %>% 
  filter(gasPC != 0)

baseHogares %>% ggplot() +
  aes(x = nse, y = gasPC)+
  geom_point()

# 3. Generación de NSE
## 3.1 Clusterización con K-Means
baseHogares <- baseHogares %>% 
  select(aÑo, mes, conglome, vivienda, hogar, ubigeo, dominio, estrato, factor07, mieperho, nse, gasPC, gastoMensual, contador, gpgru0, gpgru1, gpgru2, gpgru3, gpgru4, gpgru5, gpgru6, gpgru7, gpgru8, gpgru9, gpgru10, gpgru11, gpgru12) %>% 
  mutate(gasPC = log(gasPC)) %>% 
  mutate(gasPC = scale(gasPC),
         nseNew = scale (nse))

baseHogares %>% ggplot() +
  aes(x = nseNew, y = gasPC)+
  geom_point() 

library(factoextra)

set.seed(2023)
tic()
km <- kmeans(baseHogares %>% select(nseNew, gasPC), 
             centers = 7,     # N??mero de Cluster
             iter.max = 1000,  # N??mero de iteraciones m??xima
             nstart = 15,     # N??mero de puntos iniciales
             algorithm = "Lloyd")


print(km)
prop.table(km$size)

fviz_cluster(km, data = baseHogares %>% select(nseNew, gasPC), ellipse.type = "convex") +
  theme_classic()

toc()

baseHogares$cluster <- km$cluster

baseHogares <- baseHogares %>% 
  mutate(nseOpcion1 = case_when(cluster == 7 ~ "E",
                                cluster == 5 ~ "D",
                                cluster == 6 ~ "C1",
                                cluster == 3 ~ "C2",
                                cluster == 1 ~ "B1",
                                cluster == 2 ~ "B2",
                                cluster == 4 ~ "A"))

library(survey)
design <- svydesign(id = ~conglome,  # Variable de conglomerados
                    strata = ~estrato,   # Variable de estratos
                    weights = ~factor07,     # Variable de pesos
                    data = baseHogares,
                    nest = FALSE) 

gastoprom1 <- svyby(~gastoMensual, ~nseOpcion1, design, svymean)
num_observaciones1 <- svyby(~contador, ~nseOpcion1, design, svytotal)
colnames(num_observaciones1)[2] <- "N° hogares"
resultados1 <- merge(gastoprom1, num_observaciones1, by = "nseOpcion1")

## 3.2 Clusterización con Jenks breaks
library(classInt)
breaks <- classIntervals(baseHogares$nse, n = 7, style = "jenks")
baseHogares$jenks_breaks <- cut(baseHogares$nse, breaks$brks, include.lowest = TRUE)

baseHogares <- baseHogares %>% 
  mutate(nseOpcion2 = case_when(jenks_breaks == "[3,6]" ~ "E",
                                jenks_breaks == "(6,9]" ~ "D",
                                jenks_breaks == "(9,11]" ~ "C2",
                                jenks_breaks == "(11,13]" ~ "C1",
                                jenks_breaks == "(13,16]" ~ "B2",
                                jenks_breaks == "(16,19]" ~ "B1",
                                jenks_breaks == "(19,25]" ~ "A"))

library(survey)
design <- svydesign(id = ~conglome,  # Variable de conglomerados
                    strata = ~estrato,   # Variable de estratos
                    weights = ~factor07,     # Variable de pesos
                    data = baseHogares,
                    nest = FALSE) 

gastoprom2 <- svyby(~gastoMensual, ~nseOpcion2, design, svymean)
num_observaciones2 <- svyby(~contador, ~nseOpcion2, design, svytotal)
colnames(num_observaciones2)[2] <- "N° hogares"
resultados2 <- merge(gastoprom2, num_observaciones2, by = "nseOpcion2")

## 3.3. Clusterización con límites de APEIM Metodología 2011-2012
baseHogares <- baseHogares %>% 
  mutate(nseOpcion3 = case_when(nse <= 8 ~ "E",
                                nse > 8 & nse <= 11 ~ "D",
                                nse > 11 & nse <= 13 ~ "C2",
                                nse > 13 & nse <= 17 ~ "C1",
                                nse > 17 & nse <= 20 ~ "B2",
                                nse > 20 & nse <= 22 ~ "B1",
                                nse > 22  ~ "A"))

design <- svydesign(id = ~conglome,  # Variable de conglomerados
                    strata = ~estrato,   # Variable de estratos
                    weights = ~factor07,     # Variable de pesos
                    data = baseHogares,
                    nest = FALSE) 
gastoprom3 <- svyby(~gastoMensual, ~nseOpcion3, design, svymean)
num_observaciones3 <- svyby(~contador, ~nseOpcion3, design, svytotal)
colnames(num_observaciones3)[2] <- "N° hogares"
resultados3 <- merge(gastoprom3, num_observaciones3, by = "nseOpcion3")

# Exportación de resultados
setwd(dirOutput)

wb <- createWorkbook()
addWorksheet(wb, "Opción 1 - Clusters K-means")
writeData(wb, "Opción 1 - Clusters K-means", resultados1)

# Agregar una hoja para la tabla de proporciones ponderadas
addWorksheet(wb, "Opción 2 - Jenks Breaks")
writeData(wb, "Opción 2 - Jenks Breaks", resultados2)

# Agregar una hoja para el ingreso promedio por nse
addWorksheet(wb, "Opción 3 - APEIM")
writeData(wb, "Opción 3 - APEIM", resultados3)

# Guardar el archivo Excel
saveWorkbook(wb, "resultados.xlsx", overwrite = TRUE)


## 4. Desagregación por sexo y edad

basePersonas2 <- basePersonas %>% 
  left_join(baseHogares, by = c("aÑo", "mes", "conglome", "vivienda", "hogar", "ubigeo", "dominio", "estrato")) %>% 
  mutate(sexo = case_when(p207 == 2 ~ "Mujer",
                          TRUE ~ "Hombre"),
         grupoEdad = case_when(p208a < 5 ~ "0 a 4 años",
                               p208a >= 5 & p208a < 15 ~ "5 a 14 años",
                               p208a >=15 & p208a < 45 ~ "15 a 44 años",
                               p208a >=45 & p208a < 60 ~ "45 a 59 años",
                               p208a == NA ~ NA,
                               TRUE ~ "60 a más años")) %>% 
  filter(((p204==1 & p205==2) | (p204==2 & p206==1)))

design <- svydesign(id = ~conglome,  # Variable de conglomerados
                    strata = ~estrato,   # Variable de estratos
                    weights = ~facpob07,     # Variable de pesos
                    data = basePersonas2,
                    nest = FALSE) 

distSexo <- svyby(~contador, ~ sexo + nseOpcion1, design, svytotal)
distEdad <- svyby(~contador, ~ grupoEdad + nseOpcion1, design, svytotal)
distSexoEdad <- svyby(~contador, ~ sexo + grupoEdad + nseOpcion1, design, svytotal)

setwd(dirOutput)

wb2 <- createWorkbook()
addWorksheet(wb2, "Distribución por Sexo")
writeData(wb2, "Distribución por Sexo", distSexo)

# Agregar una hoja para la tabla de proporciones ponderadas
addWorksheet(wb2, "Distribución por Edad")
writeData(wb2, "Distribución por Edad", distEdad)

addWorksheet(wb2, "Distribución por Sexo y Edad")
writeData(wb2, "Distribución por Sexo y Edad", distSexoEdad)

# Guardar el archivo Excel
saveWorkbook(wb2, "distribucion.xlsx", overwrite = TRUE)

## 5. Desagregación del gasto
library(survey)
design <- svydesign(id = ~conglome,  # Variable de conglomerados
                    strata = ~estrato,   # Variable de estratos
                    weights = ~factor07,     # Variable de pesos
                    data = baseHogares,
                    nest = FALSE) 

gastoDesagregado <- svyby(~gpgru1 + gpgru2 + gpgru3 + gpgru4 + gpgru5 + gpgru6 + gpgru7 + gpgru8 + gpgru9 + gpgru10 + gpgru11 + gpgru12 + gpgru0, ~nseOpcion1, design, svymean)
colnames(gastoDesagregado)[1:13] <- c("NSE", "Alimentos", "Bebidas alcoholicas, estupefacientes y tabaco", "Vestido y calzado", "Alojamiento, agua, electricidad, gas, y guardianía", "Muebles, enseres y mantenimiento de la vivienda", "Salud", "Transporte", "Comunicaciones", "Recreación y cultura", "Educación", "Restaurantes y hoteles, alimentos fuera del hogar", "Bienes y servicios diversos")
gastoDesagregado <- gastoDesagregado[1:13]


baseHogares <- baseHogares %>% 
  mutate(gpgru0PC = gpgru0 / mieperho,
         gpgru1PC = gpgru1 / mieperho,
         gpgru2PC = gpgru2 / mieperho,
         gpgru3PC = gpgru3 / mieperho,
         gpgru4PC = gpgru4 / mieperho,
         gpgru5PC = gpgru5 / mieperho,
         gpgru6PC = gpgru6 / mieperho,
         gpgru7PC = gpgru7 / mieperho,
         gpgru8PC = gpgru8 / mieperho,
         gpgru9PC = gpgru9 / mieperho,
         gpgru10PC = gpgru10 / mieperho,
         gpgru11PC = gpgru11 / mieperho,
         gpgru12PC = gpgru12 / mieperho)

library(survey)
design <- svydesign(id = ~conglome,  # Variable de conglomerados
                    strata = ~estrato,   # Variable de estratos
                    weights = ~factor07,     # Variable de pesos
                    data = baseHogares,
                    nest = FALSE) 

gastoDesagregadoPC <- svyby(~gpgru1PC + gpgru2PC + gpgru3PC + gpgru4PC + gpgru5PC + gpgru6PC + gpgru7PC + gpgru8PC + gpgru9PC + gpgru10PC + gpgru11PC + gpgru12PC + gpgru0PC, ~nseOpcion1, design, svymean)
colnames(gastoDesagregadoPC)[1:13] <- c("NSE", "Alimentos", "Bebidas alcoholicas, estupefacientes y tabaco", "Vestido y calzado", "Alojamiento, agua, electricidad, gas, y guardianía", "Muebles, enseres y mantenimiento de la vivienda", "Salud", "Transporte", "Comunicaciones", "Recreación y cultura", "Educación", "Restaurantes y hoteles, alimentos fuera del hogar", "Bienes y servicios diversos")
gastoDesagregadoPC <- gastoDesagregadoPC[1:13]

wb3 <- createWorkbook()
addWorksheet(wb3, "Grupos de gasto")
writeData(wb3, "Grupos de gasto", gastoDesagregado)

addWorksheet(wb3, "Grupos de gasto - Per cápita")
writeData(wb3, "Grupos de gasto - Per cápita", gastoDesagregadoPC)

saveWorkbook(wb3, "gastogrupos.xlsx", overwrite = TRUE)

