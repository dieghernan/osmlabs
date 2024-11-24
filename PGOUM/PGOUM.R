library(sf)
library(tidyverse)
library(leaflet)
library(mapSpain)


viales <- read_sf("PGOUM/data/CALZADAS.shp") %>%
  st_zm() %>%
  st_transform(4326) %>%
  select(Distrito, Calles, RedViaria)

viales %>%
  st_drop_geometry() %>%
  count(RedViaria) %>%
  arrange((n))



metropol <- viales %>%
  filter(RedViaria == "METROPOLITANA")

urbana <- viales %>%
  filter(RedViaria == "URBANA")

distrital <- viales %>%
  filter(RedViaria == "DISTRITAL")

local <- viales %>%
  filter(RedViaria == "LOCAL")

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
    data = metropol, color = "red",
    fillOpacity = 1,
    label = ~Calles,
    group = "Metropolitana"
  ) %>%
  addControl(html = "Source: <a href='https://geoportal.madrid.es/IDEAM_WBGEOPORTAL/dataset.iam?id=4469e28e-d326-11eb-9e62-98fc84ef8cb9'>Geoportal del Ayuntamiento de Madrid</a>", position = "bottomright") %>%
  addPolylines(
    data = urbana, color = "orange", group = "Urbana",
    label = ~Calles,
    fillOpacity = 1
  ) %>%
  addPolylines(
    data = distrital, color = "yellow", fillOpacity = 1,
    label = ~Calles,
    group = "Distrital"
  ) %>%
  addPolylines(
    data = local, color = "black", fillOpacity = 1,
    label = ~Calles,
    group = "Local"
  ) %>%
  addLayersControl(
    baseGroups = c(
      "OSM (Mapnik)",
      "IGN Base Gris",
      "PNOA"
    ),
    overlayGroups = c("Metropolitana", "Urbana", "Distrital", "Local"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addLegend(
    colors = c("red", "orange", "yellow", "black"),
    labels = c("Metropolitana", "Urbana", "Distrital", "Local")
  )




htmlwidgets::saveWidget(m, "PGOUM/index.html",
  selfcontained = FALSE,
  libdir = "deps",
  title = "PGOUM: Red Estructurante"
)

# Export

ls <- list.files("PGOUM/dist", full.names = TRUE)

unlink(ls)

st_write(metropol, "PGOUM/dist/metropol.geojson")
st_write(urbana, "PGOUM/dist/urbana.geojson")
st_write(distrital, "PGOUM/dist/distrital.geojson")
st_write(local, "PGOUM/dist/local.geojson")

