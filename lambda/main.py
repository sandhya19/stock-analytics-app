import json
import requests
import os
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('StockData')

def lambda_handler(event, context):
    symbol = event.get("queryStringParameters", {}).get("symbol", "AAPL")
    # symbol = event.get("symbol", "AAPL")
    api_key = os.environ.get("ALPHA_VANTAGE_API_KEY")

    url = f"https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol={symbol}&interval=5min&apikey={api_key}"
    response = requests.get(url)
    data = response.json()

    try:
        price = list(data["Time Series (5min)"].values())[0]["1. open"]
        timestamp = list(data["Time Series (5min)"].keys())[0]

        table.put_item(Item={
            "symbol": symbol,
            "timestamp": timestamp,
            "price": price
        })

        return {
            "statusCode": 200,
            "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
            },
            "body": json.dumps({"symbol": symbol, "timestamp": timestamp, "price": price})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }