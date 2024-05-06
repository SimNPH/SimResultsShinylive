library("SimNPH")
library("tidyverse")

# read data ---------------------------------------------------------------

design_vars_all <- c("censoring_prop", "n_pat_design", "recruitment", "effect_size_ph", "hazard_ctrl")
design_vars_delayed     <- c("delay", design_vars_all)
design_vars_crossing    <- c("crossing", "hr_before", design_vars_all)
design_vars_progression <- c("prog_prop_trt", "prog_prop_ctrl", "hr_before_after", design_vars_all)
design_vars_subgroup    <- c("prevalence", "hr_subgroup_relative", design_vars_all)

shhr_varnames <- c("hazard_ctrl", "prog_rate_ctrl", "hazard_after_prog", "hazard_trt", "delay", "hazard_trt_after", "hazard_trt_before", "hazard_subgroup", "prevalence", "prog_rate_trt", "crossing")
names(shhr_varnames) <- shhr_varnames

if(!exists("data_dir")){
  stop("set data dir!")
}

delayed <- readRDS(paste0(data_dir, "delayed_revision2.Rds"))

crossing <- readRDS(paste0(data_dir, "crossing_revision2.Rds"))

subgroup <- readRDS(paste0(data_dir, "subgroup_revision2.Rds"))

progression <- readRDS(paste0(data_dir, "progression_revision2.Rds"))


# Metadata ----------------------------------------------------------------

# metadata for methods ----------------------------------------------------

method_metadata <- tibble::tribble(
  # variable name      direction (one sided test)                                  name for output   estimator/test/gs-test  procedure category
  ~method,            ~direction, ~method_name,                     ~type,                        ~category,
  "ahr_6m",              "lower", "AHR 6m",                         "estimator",             "Average Hazard Ratio",
  "ahr_12m",             "lower", "AHR 12m",                        "estimator",             "Average Hazard Ratio",
  "ahr_24m",             "lower", "AHR 24m",                        "estimator",             "Average Hazard Ratio",
  "ahr_36m",             "lower", "AHR 36m",                        "estimator",             "Average Hazard Ratio",
  "gahr_6m",             "lower", "gAHR 6m",                        "estimator",             "Geometric Average Hazard Ratio",
  "gahr_12m",            "lower", "gAHR 12m",                       "estimator",             "Geometric Average Hazard Ratio",
  "gahr_24m",            "lower", "gAHR 24m",                       "estimator",             "Geometric Average Hazard Ratio",
  "gahr_36m",            "lower", "gAHR 36m",                       "estimator",             "Geometric Average Hazard Ratio",
  "median_surv",        "higher", "diff. med. surv.",               "estimator",             "Diff. Median Survival",
  "milestone_6m",       "higher", "milestone surv. ratio 6m",       "estimator",             "Ratio of Milestone Survival",
  "milestone_12m",      "higher", "milestone surv. ratio 12m",      "estimator",             "Ratio of Milestone Survival",
  "milestone_24m",      "higher", "milestone surv. ratio 24m",      "estimator",             "Ratio of Milestone Survival",
  "milestone_36m",      "higher", "milestone surv. ratio 36m",      "estimator",             "Ratio of Milestone Survival",
  "rmst_diff_6m",       "higher", "RMST (6m) difference",           "estimator",             "Diff. RMST",
  "rmst_diff_12m",      "higher", "RMST (12m) difference",          "estimator",             "Diff. RMST",
  "rmst_diff_24m",      "higher", "RMST (24m) difference",          "estimator",             "Diff. RMST",
  "rmst_diff_36m",      "higher", "RMST (36m) difference",          "estimator",             "Diff. RMST",
  "cox",                 "lower",  "Cox regression",                "estimator",             "Cox regression",
  "aft_weibull",        "higher", "AFT Weibull",                    "estimator",             "Accelerated Failure Time Model",
  "aft_lognormal",      "higher", "AFT log-normal",                 "estimator",             "Accelerated Failure Time Model",
  "diff_med_weibull",   "higher", "diff. med. surv. Weibull",       "estimator",             "Diff. Median Survival",
  "fh_0_0",                   NA, "FH 0,0",                         "test",                  "Fleming-Harrington Test",
  "fh_0_1",                   NA, "FH 0,1",                         "test",                  "Fleming-Harrington Test",
  "fh_1_0",                   NA, "FH 1,0",                         "test",                  "Fleming-Harrington Test",
  "fh_1_1",                   NA, "FH 1,1",                         "test",                  "Fleming-Harrington Test",
  "logrank",                  NA, "logrank test",                   "test",                  "Log-Rank Test",
  "max_combo",                NA, "max-combo test",                 "test",                  "Max-Combo Test",
  "modest_6",                 NA, "modestly wtd. t*=6m",            "test",                  "Modestly Weighted Test",
  "modest_8",                 NA, "modestly wtd. t*=8m",            "test",                  "Modestly Weighted Test",
  "fh_gs_0_0",                NA, "FH 0,0, grp. seq.",              "group sequential test", "Fleming-Harrington Test",
  "fh_gs_0_1",                NA, "FH 0,1, grp. seq.",              "group sequential test", "Fleming-Harrington Test",
  "fh_gs_1_0",                NA, "FH 1,0, grp. seq.",              "group sequential test", "Fleming-Harrington Test",
  "fh_gs_1_1",                NA, "FH 1,1, grp. seq.",              "group sequential test", "Fleming-Harrington Test",
  "logrank_gs",               NA, "logrank test, grp. seq.",        "group sequential test", "Log-Rank Test",
  "max_combo_gs",             NA, "max-combo test, grp. seq.",      "group sequential test", "Max-Combo Test",
  "modest_gs_6",              NA, "modestly wtd. t*=6m, grp. seq.", "group sequential test", "Modestly Weighted Test",
  "modest_gs_8",              NA, "modestly wtd. t*=8m, grp. seq.", "group sequential test", "Modestly Weighted Test"
)

