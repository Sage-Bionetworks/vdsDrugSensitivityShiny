listFiles <- list.files("out",full.names = T)
###Extract VDS rho estimates
drugs = c()
for (x in listFiles) {
  load(x)
  perf <- vds$perf
  rhovalues <- sapply(names(perf), function(y) {
    return(perf[[y]]$rho$estimate)
  })
  rhovalues <- data.frame(t(rhovalues),row.names = drug)
  colnames(rhovalues) = names(perf)
  if (which(x==listFiles) == 1) {
    test = rhovalues
  } else {
    test = merge(test,rhovalues,all = T,sort = F)
  }
  drugs = c(drugs, drug)
}
row.names(test) = drugs

## Extract dataframe from R object
model2 <- lapply(listFiles, function(x) { 
  load(x)
  df <- lapply(names(R), function(y) {
    diseaseArea=R[[y]]$df
    diseaseArea$drug = drug
    diseaseArea$disease = y
    return(diseaseArea)
  })
  temp <- do.call(rbind,df)
  return(temp)
})
model2<- do.call(rbind, model2)

