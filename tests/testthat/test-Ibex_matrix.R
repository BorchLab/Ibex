# test script for Ibex_matrix.R - testcases are NOT comprehensive!
ibex_example <- get(data("ibex_example"))

test_that("Ibex_matrix handles incorrect inputs gracefully", {

  local_reproducible_output(unicode = FALSE)

  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Middle", method = "encoder"),
               "'arg' should be one of \"Heavy\", \"Light\"")
  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Heavy", method = "xyz"),
               "'arg' should be one of \"encoder\", \"geometric\"")
  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Heavy", method = "encoder", encoder.model = "ABC"),
               "'arg' should be one of \"CNN\", \"VAE\", \"CNN.EXP\", \"VAE.EXP\"")
  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Heavy", method = "encoder", encoder.input = "XYZ"),
               "arg' should be one of \"atchleyFactors\", \"crucianiProperties\", \"kideraFactors\", \"MSWHIM\", \"tScales\", \"OHE\"")
  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Heavy", method = "geometric", geometric.theta = "not_numeric"),
               "non-numeric argument to mathematical function")
})

test_that("Ibex_matrix returns expected output format", {
  skip_if_py_not_installed(c("keras", "numpy"))
  result <- Ibex_matrix(input.data = ibex_example, 
                        chain = "Heavy", 
                        method = "encoder",
                        encoder.model = "VAE", 
                        encoder.input = "atchleyFactors", 
                        verbose = FALSE)
  expect_true(is.data.frame(result))
  expect_true(all(grepl("^Ibex_", colnames(result))))
  expect_gt(nrow(result), 0)
  expect_gt(ncol(result), 0)
})

test_that("Ibex_matrix works with encoder method", {
  skip_if_py_not_installed(c("keras", "numpy"))
  result <- Ibex_matrix(input.data = ibex_example, 
                        chain = "Light", 
                        method = "encoder",
                        encoder.model = "CNN", 
                        encoder.input = "OHE", 
                        verbose = FALSE)
  expect_true(is.data.frame(result))
  expect_true(all(grepl("^Ibex_", colnames(result))))
})

test_that("Ibex_matrix works with geometric method", {
  skip_if_py_not_installed(c("keras", "numpy"))
  result <- Ibex_matrix(input.data = ibex_example, 
                        chain = "Heavy", 
                        method = "geometric",
                        geometric.theta = pi / 4, 
                        verbose = FALSE)
  expect_true(is.data.frame(result))
  expect_true(all(grepl("^Ibex_", colnames(result))))
})

test_that("Ibex_matrix handles different species options", {
  skip_if_py_not_installed(c("keras", "numpy"))
  result1 <- Ibex_matrix(input.data = ibex_example, 
                          chain = "Heavy", 
                          method = "encoder",
                          encoder.model = "VAE", 
                          encoder.input = "atchleyFactors", 
                          species = "Human", 
                          verbose = FALSE)
  result2 <- Ibex_matrix(input.data = ibex_example, 
                          chain = "Heavy", 
                          method = "encoder",
                          encoder.model = "VAE", 
                          encoder.input = "atchleyFactors", 
                          species = "Mouse", 
                          verbose = FALSE)
  expect_true(is.data.frame(result1))
  expect_true(is.data.frame(result2))
  expect_true(all(grepl("^Ibex_", colnames(result1))))
  expect_true(all(grepl("^Ibex_", colnames(result2))))
})
