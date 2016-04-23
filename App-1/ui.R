library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Minority Report for Carp"),

  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(

      # Specification of range within an interval
      sliderInput("range", "Range:",
                  min = 0,
                  max = 120,
                  animate = TRUE,
                  value = c(0,30))
      
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot")
    )
  )
))
