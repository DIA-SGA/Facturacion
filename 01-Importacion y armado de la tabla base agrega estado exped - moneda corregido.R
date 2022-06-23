  rm(list=ls())
  
  #VALORES DE LAS DIVISAS
  #link para cotizaciones del banco nacion
  url<-"https://www.bna.com.ar/Personas"
  DOLAR<-122.25
  EURO<-125.75
  
  #1-importo los archivos bajados de TABLEAU (son las 4hojas en verde del xls de Denise)
  library(pacman)
  p_load(readxl,tidyverse,lubridate,R.utils)
  
  #a)tramitaciones
  movimientos.exp<- read_excel("bases/Detalle_crosstab.xlsx")
  view(movimientos.exp)
  
  ## construimos campos fechas como lo requiere el script
  ## me quedo con la primero de la fecha
  movimientos.exp$`Fecha de caratulación`<- word(movimientos.exp$`Fecha de caratulación`, 1, sep = fixed(" "))
  movimientos.exp$`Fecha de última modificación`<- word(movimientos.exp$`Fecha de última modificación`, 1, sep = fixed(" "))
  movimientos.exp$`Fecha de último pase`<- word(movimientos.exp$`Fecha de último pase`, 1, sep = fixed(" "))
  
  ## las paso a lubridate
  movimientos.exp$`Fecha de caratulación`<-ymd(movimientos.exp$`Fecha de caratulación`)
  movimientos.exp$`Fecha de última modificación`<-ymd(movimientos.exp$`Fecha de última modificación`)
  movimientos.exp$`Fecha de último pase`<-ymd(movimientos.exp$`Fecha de último pase`)
  
  ##las paso a formato dia mes año
  movimientos.exp <- movimientos.exp %>%
    mutate(año_cara=year(`Fecha de caratulación`),
           mes_cara=month(`Fecha de caratulación`),
           dia_cara=day(`Fecha de caratulación`),
           año_modi=year(`Fecha de última modificación`),
           mes_modi=month(`Fecha de última modificación`),
           dia_modi=day(`Fecha de última modificación`),
           año_pas=year(`Fecha de último pase`),
           mes_pas=month(`Fecha de último pase`),
           dia_pas=day(`Fecha de último pase`),
           fecha_cara=paste(dia_cara,mes_cara,año_cara,sep="/"), 
           fecha_modi=paste(dia_modi,mes_modi,año_modi,sep="/"),
           fecha_pas=paste(dia_pas,mes_pas,año_pas,sep="/")) %>%
    select(1:4,61,62,7:44,63,46:51) %>%
    rename(`Fecha de caratulación`="fecha_cara") %>%
    rename(`Fecha de última modificación`="fecha_modi") %>%
    rename(`Fecha de último pase`="fecha_pas")    
  
  # movimientos.exp$`Fecha de caratulación`<- lubridate::mdy(movimientos.exp$`Fecha de caratulación`)
  # movimientos.exp$`Fecha de último pase`<- lubridate::mdy(movimientos.exp$`Fecha de último pase`)
  # movimientos.exp$`Fecha de última modificación`<- lubridate::mdy(movimientos.exp$`Fecha de última modificación`)
  
  ##criterio exclusión DIRAYS (incluido 15/09/2021)
  
  exclusion_dirays<-c("DIRAYS#MS - Dirección de integridad, responsabilidad administrativa y sumarios")
  movimientos.exp<-movimientos.exp %>%
    filter(!`Repartición actual` %in% exclusion_dirays)

  # movimientos.exp<- read_excel("2021-05-14 Facturas recibidas en trámite.xlsx", sheet = "Movimientos Exp")
  # nrow(movimientos.exp)
  
  #b)autogestion
  autogestion<- read_excel("bases/Detalle_formulario_crosstab.xlsx")
  autogestion$sist.origen <- "Ordenes de compra" 
  #autogestion<- read_excel("2021-05-14 Facturas recibidas en trámite.xlsx", sheet = "Autogestión")
  nrow(autogestion)
  names(autogestion)
  
  #c)financiamiento internacional
  facturas.fin.int<- read_excel("bases/Presentación_de_Facturas_Adquisiciones_con_Financi_crosstab.xlsx")
  facturas.fin.int$sist.origen <- "Financiamiento internacional" 
  #facturas.fin.int<- read_excel("2021-05-14 Facturas recibidas en trámite.xlsx", sheet = "FinInt")
  #fin.int no tiene importe ni moneda
  nrow(facturas.fin.int)
  #View(facturas.fin.int)
  
  ##completo los importes de los expedientes viejos
  #traigo la base con los importes viejos
  importesviejos.fin.int<- read_excel("2021-06-04 Facturas recibidas en trámite.xlsx",
                                      sheet = "FinInt")
  #selecciono las variables de interes
  importesviejos.fin.int<- importesviejos.fin.int[,
                                                  c("Número de expediente",
                                                    "Moneda...16",
                                                    "Importe")]
  #cambio el nombre de las variables
  names(importesviejos.fin.int)<-c("Número de expediente",
                                   "moneda.viejo","importe.viejo")
  #mezclo las bases
  facturas.fin.int.iv<-merge(facturas.fin.int ,importesviejos.fin.int, 
                             by="Número de expediente", all.x = T)
  
  #relleno los valores faltantes de moneda
  facturas.fin.int.iv$Moneda<-ifelse(is.na(facturas.fin.int.iv$Moneda),
                                     facturas.fin.int.iv$moneda.viejo, 
                                     facturas.fin.int.iv$Moneda)
  
  #relleno los valores faltantes de importe
  facturas.fin.int.iv$`Monto de factura` <-ifelse(is.na(facturas.fin.int.iv$`Monto de factura`),
                                                  facturas.fin.int.iv$importe.viejo, 
                                                  facturas.fin.int.iv$`Monto de factura`)
  
  #elimino las variables con los importes viejos que ya fueron agregados
  names(facturas.fin.int.iv)
  facturas.fin.int<-facturas.fin.int.iv[,c(-16,-17)]
  
  #d)sin ordenes de compra
  facturas.sin.oc<- read_excel("../FacturasEnTramite/bases/Presentación_de_facturas_no_amparadas_por_proceso_crosstab.xlsx")
  facturas.sin.oc$sist.origen <- "Legitimo abono" 
  #facturas.sin.oc <- read_excel("2021-05-14 Facturas recibidas en tramite.xlsx", sheet = "sinOC")
  #sin.oc ahora tiene importe y moneda, se agrego pero el campo no esta estructurado
  nrow(facturas.sin.oc)
  
  names(facturas.sin.oc)
  names(facturas.fin.int)
  names(autogestion)
  names(movimientos.exp)
  
  #2-Mezclo las bases 
  #a)tramitaciones con la de autogestion
  nrow(autogestion)
  nrow(movimientos.exp)
  mov.auto<-merge(movimientos.exp, autogestion, by = "Expediente")
  names(mov.auto)
  
  #b)tramitaciones con la de facturas sin OC
  nrow(facturas.sin.oc)
  nrow(movimientos.exp)
  mov.facsinoc<-merge(movimientos.exp, facturas.sin.oc,
                      by.x="Expediente", by.y="Número de expediente")
  nrow(mov.facsinoc)
  
  #c)tramitaciones con FINANCIAMIENTO INTERNACIONAL
  nrow(facturas.fin.int)
  nrow(movimientos.exp)
  mov.finint<-merge(movimientos.exp, facturas.fin.int,
                    by.x="Expediente", by.y="Número de expediente")
  nrow(mov.finint)
  
  #3-Stackeo las bases
  library(dplyr)
  #a)Selecciono las variables que me interesan de cada base
  #(i)mezcla con autogestion
  mezcla.auto<-mov.auto %>% 
    select(`Sistema creador`,sist.origen,`Estado expediente`, `Fecha de caratulación.x`,
           `Expediente`, `Tipo de comprobante`,
           `Importe total`,
           `Razón social proveedor`,
           `Repartición actual`, `Sector actual`, `Usuario actual`, 
           `Fecha de último pase`,
           `Nro de procedimiento de adquisición`, `Nro. orden de compra`)
  nrow(mezcla.auto)
  
  #(ii)mezcla con base de sin OC
  mezcla.sinoc<-mov.facsinoc %>% 
    select(`Sistema creador`,sist.origen,`Estado expediente`,`Fecha de caratulación.x`,
          `Expediente`, `Tipo de Comprobante`, 
          `Importe total`,
          `Razón Social`, 
          `Repartición actual`, `Sector actual`, `Usuario actual`, 
          `Fecha de último pase`)
  nrow(mezcla.sinoc)
  
  #(iii)mezcla con base de FINANCIAMIENTO INTERNAC
  #agrego las variables faltantes
  mov.finint$`Tipo de Comprobante`<-"Factura"
  mov.finint$`Importe total`<-mov.finint$`Monto de factura`
  mov.finint$`Razón Social`<-mov.finint$`Razón social`
  
  mezcla.finint<-mov.finint %>% 
    select(`Sistema creador`,sist.origen,`Estado expediente`,`Fecha de caratulación.x`,
           `Expediente`, `Tipo de Comprobante`, 
           `Importe total`,
           `Razón Social`, 
           `Repartición actual`, `Sector actual`, `Usuario actual`, 
           `Fecha de último pase`)
  nrow(mezcla.finint)
  
  #b)hago homogena las bases
  #(i)agrego las vs q no estan en la base de sin OC
  mezcla.sinoc$`Nro de procedimiento de adquisición`<-"Legitimo abono"
  mezcla.sinoc$`Nro. orden de compra`<-"Legitimo abono"
  
  #(ii)agrego las vs q no estan en la base de fin int
  mezcla.finint$`nro de procedimiento de adquisición`<- mov.finint$Proyecto
  mezcla.finint$`nro. orden de compra`<- mov.finint$Proyecto
    
  #(ii)paso los nombres a minuscula
  names(mezcla.auto)<-tolower(names(mezcla.auto))  
  names(mezcla.sinoc)<-tolower(names(mezcla.sinoc))  
  names(mezcla.finint)<-tolower(names(mezcla.finint))  
  
  names(mezcla.auto)
  #(iii)cambio el nombre de razon social q estaba diferente
  names(mezcla.auto)<-c("sistema creador","sist.origen","estado expediente", "fecha de caratulación.x",
                        "expediente", "tipo de comprobante",                
                        "importe total", "razón social",             
                        "repartición actual", "sector actual",                      
                        "usuario actual", "fecha de último pase",               
                        "nro de procedimiento de adquisición", "nro. orden de compra")
 
  #c)hago el rbind para stackear las variables
  mezcla.auto.sinoc<-rbind(mezcla.auto, mezcla.sinoc, mezcla.finint)
  nrow(mezcla.auto)
  #1172 1346 1339 1375 1420 1461
  nrow(mezcla.sinoc)
  #376 582 551 592 545 628
  nrow(mezcla.finint)
  #406 490 493 508 548 571
  nrow(mezcla.auto.sinoc)
  #1951 2418 2383 2474 2513 2660
  
  #4-Agrego o modifico variables
  #a)calculo los dias desde el ultimo pase
  hoy <- as.Date(Sys.Date(), format="%d/%m/%Y")
  mezcla.auto.sinoc$dias.desde.ultimo.pase <- 
    hoy - as.Date(mezcla.auto.sinoc$`fecha de último pase`, format="%d/%m/%Y")
  summary(as.numeric(mezcla.auto.sinoc$dias.desde.ultimo.pase))
  
  #b)calculo los dias desde el inicio
  hoy <- as.Date(Sys.Date(), format="%d/%m/%Y")
  mezcla.auto.sinoc$dias.desde.caratulacion <- 
    hoy - as.Date(mezcla.auto.sinoc$`fecha de caratulación.x`, format="%d/%m/%Y")
  summary(as.numeric(mezcla.auto.sinoc$dias.desde.caratulacion))
  
  #c)agrupo la variable ubicacion
  baseok<-mezcla.auto.sinoc %>% 
    mutate(ubicacion.actual = case_when(
      substr(`repartición actual`,1,5)=="DGPFE" ~ "DGPFE",
      substr(`repartición actual`,1,5)=="DAFYP" ~ "DGPFE",
      substr(`repartición actual`,1,4)=="DGAJ" ~ "DAL",
      substr(`repartición actual`,1,3)=="DAL" ~ "DAL",
      #substr(`repartición actual`,1,2)=="DS" ~ "DAL",
      substr(`repartición actual`,1,3)=="DGA" ~ "DGA",
      substr(`repartición actual`,1,4)=="DCYC" ~ "Compras",
      substr(`repartición actual`,1,4)=="SSGA" & substr(`sector actual`,1,3)=="CRD" ~ "CRD",
      substr(`repartición actual`,1,3)=="SGA" & substr(`sector actual`,1,3)=="CRD" ~ "CRD",
      substr(`repartición actual`,1,4)=="SSGA" & substr(`sector actual`,1,3)!="CRD" ~ "SGA",
      substr(`repartición actual`,1,3)=="SGA" & substr(`sector actual`,1,3)!="CRD" ~ "SGA",
      substr(`repartición actual`,1,4)=="DTYC" ~ "Contabilidad",
      substr(`repartición actual`,1,4)=="DCYT" ~ "Contabilidad",
      substr(`repartición actual`,1,4)=="RCTD" ~ "Ejercito Argentino",
      substr(`repartición actual`,1,2)=="DD" ~ "Despacho",
      substr(`repartición actual`,1,3)=="DSB" ~ "Programas",
      substr(`repartición actual`,1,3)=="DSD" ~ "Programas",
      substr(`repartición actual`,1,9)=="DSFYTT#MS" ~ "Programas",
      substr(`repartición actual`,1,3)=="DSO" ~ "RRHH",
      substr(`repartición actual`,1,3)=="DGO" ~ "DGA",
      substr(`repartición actual`,1,6)=="DGPYCP" ~ "Presupuesto",
      TRUE                      ~ "Programas")) 
  nrow(baseok)
  
   #d)Proveedores
  #importo la tabla de Denise
  proveedores<- read_excel("proveedores.xlsx")
  names(proveedores)
  
  proveedores<-as.data.frame(proveedores)
  ##paso todo a mayuscula y elimino puntos u otros characteres especiales
  proveedores[,1]<- toupper(gsub("[][!#$%()*,.:;<=>@^_`|~.{}]", "", proveedores[,1]))
  proveedores[,2]<- toupper(gsub("[][!#$%()*,.:;<=>@^_`|~.{}]", "", proveedores[,2]))
  #agrego una variable marca
  proveedores$base.den<-"base.den"
  nrow(proveedores)
  #387 389
  names(proveedores)
  
  #armo una base de proveedores con una lista de todos los q estan en mi base
  #unificandolos al oner el nombre en mayuscula
  proveedores.base<-as.data.frame(
    names(table(toupper(
      gsub("[][!#$%()*,.:;<=>@^_`|~.{}]", "",baseok$`razón social`)))))

  #agrego una variable marca
  proveedores.base$base.mia<-"base.mia"
  nrow(proveedores.base)
  #211 211
  #cambio el nombre de la variable para poderla mezclar
  names(proveedores.base)<-c("Razón Social","base.mia")
  
  #mezclo las tablas de proveedores y me quedo solo con las q estan en la base
  p<-merge(proveedores, proveedores.base, by="Razón Social", all.y = T)

  #miro cuales son las q no se les pego el formato limpio
  summary(as.factor(p$base.den))
  summary(as.factor(p$base.mia))
  #52 54 55
  
  #corrijo los q ya estan en la tabla y aparecen de una nueva forma
  p$`Razón Social_Clean`<-ifelse(p$`Razón Social`=="HELLMANN WORDWIDE LOGISTICS S.A.",
                                 "HELLMANN WORLDWIDE LOGISTICS SA",
                                 p$`Razón Social_Clean`)
  
  #completo los q estan vacios con el mismo valor
  p$`Razón Social_Clean`<-ifelse(is.na(p$`Razón Social_Clean`),
                                 p$`Razón Social`,
                                 p$`Razón Social_Clean`)
  
  #mezclo las tablas de proveedores y me quedo solo con las q estan en la base
  baseok$`razón social`<-toupper(gsub(
    "[][!#$%()*,.:;<=>@^_`|~.{}]", "",baseok$`razón social`))
  baseok.provok<-merge(baseok , p, 
                       by.x = "razón social", by.y="Razón Social", all.x = T)
  view(baseok)
  nrow(baseok.provok)
  unique(baseok.provok$`razón social`)
  #View(baseok.provok)
  
  #5-FILTRO LA BASE por criterios de seleccion y expedientes repetidos en la mezcla
  baseok.afiltrar <- baseok.provok %>% 
    mutate(filtro.reparticionysector = case_when(
      (substr(`repartición actual`,1,5)=="DAFYP" & 
         (`sector actual` =="ARCHIVO - Archivo" | `sector actual` =="PVD - Privada")) |
        ((substr(`repartición actual`,1,4)=="DTYC" | substr(`repartición actual`,1,4)=="DCYT") & 
           (`sector actual` =="TESORERIA - Tesorería"))  ~ "sacar",
      T ~ "ok")) %>% 
    mutate(filtro.comprobante = case_when(
      substr(`tipo de comprobante`,1,7)!="Factura" | is.na(`tipo de comprobante`)  ~ "sacar",
      T ~ "ok")) 
  nrow(baseok.afiltrar)
  
  baseok.afiltrar %>% 
    filter(filtro.reparticionysector=="sacar") %>% 
    group_by(`repartición actual`, `sector actual`) %>% 
    summarise(n())
  
  baseok.filtrada <-baseok.afiltrar %>% 
    filter(filtro.reparticionysector =="ok" & filtro.comprobante=="ok") %>% 
    group_by(expediente) %>% 
    slice(1)
  nrow(baseok.filtrada)

  # a<-baseok.filtrada %>%
  #   group_by(`Razón Social_Clean`) %>% 
  #   select(`Razón Social_Clean`) %>% 
  #   summarise(n())
  # 
  # view(a)
  #820
  #1001
  #1066
  #1046
  baseok.filtrada %>% 
    group_by(`repartición actual`,`sector actual`) %>% 
    summarise(n()) #%>% 
    #View()
  
  baseok.filtrada %>% 
    group_by(`repartición actual`,`sector actual`, `tipo de comprobante`) %>% 
    summarise(n()) # %>% 
    #View()
  
 #6-arreglo la variable de importe
  #A)CAMBIOS PUNTUALES
  baseok.filtrada$`importe total`<-ifelse(
    baseok.filtrada$expediente=="EX-2020-71078682-APN-DTYC#MS",
    2933529.947, baseok.filtrada$`importe total`)
  
  baseok.filtrada$`importe total`<-ifelse(
    baseok.filtrada$expediente=="EX-2020-89727018-APN-DTYC#MS",
    9101400, baseok.filtrada$`importe total`)
  
  baseok.filtrada$importe.moneda<-"xx"
  baseok.filtrada$importe.moneda<-ifelse(
    baseok.filtrada$expediente=="EX-2021-47797667-APN-DD#MS",
    "U$S", baseok.filtrada$importe.moneda)
  
  baseok.filtrada$importe.moneda<-ifelse(
    baseok.filtrada$expediente=="EX-2021-46705162-APN-DD#MS" |
      baseok.filtrada$expediente=="EX-2021-46710872-APN-DD#MS" |
      baseok.filtrada$expediente=="EX-2021-46719130-APN-DD#MS",
    "U$S", baseok.filtrada$importe.moneda)
  
  baseok.filtrada$importe.moneda<-ifelse(
    baseok.filtrada$expediente=="EX-2021-47028853-APN-DD#MS" |
      baseok.filtrada$expediente=="EX-2021-47578930-APN-DD#MS" |
      baseok.filtrada$expediente=="EX-2021-48583241-APN-DD#MS",
    "U$S", baseok.filtrada$importe.moneda)
  
  baseok.filtrada$importe.moneda<-ifelse(
    baseok.filtrada$expediente=="EX-2021-49895067-APN-DD#MS" |
      baseok.filtrada$expediente=="EX-2021-49898385-APN-DD#MS" |
      baseok.filtrada$expediente=="EX-2021-49903233-APN-DD#MS",
    "€", baseok.filtrada$importe.moneda)
  
  #B)CAMBIOS ESTRUCTURALES
  #(i)agrego el signo $ para los que no lo tienen
  baseok.filtrada$importe.ok<-ifelse(
    is.na(as.numeric(substr(baseok.filtrada$`importe total`,1,1))),
    baseok.filtrada$`importe total`,
    paste("$",baseok.filtrada$`importe total`,sep=" ")
    )
  #(ii)estandarizo los espacios en los signos $ yc
  baseok.filtrada$importe.ok<-ifelse(
    substr(baseok.filtrada$importe.ok,1,1)=="$",
    paste("$   ", substr(baseok.filtrada$importe.ok,3,20), sep=""),
    baseok.filtrada$importe.ok
  )
  baseok.filtrada$importe.ok<-ifelse(
    substr(baseok.filtrada$importe.ok,1,1)=="€",
    paste("€   ", substr(baseok.filtrada$importe.ok,3,20), sep=""),
    baseok.filtrada$importe.ok
  )
  
  #(iii)saco los separadores de coma
  baseok.filtrada$importe.ok<-gsub(",","",baseok.filtrada$importe.ok)
  
  #(iv)Selecciono los caracteres q hacen referencia a la moneda, para los q aun no tienen
  baseok.filtrada$importe.moneda<-ifelse(baseok.filtrada$importe.moneda=="xx",
                                         substr(baseok.filtrada$importe.ok,1,3), 
                                         baseok.filtrada$importe.moneda)
  
  #(v)hago el redondeo sin decimales
  baseok.filtrada$importe.monto<-round(as.numeric(substr(baseok.filtrada$importe.ok,5,20)),0) 
  
  #(vi)reviso valores faltantes en monto
  View(subset(baseok.filtrada,is.na(baseok.filtrada$importe.monto)))
  
  #reemplazo por el valor q esta ok
  baseok.filtrada$importe.monto<-ifelse(
    is.na(baseok.filtrada$importe.monto) & baseok.filtrada$importe.ok=="$   3.653.657.439507.",
    3657439, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    is.na(baseok.filtrada$importe.monto) & baseok.filtrada$expediente =="EX-2021-51705231-APN-DAFYP#MS",
    51787400, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    is.na(baseok.filtrada$importe.monto) & baseok.filtrada$expediente =="EX-2021-52665726-APN-DAFYP#MS",
    247287.6, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    is.na(baseok.filtrada$importe.monto) & baseok.filtrada$expediente =="EX-2021-52577533-APN-DD#MS",
    13287.31, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    is.na(baseok.filtrada$importe.monto) & baseok.filtrada$expediente =="EX-2021-52586329-APN-DD#MS",
    72067.11, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    is.na(baseok.filtrada$importe.monto) & baseok.filtrada$expediente =="EX-2021-54639137-APN-DD#MS",
    6405861.68, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    is.na(baseok.filtrada$importe.monto) & baseok.filtrada$expediente =="EX-2021-66201058-APN-DD#MS",
    250305, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    is.na(baseok.filtrada$importe.monto) & baseok.filtrada$expediente =="EX-2021-64021062-APN-DAFYP#MS",
    36633.72, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    is.na(baseok.filtrada$importe.monto) & baseok.filtrada$expediente =="EX-2021-58607137-APN-DAFYP#MS",
    340, baseok.filtrada$importe.monto)

  #CORRECCION PARA BAYER
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-62872754-APN-DCYT#MS",21736893.02, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-62900381-APN-DCYT#MS",14422375.81, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-62921697-APN-DCYT#MS",7383403.42, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-63836326-APN-DCYT#MS",28441238.18, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-65211542-APN-DCYT#MS",11687054.26, baseok.filtrada$importe.monto)
  #HELLMANN
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$`Razón Social_Clean`=="HELLMANN WORLDWIDE LOGISTICS SA" & baseok.filtrada$importe.ok =="$   143.349.00",
    143349, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$`Razón Social_Clean`=="HELLMANN WORLDWIDE LOGISTICS SA" & baseok.filtrada$importe.ok =="$   115.349.00",
    115349, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$`Razón Social_Clean`=="HELLMANN WORLDWIDE LOGISTICS SA" & baseok.filtrada$importe.ok =="$   207.550.90",
    207550.9, baseok.filtrada$importe.monto)
  #otros
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-70253264-APN-DNSMA#MS",1529.06, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-63993038-APN-DAFYP#MS", 29158, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-65994400-APN-DAFYP#MS", 734700, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-69452428-APN-DAFYP#MS", 517874, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-71352233-APN-DAFYP#MS", 105211, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-122773258-APN-DD#MS", 1534647, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-83971178-APN-DAFYP#MS", 32, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-122769870-APN-DD#MS",59435, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2021-122752609-APN-DD#MS",873569, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2022-6567423-APN-DD#MS",20810, baseok.filtrada$importe.monto)
  baseok.filtrada$importe.monto<-ifelse(
    baseok.filtrada$expediente =="EX-2022-1624446-APN-DD#MS",4621, baseok.filtrada$importe.monto)
  
  View(subset(baseok.filtrada,is.na(baseok.filtrada$importe.monto)))
