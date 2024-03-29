Banks employ extensive risk management procedures that include far more
than machine learning prediction. Nevertheless, predicting loan defaults
before they occur, with a high accuracy, would at the very least be
beneficial to lenders. This Master’s project for the module “Data
Science” seeks to ascertain how well defaults on loans can be predicted.
The answer is that, with the techniques used, the best accuracy score
seems to be about 89%.

The purpose of this README is to provide a basic machine learning
procedure, from receiving the data to prediction. This includes a Random
Forest model (89% accuracy), K-Nearest-Neighbors (KNN) and a LASSO
regression. These are compared to a standard statistical/econometric
logit model (with a low accuracy). The models are all tasked with
predicting whether a person will default on a loan, or not, the month
before the loan is due.

# Required R Packages

## Plotting and General Code:

-   tidyverse
-   ggplot2
-   gridExtra
-   ggridges
-   viridis
-   hrbrthemes
-   formattable
-   GGally
-   jtools
-   kableExtra
-   knitr
-   pROC

## Model Building:

-   caret (splitting data)

-   glmnet (Lasso)

-   randomForest

-   class (KNN)

# Data Creation

``` r
Data <- 
  
  read.csv("Data/Credit Default Dataset.csv") %>% 
  
  na.omit() %>% 
  
  subset(Amount != 0) %>% 
  
  # Feature creation:
  
  mutate(Owed = rowSums(.[,c(12,13,14,15,16,17)])) %>%  # total owed
  
  mutate(TotalPaid = rowSums(.[,c(18,19,20,21,22,23)])) %>% # total paid
  
  mutate(Difference = (Owed - TotalPaid)/Amount) %>%
  
  mutate(Interest = (Owed/Amount)^2) %>% # squared to accentuate 
  
  mutate(Pressure = (Owed/6)/(Amount/6)) %>%  
  
  mutate(Variance = (rowSums(.[,18:23])/6) - (rowSums(.[,18:23])/6)^2) %>%
  
  filter(Owed != 0) %>% 

         # Many of these are better explained in the "Final Project" html            Google link.

# Feature Formatting:
  
  mutate(Gender = gsub("2", "0", Gender)) %>% # 0 == female
  
  mutate(Education = gsub("4|5|6", "-1", Education),
         Education = gsub("2|1", "5", Education),
         Education = gsub("3", "2", Education)) %>% 
  
  mutate(Marriage.Status = gsub("2|3", "0", Marriage.Status)) %>% 
  
  mutate(Age = ifelse(Age < 30, 1,
                   ifelse(Age >= 30 & Age < 40, 2,
                          ifelse(Age >= 40 & Age < 50, 3,
                                 ifelse(Age >= 50, 4, 0))))) %>% 
  
  # Quality variable 
  
  mutate(Quality = (
    
    (.[, 6] + .[, 7] + .[, 8] + .[, 9] + .[, 10] + .[, 11])) / 6) %>% 
  
  mutate(Quality = 
           
           ifelse(Quality < -1, 5,
                  
                  ifelse(Quality < 0 & Quality >= -1, 1,
                         
                         ifelse(Quality > 0 & Quality < 2, -2,
                                
                                ifelse(Quality >= 2, -10,0)))))

# The Quality variable is essentially the average of how timely your payments were, were they on average half a month before, or two months late?
```

# Descriptive Analysis

## Sourcing Functions, Plots, and Tables.

``` r
source("Code/TransitorySets.R") # data sets for plotting 

source("Code/Themes.R") # themes for different ggplots 

source("Code/Functions.R") # plotting functions I made. 

source("Code/PlotCreation.R") # creation of plots and tables. 
```

## Plotting

Ridge plots show you how the distribution of a variable changes over
time, or by any other category. This often tells enough of a story on
its own.

``` r
# Ridge plots, beautiful! Credit RGraphGallery. 

grid.arrange(Ridge(DataPaid, "Amount Paid Over Time"), 
             Ridge(DataBills, "Amount Billed Over Time"),
                   nrow = 2)
```

    ## Picking joint bandwidth of 289

    ## Picking joint bandwidth of 608

<img src="README_files/figure-markdown_github/Ridges-1.png" width="80%" height="80%" style="display: block; margin: auto;" />

