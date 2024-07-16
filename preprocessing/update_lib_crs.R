# convert ./data_raw/Lib_CRS.csv to ./data/lib_crs.rds

library(readr)

df <- read_csv("./data_raw/Lib_CRS.csv")

saveRDS(df, "./data/lib_crs.rds")
