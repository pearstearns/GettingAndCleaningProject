library(dplyr)
setwd("./UCI HAR Dataset/")
features <- read.table("features.txt")
features$V2 <- gsub("-", "", features$V2)
features$V2 <- gsub("\\(", "", features$V2)
features$V2 <- gsub("\\)", "", features$V2)

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
        suppressWarnings(full_join(wantedRowsA, wantedRowsB)) %>%
        
wantedRows$V1 <-
        as.numeric(wantedRows$V1)
wantedRows <-
        wantedRows[-(grep("Freq", wantedRows$V2)),] %>%
        arrange(V1)


activityLabels <- read.table("activity_labels.txt")
activityLabels$V2 <- tolower(activityLabels$V2)
activityLabels$V2 <- gsub("_", "", activityLabels$V2)
activityLabels$V2 <- sub("dow", "Dow", activityLabels$V2)
activityLabels$V2 <- sub("up", "Up", activityLabels$V2)


testSubject <- read.table("./test/subject_test.txt")
names(testSubject) <- "subjectID"
testMain <-
        read.table("./test/X_test.txt")
testMain <- 
        testMain[, wantedRows$V1]
names(testMain) <- wantedRows$V2
testActivites <- read.table("./test/y_test.txt")
names(testActivites) <- "activityID"
trainActivites <- read.table("./train/y_train.txt")
names(trainActivites) <- "activityID"
trainMain <-
        read.table("./train/X_train.txt")
trainMain <-trainMain[, wantedRows$V1]
names(trainMain) <- wantedRows$V2
trainSubject <-  read.table("./train/subject_train.txt")
names(trainSubject) <- "subjectID"



testComplete <-
        cbind(testSubject, testActivites, testMain) %>%
        tbl_df
trainComplete <-
        cbind(trainSubject, trainActivites, trainMain)  %>%
        tbl_df


completeSet <-
        full_join(testComplete, trainComplete)

        for (i in 1:6) {
               completeSet$activityID <- gsub(i, activityLabels[i, 2], completeSet$activityID)
        }


tidyMeans <-
        completeSet %>%
        group_by(subjectID, activityID) %>%
        summarize_each(funs(mean)) %>%
        print