#' @title label_selecter
#'
#' @description Deze functie onderzoekt of de labels bestaan in de datasets AfschotMelding (AM), ToegekendeLabels (TL), Toekenningen_Cleaned (TL_Cleaned), Dieren_met_onderkaakgegevens (DMOG), Dieren_met_onderkaakgegevens_Georef (DMOGG).
#'
#' @param label een character (lijst) met labelnummer(s) die dienen onderzocht te worden. Dit kan in 3 vormen (volgnummer, met streepjes of zonder streepjes) of een combinatie van deze vormen aangeleverd worden
#' @param update een boolean die aangeeft of ook de nog niet wegeschreven dwh - bestanden moeten worden gecontroleerd.
#' @param label_type een een character (lijst) met labeltypes die dienen onderzocht te worden.
#' @param jaar een numerieke (lijst) van jaren die dienen onderzocht te worden.
#' @param soort een character van de soort die onderzocht dient te worden.
#' @param bo_dir een character met de directory waar de backoffice-wild-analyse repository staat.
#'
#' @details
#' De parameter `label_type`, `jaar` en `soort` zijn enkel relevant als één van
#' de labels de vorm 'volgnummer' heeft. Wanneer deze parameter niet gespecifieerd
#' worden zal een default waarde voor het jaar (2013 t.e.m. max(AfschotMelding$Jaartal))
#' en label_type (c("REEGEIT", "REEKITS", "REEBOK", "WILD ZWIJN", "DAMHERT", "EDELHERT"))
#' gebruikt worden. Wanneer soort gespecifieerd is zal de lijst van labeltypes
#' beperkt worden tot deze die op de soort betrekking hebben. Voor ree bvb wordt dit reekits, reegeit en reebok.
#'
#' De parameters `label`, `label_type`, `jaar` en `soort` kunnen als lijst aangeleverd worden.
#'
#' De parameters `label_type`, `jaar` en `soort` zijn niet hoofdlettergevoelig.
#'
#' `bo_dir` is de directory waar de backoffice-wild-analyse repository staat.
#' De functie checkt namelijk of de labels voorkomen in de lokale versie van de backoffice-wild-analyse repository.
#' Hiervoor is het belangrijk dat de backoffice-wild-analyse repository lokaal aanwezig is en de laatste versie gepulled is.
#'
#' `update` is een boolean die aangeeft of de nog niet wegeschreven dwh - bestanden moeten worden gecontroleerd.
#' om dit te kunnen lopen is een verbinding met de DWH nodig. Dit is enkel mogelijk als je met de VPN van het INBO verbonden bent.
#' Of als je aanwezig bent op een vestiging van de Vlaamse Overheid (VAC).
#'
#' @return Een dataframe met de volgende kolommen:
#' - INPUTLABEL: de input label
#' - LABELTYPE: de labeltype(s) die onderzocht worden
#' - JAAR: het jaar waarin de labels onderzocht worden
#' - AM_OLD: een boolean die aangeeft of de label(s) in AfschotMelding voorkomen **voor** de update van DWH_Connect
#' - AM_OLD_LABEL: de label(s) die in AfschotMelding voorkomen **voor** de update van DWH_Connect
#' - TL_OLD: een boolean die aangeeft of de label(s) in ToegekendeLabels voorkomen **voor** de update van DWH_Connect
#' - TL_OLD_LABEL: de label(s) die in ToegekendeLabels voorkomen **voor** de update van DWH_Connect
#' - TL_CLEANED: een boolean die aangeeft of de label(s) in Toekenningen_Cleaned voorkomen
#' - TL_CLEANED_LABEL: de label(s) die in Toekenningen_Cleaned voorkomen
#' - DMOG: een boolean die aangeeft of de label(s) in Dieren_met_onderkaakgegevens voorkomen
#' - DMOG_LABEL: de label(s) die in Dieren_met_onderkaakgegevens voorkomen
#' - DMOG_GEO: een boolean die aangeeft of de label(s) in Dieren_met_onderkaakgegevens_Georef voorkomen
#' - DMOG_GEO_LABEL: de label(s) die in Dieren_met_onderkaakgegevens_Georef voorkomen
#' *Als `update = TRUE` worden de volgende kolommen toegevoegd:*
#' - AM_NEW: een boolean die aangeeft of de label(s) in AfschotMelding voorkomen **na** de update van DWH_Connect
#' - AM_NEW_LABEL: de label(s) die in AfschotMelding voorkomen **na** de update van DWH_Connect
#' - TL_NEW: een boolean die aangeeft of de label(s) in ToegekendeLabels voorkomen **na** de update van DWH_Connect
#' - TL_NEW_LABEL: de label(s) die in ToegekendeLabels voorkomen **na** de update van DWH_Connect
#'
#' @family other
#' @export
#' @author Sander Devisscher
#'
#' @examples
#' \dontrun{
#' #enkel label:
#'  label <- c(1234, "ANB2016REEGEIT001234", "ANB-2016-REEGEIT001234")
#'  output <- label_selecter(label)
#'
#' #label & labeltype
#'  label <- c(1234, "ANB2016REEGEIT001234", "ANB-2016-REEGEIT001234")
#'  labeltype <- c("reegeit", "REEBOK")
#'  output <- label_selecter(label, label_type = labeltype)
#'
#' #label & jaar & soort
#'  label <- c(1234, "ANB2016REEGEIT001234", "ANB-2016-REEGEIT001234")
#'  soort <- "ree"
#'  jaar <- c(2018, 2019)
#'  output <- label_selecter(label, jaar = jaar , soort = soort)
#'}

