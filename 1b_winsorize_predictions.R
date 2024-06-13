# Script winsorizes extreme UFP predictions using 2010 & 2020 covariates
# output is here: output/winsorize and output/predictions/original_model/blocks/modified 

####################################################################
# SETUP
####################################################################
# Clear workspace of all objects and unload all extra (non-base) packages
rm(list = ls(all = TRUE))
if (!is.null(sessionInfo()$otherPkgs)) {
  res <- suppressWarnings(
    lapply(paste('package:', names(sessionInfo()$otherPkgs), sep=""),
           detach, character.only=TRUE, unload=TRUE, force=TRUE))}

pacman::p_load(tidyverse, parallel)

input_path <- file.path("output", "predictions", "original_model", "blocks", "raw")
output_path <- file.path("output", "predictions", "original_model", "blocks", "modified")

prediction_files <- list.files(input_path)
quantile_files <- paste0("raw_quantiles_", prediction_files)

use_cores <- 1 #4 works in brain #6 is slow during winsorizing???

####################################################################
testing_mode <- FALSE
override_quantile_file <- FALSE # TRUE if e.g., updating missing block covariates
override_winsorized_file <- TRUE

####################################################################
# COMMON VARIABLES
####################################################################

# winsorizing thresholds
low_quantile <- 0.01#0.02
## results in max conc ~25k pt/cm3. Saha paper & block prediction max is ~26,579. anything higher produces much higher conc's (99th quantile ~105k)
high_quantile <- 0.99#0.98
#winsorizing_label <- paste0(low_quantile, high_quantile, sep="_")
####################################################################
# CALCULATE DATASET QUANTILES FOR WINSORIZING
####################################################################
# f=quantile_files[2]
lapply(c(quantile_files), function(f){
  
  this_quantile_file <- file.path("output", "winsorize", f)
  
  if(!file.exists(this_quantile_file) | 
     override_quantile_file == TRUE) {
    message("generating new quantile file")
    message("reading in raw UFP prediction file")
    predictions <- readRDS(file.path(input_path, gsub("raw_quantiles_", "", f))) 
    quantile_list <-seq(0, 1, 0.01)
    
    if(testing_mode==TRUE){
      message("...testing mode")
      predictions <- predictions[1:100,]
      quantile_list <- c(0.01, 0.99)
      }
    
    message(paste("calculating UFP quantiles"))
    ufp_quantiles <- mclapply(quantile_list, mc.cores = use_cores, function(q){
      tibble(quantile = q,
             
             # --> TEMP: some blocks have missing values for 'imp_a00750' 
             conc = quantile(predictions$ufp, q, na.rm = T))
    }) %>%
      bind_rows()
    
    message(paste("...saving UFP quantile file", this_quantile_file))
    saveRDS(ufp_quantiles, this_quantile_file)
  } else{
    message("using existing quantile file")
  }
})

####################################################################
# WINSORIZE PREDICTIONS
####################################################################
# 11/28/24 email (Re: Missing values in the national UFP model): based on my analyses in the qc directory, ~2% of blocks (with pop >=1) were dropped because of extreme covariate values (outside the covariate space)
# blocks that were dropped have a slightly different distribution, with the largest discrepancy being that blocks dropped on average had higher predictions, but not always
# we want predictions for these locations b/c we have ECHO participants living in these areas 

message("winsorizing predictions...")

# --> make into fn to output serveral quantile estimaets?

# f=prediction_files[2]
mclapply(prediction_files, mc.cores = use_cores, function(f) {
  
  raw_file <- file.path(input_path, f)
  modified_file <- file.path(output_path, f)
  
  if(!file.exists(modified_file) | 
     override_winsorized_file == TRUE) {
    
  # winsorization values for specific year covariates
  ufp_quantiles <- readRDS(file.path("output", "winsorize", paste0("raw_quantiles_", f)))
  low_conc <- ufp_quantiles$conc[ufp_quantiles$quantile==low_quantile] %>% as.numeric()
  high_conc <- ufp_quantiles$conc[ufp_quantiles$quantile==high_quantile] %>% as.numeric()
  
  raw_predictions <- readRDS(raw_file)  
  
  if(testing_mode==TRUE){
    message("...testing mode")
    raw_predictions <- raw_predictions[1:100,]
    }
    
  predictions_modified <- raw_predictions %>% 
    mutate(ufp_winsorized = ifelse(ufp < low_conc, low_conc, 
                                   ifelse(ufp > high_conc, high_conc, ufp)),
           winsorized = ifelse(ufp < low_conc | ufp > high_conc, TRUE, FALSE))
  
  # save modified predictions
  message(paste("...saving:", modified_file))
  saveRDS(predictions_modified, modified_file)
  }
  
})

####################################################################
# DONE
####################################################################
message("DONE WITH 1b_winsorize_predictions.R")
