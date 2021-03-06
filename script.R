---
  title: "Aggregating Hate Crime News Reports"
author: "Jeff Huang"
date: "4/7/2019"
output: html_document
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

library(tidyverse)
library(readr)
library(janitor)
library(ggplot2)
library(lubridate)
library(ggthemes)

hate_crimes <- read.csv("hatecrimes2017.csv") %>% 
  clean_names() %>% 
  mutate(crime_day= as.POSIXct(article_date, format = "%m/%d/%y")) %>% 
  filter(month(crime_day) > 3)


```

# Trend Analysis
#This dataset uses instances of news reports on Google News to track hate crimes from the Spring/Summer seasons in 2017. This dataset was obtained from the Propublica Data center (https://www.propublica.org/datastore/dataset/documenting-hate-news-index), compiled with Google News search results. So far, I`ve looked into the different trends over time, as well as looking at trends within types of hate crimes using the title and keywords columns. 


crimes_by_day <- hate_crimes %>% 
group_by(crime_day) %>% 
summarize(num = n())


crimes_by_city <- hate_crimes %>% 
select(city, state) %>% 
drop_na(city, state) %>% 
mutate(city_state = paste(city,state, sep=", ")) %>% 
group_by(city_state) %>% 
summarize(city_total = n())

lgbtq_crimes <- hate_crimes %>% 
select(keywords, article_date, article_title) %>% 
mutate(crime_day= as.POSIXct(article_date, format = "%m/%d/%y")) %>% 
filter(str_detect(keywords, "gay") | str_detect(article_title, "gay")) %>% 
group_by(crime_day) %>% 
summarize(total = n())

iphobia_crimes <- hate_crimes %>% 
select(keywords, article_date, article_title) %>% 
mutate(crime_day= as.POSIXct(article_date, format = "%m/%d/%y")) %>% 
filter(str_detect(keywords, "muslim") | str_detect(article_title, "muslim")) %>% 
group_by(crime_day) %>% 
summarize(total = n()) 


ggplot() +
geom_line(data= crimes_by_day, aes(x=crime_day, y=num)) + 
geom_line(data = lgbtq_crimes, aes(x=crime_day, y=total, color = "red")) + 
geom_line(data = iphobia_crimes, aes(x=crime_day, y=total, color = "blue")) +
labs(title = "Spring-Summer Hate Crime Activity (2017)",
subtitle = "According to counts of Google News Reports",
caption = "Source: Propublica",
x = "Month",
y = "Number of Results") +
# formatting time labels
scale_x_datetime(date_labels = "%B") + 
scale_color_discrete(name = "Hate Crime Type", labels = c("Islamophia", "LGBTQ")) +


# add theme
theme_economist()


