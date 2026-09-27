#!/bin/bash
set -e

# ---- System Update & Docker Install ----
apt-get update -y
apt-get install -y docker.io curl
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# ---- Pull all Docker images ----
docker pull ${dockerhub_username}/ecommerce-user-service:latest
docker pull ${dockerhub_username}/ecommerce-product-service:latest
docker pull ${dockerhub_username}/ecommerce-cart-service:latest
docker pull ${dockerhub_username}/ecommerce-order-service:latest
docker pull ${dockerhub_username}/ecommerce-frontend:latest

# ---- Run User Service (port 3001) ----
docker run -d --restart=always \
  -p 3001:3001 \
  -e PORT=3001 \
  -e MONGODB_URI="${mongodb_uri}" \
  -e JWT_SECRET="${jwt_secret}" \
  --name user-service \
  ${dockerhub_username}/ecommerce-user-service:latest

# ---- Run Product Service (port 3002) ----
docker run -d --restart=always \
  -p 3002:3002 \
  -e PORT=3002 \
  -e MONGODB_URI="${mongodb_uri}" \
  --name product-service \
  ${dockerhub_username}/ecommerce-product-service:latest

# ---- Run Cart Service (port 3003) ----
docker run -d --restart=always \
  -p 3003:3003 \
  -e PORT=3003 \
  -e MONGODB_URI="${mongodb_uri}" \
  --name cart-service \
  ${dockerhub_username}/ecommerce-cart-service:latest

# ---- Run Order Service (port 3004) ----
docker run -d --restart=always \
  -p 3004:3004 \
  -e PORT=3004 \
  -e MONGODB_URI="${mongodb_uri}" \
  --name order-service \
  ${dockerhub_username}/ecommerce-order-service:latest

# ---- Run Frontend (port 80) ----
docker run -d --restart=always \
  -p 80:80 \
  --name frontend \
  ${dockerhub_username}/ecommerce-frontend:latest

echo "✅ All containers started successfully!"
docker ps
