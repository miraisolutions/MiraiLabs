#' remove_ads
#' @description
#' Remove entry(-es) from the dataframe of advertisements via filtering.
#' @param ad_id advertisement id. Integer positive number.
#' @param ad_name advertisement name. Character vector with the name of the advertisement
#' @param ad_cat category of the advertisements to return. Character vector.
#' @param ad_subcat subcategory of the advertisements to return. Character vector.
#' @param ad_customer customer of the advertisements to return. Character vector.
#'
#' @return dataframe
#' @export
remove_ads <- function(ad_id = NULL, ad_name = NULL, ad_cat = NULL, ad_subcat = NULL, ad_customer = NULL) {

    # TODO: authorize this function
    ads_removed <- subset_ads(ad_id, ad_name, ad_cat, ad_subcat, ad_customer)
    ads_kept <- setdiff(read.ads(), ads_removed)

    write.ads(ads_kept)

    return(invisible(ads_removed))
}
