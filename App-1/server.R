library(shiny)
library(ggplot2)
library(gridExtra)
library(zoo)
library(plyr)
library(grid)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  #t <- read.table("http://nwis.waterdata.usgs.gov/mi/nwis/uv?cb_00010=on&cb_00055=on&format=rdb&site_no=04157005&period=&begin_date=2015-01-01&end_date=2016-01-01", comment.char='#', sep="\t", header=TRUE)
  t <- read.table("C:\\Users\\Alex\\Desktop\\2015.tab", comment.char='#', sep="\t", header=TRUE)
  t <- t[-1,]
  t[,c("datetime","X01_00010","X11_00055")]
  t$datetime <- strptime(t$datetime, "%Y-%m-%d %H:%M", tz="EST") 
  t$temperature <- as.double( as.character( t$X01_00010 ) )
  t$temperature <- na.locf(t$temperature)
  t$flowRate <- as.double( as.character( t$X11_00055 ) )
  t$flowRate <- na.locf(t$flowRate)
  t$date <- as.Date(t$datetime)
  d <- ddply(t, "date", summarize, meanTemp = mean(temperature), meanFlow = mean(flowRate) )
  BASE <- 15
  d$gdd <- sapply(d$meanTemp , FUN = function(v) max( c( v - BASE, 0) ) )
  d$cgdd <- cumsum(d$gdd)
  INCUBATION_TIME <- 200
  d$reqLenKm <- 3.6*d$meanFlow*INCUBATION_TIME
  
  warnMsg <- textGrob("no risk", gp = gpar(fontsize = 50))
  
  output$distPlot <- renderPlot({
    
    t0 <- strptime("2015-01-01 00:00", "%Y-%m-%d %H:%M", tz="EST")
    start <- t0 + input$range[1] * 24*60*60
    end <- t0 + input$range[2] * 24*60*60
    twin <- t[(t$datetime > start) & (t$datetime < end),]
    dwin <- d[d$date > as.Date(start) & d$date < as.Date(end),]
    
    temperature <- ggplot(twin,aes(x=datetime,y=temperature)) + ylim(-2, 30) + geom_line(colour="red") 
    speed <- ggplot(twin,aes(x=datetime,y=flowRate)) + ylim(0, 3) + geom_line(colour="blue") + geom_hline(yintercept = 0.7, linetype="dashed" )
    gddline <- ggplot(dwin,aes(x=date,y=cgdd)) + ylim(0, 1000) + geom_line() + 
      geom_hline(yintercept = 650, linetype="dashed" ) + 
      geom_hline(yintercept = 900, linetype="dashed" )
    #reqLen <- ggplot(dwin,aes(x=date,y=reqLenKm)) + geom_bar(stat = "identity", fill = "green", colour = "black")
    if ( tail(dwin$cgdd,n=1) > 650 ) {
      warnMsg <- textGrob("Medium Risk", gp = gpar(fontsize = 100, col = "orange"))
    } 
    if ( tail(dwin$cgdd,n=1) > 900 ) {
      warnMsg <- textGrob("HIGH RISK", gp = gpar(fontsize = 100, col = "red"))
    } 
    grid.arrange( temperature, gddline, speed, warnMsg, ncol=2 )
    
  })
})
