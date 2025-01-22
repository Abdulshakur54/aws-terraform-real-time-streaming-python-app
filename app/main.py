import time
from WeatherAPI import WeatherAPIToS3
import sys
region = 'eu-west-1'
bucket_name = sys.argv[1]
apiToS3Obj = WeatherAPIToS3(bucket_name=bucket_name, region=region)
cities = ['New York', 'London', 'Lagos']

def main():
    for city in cities:
        weather_data = apiToS3Obj.get_weather(city)
        apiToS3Obj.insert_to_s3(weather_data, city) 



if __name__ == '__main__':
    while True: #starting an infinite loop
        main()
        time.sleep(30) # get weather data every 30 seconds

