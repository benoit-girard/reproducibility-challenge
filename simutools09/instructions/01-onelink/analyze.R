# R script to evaluate single link SimGrid model
# Author        : Pedro Velho
# Last Modified : 04/11/2008  

logbasedLinearRegression = function(dataTable, quiet=TRUE) { 
  checkLabels = sum(names(dataTable) == c("Bandwidth", "Latency", "Size", "Model", "Time"))
  if (checkLabels != length(names(dataTable))){
    cat("Your frame should respect the following columns format:\n",sep="")
    cat(c("Bandwidth", "Latency", "Size", "Model", "Time"),sep=" ")
    cat("\n",sep="")
    cat("Your frame names are:\n",sep="")
    cat(names(dataTable),sep=" ")
    cat("\n",sep="")
    return(1)
  }

  #export data to ./bin/logbased-regression.pl script
  outFile = file("./tmp/logbased-regression.data", "w")
  write.table(file=outFile, dataTable, row.names=FALSE, col.names=FALSE)
  close(outFile)

  #call logbased-regression.pl
  if(quiet){
    system("./bin/logbased-regression.pl ./tmp/logbased-regression.data 2> /dev/null")
  }else {
    system("./bin/logbased-regression.pl ./tmp/logbased-regression.data")
  }
}

plotGnuplotError = function(A,B,minX=1,maxX=100,minY=0,maxY=1,labelX="X",labelY="Y",title="",generateEps = FALSE) {
  #export data to gnuplot file
  outFile = file("./tmp/gnuplotError.data", "w")
  write.table(data.frame(A,B), file = outFile , row.names = FALSE, col.names = FALSE)
  close(outFile)

  #export gnuplot script
  outFile = file("./tmp/gnuplotError.script", "w")

  if(generateEps) {
    cat(file = outFile, sep = "", "set terminal postscript eps color lw 2 \"Helvetica\" 20\n")
    cat(file = outFile, sep = "", "set output './tmp/gnuplotError.eps'\n")
  }
  cat(file = outFile, sep = "", "set grid\n")
  cat(file = outFile, sep = "", "set xrange [",minX, ":",maxX,"]\n")
  cat(file = outFile, sep = "", "set yrange [",minY, ":",maxY,"]\n")
  cat(file = outFile, sep = "", "set logscale x\n")
  cat(file = outFile, sep="", "set xlabel \"",labelX,"\"\n")
  cat(file = outFile, sep="", "set ylabel \"",labelY,"\"\n")
  cat(file = outFile, "plot './tmp/gnuplotError.data' u ($1/1000000):2 w boxes t '",title,"'\n")
  close(outFile)

  #call gnuplot and present 3D data
  system("gnuplot -persist ./tmp/gnuplotError.script")
}



gnuplot3D = function (X,Y,Z,minX=0,maxX=5,minY=0,maxY=5,minZ=0,maxZ=5,labelX="X",labelY="Y",labelZ="Z") {
  #export data to gnuplot file
  outFile = file("./tmp/gnuplot3d.data", "w")
  cat("#",labelX,labelY,labelZ,"\n",sep=" ")
  write.table(data.frame(X,Y,Z), file = outFile , row.names = FALSE, col.names = FALSE)
  close(outFile)
   
  #export gnuplot script
  outFile = file("./tmp/gnuplot3d.script", "w")
  cat(file = outFile, sep = "", "set xrange [",minX, ":",maxX,"]\n")
  cat(file = outFile, sep = "", "set yrange [",minY, ":",maxY,"]\n")
  cat(file = outFile, sep = "", "set zrange [",minZ, ":",maxZ,"]\n")
  cat(file = outFile, sep="", "set xlabel \"",labelX,"\"\n")
  cat(file = outFile, sep="", "set ylabel \"",labelY,"\"\n")
  cat(file = outFile, sep="", "set zlabel \"",labelZ,"\"\n")
  cat(file = outFile, "splot './tmp/gnuplot3d.data' w linespoints\n")
  close(outFile)

  #call gnuplot and present 3D data
  system("gnuplot -persist ./tmp/gnuplot3d.script")
}

oneLinkResult = read.table("./dat/raw.data")

# Plot a 3D graph with T = f(S,L) for a fixed bandwidth B=1e5 (100MBps)
auxTable = oneLinkResult[((oneLinkResult$Model == 'GTNets')&(oneLinkResult$Bandwidth == 1e5)),]
gnuplot3D(auxTable$Latency, auxTable$Size, auxTable$Time, maxX=max(auxTable$Latency), maxY=max(auxTable$Size), maxZ=max(auxTable$Time), labelX="Latency (SECONDS)", labelY="Size (BYTES)", labelZ="Time (SECONDS)")

# Use auxiliar script to get coefficient table
logbasedLinearRegression(oneLinkResult[((oneLinkResult$Size >= 1e5)&(oneLinkResult$Model == 'GTNets')),])


