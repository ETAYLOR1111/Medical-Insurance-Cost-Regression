# Medical-Insurance-Cost-Regression

## Overview

R-based investigation of factors associated with medical insurance costs using linear regression analysis. This project begins with data cleaning and exploratory data analysis before investigating simple models and developing a multiple linear regression model. Transformations, quadratic terms and interactions are considered during model development with diagnostic plots and statistical test are used to assess the suitability of the different models. Finally, potentially influential observations identified using Cook's distance are investigated and evaluated.

## Dataset
- Source: Miri Choi via Kaggle
- Link: https://www.kaggle.com/datasets/mirichoi0218/insurance/data
- Licence: Database Contents License (DbCL) v1.0
- Rows: 1338

## Objectives
- Address issues within the data
- Perform exploratory data analysis
- Investigate relationships between predictors and medical insurance costs
- Develop and compare regression models
- Assess model assumptions using diagnostic methods
- Identify and investigate potentially influential observations using Cook's distance
- Evaluate limitations of final model.

## Tools Used
- R
- RStudio
- Tidyverse
- Cars
- Kaggle

## Process
### Data Cleaning
- Check the datatypes of the variables
- Identify and remove duplicates
- Search for missing values

### Exploratory Data Analysis
Summary statistics and visualisations were used to understand the distributions of the variables and relationships between predictors
#### Distribution of Variables
  - The distribution of Charges is strongly right-skewed, suggesting a logarithmic transformation is worth investigating.
 ![Transactional Value by Item](Exploratory%20Plots/Distribution%20of%20Charges.png)
  - Age is approximately symmetric with most observations falling within a narrow range, however, there are increases in frequency around some values.
  - BMI is approximately symmetric.
#### Relationships Between Predictors
  - There appears to be little association between Age and BMI in this dataset
  - The very large p-value (0.891) provides insufficient evidence that smoker status is associated with BMI.

### Model Development
Simple models were initially used to investigate relationships between covariates and medical insurance costs:
- Age: The very small p-value (<2x10<sup>-16</sup>) provides strong evidence of an association between age and charges. The simple model explains 8.9% of variation in charges. ![Transactional Value by Item](Exploratory%20Plots/Age%20against%20Charges%20Plot.png)
- BMI: The very small p-value provides statistically significant evidence of a relationship between BMI and charges, with the model explaining 3.9% of variation in charges.
- Smokers: The very small p-value provides strong evidence that the mean charges differ between smokers and non-smokers. The R<sup>2</sup> statistic of 0.62 indicates that the smoking variable explains a substantial proportion of variation in charges in the simple model.
- Sex: The small p-value (0.034) provides statistically significant evidence that there is a difference in the mean charges between male and female policyholders. However, the R<sup>2</sup> statistic is (0.0034) which implies the model captures 0.34% of overall variation of charges.
- Region: Although the mean charges vary between regions, none of the p-values provide statistically significant evidence that the regional mean charges differ from the north-east reference group.
- Number of Policyholder Children: The p-value for the groups with 1, 4 and 5 children is high, meaning there is insufficient evidence that these groups differ from the zero children reference group. For the groups with 2 and 3 children, the low p-value provides statistically significant evidence of a difference between these groups and the reference group. The R<sup>2</sup> statistic of 0.012 indicates that the model only captures 1.2% of the response variance.

#### Investigating the interaction of smoker status on the relationship between BMI and Charges:
It would be reasonable to assume that the smoker covariate will have an effect on the relationship between BMI and Charges
  - The regression lines have two noticeably different slopes, suggesting that the relationship between BMI and charges may depend on smoking status. This indicates we should look for an interaction between BMI and smoking status.
  - The very small p-value for BMI:smoker (<2x10<sup>-16</sup>) provides strong evidence of a difference in the relationship between BMI and charges for the different groups: smokers and non-smokers.
  - Compared with the linear model that only includes the addition of covariates, there is an increase in the adjusted R<sup>2</sup> statistic of 0.084 when including the interaction, explaining 74.1% of variation in charges.
 ![Transactional Value by Item](Exploratory%20Plots/Impact%20of%20Smoking%20on%20BMI-Charges%20Relationship.png)

#### Investigating whether the smoker status affects the relationship between Age and Charges:
  - The two regression lines appear approximately parallel, suggesting that effect of age on charges may be similar for smokers and non-smokers.
  - The large p-value (0.22) for the age:smoker interaction provides insufficient evidence of a difference in the relationship between age and charges when considering the smoking status.
 ![Transactional Value by Item](Exploratory%20Plots/Impact%20of%20Smoking%20on%20Age-Charges%20Relationship.png)

#### Investigating the full model:

