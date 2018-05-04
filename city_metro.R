# Metro area shapefile - https://www2.census.gov/geo/tiger/TIGER2016/CBSA/tl_2016_us_cbsa.zip
# Cities shapefule - https://www2.census.gov/geo/tiger/TIGER2017/UAC/tl_2017_us_uac10.zip

library(sf)
library(dplyr)
library(stringr)
setwd('/Users/JamesWang1/Documents/ML/datafest2018/cityMetroJoin')
metro = st_read("tl_2016_us_cbsa/") %>%
  select(metro_name = NAME)
met1 = st_read("tl_2016_us_cbsa/")
head(met1)
met1$LSAD %>% table() # there are Metro (389) and Micro area (556)



# metro$centroid = st_centroid(metro$geometry)
# plot(metro$centroid)
# 
# metro$centroid[metro$metro_name %>% str_detect("Durham") %>% which,] %>% plot
# how to plot centroid is a headache. I need to look at the tobacco project to review


# one challenge is that we need to make the location name usable for tableau. use str split 
# here I use "New York-Newark-Jersey City, NY-NJ-PA" as a test case, as it contains multiple cities and states in the name 
metros = metro[metro$metro_name %>% str_detect("New York") %>% which,]$metro_name
metros
# because we have mutliple city, we use the first city and first state to plot
# first city: remove all the things after "-" and ","
metros %>% str_replace("-.+","") %>% str_replace(",.+","")
# first state: remove all before the "," and after the "-", finally remove white space
metros %>% str_replace(".+,","") %>% str_replace("-.+","") %>% str_trim()

# final product

metro$firstCity = metro$metro_name %>% str_replace("-.+","") %>% str_replace(",.+","") 
metro$firstState = metro$metro_name %>% str_replace(".+,","") %>% str_replace("-.+","") %>% str_trim()
# read in the cities file 
cities = st_read("tl_2017_us_uac10/") %>%
  select(city_name = NAME10)
# join metro and cities together
d = st_join(metro, cities, left = FALSE) # inner join
# we can plot different metros 
d %>% names
par(mfrow = c(2,2))
plot(st_geometry(d[d$metro_name %>% str_detect("Durham") %>% which,]))
plot(st_geometry(d[d$metro_name %>% str_detect("San Jose") %>% which,]))
plot(st_geometry(d[d$metro_name %>% str_detect("Miami-") %>% which,]))
plot(st_geometry(d[d$metro_name %>% str_detect("New York") %>% which,]))
# at this point we don't need the geometry, so we write out the csv file with other colunmns
# note: we need to convert d to a data.frame object first, otherwise the "geometry" column can't be removed 
df = d %>% data.frame() %>% select(-geometry)

write.csv(df, "metroAndCity.csv", row.names = F)
df %>% names





