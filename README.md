# 📊 Stock Analytics — Cloud-Native Serverless Application on AWS

A fully serverless, secure, and scalable application that fetches real-time stock data using Alpha Vantage, stores it in DynamoDB, and displays it through a lightweight frontend hosted on AWS S3 and served via CloudFront with HTTPS. All infrastructure is managed using Terraform.

---

## 🌐 Live Demo

🔗 **[Try the App](https://<your-cloudfront-distribution>.cloudfront.net)**  
_(Replace this with your actual CloudFront URL)_

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
[ S3 + CloudFront ] ⬇ Static HTML/JS ⬇ [ API Gateway ] ⬇ [ AWS Lambda ] ⬇ [ DynamoDB ] ⬇ [ Alpha Vantage API ]


