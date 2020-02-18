#' Read advertisements from disk
#' @title Utils to read, write and restore from backup example ads and users data
#'
#' @description convenient wrappers to read.csv2 and write.csv2 frequent calls in adspool.
#' If ever this package is developed to read-write from database, it would be sufficient to update these wrappers.
#' @param x the object to be written by write.csv2
#' @param object the object to be written by saveRDS
#' @param ... passed down to the low level read/write functions
#' @export
read.ads <- function(...) {
    read.csv2(file = getOption("ads_file"), dec = ".", ...)
}

#' @describeIn read.ads Write advertisements from disk
write.ads <- function(x, ...){
    write.table(x = x, file = getOption("ads_file"), quote = TRUE, sep = ";", row.names = FALSE, ...)
}

#' @describeIn read.ads Re-create the ads file
#' @export
recreate.ads <- function(...) write.ads(x = getOption("ads.backup"), ...)

#' @describeIn read.ads Read users from disk
#' @export
read.users <- function(...) {
    readRDS(getOption("users_file"), ...)
}

#' @describeIn read.ads Write users from disk
#' @export
write.users <- function(object, ...){
    saveRDS(object = object, file = getOption("users_file"), ...)
}

#' @describeIn read.ads Re-create the users file
#' @export
recreate.users <- function(...) write.users(x = getOption("users.backup"), ...)

#' Write logging info to disk
#' @title Append info to logging file
#'
#' @description convenient wrappers to write() for frequent calls in adspool.
#' @param line the object to be written by write
#' @param ... passed down to the low level functions
#' @export
write.logs <- function(line, ...){
  write(line, file = getOption("logging_file"), append = TRUE, ...)
}
