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
# news_data%>%
#   ggplot(mapping=aes(x=Media,y=Title,fill=Media))+
#   geom_col()+
#   facet_wrap(~New_Date)+
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
#   
  # +theme(legend.position = "none")  

news_data%>%
  ggplot(aes(x=New_Date, y=Title, group=Media, color=Media))+
  geom_line()+
  geom_point()

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
