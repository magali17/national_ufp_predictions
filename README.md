# National UFP Predictions
Summary: This project is used to generate UFP predictions across the US using existing and updated models


## Summary of Steps

**install the UFP Model package**

`remotes::install_github('karr-lab/ufp_model')`


**run scripts, in order:**
* 0_setup.R (sets up directories etc.).  
* 1a_predict...R (generate predictions using covariate files)
* 1b_clean_predictions....R (clean/modify raw model predictions)


**view saved predictions**
These are saved as txt and rda files both in their raw and modified (winsorized) form under: output/predictions/2016_2017