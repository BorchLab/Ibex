getdata <- function(dir, name) {
	readRDS(paste("testdata/", dir, "/", name, ".rds", sep = ""))
}

skip_if_py_not_installed <- function(python_packages) {

	missing_packages <- basilisk::basiliskRun(
		env = IbexEnv,
		fun = function(packages) {
			packages[sapply(packages, Negate(reticulate::py_module_available))]
		},
		packages = python_packages
	)

	if (length(missing_packages) > 0) {
		testthat::skip(paste0(
			"Required Python Module",
			if (length(missing_packages) > 1) "s" else "",
			" `",
			paste(missing_packages, collapse = "`, `"),
			"` not available."
		))
	}

}
