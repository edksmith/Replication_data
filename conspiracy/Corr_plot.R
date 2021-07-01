#################### SET UP ####################
library(haven)
library(corrplot)
library(tidyverse)
setwd("~/Dropbox/Keith and Adam Projects/Conspiracy!/Stata Stuff")
R_corr <- read_dta("R_corr.dta")

################# CORRELATION ###################

correlations <- cbind.data.frame(R_corr$idea,
                                R_corr$coemiss,R_corr$skptk,
                                R_corr$fftax,R_corr$subrnw,R_corr$banapp,
                                R_corr$CCcon_gen,R_corr$sex,
                                R_corr$age,R_corr$income,R_corr$education,
                                R_corr$partyid)
    

colnames(correlations) <- c("Consp. Ideation", "CO2 Marginal Impact", "CC Exaggerated", "Increase FF Tax",
                            "Subsidize Renewables","Ban Old Apps",
                            "Climate Change Concern", "Sex","Age", "Income", "Education", "Party ID")
correlations <- na.omit(correlations)
res <- cor.mtest(correlations, conf.level = .95)

corrplot(cor(correlations), method = "color",
         type = "lower", number.cex = .7,
         addCoef.col = "black", 
         tl.col = "black", tl.srt = 90, 
         p.mat = res$p, sig.level = 0.05, insig = "blank", 
         diag = FALSE,number.digits = 2)

correlations <- cbind.data.frame(R_corr$idea,
                                R_corr$flu, R_corr$china,
                                R_corr$mask, R_corr$socdist, R_corr$contact,
                                R_corr$COVcon_gen,
                                R_corr$coemiss,R_corr$skptk,
                                R_corr$fftax,R_corr$subrnw,R_corr$banapp,
                                R_corr$CCcon_gen,R_corr$sex,
                                R_corr$age,R_corr$income,R_corr$education,
                                R_corr$partyid)


colnames(correlations) <- c("Consp. Ideation", 
                            "No More Danger Flu", "Made in Chinese Lab",
                            "Wear a mask", "Social Distance", "Limit Contact",
                            "COVID Concern",
                            "CO2 Marginal Impact", "C.C. Exaggerated", "Increase FF Tax",
                            "Subsidize Renewables","Ban Old Apps",
                            "C.C. Concern", "Sex","Age", "Income", "Education", "Party ID")
correlations <- na.omit(correlations)
res <- cor.mtest(correlations, conf.level = .95)

pdf('Graphs/Final/Corr_plot.pdf')
corrplot(cor(correlations), method = "color",
         type = "upper", number.cex = .7,
         addCoef.col = "black", 
         tl.col = "black", tl.srt = 90, 
         p.mat = res$p, sig.level = 0.05, insig = "blank", 
         diag = FALSE,number.digits = 2)
dev.off()
