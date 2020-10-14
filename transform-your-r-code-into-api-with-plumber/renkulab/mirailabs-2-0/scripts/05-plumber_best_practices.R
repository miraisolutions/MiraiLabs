library(plumber)
library(dplyr)

# > Managing secrets ----
# https://cran.r-project.org/web/packages/httr/vignettes/secrets.html

# Encript a cookie with a secure key
keyring::key_set_with_value("plumber_api", password = randomCookieKey())
adspool <- plumb("~/mirailabs-2-0/scripts/03-plumber_by_example.R")
adspool$registerHooks(
  sessionCookie(
    key = keyring::key_get("plumber_api"),
    name = "plumber_session")
)
if (FALSE){
  adspool$run()
}

# > Explicit API version ----
versionedAPI <- plumber$new()
versionedAPI$mount("/adspool/v1", adspool)
if (FALSE){
  versionedAPI$run()
}

# > Resource pagination and expansion ----
# Cutting down the default response size

# Pagination and default value
pr <- plumber$new()
pr$handle("GET", "/EuStockMarkets", 
          function(n = 100) {
            list(indexes = colnames(EuStockMarkets),
                 values = head(EuStockMarkets, as.integer(n)))
          }, 
          params = list(n = list(desc = "Number of rows", type = "integer", required = FALSE)),
          tags = "EU stock markets data"
)

# Expand the response on demand
# The dplyr dataset "nasa" records meterological data (temperature, cloud cover, ozone etc)
# for a 4d spatio-temporal dataset (lat, long, month and year)
# For simplicity, we filter the dataset

pr$handle("GET", "/nasa/",
          function(mets = NULL, year = 2000, month = 1){
            if (is.null(mets)) {
              list(measures = names(nasa$mets), years = nasa$dims$year)
            } else {
              yearmonth <- expand.grid(as.integer(year), as.integer(month)) %>% 
                setNames(c("year", "month"))
              
              apply(yearmonth, 1,
                    function(ym) {
                      nasa %>%
                        filter(lat > 22, long < -100, year == ym["year"], month == ym["month"]) %>%
                        as.data.frame() %>%
                        select(lat, long, mets) %>%
                        setNames(sprintf("%04d%02d", ym["year"], ym["month"]))
                    }
              ) 
              
            }
          },
          params = list(
            mets = list(desc = "Run with empty value to see the options"),
            year = list(desc = "Default: 2000", type = "int"),
            month = list(desc = "Default: 1", type = "int")
          ),
          tags = "NASA meteorological data"
)
# Hint: This example shows nicely when openning direclty the nasa url in a browser that parses json, like mozilla firefox
if (FALSE){
  pr$run(
    swagger = function(pr_, spec, ...) {
      spec$info$title <- "Pagination and Expansion"
      spec}
  )
}


# > Injection attacks ----
attacks <- plumber$new()

# Code injection
attacks$handle("GET",
               "/Rinjection", 
               function(.expr){
                 eval(parse(text = .expr))
               },
               params = list(.expr = list(desc = "Your R code here")),
               tags = "Injection",
               comments = "Allowing code injection is a dangerous practice to avoid\n"
)
# Examples, including ill-intentioned calls:
#   getwd()
#   list.files()
#   search()
#   ls("package:adspool")
#   adspool::read.users()
#   adspool::remove_ads
#   system("lsb_release -a", intern = TRUE)
#   system("ps -eaf", intern = TRUE)
#   system("killall ...", intern = TRUE)
#   system("rm ...", intern = TRUE)


# Unexpected path
attacks$handle("GET",
               "/logfile/",
               function(filename, res){
                 tmp_path <- Sys.getenv("TMP_PATH")
                 if (tmp_path == "") tmp_path <- tempdir()
                 if (file.exists(file.path(tmp_path, filename))){
                   file.path(tmp_path, filename) %>%
                     readLines()  
                 } else {
                   res$status <- 404
                   res$body <- "File not found"
                 }
               },
               params = list(filename = list(desc = "Eg: adspool.log, ../../../home/rstudio/.ssh/id_rsa_dummy")),
               tags = "Injection",
               comments = "File getter vulnerable to malicious file names"
)

# > Sanitization ----
attacks$handle("GET",
               "/logfile/sanitized",
               function(filename, res){
                 sanitizedFilename <- basename(filename)
                 if (sanitizedFilename != filename) {
                   print(sprintf("Unexpected filename. Possibly an attack attempt. filename: %s", filename))
                 }
                 
                 tmp_path <- Sys.getenv("TMP_PATH")
                 if (tmp_path == "") tmp_path <- tempdir()
                 
                 if (file.exists(file.path(tmp_path, sanitizedFilename))){
                   file.path(tmp_path, sanitizedFilename) %>%
                     readLines()  
                 } else {
                   res$status <- 404
                   res$body <- "File not found"
                 }
               },
               params = list(filename = list(desc = "Eg: adspool.log, ../../../home/rstudio/.ssh/id_rsa_dummy")),
               tags = "Injection",
               comments = "File getter sanitized"
)


# > Denial of Service attack ----
attacks$handle("GET", 
               "/rnorm_histogram", 
               function(n = 1000) {
                 n <- as.integer(n)
                 tmpfile <- file.path(tempdir(), "rnorm_hist.png")
                 png(tmpfile)
                 hist(rnorm(n))
                 dev.off()
                 readBin(tmpfile, "raw", n = file.info(tmpfile)$size)
               },
               params = list(n = list(desc = "Number of draws", type = "integer")),
               serializer = serializer_content_type(type="image/png"),
               tags = "Denial of Service",
               comments = "Vulnerable to denial of service attack"
)
# don't go above 1e8 or you break your renku session :)

attacks$handle("GET", 
               "/rnorm_histogram/limited", 
               function(n = 1000, res) {
                 n <- as.integer(n)
                 if (n > 1e5){
                   res$status <- 400
                   res$setHeader("Content-type", "application/json")
                   return(jsonlite::toJSON("Number of draws above treshold of 1e5"))
                 }
                 tmpfile <- file.path(tempdir(), "rnorm_hist.png")
                 png(tmpfile)
                 hist(rnorm(n))
                 dev.off()
                 readBin(tmpfile, "raw", n = file.info(tmpfile)$size)
               },
               params = list(n = list(desc = "Number of draws", type = "integer")),
               serializer = serializer_content_type(type="image/png"),
               tags = "Denial of Service",
               comments = "Secured vs denial of service attack"
)

if (FALSE) {
  attacks$run(
    swagger = function(pr_, spec, ...) {
      spec$info$title <- "Security attacks"
      spec$info$description <- "Examples of common security vulnerabilities"
      spec}
  )
}