The reason for reviewing demographics is that I wanted to ascertain
whether there was enough variation between categories to include them as
useful indicators to the model.

``` r
# I seriously recommend gridExtra. 

grid.arrange(G1, G2, G3, ncol = 3)
```

<img src="README_files/figure-markdown_github/Demographics-1.png" width="80%" height="80%" style="display: block; margin: auto;" />

``` r
grid.arrange(B1, B2, B3, B4, nrow = 2)
```

<img src="README_files/figure-markdown_github/Box Plots-1.png" width="80%" height="80%" style="display: block; margin: auto;" />

These are basic correlation plots. Uusally, you want to exclude highly
correlated variables and choose only one. In this case, I am performing
a LASSO regression first, regardless, so I did not do that. It is
recommened that you do.

``` r
grid.arrange(
  
  (PreScatter(Bill1, Bill6, "Preceding Bill", "First Bill") +
     
     scale_x_continuous(labels = function(x) ifelse(x == 100000, "", x))),
             
  PreScatter(Paid1, Paid6, "Preceding Payment", "First Payment"),
             nrow = 2)
```

    ## `geom_smooth()` using formula = 'y ~ x'
    ## `geom_smooth()` using formula = 'y ~ x'

<img src="README_files/figure-markdown_github/Variables for Exclusion-1.png" width="80%" height="80%" style="display: block; margin: auto;" />

# Technical Data Wrangling and Editing

## Outliers

``` r
Data <- as.data.frame(lapply(Data, as.numeric)) # Now Numeric

# Outliers 

outliers <-
  
  which(
  
      abs(
    
          scale(
        
            Data[, c(1, 5, 25, 26, 27, 28)])) > 2.5)

Data <- Data[-outliers, ] # Removing Outliers. 

rm(outliers)

# Random Forests should be less responsive to outliers anyway but I was only getting about 64% accuracy for the (1,1) part of the confusion matrix. After this change I got about 67%.
```

## Oversampling

``` r
# This is done manually here but there are also packages for this now, I did not know that at the time. Also, do not do simple oversampling, do the SMOTE technique. 

Q <- sum(Data$Default == 0) - sum(Data$Default == 1)

Data <- Data %>%  
  
  filter(Default == 1) %>%  
  
  sample_n(Q, replace = TRUE) %>%  
  
  bind_rows(Data)

# Shuffle the data to ensure randomness

Data <- Data %>%  
  
  sample_frac() %>% 
  
  mutate(row_id = row_number()) %>%  
  
  arrange(row_id) %>%  
  
  select(-row_id)

rm(Q)

# This seems dubious but ML techniques can also be biased in imbalanced datasets. In order to use accuracy measures etc I thought it best to have a balanced data set. 

# Standardising and partitioning data

Standardised <- c(1,6:23,25:27)

Process <- function(a, b) {
  
  b[, a] <- scale(b[, a])
  NewData <<- b
  
} 

Process(Standardised, Data) # Standardized Data

rm(Standardised)

NewData <- NewData[, -c(32:35)]

# Partition 

set.seed(123)

Training <- createDataPartition(NewData$Default, 
                                p = 0.76, 
                                list = FALSE)
Train <- NewData[Training, ]
Test <- NewData[-Training, ]
```

## Correlation Plot

``` r
ggcorr(
  NewData[, -c(2:5, 7:11, 12:17, 19:23, 30, 25)],
  method = c("everything", "pearson"),
  low = "maroon4",
  mid = "white",
  high = "blue4",
  midpoint = 0,
  geom = "tile",
  min_size = 1,
  max_size = 8,
  label_color = "white",
  label_round = 1,
  label_size = 4,
  limits = c(-1, 1),
  drop = is.null(limits) || identical(limits, FALSE),
  layout.exp = 0,
  legend.position = "left",
  legend.size = 10)
```

<img src="README_files/figure-markdown_github/unnamed-chunk-8-1.png" width="80%" height="80%" style="display: block; margin: auto;" />

# Models

## Logit Model