printError = function(dataTable, size=10000, coef=0.98, inter = 10, bw=1.333521e+08, lat=0.5){
  tmp = dataTable[(
    (dataTable$Model == 'GTNets')&
    (dataTable$Size > size)&
    (dataTable$Latency == lat)&
    (dataTable$Bandwidth == bw)),]
  
  timeGT = tmp$Time
  timeLV = tmp$Size/pmin(tmp$Bandwidth*coef,10000/tmp$Latency)  + inter*tmp$Latency
  error = abs(log(timeLV) - log(timeGT))
  cat(max(error),mean(error),sd(error),sep=" & ")
  cat(" \\\\ \n",sep="")
}


#1 KB  & 0.6000 & 6.2400   \\
printError(oneLinkResult, size=1000, coef=0.6000, inter = 6.24)
#10 KB & 0.7666 & 8.5008   \\
printError(oneLinkResult, size=10000, coef= 0.7666, inter = 8.5008)
#100 KB & 0.9200 & 10.4000 \\
printError(oneLinkResult, size=100000, coef= 0.92, inter = 10.4000)
#1 MB & 0.9202 & 14.8193   \\
printError(oneLinkResult, size=1000000, coef= 0.9202, inter = 14.8193)
#10 MB & 0.9056 & 22.4166 \\
printError(oneLinkResult, size=10000000, coef= 0.9056, inter = 22.4166)
#100 MB & 0.8976 & 22.4166 \\
printError(oneLinkResult, size=100000000, coef= 0.8976, inter = 22.4166)


# B = 100MB, L = 10 ms,
# S = { 0.001, 0.01, 0.1, 1 , 10, 100, 1000} MB
# 1000B, 10 000B, 1 000 000B, 10 000 000B, 100 000 000B, 1 000 000 000B
S = c(1e3,1e4,1e5,1e6,1e7,1e8,1e9)
coef= 0.92
inter = 10.4
timeLV = S/min(1e8*coef,10000/1e-2)  + inter*1e-2
resultThroughput = (S/timeLV)/1000
cat(formatC(resultThroughput, digits=4),sep=" ")

# error when limited by bandwidth, S = 100KB, B = 10KB
printError(oneLinkResult, size=1e5, coef= 0.92, inter = 10.4000, bw=1e4)

# error when not limited by bandwidth, S = 100KB, B = 100MB
printError(oneLinkResult, size=1e5, coef= 0.92, inter = 10.4000, bw=1e8)



# error for small size, S == 100MB, B == 100KB/s, L=0.5s
printError(oneLinkResult, size=1e8, coef=0.92, inter = 10.4, bw=1e5, lat=0.5)

# error for small size, S == 100MB, B == 100KB/s, L=0.01s
printError(oneLinkResult, size=1e8, coef=0.92, inter = 10.4, bw=1e5, lat=0.001)


  
# error for big size, S > 100KB
tmp = oneLinkResult[((oneLinkResult$Model == 'GTNets')&(oneLinkResult$Size > 1e5)),]
timeGT = tmp$Time
timeLV = tmp$Size/pmin(tmp$Bandwidth*coef,10000/tmp$Latency)  + inter*tmp$Latency
error = abs(log(timeLV) - log(timeGT))




# B = 100MB, L = 10 ms,
# S = { 0.001, 0.01, 0.1, 1 , 10, 100, 1000} MB
# 1000B, 10 000B, 1 000 000B, 10 000 000B, 100 000 000B, 1 000 000 000B
#S = c(1e3,1e4,1e5,1e6,1e7,1e8,1e9)
tmpTable = oneLinkResult[((oneLinkResult$Latency == 0.016)&(oneLinkResult$Bandwidth == 1e8)),]
timeGT = tmpTable[(tmpTable$Model == 'GTNets'),]
timeLV = tmpTable[(tmpTable$Model == 'LegrandVelho'),]
timeCM = tmpTable[(tmpTable$Model == 'CM02'),]
error = abs(log(timeCM$Time) - log(timeGT$Time))
errorImproved = abs(log(timeLV$Time) - log(timeGT$Time))
plotGnuplotError(timeGT$Size,errorImproved, minX=min(timeGT$Size)/1000000, maxX=max(timeGT$Size)/1000000, maxY=2, labelX="Size (MB)", labelY="abs(Error)", title="Improved", generateEps=TRUE)
plotGnuplotError(timeGT$Size,error, minX=min(timeGT$Size)/1000000, maxX=max(timeGT$Size)/1000000, maxY=2, labelX="Size (MB)", labelY="abs(Error)", title="Max-min", generateEps=TRUE)



tmpTable = oneLinkResult[((oneLinkResult$Latency == 0.016)&(oneLinkResult$Bandwidth == 1e8)&(oneLinkResult$Size > 10000000)),]
timeGT = tmpTable[(tmpTable$Model == 'GTNets'),]
timeLV = tmpTable[(tmpTable$Model == 'LegrandVelho'),]
timeCM = tmpTable[(tmpTable$Model == 'CM02'),]
error = abs(log(timeCM$Time) - log(timeGT$Time))
errorImproved = abs(log(timeLV$Time) - log(timeGT$Time))
exp(mean(error)) - 1
exp(max(error)) - 1

