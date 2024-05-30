
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

# remotes::install_github('karr-lab/ufp_model', auth_token = "ADD YOUR TOKEN HERE")

####################################################################
pacman::p_load(ufp.model.saha2021,
               tidyverse)

output_path <- file.path("output", "predictions", "2016_2017", "raw", "blocks")

# create directories
lapply(c(file.path(output_path, "txt"),
         file.path(output_path, "rda"),
         file.path("output", "predictions", "2016_2017", "modified", "blocks", "txt"),
         file.path("output", "predictions", "2016_2017", "modified", "blocks", "rda"),
         file.path("output", "qc"),
         file.path("output", "winsorize")
         ), 
       function(x) {if(!dir.exists(x)){dir.create(x, recursive = T)}})






####################################################################
#  
####################################################################
