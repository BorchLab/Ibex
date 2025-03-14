% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/runIbex.R
\name{runIbex}
\alias{runIbex}
\title{Ibex Single-Cell Calculation}
\usage{
runIbex(
  sc.data,
  chain = "Heavy",
  method = "encoder",
  encoder.model = "VAE",
  encoder.input = "atchleyFactors",
  geometric.theta = pi,
  reduction.name = "Ibex",
  species = "Human",
  verbose = TRUE
)
}
\arguments{
\item{sc.data}{A single-cell dataset, which can be:
\itemize{
  \item A Seurat object
  \item A SingleCellExperiment object
}}

\item{chain}{Character. Specifies the chain to analyze:
\itemize{
  \item "Heavy" for the heavy chain
  \item "Light" for the light chain
}}

\item{method}{Character. Algorithm to use for generating latent dimensions:
\itemize{
  \item "encoder" - Uses deep learning autoencoders
  \item "geometric" - Uses geometric transformations based on the BLOSUM62 matrix
}}

\item{encoder.model}{Character. The type of autoencoder model to use:
\itemize{
  \item "CNN" - CDR3 Convolutional Neural Network-based autoencoder
  \item "VAE" - CDR3 Variational Autoencoder
  \item "CNN.EXP" - CDR1/2/3 CNN
  \item "VAE.EXP" - CDR1/2/3 VAE
}}

\item{encoder.input}{Character. Input features for the encoder model:
\itemize{
  \item Amino Acid Properties: "atchleyFactors", "crucianiProperties",
   "kideraFactors", "MSWHIM", "tScales"
  \item "OHE" - One Hot Encoding 
}}

\item{geometric.theta}{Numeric. Angle (in radians) for geometric transformation. 
Used only when \code{method = "geometric"}.}

\item{reduction.name}{Character. The name to assign to the dimensional reduction. 
This is useful for running Ibex with multiple parameter settings and saving results 
under different names.}

\item{species}{Character. Default is "Human" or "Mouse".}

\item{verbose}{Logical. Whether to print progress messages. Default is TRUE.}
}
\value{
An updated Seurat or SingleCellExperiment object with Ibex dimensions added 
to the dimensional reduction slot.
}
\description{
This function applies the Ibex algorithm to single-cell data, integrating 
seamlessly with Seurat or SingleCellExperiment pipelines. The algorithm 
generates latent dimensions using deep learning or geometric transformations,
storing the results in the dimensional reduction slot. \code{runIbex} will
automatically subset the single-cell object based on amino acid sequences 
present for the given chain selection.
}
\examples{
# Using the encoder method with a variational autoencoder
ibex_example <- runIbex(ibex_example, 
                        chain = "Heavy",
                        method = "encoder",
                        encoder.model = "VAE",
                        encoder.input = "atchleyFactors")

# Using the geometric method with a specified angle
ibex_example <- runIbex(ibex_example, 
                        chain = "Heavy",
                        method = "geometric",
                        geometric.theta = pi)

}
