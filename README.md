# 📊 Stock Analytics — Cloud-Native Serverless Application on AWS

A fully serverless, secure, and scalable application that fetches real-time stock data using Alpha Vantage, stores it in DynamoDB, and displays it through a lightweight frontend hosted on AWS S3 and served via CloudFront with HTTPS. All infrastructure is managed using Terraform.

---

## 🎥 Live Demo

![Live Demo](demo/demo.gif)

---

## 🚀 Features

- 📈 Fetch real-time stock data from Alpha Vantage
- 🔁 Schedule data fetches every 5 minutes using EventBridge
- 💾 Store stock prices with timestamp in DynamoDB
- 🌐 Public REST API via API Gateway with CORS enabled
- 🔐 Secure, HTTPS frontend hosted on S3 + CloudFront
- 🧱 Infrastructure as Code using Terraform

---

## 🧰 Tech Stack

| Category         | Tools / Services                      |
|------------------|----------------------------------------|
| Cloud Provider   | AWS                                   |
| Compute          | AWS Lambda (Python)                   |
| API Gateway      | REST API with CORS                    |
| Data Storage     | AWS DynamoDB                          |
| Frontend Hosting | S3 static website + CloudFront CDN    |
| Infrastructure   | Terraform                             |
| Scheduling       | EventBridge (rate-based triggers)     |
| Dev Tools        | GitHub, VS Code, CloudWatch Logs      |

---

## 🗂️ Architecture Overview

S3 (static frontend) + CloudFront (CDN & HTTPS)
         ⬇
  User submits symbol → API Gateway (GET /fetch)
         ⬇
   Lambda fetches data → Alpha Vantage API
         ⬇
       Saves to DynamoDB


---

## ⚙️ Setup Instructions

## 1. Clone and Configure

```bash
git clone https://github.com/sandhya19/stock-analytics-app.git
cd stock-analytics-app
```

## 2. Configure Secrets
Create a file named terraform.tfvars with the following:

alpha_vantage_api_key = "your_alpha_vantage_api_key"

Ensure you also have AWS credentials configured.

## 3.Deploy with Terraform

terraform init
terraform apply -auto-approve

## Usage
Visit the CloudFront URL to access the frontend
Enter any stock symbol (e.g., AAPL, TSLA) and click Fetch
The backend Lambda will retrieve and store data, which can be extended for analytics

## 🔒 Security Considerations
CORS configured to allow browser access to API Gateway
No credentials exposed in frontend
HTTPS via CloudFront default certificate
Public read access limited only to frontend assets

## 📌 Learning Highlights

- ✅ Hands-on experience with AWS services
- ✅ Writing & deploying AWS Lambda in Python
- ✅ Using Terraform for declarative infrastructure
- ✅ Handling CORS and API integration
- ✅ Debugging CloudWatch logs effectively
- ✅ Creating a public-facing cloud-native app




