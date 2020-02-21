#' update_ad
#' @description
#' Update an entry from the dataframe of advertisements.
#' @param ad_id advertisement id. Integer positive number.
#' @param ad_name advertisement name. Character vector with the name of the advertisement
#' @param ad_cat category of the advertisements to return. Character vector.
#' @param ad_subcat subcategory of the advertisements to return. Character vector.
#' @param ad_client client of the advertisements to return. Character vector.
#' @param ad_click_count click count
#' @param ad_click_rate price per click
#'
#' @return dataframe
#' @export
update_ad <- function(ad_id, ad_name = NULL, ad_cat = NULL, ad_subcat = NULL, ad_client = NULL, ad_click_count = NULL, ad_click_rate = NULL) {
    ad_to_update <- subset_ads(ad_id = ad_id)
    if (is.null(ad_name)) ad_name <- ad_to_update$name
    if (is.null(ad_cat)) ad_cat <- ad_to_update$category
    if (is.null(ad_subcat)) ad_subcat <- ad_to_update$subcategory
    if (is.null(ad_client)) ad_client <- ad_to_update$client_id
    if (is.null(ad_click_count)) ad_click_count <- ad_to_update$click_count
    if (is.null(ad_click_rate)) ad_click_rate <- ad_to_update$click_rate

    updated.ads <- read.ads()
    updated.ads[updated.ads$id == ad_id,
               c("name", "category", "subcategory", "client_id", "click_count", "click_rate")] <-
        c(ad_name, ad_cat, ad_subcat, ad_client, ad_click_count, ad_click_rate)
    write.ads(updated.ads)
    return(subset_ads(ad_id = ad_id))
}
