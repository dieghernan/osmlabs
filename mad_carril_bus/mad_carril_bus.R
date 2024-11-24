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
  addPolylines(
    data = cbus,
    fillOpacity = 1,
    group = "Carril Bus"
  ) %>%
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
