run_analysis <- function() {
  
    # Prepare the environment
    workingDir <- "C:/Users/user/Dropbox/School/Data Science 2014/Course 3 - Getting and Cleaning Data/Project 1" 
  
    dataDir  <- paste(workingDir,"data",sep="/")  
    setwd(dataDir)

    #download then extract data into data directory
    downloadData <- function() {
        
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        downloadFilename <- "FUCI HAR Dataset.zip"
        zipFile <- file.path(dataDir, downloadFilename)    
        print (paste("STATUS: Data directory:", dataDir, sep=" "))            
        
        # Check to see if data exists. If not, download and extract. Download could take a while.        
        if(!file.exists(zipFile)) { 
            print ("STATUS: downloading data...")
            download.file(url, zipFile, method = "auto") #curl method does not work
        }
        else {
            print("STATUS: Zip file already downloaded.")
        }
        
        dataDir  <- paste(dataDir,"UCI HAR Dataset", sep="/")  
                
        if (!file.exists(paste(dataDir,"test/X_test.txt", sep="/"))){
            print("STATUS: extracting data...")        
            # Warning - subdirectory is created during extraction
            unzip(zipFile, exdir = ".")
        } else{
            print("STATUS: Zip file already extracted.")            
        }
        print ("STATUS: All data files are ready.")        
        return(dataDir)        
    }
    
    # Update working directory to the new data directory
    setwd(downloadData())
    
    #Load the data files into objects. Could take a while.
    print ("STATUS: loading objects from files...")
    
    trainingSet = read.csv("train/X_train.txt", sep="", header=FALSE)
    trainingSet[,562] = read.csv("train/Y_train.txt", sep="", header=FALSE)
    trainingSet[,563] = read.csv("train/subject_train.txt", sep="", header=FALSE)
    
    testingSet = read.csv("test/X_test.txt", sep="", header=FALSE)
    testingSet[,562] = read.csv("test/Y_test.txt", sep="", header=FALSE)
    testingSet[,563] = read.csv("test/subject_test.txt", sep="", header=FALSE)
    
    activityLabels = read.csv("activity_labels.txt", sep="", header=FALSE)
    
    # Get features then change their names to make them more readable
    print ("STATUS: Renaming features...")    
    features = read.csv("features.txt", sep="", header=FALSE)
    features[,2] = gsub('-mean', 'Mean', features[,2])
    features[,2] = gsub('-std', 'Std', features[,2])
    features[,2] = gsub('[-()]', '', features[,2])
    
    # Merge the training and test sets into a single dataset
    print ("STATUS: Merging training set and test set...")
    mergedData = rbind(trainingSet, testingSet)
    
    # Get only the mean and sd data
    print ("STATUS: Parsing the dataset...")
    #look for substrings in feature names
    desiredCols <- grep(".*Mean.*|.*Std.*", features[,2])
    # Make a subset of the features table using desiredCols
    features <- features[desiredCols,]
    # Now append the subject and activity columns
    desiredCols <- c(desiredCols, 562, 563)
    # Make a subset of the dataset using the desired columns only (as above)
    mergedData <- mergedData[,desiredCols]
    # Add the column names (features) to mergedData
    colnames(mergedData) <- c(features$V2, "Activity", "Subject")
    colnames(mergedData) <- tolower(colnames(mergedData))
    
    print ("STATUS: Replacing character labels in dataset...")
    # Iterate through the acrivityLabels and change each label
    currentActivity = 1
    for (currentActivityLabel in activityLabels$V2) {
        mergedData$activity <- gsub(currentActivity, currentActivityLabel, mergedData$activity)
        currentActivity <- currentActivity + 1
    }
    
    # Coerce into factors
    mergedData$activity <- as.factor(mergedData$activity)
    mergedData$subject <- as.factor(mergedData$subject)
    
    # Split into summary subsets
    tidyData = aggregate(mergedData, by=list(activity = mergedData$activity, subject=mergedData$subject), mean)
    # Remove the subject and activity columns
    tidyData[,90] = NULL
    tidyData[,89] = NULL
    
    # Write the table to a file in the working directory
    write.table(tidyData, "tidy.txt", sep="\t")
    print ("STATUS: Finished. Created tidy.txt in the working directory.")
  
}