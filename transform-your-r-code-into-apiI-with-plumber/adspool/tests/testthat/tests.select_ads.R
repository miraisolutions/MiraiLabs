context("select_ads")

test_that("Select a single random add", {
    res <- select_ads(n = 1L)
    testthat::expect(nrow(res) == 1, "Select a single random add failed")
})

test_that("Select n adds with a filter for which only m < n adds qualify", {
    res <- select_ads(n = 100L, ad_cat = "Fashion", ad_subcat = "Footware")
    testthat::expect(nrow(res) == 100, "Unexpected number of rows")
})

test_that("Select n adds with ads.history", {
    res <- select_ads(n = 100L, ads.history = c("Games", "News"), onlyMatching = TRUE)
    testthat::expect(nrow(res) == 100, "Unexpected number of rows")
    testthat::expect(setequal(res$category, c("Games", "News")), "Unexpected categories in results")
})
