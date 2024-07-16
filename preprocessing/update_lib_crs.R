# convert ./data_raw/Lib_CRS.csv to ./data/lib_crs.rds

library(readr)

lib_crs <- read_csv("./data_raw/Lib_CRS.csv")

save(lib_crs,file= "./data/lib_crs.rda")
