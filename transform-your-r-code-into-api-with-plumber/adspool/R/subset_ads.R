#' subset_ads
#' @description
#' Return subset of the dataframe of advertisements via filtering.
#' The function assumes the existence of a file "ads_file":
#'  - a dataframe ads, with minimal structure "ads" "subcats" "cats" "customer";
#'
#' @param ad_id advertisement id. Integer positive number.
#' @param ad_name advertisement name. String with the name of the advertisement
#' @param ad_cat category of the advertisements to return. String.
#' @param ad_subcat subcategory of the advertisements to return. String.
#' @param ad_customer customer of the advertisements to return. String.
#'
#' @return \code{dataframe}, a subset of the ads that match the given parameters.
#' \code{ad_name}, \code{ad_cat} and \code{ad_subcat} are matched by pattern, \code{ad_id} and \code{customer_id} exact match.
#' @export
subset_ads <- function(ad_id = NULL, ad_name = NULL, ad_cat = NULL, ad_subcat = NULL, ad_customer = NULL) {
    # handle nulls for pattern matching with grepl
    if(is.null(ad_name)) ad_name <- "."
    if(is.null(ad_cat)) ad_cat <- "."
    if(is.null(ad_subcat)) ad_subcat <- "."

    read.ads() %>%
        filter((is.null(ad_id) | id %in% ad_id) &
                   grepl(ad_name, name, ignore.case = TRUE) &
                   grepl(ad_cat, category, ignore.case = TRUE) &
                   grepl(ad_subcat, subcategory, ignore.case = TRUE) &
                   (is.null(ad_customer) | customer_id %in% ad_customer)
        )
}