#ok

#divididos por 100
baseok.filtrada$importe.monto<-ifelse(
  baseok.filtrada$importe.monto>99999999,
  baseok.filtrada$importe.monto/100, baseok.filtrada$importe.monto)

#EX-2021-70509695-APN-DAFYP#MS
#EX-2021-70519554-APN-DAFYP#MS
#EX-2021-61973901-APN-DCYT#MS

## saco los expedientes con acrónimo ordpago vista Facturas en trámite - Silvia Prieri
## en tableau documentos asociados a expedientes

tabla_ordpago<- read_excel("bases/Expedientes_crosstab_PRIERI.xlsx") %>% 
  select(1) %>% 
  rename("expediente" = Expediente)

baseok.filtrada <- baseok.filtrada %>% 
  anti_join(tabla_ordpago, by="expediente")
view(baseok.filtrada)

## correcciones a importe moneda

baseok.filtrada$importe.moneda<-ifelse(
  baseok.filtrada$expediente =="EX-2021-122773258-APN-DD#MS","$  ", baseok.filtrada$importe.moneda)
baseok.filtrada$importe.moneda<-ifelse(
  baseok.filtrada$expediente =="EX-2021-122752609-APN-DD#MS","$  ", baseok.filtrada$importe.moneda)
baseok.filtrada$importe.moneda<-ifelse(
  baseok.filtrada$expediente =="EX-2021-83971178-APN-DAFYP#MS","$  ", baseok.filtrada$importe.moneda)
