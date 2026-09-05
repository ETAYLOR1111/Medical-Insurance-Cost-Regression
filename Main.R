# Required Packages:
# install.packages("tidyverse")
# install.packages("car")

# To use the packages
library(tidyverse)
library(car)

# Downloading the dataset
raw_df <- read_csv("Dataset/Insurance.csv")
# The data does not specify the currency of insurance charges.
# However, given the context of the data, US dollars are assumed for interpretation.

  ###################
 # Exploring Data #
#################


dim(raw_df)
# There are 1338 observations and  7 variables.

names(raw_df)
# The response variable in this project is the 'charges', which is the cost of medical insurance for each individual


# Checking the datatypes of the covariates:

str(raw_df)

# All variables have been imported with appropriate data types for this project.
# The Age and Children variables would be integer-valued, but have been kept as numeric for modelling purposes.


# Identifying duplicates:

raw_df[duplicated(raw_df),]

# One duplicate row was identified.


# Checking the duplicated row:

raw_df |> 
  filter(age == 19,
         sex == 'male',
         between(bmi,30,31))

# The dataset provides no additional information to determine whether these observations are the same individual or duplicated copies.
# For this project, one copy was removed.

# Removing Duplicate Row
df <- raw_df[!duplicated(raw_df),]


# Checking for missing values:

View(df[!complete.cases(df), ])
# There is no missing data in this dataset



  #############################
 # Exploratory Data Analysis #
#############################

### Summary Statistics ###

View(df |>
  select(age, bmi, children, charges) |>
  summarise(across(everything(),
                   list(Lower = min,
                        Upper = max,
                        Mean = mean))) |> 
                    pivot_longer(everything()))


# Covariate: | Minimum | Maximum | Mean
# Age            18        64      39.2
# BMI           16.0      53.1     30.7
# Children        0         5       1.1
# Charges      $1122    $63770    $13279



### Distribution of Charges ###

df |> 
  ggplot(aes(charges)) +
  geom_histogram(color="black", fill="blue", bins = 40) +
  labs(title = "The Distribution of Charges")

# The distribution of charges is strongly right-skewed.
# A logarithmic transformation of charges may be worth investigating.



### Distribution of Age ###

 df |> 
   ggplot(aes(age)) +
   geom_histogram(col = "black", fill = "blue", bins = 45) +
   labs(title = "Distribution of Age")

# The distribution of age is relatively stable with most observations falling within a narrow range, although there are some increases in frequency around <20, 30 and 52.



### Distribution of BMI ###
 
df |> 
  ggplot(aes(bmi)) +
  geom_histogram(col = "black", fill = "blue", bins = 40) +
  labs(title = "Distribution of BMI")

# The distribution of BMI is approximately symmetric, with a mean of 30.7.



### Relationship between Age and BMI ###

df |> 
  ggplot(aes(age,
             bmi)) +
  geom_point() +
  geom_smooth(method = lm, se = F, col = "red") +
  labs(title = "Age Against BMI")

# The data is scattered with no obvious pattern implying age has little effect on BMI in this data.

# To clarify the last point:
summary(lm(bmi ~ age, data = df))

# The p-value is low, suggesting there is sufficient evidence to claim that there is a relationship between BMI and age.
# However, for every additional year, BMI increases by 0.048, which is a very small increase.
# Additionally, the R(^2) statistic highlights that the model only captures 1% of BMI variation.



### Relationship between BMI and smoking ###


# Smoking can interfere with appetite and metabolism, so it would be sensible to investigate their relationship:

df |> 
  ggplot(aes(smoker,
             bmi))+
  geom_boxplot() +
  labs(title = "Smoker vs Non-Smoker BMI")

# From the boxplot, smokers have a slightly larger IQR than non-smokers but non-smokers have more outliers.
# We cannot say that smoking has a significant impact on BMI in this data


# To clarify these claims, we can check the summary
summary(lm(bmi ~ smoker, data = df))

# The high p-value suggests there is insufficient evidence for a difference in the mean of smokers and non-smokers.
# Additionally, the R(^2) statistic is very small, meaning smoking captures incredibly small amount of variation of BMI.
# Therefore, there is little evidence in this dataset that the smoker variable is a useful predictor for BMI.



  ##################################
 # Exploring Simple Linear Models #
##################################

