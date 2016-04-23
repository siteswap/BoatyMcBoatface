library(shiny)
library(ggplot2)
library(gridExtra)
library(zoo)
library(plyr)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  t <- read.table("http://waterdata.usgs.gov/mi/nwis/uv?cb_00055=on&cb_00010=on&format=rdb&site_no=04119400&period=&begin_date=2016-01-01&end_date=2016-04-23", comment.char='#', sep="\t", header=TRUE)
  t <- t[-1,]
  t$datetime <- strptime(t$datetime, "%Y-%m-%d %H:%M", tz="EST") 
  t$temperature <- as.double( as.character( t$X06_00010 ) )
  t$flowRate <- as.double( as.character( t$X04_00055 ) )
  t$date <- as.Date(t$datetime)
  d <- ddply(t, "date", summarize, meanTemp = mean(temperature) )
  BASE <- 10
  d$gdd <- sapply(d$meanTemp , FUN = function(v) max( c( v - BASE, 0) ) )
  d$gdd <- na.locf(d$gdd)
  d$cgdd <- cumsum(d$gdd)
  

  output$distPlot <- renderPlot({
    
    t0 <- strptime("2016-01-01 00:00", "%Y-%m-%d %H:%M", tz="EST")
    start <- t0 + input$range[1] * 24*60*60
    end <- t0 + input$range[2] * 24*60*60
    twin <- t[(t$datetime > start) & (t$datetime < end),]
    dwin <- d[d$date > as.Date(start) & d$date < as.Date(end),]
    
    temperature <- ggplot(twin,aes(x=datetime,y=temperature)) + ylim(-2, 20) + geom_line(colour="red")
    speed <- ggplot(twin,aes(x=datetime,y=flowRate)) + ylim(0, 2) + geom_line(colour="blue")
    gddline <- ggplot(dwin,aes(x=date,y=cgdd)) + geom_line()
    grid.arrange( temperature, speed, gddline ) # , ncol=2 )
    

  })
})
