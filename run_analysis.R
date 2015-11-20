library(dplyr)
library(data.table)

# preparing observations from group 'test'
subject_test=read.fwf("subject_test.txt", header=FALSE, widths = 2, sep ='\n' ,col.names = "subject")
subject_test$Group = 'test'
Y_test=read.fwf("y_test.txt", header=FALSE, widths = 1, sep ='\n' ,col.names = "activity")
featurelist=read.fwf("features.txt", header=FALSE, widths = c(3,600), sep ="")
x_test=fread('X_test.txt', sep = " ",sep2 = "\n")
names(x_test)=as.character(featurelist$V2)
x_test_mean=select(x_test, contains("mean()"),contains("-std()"))
test_table=cbind(subject_test,Y_test,x_test_mean)

# preparing observations from group 'train'
subject_train=read.fwf("subject_train.txt", header=FALSE, widths = 2, sep ='\n' ,col.names = "subject")
subject_train$Group = 'train'
Y_train=read.fwf("y_train.txt", header=FALSE, widths = 1, sep ='\n' ,col.names = "activity")
x_train=fread('X_train.txt', sep = " ",sep2 = "\n")
names(x_train)=as.character(featurelist$V2)
x_train_mean=select(x_train, contains("mean()"),contains("-std()"))
train_table=cbind(subject_train,Y_train,x_train_mean)

# Joining subsets from "test" and "train" groups:
uci=rbind(test_table,train_table)

# Renaming activity labels:

uci$activity=gsub ("1","WALKING", uci$activity)
uci$activity=gsub ("2","WALKING_UPSTAIRS", uci$activity)
uci$activity=gsub ("3","WALKING_DOWNSTAIRS", uci$activity)
uci$activity=gsub ("4","SITTING", uci$activity)
uci$activity=gsub ("5","STANDING", uci$activity)
uci$activity=gsub ("6","LAYING", uci$activity)

#final touch (step 4)...

uci=arrange(uci,subject)

# Step 5 - From the data set in step 4, creates a second, independent tidy data set
# with the average of each variable for each activity and each subject.
uci_means=select(uci, contains("subject"),contains("Group"),contains("activity"), contains("mean()"))
uci_means=ddply(uci_means, .(subject,Group,activity), numcolwise(mean))
names(uci_means)=gsub("-mean()","",names(uci_means))
write.table(uci_means,"uci_means.txt",row.name=FALSE)