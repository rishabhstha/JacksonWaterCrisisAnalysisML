import tweepy
import folium
from geopy.exc import GeocoderTimedOut
from geopy.geocoders import Nominatim
import pandas as pd
import matplotlib.pyplot as plt
#import cartopy.crs as ccrs
from matplotlib.patches import Circle
from geopy.exc import GeocoderTimedOut

df_JWC = pd.read_csv("JWC_alltweets.csv")

locs = df_JWC['User Location'].value_counts()
locs = locs[locs >= 10]

mapping = {'Jackson': 'Jackson, MS', 'Jackson, Mississippi': 'Jackson, MS', 'Mississippi, USA': 'Jackson, MS', 'Mississippi': 'Jackson, MS', 'United States': 'USA', 'Los Angeles': 'Los Angeles, CA', 'New York City': 'New York, NY', 'NYC': 'New York, NY', 'New York': 'New York, NY', 'New York, USA': 'New York, NY', 'Mississippi State, MS': 'Jackson, MS',
           'Hattiesburg, Mississippi': 'Hattiesburg, MS'}

df_JWC['User Location'] = df_JWC['User Location'].apply(
    lambda x: mapping[x] if x in mapping.keys() else x)


geolocator = Nominatim(user_agent='twitter-analysis-cl')
# note that user_agent is a random name
locs = list(locs.index)  # keep only the city names

geolocated = list(map(lambda x: [x, geolocator.geocode(
    x)[1] if geolocator.geocode(x) else None], locs))

geolocated = pd.DataFrame(geolocated)
geolocated.columns = ['locat', 'latlong']
geolocated['lat'] = geolocated.latlong.apply(lambda x: x[0])
geolocated['long'] = geolocated.latlong.apply(lambda x: x[1])
geolocated.drop('latlong', axis=1, inplace=True)

mapdata = pd.merge(df_JWC, geolocated, how='inner',
                   left_on='User Location', right_on='locat')
locations = mapdata.groupby(by=['locat', 'lat', 'long']).count()
print(mapdata)

location_data = []
# for tweet in tweepy.Cursor(api.search, q=search).items(500):
#     if hasattr(tweet, 'user') and hasattr(tweet.user, 'screen_name') and hasattr(tweet.user, 'location'):
#         if tweet.user.location:
location_data.append((mapdata.Username, mapdata.locat))
print(type(location_data))

map = folium.Map(location=[0, 0], zoom_start=2)
#folium.Marker([location.latitude, location.longitude], popup=name).add_to(map)


mapdata.apply(lambda row: folium.Marker(location=[row["lat"],
                                                  row["long"]], popup=row['User Location']).add_to(map),
              axis=1)
map.save("index1.html")
# plt.style.use('fivethirtyeight')
# plt.rcParams.update({'font.size': 20})
# plt.rcParams['figure.figsize'] = (20, 10)


# ax = plt.axes(projection=ccrs.PlateCarree())
# ax.stock_img()
# # plot individual locations
# ax.plot(mapdata.lon, mapdata.lat, 'ro', transform=ccrs.PlateCarree())
# # add coastlines for reference
# ax.coastlines(resolution='50m')
# ax.set_global()
# ax.set_extent([20, -20, 45, 60])


# def get_radius(freq):
#     if freq < 50:
#         return 0.5
#     elif freq < 200:
#         return 1.2
#     elif freq < 1000:
#         return 1.8


# # plot count of tweets per location
# for i, x in locations.iteritems():
#     ax.add_patch(Circle(xy=[i[2], i[1]], radius=get_radius(
#         x), color='blue', alpha=0.6, transform=ccrs.PlateCarree()))
# plt.show()


