# scripts imports 2010 & 2020 block covariates and generates predictions with the original model
# output is here: output/predictions/original_model/blocks/raw 

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

# if prediction files already exist, should these be overwritten?
override_predictions <- TRUE

covariate_path <- file.path("input")
predictions_path <- file.path("output", "predictions", "original_model", "blocks", "raw")

####################################################################
# BLOCK PREDICTIONS
####################################################################
covariate_files <- list.files(covariate_path)

# x= covariate_files[2]
lapply(covariate_files, function(x) {
  new_prediction_file <- file.path(predictions_path, x)
  
  if(!file.exists(new_prediction_file) | 
     override_predictions==TRUE){
    message(paste("generating new predictions for", x))
    
    # read in covariate file
    covariates <- readRDS(file.path(covariate_path, x)) %>%
      rename(block_key = native_id,
             latitude = lat_block, 
             longitude= long_block,
             
             # ll_a1_a3_s03000 = ll_a1_s03000 + ll_a3_s03000 
             ## ll_a1_a3_s03000 already exists in these particular datasets. manipulate this so the function doesn't error out
             ll_a1_s03000=ll_a1_a3_s03000) %>% 
      mutate(ll_a3_s03000 = 0)
      
      
    # generate UFP predictions. 
    ## function will generate additional covariates and makes modifications as necessary
    predictions <- predictUFP(covariates)
    
    # save predictions
    message("...saving predictions") 
    saveRDS(predictions, new_prediction_file)
  } else {
    message(paste("predictions for", x, "already exist"))
    }
  }) 


####################################################################
#  
####################################################################


####################################################################
# DONE
####################################################################
message("DONE WITH 1a_predict_with_og_model.R")





