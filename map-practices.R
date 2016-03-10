## Taking input from a Practices Reference File (environment object: 'practices') this script
## finds names and codes for constituencies, NI councils, wards and NISRA super output areas, as
## well as latitudes and longitudes for each practice, in the new object 'postcode_details'

## Powered by the MapIt API from MySociety. 
## See http://mapit.mysociety.org/ for licensing terms for the use of this service,
## and for the licensing of postcode data.

library(httr)

url <- 'http://mapit.mysociety.org/postcode/'

postcode_details <- data.frame(practice = practices$PracNo[unique(practices$PracNo)], pcd1 = practices$Postcode[unique(practices$PracNo)])

postcode_details <- within(postcode_details, pcd2 <- gsub(" ","",pcd1))

addcols <- c("wmc_name", "wmc_code", "lgd_name", "lgd_code", "soa_name", 
             "soa_code", "ward_name", "ward_code", "lat", "lon")

for (i in addcols){
  postcode_details[,i] <- NA
}

for (r in 1:length(postcode_details)){
  Sys.sleep(1)
  p <- postcode_details[r,]$pcd2
  response <- GET(paste0(url,p))
  content <- content(response)
  areas <- content$areas
  for (x in 1:length(areas)){
    if(areas[[x]]$type == 'WMC'){
      wmc_name <- areas[[x]]$name
      wmc_code <- areas[[x]]$codes$gss
    }
    if(areas[[x]]$type == 'LGD'){
      lgd_name <- areas[[x]]$name
      lgd_code <- areas[[x]]$codes$gss
    }
    if(areas[[x]]$type == 'OLF'){
      soa_name <- areas[[x]]$name
      soa_code <- areas[[x]]$codes$ons
    }
    if(areas[[x]]$type == 'LGW'){
      ward_name <- areas[[x]]$name
      ward_code <- areas[[x]]$codes$gss
    }
  }
  postcode_details[r,]$wmc_name <- wmc_name
  postcode_details[r,]$wmc_code <- wmc_code
  postcode_details[r,]$lgd_name <- lgd_name
  postcode_details[r,]$lgd_code <- lgd_code
  postcode_details[r,]$soa_name <- soa_name
  postcode_details[r,]$soa_code <- soa_code
  postcode_details[r,]$ward_name <- ward_name
  postcode_details[r,]$ward_code <- ward_code
  postcode_details[r,]$lat <- content$wgs84_lat
  postcode_details[r,]$lon <- content$wgs84_lon
}
