############################################################################################################################
#   RoME: R code to perform multiple checks on MEDITS Survey data (TA, TB, TC and TE files)                                #
#   Authors: I. Bitetto, W. Zupa, M.T. Spedicato                                                                           #
#   Coispa Tecnologia & Ricerca - Stazione sperimentale per lo Studio delle Risorse del Mare                               #
#   If you have any comments or suggestions please contact the following e-mail address: bitetto@coispa.it, zupa@coispa.it #
#   January 2022                                                                                                           #
############################################################################################################################
# Check if in TE the total number sampled for weight and for ageing are consistent with individual data in TE

check_nb_TE<- function (DataTE,year,wd,suffix){

  if (FALSE){
    library(RoME)
    wd <- tempdir()
    suffix=paste(as.character(Sys.Date()),format(Sys.time(), "_time_h%Hm%Ms%OS0"),sep="")
    DataTE = read.table(file=paste(wd, "\\TE.csv",sep=""), sep=";", header=T)# RoME::TE # read.csv("~/GitHub/RoME/data/TE_2012-2018 _GSA18.csv", sep=";")
   DataTE[1,"NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_WEIGHT"] <- 131
    year=2015
    # DataTE = DataTE[DataTE$YEAR == 2012 ,   ]
    # SPECIES=NA
    # SEX=NA
    # AREA=NA
    # a=NA
    # b=NA
    # verbose=FALSE
    check_nb_TE(DataTE,year, wd, suffix)
  }

  if (!file.exists(file.path(wd, "Logfiles"))){
    dir.create(file.path(wd, "Logfiles"), recursive = TRUE, showWarnings = FALSE)
  }
  if (!exists("suffix")){
    suffix=paste(as.character(Sys.Date()),format(Sys.time(), "_time_h%Hm%Ms%OS0"),sep="")
  }
  numberError = 0
  Errors <- file.path(wd,"Logfiles",paste("Logfile_",suffix,".dat",sep=""))
  if (!file.exists(Errors)){
    file.create(Errors)
  }

  ### FILTERING DATA FOR THE SELECTED YEAR
  arg <- "year"
  if (!exists(arg)) {
    stop(paste0("'", arg, "' argument should be provided"))
  } else if (length(year) != 1) {
    stop(paste0("only one value should be provided for '", arg, "' argument"))
  } else if (is.na(year)) {
    stop(paste0(arg, " argument should be a numeric value"))
  }
  DataTE <- DataTE[DataTE$YEAR == year, ]
  ########################################

  TE <- DataTE

  write(paste("\n----------- check consistency of number of individuals sampled for weight and ageing in TE - ",TE$YEAR[1]), file = Errors, append = TRUE)


  # check on NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_OTOLITH
  TE_temp1 = TE[as.character(TE$OTOLITH_SAMPLED) == "Y",]


  if (nrow(TE_temp1)!=0){
    TE_temp1 = aggregate(TE_temp1$TYPE_OF_FILE, by= list(TE_temp1$HAUL_NUMBER,
                                                         TE_temp1$GENUS,TE_temp1$SPECIES, TE_temp1$SEX ,
                                                         TE_temp1$NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_OTOLITH),FUN="length") #
    colnames(TE_temp1)=c("HAUL_NUMBER","GENUS","SPECIES","SEX","NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_OTOLITH","NB")
    j=1
    for (j in 1:nrow(TE_temp1)){
      if(TE_temp1$NB[j]!=TE_temp1$NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_OTOLITH[j]){
        write(paste(TE_temp1$HAUL_NUMBER[j],TE_temp1$GENUS[j],TE_temp1$SPECIES[j], TE_temp1$SEX[j],"inconsistent value for the field NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_OTOLITH"), file = Errors, append = TRUE)
        numberError =   numberError +1
      }
    }
  }else {
    write("No otolith sampled", file = Errors, append = TRUE)
  }

  # check on NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_WEIGHT
  TE_temp2 = TE[as.character(TE$INDIVIDUAL_WEIGHT) != "ND",]

  if (nrow(TE_temp2)!=0){
    TE_temp2 = aggregate(TE_temp2$TYPE_OF_FILE, by= list(TE_temp2$HAUL_NUMBER,TE_temp2$GENUS,TE_temp2$SPECIES, TE_temp2$SEX,TE_temp2$NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_WEIGHT),FUN="length")
    colnames(TE_temp2)=c("HAUL_NUMBER","GENUS","SPECIES","SEX","NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_WEIGHT","NB")

    for (j in 1:nrow(TE_temp2)){
      if(TE_temp2$NB[j]!=TE_temp2$NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_WEIGHT[j]){
        write(paste("Haul",TE_temp2$HAUL_NUMBER[j],TE_temp2$GENUS[j],TE_temp2$SPECIES[j], TE_temp2$SEX[j],"inconsistent value for the field NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_WEIGHT"), file = Errors, append = TRUE)
        numberError =   numberError +1
      }
    }
  } else {
    write("No weight measured.", file = Errors, append = TRUE)
  }


  # check on NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_AGEING
  TE_temp3 = TE[as.character(TE$OTOLITH_READ) == "Y",]

  if (nrow(TE_temp3)!=0){
    TE_temp3 = aggregate(TE_temp3$TYPE_OF_FILE, by= list(TE_temp3$HAUL_NUMBER,TE_temp3$GENUS,TE_temp3$SPECIES, TE_temp3$SEX,TE_temp3$NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_AGEING),FUN="length")
    colnames(TE_temp3)=c("HAUL_NUMBER","GENUS","SPECIES","SEX","NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_AGEING","NB")

    for (j in 1:nrow(TE_temp3)){
      if(TE_temp3$NB[j]!=TE_temp3$NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_AGEING[j]){
        write(paste(TE_temp3$HAUL_NUMBER[j],TE_temp3$GENUS[j],TE_temp3$SPECIES[j], TE_temp3$SEX[j],"inconsistent value for the field NO_PER_SEX_MEASURED_IN_SUB_SAMPLE_FOR_AGEING"), file = Errors, append = TRUE)
        numberError =   numberError +1
      }
    }
  } else {
    write("No otolith read.", file = Errors, append = TRUE)
  }
  if (numberError ==0) {
    write(paste("No error occurred"), file = Errors, append = TRUE)
  }

   if (file.exists(file.path(tempdir(), "Logfiles"))){
  unlink(file.path(tempdir(),"Logfiles"),recursive=T)
  }
  if (file.exists(file.path(tempdir(), "Graphs"))){
  unlink(file.path(tempdir(),"Graphs"),recursive=T)
    }
	if (file.exists(file.path(tempdir(), "files R-Sufi"))){
  unlink(file.path(tempdir(),"files R-Sufi"),recursive=T)
    }
  if (numberError ==0) {
    return(TRUE)
  } else { return(FALSE) }



}
