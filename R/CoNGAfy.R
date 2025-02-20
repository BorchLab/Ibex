#' Reduce a Single-Cell Object to Representative Cells
#'
#' This function generates a single-cell object with a reduced representation of RNA expression 
#' by clonotype. The approach is inspired by the method introduced in \href{https://pubmed.ncbi.nlm.nih.gov/34426704/}{CoNGA}. 
#' Users can generate either a mean representation of features by clonotype or identify a representative 
#' cell using PCA-based minimal Euclidean distance. Please read and cite the original work by the authors of CoNGA.
#'
#' @examples
#' # Generate a representative single-cell object using minimal Euclidean distance
#' ibex.clones <- CoNGAfy(ibex_example, 
#'                        method = "dist",
#'                        features = NULL)
#'
#' # Generate a representative single-cell object using the mean expression across features
#' ibex.clones <- CoNGAfy(ibex_example, 
#'                        method = "mean")
#'
#' @param input.data A single-cell dataset in Seurat or SingleCellExperiment format.
#' @param method Character. Specifies the method to reduce the dataset:
#'   \itemize{
#'     \item "mean" - Computes the mean expression of selected features across cells in each clonotype.
#'     \item "dist" - Uses PCA reduction to identify the cell with the minimal Euclidean distance within each clonotype group.
#'   }
#' @param features Character vector. Selected genes for the reduction. If \code{NULL} (default), all genes are used.
#' @param assay Character. The name of the assay or assays to include in the output. Defaults to the active assay.
#' @param meta.carry Character vector. Metadata variables to carry over from the input single-cell object to the output.
#'
#' @return A reduced single-cell object where each clonotype is represented by a single cell.
#'
#' @export
#' @importFrom SeuratObject CreateSeuratObject CreateAssayObject
#' @importFrom SingleCellExperiment SingleCellExperiment 
#' @importFrom SummarizedExperiment assay assay<-

CoNGAfy <- function(input.data, 
                    method = "dist", 
                    features = NULL, 
                    assay = "RNA", 
                    meta.carry = c("CTaa", "CTgene")) {
    cells.chains <- rownames(input.data[[]][!is.na(input.data[["CTaa"]]),])
    input.data <- subset(input.data, cells = cells.chains)
    conga <- NULL
    if(method == "mean") {
        for (x in seq_along(assay)) {
            conga[[x]] <- CoNGA.mean(input.data, features, assay[x])
            
        }
    } else if(method == "dist") {
        for (x in seq_along(assay)) {
            conga[[x]] <- CoNGA.dist(input.data, features, assay[x])
            
        }
        
    }
    names(conga) <- assay
    if (inherits(x=input.data, what ="Seurat")) {
        sc.output <- CreateSeuratObject(conga[[1]], assay = names(conga)[1], project = "Ibex")
        if(length(conga) > 1) {
            for(y in 2:length(conga)) {
                sc.output[[names(conga)[y]]] <- CreateAssayObject(conga[[y]])
            }
        }
        CTge <- unique(input.data[[]][,c(meta.carry)])
    } else if (inherits(x=input.data, what ="SingleCellExperiment")) {
        sc.output <- SingleCellExperiment(assay = conga[[1]])
        if(length(conga) > 1) {
            for(y in 2:length(conga)) {
                assay(sc.output, names(conga)[y]) <- conga[[y]]
            }
        }
        sc.output$CTaa <- rownames(sc.output@colData)
        CTge <- data.frame(unique(input.data@colData[,c(meta.carry)]))
    }
    CTge <- CTge[!duplicated(CTge$CTaa),]
    clones <- unique(CTge$CTaa)
    rownames(CTge) <- clones
    colnames(CTge) <- c("CTaa", "CTgene")
    sc.output <- add.meta.data(sc.output, CTge, colnames(CTge))
    return(sc.output)
}