### Investigating Non-Categorical Covariates ###

## Age against Charges ##

df |> 
  ggplot(aes(age,
             charges)) +
  geom_point(size = 1) +
  geom_smooth(col = "red", method = lm, se = F) +
  labs(title = "Medical Insurance Costs Across Ages")

# The plot shows a positive association between age and charges, although the observations appear to form several distinct bands.
# The lowest band looks the most dense, implying it has little variation.
# There are a few observable outliers in the data.
# It seems that age doesn't explain much of the variation in charges.

# Summary for age against charges linear model.
summary(lm(charges ~ age, data = df))

# The estimated coefficient for age is 257.23, suggesting that a one-year increase in age is associated with an estimated $257.23 increase in charges, on average.
# The p-value for age suggest that there is statistically significant evidence that there is a relationship between charges and age.
# However, the R(^2) statistic suggests this model only explains 8.9% of the variance in the data.
# Therefore, other models may be better at fitting the data.



## BMI against Charges ##

df |> 
  ggplot(aes(bmi,
             charges)) + 
  geom_point(size = 1) +
  geom_smooth(col = "red", method = lm, se = F) +
  labs(title = "Medical Insurance Costs for BMI")

# The regression line implies a positive linear association between BMI and charges, but the observations are very scattered with no obvious pattern.
# Given the average BMI is 30.7, it seems that there is a lot of variation in charges around this value.
# The spread of charges appears to increase at higher BMI values, suggesting possible non-constant variance.

# Summary of mod2
summary(lm(charges ~ bmi, data =df))

# The estimated regression coefficient for BMI is 393.86, suggesting that for every incremental increase of BMI, charges increase by $393.86
# The small p-value for the BMI covariate suggests that there is sufficient evidence of a relationship between BMI and Charges.
# The R(^2) statistic infers our model explains only 3.9% of the total variance.



## Combining the linear models: ##
summary(lm(charges ~ age + bmi, data = df))

# For every incremental increase in age, the medical insurance cost increases by $241.41, holding BMI constant.
# Holding age constant, a one unit increase in BMI is associated with an estimated increase $333.09 in charges.
# Very small p-values suggests statistical significance.
# Since we are looking at multi-regression models, we now look at the adjusted R(^2) statistic
# The adj R(^2) statistic of 0.1155 implies that this model now captures for 11.6% of the variance.


### Categorical Covariates ###

## Smokers ##

df |> 
  ggplot(aes(smoker,
             charges)) +
  geom_boxplot() +
  labs(title = "Medical Insurance Costs of Smokers vs Non-Smokers")

df |> 
  group_by(smoker) |> 
  summarise(median(charges))

# The box-plot highlights the large difference in the distribution of charges between smokers and non-smokers
# The medians are drastically different; the median charges for non-smokers and smokers are $7346 and $34456 respectively.
# Upper and Lower quartiles for non-smokers are much less than that of smokers, with a noticeably smaller interquartile range
# The dots on the whisker suggest that there are outliers in the non-smoker group; this will be investigated later.


# Summary of linear model for smoker covariate against charges
summary(lm(charges ~ smoker, data = df))

# The estimated regression coefficient suggests that smokers have charges approximately $23,609 higher than non-smokers, on average.
# The very small p-value provides strong statistical evidence that the mean charges differ between smokers and non-smokers.
# From the R(^2) statistic, this model alone explains 62.0% of response variation, indicating that smoking status is a particularly informative predictor in this dataset.


# BMI and Smoker Covariate interaction:

# It is reasonable to assume there may be an interaction between the BMI and smoker covariate when considering charges:

df |> 
  ggplot(aes(bmi,
             charges,
             colour = smoker)) +
  geom_point() +
  geom_smooth(method = lm,
              se = F) +
  labs(title = "Impact of Smoking on BMI-Charges Relationship")

# The regression lines have two noticeably different slopes, strongly suggesting that the relationship between BMI and charges may depend on smoking status.

# Checking summary for both linear models
summary(lm(charges ~ bmi + smoker, data = df))
summary(lm(charges ~ bmi * smoker, data = df))

# Both summaries:
# The small p-value for BMI infers there is significant relationship between BMI and charges for non-smokers.
# The very-small p-value for smokers suggest that there is a significant difference in the predicted charges between them and non-smokers

