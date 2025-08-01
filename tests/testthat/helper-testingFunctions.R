getdata <- function(dir, name) {
	readRDS(file.path("testdata", dir, paste0(name, ".rds")))
}

skip_if_py_not_installed <- function(python_packages) {
	for (python_package in python_packages) {
		if (!reticulate::py_module_available(python_package)) {
			testthat::skip(paste(
				"Required Python Module", python_package, "is not available."
			))
		}
	}
}
