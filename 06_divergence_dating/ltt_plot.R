# simple R script for making LTT plots for subsets of taxa from timetree

library(ape)

setwd("C:/Documents/Projects/AplonisUCE/ltt")

# read in time tree
tree_75 <- read.nexus("aplonis_mito_time75-tree_logcombined.tre")
# outgroup tips to drop
drop_tips <- c("Ampeliceps_coronatus_AMNH10030", "Basilornis_celebensis_KU130319", "Basilornis_miranda_KU113357", "Gracula_religiosa_KU128294", "Mino_krefti_MSB277187", "Rhabdornis_mystacalis_KU119811", "Sarcops_calvus_KU132009", "Scissirostrum_dubium_UWBM90366")
# drop tips and plot subspecies level
tree_67 <- drop.tip(tree_75, drop_tips)

# keep list for species level, then subset
keep_species <-c("A_atrifusca_KU_104055", "A_brunneicapillus_UWBM60250", "A_cantoroides_AMNH19853", "A_cinerascens_UWBM42817", "A_corvina_RMNH_90380", "A_crassa_AMNH_667749", "A_dichroa_MSB277311", "A_feadensis_heureka_MVZ_90281", "A_fusca_hulliana_AMNH_667998", "A_grandis_macrura_UWBM60254", "A_insularis_MSB279880", "A_magna_brevicauda_AMNH_301387", "A_metallica_metallica_KU97869", "A_minor_todayensis_FMNH357661", "A_mysolensis_foresteni_YPM_75229", "A_mystacea_AMNH_427398", "A_opaca_orii_KU117213", "A_panayensis_pachistorhina_USNM_486786", "A_panayensis_panayensis_KU121758", "A_panayensis_tytleri_AMNH_667522", "A_pelzelni_AMNH_331652", "A_santovestris_NHMUK_1954_52_30", "A_striata_atronitens_UMMZ_221919", "A_striata_striata_UMMZ_221914", "A_tabuensis_tabuensis_KU119026", "A_zelandica_rufipennis_YPM_40517")
species <- keep.tip(tree_67, keep_species)

# keep list for superspecies level, then subset
keep_superspecies <- c("A_atrifusca_KU_104055", "A_minor_todayensis_FMNH357661", "A_panayensis_pachistorhina_USNM_486786", "A_panayensis_panayensis_KU121758", "A_panayensis_tytleri_AMNH_667522", "A_mysolensis_foresteni_YPM_75229", "A_cantoroides_AMNH19853", "A_opaca_orii_KU117213", "A_brunneicapillus_UWBM60250", "A_metallica_metallica_KU97869", "A_tabuensis_tabuensis_KU119026", "A_crassa_AMNH_667749", "A_grandis_macrura_UWBM60254", "A_insularis_MSB279880", "A_mystacea_AMNH_427398", "A_santovestris_NHMUK_1954_52_30", "A_zelandica_rufipennis_YPM_40517")
superspecies <- keep.tip(tree_67, keep_superspecies)

# plot on top of eachother
ltt.plot(tree_67, col = "black", lwd=3)
ltt.lines(species, col = "purple3", lwd=3.5)
ltt.lines(superspecies, col="forestgreen", lwd=4)