baseok.filtrada$importe.moneda<-ifelse(
  baseok.filtrada$expediente =="EX-2021-122769870-APN-DD#MS","$  ", baseok.filtrada$importe.moneda)

#7-genero la tabla sabana de expedientes
#A)genero la tabla en dplyr

names(baseok.filtrada)
substr(baseok.filtrada$`fecha de caratulación.x`,1,10)
names(baseok.filtrada)

#######################################################################
#b) corrijo moneda montos 19.05.2022
#######################################################################

## traigo facturas financ externo
facturas.fin.int<- read_excel("bases/Presentación_de_Facturas_Adquisiciones_con_Financi_crosstab.xlsx") %>% 
  select (2,14,13) %>% 
  rename(`Importe total`=`Monto de factura`) %>%
  rename(`expediente`=`Número de expediente`) %>%
  distinct() 

## traigo facturas legítimo abono
facturas.sin.oc<- read_excel("../FacturasEnTramite/bases/Presentación_de_facturas_no_amparadas_por_proceso_crosstab.xlsx") %>% 
  select(2,11,12) %>% 
  rename(`expediente`=`Número de expediente`) %>%
  distinct()

names(facturas.fin.int)
names(facturas.sin.oc)
nrow(facturas.fin.int)
nrow(facturas.sin.oc)

