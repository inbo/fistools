#' label_extracter
#'
#' @description
#' A function to extract specific columns from the DMOGG dataset based on provided labels. The user can choose to extract all columns, select specific columns, or choose from predefined groups of columns. Additionally, the user can opt to include info about the labels presence in different datasets to the return dataset.
#'
#' @param label A vector of labels to filter the dataset on. These should be in the form of ANBjjjjlabeltype######.
#' @param columns A character string specifying which columns to extract. Options are "all" (default), "select", "list", or "group".
#' - `all`: extracts all columns from the dataset.
#' - `select`: allows the user to interactively select columns from the dataset.
#' - `list`: extracts columns specified in the `column_list` argument.
#' - `group`: allows the user to choose from predefined groups of columns (e.g., "comp", "georef", "okl", "gewicht", "geslacht", "leeftijd_cat", "toek", "coord").
#' @param column_list A vector of column names to extract when `columns` is set to "list". This argument is ignored for other values of `columns`.
#' @param choice A character string specifying the group of columns to extract when `columns` is set to "group". Options include "comp", "georef", "okl", "gewicht", "geslacht", "leeftijd_cat", "toek", and "coord". This argument is ignored for other values of `columns`.
#' @param presence A boolean indicating whether to include information about the presence of the labels in the "DMOGG" dataset. Default is FALSE.
#' @param dataset A character string specifying the dataset to extract from. Currently, only "DMOGG" is supported. Default is "DMOGG".
#' @param email een character met het email adres van de gebruiker. Wordt gebruikt voor authenticatie bij het updaten van de google drive bestanden. Standaard wordt het email adres uit de system variables gehaald, indien deze niet bestaat zal er een popup verschijnen waarin je je email adres kan ingeven.
#'
#' @details
#' The function checks the validity of the input parameters and reads the specified dataset. It then filters the dataset based on the provided labels and extracts the specified columns.
#' If `presence` is set to TRUE, it also joins information about the presence of the labels in the "DMOGG" dataset. Presence data is retrieved using the `label_selecter` function, which may have access restrictions. If you encounter issues with retrieving presence data, try setting `presence` to FALSE. If `presence` is set to FALSE only labels present in the "DMOGG" dataset are returned. If presence is set to TRUE all labels are returned, labels not present in DMOGG get FALSE in the DMOG_GEO column.
#' Finally, it adds a column indicating the dataset and returns the extracted data.
#' When using the "select" option for `columns`, the user will be prompted to choose which columns to extract from the dataset. When using the "group" option, the user can choose from predefined groups of columns that are relevant for different types of analyses.
#'
#' @return A data frame containing the extracted columns for the specified labels, with an additional column indicating the dataset. If `presence` is set to TRUE, it also includes information about the presence of the labels in different datasets.
#' @author Sander Devisscher
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: Extract all columns for specific labels
#' data_all <- label_extracter(label = c("ANB2024REEGEIT004002",
#' "ANB2024REEGEIT004001"),
#'                                      columns = "all")
#'
#' # Example 2: Interactively select columns to extract for specific labels
#' data_select <- label_extracter(label = c("ANB2024REEGEIT004002",
#' "ANB2024REEGEIT004001"),
#'                                         columns = "select")
#'
#' # Example 3: Extract specific columns from a list for specific labels
#' data_list <- label_extracter(label = c("ANB2024REEGEIT004002",
#' "ANB2024REEGEIT004001"),
#' columns = "list",
#' column_list = c("label_nummer_samen", "onderkaaklengte_comp",
#' "geslacht_comp"))
#'
#' # Example 4: Extract a predefined group of columns for specific labels
#' data_group <- label_extracter(label = c("ANB2024REEGEIT004002",
#' "ANB2024REEGEIT004001"),
#'                                         columns = "group",
#'                                         choice = "comp")
#'}
#'
label_extracter <- function(label,
                            columns = "all",
                            column_list,
                            choice,
                            presence = FALSE,
                            dataset = "DMOGG",
                            email = Sys.getenv("email")) {

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
    Data <- read_dmogg(email = email)
  }

  # Calculate Data_Extract ####
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
  # Add presence data ####
  if(presence == TRUE){
    warning("You have selected presence = TRUE, due to access restrictions this step may fail. Ifso try setting presence = FALSE")
    presence_tbl <- label_selecter(label,
                                   email = email)
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
