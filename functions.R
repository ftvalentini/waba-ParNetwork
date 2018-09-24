source("libraries.R")

# paste text
"%+%" <- function(a,b) paste(a,b,sep="")

# max min transformation
maxmin <- function(x) (x - min(x))/(max(x)-min(x))