# Summary for interaction:
# The very-small p-value for bmi:smoker provides strong evidence that the relationship between BMI and charges change between smokers and non-smokers.
# The adjusted R(^2) statistic increases by 0.084 in the interaction model, which is an extra 8.4% of response variance explained by the model.
# Therefore, we can conclude that there is an interaction between these covariates.


# Age and Smoker Covariate interaction:
  
df |> 
  ggplot(aes(age,
             charges,
             colour = smoker)) +
  geom_point() +
  geom_smooth(method = lm,
              se = F) +
  labs(title = "Impact of Smoking on Age-Charges Relationship")

# Once again, including the smoker covariate in the linear model appears to improves the model fit for the regression line.
# However, unlike the previous exploration of interactions, there is not a significant difference in the slopes of the two regression lines, so we resort to the summary table:

summary(lm(charges ~ age + smoker, data = df))
summary(lm(charges ~ age * smoker, data = df))

# The small p-value for age suggests there is significant relationship between age and charges for non-smokers.
# The p-value for the interaction term is large, suggesting there is insufficient evidence that smoking has an effect on the relationship between age and charges.
# Therefore, there is insufficient evidence to conclude that there is an interaction between these covariates in this model.



## Sex ## 

df |> 
  ggplot(aes(sex,
             charges)) +
  geom_boxplot() +
  labs(title = "Charges for Each Sex")

# A clear result is that the interquartile range for male policyholders is larger than that of female policyholders.
# The lower quartile and median for both groups look relatively similar, but the male policyholder group has a larger upper quartile.
# Unfortunately, there is many outliers in both groups, which will need to be investigated

# Linear Model Summary for Sex against Charges:
summary(lm(charges ~ sex, data = df))

# The summary suggests that the male policyholder group has a mean cost of $1,405.50 more than female policyholders.
# The small p-value provides statistical evidence of a difference in mean charges between male and female policyholders.
# However, the R(^2) statistic tells us that this model only captures 0.3% of the response variance.



## Region ##

df |> 
  ggplot(aes(region,
             charges)) +
  geom_boxplot() +
  labs(title = "Charges for Each Region")

# All plots have a lot of outliers, which may be influential on the model fit.
# The median and lower quartiles of all regions look relatively similar.
# Individuals from the south-west region have a smallest upper quartile and IQR
# Policyholders from the south-east region have the largest upper quartile range and IQR

# Linear Model Summary for Regions
summary(lm(charges ~ region, data = df))

# Compared to the mean charge of policyholders from the north-east region, the north-west group and south-west region group have a lower mean cost, -$955.50 and -$1,059.40 respectively.
# Whereas, the south-east region has the highest mean charge of $1,329.00 more than the reference group.
# The p-values indicate that the evidence for differences from the north-east reference group varies by region.
# Additionally, the R(^2) statistic of 0.0065 suggests that region alone explains very little of the variation in charges.



## Policyholder's Children ## 

df |> 
  ggplot(aes(factor(children),
             charges)) +
  geom_boxplot() +
  labs(title = "Distribution of Charges for the Number of Policyholder Children")

df |> 
  group_by(children) |> 
  summarise(median(charges))


# Among the observed groups, policyholders with four children have the highest median of $11,034 and those with 1 have the lowest at $8,484; a difference of $2,550
# Those that have 4 or 5 children have a few outliers, whereas the other groups have a lot of outliers that may influence the model fit; this will need to be investigated.
# Policyholders with 5 children have the smallest IQR, whereas those with 2 have the largest.

summary(lm(charges ~ factor(children), data = df))


# Relative to policyholders with no children, the estimated mean charges are higher for those with 1–4 children and lower for those with 5 children.
# The highest of those being individuals with 3 children having a cost of $2,970 more compared to reference.
# The lowest of those being individuals with 5 children having a cost of $3,598 less compared to reference. 
# There are mixed p-values:
# For the groups with 1,4 and 5, the p-value is high, meaning there is insufficient evidence that these groups differ from the zero children reference group.
# For the groups with 2 and 3 children, the p-value is low, suggesting there is a difference between these groups and the reference group.
# From the R(^2) statistic of 0.012, we can infer that the model only captures 1.2% of the response variance.



  ############################
 # Investigating Full Model #
############################


# Is there evidence of an association between age and charges after accounting for BMI, children, sex, smoking status and region?

