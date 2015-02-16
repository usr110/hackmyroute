library(shiny)
library(leaflet)
library(ggmap)
library(rgdal)
library(RColorBrewer)
library(dplyr)
library(reshape)

#setwd('~/R Studio Projects/hackmyroute/fixMyPath') # go into the directory if running in rstudio

# Load data
map_centre <- geocode("Leeds")
pedallers <- geocode("Mabgate Green")
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
  # df <- rename(df,c('foo'='samples'))
  #ldata <- rename(ldata, geo_code = CODE)
  names(ldata)[names(ldata)=="CODE"] <- "geo_code"
  #ldata <- rename(ldata,c('CODE' = 'geo_code'))
  ldata <- inner_join(leeds@data, ldata)
  leeds@data <- ldata
  leeds$color_pcycle <- cut(leeds$pCycle, breaks = quantile(leeds$pCycle), labels = brewer.pal(4, "PiYG") )


shinyServer(function(input, output, session){
#cat(input$myMap_zoom)
  
cents <- coordinates(leeds)
cents <- SpatialPointsDataFrame(cents, data = leeds@data, match.ID = F)

# Create the map; this is not the "real" map, but rather a proxy
# object that lets us control the leaflet map on the page.
#map <- createLeafletMap(session, 'map')

#map <- leaflet(leeds) %>% addTiles()

#observe({
  
#  geojson <- RJSONIO::fromJSON(sprintf("%s.geojson", input$feature))
  
#map %>%
#  addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png") %>%
#  addPolygons(data = leeds
#              , fillOpacity = 0.4
#              , opacity = input$transp_zones
#              , fillColor = leeds$color_pcycle
#              
#  ) %>%
#  addPolylines(data = lfast, color = "red"
#               , opacity = input$transp_fast
#               , popup = sprintf("<dl><dt>Distance </dt><dd>%s km</dd><dt>Journeys by bike</dt><dd>%s%%</dd>", round(flows$fastest_distance_in_m / 1000, 1), round(flows$p_cycle * 100, 2))
#  ) %>%
#  addPolylines(data = lquiet, color = "green",
#               , opacity = input$transp_fast, popup = sprintf("<dl><dt>Distance </dt><dd>%s km</dd><dt>Journeys by bike</dt><dd>%s%%</dd>", round(flows$quietest_distance_in_m / 1000, 1), round(flows$p_cycle*100,2))
#  ) %>%
#  addCircleMarkers(data = cents
#                   , radius = 2
#                   , color = "black"
#                   , popup = sprintf("<b>Journeys by bike: </b>%s%%", round(ldata$pCycle*100,2))) %>%
#  addGeoJSON(geojson) %>%
#  addPopups(pedallers$lon, pedallers$lat, "The best bike shop in Leeds!") 
#})
  z <- 0
  observe({
    # Take a dependency on input$map_zoom
    input$map_zoom
    # Use isolate() to avoid dependency on input$map_zoom
    z <- isolate(
      input$map_zoom      
    )
    cat('zoom : ', z, '\n')
  })

 # input$map %>% setView(lng = input$myMap_click$lng, lat = input$myMap_click$lat, zoom = input$myMap_zoom)
 
 observe({
   #cat(input$myMap_zoom, "\n")
   #cat('lat', input$myMap_click$lat, "\n")
   #cat(input$myMap_click$lat, "\n")
   #cat('lat : ', mean(c(input$map_bounds$north, input$map_bounds$south)))
   #cat('zoom : ', local_zoom)
   #if (is.reactivevalues(input$map_zoom)){
  #   cat(' i am  here ')
   #}
   # Take a dependency on input$goButton
   #input$map
      
   #lat <- isolate(mean(c(input$map_bounds$north, input$map_bounds$south)))
   #lat <- isolate(mean(c(input$map_bounds$north, input$map_bounds$south)))
   #lng <- isolate(mean(c(input$map_bounds$east, input$map_bounds$west)))
   #zoom <- isolate(input$map_zoom)
   
   
   
   if (input$layers == FALSE){
     updateSliderInput(session, "transp_zones", value = 0, min = 0, max = 1)       
     updateSliderInput(session, "transp_fast", value = 0, min = 0, max = 1)       
   }else {
     updateSliderInput(session, "transp_zones", value = input$transp_zones, min = 0, max = 1)       
     updateSliderInput(session, "transp_fast", value = input$transp_fast, min = 0, max = 1)       
     
   }
   
   geojson <- RJSONIO::fromJSON(sprintf("%s.geojson", input$feature))
          # setView(lng = map_centre[1], lat = map_centre[2], zoom = 10)

   output$map = renderLeaflet(
     
     leaflet() %>%
     addTiles(urlTemplate = "http://{s}.tile.thunderforest.com/cycle/{z}/{x}/{y}.png") %>%
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
                  , opacity = input$transp_fast, popup = sprintf("<dl><dt>Distance </dt><dd>%s km</dd><dt>Journeys by bike</dt><dd>%s%%</dd>", round(flows$quietest_distance_in_m / 1000, 1), round(flows$p_cycle*100,2))
                  ) %>%
     addCircleMarkers(data = cents
                , radius = 2
                , color = "black"
                , popup = sprintf("<b>Journeys by bike: </b>%s%%", round(ldata$pCycle*100,2))) %>%
     addGeoJSON(geojson) %>%
     addPopups(pedallers$lon, pedallers$lat, "The best bike shop in Leeds!") 
      ##%>%
      # #setView(lng = input$lng, lat = input$lat, zoom = input$myMap_zoom)
      #setView(lng = input$myMap_click$lng, lat = input$myMap_click$lat, zoom = input$myMap_zoom)
        
  )
 })

  output$desc <- reactive({
    if (is.null(input$map_bounds))
      return(list())
    list(
      lat = mean(c(input$map_bounds$north, input$map_bounds$south)),
      lng = mean(c(input$map_bounds$east, input$map_bounds$west)),
      zoom = input$map_zoom
    )
  })

  output$feature <- reactive({
    lat = mean(c(input$map_bounds$north, input$map_bounds$south))
    lng = mean(c(input$map_bounds$east, input$map_bounds$west))
    zoom = input$map_zoom
    cat(lat, ' : ' , lng , ' : ', zoom )
  })

  #observe({
  #  if (input$layers == FALSE){
  #    updateSliderInput(session, "transp_zones", value = 0, min = 0, max = 1)       
  #    updateSliderInput(session, "transp_fast", value = 0, min = 0, max = 1)       
  #  }
  #})

  output$layers <- reactive({
    if (input$layers == FALSE){
      cat("the checkbox is off \n")
      #updateSliderInput(session, "transp_zones", value = 0, min = 0, max = 1)       
      #updateSliderInput(session, "transp_fast", value = 0, min = 0, max = 1) 
      
    }
    
  })
})

