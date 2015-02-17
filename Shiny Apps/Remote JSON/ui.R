library(shiny)
library(ShinyDash)
library(leaflet)
fluidPage(
  titlePanel("Remote Geo JSON"),
  sidebarLayout(
    sidebarPanel("User input", width = 3
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