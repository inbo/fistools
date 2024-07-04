#' label converter
#'
#' @description
#' Script to convert labelnummer, soort en/of labeltype en jaar into afschotlabel
#'
#' @param input a dataframe containing the necessary columns.
#' @param id_column a character string pointing to a column used to link result with input.
#' @param labelnummer_column a character string pointing to the column containing label numbers.
#' @param soort_column a character string pointing to the column containing species.
#' @param labeltype_column a character string pointing to the column containing label types.
#' @param jaar_column a character string pointing to the column containing years.
#' @param output_style a charcter string specifiying the output style. Can be "eloket" or "labo". Default is "eloket".
#'
#' @details
#' The input dataframe should a least contain a id_column & labelnummer_column
#' other values can be 'hardcoded'.
#'
#' @return a dataframe containing 2 columns id & label
#'
#' @examples
#' \dontrun{
#' }
#'
#' @export


label_converter <- function(input,
                            id_column,
                            labelnummer_column,
                            soort_column,
                            labeltype_column,
                            jaar_column,
                            output_style = "eloket"){
  # CHECKS ####
  ## input is a data.frame ? ####
  if(!is.data.frame(input)){
    stop("input is geen dataframe")
  }else{
    temp_input <- input
  }

  ## id_column in input ? ####
  if(!id_column %in% names(input)){
    stop(paste0("id_column: ", id_column, " is not present in input"))
  }else{
    temp_input$id <- temp_input[[id_column]]
  }

  ## labelnummer_column in input ? ####
  if(!labelnummer_column %in% names(input)){
    stop(paste0("labelnummer_column: ", labelnummer_column, " is not present in input"))
  }else{
    temp_input$labelnummer_ruw <- as.integer(temp_input[[labelnummer_column]])

    nonIntLbl <- sum(is.na(temp_input$labelnummer_ruw))

    if(nonIntLbl > 0){
      warning(paste0(nonIntLbl, " rows have a incorrect labelnumber and will thus be removed"))
      temp_input <- temp_input %>%
        dplyr::filter(!is.na(labelnummer_ruw))
    }
  }

  ## soort_column ####
  standard_spec <- c("wild zwijn", "ree", "damhert", "edelhert")
  bas_zwijn <- c("zwijn", "everzwijn", "boar", "sus scrofa")
  bas_ree <- c("reegeit", "reebok", "reekits", "smallree", "jaarlingbok", "capreolus capreolus")
  bas_damhert <- c("dama dama")
  bas_edelhert <- c("cervus elaphus")

  ### soort_column is in input ? ####
  if(!soort_column %in% names(input)){
    #### soort_column is not in input ####
    warning(paste0("soort_column: ", soort_column, " is not a column of input >> checking if its a allowed species"))

    if(length(soort_column) > 1){
      ##### soort_column consists of more than 1 species ####
      stop(paste0("The soort_column consists of more than 1 species. Add this value to the input dataframe manually. The function has no way to now which species should be used when."))
    }
    if(tolower(soort_column) %in% standard_spec){
      ##### soort_column is standard species ####
      # > add soort to input with soort_column as value
      print("soort_column is standard species >> adding to input")
      temp_input$soort <- toupper(soort_column)
    }else{
      if(tolower(soort_column) %in% c(bas_zwijn, bas_ree, bas_damhert, bas_edelhert)){
        #### soort_column is bastardised ####
        # > add soort to input with equivalent standard species as value
        print("soort_column is bastardised")
        if(tolower(soort_column) %in% bas_zwijn){
          # soort_column is a bastard form of wild zwijn
          print(">> adding 'WILD ZWIJN' to input")
          temp_input$soort <- "WILD ZWIJN"
        }
        if(tolower(soort_column) %in% bas_ree){
          # soort_column is a bastard form of ree
          print(">> adding 'REE' to input")
          temp_input$soort <- "REE"
        }
        if(tolower(soort_column) %in% bas_damhert){
          # soort_column is a bastard form of damhert
          print(">> adding 'DAMHERT' to input")
          temp_input$soort <- "DAMHERT"
        }
        if(tolower(soort_column) %in% bas_edelhert){
          # soort_column is a bastard form of edelhert
          print(">> adding 'EDELHERT' to input")
          temp_input$soort <- "EDELHERT"
        }
      }else{
        #### soort_column is not a standard nor bastardised species & soort_column is not in input ####
        stop("soort_column: ", soort_column, " is not a column of input nor is it a allowed species")
      }
    }
  }else{
    #### soort_column is in input ####
    # > add soort to input with content of soort_column as value
    temp_input$soort <- temp_input[[soort_column]]

    # > standardise soort
    temp_input <- temp_input %>%
      dplyr::mutate(soort = dplyr::case_when(tolower(soort) %in% standard_spec ~ toupper(soort),
                                             tolower(soort) %in% bas_zwijn ~ "WILD ZWIJN",
                                             tolower(soort) %in% bas_ree ~ "REE",
                                             tolower(soort) %in% bas_damhert ~ "DAMHERT",
                                             tolower(soort) %in% bas_edelhert ~ "EDELHERT",
                                             TRUE ~ NA_character_))

    if(sum(is.na(temp_input$soort)) > 0){
      #### soort_column has non valid species ####
      # > remove non valid species
      temp_input <- temp_input %>%
        dplyr::filter(!is.na(soort))
      warning(paste0(sum(is.na(temp_input$soort)), " rows from input have non valid species & are removed"))

      if(nrow(temp_input) == 0){
        #### no valid species in input ####
        stop("No valid species in input")
      }
    }
  }


  ## labeltype_column ####
  standard_lbltype <- c("reegeit", "reebok", "reekits")

  if(unique(temp_input$soort) == "REE"){
    ### soort is REE ####
    # in case of REE the labeltype_column should indicate either a column in input or a standard labeltype
    if(!labeltype_column %in% names(input)){
      #### labeltype_column is not in input ####
      # > indicates a value not a column name
      warning(paste0("labeltype_column: ", labeltype_column, " is not present in input >> checking if its a allowed labeltype"))

      if(length(labeltype_column) > 1){
        #### labeltype_column consists of more than 1 labeltype ####
        stop("The labeltype_column consists of more than 1 labeltype. Add this value to the input dataframe manually. The function has no way to now which labeltype should be used when.")
      }

      if(labeltype_column %in% standard_lbltype){
        #### labeltype_column is a standard labeltype ####
        # > all labels will be the same type
        # > add labeltype to input with labeltype_column as value
        temp_input$labeltype <- labeltype_column
      }else{
        #### labeltype_column is not a standard labeltype & labeltype_column is not in input ####
        stop("labeltype_column: ", labeltype_column, " is not a column of input nor is it a allowed labeltype")
      }
    }else{
      #### labeltype_column is in input ####
      # > indicates a column name
      # > add labeltype to input with content of labeltype_column as value
      temp_input$labeltype <- temp_input[[labeltype_column]]
    }
  }

  ## jaar_column ####
  ### jaar_column is in input ? ####
  if(!jaar_column %in% names(input)){
    warning(paste0("jaar_column: ", jaar_column, " is not a column of input >> checking if its a allowed year"))
    if(length(jaar_column) > 1){
      stop("The jaar_column consists of more than 1 year. Add this value to the input dataframe manually. The function has no way to now which year should be used when.")
    }
    jaar_column <- as.integer(jaar_column)
    ### jaar_column is integer & not future ####
    if(jaar_column >= 2014 & jaar_column <= lubridate::year(Sys.Date())){
      temp_input$jaar <- jaar_column
    }else{
      stop("The jaar_column is neither a column of input nor a valid year (>=2014 & <= current year)")
    }
  }else{
    temp_input$jaar <- input[[jaar_column]]
  }

  ## output_style is allowed ? ####
  if(!output_style %in% c("eloket", "labo")){
    stop("output_style is not one of 'eloket' or 'labo'")
  }

  # create labels ####
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
