library(shiny)
library(leaflet)
library(ggmap)
library(rgdal)
library(RColorBrewer)
library(dplyr)
library(reshape)

# Load data
map_centre <- geocode("Leeds")
#pedallers <- geocode("Mabgate Green")
l <- readRDS("al.Rds")

l$color <- "green"
l$color[grepl("fast", rownames(l@data))] <- "red"

lfast <- l[ l$color == "green", ]
lquiet <- l[ l$color == "red", ]

flows <- read.csv("al-flow.csv")
leeds <- readRDS("leeds-msoas-simple.Rds") %>%
  spTransform(CRS("+init=epsg:4326"))

# Add census data to leeds
ldata <- read.csv("leeds-msoa-data.csv")
names(ldata)[names(ldata)=="CODE"] <- "geo_code"
ldata <- inner_join(leeds@data, ldata)
leeds@data <- ldata
leeds$color_pcycle <- cut(leeds$pCycle, breaks = quantile(leeds$pCycle), labels = brewer.pal(4, "PiYG") )

shinyServer(function(input, output, session){

cents <- coordinates(leeds)
cents <- SpatialPointsDataFrame(cents, data = leeds@data, match.ID = F)
observe({
   
   geojson <- RJSONIO::fromJSON(sprintf("%s.geojson", input$feature))
   
   # Create a leaflet instance without any transport layers (fast or slow lanes)
   m <- leaflet() %>%
     addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png")  %>%
     addCircleMarkers(data = cents
                      , radius = 2
                      , color = "black"
                      , popup = sprintf("<b>Journeys by bike: </b>%s%%", round(ldata$pCycle*100,2))) %>%
     addGeoJSON(geojson) %>%
     #addPopups(pedallers$lon, pedallers$lat, "The best bike shop in Leeds!") %>%
     mapOptions(zoomToLimits = "first") 
     #%>%
     #addPolylines(data = lfast, color = "red"
    #              , opacity = input$transp_fast
    #              , popup = sprintf("<dl><dt>Distance </dt><dd>%s km</dd><dt>Journeys by bike</dt><dd>%s%%</dd>", round(flows$fastest_distance_in_m / 1000, 1), round(flows$p_cycle * 100, 2))
    # ) %>%
    # addPolylines(data = lquiet, color = "green",
    #              , opacity = input$transp_fast, 
    #              popup = sprintf("<dl><dt>Distance </dt><dd>%s km</dd><dt>Journeys by bike</dt><dd>%s%%</dd>", round(flows$quietest_distance_in_m / 1000, 1), round(flows$p_cycle*100,2))
    # )
   
   if (input$layers == FALSE){
     updateSliderInput(session, "transp_zones", value = 0, min = 0, max = 1)       
     updateSliderInput(session, "transp_fast", value = 0, min = 0, max = 1)  
     
   }else {
     
     updateSliderInput(session, "transp_zones", value = input$transp_zones, min = 0, max = 1)       
     updateSliderInput(session, "transp_fast", value = input$transp_fast, min = 0, max = 1)
     
     ## Only add polygones (of MSOA boundaries) and also of route when 'show layers' is set to TRUE
     m <- m %>%
       addPolygons(data = leeds
                   , fillOpacity = 0.4
                   , opacity = input$transp_zones
                   , fillColor = leeds$color_pcycle
                   
       ) %>%
       addPolylines(data = lfast, color = "red"
                    , opacity = input$transp_fast
                    , popup = sprintf("<dl><dt>Distance </dt><dd>%s km</dd><dt>Journeys by bike</dt><dd>%s%%</dd>", round(flows$fastest_distance_in_m / 1000, 1), round(flows$p_cycle * 100, 2))
       ) %>%
       addPolylines(data = lquiet, color = "green",
                    , opacity = input$transp_fast, 
                    popup = sprintf("<dl><dt>Distance </dt><dd>%s km</dd><dt>Journeys by bike</dt><dd>%s%%</dd>", round(flows$quietest_distance_in_m / 1000, 1), round(flows$p_cycle*100,2))
      )
   }
 
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
