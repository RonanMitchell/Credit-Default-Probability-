# sadly there really is no easy way to do the following in R:

names(Data) <- c("Amount",
                 
                 "Gender", 
                 
                 "Education",
                 
                 "Marriage",
                 
                 "Age",
                 
                 "Repayment-1",
                 
                 "Repayment-2",
                 
                 "Repayment-3",
                 
                 "Repayment-4",
                 
                 "Repayment-5",
                 
                 "Repayment-6",
                 
                 "Bill-1",
                 
                 "Bill-2",
                 
                 "Bill-3",
                 
                 "Bill-4",
                 
                 "Bill-5",
                 
                 "Bill-6",
                 
                 "Paid-1",
                 
                 "Paid-2",
                 
                 "Paid-3",
                 
                 "Paid-4",
                 
                 "Paid-5",
                 
                 "Paid-6",
                 
                 "Default",
                 
                 "Owed",
                 
                 "Payment",
                 
                 "Difference",
                 
                 "Interest",
                 
                 "Pressure",
                 
                 "Variance",
                 
                 "Quality")

colnames(Data) <- gsub("-", "", colnames(Data))

### Transitory Datasets

DataPaid <- Data %>% 
  
  select(Paid1, Paid2, Paid3, Paid4, Paid5, Paid6) %>% 
  
  gather(key = "Month", value = "Amounts") %>% 
  
  mutate(Month = factor(Month,
                        levels = c("Paid6", 
                                   "Paid5", 
                                   "Paid4", 
                                   "Paid3", 
                                   "Paid2", 
                                   "Paid1"),
                        labels = c("April", 
                                   "May",
                                   "June",
                                   "July", 
                                   "August",
                                   "September"))) 

###

DataBills <- Data %>% 
  
  select(Bill1, Bill2, Bill3, Bill4, Bill5, Bill6) %>% 
  
  gather(key = "Month", value = "Amounts") %>% 
  
  mutate(Month = factor(Month,
                        levels = c("Bill6", 
                                   "Bill5", 
                                   "Bill4", 
                                   "Bill3", 
                                   "Bill2", 
                                   "Bill1"),
                        labels = c("April", 
                                   "May",
                                   "June",
                                   "July", 
                                   "August",
                                   "September")))

###

DataAge <- Data |> 
  select(Amount, Age) |> 
  gather(key = "Amount", value = "Age") |> 
  mutate(Age = factor(Age,
                      levels = c("1",
                                 "2",
                                 "3",
                                 "4"),
                      labels = c("< 30",
                                 "< 40",
                                 "< 50",
                                 "50 +")))

DataGender <- Data |> 
  select(Amount, Gender) |> 
  gather(key = "Amount", value = "Gender") |> 
  mutate(Gender = factor(Gender,
                         levels = c("0",
                                    "1"),
                         labels = c("Female",
                                    "Male")))

DataMarriage <- Data |> 
  select(Amount, Marriage) |> 
  gather(key = "Amount", value = "Marriage") |> 
  mutate(Marriage = factor(Marriage,
                           levels = c("0",
                                      "1"),
                           labels = c("Unmarried",
                                      "Married")))

DataEducation <- Data |> 
  select(Amount, Education) |> 
  gather(key = "Amount", value = "Education") |> 
  mutate(Education = factor(Education,
                            levels = c("-5",
                                       "0",
                                       "2",
                                       "5"),
                            labels = c("No Schooling",
                                       "Some Schooling",
                                       "High School",
                                       "University")))