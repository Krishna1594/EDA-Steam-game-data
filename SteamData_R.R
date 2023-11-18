# Let's load our libraries

library(readxl) 
library(crayon)
library(dplyr)
library(stringr) 
library(stringi) 
library(openxlsx) 
library(janitor) 
library(tidyverse)
library(ggrepel)
library(tidyr)
library(lubridate) 
library(dplyr) 
library(ggplot2) 
library(plotly) 
library(plotrix) 
library(viridisLite, lib.loc="~/R/win-library/3.5") 
library(viridis, lib.loc="~/R/win-library/3.5")
library(hrbrthemes)
library(scales)
library(formattable)
library(showtext)
library(cowplot)
library(readr)
showtext_auto()

# Let's import our raw data
Data <- read.csv(file.choose(), header = TRUE, sep = ",", stringsAsFactors=FALSE)

# Pre-processing and cleaning the data

## Price columns
### Original Prices
Data$Original.Price <- parse_number(Data$Original.Price)
Data$Original.Price <- ifelse(is.na(Data$Original.Price), 0, Data$Original.Price)
### Discounted Prices
Data$Discounted.Price <- parse_number(Data$Discounted.Price)
Data$Discounted.Price <- ifelse(is.na(Data$Discounted.Price), 0, Data$Discounted.Price)

## Release Dates specific to dd-mm-yyyy
Data$Release.Date<- format(dmy(Data$Release.Date), format ="%d %b %Y")# this avoids problems with date on axis while plotting

## Review Numbers
Data$ReviewPercentage <- str_extract(Data$Recent.Reviews.Number, "(\\d+)%")
Data$ReviewPercentage <- as.numeric(gsub("%", "", Data$ReviewPercentage)) #convert text to number
Data$Reviews <- str_extract(Data$Recent.Reviews.Number, "(\\d{1,3}(?:,\\d{3})*)(?= user reviews)")
Data$Reviews <- as.numeric(gsub(",", "", Data$Reviews)) #convert text to number

## There are games with no reviews/empty cells, so, filling 0's/text in place of NA:
Data$ReviewPercentage[is.na(Data$ReviewPercentage)] <- 0
Data$Reviews[is.na(Data$Reviews)] <- 0
Data <- Data %>% mutate(Recent.Reviews.Summary = na_if(Recent.Reviews.Summary, ""))
Data <- Data %>% mutate(All.Reviews.Summary = na_if(All.Reviews.Summary, ""))
Data$Recent.Reviews.Summary[is.na(Data$Recent.Reviews.Summary)] <- 'No Reviews'
Data$All.Reviews.Summary[is.na(Data$All.Reviews.Summary)] <- 'No Reviews'



## Extracting details of minimum system requirements
# Define the labels you want to extract
labels <- c("OS:", "Processor:", "Memory:", "Graphics:", "DirectX:", "Storage:")

# Initialize a list to hold extracted information for each label
extracted_data <- list()

# Extract the information for each label
for (label in labels) {
  extracted_data[[label]] <- str_extract(Data$Minimum.Requirements, paste0(label, " \\|\\s*([^\\|]*)"))
}

# Create a data frame with extracted information in separate columns
extracted_df <- as.data.frame(extracted_data)
extracted_df$OS. <- gsub("^OS: \\| ", "", extracted_df$OS.) 
extracted_df$Processor. <- gsub("^Processor: \\| ", "", extracted_df$Processor.)
extracted_df$Memory. <- gsub("^Memory: \\| ", "", extracted_df$Memory.)
extracted_df$Graphics. <- gsub("^Graphics: \\| ", "", extracted_df$Graphics.)
extracted_df$DirectX. <- gsub("^DirectX: \\| ", "", extracted_df$DirectX.)
extracted_df$Storage. <- gsub("^Storage: \\| ", "", extracted_df$Storage.)
## Refining further
extracted_df$Storage. <- gsub(".*?(\\d+\\s*(GB|MB)).*", "\\1", extracted_df$Storage.)
extracted_df$Memory. <- gsub(".*?(\\d+\\s*(GB|MB)).*", "\\1", extracted_df$Memory.)

## Finally, merging these two tables:
extracted_df$Title <- Data$Title
SteamData <- full_join(Data,extracted_df, by = "Title")

