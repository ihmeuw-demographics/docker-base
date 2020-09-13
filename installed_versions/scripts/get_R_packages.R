library(data.table)

args = commandArgs(trailingOnly=TRUE)
VERSION_TAG = args[1]

installed <- data.table(installed.packages())
installed <- installed[, .SD, .SDcols = c('Package', 'Version')]
readr::write_csv(installed, paste0('/tmp/', VERSION_TAG, '/R_packages.csv'))