``` r
# Create Model 

Logit <- glm(
  
  Default ~ Amount + 
            Payment +
            Variance +
            Quality +
            Repayment1 +
            Repayment2 + 
            Paid1 + 
            Bill1 +
            Gender +
            Education +
            Marriage + 
            Age,
  
  data = Train,
  
  family = binomial(link = "logit"))

###

# get model predictions 

PredLogit <- predict(Logit, newdata = Test)
PredLogit <- ifelse(PredLogit >= 0.5, 1, 0)

ConfLogit <- table(PredLogit, Test$Default)
PropLogit <- prop.table(ConfLogit, margin = 2)

# Put logit in a nice table to talk about 

Table <- summ(Logit)

kable_table <- kable(
  Table$coeftable, 
  format = "html", 
  digits = 5, 
  align = "c") |> 
  kable_classic_2(full_width = TRUE)
```

``` r
# I used to like including images instead, because they render the same no matter what. Kable can be volatile with different knitting formats. 

knitr::include_graphics("Images/KableTable.png",
                        dpi = 300)
```

<img src="Images/KableTable.png" width="80%" height="80%" style="display: block; margin: auto;" />

## LASSO

``` r
# I am sorry that this includes so much base R coding, it is not the prettiest coding language in the world. 

X <- as.matrix(Train[, -24]) # Remove Target variable
Y <- Train$Default

# cross-validation

CV <- cv.glmnet(X, Y, family = "binomial", alpha = 1)
TrueL <- CV$lambda.1se

ElasticFinal <- glmnet(X, Y, family = "binomial", alpha = 1, lambda = TrueL)

# Final Features

# I want only the features that survive the LASSO to be in the Random Forest model. 

Features <- rownames(coef(
  ElasticFinal))[coef(
    ElasticFinal)[, 1] !=0]
Features <-  Features[Features != "(Intercept)"]
Features <- c("Default", Features)

PredNet <- predict(
  
  ElasticFinal, 
  
  newx = as.matrix(
    
    Test[, -which(names(Test) == "Default")]), type = "response")

PredNet <- ifelse(PredNet >= 0.5, 1, 0)

ConfNet <- table(PredNet, Test$Default)

NetProp <- prop.table(ConfNet, margin = 2)
```

``` r
# View of the elastic net in action 

knitr::include_graphics("Images/Selection.png",
                        dpi = 300)
```

<img src="Images/Selection.png" width="80%" height="80%" style="display: block; margin: auto;" />

``` r
knitr::include_graphics("Images/Lambda.png",
                        dpi = 300)
```

<img src="Images/Lambda.png" width="80%" height="80%" style="display: block; margin: auto;" />

## Random Forest

``` r
Train <- Train[, Features] # features from LASSO 
Test <- Test[, Features]

###

# Model 

MLModel <- randomForest(
  Default ~ ., 
  data = Train, 
  ntree = 300,
  mtry = sqrt(ncol(Train)),
  nodesize = 20, 
  maxdepth = NULL)
```

    ## Warning in randomForest.default(m, y, ...): The response has five or fewer
    ## unique values.  Are you sure you want to do regression?

``` r
###

# Predictions 

PredTree <- predict(MLModel, newdata = Test)
PredForPlot <- predict(MLModel, newdata = Test)
PredTree <- ifelse(PredTree >= 0.5, 1, 0)

ConfTree <- table(PredTree, Test$Default)
PropTree <- prop.table(ConfTree, margin = 2)
```

``` r
# Variable importance plot.

# VarImportance is just the extracted bar graphs from the random forest model. 

ggplot(VarImportance, 
       
       aes(x =IncNodePurity, 
           y =  reorder(rownames(VarImportance), IncNodePurity), 
           fill = IncNodePurity)) +
  
       geom_bar(stat = "identity") +
  
       labs(x = "Importance", 
            y = "", 
            title = "") +
  
       scale_fill_gradient(low = "pink2", 
                           high = "maroon4") +
  
       th1
```

<img src="README_files/figure-markdown_github/unnamed-chunk-16-1.png" width="80%" height="80%" style="display: block; margin: auto;" />

## K-Nearest-Neighbours

