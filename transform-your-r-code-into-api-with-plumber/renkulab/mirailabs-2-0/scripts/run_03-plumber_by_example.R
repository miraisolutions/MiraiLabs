library(plumber)
pr <- plumber::plumb("03-plumber_by_example.R")
pr$run(port = 8000)