mod_full <- lm(charges ~ age + bmi + smoker + sex + region + factor(children), data = df)
summary(mod_full)

# Age: The low p-value suggests that there is a statistically significant association with charges after accounting for other covariates.
# BMI: The low p-value suggests that there is a statistically significant relationship with charges after accounting for other covariates.
# Smoker: The small p-value provides strong evidence of a difference in mean charges between smokers and non-smokers after accounting for the other predictors.
# Sex: The large p-value provides insufficient evidence of a difference in mean charges between male and female policyholders after accounting for the other predictors.
# Region (High p-val): the high p-value for the individuals from north-west region implies that there is insufficient evidence that there is a difference between this region and north-east region after controlling other covariates.
# Region (Low p-val): south-east and south-west groups have low p-values demonstrating that after accounting for other covariates, there is a sufficient evidence that there is a difference between their means and the reference group.
# Policyholder children (High p-val): the high p-value for policyholders with 1,3 or 5 children implies that there is insufficient evidence that there is a difference between these groups and the group with zero children after controlling other covariates.
# Policyholder children (Low p-val): policyholders with 2 or 4 children have low p-values providing significant evidence that, after accounting for other covariates, there is a difference between their means and the reference group.
# The adjusted R(^2) statistic of 0.7495 implies this model explains 75% of variation in charges.
# This model will be used as a baseline for diagnostics and model transformations.



  ###############
 # Diagnostics #
###############

# To see all diagnostic plots at one:
par(mfrow = c(2, 2))
plot(mod_full)

# Or

# To see all dianostic plots individually:
par(mfrow = c(1,1))
plot(mod_full)


## Residual vs Fitted Plot ##
# The presence of large residuals, the plot covers a large range. This gives the residuals a clustered appearance, making it harder to interpret.
# Below fitted values of 20,000, the majority of residuals are somewhat scattered around 0 with no clear sign of a pattern, which is good.
# Variance seems to increase as fitted values increase, suggesting heteroscedasticity.
# There are some residuals that stray from the main cloud, which could be outliers or have a large influence.

# Above charges of 20,000, residuals are clustered aroud -+ 10,000, implying the model is systematically over-predicting one group, and under-predicting another.
# There are very few residuals that appear around 0.
# The red line deviates from zero, suggesting this model is not great at capturing the relationship between residuals and fitted values.
# The variation of residuals is not constant, and there are observations that have large residuals that should be investigated further


## Q-Q Residual Plot ##
# An assumption for the residuals is that they are normally distributed. This is illustrated on the Q-Q plot with studentised residuals lying on the linear line.
# From -1 to 1 in theoretical quantiles, the residuals are along the line which is desired.
# However, the rest of residuals stray from this line, suggesting that the residuals may not be normally distributed using our linear model.

## Scale-Location Plot ##
# There is no obvious pattern within the spread of data points.
# The upward trend of the red line and data point spread resembling a funnel-shape suggesting that variance may not be constant, implying.


## Residuals Vs Leverage Plot ##
# The Cook's Distance contour is not clearly visible, reducing the usefulness of this model for identifying potentially influential observations.
# However, we do see observations with high studentised residuals and or high leverage, which could influence the model.


# Overall, we should alter the linear model to improve these results.


  #################################
 # Transforming the Linear Model #
#################################


## Log Transformation ##

mod_log <- lm(log(charges) ~ age + bmi + smoker + sex + region + factor(children), data = df)

summary(mod_full)
summary(mod_log)

# After applying a logarithmic transformation to charges, several previously large p-values became smaller.
# This provides stronger statistical evidence for associations between these predictors and the response, while holding the other covariates constant.
# The adjusted R(^2) statistic increased by 0.0183, which means the log model explains 1.8% more of the variation in charges compared to the untransformed model.

# To investigate which model is more suitable for further investigation, use the Akaike Information Criterion

AIC(mod_full, mod_log)

# The log-transformed model has a substantially lower AIC, providing evidence that it offers a better trade-off between model fit and model complexity than the untransformed model.
# The log-model will be used for further investigation.

plot(mod_full, which = 1)
plot(mod_log, which = 1)

## Residuals vs Fitted Values ## 
# More residuals are now a lot closer to zero
# There is non-linear pattern to the data, which needs to be addressed.
# Variance seems to systematically decrease, implying heteroscedasticity.

