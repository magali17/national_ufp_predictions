# Script winsorizes extreme UFP predictions

####################################################################
# SETUP
####################################################################
# Clear workspace of all objects and unload all extra (non-base) packages
rm(list = ls(all = TRUE))
if (!is.null(sessionInfo()$otherPkgs)) {
  res <- suppressWarnings(
    lapply(paste('package:', names(sessionInfo()$otherPkgs), sep=""),
           detach, character.only=TRUE, unload=TRUE, force=TRUE))}

pacman::p_load(tidyverse)

override_quantile_file <- TRUE
override_winsorized_file <- TRUE

quantile_file <- file.path("output", "winsorize", "raw_ufp_quantiles.txt")

predictions_path <- file.path("output", "predictions", "2016_2017", "raw", "blocks", "rda")
output_path <- file.path("output", "predictions", "2016_2017", "modified", "blocks", "rda")
####################################################################
# CALCULATE DATASET QUANTILES FOR WINSORIZING
####################################################################
if(!file.exists(quantile_file) | override_quantile_file == TRUE) {
  message("calculating UFP quantiles")
  
  predictions_path <- file.path("output", "predictions", "2016_2017", "raw", "blocks", "rda")
  prediction_files <- list.files(file.path(predictions_path))
  
  # x=prediction_files[1]
  predictions <- lapply(prediction_files, function(x){ readRDS(file.path(predictions_path, x)) }) %>%
    bind_rows()
  
  ufp_quantiles <- lapply(seq(0, 1, 0.01 #0.005
                              ), function(q){
    tibble(quantile = q,
           conc = quantile(predictions$ufp, q))
    }) %>%
    bind_rows()
  
  #saveRDS(ufp_quantiles,  quantile_file)
  write.csv(ufp_quantiles,  quantile_file, row.names = F)
} else{
  ufp_quantiles <- read.csv(quantile_file)
}

####################################################################
# COMMON VARIABLES
####################################################################
# ufp_quantiles %>%
#   filter(quantile <= 0.05 | quantile >= 0.95,
#          quantile %in% seq(0.01, 1, 0.01))

# winsorizing thresholds
low_quantile <- 0.02
## results in max conc ~25k pt/cm3. Saha paper & block prediction max is ~26,579. anything higher produces much higher conc's (99th quantile ~105k)
high_quantile <- 0.98

low_conc <- ufp_quantiles$conc[ufp_quantiles$quantile==low_quantile] %>% as.numeric()
high_conc <- ufp_quantiles$conc[ufp_quantiles$quantile==high_quantile] %>% as.numeric()

####################################################################
# WINSORIZE PREDICTIONS
####################################################################
# 11/28/24 email (Re: Missing values in the national UFP model): based on my analyses in the qc directory, ~2% of blocks (with pop >=1) were dropped because of extreme covariate values (outside the covariate space)
# blocks that were dropped have a slightly different distribution, with the largest discrepancy being that blocks dropped on average had higher predictions, but not always
# we want predictions for these locations b/c we have ECHO participants living in these areas 

# rda files
predictions_files <- list.files(predictions_path)
  
# f=predictions_files[1]
lapply(predictions_files, function(f) {
  
  raw_file <- file.path(predictions_path, f)
  modified_file <- file.path(output_path, f)
  
  if(!file.exists(modified_file) | override_winsorized_file == TRUE) {
    message("calculating UFP quantiles")
    
  
  predictions_modified <- readRDS(raw_file) %>%
    mutate(ufp_winsorized = ifelse(ufp < low_conc, low_conc, 
                                   ifelse(ufp > high_conc, high_conc, ufp)),
           winsorized = ifelse(ufp < low_conc | ufp > high_conc, TRUE, FALSE))
  
  # [could add df w/ file_name, no_blocks, no_blocks_winsorized, prop_blocks_winsorized]
  
  # save as rda & txt file
  saveRDS(predictions_modified, modified_file)
  write.csv(predictions_modified, gsub("rda", "txt", modified_file), row.names = F)
  }
  
})

 