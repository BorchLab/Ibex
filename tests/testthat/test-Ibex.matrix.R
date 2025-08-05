# test script for Ibex.matrix.R - testcases are NOT comprehensive!

test_that("Ibex.matrix handles incorrect inputs gracefully", {

  local_reproducible_output(unicode = FALSE)

  expect_error(
    Ibex.matrix(
      input.data = ibex_example,
      chain = "Middle",
      method = "encoder",
      verbose = FALSE
    ),
    "'arg' should be one of \"Heavy\", \"Light\""
  )
  expect_error(
    Ibex.matrix(
      input.data = ibex_example,
      chain = "Heavy",
      method = "xyz",
      verbose = FALSE
    ),
    "'arg' should be one of \"encoder\", \"geometric\""
  )
  expect_error(
    Ibex.matrix(
      input.data = ibex_example,
      chain = "Heavy",
      method = "encoder",
      encoder.model = "ABC",
      verbose = FALSE
    ),
    "'arg' should be one of \"CNN\", \"VAE\", \"CNN.EXP\", \"VAE.EXP\""
  )
  expect_error(
    Ibex.matrix(
      input.data = ibex_example,
      chain = "Heavy",
      method = "encoder",
      encoder.input = "XYZ",
      verbose = FALSE
    ),
    "arg' should be one of \"atchleyFactors\", \"crucianiProperties\", \"kideraFactors\", \"MSWHIM\", \"tScales\", \"OHE\""
  )
  expect_error(
    Ibex.matrix(
      input.data = ibex_example,
      chain = "Heavy",
      method = "geometric",
      geometric.theta = "not_numeric",
      verbose = FALSE
    ),
    "non-numeric argument to mathematical function"
  )

})

test_that("Ibex.matrix returns expected output format", {
  skip_if_py_not_installed(c("keras", "numpy"))
  result <- Ibex.matrix(input.data = ibex_example, 
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

test_that("Ibex.matrix works with encoder method", {
  skip_if_py_not_installed(c("keras", "numpy"))
  result <- Ibex.matrix(input.data = ibex_example, 
                        chain = "Light", 
                        method = "encoder",
                        encoder.model = "CNN", 
                        encoder.input = "OHE", 
                        verbose = FALSE)
  expect_true(is.data.frame(result))
  expect_true(all(grepl("^Ibex_", colnames(result))))
})

test_that("Ibex.matrix works with geometric method", {
  skip_if_py_not_installed(c("keras", "numpy"))
  result <- Ibex.matrix(input.data = ibex_example, 
                        chain = "Heavy", 
                        method = "geometric",
                        geometric.theta = pi / 4, 
                        verbose = FALSE)
  expect_true(is.data.frame(result))
  expect_true(all(grepl("^Ibex_", colnames(result))))
})

test_that("Ibex.matrix handles different species options", {
  skip_if_py_not_installed(c("keras", "numpy"))
  result1 <- Ibex.matrix(input.data = ibex_example, 
                          chain = "Heavy", 
                          method = "encoder",
                          encoder.model = "VAE", 
                          encoder.input = "atchleyFactors", 
                          species = "Human", 
                          verbose = FALSE)
  result2 <- Ibex.matrix(input.data = ibex_example, 
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

test_that("Ibex.matrix.character() works", {

  skip_if_py_not_installed(c("keras", "numpy"))

  expect_equal(
    Ibex.matrix(ibex_example),
    Ibex.matrix(stats::setNames(ibex_example$CTaa, colnames(ibex_example)))
  )

  heavy_cdr3s <- immApex::generateSequences(min.length = 14, max.length = 16)
  expect_equal(
    Ibex.matrix(heavy_cdr3s, verbose = FALSE),
    Ibex.matrix(paste0(heavy_cdr3s, "_None"), verbose = FALSE)
  )

  light_cdr3s <- immApex::generateSequences(min.length = 8, max.length = 10)
  expect_equal(
    Ibex.matrix(paste0("AAA_", light_cdr3s), chain = "Light", verbose = FALSE),
    Ibex.matrix(paste0("None_", light_cdr3s), chain = "Light", verbose = FALSE)
  )

})