def get_twitter_api():
    # personal details
    consumer_key = "P5i8oS0DWMlplkEPWHewdcvnZ"
    consumer_secret = "opXG0LpwkrMCPjogMdTikFXWbbvI2tnKFglG1YOc1BQj04Uvan"
    access_token = "4091794879-nfBkiutGX2qkiVbETwsxOXENrk4ALrqV8keqSG4"
    access_token_secret = "bZDq7LGETyqILIogC4IOSDMkaQKjYdc3wSEBJ3r2NgZsJ"

    # authentication of consumer key and secret
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)

    # authentication of access token and secret
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth, wait_on_rate_limit=True,
                     wait_on_rate_limit_notify=True)
    return api


def get_twitter_location(search):
    api = get_twitter_api()

    count = 0
    for tweet in tweepy.Cursor(api.search, q=search).items(500):
        if hasattr(tweet, 'coordinates') and tweet.coordinates is not None:
            count += 1
            print("Coordinates", tweet.coordinates)
        if hasattr(tweet, 'location') and tweet.location is not None:
            count += 1
            print("Coordinates", tweet.location)
    print(count)


get_twitter_location("#100DaysOfCode")


def get_tweets(search):
    api = get_twitter_api()

    location_data = []
    for tweet in tweepy.Cursor(api.search, q=search).items(500):
        if hasattr(tweet, 'user') and hasattr(tweet.user, 'screen_name') and hasattr(tweet.user, 'location'):
            if tweet.user.location:
                location_data.append(
                    (tweet.user.screen_name, tweet.user.location))
    return location_data


def put_markers(map, data):
    geo_locator = Nominatim(user_agent="LearnPython")

    for (name, location) in data:
        if location:
            try:
                location = geo_locator.geocode(location)
            except GeocoderTimedOut:
                continue
            if location:
                folium.Marker(
                    [location.latitude, location.longitude], popup=name).add_to(map)


def get_newtweets(df_JWC):

    locs = df_JWC['User Location'].value_counts()
    locs = locs[locs >= 10]

    mapping = {'Jackson': 'Jackson, MS', 'Jackson, Mississippi': 'Jackson, MS', 'Mississippi, USA': 'Jackson, MS', 'Mississippi': 'Jackson, MS', 'United States': 'USA', 'Los Angeles': 'Los Angeles, CA', 'New York City': 'New York, NY', 'NYC': 'New York, NY', 'New York': 'New York, NY', 'New York, USA': 'New York, NY', 'Mississippi State, MS': 'Jackson, MS',
               'Hattiesburg, Mississippi': 'Hattiesburg, MS'}

    df_JWC['User Location'] = df_JWC['User Location'].apply(
        lambda x: mapping[x] if x in mapping.keys() else x)

    geolocator = Nominatim(user_agent='twitter-analysis-cl')
    # note that user_agent is a random name
    locs = list(locs.index)  # keep only the city names

    geolocated = list(map(lambda x: [x, geolocator.geocode(
        x)[1] if geolocator.geocode(x) else None], locs))

    geolocated = pd.DataFrame(geolocated)
    geolocated.columns = ['locat', 'latlong']
    geolocated['lat'] = geolocated.latlong.apply(lambda x: x[0])
    geolocated['long'] = geolocated.latlong.apply(lambda x: x[1])
    geolocated.drop('latlong', axis=1, inplace=True)

    mapdata = pd.merge(df_JWC, geolocated, how='inner',
                       left_on='User Location', right_on='locat')
    locations = mapdata.groupby(by=['locat', 'lat', 'long']).count()

    location_data = []
    # for tweet in tweepy.Cursor(api.search, q=search).items(500):
    #     if hasattr(tweet, 'user') and hasattr(tweet.user, 'screen_name') and hasattr(tweet.user, 'location'):
    #         if tweet.user.location:
    location_data.append((mapdata.Username, mapdata.locat))
    return location_data


if __name__ == "__main__":
    map = folium.Map(location=[0, 0], zoom_start=2)
    # location_data = get_tweets("#100DaysOfCode")
    #location_data = get_newtweets(df_JWC)
   # print(location_data)
    # put_markers(map, location_data)
    # map.save("index1.html")
