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
* Added information to example data
* Examples now check if python is installed and running
* Updated example data to 2k HEL BEAM-Ab from 10x
* Converted ibex_example into SCE object for compliance
* Large revision of vignette to fit new data/format
* Added species argument to runIbex
* Deprecated `quietBCRgenes()`
* Converted `Ibex.matrix()` to `Ibex_matrix()`
* Added Install Instructions for Bioconductor on README and Vignette
* Removed references to Keras3 Installation
* Moved data processing script out of vignette to inst/scripts
* Added ibex_ensure_basilisk_external_dir with basilisk.utils
* Adding internal .OnLoad() function to handle basilisk lock dir issue

## Pre-release Development (v0.99.0 - v0.99.5)
* Initial commit and early development
* Added detection of chain length to function call
* Added support for direct output of combineBCR()
* Modified quietBCR() to include constant regions and J-chains
* Updated models to include radam optimization, early stop, trained on 800,000 unique cdr3s
* quietBCRgenes() now does not remove human Ig pseudogenes
* Updated models for manuscript revision
* Added chain.checker() function to allow for uncapitalized chain calls
* Trained classical and variational autoencoders for light/heavy chains (architecture: 256-128-30-128-256)
