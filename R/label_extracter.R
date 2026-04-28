label_extracter <- function(label,
                            columns = "all",
                            column_list,
                            choice,
                            presence = FALSE,
                            dataset = "DMOGG"){

  # Checks ####
  ## Columns ####
  correct_columns <- c("all", "select", "list", "group")
  if(!columns %in% correct_columns){
    stop("ERROR 001: De waarde voor columns is geen correcte optie!! Kies uit 'all', 'select', 'list' of 'group'")
  }

  ## Label ####
  if(check(label) == 0){
    stop("ERROR 002: Waarde voor label ontbreekt!! Gelieve minstens 1 label toe te voegen in ANBjjjjlabeltype###### - vorm.")
  }

  ## Dataset ####
  if(!dataset %in% c("DMOGG")){
    stop("ERROR 003: De gevraagde dataset is niet compatibel met deze functie!! Bedoelde je DMOGG")
  }

  # Read Data ####
  if(dataset == "DMOGG"){
    print("dataset is dieren met onderkaakgegevens georef")
    Data <- read_dmogg()
  }

  #Calculate Data_Extract
  if(columns == "all"){
    Data_Extract <-
      Data %>%
      filter(label_nummer_samen %in% label)
  }else{
    if(columns == "select"){
      column_list <- colnames(Data)
      prompt <- select.list(choices = column_list, title = "Welke kolommen wil je extraheren ?", multiple = TRUE)
      if(purrr::is_empty(grep("label_nummer_samen", prompt, value = TRUE))){
        prompt <- append("label_nummer_samen", prompt)
      }
    }else{
      if(columns == "list"){
        prompt <- column_list
        if(is_empty(grep("label_nummer_samen", prompt, value = TRUE))){
          prompt <- append("label_nummer_samen", prompt)
        }

      }else{
        if(columns == "group"){
          print("under construction")
          choices <- c("comp", "georef", "okl", "gewicht", "geslacht", "leeftijd_cat", "toek", "coord")
          toek <- c("label_nummer_samen",
                    "KboNummer_Toek_integer",
                    "KboNummer_Toek",
                    "WBE_Naam_Toek",
                    "AfschotplanNummer",
                    "nummer_afschotplan")
          comp <- c("label_nummer_samen",
                    "onderkaaklengte_comp",
                    "onderkaaklengte_comp_bron",
                    "aantal_embryos",
                    "aantal_embryos_bron",
                    "leeftijd_comp",
                    "leeftijd_comp_bron",
                    "geslacht_comp",
                    "geslacht_comp_bron",
                    "ontweid_gewicht",
                    "type_comp")

          georef <- c("label_nummer_samen",
                      "NisCode_Georef",
                      "KboNummer_Georef",
                      "FaunabeheerDeelzone",
                      "FaunabeheerZone",
                      "provincie",
                      "WBE_Naam_Georef",
                      "NisCode_Oorsprong",
                      "KboNummer_Oorsprong",
                      "FaunabeheerDeelzone_Oorsprong",
                      "FaunabeheerZone_Oorsprong",
                      "Provincie_Oorsprong",
                      "Georef",
                      "GeorefCode")
          coord <- c("label_nummer_samen",
                     "Xcoordinaat.x",
                     "Ycoordinaat.x",
                     "Xcoordinaat.y",
                     "Ycoordinaat.y",
                     "PuntLocatieTypeID",
                     "verbatimLatitude",
                     "verbatimLongitude",
                     "verbatimCoordinateUncertainty")
          okl <- c("label_nummer_samen",
                   "onderkaaklengte_comp",
                   "onderkaaklengte_comp_bron",
                   "lengte_mm",
                   "onderkaaklengte_links",
                   "onderkaaklengte_rechts",
                   "beschadigd")
          gewicht <- c("label_nummer_samen",
                       "ontweid_gewicht",
                       "ontweid_gewicht_el",
                       "ontweid_gewicht_MF")
          geslacht <- c("label_nummer_samen",
                        "geslacht_comp",
                        "geslacht_comp_bron",
                        "geslacht_el",
                        "geslacht_labo")
          leeftijd_cat <- c("label_nummer_samen",
                            "leeftijd_comp",
                            "leeftijd_comp_bron",
                            "leeftijdcategorie_MF",
                            "leeftijdcategorie_onderkaak",
                            "leeftijdcategorie_onderkaak_gs")
          if(check(choice) == 0){
            choice <- menu(choices, title = "Welke groep kolommen wil je extraheren?")
            prompt <- get(choices[choice])
          }else{
            choice <- tolower(choice)
            if(choice %in% choices){
              prompt <- get(choice)
            }else{
              print(paste0("WARNING 001: ", choice, " behoort niet tot de opties voor choice."))
              choice <- menu(choices, title = "Welke groep kolommen wil je extraheren?")
              prompt <- get(choices[choice])
            }
          }

        }
      }
    }
    Data_Extract <-
      Data %>%
      dplyr::filter(label_nummer_samen %in% label) %>%
      dplyr::select(prompt)
  }
  #Add presence data
  if(presence == TRUE){
    warning("You have selected presence = TRUE, due to access restrictions this step may fail. Ifso try setting presence = FALSE")
    presence_tbl <- label_selecter(label)
    presence_tbl <-
      presence_tbl %>%
      dplyr::select(INPUTLABEL, DMOG_GEO)
    Data_Extract <-
      Data_Extract %>%
      dplyr::full_join(presence_tbl, by = c("label_nummer_samen" = "INPUTLABEL"))
  }

  #Add dataset column
  Data_Extract <- Data_Extract %>%
    dplyr::mutate(dataset = dataset)

  return(Data_Extract)
}
