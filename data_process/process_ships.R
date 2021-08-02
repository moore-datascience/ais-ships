#'
#' file: process_ships.R
#' loc: /efs/Shiny/ais-ships2/data_process/
#' date: 7.30.21
#' 
#' This file will represent the first step in this project, where we will
#' be cleaning up our raw data into a form that will be usable in our 
#' shiny application.
#'
#--------------------------/

library(dplyr)
library(lubridate)
library(stringr)
library(purrr)
library(geodist)


simpleCap2 <- function(x) {
  
  a <- NULL
  
  for(k in 1:length(x)){
    
    s <- strsplit(x[k], " ")[[1]]
    a2 <- paste(toupper(substring(s, 1,1)), substring(s, 2),
                sep="", collapse=" ")
    
    a <- c(a,a2)
    
  }
  
  return(a)
  
}



#' First off lets convert to df and save as a .rds for faster
#' loads later
#' 
root_data <- paste0(root0,'Shiny/ais-ships/data/ships.csv')
# ships_raw <- read.csv(root_data)

loc0 <- root_data %>% gsub('.csv','.rds',.,fixed = T)
# saveRDS(ships_raw,loc0)

ships_raw <- readRDS(loc0)

s0 <- ships_raw



#' Basic cleanup for easier to use names
#' 
names(s0) <- names(s0) %>% tolower(.)

s0$date <- ymd(s0$date) 
s0$datetime <- ymd_hms(s0$datetime) 

s0 <- s0 %>% select(
  uid = ship_id, 
  name = shipname,
  type=ship_type,
  datetime,
  la=lat, 
  lo=lon, 
  all_of(names(.))
)


#' Check for all entries with at least 2 entries. Only 3 ships 
#' match but should be removed
#' 
s0 <- s0 %>% 
  add_count(uid) %>% 
  filter(n>1) %>% 
  select(-n)


#' First lets take a look at only a single ship. 
#' 
s1 <- s0 %>% filter(name=='KAROLI')

glimpse(s1)

View(s1)


#' A simple datetime reordering shows that not all entries are in 
#' proper order, so I should start by arranging by uid, datetime 
#' to allow me to create function that compares distances
#' 
s0 <- s0 %>% arrange(uid,datetime)



#' Now lets check to see if any names are numeric based,
#' 
s0$is_num_name <- !is.na(as.numeric(s0$name))

table(s0$is_num_name)

inn <- s0 %>% filter(is_num_name) %>% arrange(uid,desc(speed))

View(inn)


#' From looking at the data, these generally seem like junk, will 
#' remove for now.
#' 
s0 <- s0 %>% filter(!is_num_name) %>% select(-is_num_name)

glimpse(s0)




#' Now lets use the geodist::geodist_vec() function to calculate the 
#' distance between two points. This function naturally accepts x1,x2 
#' and y1,y2 values, but with the use of sequential=T we are able to leave
#' in in current format and distances are calculated using row pairs. Then
#' remove all instances where the max_distance is not greater than 0. 
#' 
ships <- s0 %>%
  group_by(uid) %>%
  mutate(
    distance = geodist_vec(lo,la,sequential = TRUE,pad = TRUE,
                           measure = "geodesic")
  ) %>%
  mutate(
    max = max(distance, na.rm = TRUE)
  ) %>%
  ungroup() %>% 
  filter(max>0)


glimpse(ships)
 



#' Now here i will be using a somewhat sloppy for-loop, but because I want
#' to check for name and duplicated max distance errors, I will use this form
#' to more carefully analyze where these errors occur. The fact that this is
#' not optimized is ok because we only need to run this once and time saving
#' from apply family of methods will be non-critical to the rest of the 
#' project

un0 <- unique(ships$uid)

match_df <- data.frame()
name_errors <- NULL

for(i in 1:length(un0)){
  
  id0 <- un0[i]
  
  if(i %% 50 ==0){pripas('i=',i)}
  
  lil0 <- ships %>% filter(uid==id0)
  
  un1 <- unique(lil0$name)
  if(length(un1)>1){
    
    pripas('Non unique name at i = ',i)
    
    name_errors <- c(name_errors,lil0$uid[1])
    
    t0 <- table(lil0$name) 
    print(t0)
    
    n0 <- names(t0)
    n1 <- as.numeric(t0)
    
    wm0 <- n0[which(n1==max(n1))]
    
    lil0$name <- wm0
    
  }

  w0 <- which(lil0$distance==lil0$max_distance) %>% max()
  
  df0 <- lil0[c(w0-1,w0),] %>% select(-max_distance)
  
  match_df <- bind_rows(match_df,df0)
    
}

name_errors %>% paste(.,collapse = "','")
# ->
# name_errors <- c('315731','315950','316404','316482','345254','347195',
#                  '364937','406999','757619','3653787','4666609')


ships_clean <- match_df

ships_clean$name <- ships_clean$name %>% tolower() %>% simpleCap2()


loc_save0 <- root_data %>% 
  gsub('.csv','_clean.rds',.,fixed = T) %>% 
  gsub('data','app/data',.)

saveRDS(ships_clean,loc_save0)































































