
#' @param 'label' een character (lijst) met labelnummer(s) die dienen onderzocht te worden. Dit kan in 3 vormen (volgnummer, met streepjes of zonder streepjes) of een combinatie van deze vormen aangeleverd worden
#' @param 'update' een boolean die aangeeft of ook de nog niet wegeschreven dwh - bestanden moeten worden gecontroleerd. **Deze parameter is nog niet bruikbaar**. **Deze parameter werkt enkel met een connectie met het inbo netwerk (ook via vpn)** 
#' @param 'label_type' een een character (lijst) met labeltypes die dienen onderzocht te worden. *Deze parameter is case ongevoelig* 
#' @param 'jaar' een numerieke (lijst) van jaren die dienen onderzocht te worden.
#' @param 'soort' een character van de soort die onderzocht dient te worden. *Deze parameter is case ongevoelig* 
#' 
#' @details De parameter 'label_type', 'jaar' en 'soort' zijn enkel relevant als één van de labels de vorm 'volgnummer' heeft. 
#' @details Wanneer deze parameter niet gespecifieerd worden zal een default waarde voor het jaar (2013 t.e.m. max(AfschotMelding$Jaartal)) en label_type (c("REEGEIT", "REEKITS", "REEBOK", "WILD ZWIJN", "DAMHERT", "EDELHERT")) gebruikt worden.
#' @details Wanneer soort gespecifieerd is zal de lijst van labeltypes beperkt worden tot deze die op de soort betrekking hebben. 
#' @details voor ree bvb wordt dit reekits, reegeit en reebok. 
#' 
#' @details deze functie onderzoekt of de lijst van labels bestaan in de volgende datasets: AfschotMelding, ToegekendeLabels,Toekenningen_Cleaned, Dieren_met_onderkaakgegevens, Dieren_met_onderkaakgegevens_Georef. 
#' @details Om deze functie te gebruiken maak je een leeg r - bestand (of in de console) en plak je de onderstaande code:
#' @details source("./Functies/label_selecter.R")
#' @details output <- label_selecter(label, update = FALSE, label_type, jaar, soort)
#' 
#' @examples #enkel label:
#' @examples label <- c(1234, "ANB2016REEGEIT001234", "ANB-2016-REEGEIT001234")
#' @examples output <- label_selecter(label)
#' 
#' @examples #label & labeltype
#' @examples label <- c(1234, "ANB2016REEGEIT001234", "ANB-2016-REEGEIT001234")
#' @examples labeltype <- c("reegeit", "REEBOK")
#' @examples output <- label_selecter(label, label_type = labeltype)
#' 
#' @examples #label & jaar & soort
#' @examples label <- c(1234, "ANB2016REEGEIT001234", "ANB-2016-REEGEIT001234")
#' @examples soort <- "ree"
#' @examples jaar <- c(2018, 2019)
#' @examples output <- label_selecter(label, jaar = jaar , soort = soort)
#' 

