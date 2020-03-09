library(plumber)
pr <- plumber::plumb("02-plumber_essentials.R")
pr$run(port = 8000)