install.packages("tinytex")
tinytex::install_tinytex()
tinytex::tlmgr_install("pdfcrop") # to crop images
install.packages("remotes")
install.packages("dplyr")
install.packages("magrittr")
install.packages("reshape2")
install.packages("gapminder")
install.packages("assertthat")
install.packages("tidyverse")
install.packages("tidyquant")
# install.packages("plumber")
remotes::install_github("rstudio/plumber") #get dev version where swagger shows the body in responses with error status
install.packages("httr")
install.packages("rmarkdown")
install.packages("ggplot2")
install.packages("testthat")
install.packages("keyring")
remotes::install_github(repo = "https://github.com/miraisolutions/MiraiLabs.git", 
                        subdir = "transform-your-r-code-into-api-with-plumber/adspool", 
                        upgrade = "never")
#remotes::install_git(url = "https://renkulab.io/gitlab/gustavo.martinez/mirailabs-2-0.git", subdir = "adspool")