label_selecter <- function(label, update = FALSE, label_type, jaar, soort){
  
  require(tidyverse)
  
  source("../backoffice-wild-analyse/Functies/Check.R")
  
  #Datasets to check
  AfschotMelding <- read_csv("../backoffice-wild-analyse/Basis_Scripts/Input/E_Loket/AfschotMelding.csv") #AM_OLD
  ToegekendeLabels <- read_csv("../backoffice-wild-analyse/Basis_Scripts/Input/E_Loket/ToegekendeLabels.csv") #TL_OLD
  Toekenningen_Cleaned <- read_delim("../backoffice-wild-analyse/Basis_Scripts/Interim/Toekenningen_Cleaned.csv", 
                                     ";", escape_double = FALSE, trim_ws = TRUE) #TL_CLEANED
  Dieren_met_onderkaakgegevens <- read_csv("../backoffice-wild-analyse/Data/Interim/Dieren_met_onderkaakgegevens.csv") #DMOG
  Dieren_met_onderkaakgegevens_Georef <- read_delim("../backoffice-wild-analyse/Data/Interim/Dieren_met_onderkaakgegevens_Georef.csv", 
                                                    ";", escape_double = FALSE, trim_ws = TRUE) #DMOG_GEO
  if(update == TRUE){
  print("Updating E_Loket Data")
  source("./Basis_Scripts/DWH_connect.R", local = TRUE)
  
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
    mutate(label = 1,
           numeric = as.numeric(1)) %>% 
    dplyr::select(-X1)
    
  progress_bar <- progress_estimated(length(label))
  for(l in label){
    progress_bar$tick()$print()
    ##Make empty label_lists
    label_list <- NULL
    label_list4 <- NULL
    ##Check label type
    label_check <- 
      label_check %>% 
      mutate(label = l,
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
          mutate(AM_NEW = TRUE,
                 AM_NEW_LABEL = AM_NEW_LABEL2)
      }
        
      ##Toegekende labels
      TL_NEW_CHECK <- subset(dataToegekendeLabels, Label %in% label_list)
      TL_NEW_LABEL1 <- unique(TL_NEW_CHECK$Label)
      TL_NEW_LABEL2 <- paste(unlist(TL_NEW_LABEL1), collapse='/')
      if(nrow(TL_NEW_CHECK)>0){
        output_temp <- 
          output_temp %>% 
          mutate(TL_NEW = TRUE,
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
        mutate(AM_OLD = TRUE,
               AM_OLD_LABEL = AM_OLD_LABEL2)
    }
    
    ##Toegekende labels
    TL_OLD_CHECK <- subset(ToegekendeLabels, Label %in% label_list)
    TL_OLD_LABEL1 <- unique(TL_OLD_CHECK$Label)
    TL_OLD_LABEL2 <- paste(unlist(TL_OLD_LABEL1), collapse='/')
    if(nrow(TL_OLD_CHECK)>0){
      output_temp <- 
        output_temp %>% 
        mutate(TL_OLD = TRUE,
               TL_OLD_LABEL = TL_OLD_LABEL2)
    }
    
    ##Toekenningen_Cleaned
    TL_CLEANED_CHECK <- subset(Toekenningen_Cleaned, Label_Toek %in% label_list)
    TL_CLEANED_LABEL1 <- unique(TL_CLEANED_CHECK$Label_Toek)
    TL_CLEANED_LABEL2 <- paste(unlist(TL_CLEANED_LABEL1), collapse='/')
    if(nrow(TL_CLEANED_CHECK)>0){
      output_temp <- 
        output_temp %>% 
        mutate(TL_CLEANED = TRUE,
               TL_CLEANED_LABEL = TL_CLEANED_LABEL2)
    }
    
    ##Dieren_met_onderkaakgegevens
    DMOG_CHECK <- subset(Dieren_met_onderkaakgegevens, label_nummer %in% label_list)
    DMOG_LABEL1 <- unique(DMOG_CHECK$label_nummer)
    DMOG_LABEL2 <- paste(unlist(DMOG_LABEL1), collapse='/')
    if(nrow(DMOG_CHECK)>0){
      output_temp <- 
        output_temp %>% 
        mutate(DMOG = TRUE,
               DMOG_LABEL = DMOG_LABEL2)
    }
    
    ##Dieren_met_onderkaakgegevens_Georef
    DMOG_GEO_CHECK <- subset(Dieren_met_onderkaakgegevens_Georef, label_nummer_samen %in% label_list)
    DMOG_GEO_LABEL1 <- unique(DMOG_GEO_CHECK$label_nummer_samen)
    DMOG_GEO_LABEL2 <- paste(unlist(DMOG_GEO_LABEL1), collapse='/')
    if(nrow(DMOG_GEO_CHECK)>0){
      output_temp <- 
        output_temp %>% 
        mutate(DMOG_GEO = TRUE,
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
  