- Age and BMI provide statistically significant evidence of associations with charges after accounting for other predictors.
- Smoker status provides strong evidence of a difference in mean charges between smokers and non-smokers after accounting for the other predictors.
- Sex provides insufficient evidence of a difference in mean charges between male and female policyholders after accounting for the other predictors.
- There is insufficient evidence of a difference between the north-west and north-east region after controlling other covariates.
- There is statistically significant evidence of a difference in mean charges between the south-east and south-west groups and the north-east reference group after accounting for other predictors.
- The groups of policyholders with 1,3 or 5 children has insufficient evidence of a difference between these groups and the group with zero children after controlling other covariates.
- The groups of policyholders with 2 or 4 children provide statistically significant evidence of a difference between their means and the reference group after accounting for other predictors.
- The adjusted R<sup>2</sup> statistic of 0.7495 implies this model explains 75% of variation in charges.

This model was used as a baseline for model developments.

#### Logarithmic Transformation of Charges:
The response variable was transformed using log(charges) to investigate the model's fit and diagnostic plots.
- Several previously large p-values became smaller, providing stronger statistical evidence for associations between these predictors and the response, while holding the other covariates constant.
- The adjusted R<sup>2</sup> statistic increased by 0.0183, which means the log model explains 1.8% more of the variation in charges.
- The diagnostic plots showed improvements after the transformation.
The log-model will be used for further model development.

#### Adding Quadratic Terms
Diagnostic analysis suggested that non-linearity was present in the residuals vs fitted values plot. Therefore, quadratic terms were added into the model to be investigated.
- Age and BMI covariates were squared and added into separate models and then both were added into the another model.
- Conduct ANOVA tests between log-model and quadratic models:
  - The ANOVA comparisons returned small p-values, providing statistically significant evidence that the model containing both quadratic terms provides an improvement in fit

#### Adding Interactions
The interaction between smoking status and BMI was investigated because of earlier analysis.  The interaction between age and smoking was reconsidered, this time accounting for the additional variables.
- Interactions for age and BMI with smoking were added to separate models and then both were added into one model.
- ANOVA tests were conducted between each model and the previous quadratic model.
  - The ANOVA test returned very small p-values that provides strong evidence that the model containing both interaction terms improved model fit.


### Model Diagnostics
Diagnostics were used throughout model development to assess assumptions of the linear model.

#### Residuals vs Fitted Values
The residuals vs fitted plot was used to assess whether the residuals were centred around zero and whether systematic patterns were present.
The initial model was difficult to interpret and presented with patterns of non-linearity and heteroscedasticity. Following the logarithmic transformation and inclusion of quadratic terms and interaction, there were improvements with more residuals appearing to be centred around zero and the systematic pattern being reduced. However, some structure remained, indicating the model does not completely capture the relationship between the predictors and insurance costs.
 ![Transactional Value by Item](Diagnostic%20Plots/Residuals%20Vs%20Fitted.png)


#### Q-Q Plot
The Q-Q plot was used to assess whether the residuals approximately followed a normal distribution. 
The final model showed an improvement compared with the initial model, although deviations from line were still present, mostly in the tails. Therefore, the normality assumption for residuals is not perfectly satisfied.
 ![Transactional Value by Item](Diagnostic%20Plots/Q-Q%20Plot.png)


#### Scale-Location Plot
The Scale-Location plot was used to assess whether variance of residuals was constant.
The plot for the final model showed improvement compared to the previous models. The red line was somewhat more horizontal and the spread of the residuals appeared more consistent across the fitted values. However, some systematic variation remains, suggesting heteroscedasticity is still present.
 ![Transactional Value by Item](Diagnostic%20Plots/Scale-Location%20Plot.png)


#### Residuals vs Leverage
The Residuals vs Leverage plot was used to identify observations that combined relatively large residuals with high leverage.
The final model showed improvement compared to earlier models. However, observations with relatively high studentised residuals and leverage were investigated further using Cook's distance.

 ![Transactional Value by Item](Diagnostic%20Plots/Residuals%20vs%20Leverage.png)


### Collinearity
Collinearity may increase standard errors and make regression coefficients estimates less stable to change.
- The inclusion of quadratic terms and interactions in the model may have resulted in collinearity.
- Use the Variance Inflation Factor function (VIF):
  - Terms in the linear model presented with a VIF above 5, indicating considerable collinearity.
- Age and BMI covariates were centred before being used in the final model.
- Use the VIF function on the centred model:
  - All VIF values are now close to 1, which suggests little evidence of collinearity.
- Run the summary function, AIC and check the diagnostic plots:
  - No values or plots had any meaningful change.
The centred model was used for further investigation.

### Final Model
The most suitable model for our data is:

