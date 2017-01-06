library(jsonlite)
library(plyr)
library(readr)
library(data.table)

## Use the OpenDataNI package API for the GP prescribing dataset (providing the id doesn't change)
datapackage <- fromJSON('https://www.opendatani.gov.uk/api/3/action/package_show?id=a7b76920-bc0a-48fd-9abf-dc5ad0999886')
resources <- datapackage$result$resources

print("Available datasets and range numbers: ")
for (i in 1:length(resources$name)){
  print(paste(i, "-", resources$name[i]))
}

range <- 1:6 ## x months to work with. Can change start and end of range. 
             ## 1 = most recent month on https://www.opendatani.gov.uk/dataset/gp-prescribing-data
             ## So be aware that you're working backwards
             ## Each month is ~60MB so the more that you download the bigger your eventual file size will be 

if(dir.exists('~/GP Prescribing Data') != TRUE){
  dir.create('~/GP Prescribing Data')
}

setwd("~/GP Prescribing Data/")
wd <- getwd()

newCols<-as.character(c("practice","year","month","vtm_nm","vmp_nm","amp_nm",
                        "presentation","strength","total_items","total_quantity",
                        "gross_cost","actual_cost","bnf_code","bnf_chapter",
                        "bnf_section","bnf_paragraph","bnf_subparagraph"))

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

## Then, we can stitch the files together (it doesn't matter on the order, the month number is a field that can be used to sort later):
combined <- c()
combined <- data.table(combined)

for (i in filenames){
  print(paste('Now reading:',i))
  temp_dataset <- read_csv(i, col_names=TRUE, na=c("-","NA",""))
  if (length(temp_dataset) > 17) {
    temp_dataset <- temp_dataset[1:17]
  }
  colnames(temp_dataset) <- newCols
  combined <- rbind.fill(combined, temp_dataset)
  rm(temp_dataset)
}

colnames(combined) <- tolower(colnames(combined))

## Now, let's sort by the medicine type using the British National Formulary (BNF) coding system, then month:
attach(combined)
combined <- combined[order(bnf_chapter, bnf_section, bnf_paragraph, 
                           bnf_sub.paragraph, bnf_code, year, month),]
detach(combined)

combofilename <- paste("combined-prescribing-dataset-",Sys.Date(),".csv",sep="")

## Write the combined file to disk.
write.csv(combined, row.names=FALSE, combofilename, fileEncoding = "UTF-8", eol="\n")
print(paste("Created file for range between",resources$name[max(range)],"and",resources$name[min(range)],". You'll find it in your environment as the data frame 'combined'"))