## junto ambas bases legítimo abono y financ ext y armmo base de montos y monedas
base.montos.final<-rbind(facturas.sin.oc,facturas.fin.int) %>% 
  rename(Moneda.final=Moneda) %>% 
  rename(importe.final=`Importe total`) 
view(base.montos.final)

## uno base baseok.filtrada con la de base.montos.final
baseok.filtrada.final<-baseok.filtrada 

baseok.filtrada.final<-baseok.filtrada.final %>% 
  left_join(base.montos.final, by=c("expediente")) %>% 
  mutate(moneda.final.final=Moneda.final)

## corrio las monedas y unifico en pesos dolares y euros
baseok.filtrada.final$moneda.final.final [baseok.filtrada.final$moneda.final.final=="Peso Argentino (Argentina)"]<-"$"
baseok.filtrada.final$moneda.final.final [baseok.filtrada.final$moneda.final.final=="Afgani (Afganistán)"]<-"$"
baseok.filtrada.final$moneda.final.final [baseok.filtrada.final$moneda.final.final=="Dólar Estadounidense (Estados Unidos)"]<-"U$S"
baseok.filtrada.final$moneda.final.final [baseok.filtrada.final$moneda.final.final=="USD"]<-"U$S"
baseok.filtrada.final$moneda.final.final [baseok.filtrada.final$moneda.final.final=="Euro (Alemania)"]<-"€"
baseok.filtrada.final$moneda.final.final [baseok.filtrada.final$moneda.final.final=="Euro (Austria)"]<-"€"
baseok.filtrada.final$moneda.final.final [baseok.filtrada.final$moneda.final.final=="Euro (Países Bajos)"]<-"€"
baseok.filtrada.final$moneda.final.final [baseok.filtrada.final$moneda.final.final=="$"]<-"$"
baseok.filtrada.final$moneda.final.final [is.na(baseok.filtrada.final$moneda.final.final)]<-"$"

