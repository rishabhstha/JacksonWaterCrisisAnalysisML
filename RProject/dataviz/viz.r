library(tidyverse)
library(ggplot2)
library(maps)
library(leaflet)
library(gganimate)
library(ggthemes)
library(lubridate)

news_data<-read_csv("bargraph.csv")


news_data<-news_data%>%filter(Media %in% c('WLBT', 'The Clarion-Ledger', 'WJTV', 'WAPT', 'Jackson Free Press', 'Mississippi Today', 'ABC News', 'CNN', 'WBUR', 'NPR'))

non_MS<-c("ABC News","CNN","WBUR","NPR")
MS<-c('WLBT', 'The Clarion-Ledger', 'WJTV', 'WAPT', 'Jackson Free Press', 'Mississippi Today')

news_data<-news_data%>% 
  mutate(Media_Type=case_when(
    Media %in% MS ~"MS",
    Media %in% non_MS ~ "non-MS"
    
  ))

news_data<-news_data%>%
  mutate(Week=case_when(
    New_Date=="2021-02-08"~0,
    New_Date=="2021-02-15"~1,
    New_Date=="2021-02-22"~2,
    New_Date=="2021-03-01"~3,
    New_Date=="2021-03-08"~4,
    New_Date=="2021-03-15"~5,
    New_Date=="2021-03-22"~6,
    New_Date=="2021-03-29"~7,
    New_Date=="2021-04-05"~8,
    New_Date=="2021-04-12"~9,
    New_Date=="2021-04-19"~10,
    New_Date=="2021-04-26"~11,
    New_Date=="2021-05-03"~12
    
  ))

# news_data<-news_data%>%
#   mutate(Week=case_when(
#     New_Date=="2021-02-08"~"Week0",
#     New_Date=="2021-02-15"~"Week1",
#     New_Date=="2021-02-22"~"Week2",
#     New_Date=="2021-03-01"~"Week3",
#     New_Date=="2021-03-08"~"Week4",
#     New_Date=="2021-03-15"~"Week5",
#     New_Date=="2021-03-22"~"Week6",
#     New_Date=="2021-03-29"~"Week7",
#     New_Date=="2021-04-05"~"Week8",
#     New_Date=="2021-04-12"~"Week9",
#     New_Date=="2021-04-19"~"Week10",
#     New_Date=="2021-04-26"~"Week11",
#     New_Date=="2021-05-03"~"Week12"
#       
#   ))

#Bar graph faceted with Media
# news_data%>%
#   ggplot(mapping=aes(x=Media,y=Title,fill=Media))+
#   geom_col()+
#   facet_wrap(~New_Date)+
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
#   
  # +theme(legend.position = "none")  


#Line graph for top 10 Media source of JWC

news_data_mediaType<-news_data%>%
  group_by(Media_Type,Week)%>%
  summarise(count=sum(Title))

news_data_mediaType%>%
  ggplot(aes(x=Week, y=count, group=Media_Type, color=Media_Type))+
  geom_line()+
  labs(title="Line graph of articles counts of Top 10 news media source by Media type")

str(news_data)

#Plotting tweet-location map
map_data<-read_csv("mapdata.csv")

map_data

#create base map of the globe(may be try just map of the usa with states)
world_basemap<-ggplot()+
  borders("world",colour="gray85",fill="gray80")+
  theme_map()

world_basemap+
  geom_point(data = map_data, aes(x = long, y = lat),
             colour = 'purple', alpha = .5) +
  scale_size_continuous(range = c(1, 8),
                        breaks = c(250, 500, 750, 1000)) +
  labs(title = "Tweet Locations of Jackson Water Crisis")


#Leaflet map
# plot points on top of a leaflet basemap

site_locations <- leaflet(map_data) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~long, lat = ~lat, popup = ~Text,
                   radius = 3, stroke = FALSE)

site_locations

str(map_data)

#Summarizing by day

tweet_locations_grp<-map_data %>%
  mutate(day=day(Date),
         long_round=round(long,2),
         lat_round=round(lat,2))%>%
  group_by(day, long_round, lat_round)%>%
  summarise(total_count=n())

grouped_tweet_map <- world_basemap + geom_point(data = tweet_locations_grp,
                                                aes(long_round, lat_round, frame = day, size = total_count),
                                                color = "purple", alpha = .5) + coord_fixed() +
  labs(title = "Twitter Activity of Jackson Water Crisis")

grouped_tweet_map

#Location Animation
# created animated gif file
#gganimate(grouped_tweet_map)

# save the animation to a new file
gganimate::gg_animate(grouped_tweet_map)

gganimate(grouped_tweet_map)


gganimate_save(grouped_tweet_map,
               filename = "data/tweets.gif",
               fps = 1, loop = 0,
               width = 1280,
               height = 1024)

grouped_tweet_map+
  transition_states(year)

#may be do it from  the ggplot
