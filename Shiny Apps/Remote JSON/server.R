library(shiny)
library(leaflet)
library(ggmap)
library(rgdal)
library(RColorBrewer)
library(dplyr)
library(reshape)

shinyServer(function(input, output, session){
  observe({
   geojson <- RJSONIO::fromJSON('https://raw.githubusercontent.com/cesaregerbino/DatiGeo/master/ScuoleTorino.geojson')

   m <- leaflet() %>%
     addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png")  %>%
     addGeoJSON(geojson) %>%
     setView(lat = 45.1, lng = 7.7, zoom = 12) %>%
     mapOptions(zoomToLimits = "first")

   output$map = renderLeaflet(m)

})

output$desc <- reactive({
  if (is.null(input$map_bounds))
    return(list())
  list(
    lat = round(mean(c(input$map_bounds$north, input$map_bounds$south)), 1),
    lng = round(mean(c(input$map_bounds$east, input$map_bounds$west)), 1),
    zoom = input$map_zoom
  )
})


})