baseok.filtrada.final$importe.final_dos<-round(as.numeric(baseok.filtrada.final$importe.final),0) 
baseok.filtrada.final$monto.final.final<-ifelse(is.na(baseok.filtrada.final$importe.monto),baseok.filtrada.final$importe.final_dos,baseok.filtrada.final$importe.monto)

## armo base con exped duplicados
expe.dupli<-baseok.filtrada.final %>%
  group_by(expediente) %>% 
  summarise("cantidad"=n()) 

## unifico base y me quedo con un sola fila por exped
base.filrada.final.final<-baseok.filtrada.final %>% 
  left_join(expe.dupli, by=c("expediente")) %>%
  filter(cantidad==2 & !is.na(importe.final_dos) | cantidad==1)

## armo tabla sabana
tabla.sabana <- base.filrada.final.final %>% 
  mutate(fecha.caratulacion=substr(`fecha de caratulación.x`,1,10)) %>% 
  mutate(dias.desde.ultimo.pase.num=as.numeric(dias.desde.ultimo.pase)) %>% 
  mutate(dias.desde.caratulacion.num=as.numeric(dias.desde.caratulacion)) %>% 
  mutate(monto.en.pesos = case_when(moneda.final.final=="$" ~ monto.final.final,
                                    moneda.final.final=="U$S" ~ monto.final.final*117.5,
                                    moneda.final.final=="€" ~ monto.final.final*120.0)) %>% 
  select(#`sistema creador`, 
    sist.origen, `sector actual`,`estado expediente`, ubicacion.actual,
    fecha.caratulacion, expediente, `nro. orden de compra`,
    `Razón Social_Clean`,
    `repartición actual`, 
    `usuario actual`, 
    moneda.final.final, monto.final.final,monto.en.pesos, dias.desde.ultimo.pase.num,
    dias.desde.caratulacion.num) %>% 
  group_by(#`sector actual`, 
    expediente) 

