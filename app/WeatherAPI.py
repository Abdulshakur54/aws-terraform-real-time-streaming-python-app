import requests
import boto3
from botocore.exceptions import ClientError
import json
import pendulum


class WeatherAPIToS3:
    """
    Class to fetch weather data from OpenWeatherMap API and store it in S3 bucket
    """
    def __init__(self,bucket_name: str, region: str):
        self.bucket_name = bucket_name
        self.region = region
        self.s3_client = boto3.client('s3', region_name=region)
        self.api_key = self.__getWeatherAPIKey()


    def __getWeatherAPIKey(self)-> str:
        """Get the API key for OpenWeatherMap from AWS Secrets Manager"""
        session = boto3.session.Session()
        client = session.client(service_name='secretsmanager', region_name=self.region)
        try:
            get_secret_value_response = client.get_secret_value(SecretId="OpenWeatherAppSecret")
        except ClientError as e:
            print(f'Error while fetching secret: {e}')
            return None
        secret =  get_secret_value_response['SecretString']
        return json.loads(secret)['OpenWeatherAPIKey']


    def get_weather(self, city: str) -> dict:
        """Get weather data for a city  from OpenWeatherMap API"""
        url = 'http://api.openweathermap.org/data/2.5/weather'
        params = {
            'q': city,
            'appid': self.api_key,
            'units': 'imperial'
        }
        try:
            response = requests.get(url, params=params)
            response.raise_for_status()
            print(f'Weather data fetched for {city}')
            return response.json()
        except requests.RequestException as e:
            print(f'Error while fetching data from weather API: {e}')
            return None
        
    def insert_to_s3(self, weather_data: dict, city: str) -> None:
        """Insert weather data for a city into S3 bucket"""
        weather_data = json.dumps(weather_data)
        key = f'weather/{city}/{pendulum.now("Africa/Lagos").strftime("%Y%m%d-%H:%M:%S")}.json'
        try:
            self.s3_client.put_object(Bucket=self.bucket_name, Key=key, Body=weather_data, ContentType='application/json')
            print(f'Weather data inserted to s3 for {city}')
        except Exception as e:
            print(f'Error while inserting weather data to s3: {e}')
    




        
