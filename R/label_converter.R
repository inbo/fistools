label_converter <- function(input, id_column, labelnummer_column, soort_column, labeltype_column, jaar_column){
  
  require(tidyverse)
  
  if(!is.data.frame(input)){
    stop("input is geen dataframe")
  }
  temp_input <- input
  temp_input$id <- input[[id_column]]
  temp_input$labelnummer_ruw <- input[[labelnummer_column]]
  temp_input$soort <- input[[soort_column]]
  temp_input$labeltype <- input[[labeltype_column]]
  temp_input$jaar <- input[[jaar_column]]
  
  temp_output <- 
    temp_input %>% 
    dplyr::select(id, labelnummer_ruw, soort, labeltype, jaar) %>% 
    mutate(soort = toupper(soort)) %>% 
    mutate(soort = case_when(soort == "EVERZWIJN" ~ "WILD ZWIJN",
                             TRUE ~ as.character(soort))) %>% 
    mutate(labeltype = case_when(soort != "REE" ~ soort,
                                 TRUE ~ case_when(grepl("kits", labeltype, perl = TRUE) ~ paste0(soort,"KITS"),
                                           labeltype == "geit" ~ paste0(soort,"GEIT"),
                                           labeltype == "bok" ~ paste0(soort, "BOK"),
                                           TRUE ~ as.character(NA)))) %>% 
    mutate(labelnummer_num = as.numeric(labelnummer_ruw)) %>% 
    mutate(labelnummer_int = str_pad(labelnummer_num, width = 6, side = "left", pad = 0)) %>% 
    mutate(labelnummer_pros = paste0("ANB",jaar,labeltype,labelnummer_int)) %>% 
    mutate(labelnummer = case_when(!is.na(labelnummer_num) ~ labelnummer_pros,
                                   TRUE ~ gsub("-", "", labelnummer_ruw))) %>% 
    filter(!grepl("NA", labelnummer)) %>% 
    dplyr::select(id, labelnummer)
  
  return(temp_output)
}