#B) le doy formato a la tabla
names(tabla.sabana)<-c("Sist. de origen", "Sector actual","Estado expediente","Ubicación actual",
                       "Fecha de caratulación", "Expediente", "Orden de compra",
                       "Razón social",
                       "Repartición actual", "Usuario actual", 
                       "Moneda", "Monto","Monto en $","Días desde último pase",
                       "Días desde la caratulación")

### armo tabla resumen
tabla.resumen <- base.filrada.final.final %>% 
  mutate(monto.en.pesos = case_when(moneda.final.final=="$" ~ monto.final.final,
                                    moneda.final.final=="U$S" ~ monto.final.final*117.5,
                                    moneda.final.final=="€" ~ monto.final.final*120.0)) %>%  
  select(`repartición actual` , `usuario actual`, 
         monto.en.pesos, dias.desde.ultimo.pase) %>% 
  group_by(`repartición actual` 
           ,`usuario actual`
  ) %>% 
  summarise( cantidad.facturas=n(),
             promedio.dias.up = round(mean(dias.desde.ultimo.pase),0),
             monto.en.pesos = sum(monto.en.pesos, na.rm = T)
  )
nrow(tabla.resumen)


#B) le doy formato a la tabla
names(tabla.resumen)<-c("Repartición actual", "Usuario actual", "Cantidad de facturas",
                        "Promedio de días desde el ultimo pase", 
                        "Monto total de las facturas en $")
#paso a numerica la variable dias
tabla.resumen$`Promedio de días desde el ultimo pase`<-as.numeric(
  tabla.resumen$`Promedio de días desde el ultimo pase`)

#9-guardo las tablas
library(R.utils)
saveObject(tabla.sabana, "tablas/tabla.sabana.Rbin")
saveObject(tabla.resumen, "tablas/tabla.resumen.Rbin")

