### Web Scraping with R - Teaching Script

## 20-05-2020
## Evelyne Brie
## City Lab Berlin

# 1. Installing and loading packages

install.packages("rvest") # You only need to install each package once
install.packages("tidyverse")
install.packages("stringr")
install.packages("tictoc")

library(rvest) # You always need to load relevant packages
library(tidyverse)
library(stringr)
library(tictoc)

# 2. Create a function called scraping() to scrape this specific website

# Identifying the nodes using SelectorGadget (https://selectorgadget.com/)
scraping <- function(x){
  tibble(petition_title = html_nodes(x, ".petition-open a") %>% html_text(), # Scraping the petition's title
         number_of_signatures = html_nodes(x, ".count") %>% html_text(), # Scraping the number of signatures
         link = html_attr(html_nodes(x, ".petition-open a"), "href")) # Scraping the URL behind the petition's title
}

# 3. Generate all relevant URLs

# This is our "base" URL for page 1: https://petition.parliament.uk/petitions?page=1&state=open
# We only need to replace the "1" by the relevant number of pages
# We know that there are 17 pages, so we need to insert numbers 1 to 17 inclusively

numbers <- seq(from = 1, to = 17) # Creating a sequence of numbers between 1 and 17
urls <- paste("https://petition.parliament.uk/petitions?page=", numbers, "&state=open", sep="") # Pasting both to copy the URL format of that website for each alphabetical section

urls[1:5] # Viewing our first five URLs

# 4. Scrape the website and store the output in a tibble named "myResults"

# Please note that the %>% operator forwards a value (or the result of an expression) into the next function

tic() 
myResults <- urls %>% # Saving the scraping results in a tibble named "myResults" 
  map(read_html) %>% # Applying the "read_html" function to each element and returning a vector of the same length
  map_df(scraping) # Applying the "scraping" function to each element and returning a data frame
toc()

# 5. Check results and create new URLs

head(myResults,5) # Displaying the first 5 rows of our dataset

myResults[1:5,3] # Viewing 5 first values of the "link" vector

myResults$link_clean <- paste("https://petition.parliament.uk",myResults$link, sep="")

myResults[1:5,4] # Viewing  5 first values of the "link_clean" vector

# 6. Create a function called within_page() to scrape each individual link from myResults$link_clean

within_page <- function(x){
  tibble(created_by = html_node(x, ".meta-created-by") %>% html_text(),
         deadline = html_node(x, ".meta-deadline") %>% html_text(),
         description = html_node(x, "h1+ div p") %>% html_text())
}

# 7. Scrape the website and storing the output in a tibble named "myAdditionalResults"

tic()
myAdditionalResults <- myResults$link_clean %>% 
  map(read_html) %>% 
  map_df(within_page)
toc() # This took 147.66 sec 

# 8. Check results and merge both dataframes

head(myAdditionalResults,5) # Displaying the first 5 rows of our dataset

finalDataset <- cbind(myResults,myAdditionalResults) # Merging both dataframes

# 9. Cleaning the final dataset

colnames(finalDataset) # Seeing all column names

finalDataset <- finalDataset[,-3] # Removing the "link" column

# The two problematic columns are "created_by" and "deadline" 

# The first thing we want to do is to remove the characters that are always present
finalDataset$created_by <- gsub("Created by ","",finalDataset$created_by) # Replace all occurences of this string by "" (i.e. nothing)
finalDataset$deadline <- gsub("All petitions run for 6 months","",finalDataset$deadline)
finalDataset$deadline <- gsub("Deadline","",finalDataset$deadline)

# Now we might want to remove the extra white space in some of the vectors
trim <- function (x) gsub("^\\s+|\\s+$", "", x) # Create a function called trim() to remove white space at the beginning and end of the strings
finalDataset <- data.frame(sapply(finalDataset, function(x) trim(x)), stringsAsFactors=FALSE) # Apply this function to all columns in the dataset

head(finalDataset, 10) # Displaying the first 10 rows of our dataset

# 7. Save scraped data into a .csv file
write.csv(finalDataset,file="/Users/evelynebrie/Desktop/myFile.csv") # Saving that dataframe into a .csv file named "myFile"
