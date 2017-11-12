* Encoding: UTF-8.
* =================================================.
* N736 Lesson 21 - dependent/paired data
*
* dated 11/8/2017
* Melinda Higgins, PhD
* =================================================.

* =================================================.
* In the HELP dataset there are 5 time points
* baseline and 4 follow-up time points at 6m, 12m, 18m and 24m
*
* for today's lesson we will be working with the PCS
* physical component score for the SF36 quality of life tool
* let's look at how these 5 PCS measurements are
* correlated across time.
* =================================================.

CORRELATIONS
  /VARIABLES=pcs pcs1 pcs2 pcs3 pcs4
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

* =================================================.
* notice that most of these correlations have r>0.4 indicating
* moderate to large correlation across time
* this makes sense since particpants scores probably
* do not change a lot every 6 months and will tend to be 
* similar to each other WITHIN each particpant
* more so than pcs scores BETWEEN participants
* =================================================.

* let's look at the first 2 time points and run a PAIRED t-test
* to see if the scores are significantly changing across time
* WITHIN individuals.

T-TEST PAIRS=pcs WITH pcs1 (PAIRED)
  /CRITERIA=CI(.9500)
  /MISSING=ANALYSIS.

* another way to approach this is to compute
* the change scores and compare the difference
* scores to 0.

COMPUTE diff_pcs_bl_1=pcs - pcs1.
EXECUTE.

T-TEST
  /TESTVAL=0
  /MISSING=ANALYSIS
  /VARIABLES=diff_pcs_bl_1
  /CRITERIA=CI(.95).

* when we run a paired t-test, one of the assumptions
* is that the difference or change scores have a normal
* distribution - not the original scores but the difference scores
* these are good here.

EXAMINE VARIABLES=diff_pcs_bl_1
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING PAIRWISE
  /NOTOTAL.

* we can also run a paired t-test using RM-ANOVA
* repeated measures ANOVA
* compare this F-test wth the 
* t-test from the paired t-test
* for 2 groups when df=1
* a t(df=1)^2 = F-test

DATASET ACTIVATE DataSet1.
GLM pcs pcs1
  /WSFACTOR=time 2 Polynomial 
  /METHOD=SSTYPE(3)
  /EMMEANS=TABLES(OVERALL) 
  /EMMEANS=TABLES(time) 
  /PRINT=DESCRIPTIVE ETASQ HOMOGENEITY 
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time.

* compare the 2 changes from BL to 6m
* for pcs and pcs1 between the 2 treat groups

T-TEST GROUPS=treat(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=diff_pcs_bl_1
  /CRITERIA=CI(.95).

* now let's run a RM-ANOVA
* for the changes from BL to 6m
* BETWEEN the 2 treat groups
* compare the time*treat effect to
* the t-test above for the difference scores

GLM pcs pcs1 BY treat
  /WSFACTOR=time 2 Polynomial 
  /METHOD=SSTYPE(3)
  /EMMEANS=TABLES(OVERALL) 
  /EMMEANS=TABLES(time) COMPARE ADJ(LSD)
  /EMMEANS=TABLES(treat) COMPARE ADJ(LSD)
  /EMMEANS=TABLES(treat*time) COMPARE(treat) 
  /EMMEANS=TABLES(treat*time) COMPARE(time) 
  /PRINT=DESCRIPTIVE ETASQ HOMOGENEITY 
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time 
  /DESIGN=treat.

* we can make a plot of
* pcs and pcs1 scores by group
* to get an idea of trend across time
* but this plot is cross sectional not paired

GRAPH
  /ERRORBAR(CI 95)=pcs pcs1
  /PANEL COLVAR=treat COLOP=CROSS
  /MISSING=LISTWISE.
