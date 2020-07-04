library(dplyr)

filename <- "week3Assignment"

# Checking if archive already exists.
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  

# Checking if folder exists
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

## Assigning the dataframes
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("id","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

##Merging training and test datasets into one
X <- rbind(x_train,x_test)
Y <- rbind(y_train,y_test)
subject <- rbind(subject_train,subject_test)
merged_data <- cbind(subject,X,Y)
names(merged_data)

## Extracting only the measurements on the mean and standard deviation for each
## measurements
tidyData <- merged_data %>% 
  select(subject, code, contains("mean"), contains("std"))

## renaming activities with descsriptive activity names
tidyData$code <- activities[tidyData$code, 2]

## using gsub to label the data sets with descriptive variable names
names(tidyData)[2] = "activity"
names(tidyData)<-gsub("Acc", "Accelerometer", names(tidyData))
names(tidyData)<-gsub("Gyro", "Gyroscope", names(tidyData))
names(tidyData)<-gsub("BodyBody", "Body", names(tidyData))
names(tidyData)<-gsub("Mag", "Magnitude", names(tidyData))
names(tidyData)<-gsub("^t", "Time", names(tidyData))
names(tidyData)<-gsub("^f", "Frequency", names(tidyData))
names(tidyData)<-gsub("tBody", "TimeBody", names(tidyData))
names(tidyData)<-gsub("-mean()", "Mean", names(tidyData), ignore.case = TRUE)
names(tidyData)<-gsub("-std()", "STD", names(tidyData), ignore.case = TRUE)
names(tidyData)<-gsub("-freq()", "Frequency", names(tidyData), ignore.case = TRUE)
names(tidyData)<-gsub("angle", "Angle", names(tidyData))
names(tidyData)<-gsub("gravity", "Gravity", names(tidyData))

## creating a second tidy_data with avg of each variable for each activity and 
## subject
finalTidyData <- tidyData %>%
  group_by(subject, activity) %>%
  summarise_all(list(mean))

write.table(finalTidyData,"FinalData.txt",row.name = FALSE )