## Q-Q Plot ##
# There is more of a linear trend with the log model, but there are still a lot of points not on the line implying that our residuals are not normally distributed.

## Scale Vs Location ##
# The red line is a parametric shape now rather than an inclined linear line
# There is more of an obvious pattern to the data which means it will be easier to interpret from now on.

## Residual Vs Leverage ##
# The residuals now form a big cloud rather than having separated clouds.
# Residuals centre more around zero than in the last linear model, but apart from that, not much change.


## Addressing the non-linearity in the Residual vs Fitted plot ## 
# Creating two models, squaring the non-categorical covariates, Age and BMI.

mod_age2 <- lm(log(charges) ~ age + I(age^2) + bmi + smoker + sex + region + factor(children), data = df)
mod_bmi2 <- lm(log(charges) ~ age + bmi + I(bmi^2) + smoker + sex + region + factor(children), data = df)

# The model for age^2 is not nested within the model for BMI^2, and vice verca.
# Therefore, we cannot compare these models in the ANOVA test, but we can compare these models to the log-model.
anova(mod_log, mod_age2)
anova(mod_log, mod_bmi2)

# Both ANOVA tables return small p-values for each of the new models, providing strong evidence that adding these terms improves model fit.
# Looking at the diagnostic plots:

plot(mod_log, which = 1)
plot(mod_age2, which = 1)
plot(mod_bmi2, which = 1)

# The data for the quadratic model for age is scattered more than the log-model, resulting in less of a pattern. This is an improvement
# The data forthe  quadratic model for BMI is scattered a little more than the log-model, but no significant changes.

# Even with improvements in the model's fit, the model can still be refined.


# Combining quadratic models into one:

mod_quad <- lm(log(charges) ~ age + I(age^2) + bmi + I(bmi^2) + smoker + sex + region + factor(children), data = df)
summary(mod_quad)

anova(mod_age2, mod_quad)
anova(mod_bmi2, mod_quad)

# Both ANOVA tables highlight small p-values, infering that the new quadratic model is a better fit for the data.

# Checking Residual Vs Fitted plots:
plot(mod_age2, which = 1)
plot(mod_bmi2, which = 1)
plot(mod_quad, which = 1)

# Once again, it seems the only identifiable difference is that the data is a little less dense, showing less of a pattern, which is an improvement, but not a substantial one.


# Previously, we saw that there was a significant interaction between BMI and smoking covariates.
# We can now include them in the model to see if they improve model fit.
# We could also again investigate the interaction between age and smoking, this time accounting for the additional variables.

mod_smoker_bmi <- lm(log(charges) ~ age + I(age^2) + bmi*smoker + I(bmi^2) + sex + region + factor(children), data = df)
mod_smoker_age <- lm(log(charges) ~ age*smoker + I(age^2) + bmi + I(bmi^2) + sex + region + factor(children), data = df)

anova(mod_quad, mod_smoker_bmi)
anova(mod_quad, mod_smoker_age)

# For both of these models, the p-value is very small, providing strong evidence that adding the interaction significantly improved the model fit.

# Checking the Residual Vs Fitted Plots:

plot(mod_quad, which = 1)
plot(mod_smoker_age, which = 1)
plot(mod_smoker_bmi, which = 1)

# The age*smoker model looks significantly better than the model just including the quadratics
# There is a lot less evidence of a non-linear pattern and data points are closer to zero.

# The bmi*smoker model looks worse; the data points are less scattered and follow a stronger non-linear pattern.


# Try combining these models:

mod_smoker_age_bmi <- lm(log(charges) ~ age*smoker + I(age^2) + bmi*smoker + I(bmi^2) + sex + region + factor(children), data = df)

anova(mod_smoker_bmi, mod_smoker_age_bmi)
anova(mod_smoker_age, mod_smoker_age_bmi)
# the p-value for both of the new models are signficantly small. This suggests that the new models fit the data better than the quadratic model.

plot(mod_smoker_age, which = 1)
plot(mod_smoker_bmi, which = 1)
plot(mod_smoker_age_bmi, which = 1)

# The Residuals Vs Fitted plot shows a significant improvement compared with the model containing only the BMI and smoker interaction.
# The residuals are centred around zero and follow less of a systematic pattern.
# Compared to the model containing the interaction between smokers and age, the end tail looks more evenly distributed.
# However, there is still some evidence of a pattern in the residuals, indicating the model does not completely capture the relationship between the predictors and insurance costs.

