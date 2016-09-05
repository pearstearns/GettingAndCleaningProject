#require and load dplyr
require(dplyr)
library(dplyr)

## Download and unzip the dataset:
filename <- "getData.zip"

if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

#load the features, remove dashes and parenthesis
features <- read.table("UCI HAR Dataset/features.txt")
features$V2 <- gsub("-mean", "Mean", features$V2)
features$V2 <- gsub("-std", "Std", features$V2)
features$V2 <- gsub("\\(", "", features$V2)
features$V2 <- gsub("\\)", "", features$V2)

#Grab what we want (mean, std) from features and put it in a seperate dataset
wantedRowsA <-
        cbind(grep("mean", features$V2),
              grep("mean", features$V2, value = TRUE)) %>%
        as.data.frame(wantedRowsA) %>%
        tbl_df

wantedRowsB <-
        cbind(grep("std", features$V2),
              grep("std", features$V2, value = TRUE)) %>%
        as.data.frame(wantedRowsB) %>%
        tbl_df

wantedRows <-
        suppressWarnings(full_join(wantedRowsA, wantedRowsB))
        
wantedRows$V1 <-
        as.numeric(wantedRows$V1)
wantedRows <-
        wantedRows[-(grep("Freq", wantedRows$V2)),] %>%
        arrange(V1)

#make the labels more tidy
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels$V2 <- tolower(activityLabels$V2)
activityLabels$V2 <- gsub("_", "", activityLabels$V2)
activityLabels$V2 <- sub("dow", "Dow", activityLabels$V2)
activityLabels$V2 <- sub("up", "Up", activityLabels$V2)

#Read all the files in the directories, add variable names, and have only the rows we want
testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt")
names(testSubject) <- "subject"
testData <-
        read.table("UCI HAR Dataset/test/X_test.txt")
testData <- 
        testData[, wantedRows$V1]
names(testData) <- wantedRows$V2
testActivites <- read.table("UCI HAR Dataset/test/y_test.txt")
names(testActivites) <- "activity"
trainActivites <- read.table("UCI HAR Dataset/train/y_train.txt")
names(trainActivites) <- "activity"
trainData <-
        read.table("UCI HAR Dataset/train/X_train.txt")
trainData <-trainData[, wantedRows$V1]
names(trainData) <- wantedRows$V2
trainSubject <-  read.table("UCI HAR Dataset/train/subject_train.txt")
names(trainSubject) <- "subject"


#concatenate train files and test files
testComplete <-
        cbind(testSubject, testActivites, testData) %>%
        tbl_df
trainComplete <-
        cbind(trainSubject, trainActivites, trainData)  %>%
        tbl_df

#join the two to make a set, and make the activity column into text
completeSet <-
        full_join(testComplete, trainComplete)

        for (i in 1:6) {
               completeSet$activity <- gsub(i, activityLabels[i, 2], completeSet$activity)
        }

#create the second, tidy set using dplyr
tidyMeans <-
        completeSet %>%
        group_by(subject, activity) %>%
        summarize_each(funs(mean))

#write results to text files
write.table(completeSet, "./merged_data.txt", row.name=FALSE)
write.table(tidyMeans, "./merged_means.txt", row.name=FALSE)
