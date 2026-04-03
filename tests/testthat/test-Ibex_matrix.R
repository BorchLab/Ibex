# test script for Ibex_matrix.R - testcases are NOT comprehensive!
ibex_example <- get(data("ibex_example"))

test_that("Ibex_matrix handles incorrect inputs gracefully", {

  local_reproducible_output(unicode = FALSE)

  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Middle", method = "encoder", verbose = FALSE),
               "'arg' should be one of \"Heavy\", \"Light\"")
  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Heavy", method = "xyz", verbose = FALSE),
               "'arg' should be one of \"encoder\", \"geometric\"")
  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Heavy", method = "encoder", encoder.model = "ABC", verbose = FALSE),
               "'arg' should be one of \"CNN\", \"VAE\", \"CNN.EXP\", \"VAE.EXP\"")
  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Heavy", method = "encoder", encoder.input = "XYZ", verbose = FALSE),
               "arg' should be one of \"atchleyFactors\", \"crucianiProperties\", \"kideraFactors\", \"MSWHIM\", \"tScales\", \"OHE\"")
  expect_error(Ibex_matrix(input.data = ibex_example, chain = "Heavy", method = "geometric", geometric.theta = "not_numeric", verbose = FALSE),
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

test_that("Ibex_matrix works with character vector input", {
  # Test with unnamed vector
  sequences <- c("CARDYWGQGTLVTVSS", "CARDSSGYWGQGTLVTVSS", "CARDTGYWGQGTLVTVSS")
  result <- Ibex_matrix(input.data = sequences, 
                        chain = "Heavy", 
                        method = "geometric",
                        verbose = FALSE)
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 3)
  expect_equal(rownames(result), c("1", "2", "3"))
  expect_true(all(grepl("^Ibex_", colnames(result))))
  
  # Test with named vector
  named_sequences <- c(cell1 = "CARDYWGQGTLVTVSS", cell2 = "CARDSSGYWGQGTLVTVSS")
  result_named <- Ibex_matrix(input.data = named_sequences, 
                              chain = "Heavy", 
                              method = "geometric",
                              verbose = FALSE)
  expect_equal(rownames(result_named), c("cell1", "cell2"))
})

test_that("Ibex_matrix character input validates amino acids", {
  # Test with invalid characters
  bad_sequences <- c("CARDYW123", "CARDSSGYW")
  expect_error(
    Ibex_matrix(input.data = bad_sequences, chain = "Heavy", method = "geometric", verbose = FALSE),
    "Invalid character"
  )
})

test_that("Ibex_matrix character input works with light chain", {
  sequences <- c("CQQYNSYPLTFG", "CQQSYSTPLTFG")
  result <- Ibex_matrix(input.data = sequences, 
                        chain = "Light", 
                        method = "geometric",
                        verbose = FALSE)
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)
})

test_that("Ibex_matrix character input works with encoder method", {
  skip_if_py_not_installed(c("keras", "numpy"))
  sequences <- c("CARDYWGQGTLVTVSS", "CARDSSGYWGQGTLVTVSS")
  result <- Ibex_matrix(input.data = sequences, 
                        chain = "Heavy", 
                        method = "encoder",
                        encoder.model = "VAE",
                        encoder.input = "atchleyFactors",
                        species = "Human",
                        verbose = FALSE)
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 2)
  expect_true(all(grepl("^Ibex_", colnames(result))))
})
