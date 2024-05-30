# National UFP Predictions
This project is used to generate UFP predictions across the US using the existing 2016-2017 (Saha et al. 2021) and updated UFP models

Predictions are generated using the [ufp.model.saha2021 R package](https://github.com/karr-lab/ufp_model)

## Summary of Steps

**install the UFP Model package**

`remotes::install_github('karr-lab/ufp_model')`


**run R scripts, in this order:**
* 0_setup.R (sets up directories etc.).  
* 1a_predict...R (generate predictions using covariate files)
* 1b_clean_predictions....R (clean/modify raw model predictions)


**view saved predictions**    
These are saved as txt and rda files both in their raw and modified (winsorized) form under: output/predictions/2016_2017