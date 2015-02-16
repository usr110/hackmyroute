library(shiny)
library(ShinyDash)
library(leaflet)
fluidPage(
  titlePanel("FixMyPath"),
  sidebarLayout(
    sidebarPanel("User input", width = 3 , 
       checkboxInput("layers", "Show Layers", TRUE)
      ,  sliderInput("transp_zones", label = "Transparency of zone boundaries", min = 0, max = 1, value = 0)
      , sliderInput("transp_fast", label = "Transparency of paths", min = 0, max = 1, value = 0)
      , selectInput("viewout", "Output to view", choices = c("Highest cycle counts", "Lowest number who cycle", "Highest potential", "Greatest extra cycling potential"))
      , selectInput("feature", "Features", choices = c("none", "cycleparking", "collisions", "bikeshopsp"))
      , htmlWidgetOutput(
        outputId = 'desc',
        HTML(paste(
          'The map is centered at <span id="lat"></span>, <span id="lng"></span>',
          'with a zoom level of <span id="zoom"></span>.<br/>'
        ))
      )
    ),
    mainPanel(
     leafletOutput('map', height = 600)
    )
  ))