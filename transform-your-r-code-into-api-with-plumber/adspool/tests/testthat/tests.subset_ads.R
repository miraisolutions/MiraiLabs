context("subset_ads")

test_that("Subset by id", {
    res <- subset_ads(ad_id = 10)
    testthat::expect(nrow(res) == 1, "Subset by id failed")
})

test_that("Subset by name", {
    res <- subset_ads(ad_name = "Mario Kart")
    testthat::expect(nrow(res) == 1, "Subset by name failed")
})

test_that("Subset by cat", {
    res <- subset_ads(ad_cat = "Vehicles")
    testthat::expect(nrow(res) > 0, "Subset by category failed")
})

test_that("Subset by subcat", {
    res <- subset_ads(ad_subcat = "Jobs")
    testthat::expect(nrow(res) > 0, "Subset by subcategory failed")
})

test_that("Subset by customer", {
    res <- subset_ads(ad_customer = 1)
    testthat::expect(nrow(res) > 0, "Subset by customer failed")
})

test_that("Subset by cat and subcat", {
    res <- subset_ads(ad_cat = "News", ad_subcat = "Sport")
    testthat::expect(nrow(res) > 0, "Subset by category and subcategory failed")
})