# The Q-Q plot shows that the residuals generally follow the linear pattern.
# Toward the tails, there are deviations from this line, but the plot is marginally improved compared to previous models.

# Scale-Location plot for the new model shows a slight improvement compared to the previous models.
# The red line is somewhat more horizontal and the spread of the residuals appears more consistent across the fitted values
# However, some systematic variation remains, suggesting there is still heteroscedasticity present.

# The Residual Vs Leverage plot for the new model improves slightly from that of the previous models.
# However, observations with relatively high studentised residual values and leverage should still be considered when assessing the model.

# Overall, the model including both interactions seems to be an overall better fit for the data.

# Additionally, we can use the Akaike Information Criterion to compare the models:

AIC(mod_smoker_age, mod_smoker_bmi, mod_smoker_age_bmi)

# The model including both interaction terms has a lower AIC, indicating the best trade-off between model fit and model complexity among the models considered.

# Summary:
summary(mod_smoker_age_bmi)



  #########################
 # Checking Collinearity #
#########################

# If collinearity is present in the model, standard errors may be inflated and regression coefficients may be unstable to change.
# Presumably, there will be collinearity in our model, but we can more confidently assume this due to the model including quadratic terms.
# Using the Variance Inflation Factor (VIF)

vif(mod_smoker_age_bmi)

# Except from the sex, region and children covariates, the other terms in the model had VIF values above 5, indicating potential considerable collinearity.
# These results follow from previous assumptions.

# Centering the non-categorical covariates in an attempt to reduce collinearity:

df$age_c <- df$age - mean(df$age)
df$bmi_c <- df$bmi - mean(df$bmi)

# Replacing Age and BMI covariates with their centred versions:
mod_centred <- lm(log(charges) ~ age_c * smoker + I(age_c^2) + bmi_c*smoker + I(bmi_c^2) + sex + region + factor(children), data = df)

# Now check for collinearity in the new model:
vif(mod_centred)

# Now, all VIF values are very close to one, suggesting there is small correlation between the terms in this linear model.

# Checking for changes between model summaries:
summary(mod_centred)
summary(mod_smoker_age_bmi)

# Apart from the differences of age and BMI with their centred covariates, there is very little to no change in the summary.

# Using AIC to check if one model is a better predictor:
AIC(mod_smoker_age_bmi, mod_centred)
# AIC results were the exact same.

# Checking our Diagnostic Plots have not changed:
plot(mod_smoker_age_bmi, which = 1)
plot(mod_centred, which = 1)

# All diagnostic plots have not changed, or has no noticeable significant change.

# Therefore, since centering reduces multicollinearity while leaving everything else unchanged, this model is preferred.


  ####################
 # Outlier Analysis #
####################

plot(mod_centred, which = 4)

# The highest Cook's distance in this model is around 0.033.
# While this Cook Distance value does not look obviously concerning, we can test it against the screening rule for Cook's distance: 4/n where n is the number of observations in the dataset.
# A value above 4/n should be investigated further.
# For this model there are 1337 observations; 4/1337 ≈ 0.003

# Adding a horizontal line at Cook's distance of 0.003
abline(h = 0.003, lwd = 2, col = "Red")

# A number of observations exceed this screening threshold and will be investigated further.


# Identifying rows with high values for Cook's Distance:

cd <- cooks.distance(mod_centred)
high_cd <- which(cd > 4/1337)
length(high_cd)
# R has identified 65 data points that surpass the Cook's Distance screening; This is 4.9% of the overally data.

# Identifying rows and their residual statistics:
St_res <- rstudent(mod_centred) # Calculates studentised residuals
Hmat <- hatvalues(mod_centred) # Forms the hat matrix
cd_tab <- data.frame(row = 1:nrow(df),
                      St_res,
                      leverage = Hmat,
                      cooks = cd)

# Finding the data for potentially influential individuals:
high_cd_tab <- cd_tab[order(cd_tab$cooks, decreasing = TRUE),][1:68,]
row_num <- high_cd_tab[, "row"]
row_info <- df[row_num, ]

view(row_info[1:20,])
mean(row_info$age_c[1:20])
mean(row_info$bmi_c[1:20])