$$ \log(\text{charges}_i) = \beta_0 + \beta_1\text{Age}_{c,i}
+\beta_2\text{Age}_{c,i}^2
+\beta_3\text{BMI}_{c,i}
+\beta_4\text{BMI}_{c,i}^2
+\beta_5\text{Smoker}_i
+\beta_6(\text{Age}_{c,i}\times\text{Smoker}_i)
+\beta_7(\text{BMI}_{c,i}\times\text{Smoker}_i)
+\beta_8\text{Sex}_i
+\beta_9\text{Region}_i
+\beta_10\text{Children}_i
+\epsilon_i $$

### Outlier Analysis
Cook's distance was used to identify observations that could have a large influence on the linear model.

- Consider the common screening threshold for Cook's Distance: any observation with a Cook's Distance > 4/n.
  - For this dataset, the threshold is 4/1337 ≈ 0.003.
 
 ![Transactional Value by Item](Diagnostic%20Plots/Cook's%20Distance%20Plot.png)

- Using the screening rule, 68 influential observations were identified.

#### Analysis of top 20 observations

- The smoking covariate was one of the strongest predictors of insurance charges throughout the modelling process. However, all 20 observations were non-smokers, but presented with high charges. This is unusual given the pattern observed in the data. This may be a result of large residuals, influencing the fitted model.
- Most of the individuals are young, 18-30. Their mean age was approximately 17.6 years lower than the mean age of the full dataset. This is relevant because age had a positive relationship with charges in the fitted model, meaning these observations would generally be expected to have lower charges based just on age.
- Therefore, these combined factors contribute to observations having large residuals and high Cook's distance values.


#### Analysis of all 68 observations:
- The distribution of charges appears approximately symmetric, with the observations concentrated around $20,000.
- Compared to the mean of all observations, $13,279, the mean of these observations is $22,145.
- The substantially larger mean suggests that these observations may have a considerable effect on the fitted regression.

- 64 out of the 68 individuals were non-smokers despite having higher costs.
- This will create potential in the dataset because their charges are unusually high relative to what the model expects.
- Therefore, these data points may have larger residuals, contributing towards higher Cook's Distance.
- However, the dataset does not provide enough information to determine why these individuals had high charges.

#### Model using dataset with high Cook's distance observations removed:
A second model was fitted, removing the potentially influential observations:
- The reduced model recorded an increase of the adjusted R<sup>2</sup> statistic of 0.1316 from the other model. That is, the adjusted R<sup>2</sup> is 0.9592, indicating it explains a considerably greater proportion of variation in log(charges).
- The residual standard error halved.
- The F statistic increased by substantially.
- The range of residuals decreased.
- The p-value for the north-west region decreased.

- Although these changes indicate an improved fit for the remaining observations, this does not necessarily mean that the model is better.
- The improvement may be caused by removing observations that were difficult for the original model to predict.

We require a reason to remove these observations from our data. This is because the observations may not be errors, but legitimate with reasons behind them. Without additional information, it is not possible to determine whether removing them is justified. Furthermore, including this information may potentially improve the reliability of the model.

## Key Findings
- The distribution of charges in this dataset are heavily right-skewed, motivating a logarithmic transformation of charges.
- There is little association between Age and BMI
- There is insufficient evidence to suggest that smoking status is a useful indicator for BMI
- There is statistically significant evidence of smoking having an effect on the relationship between BMI and charges
- There is initially not enough evidence to suggest that smoker effects the association between Age and charges. However, the interaction was reconsidered after accounting for other covariates.
- Non-linearity and heteroscedasticity was present within the residuals vs fitted plot.
- Many residuals deviated from the linear relationship in the Q-Q plot, suggesting residuals may not be approximately normally distributed.
- Heteroscedasticity was present in the Scale-Location plot.
- Logarithmic transforming the charges covariate, adding in quadratic terms and interactions improved residual behaviour and model fit.
- Collinearity was introduced by quadratic terms and was reduced by centering Age and BMI.
- 68 observations exceeded the Cook's distance threshold.
- Most potentially influential observations to model fit were young policyholders that didn't smoke, but incurred high charges.
- Removing observations that are potentially influential substantially improved model fit, but without more information, it cannot be determine whether these observations were errors or legitimate inputs.

## Learning Outcomes
- Used R and RStudio to perfom statistical analysis on a real-world dataset.
- Applied data-cleaning techniques.
- Performed exploratory data analysis using summary statistics and visualisations.
- Developed and interpreted simple and multiple linear regression models.
- Investigated transformations, adding quadratic terms and interaction effects.
- Using R to develop a linear model to predict medical insurance costs.
- Applied model diagnostic techniques to assess regression assumptions.
- Used VIF to investigate and address collinearity.
- Used Cook's distance to identify and investigate potentially influential observations
- Developed stronger analytical and statistical reasoning skills.
