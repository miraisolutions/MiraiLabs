context("update_ad")

test_that("Update name", {
    on.exit(recreate.ads())
    update_ad(ad_id = 100,  "test update name")
    testthat::expect(nrow(read.ads()) == nrow(getOption("ads.backup")), "Row count failed")
    testthat::expect(with(read.ads(), name[id == 100]) == "test update name", "Name update failed")
})
