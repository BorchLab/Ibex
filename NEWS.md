# Ibex - Change Log

## v1.1.1

* Aligned version with Bioconductor release
* Switched default branch to `devel` for Bioconductor compatibility
* Updated CI workflows to target `devel` branch
* Converted NEWS to NEWS.md format
* Added automated GitHub Release workflow via tags

## v1.0.0
* Integration of Ibex with immApex
* Updated Seurat object to v5
* Updated support for SCE format for `runIbex()`
* Update `CoNGAfy()` to function with all versions of Seurat
* Updated `quietBCRgenes()` to use VariableFeatures() call for SeuratV5 and backward compatibility
* Added `getHumanIgPseudoGenes()` to return a list of human Immunoglobulin Pseudo genes
* Added new light and heavy chain models with encoding methods: OHE, atchleyFactors, crucianiProperties, kideraFactors, MSWHIM, tScales, zScales
* Trained convolutional and variational autoencoders (architecture: 512-256-128-256-512)
* Implementing GitHub action workflows
* Adding testthat framework
* Deprecated clonalCommunity
* Added geometric encoding using the BLOSUM62 matrix
* `Ibex_matrix()` now accepts character vectors of amino acid sequences directly
* Removed rlang from Imports, added lifecycle
* As per `basilisk` documentation:
    - Add `.BBSoptions` with `UnsupportedPlatforms: win32`
    - Add `configure` and `configure.win` scripts
* Add Docker infrastructure with `Dockerfile` and `.devcontainer/devcontainer.json`
* Improved testthat compatibility across platforms
* Improve adherence to verbosity arguments

## v1.0.0

### Major Underlying Changes

* Integration of Ibex with immApex
* Updated Seurat object to v5
* Runs using basilisk instead of reticulate - no installation of python packages

### Feature Changes

* Renamed `Ibex.matrix()` to `Ibex_matrix()`
* Updated support for SCE format for `runIbex()`
* Update `CoNGAfy()` to function with all versions of Seurat
* Updated `quietBCRgenes()` to use `VariableFeatures()` call for SeuratV5 and backward compatibility
* Add `getHumanIgPseudoGenes()` to return a list of human Immunoglobulin Pseudo genes that are kept by `quietBCRgenes()`

### New Models

* Added New Light and Heavy Chain Models
* Encoding methods now accepted: "OHE", "atchleyFactors", "crucianiProperties", "kideraFactors", "MSWHIM", "tScales", "zScales"
* Sequence input:
    - Human Heavy: 10000000
    - Human Light: 5000000
    - Human Heavy-Expanded: 5000000
    - Human Light-Expanded: 2500000
    - Mouse Heavy: 5000000
    - Mouse Heavy-Expanded: 5000000
* Trained convolutional and variational autoencoders for Heavy/Light chains
    - Architecture: 512-256-128-256-512
    - Parameters:
        - Batch Size = 128
        - Latent Dimensions = 128
        - Epochs = 100
        - Loss = Mean Squared Error (CNN) & KL Divergence (VAE)
        - Activation = relu
        - Learning rate = 1e-6
    - Optimizers: Adam
    - Early stopping was set to patients of 10 for minimal validation loss and restoration of best weights
    - CNN autoencoders have batch normalization layers between the dense layers

## Pre-release Development (v0.99.0 - v0.99.31)

* ibex_ensure_basilisk_external_dir no longer importsFrom basilisk.utils directly
* Moved data processing script out of vignette to inst/scripts
* Added ibex_ensure_basilisk_external_dir with basilisk.utils
* Adding internal .OnLoad() function to handle basilisk lock dir issue
* Deprecated `quietBCRgenes()`
* Converted `Ibex.matrix()` to `Ibex_matrix()`
* Added Install Instructions for Bioconductor on README and Vignette
* Removed references to Keras3 Installation
* Added information to example data
* Examples now check if python is installed and running
* Updated example data to 2k HEL BEAM-Ab from 10x
* Converted ibex_example into SCE object for compliance
* Large revision of vignette to fit new data/format
* Added species argument to runIbex
* Implementing GitHub action workflows
* Adding testthat framework
* Deprecating clonalCommunity
* Added geometric encoding using the BLOSUM62 matrix
* Added chain.checker() function to allow for uncapitalized chain calls
* Updated models for manuscript revision
* Updated models to include radam optimization, early stop, trained on 800,000 unique cdr3s
* quietBCRgenes() now does not remove human Ig pseudogenes
* Added detection of chain length to function call
* Added support for direct output of combineBCR()
* Modified quietBCR() to include constant regions and J-chains
* Initial commit