label_selecter <- function(label,
                           update = FALSE,
                           label_type,
                           jaar,
                           soort,
                           bo_dir = "~/Github/backoffice-wild-analyse/"){

  # check if bo_dir is a directory
  if (!dir.exists(bo_dir)) {
    stop(paste0(bo_dir, " is geen directory >> probeer 'https://github.com/inbo/backoffice-wild-analyse' te clonen en/of 'bo_dir' te wijzgigen"))
  }

  #Datasets to check
  AfschotMelding <- readr::read_csv(paste0(bo_dir, "Basis_Scripts/Input/E_Loket/AfschotMelding.csv")) #AM_OLD
  ToegekendeLabels <- readr::read_csv(paste0(bo_dir, "Basis_Scripts/Input/E_Loket/ToegekendeLabels.csv")) #TL_OLD
  Toekenningen_Cleaned <- readr::read_delim(paste0(bo_dir,"Basis_Scripts/Interim/Toekenningen_Cleaned.csv"),
                                            ";", escape_double = FALSE, trim_ws = TRUE) #TL_CLEANED
  Dieren_met_onderkaakgegevens <- readr::read_csv(paste0(bo_dir,"Data/Interim/Dieren_met_onderkaakgegevens.csv")) #DMOG
  Dieren_met_onderkaakgegevens_Georef <- readr::read_delim(paste0(bo_dir,"Data/Interim/Dieren_met_onderkaakgegevens_Georef.csv"),
                                                           ";", escape_double = FALSE, trim_ws = TRUE) #DMOG_GEO
  if(update == TRUE){
    print("Updating E_Loket Data")
    temp_dir_update <- paste0(bo_dir, "Basis_Scripts/Basis_Scripts/Input/")
    dir.create(paste0(temp_dir_update, "/E_Loket"), recursive = TRUE, showWarnings = FALSE)
    dir.create(paste0(temp_dir_update, "/INBO"), recursive = TRUE, showWarnings = FALSE)

    # handle a failure with trycatch
    tryCatch({
      # download data from DWH
      source(paste0(bo_dir,"Basis_Scripts/DWH_connect.R"),
             local = TRUE,
             verbose = TRUE,
             chdir = TRUE)
    }, error = function(e) {
      warning("DWH_connect.R failed to run >> DWH niet upgedatet")
      update <<- FALSE
    })

    remove(dataAanvragenAfschot,
           dataAanvragenAfschotPartij,
           dataDiersoort,
           dataErkenningWBE,
           dataGeslacht,
           dataIdentificaties,
           dataKboWbe,
           dataLeeftijd,
           dataMeldingsformulier,
           dataOnderkaak,
           dataRapport,
           dataRapportGegevens,
           dataStaal,
           dataVerbandKboWbe,
           datawildschade,
           csvPath_backoffice,
           csvPath_e_loket,
           csvPathAanvragenAfschot,
           csvPathAanvragenAfschotPartij,
           csvPathAfschotMelding,
           csvPathdataRapportGegevens,
           csvPathDiersoort,
           csvPathErkenningWBE,
           csvPathGeslacht,
           csvPathIdentificaties,
           csvPathKboWbe,
           csvPathLeeftijd,
           csvPathMeldingsformulier,
           csvPathOnderkaak,
           csvPathRapport,
           csvPathSchade,
           csvPathStaal,
           csvPathVerbandKboWbe)

    unlink(paste0(temp_dir_update, "/E_Loket"), recursive = TRUE)
    unlink(paste0(temp_dir_update, "/INBO"), recursive = TRUE)
    unlink(temp_dir_update, recursive = TRUE)
    unlink(paste0(bo_dir, "/Basis_Scripts/"), force = TRUE, expand = TRUE)

  }
  #make labeltypes
  if(check(label_type) == 1){
    label_type <- toupper(label_type)
    labeltypes <- label_type
  }else{
    if(check(soort) == 1){
      soort <- toupper(soort)
      if(soort == "REE"){
        labeltypes <- c("REEGEIT", "REEKITS", "REEBOK")
      }else{
        labeltypes <- soort
      }
    }else{
      labeltypes <- c("REEGEIT", "REEKITS", "REEBOK", "WILD ZWIJN", "DAMHERT", "EDELHERT")
      warning("Using default labeltypes")
    }
  }

  #make jaren
  if(check(jaar) == 1){
    jaren <- jaar
  }else{
    jaren <- 2013
    for(i in 2014:max(AfschotMelding$Jaartal)){
      jaren <- append(jaren, i)
    }
    warning("Using default jaren")
  }

  #Make alternative label_list
  ## make empty label checker
  label_check <- data.frame(1)
  label_check <-
    label_check %>%
    dplyr::mutate(label = 1,
                  numeric = as.numeric(1)) %>%
    dplyr::select(-X1)

  ##Make progress bar
  progress_bar <- progress::progress_bar$new(total = length(label))

  for(l in label){
    progress_bar$tick()
    ##Make empty label_lists
    label_list <- NULL
    label_list4 <- NULL
    ##Check label type
    label_check <-
      label_check %>%
      dplyr::mutate(label = l,
                    numeric = as.numeric(l))
    ##Make list
    if(is.na(label_check$numeric)){
      print(paste0(l, " is a character"))
      if(grepl("-", l)){
        l2 <- gsub("-", "", l)
        label_list1 <- c(l, l2)
        labeltypes <- substr(l2, 8, nchar(l2)-6)
        jaren <- substr(l2, 4, 7)
      }else{
        l2 <- substr(l, 8, nchar(l))
        j <- substr(l,4, 7)
        l3 <- paste0("ANB-", j, "-", l2)
        label_list2 <- c(l, l3)
        labeltypes <- substr(l, 8, nchar(l)-6)
        jaren <- substr(l, 4, 7)
      }
    }else{
      print(paste0(l, " is numeric"))
      l2 <- str_pad(string = l, 6, "0", side = "left")
      label_list4 <- NULL
      label_list3a <- NULL
      for(lt in labeltypes){
        for(j in jaren){
          l3 <- paste0("ANB", j, lt, l2)
          l4 <- paste0("ANB-", j, "-", lt, l2)
          label_list3 <- c(l3,l4)
          label_list4 <- append(label_list4, label_list3)
        }
      }
    }
    #Merge labellists
    if(check(label_list1)==0){
      label_list1 <- NULL
    }else{
      n <- length(label_list1)
    }
    if(check(label_list2)==0){
      label_list2 <- NULL
    }else{
      n <- length(label_list2)
    }
    if(check(label_list4)==0){
      label_list4 <- NULL
    }

    label_list <- c(label_list1, label_list2, label_list4)
    print("Labels to check:")
    print(paste0("input_label: ", l))
    print(label_list)

    #Make output dummy

    INPUTLABEL <- l
    LABELTYPE <- paste(unlist(labeltypes), collapse='/')
    JAAR <- paste(unlist(jaren), collapse='/')
    AM_OLD <- FALSE
    AM_OLD_LABEL <- NA
    TL_OLD <- FALSE
    TL_OLD_LABEL <- NA
    TL_CLEANED <- FALSE
    TL_CLEANED_LABEL <- NA
    DMOG <- FALSE
    DMOG_LABEL <- NA
    DMOG_GEO <- FALSE
    DMOG_GEO_LABEL <- NA
    if(update == TRUE){

      AM_NEW <- FALSE
      AM_NEW_LABEL <- NA
      TL_NEW <- FALSE
      TL_NEW_LABEL <- NA
      output_temp <- data.frame(INPUTLABEL, LABELTYPE, JAAR, AM_OLD, AM_OLD_LABEL, AM_NEW, AM_NEW_LABEL, TL_OLD, TL_OLD_LABEL, TL_NEW, TL_NEW_LABEL, TL_CLEANED, TL_CLEANED_LABEL, DMOG, DMOG_LABEL, DMOG_GEO,DMOG_GEO_LABEL)

      ##Afschotmeldingen_updated
      AM_NEW_CHECK <- subset(dataAfschotMelding, LabelNummer %in% label_list)
      AM_NEW_LABEL1 <- unique(AM_NEW_CHECK$LabelNummer)
      AM_NEW_LABEL2 <- paste(unlist(AM_NEW_LABEL1), collapse='/')
      if(nrow(AM_NEW_CHECK)>0){
        output_temp <-
          output_temp %>%
          dplyr::mutate(AM_NEW = TRUE,
                        AM_NEW_LABEL = AM_NEW_LABEL2)
      }

      ##Toegekende labels
      TL_NEW_CHECK <- subset(dataToegekendeLabels, Label %in% label_list)
      TL_NEW_LABEL1 <- unique(TL_NEW_CHECK$Label)
      TL_NEW_LABEL2 <- paste(unlist(TL_NEW_LABEL1), collapse='/')
      if(nrow(TL_NEW_CHECK)>0){
        output_temp <-
          output_temp %>%
          dplyr::mutate(TL_NEW = TRUE,
                        TL_NEW_LABEL = TL_NEW_LABEL2)
      }
    }else{
      output_temp <- data.frame(INPUTLABEL, LABELTYPE, JAAR, AM_OLD, AM_OLD_LABEL, TL_OLD, TL_OLD_LABEL, TL_CLEANED, TL_CLEANED_LABEL, DMOG, DMOG_LABEL, DMOG_GEO,DMOG_GEO_LABEL)
    }


    #Check Aanwezigheid labels
    ##Afschotmeldingen
    AM_OLD_CHECK <- subset(AfschotMelding, LabelNummer %in% label_list)
    AM_OLD_LABEL1 <- unique(AM_OLD_CHECK$LabelNummer)
    AM_OLD_LABEL2 <- paste(unlist(AM_OLD_LABEL1), collapse='/')
    if(nrow(AM_OLD_CHECK)>0){
      output_temp <-
        output_temp %>%
        dplyr::mutate(AM_OLD = TRUE,
                      AM_OLD_LABEL = AM_OLD_LABEL2)
    }

    ##Toegekende labels
    TL_OLD_CHECK <- subset(ToegekendeLabels, Label %in% label_list)
    TL_OLD_LABEL1 <- unique(TL_OLD_CHECK$Label)
    TL_OLD_LABEL2 <- paste(unlist(TL_OLD_LABEL1), collapse='/')
    if(nrow(TL_OLD_CHECK)>0){
      output_temp <-
        output_temp %>%
        dplyr::mutate(TL_OLD = TRUE,
                      TL_OLD_LABEL = TL_OLD_LABEL2)
    }

    ##Toekenningen_Cleaned
    TL_CLEANED_CHECK <- subset(Toekenningen_Cleaned, Label_Toek %in% label_list)
    TL_CLEANED_LABEL1 <- unique(TL_CLEANED_CHECK$Label_Toek)
    TL_CLEANED_LABEL2 <- paste(unlist(TL_CLEANED_LABEL1), collapse='/')
    if(nrow(TL_CLEANED_CHECK)>0){
      output_temp <-
        output_temp %>%
        dplyr::mutate(TL_CLEANED = TRUE,
                      TL_CLEANED_LABEL = TL_CLEANED_LABEL2)
    }

    ##Dieren_met_onderkaakgegevens
    DMOG_CHECK <- subset(Dieren_met_onderkaakgegevens, label_nummer %in% label_list)
    DMOG_LABEL1 <- unique(DMOG_CHECK$label_nummer)
    DMOG_LABEL2 <- paste(unlist(DMOG_LABEL1), collapse='/')
    if(nrow(DMOG_CHECK)>0){
      output_temp <-
        output_temp %>%
        dplyr::mutate(DMOG = TRUE,
                      DMOG_LABEL = DMOG_LABEL2)
    }

    ##Dieren_met_onderkaakgegevens_Georef
    DMOG_GEO_CHECK <- subset(Dieren_met_onderkaakgegevens_Georef, label_nummer_samen %in% label_list)
    DMOG_GEO_LABEL1 <- unique(DMOG_GEO_CHECK$label_nummer_samen)
    DMOG_GEO_LABEL2 <- paste(unlist(DMOG_GEO_LABEL1), collapse='/')
    if(nrow(DMOG_GEO_CHECK)>0){
      output_temp <-
        output_temp %>%
        dplyr::mutate(DMOG_GEO = TRUE,
                      DMOG_GEO_LABEL = DMOG_GEO_LABEL2)
    }

    #Outputs Samenvoegen
    if(check(final) == 0){
      final <- output_temp
    }else{
      final <- rbind(final, output_temp)
    }
  }
  return(final)
}
