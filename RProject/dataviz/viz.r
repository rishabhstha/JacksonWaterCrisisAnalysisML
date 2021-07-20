library(tidyverse)


data<-read_csv("bargraph.csv")


data<-data%>%filter(Media %in% c('WLBT', 'The Clarion-Ledger', 'WJTV', 'WAPT', 'Jackson Free Press', 'Mississippi Today', 'ABC News', 'CNN', 'WBUR', 'NPR'))

data%>%
  ggplot(mapping=aes(x=Media,y=Title,fill=Media))+
  geom_col()+
  facet_wrap(~New_Date)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  # +theme(legend.position = "none")  
