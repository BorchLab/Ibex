#' A SingleCellExperiment object with 200 randomly-sampled
#' B cells with BCR sequences from the 10x Genomics
#' 2k_BEAM-Ab_Mouse_HEL_5pv2 dataset.
#'
#' This object includes normalized gene expression values, metadata annotations,
#' and B cell clonotype information derived from 10x V(D)J sequencing. It is intended
#' as a small example dataset for testing and demonstration purposes.
#'
#' @format A \code{SingleCellExperiment} object with 32,285 genes (rows) and 200 cells (columns).
#' \describe{
#'   \item{assays}{List of matrices containing expression values: \code{counts} (raw counts) and \code{logcounts} (log-transformed).}
#'   \item{rowData}{Empty in this example (no gene-level annotations).}
#'   \item{colData}{A \code{DataFrame} with 14 columns of cell metadata, including:}
#'     \itemize{
#'       \item orig.identOriginal sample identity.
#'       \item nCount_RNA Total number of counts per cell.
#'       \item nFeature_RNA Number of detected genes per cell.
#'       \item cloneSize Size of each clone.
#'       \item ident Cluster assignment.
#'     }
#'   \item{reducedDims}{Contains dimensionality reductions: \code{PCA}, \code{pca}, and \code{apca}.}
#'   \item{altExp}{One alternative experiment named \code{BEAM} containing additional expression data.}
#' }
#' @name ibex_example
#' @docType data
NULL
