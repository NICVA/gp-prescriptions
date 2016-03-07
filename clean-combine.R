library(jsonlite)
library(plyr)


range <- 1:6 ## x months to work with. Can change start and end of range. 
             ## 1 = most recent month on https://www.opendatani.gov.uk/dataset/gp-prescribing-data
             ## So be aware you're working backwards

if(dir.exists('~/GP Prescribing Data') != TRUE){
  dir.create('~/GP Prescribing Data')
}

setwd("~/GP Prescribing Data/")
wd <- getwd()

newCols<-as.character(c("id","practice","year","month","vtm_nm","vmp_nm","amp_nm",
                        "presentation","strength","total.items","total.quantity",
                        "gross.cost","actual.cost","bnf.code","bnf.chapter",
                        "bnf.section","bnf.paragraph","bnf.sub.paragraph"))

cClasses<-c("integer","integer","integer","factor","factor","factor",
            "factor","factor","integer","integer",
            "numeric","numeric","factor","integer",
            "integer","integer","integer")

## Use the OpenDataNI package API for the GP prescribing dataset (providing the id doesn't change)
datapackage <- fromJSON('https://www.opendatani.gov.uk/api/3/action/package_show?id=a7b76920-bc0a-48fd-9abf-dc5ad0999886')
resources <- datapackage$result$resources

## Create a list of the files that we actually want (the range)
filenames <- c()
for (i in range){
  name <- paste(resources$name[i],'.csv',sep='')
  filenames <- append(filenames,as.character(name))
}

print(paste("Downloading and combining files between",resources$name[max(range)],"and",resources$name[min(range)]))

## Download the actual files
for (i in range) {
  download.file(resources$url[i], paste(resources$name[i],".csv",sep=''),method='libcurl')
}

combined <- c()

## Then, we can stitch the files together (it doesn't matter on the order, the month number is a field):
for (i in filenames){
  temp_dataset <- read.csv(i, header=TRUE, na.strings="-")
  combined <- rbind.fill(combined, temp_dataset)
  rm(temp_dataset)
}

colnames(combined) <- tolower(colnames(combined))

## Now, let's sort by the medicine type using the British National Formulary (BNF) coding system, then month:
attach(combined)
combined <- combined[order(bnf.chapter, bnf.section, bnf.paragraph, 
                           bnf.sub.paragraph, bnf.code, year, month),]
detach(combined)

## Write the combined file to disk
write.csv(combined, row.names=FALSE, paste("combined-prescribing-dataset-",Sys.Date(),".csv",sep=""))
print(paste("Created file for range between",min(filenames),"and",max(filenames)))
