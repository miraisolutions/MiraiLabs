#' add_ad
#' @description
#' Add a new advertisement to the dataframe of advertisements.
#' The function assumes the existence of a file "ads_file":
#'  - a dataframe ads, with minimal structure "ads" "subcats" "cats" "client";
#'
#' @param newad new advertisement. Character string of name of new advertisement.
#' @param newad_cat new advertisement category. Character string of name of new advertisement category. If unavailable a random category from those already available in ads will be used.
#' @param newad_subcat new advertisement subcategory. Character string of name of new advertisement subcategory. If unavailable a random subcategory from those already available in catsToSubcats and associated with the given category will be used.
#' @param newad_client new advertisement category. Integer indicating the client id.
#' @param newad_click_rate  new advertisement rate.
#'
#' @return dataframe
#' @export
add_ad <- function(newad, newad_cat = NULL, newad_subcat = NULL, newad_client, newad_click_rate){
    ads <- read.ads()
    assert_that(is.character(newad))
    if (length(newad) > 1){
        message("Warning: length(newad) > 1, considering only the first element")
        newad <- newad[1]
    }

    # Define newad_cat
    if (is.null(newad_cat)) {
        newad_cat <- sample(ads$category, 1)
    }
    # Define newad_subcat
    if (is.null(newad_subcat)) {
        newad_subcat <- with(ads, sample(subcategory[category == newad_cat], 1))
        if (length(newad_subcat) == 0) {
            newad_subcat <- "none"
        }
    }

    # Create newad dataframe
    newad_df <- data.frame(
        id = max(ads$id) + 1,
        name = newad,
        category = newad_cat,
        subcategory = newad_subcat,
        client_id = as.integer(newad_client),
        img_path = sprintf("%03d_%s.jpeg", max(ads$id) + 1, gsub("\\W", "", newad)),
        click_count = 0,
        click_rate = as.numeric(newad_click_rate)
    )

    # Add new row to ads
    write.ads(newad_df, append = TRUE, col.names = FALSE)

    # Return the newly created ad
    return(newad_df)
}
