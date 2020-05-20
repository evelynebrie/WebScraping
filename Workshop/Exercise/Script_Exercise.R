### Web Scraping with R - Exercise Script 

## 20-05-2020
## Evelyne Brie
## City Lab Berlin

# This code is useful to try and scrape one single Web page
# Modifications are only necessary where "!!!" is indicated

# Here is my Website suggestion: "https://petitions.ourcommons.ca/en/Petition/Search?View=D&parl=43&type=&keyword=&sponsor=&status=&Text=&RPP=20&order=Recent&Page=1&category=All"

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

# !!! In the code below, replace each occurence of "NODE" with nodes identified using SelectorGadget

# Identifying the nodes using SelectorGadget (https://selectorgadget.com/)
scraping <- function(x){
  tibble(signatures = html_nodes(x, "NODE") %>% html_text(), # Scraping the number of signatures
         mp = html_nodes(x, "NODE") %>% html_text()) # Scraping the name of the Member of Parliament
}

# 3. Store your URL

# !!! Replace "URL" below by the URL of your Website (remember: we are only scraping one page here)

url <- "URL"

# 4. Scrape the website and store the output in a tibble named "myResults"

# Please note that the %>% operator forwards a value (or the result of an expression) into the next function

tic() 
myResults <- url %>% # Saving the scraping results in a tibble named "myResults" 
  map(read_html) %>% # Applying the "read_html" function to each element and returning a vector of the same length
  map_df(scraping) # Applying the "scraping" function to each element and returning a data frame
toc()

# 5. Check results and create new URLs

head(myResults,5) # Displaying the first 5 rows of our dataset

# 6. Save scraped data into a .csv file

# !!! Replace "yourPath" by the correct path file on your computer

write.csv(myResults,file="yourPath/myFile.csv") # Saving that dataframe into a .csv file named "myFile"
