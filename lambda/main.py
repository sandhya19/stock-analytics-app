import json
import requests
import os

def lambda_handler(event, context):
    symbol = event.get("symbol", "AAPL")
    api_key = os.environ.get("ALPHA_VANTAGE_API_KEY")
    url = f"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol={symbol}&interval=5min&apikey={api_key}"
    response = requests.get(url)
    return {
        "statusCode": 200,
        "body": json.dumps(response.json())
    }

