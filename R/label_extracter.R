label_extracter <- function(label,
                            columns = "all",
                            column_list,
                            choice,
                            presence = FALSE,
                            dataset = "DMOGG"){

  # Checks ####
  correct_columns <- c("all", "select", "list", "group")
  if(!columns %in% correct_columns){
    stop("ERROR 001: De waarde voor columns is geen correcte optie!! Kies uit 'all', 'select', 'list' of 'group'")
  }

  if(check(label) == 0){
    stop("ERROR 002: Waarde voor label ontbreekt!! Gelieve minstens 1 label toe te voegen in ANBjjjjlabeltype###### - vorm.")
  }

  if(!dataset %in% c("DMOGG", "DMOG")){
    stop("ERROR 003: De gevraagde dataset is niet compatibel met deze functie!! Bedoelde je DMOGG of DMOG")
  }

  if(dir.exists("../backoffice-wild-analyse/")){

  }else{
    stop("ERROR 004: De inbo/backoffice-wild-analyse - repo kan niet worden gevonden. Open github desktop en clone deze repo!")
  }

  #Read Data
  if(dataset == "DMOGG"){
    print("dataset is dieren met onderkaakgegevens georef")
    Data <- read_delim(here("../backoffice-wild-analyse/Data/Interim/Dieren_met_onderkaakgegevens_georef.csv"), delim = ";",
                       col_types = cols(afschot_datum2 = col_date(format = "%Y-%m-%d"),
                                        afschot_tijdstip = col_character(),
                                        PuntLocatieTypeID = col_integer(),
                                        Xcoordinaat.x = col_double(),
                                        Ycoordinaat.y = col_double(),
                                        aantal_embryos_labo = col_character(),
                                        opmerkingen.x = col_character(),
                                        opmerkingen.y = col_character(),
                                        opmerkingen_laboratorium = col_character(),
                                        ea_nummer_oud = col_character(),
                                        retournering = col_character(),
                                        label_referentie = col_character(),
                                        leeftijdcategorie_onderkaak_gs = col_character(),
                                        groepsgrootte = col_integer()))
  }
  if(dataset == "DMOG"){
    print("dataset is dieren met onderkaakgegevens")
    Data <- read_csv(here("../backoffice-wild-analyse/Data/Interim/Dieren_met_onderkaakgegevens.csv"),
                     col_types = cols(afschot_datum2 = col_date(format = "%Y-%m-%d"),
                                      afschot_tijdstip = col_character(),
                                      PuntLocatieTypeID = col_integer(),
                                      Xcoordinaat = col_double(),
                                      Ycoordinaat = col_double(),
                                      aantal_embryos_labo = col_character(),
                                      opmerkingen.x = col_character(),
                                      ea_nummer_oud = col_character(),
                                      retournering = col_character(),
                                      label_referentie = col_character(),
                                      leeftijdcategorie_onderkaak_gs = col_character()))
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
      if(is_empty(grep("label_nummer_samen", prompt, value = TRUE))){
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
          if(dataset == "DMOGG"){
            choices <- c("comp", "georef", "okl", "gewicht", "geslacht", "leeftijd_cat", "toek", "coord")
            toek <- c("label_nummer_samen",
                      "KboNummer_Toek_integer",
                      "KboNummer_Toek",
                      "WBE_Naam_Toek",
                      "AfschotplanNummer",
                      "nummer_afschotplan")
          }
          if(dataset == "DMOG"){
            choices <- c("comp", "okl", "gewicht", "geslacht", "leeftijd_cat", "toek", "coord")
            toek <- c("label_nummer_samen",
                      "KboNummer_Toek",
                      "WBE_Naam_Toek",
                      "nummer_afschotplan")
          }

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
          if(dataset == "DMOGG"){
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
          }else{
            georef <- "label_nummer_samen"
            coord <- c("label_nummer_samen",
                       "Xcoordinaat",
                       "Ycoordinaat",
                       "PuntLocatieTypeID",
                       "verbatimLatitude",
                       "verbatimLongitude",
                       "verbatimCoordinateUncertainty")
          }

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
      filter(label_nummer_samen %in% label) %>%
      dplyr::select(prompt)
  }
  #Add presence data
  if(presence == TRUE){
    source("../backoffice-wild-analyse/Functies/label_selecter.R")
    presence_tbl <- label_selecter(label)
    presence_tbl <-
      presence_tbl %>%
      dplyr::select(INPUTLABEL, DMOG_GEO)
    Data_Extract <-
      Data_Extract %>%
      full_join(presence_tbl, by = c("label_nummer_samen" = "INPUTLABEL"))
  }

  #Add dataset column
  Data_Extract <- Data_Extract %>%
    mutate(dataset = dataset)

  return(Data_Extract)
}
