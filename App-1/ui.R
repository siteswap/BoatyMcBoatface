library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  
  # Sidebar with a slider input for the number of bins
  verticalLayout(
    # Application title
    titlePanel("Minority Report for Carp"),
    plotOutput("distPlot", height = "1000px"),
    wellPanel(

      # Specification of range within an interval
      sliderInput("range", "Range:",
                  min = 0,
                  max = 365,
                  animate = TRUE,
                  value = c(0,30))
      
    )
    #sidebarPanel("FUTURE CRIMINAL:", img(src = "C:/Users/Alex/git/BoatyMcBoatface/App-1/grasscarp_adult.jpg")),
    # Show a plot of the generated distribution

  )
))