#For all single clones, will use true RNA scaled values
#For multiplets will use the cell with the minimal distance in PCA
#For doublets, will automatically select the first cell. 
#' @importFrom SummarizedExperiment assay
CoNGA.dist <- function(input.data, features, assay) {
    if (inherits(x=input.data, what ="Seurat")) {
        if("RNA" == assay) {
            data.use <- input.data[["pca"]]@cell.embeddings
        } else if ("ADT" == assay) {
            data.use <- input.data[["apca"]]@cell.embeddings
        }
    } else if (inherits(x=input.data, what ="SingleCellExperiment")){
        data.use <- reducedDim(input.data, "PCA")
    }
    meta <- grabMeta(input.data)
    data <- as.data.frame(meta[,"CTaa"])
    colnames(data) <- "CTaa"
    rownames(data) <- rownames(meta)
    all.clones <- table(data$CTaa)
    unique.clones <- all.clones[which(all.clones > 1)]
    single.clones <- all.clones[all.clones %!in% unique.clones]
    barcodes <- rownames(data)[which(data$CTaa %in% names(single.clones))]
    for (i in seq_along(unique.clones)) {
        loc <- which(data$CTaa == names(unique.clones)[i])
        dist <- as.matrix(dist(data.use[loc,]))
        cell <- names(which(rowSums(dist) == min(rowSums(dist))))
        if (length(cell) > 1) {
            cell <- cell[1]
        }
        barcodes <- c(barcodes, cell)
    }
    if (inherits(x=input.data, what ="Seurat")) {
        assay.use <- input.data[[assay]]$counts
    } else if (inherits(x=input.data, what ="SingleCellExperiment")){
        assay.use <- assay(input.data)
    }
    features.to.avg <- features %||% rownames(x = assay.use)
    features.assay <- intersect(x = features.to.avg, y = rownames(x = assay.use))
    data.return <- assay.use[rownames(assay.use) %in% features.assay, colnames(assay.use) %in% barcodes]
    colnames(data.return) <- data$CTaa[match(barcodes, rownames(data))]
    return(data.return)
}
# Adapted from the AverageExpression() function in Seurat
#' @importFrom rlang %||%
#' @importFrom Matrix sparse.model.matrix colSums
#' @importFrom SummarizedExperiment assay
#' @importFrom stats as.formula
CoNGA.mean <- function(input.data, features, assay) {
    
    if (inherits(x=input.data, what ="Seurat")) {
        data.use <- input.data[[assay]]$counts
    } else if (inherits(x=input.data, what ="SingleCellExperiment")){
        data.use <- assay(input.data, name = assay)
    }
    
    features.to.avg <- features %||% rownames(x = data.use)
    features.assay <- intersect(x = features.to.avg, y = rownames(x = data.use))
    meta <- grabMeta(input.data)
    data <- as.data.frame(meta[,"CTaa"])
    colnames(data) <- "CTaa"
    rownames(data) <- rownames(meta)
    data <- data[which(rowSums(x = is.na(x = data)) == 0), , drop = FALSE]
    for (i in seq_len(ncol(x = data))) {
        data[, i] <- as.factor(x = data[, i])
    }
    num.levels <- sapply(X = seq_len(ncol(x = data)), FUN = function(i) { 
        length(x = levels(x = data[, i]))
    })
    category.matrix <- sparse.model.matrix(object = as.formula(
        object = paste0(
            '~0+',
            paste0(
                "data[,",
                1:length(x = "CTaa"),
                "]",
                collapse = ":"
            )
        )
    ))
    colsums <- Matrix::colSums(x = category.matrix)
    category.matrix <- category.matrix[, colsums > 0]
    colsums <- colsums[colsums > 0]
    
    category.matrix <- sweep(
        x = category.matrix,
        MARGIN = 2,
        STATS = colsums,
        FUN = "/")
    colnames(x = category.matrix) <- sapply(
        X = colnames(x = category.matrix),
        FUN = function(name) {
            name <- gsub(pattern = "data\\[, [1-9]*\\]", replacement = "", x = name)
            return(paste0(rev(x = unlist(x = strsplit(x = name, split = ":"))), collapse = "_"))
        })
    data.return <- data.use %*% category.matrix
    return(data.return)
}
