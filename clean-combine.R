library(httr)
library(plyr)
library(XML)

range <- 1:2 ## last x months to work with. 1 = most recent month on https://www.opendatani.gov.uk/dataset/gp-prescribing-data

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

# Download the html for the dataset webpage and create lists of all available resources
webpage <- content(GET("http://www.opendatani.gov.uk/dataset/gp-prescribing-data"), as="text")
htmldoc <- htmlParse(webpage)
dataids <- xpathSApply(htmldoc, "//li[@class='resource-item']", xmlGetAttr,"data-id")
titles <- xpathSApply(htmldoc, "//a[@class='heading']", xmlGetAttr, "title")
df <- data.frame(dataids,titles)

## Create a list of the files that we actually want (the range)
filenames <- c()
for (i in range){
  name <- paste(df[2][i,],'.csv',sep='')
  filenames <- append(filenames,as.character(name))
}

## Download the actual files
datastoreUrl <- "https://www.opendatani.gov.uk/datastore/dump/"
for (i in range) {
  download.file(paste(datastoreUrl,df[1][i,],sep=''), paste(df[2][i,],'.csv',sep=''),method='libcurl')
}

combined <- c()

## Then, we can stitch the files together (it doesn't matter on the order, the month number is a field):
for (i in filenames){
    temp_dataset <- read.csv(i, header=TRUE, na.strings="-")
    combined <- rbind.fill(combined, temp_dataset)
    rm(temp_dataset)
  }

colnames(combined) <- newCols

## Now, let's sort by the medicine type using the British National Formulary (BNF) coding system, then month:
attach(combined)
combined <- combined[order(bnf.chapter, bnf.section, bnf.paragraph, 
                           bnf.sub.paragraph, bnf.code, year, month),]
detach(combined)

## Write the combined file to disk
write.table(combined, row.names=FALSE, paste("combined-",range,"-mostrecentmonths-",Sys.Date(),".csv",sep=""))
print("Done")
