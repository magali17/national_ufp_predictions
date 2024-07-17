# scripts imports 2010 & 2020 block covariates and generates predictions with the original model
# output is here: output/predictions/original_model/blocks/raw 

# NOTES
# --> CURRENTLY NOT USING THE FUNCITO B/C UPDATED CODE TO LOG M_TO_TRUCK

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
predictions_path <- file.path("output", "predictions", "original_model", "blocks", 
                              "20240716_log_truck",
                              #"20240621_original_model",
                              "raw")
####################################################################
# FIT A NEW MODEL WITH LOG M TO TRUCK
# 
# TEMP - UPDATING HOW LOGAN HAS CODDED THE UFP MODEL
## can afterwards delete this chunk
####################################################################
# original_ufp_model <- readRDS(file.path("original_model_fit", "lm_fit.rda"))
# 
# # we'll use log m to truck instead
# covariate_names <- coef(original_ufp_model) %>%
#   names() %>%
#   setdiff(., c("(Intercept)")) %>%
#   gsub("m_to_truck", "log_m_to_truck", .)

# file originally came from UFP_LUR_Model.R 
input_used <- read.csv(file.path("original_model_fit", "input_used.csv")) %>%
  mutate(
    # put this back on the native scale
    m_to_truck = 1/m_to_truck,
    # log transform to better specify the model. there are no 0 values
    log_m_to_truck = log(m_to_truck),
    # # covariate used in the model
    # ll_a1_a3_s03000 = ll_a1_s03000 + ll_a3_s03000
    )

# from UFP_LUR_Model.R or readRDS(file.path("original_model_fit", "lm_fit.rda"))
## we'll use log m to truck instead
model_formula <- PNC ~  + imp_a00750  + log_m_to_truck + lu_resi_p15000 + lu_comm_p01500 + ll_a1_a3_s03000

ufp_model <- lm(model_formula, data = input_used)
message("new model fit with log m_to_truck")
summary(ufp_model)

covariate_names <- coef(ufp_model) %>%
  names() %>%
  setdiff(., c("(Intercept)")) 

saveRDS(ufp_model, file.path("original_model_fit", "lm_fit_log_truck.rda"))


####################################################################
# BLOCK PREDICTIONS
####################################################################
covariate_files <- list.files(covariate_path)

# x= covariate_files[1]
lapply(covariate_files, function(x) {
  new_prediction_file <- file.path(predictions_path, x)
  
  if(!file.exists(new_prediction_file) | 
     override_predictions==TRUE){
    message(paste("generating new predictions for", x))
    
    # read in block covariate file
    covariates <- readRDS(file.path(covariate_path, x)) %>%
      rename(block_key = native_id,
             latitude = lat_block, 
             longitude= long_block,
             
             # ll_a1_a3_s03000 = ll_a1_s03000 + ll_a3_s03000 
             ## ll_a1_a3_s03000 already exists in these particular datasets. manipulate this so the function doesn't error out
             #ll_a1_s03000=ll_a1_a3_s03000
             ) %>% 
      #mutate(ll_a3_s03000 = 0)
      mutate(block_key = str_pad(block_key, side = "left", pad = "0", width=15),
             m_to_truck = ifelse(m_to_truck==0, 1, m_to_truck),
             # log transform distances (better model fit)
             log_m_to_truck = log(m_to_truck)) %>%
      
      # TEMP WHILE LOGAN UPDATES THINGS
      select(block_key, matches(paste0(c(covariate_names, "longitude", "latitude"), collapse = "|"))) %>%
      rename(lat_block = latitude, long_block = longitude)
      
      
    # generate UFP predictions. 
    # ## function will generate additional covariates and makes modifications as necessary
    # predictions <- predictUFP(covariates)
    
    ####################################################################
    # TEMP WHILE LOGAN UPDATES THIS - PREDICT
    ####################################################################
    predictions <- covariates %>%
      mutate(ufp = predict(ufp_model, newdata=.)) 
    ####################################################################
    
    # save predictions
    message("...saving predictions") 
    saveRDS(predictions, new_prediction_file)
  } else {
    message(paste("predictions for", x, "already exist"))
    }
  }) 

####################################################################
# DONE
####################################################################
message("DONE WITH 1a_predict_with_og_model.R")


####################################################################
#  QC Checks - take long time to run
####################################################################
# # visualize predictions vs covariates
# predictions %>%
#   # --> TEMP
#   #slice(1:1e4) %>%
#   
#   select(covariate_names, ufp) %>%
#   
#   pivot_longer(all_of(covariate_names)) %>%
#   
#   ggplot(aes(x=value, y=ufp)) + 
#   facet_wrap(~name, scales="free") + 
#   geom_point(alpha=0.1) + 
#   geom_smooth() + 
#   labs(x="covariate value",
#        title = "Modeling data covariates and predicted in-sample UFP"
#        )
# 
# ggsave(file.path("output", "qc", "predicted ufp vs modeling covariates log truck.png", width = 16, height = 10))

