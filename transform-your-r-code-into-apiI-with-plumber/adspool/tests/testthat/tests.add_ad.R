context("add_ad")

test_that("Add by just name", {
    on.exit(recreate.ads())
    add_ad(newad = "test new ad", newad_client = 10, newad_click_rate = 0.1)
    testthat::expect(nrow(read.ads()) == nrow(getOption("ads.backup")) + 1, "New ad not added")
})

test_that("Add by just name and category", {
    on.exit(recreate.ads())
    add_ad(newad = "test new ad", newad_cat = "Vehicles", newad_client = 10, newad_click_rate = 0.1)
    testthat::expect(nrow(read.ads()) == nrow(getOption("ads.backup")) + 1, "New ad not added")
})

test_that("Add with full details (img path not existing)", {
    on.exit(recreate.ads())
    add_ad(newad = "My motorbike test ad",
           newad_cat = "Vehicles",
           newad_subcat = "Motorcycles",
           newad_client = 9,
           newad_click_rate = 0.2
    )
    testthat::expect(nrow(read.ads()) == nrow(getOption("ads.backup")) + 1, "New ad not added")
})

