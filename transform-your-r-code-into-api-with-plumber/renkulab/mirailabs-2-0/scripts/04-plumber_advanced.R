#* @apiTitle Plumber advanced: programatic definition of routers
#* @apiDescription Application serving a pool of advertisments for web sites.

library("plumber")
library("magrittr")

# Tmp folder for logs
tmp_path <- Sys.getenv("TMP_PATH")
if (tmp_path == "") tmp_path <- tempdir()


# > Creating a router ----
pr <- plumber$new()

# Defining filters
sapply(pr$filters, `[[`, "name")
pr$filters

pr$filter("checkpoint", function(req) {
  msg <- paste0("Hi. Filter 'checkpoint' hit at: ", format(Sys.time(), "%H:%M:%S"))
  print(msg)
  forward()
})
sapply(pr$filters, `[[`, "name")

# Defining endpoints
pr$handle("GET", "/hello.world", function(){"Hello world!"})

# Additional arguments like params, tags and comments can be provided.
# These will be included in the API specs for swagger ui
pr$handle(methods = "POST",
          path = "/username", 
          handler = function(username) username %T>% options(last.user = .) %>% list(username = .),
          params = list(username = list(desc = "Your name here", type = "string", required = TRUE)),
          tags = "Created programmatically.",
          comments = "Provide a user name"
)
pr$handle("GET", "/username", function() list(username = getOption("last.user", Sys.getenv("USER"))),
          tags = "Created programmatically.", comments = "Get the last user name")
pr


# > Practical use case: Content negotiation ----

# Return text/csv if that is the preference, otherwise json
pr$handle("GET", "/titanic", function(req, res){
  
  # The Accept header contains the accept format preferences, as a comma separated string
  accept <- gsub("[[:space:]]", "", req$HEADERS["accept"]) %>% strsplit(",") %>% unlist
  
  if (is.element("text/csv", accept) && match("text/csv", accept) < match("application/json", accept, nomatch = 100)){
    tmpFile <- file.path(tmp_path, "titanic.csv")
    write.csv2(Titanic, tmpFile, row.names = FALSE)
    include_file(file = tmpFile, res = res, content_type = "text/csv")
  } else {
    res$setHeader("Content-type", "application/json")
    jsonlite::toJSON(as.data.frame(Titanic))
  }
},
tags = "Created programmatically.")

# To test the content negotiation endpoint:
# 1.- Run this script as a job
# 2.- Run the following lines of code
# 
if (FALSE){
  resp_csv <- httr::GET("http://127.0.0.1:9000/titanic", httr::accept("text/csv"))
  resp_csv
  
  resp_json <- httr::GET("http://127.0.0.1:9000/titanic")
  resp_json
  httr::content(resp_json)
}



# > Registering hooks ----

# Managing connections to many detailed log files with hooks.
pr$registerHooks(
  list(
    preroute = function(data, req, res) {
      
      data$request_is_relevant <- !grepl("swagger|openapi", req$PATH_INFO)
      
      # Create and open verbose log file connection
      if(data$request_is_relevant) {
        verboseLog <- sprintf("%s/verboseLog_%s%s_%s.log",
                              tmp_path,
                              req$REQUEST_METHOD,
                              gsub("/", "_", req$PATH_INFO),
                              format(Sys.time(), "%Y%m%d%H%M"))
        if (!file.exists(verboseLog)) file.create(verboseLog)
        verboseLogFile <- file(verboseLog, open = "w")
        
        # Adding the verboseLogFile to both data and req environments.
        # This way, it can be used by other hooks, filters and endpoints
        data$verboseLogFile <- verboseLogFile -> req$verboseLogFile
        print(paste("Open connection to verbose log file:", verboseLog))
      }
    },
    preserialize = function(data, res, value){
      if (data$request_is_relevant){
        write(sprintf("About to serialize response: %s", head(value)), file = data$verboseLogFile)
      }
      value
    },
    postserialize = function(data, res, value){
      if (data$request_is_relevant){
        write(sprintf("Value after serializing: %s", head(res$body)), file = data$verboseLogFile)
        
        print("Open connections")
        print(showConnections())
        print(paste("Closing connection:", data$verboseLogFile))
        close(data$verboseLogFile)
      }
      value
    }
  )
)


# > Practical use case: Encrypted cookie ----

# The hook sessionCookie creates an object in the request environment called "session"
# "session" is json-serialized, encripted, and stored in a cookie on the client side

