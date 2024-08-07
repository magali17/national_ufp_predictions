
####################################################################
# SETUP
####################################################################
# Clear workspace of all objects and unload all extra (non-base) packages
rm(list = ls(all = TRUE))
if (!is.null(sessionInfo()$otherPkgs)) {
  res <- suppressWarnings(
    lapply(paste('package:', names(sessionInfo()$otherPkgs), sep=""),
           detach, character.only=TRUE, unload=TRUE, force=TRUE))}

####################################################################
# install ufp_model package 
## you may need to use the auth_token parameter to add a persona access token (PAT) in order to install something from a private repo. The PAT needs to have at least repo scope: https://github.com/settings/tokens 
## ?? if using the cluster, do this on the head node?

# remotes::install_github('karr-lab/ufp_model', auth_token = "ADD YOUR TOKEN HERE")

# pacman::p_load(ufp.model.saha2021)

####################################################################

# create directories
output_path <- file.path("output", "predictions", "original_model", "blocks", 
                         "20240716_log_truck",
                         "raw")

# create directories
lapply(c("input",
         output_path,
        #file.path("output", "predictions", "original_model", "blocks", "modified"),
        gsub("raw", "modified", output_path),
        
        # file.path("output", "predictions", "original_model", "blocks", 
        #           "20240716_log_truck",
        #           #"20240621_original_model",
        #           "raw"),
        # file.path("output", "predictions", "original_model", "blocks", 
        #           "20240716_log_truck",
        #           #"20240621_original_model",
        #           "modified"),
        
         file.path("output", "qc"),
        file.path("output", "other"),
        file.path("output", "summary", "20240716_log_truck"),
         file.path("output", "winsorize", "20240716_log_truck"),
        "original_model_fit"
         ), 
       function(x) {if(!dir.exists(x)){dir.create(x, recursive = T)}})

####################################################################
#  
####################################################################
