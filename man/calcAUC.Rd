% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/01_calcAUC.R
\name{calcAUC}
\alias{calcAUC}
\alias{calcAUC,list-method}
\alias{calcAUC,character-method}
\alias{calcAUC,GeneSet-method}
\alias{calcAUC,GeneSetCollection-method}
\title{Calculate AUC}
\usage{
calcAUC(
  geneSets,
  rankings,
  nCores = 1,
  aucMaxRank = 0.03 * getNumColsInDB(rankings),
  verbose = TRUE
)

\S4method{calcAUC}{list}(
  geneSets,
  rankings,
  nCores = 1,
  aucMaxRank = 0.03 * getNumColsInDB(rankings),
  verbose = TRUE
)

\S4method{calcAUC}{character}(
  geneSets,
  rankings,
  nCores = 1,
  aucMaxRank = 0.03 * getNumColsInDB(rankings),
  verbose = TRUE
)

\S4method{calcAUC}{GeneSet}(
  geneSets,
  rankings,
  nCores = 1,
  aucMaxRank = 0.03 * getNumColsInDB(rankings),
  verbose = TRUE
)

\S4method{calcAUC}{GeneSetCollection}(
  geneSets,
  rankings,
  nCores = 1,
  aucMaxRank = 0.03 * getNumColsInDB(rankings),
  verbose = TRUE
)
}
\arguments{
\item{geneSets}{List of gene-sets to analyze.
The gene-sets should be provided as \code{\link{GeneSet}},
\code{\link{GeneSetCollection}} or character list (see examples).}

\item{rankings}{'Motif rankings' database for the required organism and
search-space (i.e. 10kbp around- or 500bp upstream the TSS).
These objects are provided in separate files, 
which can be imported with \code{importRankings()}:
\itemize{
\item \url{http://pyscenic.aertslab.org/databases/mm9-500bp-upstream-7species.mc9nr.feather}[mm9-500bp-upstream-7species.mc9nr] (Mouse, 500bp)
\item \url{http://pyscenic.aertslab.org/databases/mm9-tss-centered-10kb-7species.mc9nr.feather}[mm9-tss-centered-10kb-7species.mc9nr] (Mouse, 10kbp)
\item \url{http://pyscenic.aertslab.org/databases/hg19-500bp-upstream-7species.mc9nr.feather}[hg19-500bp-upstream-7species.mc9nr] (Human, 500bp)
\item \url{http://pyscenic.aertslab.org/databases/hg19-tss-centered-10kb-7species.mc9nr.feather}[hg19-tss-centered-10kb-7species.mc9nr] (Human, 10kbp)
\item -Coming soon- (Fly)
}
See \code{vignette("RcisTarget")} for an exhaustive list of databases.

Since the normalized enrichment score (NES) of the motif
depends on the total number of motifs in the database,
we highly recommend to use the full version of the databases (20k motifs).
A smaller version of the human databases,
containing only the 4.6k motifs from cisbp,
are available in Bioconductor:
\itemize{
\item RcisTarget.hg19.motifDBs.cisbpOnly.500bp (Human)
}}

\item{nCores}{Number of cores to use for computation.
Note: In general, using a higher number of cores (e.g. processes)
decreases overall running time.
However, it also deppends on the available memory and overall system load.
Setting nCores too high might also decrease performance.}

\item{aucMaxRank}{Threshold to calculate the AUC.
In a simplified way, the AUC value represents the fraction of genes,
within the top X genes in the ranking, that are included in the signature.
The parameter 'aucMaxRank' allows to modify the number of genes
(maximum ranking) that is used to perform this computation.
By default it is set to 5\% of the total number of genes in the rankings.
Common values range from 1 to 10\%.
See \code{vignette("RcisTarget")} for examples and more details.}

\item{verbose}{Should the function show progress messages? (TRUE / FALSE)}
}
\value{
\code{\link{aucScores}} of gene-sets (columns) by motifs (rows)
with the value of AUC for each pair as content.
}
\description{
Calculates the Area Under the Curve (AUC) of each gene-set
for each motif ranking.
This measure is used in the following steps to identify the DNA motifs
that are significantly over-represented in the gene-set.
}
\examples{
# RcisTarget workflow for advanced users:
# Running the workflow steps individually

\dontrun{
  
##################################################
#### Load your gene sets
# As example, the package includes an Hypoxia gene set:
txtFile <- paste(file.path(system.file('examples', package='RcisTarget')),
               "hypoxiaGeneSet.txt", sep="/")
geneLists <- list(hypoxia=read.table(txtFile, stringsAsFactors=FALSE)[,1])
  
#### Load databases
## Motif rankings: Select according to organism and distance around TSS
## (See the vignette for URLs to download)
motifRankings <- importRankings("hg19-500bp-upstream-7species.mc9nr.feather")

## Motif - TF annotation:
data(motifAnnotations_hgnc_v9) # human TFs (for motif collection 9)
motifAnnotation <- motifAnnotations_hgnc_v9
##################################################

#### Run RcisTarget

# Step 1. Calculate AUC
motifs_AUC <- calcAUC(geneLists, motifRankings)

# Step 2. Select significant motifs, add TF annotation & format as table
motifEnrichmentTable <- addMotifAnnotation(motifs_AUC,
                         motifAnnot=motifAnnotation)

# Step 3 (optional). Identify genes that have the motif significantly enriched
# (i.e. genes from the gene set in the top of the ranking)
motifEnrichmentTable_wGenes <- addSignificantGenes(motifEnrichmentTable,
                                                   geneSets=geneLists,
                                                   rankings=motifRankings,
                                                   method="aprox")

}
}
\seealso{
Next step in the workflow: \code{\link{addMotifAnnotation}}.

See the package vignette for examples and more details:
\code{vignette("RcisTarget")}
}
