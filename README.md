# gp-prescriptions
Working with OpenDataNI GP Prescribing Data

## Combining a number of months into a new dataset
[clean-combine.R](clean-combine.R) allows you to enter a range of months (e.g. 1:12, 1:3, 5:9) to download, combine and create a new data file from. '1' is the most recent month the data is available from on [OpenDataNI](https://www.opendatani.gov.uk/dataset/gp-prescribing-data), so count back from that.
