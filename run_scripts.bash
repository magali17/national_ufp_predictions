# bash run_scripts.bash

#Rscript 1a_predict_with_og_model.R

Rscript 1b_winsorize_predictions.R


## knit markdown with results 
# Rscript -e 'rmarkdown::render("9_summarize_epi.Rmd", "html_document")'
