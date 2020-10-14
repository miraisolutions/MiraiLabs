#exercise 02 with solutions

library(plumber)

#Set Variable with path to tmp folder in current RProj
Sys.setenv(TMP_PATH = file.path(rprojroot::find_rstudio_root_file(), "tmp"))

# The package adspool contains data and utils for the examples.
library("adspool")

# 1) ----
# Write an endpoint to GET all the advertisements belonging to one subcategory. (hint: check get_customers_ads)

#* Return all the ads of a given sub category.
#* @param ad_subcat The subgategories of the ads to get.
#* @get /subcat/
get_subcat_ads <- function(ad_subcat = NULL) {
  subset_ads(ad_subcat = ad_subcat)
}

# 2) ----
# Set a cookie that will store the time at which the endpoint get_time was requested (hint: use Sys.time(), check get_counter())
#* Send Session info with Cookies
#* @get /time
get_time <- function(req, res) {
  time <- Sys.time()
  res$setCookie("time", time, expiration = 60 ) # expiration is in seconds
  return(paste0("Cookie stet at #", time))
}


# 3) ----
# Create a filter that will print to the console the time at which the endpoint was requested (hint: use Sys.time(), check filter_logger())
#* Log to console some information about the incoming request
#* @filter /logger_time
filter_logger_time <- function(req){
  line <- Sys.time()
  print(line)
  write.logs(line)
  plumber::forward()
}