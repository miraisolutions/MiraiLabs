#' return_user_info
#' @description
#' Return infos for given user
#'
#' @param id vector of integers representing users
#' @param ... placeholder
#'
#' @return dataframe
#' @export
return_user_info <- function(id, ...) {
    users %>%
        filter(user_id %in% id)
}
