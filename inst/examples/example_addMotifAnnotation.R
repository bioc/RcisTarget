
##################################################
# Setup & previous steps in the workflow:

#### Gene sets
# As example, the package includes an Hypoxia gene set:
txtFile <- paste(file.path(system.file('examples', package='RcisTarget')),
                 "hypoxiaGeneSet.txt", sep="/")
geneLists <- list(hypoxia=read.table(txtFile, stringsAsFactors=FALSE)[,1])

#### Databases
## Motif rankings: Select according to organism and distance around TSS
## (See the vignette for URLs to download)
# motifRankings <- importRankings("~/databases/hg38_10kbp_up_10kbp_down_full_tx_v10_clust.genes_vs_motifs.rankings.feather")
# data("motifAnnotations_hgnc") # human TFs (for motif collection 10)

## For this example we will use a SUBSET of the ranking/motif databases:
library(RcisTarget.hg19.motifDBs.cisbpOnly.500bp)
data(hg19_500bpUpstream_motifRanking_cispbOnly)
motifRankings <- hg19_500bpUpstream_motifRanking_cispbOnly

## Motif - TF annotation:
data(motifAnnotations_hgnc_v9) # human TFs (for motif collection 9)
motifAnnotation <- motifAnnotations_hgnc_v9

### Run RcisTarget
# Step 1. Calculate AUC
motifs_AUC <- calcAUC(geneLists, motifRankings)

##################################################

### (This step: Step 2)
# Before starting: Setup the paralell computation
library(BiocParallel); register(MulticoreParam(workers = 2)) 
# Select significant motifs, add TF annotation & format as table
motifEnrichmentTable <- addMotifAnnotation(motifs_AUC,
                                           motifAnnot=motifAnnotation)

# Alternative: Modifying some options
motifEnrichment_wIndirect <- addMotifAnnotation(motifs_AUC, nesThreshold=2, 
        motifAnnot=motifAnnotation,
        highlightTFs = "HIF1A", 
        motifAnnot_highConfCat=c("directAnnotation"), 
        motifAnnot_lowConfCat=c("inferredBy_MotifSimilarity",
                                "inferredBy_MotifSimilarity_n_Orthology",
                                "inferredBy_Orthology"),
        digits=3)

# Getting TFs for a given TF:
motifs <- motifEnrichmentTable$motif[1:3]

getMotifAnnotation(motifs, motifAnnot=motifAnnotation)
getMotifAnnotation(motifs, motifAnnot=motifAnnotation, returnFormat="list")

### Exploring the output:
# Number of enriched motifs (Over the given NES threshold)
nrow(motifEnrichmentTable)

# Interactive exploration
motifEnrichmentTable <- addLogo(motifEnrichmentTable)
DT::datatable(motifEnrichmentTable, filter="top", escape=FALSE,
              options=list(pageLength=50))
# Note: If using the fake database, the results of this analysis are meaningless

# The object returned is a data.table (for faster computation),
# which has a diferent syntax from the standard data.frame or matrix
# Feel free to convert it to a data.frame (as.data.frame())
motifEnrichmentTable[,1:6]


##################################################
# Next step (step 3, optional):
\dontrun{
  motifEnrichmentTable_wGenes <- addSignificantGenes(motifEnrichmentTable,
                                                     geneSets=geneLists,
                                                     rankings=motifRankings,
                                                     method="aprox")
}