session <- plumber$new()
# The following throws a security warning. To be discussed in the best practices chapter.
session$registerHooks(sessionCookie(key = "This key is used to encript the cookie, and is checked in filter sharedSecret",
                                    name = "plumberEncryptedCookie"))

## Set secret key using `keyring` (preferred method)
# install.packages(keyring)
# keyring::key_set_with_value("plumberEncryptedCookie", plumber::randomCookieKey())
# session$registerHooks(sessionCookie(keyring::key_get("plumberEncryptedCookie")))


session$handle("GET", "/info", function(req){
  sessionInfo <-
    list(
      count = 0,
      requestedAdverts = floor(runif(1, min = 10, max = 100)),
      clickedAdverts = floor(runif(1, min = 1, max = 10)),
      revenueProfile = sample( c("high", "medium", "low"), 1)
    )
  
  if (!is.null(req$session$sessionInfo))  sessionInfo$count <- as.numeric(sessionInfo$count) +1
  
  # The object session stored in the cookie supports complex data structure, like a list
  req$session$info <- sessionInfo
  return(sessionInfo)
},
tags = "Created programmatically.",
comments = "Get session info"
)

session$handle("GET", "/cookie", function(req){
  print(req$cookies$plumberEncryptedCookie)
})

if (FALSE) {
  session$run(port = 9000)
}

# > Modularization: Mounting routers ----
combined <- plumber$new()

combined$mount("/pr", pr)
combined$mount("/session", session)

# Mounting router defined in a script with decorated code
adspool <- plumber$new("~/mirailabs-2-0/scripts/03-plumber_by_example.R")
combined$mount("/adspool", adspool)

combined

# >  Running the API ----

# Running a router. This serves the plumber API.
pr$run(port = 9000)
if (FALSE) {
  combined$run(port = 9000,
               swagger = function(pr_, spec, ...) {
                 spec$paths$`/adspool/ads_postbody`$post$requestBody <- list(
                   description="Body for posting an ad",
                   required=TRUE,
                   content = list(`application/json` = list(schema = list(message = list(type = "string"))))
                 )
                 spec$paths$`/adspool/ad/{ad_id}`$put$requestBody <- list(
                   description="Body for modifying an ad",
                   required=TRUE,
                   content = list(`application/json` = list(schema = list(message = list(type = "string"))))
                 )
                 spec$info$title <- "Tuned swagger spec"
                 spec
               }
               )
}

#Example of json for ads_postbody
# {
#   "ad_name": ["Test1"], #Mandatory
#   "ad_cat": ["Game"],
#   "ad_subcat": ["Videogame"],
#   "ad_customer": [1], #Mandatory
#   "ad_click_rate": [0.1] #Mandatory
# }

#
# Executing of API parts without serving the API
#

# Execute one endpoint. Accessing the endpoint through the path only works if there is no ambiguity.
pr$routes$hello.world$exec()

# Execute one endpoint. The path "username" is used by two endpoints (POST/GET), pr$routes is not an option here.
pr$endpoints$`__no-preempt__`[[2]]$exec(username = "Bob") # POST
pr$endpoints$`__no-preempt__`[[3]]$exec() # GET

#
# Processing a request end-to end
#

# Helper: create a request object (environment)
make_req <- function(verb, path, query = "", body = ""){
  req <- new.env()
  req$REQUEST_METHOD <- toupper(verb)
  req$PATH_INFO <- path
  req$QUERY_STRING <- query
  req$rook.input <- list(read_lines = function(){ body })
  req
}

# The method serve processes a request. It requires a response object.
adspool$serve(make_req("GET", "/ads_data", "ad_name=monopoly&n=1"), plumber:::PlumberResponse$new())


# # > Practical use case: testing your API ----

testthat::with_reporter("Progress", {
  testthat::context("Test a plumber API \n")
  testthat::test_that("GET customer ads is ok", {
    res <- adspool$serve(make_req("GET", "/customer/1"), plumber:::PlumberResponse$new())
    customer1_ads <- jsonlite::fromJSON(res$body)
    testthat::expect_equal(unique(customer1_ads$client_id), 1)
  })
  testthat::test_that("Endpoint not found", {
    res <- adspool$serve(make_req("GET", "/non-existing-path"), plumber:::PlumberResponse$new())
    testthat::expect_equal(res$status, 404)
  })
})
