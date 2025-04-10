"%!in%" <- Negate("%in%")

amino.acids <- c("A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V")

# Add to meta data some of the metrics calculated
#' @importFrom rlang %||%
#' @importFrom SingleCellExperiment colData
add.meta.data <- function(sc, meta, header) {
if (inherits(x=sc, what ="Seurat")) { 
  col.name <- names(meta) %||% colnames(meta)
  sc[[col.name]] <- meta
} else {
  rownames <- rownames(colData(sc))
  colData(sc) <- cbind(colData(sc), 
          meta[rownames,])[, union(colnames(colData(sc)),  colnames(meta))]
  rownames(colData(sc)) <- rownames  
}
  return(sc)
}

# This is to grab the metadata from a Seurat or SCE object
#' @importFrom SingleCellExperiment colData 
grabMeta <- function(sc) {
  if (inherits(x=sc, what ="Seurat")) {
    meta <- data.frame(sc[[]], slot(sc, "active.ident"))
    if ("cluster" %in% colnames(meta)) {
      colnames(meta)[length(meta)] <- "cluster.active.ident"
    } else {
      colnames(meta)[length(meta)] <- "cluster"
    }
  }
  else if (inherits(x=sc, what ="SingleCellExperiment")){
    meta <- data.frame(colData(sc))
    rownames(meta) <- sc@colData@rownames
    clu <- which(colnames(meta) == "ident")
    if ("cluster" %in% colnames(meta)) {
      colnames(meta)[clu] <- "cluster.active.idents"
    } else {
      colnames(meta)[clu] <- "cluster"
    }
  }
  return(meta)
}

# This is to check the single-cell expression object
checkSingleObject <- function(sc) {
  if (!inherits(x=sc, what ="Seurat") & 
      !inherits(x=sc, what ="SummarizedExperiment")){
    stop("Object indicated is not of class 'Seurat' or 
            'SummarizedExperiment', make sure you are using
            the correct data.") }
}

# This is to check that all the CDR3 sequences are < 45 residues or < 90 for CDR1/2/3
checkLength <- function(x, expanded = NULL) {
  cutoff <- ifelse( expanded == FALSE || is.null(expanded), 45, 90)
  if(any(na.omit(nchar(x)) > cutoff)) {
    stop(paste0("Models have been trained on sequences 
         less than ", cutoff, " amino acid residues. Please
         filter the larger sequences before running"))
  }
}
# Returns appropriate encoder model
#' @importFrom keras3 load_model
#' @importFrom utils read.csv download.file
#' @importFrom tools R_user_dir
aa.model.loader <- function(species, chain, encoder.input, encoder.model) {
  
  # 1) Construct the expected .keras filename
  model.name.base <- paste0(
    species, "_", chain, "_", 
    encoder.model, "_", encoder.input, 
    "_encoder.keras"
  )
  
  # 2) Locate and read the metadata CSV within your package
  meta_file <- system.file("extdata", "metadata.csv", package = "Ibex")
  if (!file.exists(meta_file)) {
    stop("Cannot find 'metadata.csv' in Ibex's 'inst/extdata' directory.")
  }
  model.meta.data <- read.csv(meta_file, stringsAsFactors = FALSE)
  
  # 3) Check if the requested model is listed in the first column (Title)
  if (!model.name.base %in% model.meta.data[[1]]) {
    stop("Model '", model.name.base, "' is not an available model.")
  }
  
  # 4) Construct the Zenodo download URL
  base_url <- "https://zenodo.org/record/14919286/files"
  download_url <- paste0(base_url, "/", model.name.base, "?download=1")
  
  # 5) Create or use a persistent cache directory for your package
  cache_dir <- tools::R_user_dir("Ibex", which = "cache")
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }
  
  # 6) Define the full local path in the cache
  local_path <- file.path(cache_dir, model.name.base)
  
  # 7) Download the file only if not already cached
  if (!file.exists(local_path)) {
    message("Downloading '", model.name.base, "' to cache directory:\n  ", local_path)
    
    status <- utils::download.file(download_url, destfile = local_path, mode = "wb")
    if (status != 0) {
      stop("Error downloading '", model.name.base, "'. Status code: ", status)
    }
  } else {
    message("Using cached model:\n  ", local_path)
  }
  
  # 8) Load the model (using keras3 or your chosen Keras interface)
  model <- suppressMessages(
    keras3::load_model(local_path, compile = TRUE)
  )
  
  return(model)
}



# Add the dimRed to single cell object
#' @importFrom SeuratObject CreateDimReducObject
#' @importFrom SingleCellExperiment reducedDim reducedDim<-
adding.DR <- function(sc, reduction, reduction.name) {
  if (inherits(sc, "Seurat")) {
    DR <- suppressWarnings(CreateDimReducObject(
      embeddings = as.matrix(reduction),
      loadings = as.matrix(reduction),
      projected = as.matrix(reduction),
      stdev = rep(0, ncol(reduction)),
      key = reduction.name,
      jackstraw = NULL,
      misc = list()))
    sc[[reduction.name]] <- DR
  } else if (inherits(sc, "SingleCellExperiment")) {
    reducedDim(sc, reduction.name) <- reduction
  }
  return(sc)
}

