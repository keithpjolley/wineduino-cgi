options(warn=-1)
suppressPackageStartupMessages(library(RMySQL))
suppressPackageStartupMessages(library(reshape))
suppressPackageStartupMessages(library(ggplot2))

getdata<-function(interval_local) {
  dbname <- c('sensormatic')
  user   <- c('sensormatic')
  passwd <- c('SenSei')
  table  <- c('wino')
  drv    <- dbDriver('MySQL')
  #
  sql<-paste("SELECT * FROM", table, "WHERE thetime >= DATE_SUB(NOW(), INTERVAL", interval_local, ") AND thetime >= '2013-07-07 18:00:00' ")
  con = dbConnect(drv, dbname=dbname, user=user, pass=passwd)
  df<-dbGetQuery(con, statement=sql)  # this is going to create an error - ignore it. 
  foo<-dbDisconnect(con)
  df$thetime <- as.POSIXlt(df$thetime, format="%Y-%m-%d %H:%M:%S") # this fixes the warning above.
  #
  df$humidity_A<-NULL
  df$humidity_B<-NULL
  df$temp_c_A  <-NULL
  df$temp_c_B  <-NULL
  df$temperature_celsius<-NULL
  df$milliseconds_now   <-NULL
  df$milliseconds_before<-NULL
  df$milliseconds_after <-NULL
  #
  # bring the photocell and infrared values inline with the temp and humidity for graphing
  N <- 20
#  df$infrared  <- 100*df$infrared/max(df$infrared)
  df$infrared  <- ifelse(df$infrared > 360, 75, 50)
  #df$infrared  <- (df$infrared  %/%N)*N - 5  # round to the nearest N
  df$photocell <- NULL  # the photocell is foobar right now.  just reports noise. :/
  #df$photocell <- 100*df$photocell/max(df$photocell)
  #df$photocell <- (df$photocell %/%N)*N + 5  # round to the nearest N
  #
  df<-melt(df,id=c("thetime"))
  #
  return(df)
}

plotit<-function(interval_local, title_local, name_local) {
  df<-getdata(interval_local)
  p<-ggplot(df, aes(x=thetime,y=value,colour=variable))
  p<-p+geom_point(size=1)
  p<-p+geom_smooth(size=0.5)
  p<-p+ggtitle(title_local)
  #p<-p+scale_x_discrete(name="")
  p<-p+xlab("")
  p<-p+ylab("")
  p<-p+scale_colour_discrete(
      name="",
      breaks=c("humidity", "temperature_fahrenheit", "infrared"),
      labels=c("Humidty (%)","Temperature (°F)","Door State")
    )
  # print a large version
  filename<-paste("../images/", name_local, "_large.png", sep="")
  png(filename=filename, width=1250, height=750, bg="white")
  print(p)
  foo<-dev.off()
  # and a small version
  filename<-paste("../images/", name_local, "_small.png", sep="")
  png(filename=filename, width=1000, height=200, bg="white")
  print(p)
  foo<-dev.off()
}