``` r
# Model 

PredKNN <- knn(
  
  Train[, Features[Features != "Default"]],
  
  Test[, Features[Features != "Default"]], 
  
  Train$Default, 
  
  15)

# Predictions 

PredKNN <- as.numeric(PredKNN)
PredKNN <- PredKNN -1

ConfKNN <- table(PredKNN, Test$Default)
PropKNN <- prop.table(ConfKNN, margin = 2)
```

## Voting Model

``` r
# A model that has a hierarchical combination of the previous models in order to make its own vote. 

Votes <- 
  
  ifelse(PredTree == PredNet & PredNet == PredKNN, PredTree,
  
  ifelse(PredTree == PredNet | PredTree == PredKNN, PredTree,
         
    ifelse(PredNet == PredKNN, PredNet, PredKNN)))

# Predictions 

Combined <- table(Votes, Test$Default)
CombConf <- prop.table(Combined, margin = 2)
```

# Model Comparisons

``` r
knitr::include_graphics("Images/MLTable.png",
                        dpi = 300)
```

<img src="Images/MLTable.png" width="80%" height="80%" style="display: block; margin: auto;" />

``` r
# I made the plots in a separate script. 

source("Code/ROC.R")
```

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

    ## Setting levels: control = 0, case = 1

    ## Setting direction: controls < cases

``` r
# plot 

ggplot(DF, 
       aes(x = 1 - x, 
           y = y, 
           color = Method)) +
  
  geom_line() +
  
  geom_ribbon(aes(ymin = 0, 
                  ymax = y, 
                  fill = Method), 
              alpha = 0.35) +
  
  labs(x = "False Positive Rate", 
       y = "True Positive Rate",
       color = "Method", 
       fill = "Method") + 
  
  scale_color_manual(values = c(
    "Lasso" = "pink", 
    "Forest" = "maroon4", 
    "KNN" = "maroon")) +
  
  scale_fill_manual(values = c(
    "Lasso" = "pink", 
    "Forest" = "maroon4", 
    "KNN" = "maroon")) +
  
  theme(
      panel.spacing = unit(0.1, "lines"),
      strip.text.x = element_text(
        size = 8),
      plot.background = element_rect(
        fill = "#000033"),
      axis.text = element_text(
        color = "white"),
      axis.title = element_text(
        color = "white"),
      plot.title = element_text(
        color = "white"),
      strip.text = element_text(
        color = "white"),
      panel.background = element_rect(
        fill = "transparent"),
      panel.grid.major = element_blank(),                
      panel.grid.minor = element_blank())
```

<img src="README_files/figure-markdown_github/unnamed-chunk-20-1.png" width="80%" height="80%" style="display: block; margin: auto;" />

``` r
TestScatter <- cbind(Test, PredForPlot) 
TestScatter <- cbind(TestScatter, PredTree)

# We can now see probability of deault as a function of a few other things.

H1 <- Heat(Amount, "Amount Loaned")
H2 <- Heat(Pressure, "Pressure") + xlim(c(0,5))
H3 <- Heat(Paid1, "Penultimate Payment Amount") + xlim(c(0,1.5))
H4 <- Heat(Payment, "Payment Habits")  + xlim(c(0,1.5))

# plot 

grid.arrange(H1, H2, H3, H4, nrow = 2)
```

<img src="README_files/figure-markdown_github/unnamed-chunk-21-1.png" width="80%" height="80%" style="display: block; margin: auto;" />

# Bibliography

Grömping, U. 2009. Variable Importance Assessment in Regression: Linear
Regression versus Random Forest. *The American Statistician*,
63(4):308-319.

Henley, W. E & Hand D. J. 1996. A *k*-Nearest-Neighbour Classifier for
Assessing Consumer Credit Risk. *Journal of the Royal Statistical
Society. Series D (The Statistician)*, 45(1):77-95.

Predict Credit Card Defaulters \[Online\]. \[n.d.\]. Available:
<https://www.kaggle.com/datasets/utkarshx27/default-of-credit-card-clients-dataset?resource=download>
(25 April 2023).

Scornet, E, Biau, G, & Vert, J. 2015. Consistency of Random Forests.
*The Annals of Statistics*, 43(4):1716-1741.

Tibshirani, R. 1996. Regression Shrinkage and Selection via the Lasso.
*Journal of the Royal Statistical Society. Series B (Methodological)*,
58(1):267-288.
