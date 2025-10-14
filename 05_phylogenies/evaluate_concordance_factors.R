# Big credit to Rob Lanfear https://www.robertlanfear.com/blog/files/concordance_factors.html

library(viridis)
library(ggplot2)
library(dplyr)
library(ggrepel)
library(GGally)
library(entropy)
library(gridExtra)
library(phytools)

setwd("C:/Documents/Projects/AplonisUCE/iqtree")

# read in data, focusing on the time75 subset
data = read.delim("aplonis_time75_concat_75per.phylip.treefile.cf.stat", header=T, comment.char='#')
# read in the cf tree, plot if you want to
tree <- read.newick("aplonis_time75_concat_75per.phylip.treefile.cf.tree")
tree <- reroot(tree, 45)
plot(tree,no.margin=TRUE,edge.width=2,cex=0.7)
# node labels to make it easier to interpret stat file
nodelabels(text=(1:tree$Nnode)+Ntip(tree),node=1:tree$Nnode+Ntip(tree),cex=0.5)

# sCF vs gCF, colored by node height, note low values across the board for gCF
length <- ggplot(data, aes(x = gCF, y = sCF)) + 
  geom_point(aes(colour = log(Length))) +
  scale_colour_viridis(direction = -1) + 
  xlim(0, 100) +
  ylim(0, 100) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  geom_smooth(method="lm", se=F) + theme(legend.position = "inside", legend.position.inside = c(0.8, 0.25))
length

# function from blog post for running chisq tests to get at deviations from ILS
chisq = function(DF1, DF2, N){
  tryCatch({
    # converts percentages to counts, runs chisq, gets pvalue
    chisq.test(c(round(DF1*N)/100, round(DF2*N)/100))$p.value
  },
  error = function(err) {
    # errors come if you give chisq two zeros
    # but here we're sure that there's no difference
    return(1.0)
  })
}

# make a big dataframe of interesting parameters
data_scf_ratio <- data %>%
  mutate(max_alt_scf = pmax(sDF1, sDF2)) %>%
  mutate(max_alt_sN = pmax(sDF1_N, sDF2_N)) %>%
  mutate(scf_ratio = sCF/max_alt_scf) %>%
  group_by(ID) %>%
  mutate(scf_diff = sCF-max_alt_scf) %>%
  mutate(diff_p = chisq(sCF, max_alt_scf, (sCF_N+max_alt_sN))) %>%
  mutate(p_33 = chisq(sCF, (100/3), sN)) %>%
  mutate(sEF_p = chisq(sDF1, sDF2, sN))
# subset to ones with no difference in sCF values
nodiff <- filter(data_scf_ratio, diff_p>=0.05 | scf_diff < 0 | p_33>=0.05) %>%
  select(ID, gCF, gDF1, gDF2, gCF_N, sCF, sDF1, sDF2, Label, scf_ratio, scf_diff, diff_p, p_33, sEF_p, sN)

# data frame with just chi squared stuff
chi_df <- data %>% 
  group_by(ID) %>%
  mutate(gEF_p = chisq(gDF1, gDF2, gN)) %>%
  mutate(sEF_p = chisq(sDF1, sDF2, sN))
chi_df$scf_p_adj = p.adjust(chi_df$sEF_p, method='BH')

# significant rows
filter(chi_df, sEF_p<0.05/nrow(chi_df))
