## Installs if needed
#install.packages('rexpokit')
install.packages('cladoRcpp')
#install.packages('devtools')
library(devtools)
devtools::install_github(repo='nmatzke/BioGeoBEARS', force=TRUE)

## Load libraries
library(rexpokit)
library(cladoRcpp)
library(BioGeoBEARS)
library(snow)
library(parallel)
library(phytools)
library(ape)

## Set variables

# Working directory
setwd('/Users/pachycephala/Dropbox/__WORK/1.MANUSCRIPTS/Aplonis-Ethan/BIOGEOBEARS/species-level')
extdata_dir = np(system.file("extdata", package="BioGeoBEARS"))
# Add the name of the tree here, later lines just print it out
treename = 'aplonis_mito_time34-tree.logcombined.newick'
moref(treename)
tree = read.tree(treename)
tree <- ladderize(tree, right = T)
tree
plot(tree)
axisPhylo()
# geographic information
geodir = 'time34_geography.txt'
moref(geodir)
tipranges = getranges_from_LagrangePHYLIP(lgdata_fn=geodir)
tipranges
max_range = 3

# DEC
BioGeoBEARS_run_object = define_BioGeoBEARS_run()
BioGeoBEARS_run_object$trfn = treename
BioGeoBEARS_run_object$geogfn = geodir
BioGeoBEARS_run_object$max_range_size = max_range
BioGeoBEARS_run_object$min_branchlength = 0.000001
BioGeoBEARS_run_object$include_null_range = TRUE
BioGeoBEARS_run_object$on_NaN_error = -1e50
BioGeoBEARS_run_object$speedup = TRUE
BioGeoBEARS_run_object$use_optimx = "GenSA"
BioGeoBEARS_run_object$num_cores_to_use = 8
BioGeoBEARS_run_object = readfiles_BioGeoBEARS_run(BioGeoBEARS_run_object)
BioGeoBEARS_run_object$return_condlikes_table = TRUE
BioGeoBEARS_run_object$calc_TTL_loglike_from_condlikes_table = TRUE
BioGeoBEARS_run_object$calc_ancprobs = TRUE
BioGeoBEARS_run_object
BioGeoBEARS_run_object$BioGeoBEARS_model_object
BioGeoBEARS_run_object$BioGeoBEARS_model_object@params_table
check_BioGeoBEARS_run(BioGeoBEARS_run_object)
runslow = TRUE
resfn = "aplonis.Rdata"
if (runslow)
{
  res = bears_optim_run(BioGeoBEARS_run_object)
  res    
  
  save(res, file=resfn)
  resDEC = res
} else {
  # Loads to "res"
  load(resfn)
  resDEC = res
}

#DEC+J
BioGeoBEARS_run_object = define_BioGeoBEARS_run()
BioGeoBEARS_run_object$trfn = treename
BioGeoBEARS_run_object$geogfn = geodir
BioGeoBEARS_run_object$max_range_size = max_range
BioGeoBEARS_run_object$min_branchlength = 0.000001
BioGeoBEARS_run_object$include_null_range = TRUE
BioGeoBEARS_run_object$include_null_range = TRUE
BioGeoBEARS_run_object$on_NaN_error = -1e50
BioGeoBEARS_run_object$speedup = TRUE
BioGeoBEARS_run_object$use_optimx = "GenSA"
BioGeoBEARS_run_object$num_cores_to_use = 8
BioGeoBEARS_run_object = readfiles_BioGeoBEARS_run(BioGeoBEARS_run_object)
BioGeoBEARS_run_object$return_condlikes_table = TRUE
BioGeoBEARS_run_object$calc_TTL_loglike_from_condlikes_table = TRUE
BioGeoBEARS_run_object$calc_ancprobs = TRUE
dstart = resDEC$outputs@params_table["d","est"]
estart = resDEC$outputs@params_table["e","est"]
jstart = 0.0001
BioGeoBEARS_run_object$BioGeoBEARS_model_object@params_table["d","init"] = dstart
BioGeoBEARS_run_object$BioGeoBEARS_model_object@params_table["d","est"] = dstart
BioGeoBEARS_run_object$BioGeoBEARS_model_object@params_table["e","init"] = estart
BioGeoBEARS_run_object$BioGeoBEARS_model_object@params_table["e","est"] = estart
BioGeoBEARS_run_object$BioGeoBEARS_model_object@params_table["j","type"] = "free"
BioGeoBEARS_run_object$BioGeoBEARS_model_object@params_table["j","init"] = jstart
BioGeoBEARS_run_object$BioGeoBEARS_model_object@params_table["j","est"] = jstart
check_BioGeoBEARS_run(BioGeoBEARS_run_object)
resfn = "aplonis_plusJ.Rdata"
runslow = TRUE
if (runslow)
{
  
  res = bears_optim_run(BioGeoBEARS_run_object)
  res    
  
  save(res, file=resfn)
  
  resDECj = res
} else {
  # Loads to "res"
  load(resfn)
  resDECj = res
}


# Set up PDF
pdffn = "aplonis_ultra_decVdecj_time34.pdf"
pdf(pdffn, width=6.5, height=9)

## DEC
# title for DEC
analysis_titletxt ="BioGeoBEARS DEC on Aplonis"
# setting up variables etc
results_object = resDEC
scriptdir = np(system.file("extdata/a_scripts", package="BioGeoBEARS"))
# States
res2 = plot_BioGeoBEARS_results(results_object, analysis_titletxt, addl_params=list("j"), plotwhat="text", label.offset=0.45, tipcex=0.2, statecex=0.4, splitcex=0.4, titlecex=0.8, plotsplits=TRUE, cornercoords_loc=scriptdir, include_null_range=TRUE, tr=ladderize(tree, right = T), tipranges=tipranges)
# Pie charts
plot_BioGeoBEARS_results(results_object, analysis_titletxt, addl_params=list("j"), plotwhat="pie", label.offset=0.3, tipcex=0.5, statecex=0.6, splitcex=0.6, titlecex=0.8, plotsplits=FALSE, cornercoords_loc=scriptdir, include_null_range=TRUE, tr=tree, tipranges=tipranges)

## DEC + J
# title for DEC+J
analysis_titletxt ="BioGeoBEARS DEC+J on Aplonis"
# setting up variables etc
results_object = resDECj
scriptdir = np(system.file("extdata/a_scripts", package="BioGeoBEARS"))
# States
res1 = plot_BioGeoBEARS_results(results_object, analysis_titletxt, addl_params=list("j"), plotwhat="text", label.offset=0.45, tipcex=0.2, statecex=0.4, splitcex=0.4, titlecex=0.8, plotsplits=TRUE, cornercoords_loc=scriptdir, include_null_range=TRUE, tr=ladderize(tree, right = T), tipranges=tipranges)
# Pie chart
plot_BioGeoBEARS_results(results_object, analysis_titletxt, addl_params=list("j"), plotwhat="pie", label.offset=0.3, tipcex=0.5, statecex=0.6, splitcex=0.6, titlecex=0.8, plotsplits=FALSE, cornercoords_loc=scriptdir, include_null_range=TRUE, tr=tree, tipranges=tipranges)

# Close and write PDF
dev.off()  # Turn off PDF
cmdstr = paste("open ", pdffn, sep="")
system(cmdstr) # Plot it




