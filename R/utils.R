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
#' @importFrom utils read.csv
aa.model.loader <- function(species, 
                            chain, 
                            encoder.input, 
                            encoder.model) {
  # Check if model is present
    model.meta.data <-  read.csv(system.file("extdata", "metadata.csv", 
                                               package = "Ibex"))
   if(!paste0(species, "_", chain, "_", 
           encoder.model, "_", encoder.input,  "_encoder.keras") %in%  model.meta.data[,1]) {
     stop(species, "_", chain, "_", encoder.model, "_", encoder.input, " is not an available model.")
   }
  # Load Model
    select  <- system.file("extdata", paste0(species, "_", chain, "_", 
                          encoder.model, "_", encoder.input,  "_encoder.keras"), 
                          package = "Ibex")

    model <- suppressMessages(keras3::load_model(select, compile = TRUE))
    return(model)
}


# Add the dimRed to single cell object
#' @importFrom SeuratObject CreateDimReducObject
#' @importFrom SingleCellExperiment reducedDim
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

