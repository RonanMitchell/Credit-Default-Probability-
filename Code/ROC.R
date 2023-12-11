### Creation

LassoROC <- roc(Test$Default, PredNet)

KnnROC <- roc(Test$Default, PredKNN)

ForestROC <- roc(Test$Default, PredTree)

VotesROC <- roc(Test$Default, Votes)

LogitROC <- roc(Test$Default, PredLogit)

### Extraction

Lasso <- data.frame(x = LassoROC$specificities, 
                    y = LassoROC$sensitivities)

Forest <- data.frame(x = ForestROC$specificities, 
                     y = ForestROC$sensitivities)

KNN <- data.frame(x = KnnROC$specificities, 
                  y = KnnROC$sensitivities)

# Combine data frames

DF <- rbind(Lasso, Forest, KNN)

DF$Method <- rep(c("Lasso", "Forest", "KNN"), each = length(Lasso$x))