############################################################################################################################
#   RoME: R code to perform multiple checks on MEDITS Survey data (TA, TB, TC and TE files)                                #
#   Authors: I. Bitetto, W. Zupa, M.T. Spedicato                                                                           #
#   Coispa Tecnologia & Ricerca - Stazione sperimentale per lo Studio delle Risorse del Mare                               #
#   If you have any comments or suggestions please contact the following e-mail address: bitetto@coispa.it, zupa@coispa.it #
#   January 2022                                                                                                           #
############################################################################################################################

scheme_individual_data <- function(DataTC,DataTE,year,wd,suffix){

  if (FALSE){
    wd <- tempdir()
    suffix=paste(as.character(Sys.Date()),format(Sys.time(), "_time_h%Hm%Ms%OS0"),sep="")
    DataTC <- RoME::TC
    DataTE <- RoME::TE
    year=2012
    scheme_individual_data(DataTC,DataTE,year,wd,suffix)
  }

  if (!file.exists(file.path(wd, "Logfiles"))){
    dir.create(file.path(wd, "Logfiles"), recursive = TRUE, showWarnings = FALSE)
  }
  if (!file.exists(file.path(wd,"Graphs"))){
    dir.create(file.path(wd, "Graphs"), showWarnings = FALSE)
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
  DataTC <- DataTC[DataTC$YEAR == year, ]
  DataTE <- DataTE[DataTE$YEAR == year, ]
  ########################################

  ResultDataTC <- DataTC
  ResultDataTC$Species <- paste(ResultDataTC$GENUS,ResultDataTC$SPECIES)
  ResultDataTE <- DataTE
  ResultDataTE$Species <- paste(ResultDataTE$GENUS,ResultDataTE$SPECIES)

write(paste("\n----------- check summary of individual measures"), file = Errors, append = TRUE)
write(paste("\n----------- check summary of individual measures - ",ResultDataTE$YEAR[1]), file = Errors, append = TRUE)

mat = aggregate(ResultDataTC$NUMBER_OF_INDIVIDUALS_IN_THE_LENGTH_CLASS_AND_MATURITY_STAGE, by=list(ResultDataTC$Species,ResultDataTC$LENGTH_CLASS), FUN="sum")
colnames(mat)= c("Species", "LENGHT_CLASS","LENGTHS")
mat_fin= data.frame(mat[order(mat$Species,decreasing=F),])
mat_fin=cbind(mat_fin,NA)
mat_fin=cbind(mat_fin,NA)
colnames(mat_fin)= c("Species", "LENGTH_CLASS","LENGTHS","WEIGHTS", "OTOLITH")

mat2 = aggregate(ResultDataTE$INDIVIDUAL_WEIGHT, by=list(ResultDataTE$Species,ResultDataTE$LENGTH_CLASS), FUN="length")
colnames(mat2) = c("Species","LENGTH_CLASS","NUMBER_WEIGHTS")

ResultDataTE_temp = ResultDataTE[ResultDataTE$OTOLITH_SAMPLED=="Y",]
mat3 = aggregate(ResultDataTE_temp$OTOLITH_SAMPLED, by=list(ResultDataTE_temp$Species,ResultDataTE_temp$LENGTH_CLASS), FUN="length")
colnames(mat3) = c("Species","LENGTH_CLASS","NUMBER_OTOLITH")

riga=1
for (riga in 1:nrow(mat_fin)){
if(length(mat2$NUMBER_WEIGHTS[mat2$Species==mat_fin$Species[riga] & mat2$LENGTH_CLASS==mat_fin$LENGTH_CLASS[riga]])==0) {
mat_fin[riga,4] = 0
} else {
mat_fin[riga,4] = mat2$NUMBER_WEIGHTS[mat2$Species==mat_fin$Species[riga]& mat2$LENGTH_CLASS==mat_fin$LENGTH_CLASS[riga]]
}
}

for (riga in 1:nrow(mat_fin)){
if(length(mat3$NUMBER_OTOLITH[mat3$Species==mat_fin$Species[riga] & mat3$LENGTH_CLASS==mat_fin$LENGTH_CLASS[riga]])==0) {
mat_fin[riga,5] = 0
} else {
mat_fin[riga,5] = mat3$NUMBER_OTOLITH[mat3$Species==mat_fin$Species[riga]& mat3$LENGTH_CLASS==mat_fin$LENGTH_CLASS[riga]]
}
}

mat_fin = mat_fin[which(mat_fin$Species %in% unique (ResultDataTE$Species)),]
write.table(mat_fin, file = file.path(wd,paste("sampling_individual_measures_",ResultDataTE$YEAR[1],".csv",sep="")),sep=";",row.names=F)

# if (numberError ==0) {
#     write(paste("No error occurred"), file = Errors, append = TRUE)
#   }

  # if (file.exists(file.path(tempdir(), "Logfiles"))){
  # unlink(file.path(tempdir(),"Logfiles"),recursive=T)
  # }
  # if (file.exists(file.path(tempdir(), "Graphs"))){
  # unlink(file.path(tempdir(),"Graphs"),recursive=T)
  #   }

  #if (numberError ==0) {
    return(TRUE)
  #} else { return(FALSE) }

}
