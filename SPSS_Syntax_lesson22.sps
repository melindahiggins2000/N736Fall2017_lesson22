* Encoding: UTF-8.
* ======================================.
* N736 - LESSON 22 - Repeated Measures ANOVA
*
* Melinda Higgins
* dated Nov 13, 2017
*
* We're working with the HELP dataset
* we'll focus on the 5 PCS measurements over time
* ======================================.

* Look at distribution of the 5 PCS measurements
* notice the changing sample size.

FREQUENCIES VARIABLES=pcs pcs1 pcs2 pcs3 pcs4
  /FORMAT=NOTABLE
  /NTILES=4
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN
  /HISTOGRAM
  /ORDER=ANALYSIS.

* we can also use the explore tool in SPSS
* to apply listwise deletion to view
* complete cases only
* and we'll look at these by treatment group.

EXAMINE VARIABLES=pcs pcs1 pcs2 pcs3 pcs4
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

EXAMINE VARIABLES=pcs pcs1 pcs2 pcs3 pcs4 BY treat
  /PLOT BOXPLOT HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* compute the number of missing measurements
* of PCS over the 5 time points.

COMPUTE nmiss_pcs=nmiss(pcs,pcs1,pcs2,pcs3,pcs4).
EXECUTE.

FREQUENCIES VARIABLES=nmiss_pcs
  /ORDER=ANALYSIS.

* create an indicator variable to compared
* subjects who completed all versus those with
* missing time points.

COMPUTE pcs_nonemissing=nmiss_pcs < 1.
EXECUTE.

SORT CASES  BY pcs_nonemissing.
SPLIT FILE LAYERED BY pcs_nonemissing.

FREQUENCIES VARIABLES=age pss_fr pcs mcs cesd
  /FORMAT=NOTABLE
  /NTILES=4
  /STATISTICS=STDDEV MINIMUM MAXIMUM MEAN
  /ORDER=ANALYSIS.

SPLIT FILE OFF.

T-TEST GROUPS=pcs_nonemissing(0 1)
  /MISSING=ANALYSIS
  /VARIABLES=age pss_fr pcs mcs cesd
  /CRITERIA=CI(.95).

CROSSTABS
  /TABLES=female racegrp homeless BY pcs_nonemissing
  /FORMAT=AVALUE TABLES
  /STATISTICS=CHISQ 
  /CELLS=COUNT EXPECTED COLUMN 
  /COUNT ROUND CELL
  /METHOD=EXACT TIMER(5).

* RM-ANOVA
* uses listwise deletion
* TIME main effect
* notice sphericity is OK, but barely.

GLM pcs pcs1 pcs2 pcs3 pcs4
  /WSFACTOR=time 5 Polynomial 
  /METHOD=SSTYPE(3)
  /PLOT=PROFILE(time)
  /EMMEANS=TABLES(OVERALL) 
  /EMMEANS=TABLES(time) COMPARE ADJ(SIDAK)
  /PRINT=DESCRIPTIVE ETASQ HOMOGENEITY 
  /CRITERIA=ALPHA(.05)
  /WSDESIGN=time.

* error-bar plot of pcs at 5 time points
* listwise deletion used as in RM-ANOVA

GRAPH
  /ERRORBAR(CI 95)=pcs pcs1 pcs2 pcs3 pcs4
  /TITLE='PCS measures over time' 'listwise deletion for RM-ANOVA'
  /MISSING=LISTWISE.
