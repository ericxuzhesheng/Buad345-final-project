# ==============================================================================
# run_all.R - run the full pipeline from the project root:
#   Rscript R/run_all.R
# ==============================================================================
source("R/01_build_analysis_table.R")
source("R/02_aggregate_and_export.R")
source("R/03_figures.R")
message("\nPipeline complete.")
