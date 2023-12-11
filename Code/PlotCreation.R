# Plot creation 

Data[, c(32, 33, 34, 35)] <- lapply(Data[, c(2, 3, 4, 5)], factor)
Data$Default <- as.factor(Data$Default)

# the above is hideous code but I must have been struggling to solve the 
# problem at the time 

###

G1 <- PreGraphs(Gender.1, Default) + 
  ylab("") +
  scale_x_discrete(
    labels = c("Female", "Male"),
    breaks = c("0", "1"),
    name = NULL) +
  scale_fill_manual(
    values = c("0" = "pink", "1" = "maroon"),
    labels = c("0" = "No", "1" = "Yes"),
    name = "Default?") +
  labs(title = "Gender") +
  th1

G2 <- PreGraphs(Age.1, Default) + 
  ylab("") +
  scale_x_discrete(
    labels = c("< 30", "< 40", "< 50", "50 +"),
    breaks = c("1", "2", "3", "4"),
    name = NULL) +
  scale_fill_manual(
    values = c("0" = "pink", "1" = "maroon"),
    labels = c("0" = "No", "1" = "Yes"),
    name = "Default?") +
  labs(title = "Age") +
  th1

G3 <- PreGraphs(Marriage.1, Default) + 
  ylab("") +
  scale_x_discrete(
    labels = c("Unmarried", "Married"),
    breaks = c("0", "1"),
    name = NULL) +
  scale_fill_manual(
    values = c("0" = "pink", "1" = "maroon"),
    labels = c("0" = "No", "1" = "Yes"),
    name = "Default?") +
  labs(title = "Marital Status") +
  th1

Data$Default <- as.numeric(Data$Default) - 1

###

B1 <- BoxPlot(DataAge, 
              Age, 
              Amount, 
              "", 
              "", 
              "Age Group")
B2 <- BoxPlot(DataGender, 
              Gender, 
              Amount, 
              "", 
              "", 
              "Gender")
B3 <- BoxPlot(DataMarriage, 
              Marriage, 
              Amount, 
              "", 
              "", 
              "Maritial Status")
B4 <- BoxPlot(DataEducation, 
              Education, 
              Amount, 
              "", 
              "", 
              "Education Level")

###

DFTable <- data.frame(
  Models = c("Lasso",
             "KNN",
             "Forest",
             "Voting",
             "Logit"),
  TPR = c(62, 75, 90, 78, 45),
  TNR = c(75, 69, 86, 82, 91),
  AUC = c(0.69, 0.72, 0.89, 0.79, 0.68))

###