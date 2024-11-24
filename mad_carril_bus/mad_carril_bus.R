library(sf)
library(tidyverse)
library(leaflet)
library(mapSpain)


viales <- read_sf("PGOUM/data/CALZADAS.shp") %>%
  st_zm() %>%
  st_transform(4326)

cbus <- viales %>%
  filter(Car_Bus == "SI") %>%
  select(Calles)

# Señales

sign <- read_delim("~/R/Projects/señalizacion_vertical.csv", 
                   locale = locale(decimal_mark = ",", 
                                   grouping_mark = "."),
                   delim = ";", escape_double = FALSE, trim_ws = TRUE)

db <- sign %>%
  select(`Tipo de Señalización`, Código, Descripción) %>%
  distinct() %>%
  filter(str_detect(Descripción, "Carril")) %>%
  filter(str_detect(Descripción, "bus|Bus")) 

signbus <- sign %>%
  filter(Código %in% db$Código) %>%
  filter(is.na(`Fecha de Baja`)) 
signgeo <- signbus %>%
  st_as_sf(coords = c("Gis_X", "Gis_Y"), crs = st_crs(25830)) %>%
  st_transform(4326)


m <- leaflet() %>%
  addTiles(
    options = tileOptions(opacity = 1),
    layerId = "OSM (Mapnik)",
    group = "OSM (Mapnik)"
  ) %>%
  addProviderEspTiles(
    provider = "IGNBase.Gris",
    group = "IGN Base Gris"
  ) %>%
  addProviderEspTiles(provider = "PNOA", group = "PNOA") %>%
  addMarkers(data = signgeo, label = ~Barrio) %>%
  addLayersControl(
    baseGroups = c(
      "OSM (Mapnik)",
      "IGN Base Gris",
      "PNOA"
    ),
    overlayGroups = c("Carril Bus"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addControl(html = "Source: <a href='https://geoportal.madrid.es/IDEAM_WBGEOPORTAL/dataset.iam?id=4469e28e-d326-11eb-9e62-98fc84ef8cb9'>Geoportal del Ayuntamiento de Madrid</a>", position = "bottomright")


htmlwidgets::saveWidget(m, "mad_carril_bus/index.html",
  selfcontained = FALSE,
  libdir = "deps",
  title = "PGOUM 2021: Carril Bus"
)

st_write(signgeo,"mad_carril_bus/sign.geojson")

