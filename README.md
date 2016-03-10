# gp-prescriptions
Working with OpenDataNI GP Prescribing Data

## Creating a prescriptions dataset by combining a number of months
[`find-combine.R`](find-combine.R) allows you to enter a range of months (e.g. 1:12, 1:3, 5:9) to download, combine and create a new data file from. '1' is the most recent month the data is available from on [OpenDataNI](https://www.opendatani.gov.uk/dataset/gp-prescribing-data), so count back from that. This uses the OpenDataNI datastore API to find and download the data. ([Datapackage {json})](https://www.opendatani.gov.uk/api/3/action/package_show?id=a7b76920-bc0a-48fd-9abf-dc5ad0999886)

## Adding numbers of patients to a prescriptions dataset
Using the quarterly [GP Practice Reference Files](http://www.hscbusiness.hscni.net/services/2471.htm), we can relate the number of patients in each practice's list to the prescriptions. [`add-patients.R`](add-patients.R) does this for you by adding an interger variable `patients` to each observation in your prescriptsion dataset (e.g. for the one we have created above). 

Providing that you apply the relevant Practice Reference Files correctly, the number of patients in the relevant *quarter* will be applied, even where a number of quarters are present in your dataset.

This is beneficial because it allows prescribing rates (e.g. number of prescriptions per 1000 patients) to be calculated, adjusting for variations in the `total.quantity`.

## Mapping practices
(`map-practices.R`)[map-practices.R] takes your GP Practice Reference File (object `practices`) and adds ONS/NISRA names and codes for the constituency, ward, NI council and Census super output area for each practice, as well as latitudes and longitudes. 