## Analysis ##

# Focusing on the top 20 influential observations (CD: 0.03 - 0.01):

# Smoking status was one of the strongest predictors of insurance charges throughout the modelling process.
# However, every individual in this group do not smoke, but still present with high charges.
# This is unusual given the pattern observed in the data.
# This may result in large residuals, influencing the fitted model.

# Most of the individuals are young, 18-30, with a mean age approximately 17.6 years lower than that of the full dataset.
# This is notable because age had a positive relationship with charges in the fitted model, meaning these observations would generally be expected to have lower charges based just on age.

# Therefore, the top 20 influential observations are young, non-smoking policyholders.

view(row_info)

row_info |> 
  ggplot(aes(charges))+
  geom_histogram(col = "Black", fill = "Blue", bins = 30) +
  labs(title = "Distribution of Charges of Potentially Influential Observations")

View(row_info |>
  select(age_c, bmi_c, charges) |>
  summarise(across(everything(),
                   list(Lower = min,
                        Upper = max,
                        Mean = mean))) |> 
  pivot_longer(everything()))

row_info |> 
  group_by(smoker) |> 
  summarise(number = n())

row_info |> 
  group_by(region) |> 
  summarise(number = n())

row_info |> 
  filter(charges == min(charges))

row_info |> 
  filter(charges == max(charges))

view(df)
# Looking at the 68 observations (CD: 0.03 - 0.003):
# The distribution of charges appears approximately symmetric, with the observations concentrated around $20,000.
# Compared to the mean of all observations, $13,279, the mean of these observations is $22145, which is significantly larger.
# The higher mean of the influential observations suggests that these observations may have a considerable effect on the fitted regression.

# Minimum Charge Value:
# An 18 year old female, 21.2 years less than the average, with a BMI of 29.2, 1.50 units lower than the average BMI.
# The observed charge of $7,324, when compared to the charges of other 18 year old policyholders in the dataset, this appears to fall between observed charges for smokers and non-smokers.
# Given that she is a non-smoker, this contributes to the observation having a high Cook's distance.

# Maximum Charge Value:
# A 45 year old male smokes, 5.78 years above average, with a BMI of 30.4, very close to average.
# Although the individual's age and smoking status would be expected to be associated with high charges, their charge is substantially higher than expected.
# Their BMI is close to the overall mean, meaning that BMI does not provide an obvious explanation for the high charge


  ######################################################
 # Model Without Potentially Influential Observations #
######################################################


df_remov <- df[-row_num, ]
View(df_remov)

# The latest model: mod_centred

mod_centred_removed <- lm(log(charges) ~ age_c * smoker + I(age_c^2) + bmi_c*smoker + I(bmi_c^2) + sex + region + factor(children), data = df_remov)

summary(mod_centred)
summary(mod_centred_removed)

# The reduced model recorded an increase of the adjusted R(^2) statistic of 0.1316 from the other model.
# That is the adjusted R(^2) is 0.9592, indicating it explains a considerably greater proportion of variation in log(charges).
# The residual standard error halved.
# The F statistic increased by 4.5x.
# The range of residuals decreased.
# The p-value for the north-west region decreased.
# Although these changes indicate an improved fit to the remaining observations, this does not necessarily mean that the model is better.
# The improvement may be caused by removing observations that were difficult for the original model to predict.


  ###############
 # Limitations #
###############

# From the previous section, the model improved as observations that exceeded the Cook's screening rule were removed.
# However, we require a reason to remove this observations from our data.
# These observations may not represent errors, but legitimate with reasons behind them
# Without additional information, it is not possible to determine whether removing them is justified.

# Although the dataset contains a substantial number of observations, additional data could provide more information about the unusual observations identified.
# This could potentially improve the reliability of the model.


  ##############
 # Conclusion #
##############

# A linear regression model was developed to investigate the factors associated with medical insurance costs. 
# Exploratory analysis and model diagnostics indicated the use of log transformations, quadratic terms for age and BMI, and the interaction between BMI and smokers and later age and smokers.
# The final model explained a large amount of response variation, even with these high Cook Distance observations included.
# Removing these observations led to a large improvement in model fit, however, there was insufficient information to determine whether these observations were errors or if they were legitimate claims.
# Further information about policyholders and additional observations could improve the model and give more insight into these observations.
