#  hackaton
setwd("~/Documents/hackaton")
library("rjson")
library(stringr)
install.packages('timeDate')
library(timeDate)
json_data <- fromJSON(file='emergency.json')
data<-json_data$data
data2=data[1]
data3=data2[[1]][[8]]
# strsplit(x, split, fixed = FALSE, perl = FALSE, useBytes = FALSE)
data4=strsplit(data3, " ")
data5=strsplit(data3, " \"")
data5[[1]][4]
data5[[1]][6]
data5[[1]][8]
data5[[1]][10]



## based on data
length(data)

csv=data.frame()
for (i in 1:length(data)){
  x=data[i][[1]][[8]]
  y=strsplit(x, " \"")
  print(length(y[[1]]))
  
  tmp=data.frame()
  if (length(y[[1]])==11){
    tmp[1,1]=y[[1]][4]
    tmp[1,2]=y[[1]][6]
    tmp[1,3]=y[[1]][8]
    tmp[1,4]=y[[1]][10]
  }
  else if (length(y[[1]])==7){
    tmp[1,1]=NA
    tmp[1,2]=NA
    tmp[1,3]=y[[1]][4]
    tmp[1,4]=y[[1]][6]
  }
  else{
    tmp[1,1]=NA
    tmp[1,2]=NA
    tmp[1,3]=NA
    tmp[1,4]=NA
    
    }
  csv=rbind(csv, tmp)
}
library(stringr)
csv2=data.frame(csv)
colnames(csv2) <- c("lati", "long", "creationtime", "closetime")
csv2$lati=as.character(csv2$lati)
csv2$long=as.character(csv2$long)
csv2$creationtime=as.character(csv2$creationtime)


for (i in 1:nrow(csv2)){
  csv2$lati[i]=str_sub(csv2$lati[i],1,-7)
  csv2$long[i]=str_sub(csv2$long[i],1,-7)
  csv2$creationtime[i]=str_sub(csv2$creationtime[i],1,-7)
}


emergency=read.csv(file='emergency.csv')
final=cbind(emergency,csv2)
final$Creation.Date<-NULL
final$Closed.Date<-NULL
final$Latitude<-NULL
final$Longitude<-NULL
final$creationtime=as.Date(final$creationtime)

write.csv(final, file='fulldata.csv')


time=final$creationtime[1]
# as.POSIXct(time)
# unique(final$Incident.Type)
# as.POSIXct(z, origin = "1960-01-01")  
# y <- strptime(time, "%m/%d/%y %H:%M:%S")
test=strsplit(time, '  ')[[1]]
# test2=c(test[1], paste(test[2], test[3]))
# test[1]
a0=as.character(timeDate(time))
a1=paste(test[2], test[3])
a2=paste(a0,a1)
as.POSIXct(a2)
a3=strptime(a2, "%Y-%m-%d %I:%M:%S %p") 



for(i in 1:nrow(final)){
  raw=final$creationtime[i]
  day=as.character(timeDate(raw))
  test=strsplit(raw, '  ')[[1]]
  thetime=test[2]
  full=paste(day, thetime)
  # print(strptime(as.character(full), "%Y-%m-%d %I:%M:%S %p") )
  final$creationtime2[i]=as.character(strptime(as.character(full), "%Y-%m-%d %I:%M:%S %p"))
  print(final$creationtime2[i])
  
  raw=final$closetime[i]
  day=as.character(timeDate(raw))
  test=strsplit(raw, '  ')[[1]]
  thetime=test[2]
  full=paste(day, thetime)
  # print(strptime(as.character(full), "%Y-%m-%d %I:%M:%S %p") )
  final$closetime2[i]=as.character(strptime(as.character(full), "%Y-%m-%d %I:%M:%S %p"))
  }
# final$interval=as.numeric(final$closetime2-final$creationtime2)
as.POSIXct(final$closetime2[1])-as.POSIXct(final$creationtime2[1][[1]])
for(i in 1:nrow(final)){
  print(final$closetime2[i])
  print(final$creationtime2[i][[1]])
  final$interval[i]=as.POSIXct(final$closetime2[i])-as.POSIXct(final$creationtime2[i][[1]])
}

final$interval=as.numeric(final$interval)
final$creationtime2=as.character(final$creationtime2)

final2=final
final2$interval<-NULL
final$interval.min=final$interval*60
write.csv(final, file='fulldata_v3.csv')
write.csv(final2, file='fulldata_v2.csv')

# datav4=read.csv(file='fulldata_v4.csv')
# datav4$hour_interval=round(datav4$min_interval/60,2)
final=final2
final$weekday=as.POSIXlt(final$creationtime2)$wday
final$month=as.POSIXlt(final$creationtime2)$mon
# final$month=as.numeric(final$month)

final[is.na(final)] <- 'zero'
for(i in 1:nrow(final)){
    if(final$weekday[i]==0)
      final$weekend[i]='weekend'
    else if(final$weekday[i]==6)
      final$weekend[i]='weekend'
    else
      final$weekend[i]='weekday'
}
for(i in 1:nrow(final)){
  if(final$month[i]>=2 & final$month[i]<=4)
    final$season[i]='spring'
  else if(final$month[i]==8 | final$month[i]==9 | final$month[i]==10 ){
    final$season[i]='fall'
    }
  else if(final$month[i]>=5 & final$month[i]<=7)
    final$season[i]='summer'
  else if(final$month[i]==11 | final$month[i]<=1)
    final$season[i]='winter'
}
final333=final[-13, ]
write.csv(final, file='datafull_v7.1.csv')

datav8.5<-read.csv(file='fulldata_v8.5.csv')

######## random forest  ########
library(randomForest)
n.val=nrow(datav8.5)
n.train=as.integer(0.8*nrow(datav8.5))
n.test=n.val-n.train
inds.train <- sample(1:n.val,n.train)
inds.test <- setdiff(1:n.val,inds.train)
data.train <- datav8.5[inds.train,]
data.test <- datav8.5[inds.test,]
tree.rf <- randomForest(nondetailed_hour~Type2 + Borough + weekend + Creation.Hour.Range, data=data.train)

out.list <- list(K)
out.vals <- mat.or.vec(n.test,K)

length(unique(datav8.5$Type2))
length(unique(datav8.5$Borough))
length(unique(datav8.5$hour_interval))
length(unique(datav8.5$))
