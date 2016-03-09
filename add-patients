## While HSCNI has lists of GP Practices (http://www.hscbusiness.hscni.net/services/1816.htm) 
## these are only the current operating practices for the most recent month. 
## When looking at past data on prescriptions, there may be some discrepency in the practice
## numbers between the datasets (e.g. there may be practice ids for prescriptions data that 
## have since merged or closed, so you won't find them in these lists). Better is to use the 
## quarterly GP Practice Reference Files (http://www.hscbusiness.hscni.net/services/2471.htm).

library(dplyr)

setwd('~/GP Prescribing Data/practices') ## Practice Reference Files in csv format

## In this case, we're using the prescriptions dataset for all of 2015. Therefore, we need
## the Practice Reference Files for each quarter of 2015. If using another temporal prescriptions
## dataset, you'll need to change the following to the relevant quarters

## ------------------- ##
practices_jan15 <- read.csv("~/GP Prescribing Data/practices/practices_jan15.csv")
practices_apr15 <- read.csv("~/GP Prescribing Data/practices/practices_apr15.csv")
practices_jul15 <- read.csv("~/GP Prescribing Data/practices/practices_jul15.csv")
practices_oct15 <- read.csv("~/GP Prescribing Data/practices/practices_oct15.csv")

practices_jan15$quarter <- 1
practices_apr15$quarter <- 2
practices_jul15$quarter <- 3
practices_oct15$quarter <- 4

practices_jan15$year <- 2015
practices_apr15$year <- 2015
practices_jul15$year <- 2015
practices_oct15$year <- 2015

practices <- rbind(practices_jan15, practices_apr15, practices_jul15, practices_oct15)
## --------------------------- ##


findPatients <- function(df){
  df <- df %>% mutate(quarter = ceiling(as.numeric(df$month) / 3))
  withPatients <<- within(df, patients <- as.integer(practices$Registered.Patients)[match(paste(df$practice,df$quarter,df$year),paste(practices$PracNo,practices$quarter,practices$year))])
  }

## Run the function 'findPatients()' with the name of your dataset object in brackets.
## This will assign the number of patients in that practice in the relevant quarter to a
## new variable 'patients' (and create the variable 'quarter') for each row in the dataset.

## You can use the number of patients, for example, to calculate the prescriptions rate...

withPatients <- mutate(withPatients, rate.per.thousand = round(total.quantity / (patients / 1000 ),2))
head(withPatients)
