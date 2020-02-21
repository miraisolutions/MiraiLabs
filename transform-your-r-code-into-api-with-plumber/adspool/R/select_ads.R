#' select_ad
#'
#' @description Select the best adverts to be exposed in the given input context
#'
#' @param n Number of adverts to return
#' @param onlyMatching Logical. When \code{TRUE} return only ads matching filter criteria
#' @param ... Additional parameters for the ad selection, including ads filter criteria
#' to be passed on to \link{subset_ads}
#'
#' @return \code{data.frame} with metadata of the advertisements
#' @details When \code{onlyMatching = TRUE} and there are no matching adverts in the pool, then the result is empty.
#' Otherwise, the resulting data frame always contains \code{n} elements. When possible, the adverts are
#' taken from the pool of ads with matching criteria. Matching ads are prioritized over non matching ones.
#' If \code{onlyMatching = TRUE} and the number of matching ads in the pool is less than \code{n}, then these will
#' be recycled until filling the request.
#'
#' @importFrom dplyr sample_n
#' @importFrom assertthat assert_that
#' @export
select_ads <- function(n = 1L, onlyMatching = FALSE, ...) {
    assert_that(is.integer(n))
    args <- list(...)

    # TODO: use of cookie
    if ("cookie" %in% names(args)) {
        # use the cookie for filtering further (or extending) matching adverts
    }

    # In the examples we either provide a filter of a history of ads
    if ("ads.history" %in% names(args)) {
        ad_cat <- base::sample(args$ads.history, n, replace = TRUE) %>%
            unique %>%
            paste0(collapse = "|")
        matching <- subset_ads(ad_cat = ad_cat)
    } else {
        matching <- subset_ads(...)
    }

    # Return a sample of the matching ads as requested
    if (n < nrow(matching) || onlyMatching){
        dplyr::sample_n(matching, n, replace = onlyMatching)
    } else {
        rbind(matching,
              setdiff(read.ads(), matching) %>%
                  dplyr::sample_n(n - nrow(matching)))
    }
}
