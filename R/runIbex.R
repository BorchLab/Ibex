#' Ibex Single-Cell Calculation
#'
#' This function applies the Ibex algorithm to single-cell data, integrating 
#' seamlessly with Seurat or SingleCellExperiment pipelines. The algorithm 
#' generates latent dimensions using deep learning or geometric transformations,
#' storing the results in the dimensional reduction slot. \code{runIbex} will
#' automatically subset the single-cell object based on amino acid sequences 
#' present for the given chain selection. 
#'
#' @examples
#' # Using the encoder method with a variational autoencoder
#' ibex_example <- runIbex(ibex_example, 
#'                         chain = "Heavy",
#'                         method = "encoder",
#'                         encoder.model = "VAE",
#'                         encoder.input = "atchleyFactors")
#'
#' # Using the geometric method with a specified angle
#' ibex_example <- runIbex(ibex_example, 
#'                         chain = "Heavy",
#'                         method = "geometric",
#'                         geometric.theta = pi)
#'
#' @param sc.data A single-cell dataset, which can be:
#'   \itemize{
#'     \item A Seurat object
#'     \item A SingleCellExperiment object
#'   }
#' @param chain Character. Specifies the chain to analyze:
#'   \itemize{
#'     \item "Heavy" for the heavy chain
#'     \item "Light" for the light chain
#'   }
#' @param method Character. Algorithm to use for generating latent dimensions:
#'   \itemize{
#'     \item "encoder" - Uses deep learning autoencoders
#'     \item "geometric" - Uses geometric transformations based on the BLOSUM62 matrix
#'   }
#' @param encoder.model Character. The type of autoencoder model to use:
#'   \itemize{
#'     \item "CNN" - CDR3 Convolutional Neural Network-based autoencoder
#'     \item "VAE" - CDR3 Variational Autoencoder
#'     \item "CNN.EXP" - CDR1/2/3 CNN
#'     \item "VAE.EXP" - CDR1/2/3 VAE
#'   }
#' @param encoder.input Character. Input features for the encoder model:
#'   \itemize{
#'     \item Amino Acid Properties: "atchleyFactors", "crucianiProperties",
#'      "kideraFactors", "MSWHIM", "tScales"
#'     \item "OHE" - One Hot Encoding 
#'   }
#' @param geometric.theta Numeric. Angle (in radians) for geometric transformation. 
#'   Used only when \code{method = "geometric"}.
#' @param reduction.name Character. The name to assign to the dimensional reduction. 
#'   This is useful for running Ibex with multiple parameter settings and saving results 
#'   under different names.
#' @param species Character. Default is "Human" or "Mouse".
#' @param verbose Logical. Whether to print progress messages. Default is TRUE.
#'
#' @return An updated Seurat or SingleCellExperiment object with Ibex dimensions added 
#' to the dimensional reduction slot.
#' @export
runIbex <- function(sc.data, 
                    chain = "Heavy", 
                    method = "encoder",
                    encoder.model = "VAE", 
                    encoder.input = "atchleyFactors",
                    geometric.theta = pi,
                    reduction.name = "Ibex", 
                    species = "Human",
                    verbose = TRUE) {
    checkSingleObject(sc.data)
    sc.data <- filter.cells(sc.data, chain)
    reduction <- Ibex.matrix(input.data = sc.data,
                             chain = chain, 
                             method = method,
                             encoder.model = encoder.model, 
                             encoder.input = encoder.input,
                             geometric.theta = geometric.theta, 
                             species = species,
                             verbose = verbose)
    BCR <- getIR(sc.data, chain, sequence.type = "aa")[[1]]
    sc.data <- adding.DR(sc.data, reduction, reduction.name)
    return(sc.data)
}

#' Filter Single-Cell Data Based on CDR3 Sequences
#'
#' This function subsets a Seurat or SingleCellExperiment object, 
#' removing cells where the `CTaa` column is missing or contains unwanted patterns.
#'
#' @param sc.obj A Seurat or SingleCellExperiment object.
#' @param chain Character. Specifies the chain type ("Heavy" or "Light").
#'
#' @return A filtered Seurat or SingleCellExperiment object.
filter.cells <- function(sc.obj, 
                         chain) {
  meta <- grabMeta(sc.obj)
  if (!"CTaa" %in% colnames(meta)) {
    stop("Amino acid sequences are not added to the single-cell object correctly.")
  }
  pattern.NA <- ifelse(chain == "Heavy", "NA_", "_NA")
  pattern.none <- ifelse(chain == "Heavy", "None_", "_None")
  
  cells.index <- which(!is.na(meta[,"CTaa"]) & 
                    !grepl(paste0(pattern.NA, "|", pattern.none), meta[,"CTaa"]))
  
  if (inherits(x=sc.obj, what ="Seurat")) {
    cell.chains <- rownames(meta)[cells.index]
    sc.obj <- subset(sc.obj, cells = cell.chains)
  } else if (inherits(x=sc.obj, what ="SingleCellExperiment")){
    sc.obj <- sc.obj[,cells.index]
  }
  return(sc.obj)
}
