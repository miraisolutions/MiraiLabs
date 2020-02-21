context("remove_ads")

test_that("Remove by id", {
    on.exit(recreate.ads())
    to_remove <- subset_ads(ad_id = 1)
    removed <- remove_ads(ad_id = 1)
    testthat::expect(nrow(intersect(read.ads(), to_remove)) == 0, "intersect check failed")
})

test_that("Remove by name", {
    on.exit(recreate.ads())
    to_remove <- subset_ads(ad_id = 1)
    removed <- remove_ads(ad_id = 1)
    testthat::expect(nrow(intersect(read.ads(), to_remove)) == 0, "intersect check failed")
})

test_that("Remove by cat", {
    on.exit(recreate.ads())
    to_remove <- subset_ads(ad_cat = "Vehicles")
    removed <- remove_ads(ad_cat = "Vehicles")
    testthat::expect(nrow(intersect(read.ads(), to_remove)) == 0, "intersect check failed")
})

test_that("Remove by subcat", {
    on.exit(recreate.ads())
    to_remove <- subset_ads(ad_subcat = "Jobs")
    res <- remove_ads(ad_subcat = "Jobs")
    testthat::expect(nrow(intersect(read.ads(), to_remove)) == 0, "intersect check failed")
})

test_that("Remove by cat and subcat", {
    on.exit(recreate.ads())
    to_remove <- subset_ads(ad_cat = "News", ad_subcat = "Sport")
    res <- remove_ads(ad_cat = "News", ad_subcat = "Sport")
    testthat::expect(nrow(intersect(read.ads(), to_remove)) == 0, "intersect check failed")
})
