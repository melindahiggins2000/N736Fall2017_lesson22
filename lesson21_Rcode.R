# ==================================
# N736 Lesson 21 - dependent/paired data
#
# dated 11/8/2017
# Melinda Higgins, PhD
# 
# ==================================

# ==================================
# we're be working with the 
# helpmkh dataset
# ==================================

library(tidyverse)
library(haven)

helpdat <- haven::read_spss("helpmkh.sav")

# ============================================.
# For this lesson we'll use the helpmkh dataset
#
# In the HELP dataset there are 5 time points
# baseline and 4 follow-up time points 
# at 6m, 12m, 18m and 24m
#
# for today's lesson we will be working with the PCS
# physical component score for the SF36 quality of life tool
# let's look at how these 5 PCS measurements are
# correlated across time
#
# and we'll also look at the treat group.
# ============================================.

h1 <- helpdat %>%
  select(treat, pcs, pcs1, pcs2, pcs3, pcs4)

# ============================================.
# let's look at the correlations between 
# these variables
# ============================================;

# look at the correlation matrix between
# the 5 pcs measurements over time
library(psych)
psych::corr.test(h1[,2:6], method="pearson")

# notice the varying sample sizes
# across these paired tests
# this is due to attrition over time

# =================================================.
# notice that most of these correlations have r>0.4 indicating
# moderate to large correlation across time
# this makes sense since particpants scores probably
# do not change a lot every 6 months and will tend to be 
# similar to each other WITHIN each particpant
# more so than pcs scores BETWEEN participants
# =================================================.

# let's look at the first 2 time points and run a PAIRED t-test
# to see if the scores are significantly changing across time
# WITHIN individuals.

t.test(h1$pcs, h1$pcs1, paired=TRUE)

# another way to approach this is to compute
# the change scores and compare the difference
# scores to 0.

h1 <- h1 %>%
  mutate(diff_pcs_bl_1=pcs - pcs1)

t.test(h1$diff_pcs_bl_1, mu=0)

# when we run a paired t-test, one of the assumptions
# is that the difference or change scores have a normal
# distribution - not the original scores but the difference scores
# these are good here.

qqnorm(h1$diff_pcs_bl_1)

# we can also run a paired t-test using RM-ANOVA
# repeated measures ANOVA
# compare this F-test wth the 
# t-test from the paired t-test
# for 2 groups when df=1
# a t(df=1)^2 = F-test

# to do these analyses in R, we first
# have to reshape the data from WIDE
# to long

# add rowid to h1
h1 <- h1 %>%
  mutate(rowid=as.numeric(rownames(h1)))
  
h1long <- h1 %>%
  gather(key=item,
         value=value,
         -c(treat,diff_pcs_bl_1,rowid))

# add a time variable to long format
h1long <- h1long %>%
  mutate(time=c(rep(0,453),
                rep(1,453),
                rep(2,453),
                rep(3,453),
                rep(4,453)))

h1long_bl1 <- h1long %>%
  filter(time<2) %>%
  select(rowid,value,time,treat)

library(car)
rm1 <- aov(value~factor(time)+Error(factor(rowid)), 
                data = h1long_bl1)
summary(rm1)

# compare the 2 changes from BL to 6m
# for pcs and pcs1 between the 2 treat groups
bartlett.test(h1$diff_pcs_bl_1~h1$treat)
t.test(h1$diff_pcs_bl_1~h1$treat, var.equal=TRUE)

# now let's run a RM-ANOVA
# for the changes from BL to 6m
# BETWEEN the 2 treat groups
# compare the time*treat effect to
# the t-test above for the difference scores
# look at the 2nd part of the table

rm2 <- aov(value~(factor(time)*factor(treat))+
             Error(factor(rowid)/(treat)), 
           data = h1long_bl1)
summary(rm2)

# we can make a plot of
# pcs and pcs1 scores by group
# to get an idea of trend across time
# but this plot is cross sectional not paired

ggplot(h1long_bl1, aes(x=factor(time), y=value)) + 
  geom_boxplot() +
  stat_summary(fun.y=mean, geom="point", shape=5, size=4) + 
  xlab("Time: Baseline (0) and 6m (1)") +
  ylab("PCs Scores") +
  facet_wrap(~treat) +
  ggtitle("Usual Care = 0; HELP Clinic = 1")




# from the cookbook for R
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

h1long_bl1_nomiss <- h1long_bl1[!complete.cases(h1long_bl1),]

h1se <- summarySE(h1long_bl1, 
                  measurevar="value", groupvars=c("time","treat"))
ggplot(h1se, aes(x=time, y=value, colour=treat)) + 
  geom_errorbar(aes(ymin=value-se, ymax=value+se), width=.1) +
  geom_line() +
  geom_point()