## Working on languages
# Define a function to count languages
count_languages <- function(row) {
  languages <- unlist(strsplit(row, ', '))
  return(length(languages))
}

# Apply the function to each row
SteamData$Languages <- sapply(SteamData$Supported.Languages, count_languages)

## Links: Every game in Steam is powered by Steam so we do not need to worry about links of the games

## Working on Popular Game tags, Game.features and Supported languages by users: we have to pre-define the game tags
SteamData$Popular.Tags <- lapply(SteamData$Popular.Tags, function(text) gsub("\\[|\\]|'", "", text))

SteamData$Supported.Languages <- lapply(SteamData$Supported.Languages, function(text) gsub("\\[|\\]|'", "", text))

SteamData$Game.Features <- lapply(SteamData$Game.Features, function(text) gsub("\\[|\\]|'", "", text))

GameTags <- c('Shooter', 'Action', 'Adventure', 'Simulation', 'Racing', 'Strategy', 'RPG', 
              'Battle Royale', 'MOBA', 'Horror')
# Create a dataframe for the specified genres and indicate their presence as TRUE or FALSE
extracted_genres <- data.frame(matrix(NA, nrow = nrow(SteamData), ncol = length(GameTags)))

# Loop through genres and populate the extracted genres data frame
for (i in 1:length(GameTags)) {
  genre <- GameTags[i]
  extracted_genres[, i] <- sapply(SteamData$Popular.Tags, function(text) grepl(genre, text))
}

# Rename the columns of the extracted genres data frame
colnames(extracted_genres) <- GameTags

# Combine the original data frame and the extracted genres data frame
SteamData <- cbind(SteamData, extracted_genres)

# Exporting the cleaned data 
#apparently, Popular.tags and Supported.Languages columns are returning empty. After observations, The data in this columns is interpreted as list.
#we have to use unlist() command for this problem.
SteamData$Popular.Tags <- unlist(SteamData$Popular.Tags, use.names = FALSE)
SteamData$Supported.Languages <- unlist(SteamData$Supported.Languages, use.names = FALSE)
SteamData$Game.Features <- unlist(SteamData$Game.Features, use.names = FALSE)

## Removing unnecessary columns as we don't need it anymore after extracting vital infomration from them:
SteamData <- subset(SteamData, select = -Minimum.Requirements)
SteamData <- subset(SteamData, select = -Game.Description)
SteamData <- subset(SteamData, select = -Link)
SteamData <- subset(SteamData, select = -Recent.Reviews.Number)
SteamData <- subset(SteamData, select = -All.Reviews.Number)
SteamData <- subset(SteamData, select = -Popular.Tags)
SteamData <- subset(SteamData, select = -Supported.Languages)
SteamData <- subset(SteamData, select = -Game.Features)

#Making sure all the data is in the format of utf-8:
SteamData$Title <- iconv(SteamData$Title, "latin1", "ASCII", sub="")
SteamData$Developer <- iconv(SteamData$Developer, "latin1", "ASCII", sub="")
SteamData$Publisher <- iconv(SteamData$Publisher, "latin1", "ASCII", sub="")
#SteamData$Supported.Languages <- iconv(SteamData$Supported.Languages, "latin1", "ASCII", sub="")
#SteamData$Popular.Tags <- iconv(SteamData$Popular.Tags, "latin1", "ASCII", sub="")
#SteamData$Game.Features <- iconv(SteamData$Game.Features, "latin1", "ASCII", sub="")
SteamData$OS. <- iconv(SteamData$OS., "latin1", "ASCII", sub="")
SteamData$Processor. <- iconv(SteamData$Processor., "latin1", "ASCII", sub="")
SteamData$Graphics. <- iconv(SteamData$Graphics., "latin1", "ASCII", sub="")

## Handling empty cells again:
SteamData <- SteamData %>% mutate(Publisher = na_if(Publisher, " "))
SteamData <- SteamData %>% mutate(Developer = na_if(Developer, " "))
SteamData$Developer[is.na(SteamData$Developer)] <- 'Unknown'
SteamData$Publisher[is.na(SteamData$Publisher)] <- 'Unknown'


# Exporting the data in csv
write.csv(SteamData, "D:\\Professional Data Analytics Cert-GOOGLE\\EDA\\Steam_Data\\SteamData.csv")
