#!/usr/bin/Rscript
library('getopt')
##library(legisdados)
## 'br_chamber/source_data/votes/'

##getQ options, using the spec as defined by the enclosed list.
##we read the options

## 1 means the argument is required, 0 no arg, 2 optional
## give a zip file
opt <- getopt(matrix(c( 'file' , 'f', 1, "character",
                       'basedir', 'b', 1, 'character'
                       ), ncol=4, byrow=TRUE))


if (is.null(opt$basedir) ) {
    opt$basedir <- "."
}

regtest <- FALSE
if (regtest) {
    opt$file <- paste(opt$basedir,"data/br_chamber/source_data/www.camara.gov.br/internet/plenario/result/votacao/Maio08.zip")
}

basedir <- opt$basedir
source(paste(basedir, "Rpackages/legisdados/load.R", sep="/"), echo=FALSE)

## tmp directory
tmpdir <- tempdir()

## unzip to temp directory
tmp <- unzip(opt$file,junkpaths=TRUE,exdir=tmpdir)

## unzip zip files inside zip files, if they exist
files <- dir(tmpdir, pattern=".*\\.zip$", full.names=TRUE)
if (length(files)>0) {
    tmp <- lapply(files, function(x) unzip(x,junkpaths=TRUE,exdir=tmpdir))
}

## get the data
LVfiles <- dir(tmpdir, pattern="LV", full.names=TRUE)
res <- get.votos(LVfiles)

fn <- basename(opt$file)
f <- function(x) paste(basedir,"data/br_chamber/output_data/votes/",x,sep="/")
f1 <- f(gsub(".zip$", "_votos.csv", fn))
f2 <- f(gsub(".zip$", "_votacoes.csv", fn))
f3 <- f(gsub(".zip$", ".RData", fn))

## output to csv files and RData files
write.csv(res[["votos"]], file=f1
          , row.names=FALSE)

write.csv(res[["votacoes"]], file=f2
          , row.names=FALSE)

save(res, file=f3)