# metadata for output columns ---------------------------------------------

rename_cols <- tibble::tribble(
  ~colname_old,                   ~colname_new,
  "random_withdrawal",            "rate of random withdrawal",                             
  "n_pat_design",                 "number of patients",                                    
  "recruitment",                  "recruitment time",                                      
  "delay",                        "delay of onset of treatment effect",                    
  "hr_after_onset",               "HR after onset of treatment effect",                    
  "median_survival_ctrl",         "median survival in the control arm",                    
  "crossing",                     "time of crossing of the hazards",                       
  "hr_before",                    "HR before crossing of the hazards",                     
  "hr_after",                     "HR after crossing of the hazards",                      
  "hr_trt",                       "HR treatment vs. control",                              
  "hr_subgroup_display",          "HR subgroup vs. control",                               
  "prevalence",                   "prevalence",                                            
  "hr_death_before_prog",         "HR death before prog. treatment vs. control",           
  "hr_after_prog_ctrl",           "HR death after prog. vs. control before prog.",         
  "median_time_to_prog_ctrl",     "median time to progression, control",                   
  "hr_prog",                      "HR progression treatment vs. control",                  
  "median_survival_before_prog",  "median time to death without progression, control",     
  "median_survival_trt",         "median survival in the treatment arm",                   
  "rmst_trt_6m",                 "RMST (6m) in the treatment arm",                         
  "rmst_ctrl_6m",                "RMST (6m) in the control arm",                           
  "gAHR_6m",                     "geometric average hazard ratio (6m)",                    
  "AHR_6m",                      "average hazard ratio (6m)",                              
  "milestone_survival_trt_6m",   "milestone survival in the treatment arm (6m)",           
  "milestone_survival_ctrl_6m",  "milestone survival in the control arm (6m)",             
  "rmst_trt_12m",                "RMST (12m) in the treatment arm",                        
  "rmst_ctrl_12m",               "RMST (12m) in the control arm",                          
  "gAHR_12m",                    "geometric average hazard ratio (12m)",                   
  "AHR_12m",                     "average hazard ratio (12m)",                             
  "milestone_survival_trt_12m",  "milestone survival in the treatment arm (12m)",          
  "milestone_survival_ctrl_12m", "milestone survival in the control arm (12m)",            
  "rmst_trt_24m",                "RMST (24m) in the treatment arm",                        
  "rmst_ctrl_24m",               "RMST (24m) in the control arm",                          
  "gAHR_24m",                    "geometric average hazard ratio (24m)",                   
  "AHR_24m",                     "average hazard ratio (24m)",                             
  "milestone_survival_trt_24m",  "milestone survival in the treatment arm (24m)",          
  "milestone_survival_ctrl_24m", "milestone survival in the control arm (24m)",            
  "rmst_trt_36m",                "RMST (36m) in the treatment arm",                        
  "rmst_ctrl_36m",               "RMST (36m) in the control arm",                          
  "gAHR_36m",                    "geometric average hazard ratio (36m)",                   
  "AHR_36m",                     "average hazard ratio (36m)",                             
  "milestone_survival_trt_36m",  "milestone survival in the treatment arm (36m)",          
  "milestone_survival_ctrl_36m", "milestone survival in the control arm (36m)",            
  "descriptive.n_pat",           "average number of patients",                             
  "descriptive.evt",             "average number of events",                               
  "descriptive.evt_ctrl",        "average number of events in the control arm",            
  "descriptive.evt_trt",         "average number of events in the treatment arm",          
  "method",                      "method",                                                 
  "mean_est",                    "mean point estimate",                                    
  "median_est",                  "median point estimate",                                  
  "sd_est",                      "standard deviation of point estimate",                   
  "bias",                        "bias",                                                   
  "mse",                         "mean squared error",                                     
  "mae",                         "mean absolute error",                                    
  "coverage",                    "CI coverage",                                            
  "null_cover",                  "proportions of CIs that contain the null value",         
  "width",                       "average CI width",                                       
  "mean_n_pat",                  "average number of patients (group sequential)",          
  "mean_n_evt",                  "average number of events (group sequential)",            
  "rejection",                   "rejection rate, one sided alpha=0.025",                  
  "study_time",                  "average study time (group sequential)",                  
  "followup",                    "average max followup (group sequential)",                
  "censoring_prop",              "proportion of censored patients",
  "effect_size_ph",              "logrank power under PH",
  "hazard_ctrl",                 "control arm hazard",
  "hr_subgroup_relative",        "HR subgroup vs. treatment",
  "prog_prop_trt",               "prop. of patients with prog., trt",
  "prog_prop_ctrl",              "prop. of patients with prog., ctrl",
  "hr_before_after",             "HR ctrl before prog. vs. after prog.",
)

