
####################################################################
# SETUP
####################################################################
# Clear workspace of all objects and unload all extra (non-base) packages
rm(list = ls(all = TRUE))
if (!is.null(sessionInfo()$otherPkgs)) {
  res <- suppressWarnings(
    lapply(paste('package:', names(sessionInfo()$otherPkgs), sep=""),
           detach, character.only=TRUE, unload=TRUE, force=TRUE))}

pacman::p_load(ufp.model.saha2021, tidyverse)

####################################################################
# BLOCK PREDICTIONS
####################################################################
# if prediction files already exist, should these be overwritten?
override_predictions <- FALSE

covariate_path <- file.path("/projects", "echo-aware", "ufp", "block10_intpts")
predictions_path <- file.path("output", "predictions", "2016_2017", "raw", "blocks", "txt")

covariate_files <- list.files(file.path(covariate_path)) %>% 
  
  # --> TEMP
  str_subset("^al_")

# x= covariate_files[1]
lapply(covariate_files, function(x) {
  predictions_file <- gsub("intpts.txt", "predictions.txt", x)
  predictions_file <- file.path(predictions_path, predictions_file)
  
  if(!file.exists(predictions_file) | override_predictions==TRUE){
    message(paste("generating new predictions for", x))
    
    # read in covariate file
    covariates <- read.csv(file.path(covariate_path, x))
    
    # generate UFP predictions. 
    ## function will generate additional covariates and makes modifications as necessary
    predictions <- predictUFP(covariates)
    
    # save predictions
    write.csv(predictions, predictions_file, row.names = F)
    # also save a smaller file
    select(predictions, block_key, ufp) %>%
      saveRDS(., gsub("txt", "rda", predictions_file))
  } else {
    message(paste("predictions for", x, "already exist"))
    }
  }) 


####################################################################
#  
####################################################################







