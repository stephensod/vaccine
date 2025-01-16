library(latex2exp)
library(janitor)

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

sessionLabels = unique(dataFrame$session)
session = 1:16
treatment = c()
v = c()
v1 = c()
v2 = c()
R0 = c()
cd1 = c()
cd2 = c()

for(i in 1:16) {
  selection = dataFrame$session==sessionLabels[i]
  selection1 = selection & dataFrame$type==1
  selection2 = selection & dataFrame$type==2
  treatment[i] = dataFrame$treatment[selection][1]
  R0[i] = dataFrame$R0[selection][1]
  cd1[i] = dataFrame$cd[selection1][1]
  cd2[i] = dataFrame$cd[selection2][1]
  v[i] = mean(dataFrame$v[selection]) 
  v1[i] = mean(dataFrame$v[selection1]) 
  v2[i] = mean(dataFrame$v[selection2])
}

vDiff = v2 - v1

mean(v[R0==4])
mean(v[R0==1.5])
wilcox.test(v[R0==4],v[R0==1.5])

mean(v1[cd1==cd2])
mean(v2[cd1==cd2])
wilcox.test(v1[cd1==cd2],v2[cd1==cd2])

mean(v1[cd1!=cd2])
mean(v2[cd1!=cd2])
wilcox.test(v1[cd1!=cd2],v2[cd1!=cd2])

mean(vDiff[cd1==cd2])
mean(vDiff[cd1!=cd2])
wilcox.test(vDiff[cd1==cd2],vDiff[cd1!=cd2])

round_half_up(mean(5*v1[treatment==1]),2)
round_half_up(mean(5*v2[treatment==1]),2)

round_half_up(mean(10*v[treatment==2]),2)

round_half_up(mean(5*v1[treatment==3]),2)
round_half_up(mean(5*v2[treatment==3]),2)

round_half_up(mean(10*v[treatment==4]),2)