# columns to tansform from days to months ---------------------------------

stats_scale <- c("mean_est", "median_est", "sd_est", "bias", "sd_bias", "mse", "sd_mse", "mae", "sd_mae", "width", "sd_width", "mean_sd", "sd_sd")
methods_scale <- c("diff_med_weibull", "median_surv", "rmst_diff_12m", "rmst_diff_6m")

time_varnames <- c(
  "delay", "crossing", "recruitment", "median_survival_trt", 
  "median_survival_ctrl",
  "rmst_trt_6m", "rmst_ctrl_6m", 
  "rmst_trt_12m", "rmst_ctrl_12m", 
  "rmst_trt_24m", "rmst_ctrl_24m", 
  "rmst_trt_36m", "rmst_ctrl_36m", 
  "descriptive.max_followup", "descriptive.study_time", 
  "descriptive.sd_max_followup", "descriptive.sd_study_time", 
  as.character(outer(methods_scale, stats_scale, \(x,y){str_c(x, ".", y)}))
  )

time_trafo <- SimNPH::d2m


# prepare data for app ----------------------------------------------------

prepare_data <- function(dataset, design_varnames){
  # transform time vars
  dataset <- dataset |> 
    mutate(
      across(any_of(time_varnames), time_trafo)
    )
  
  # pivot longer
  dataset <- results_pivot_longer(dataset) |>
  left_join(method_metadata, by = "method") |> # add metadata
    mutate(
      # one sided test based on CI
      ci_based_one_sided_rejection = case_when(
        direction == "lower" ~ 1 - null_upper,
        direction == "higher" ~ 1 - null_lower,
        TRUE ~ NA_real_
      ),
      # combine columsn with different names acros estimators/tests/gs-tests
      # coalesce: take first value, if it is missing take second value
      mean_n_pat = coalesce(mean_n_pat, n_pat),
      mean_n_evt = coalesce(mean_n_evt, n_evt),
      sd_n_pat   = coalesce(sd_n_pat, sd_npat),
      sd_n_evt   = coalesce(sd_n_evt, sd_nevt),
      study_time = coalesce(study_time, descriptive.study_time),
      followup   = coalesce(followup, descriptive.max_followup),
      rejection  = coalesce(rejection, rejection_0.025),
      rejection  = coalesce(rejection, ci_based_one_sided_rejection)
    )
  
  # rename methods
  # stopifnot(all(dataset$method %in% method_metadata$method))
  dataset <- dataset |> 
    filter(method %in% method_metadata$method)
  
  tmp_method_names <- method_metadata$method_name |>
    setNames(method_metadata$method)
  
  dataset$method <- tmp_method_names[dataset$method]
  
  # rename columns
  tmp_selection <- rename_cols$colname_old |> 
    setNames(rename_cols$colname_new) |>
    c(shhr_varnames) |> 
    keep(\(x){x %in% names(dataset)})
  
  dataset <- dataset |>
    select(tmp_selection)
  
  tmp_selection2 <- rename_cols$colname_new |> 
    setNames(rename_cols$colname_old)
  
  design_varnames <- tmp_selection2[design_varnames] |> 
    unname()
  
  list(
    data = dataset,
    design_variables = design_varnames,
    methods = unique(dataset$method),
    filter_values = lapply(
      design_varnames,
      \(var){
        unique(dataset[[var]]) |>
          sort()
      }
    ) |> 
      setNames(design_varnames)
  )
}

datasets <- list(
  delayed     = prepare_data(delayed,     design_vars_delayed     ),
  crossing    = prepare_data(crossing,    design_vars_crossing    ),
  subgroup    = prepare_data(subgroup,    design_vars_subgroup    ),
  progression = prepare_data(progression, design_vars_progression )
)


saveRDS(datasets, "datasets.Rds")

# render markdown ---------------------------------------------------------

rmarkdown::render(
  "description.md",
  rmarkdown::html_document(
    template = "pandoc_template.html"
  ),
  output_file="app/description.html"
) 
