library(latex2exp)

filePath = "data/"
files = list.files(filePath)
dataFiles = files[grepl("data",files)]
dataFrames = list()

for (i in 1:length(dataFiles)){
  file = dataFiles[i]
  dataFile = paste0(filePath,file)
  print(dataFile)
  dataFrames[[i]] = read.csv(dataFile, row.names = NULL)
}

dataFrame = do.call("rbind",dataFrames)

typeColors = c(
  rgb(0,0.0,1),
  rgb(0,0.7,0),
  rgb(0,0.0,0)
  
)
eqColors = c(
  rgb(0,0.0,1,0.2),
  rgb(0,0.7,0,0.2),
  rgb(0,0.0,0,0.2)
)

eqV1 = c(2,3.5,0,1)/5
eqV2 = c(5,3.5,3,1)/5
eqV = c(7,7,3,2)/10


plotByType = function(treatment) {
  df = dataFrame[dataFrame$treatment==treatment,]
  R0 = mean(df$R0)
  cd1 = mean(df$cd[df$type==1])
  cd2 = mean(df$cd[df$type==2])
  v1 = rep(NA,60)
  v2 = rep(NA,60)
  v = rep(NA,60)
  for(i in 1:60) {
    v1[i] = mean(df$v[df$type==1 & df$period==i])
    v2[i] = mean(df$v[df$type==2 & df$period==i])
  }
  graphics.off()
  windows(7,5)
  par(mar=c(3,3,4,3),xpd=TRUE)
  plot(-1,xlim=c(1,60),ylim=c(0,1),axes=FALSE,xlab='',ylab='')
  axis(1,pos=0)
  axis(2,pos=0)
  mainString = r'(Vaccination Rate by Type ($R_0 = %.1f, c^D_1 = %.0f, c^D_2 = %.0f$) )'
  mainTex = sprintf(mainString, R0,cd1,cd2)
  mainExp = TeX(mainTex)
  title(main=mainExp)
  lines(v1,lwd=2,col=typeColors[1],lty='31')
  lines(v2,lwd=2,col=typeColors[2],lty='31')
  segments(x0=1,x1=60,y0=eqV1[treatment],lwd=5,col=eqColors[1])
  segments(x0=1,x1=60,y0=eqV2[treatment],lwd=5,col=eqColors[2])
  legend(x=55,y=1.25,lwd=2,lty='31',col=typeColors[2:1],legend=c('Type 2','Type 1'))
  fileName = sprintf('VaccineRateByType-%.0f.pdf',treatment)
  dev.print(pdf,fileName)
  graphics.off()
}

plotOverall = function(treatment) {
  df = dataFrame[dataFrame$treatment==treatment,]
  R0 = mean(df$R0)
  cd1 = mean(df$cd[df$type==1])
  cd2 = mean(df$cd[df$type==2])
  v1 = rep(NA,60)
  v2 = rep(NA,60)
  v = rep(NA,60)
  for(i in 1:60) {
    v[i] = mean(df$v[df$period==i])
  }
  graphics.off()
  windows(7,5)
  par(mar=c(3,3,4,3))
  plot(-1,xlim=c(1,60),ylim=c(0,1),axes=FALSE,xlab='',ylab='')
  axis(1,pos=0)
  axis(2,pos=0)
  mainString = r'(Overall Vaccination Rate ($R_0 = %.1f, c^D_1 = %.0f, c^D_2 = %.0f$) )'
  mainTex = sprintf(mainString, R0,cd1,cd2)
  mainExp = TeX(mainTex)
  title(main=mainExp)
  lines(v,lwd=2,col=typeColors[3],lty='31')
  segments(x0=1,x1=60,y0=eqV[treatment],lwd=5,col=eqColors[3])
  fileName = sprintf('VaccineRateOverall-%.0f.pdf',treatment)
  dev.print(pdf,fileName)
  graphics.off()
}


plotByType(1)
plotOverall(1)
plotByType(2)
plotOverall(2)
plotByType(3)
plotOverall(3)
plotByType(4)
plotOverall(4)
