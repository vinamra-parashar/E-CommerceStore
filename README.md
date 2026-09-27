# 🛒 E-Commerce Microservices Application

A full-stack MERN e-commerce application built with **microservices architecture**, containerized with **Docker**, and deployed on **AWS EC2** using **Terraform** for infrastructure provisioning.

---

## 🏗️ Architecture Overview

```
                    ┌─────────────────────────────────────┐
                    │         AWS EC2 Instance             │
                    │  (Ubuntu 22.04 · t2.medium · VPC)   │
                    │                                      │
Internet ──► :80 ──►│  [Frontend - React + Nginx]         │
             :3001 ─►│  [User Service    - Node.js]        │
             :3002 ─►│  [Product Service - Node.js]        │
             :3003 ─►│  [Cart Service    - Node.js]        │
             :3004 ─►│  [Order Service   - Node.js]        │
                    └──────────────┬──────────────────────┘
                                   │
                          MongoDB Atlas (Cloud)
```

---

## 🔧 Technology Stack

| Layer | Technology |
|---|---|
| **Frontend** | React 18, React Router, Axios, React Query |
| **Backend** | Node.js, Express.js |
| **Database** | MongoDB Atlas (Mongoose ODM) |
| **Auth** | JWT (JSON Web Tokens) |
| **Containerization** | Docker (multi-stage builds for frontend) |
| **Container Registry** | Docker Hub |
| **IaC** | Terraform (AWS Provider ~> 5.0) |
| **Cloud** | AWS EC2, VPC, Subnet, Security Groups |
| **Web Server** | Nginx (serving React build) |

---

## 📦 Microservices

| Service | Port | Docker Image | Health Endpoint |
|---|---|---|---|
| User Service | `3001` | `YOUR_DOCKER_HUB_USERNAME/ecommerce-user-service:latest` | `GET /health` |
| Product Service | `3002` | `YOUR_DOCKER_HUB_USERNAME/ecommerce-product-service:latest` | `GET /health` |
| Cart Service | `3003` | `YOUR_DOCKER_HUB_USERNAME/ecommerce-cart-service:latest` | `GET /health` |
| Order Service | `3004` | `YOUR_DOCKER_HUB_USERNAME/ecommerce-order-service:latest` | `GET /health` |
| Frontend | `80` | `YOUR_DOCKER_HUB_USERNAME/ecommerce-frontend:latest` | `GET /health` |

### User Service (Port 3001)
- User registration and authentication
- JWT token generation and validation
- Profile management

**Endpoints:**
- `POST /api/auth/register` — Register a new user
- `POST /api/auth/login` — Authenticate and get JWT
- `GET /api/auth/me` — Get current user (auth required)
- `GET /api/users/profile` — Get user profile
- `PUT /api/users/profile` — Update user profile

### Product Service (Port 3002)
- Product catalog and category management
- Search and filtering with pagination

**Endpoints:**
- `GET /api/products` — List products (filter/paginate)
- `GET /api/products/:id` — Get a product
- `POST /api/products` — Create product (admin)
- `PUT /api/products/:id` — Update product (admin)
- `DELETE /api/products/:id` — Soft delete (admin)
- `GET /api/categories` — List categories
- `POST /api/categories` — Create category (admin)

### Cart Service (Port 3003)
- Shopping cart CRUD per user
- Integrates with Product Service for validation

**Endpoints:**
- `GET /api/cart/:userId` — Get user's cart
- `POST /api/cart/:userId/items` — Add item
- `PUT /api/cart/:userId/items/:productId` — Update item quantity
- `DELETE /api/cart/:userId/items/:productId` — Remove item
- `DELETE /api/cart/:userId` — Clear cart
- `POST /api/cart/:userId/validate` — Validate cart

### Order Service (Port 3004)
- Order creation, tracking and status management
- Payment processing simulation

**Endpoints:**
- `GET /api/orders/user/:userId` — Get user's orders
- `GET /api/orders/:id` — Get single order
- `POST /api/orders` — Create order
- `PUT /api/orders/:id/status` — Update status
- `DELETE /api/orders/:id` — Cancel order
- `POST /api/payments/process` — Process payment
- `POST /api/payments/refund` — Process refund

---

## 📁 Project Structure

```
E-CommerceStore/
├── backend/
│   ├── user-service/
│   │   ├── middleware/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── server.js
│   │   ├── Dockerfile          ← containerized
│   │   ├── .dockerignore
│   │   └── package.json
│   ├── product-service/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── server.js
│   │   ├── Dockerfile          ← containerized
│   │   ├── .dockerignore
│   │   └── package.json
│   ├── cart-service/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── server.js
│   │   ├── Dockerfile          ← containerized
│   │   ├── .dockerignore
│   │   └── package.json
│   └── order-service/
│       ├── models/
│       ├── routes/
│       ├── server.js
│       ├── Dockerfile          ← containerized
│       ├── .dockerignore
│       └── package.json
├── frontend/
│   ├── public/
│   ├── src/
│   │   ├── components/
│   │   ├── contexts/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── App.js
│   │   └── index.js
│   ├── Dockerfile              ← multi-stage (React → Nginx)
│   ├── .dockerignore
│   └── package.json
├── terraform/
│   ├── main.tf                 ← VPC, Subnet, IGW, SG, EC2
│   ├── variables.tf
│   ├── outputs.tf              ← public IP + service URLs
│   └── user_data.sh            ← Docker install + container run
├── .gitignore
└── README.md
```

---

## 🐳 Docker Setup

### Dockerfiles

Each backend service shares the same pattern:

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE <port>
CMD ["node", "server.js"]
```

The frontend uses a **multi-stage build** (React build → Nginx serve):

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Build & Push to Docker Hub

```bash
docker login

# Build all images
docker build -t YOUR_DOCKER_HUB_USERNAME/ecommerce-user-service:latest    backend/user-service/
docker build -t YOUR_DOCKER_HUB_USERNAME/ecommerce-product-service:latest backend/product-service/
docker build -t YOUR_DOCKER_HUB_USERNAME/ecommerce-cart-service:latest    backend/cart-service/
docker build -t YOUR_DOCKER_HUB_USERNAME/ecommerce-order-service:latest   backend/order-service/
docker build -t YOUR_DOCKER_HUB_USERNAME/ecommerce-frontend:latest        frontend/

# Push all images
docker push YOUR_DOCKER_HUB_USERNAME/ecommerce-user-service:latest
docker push YOUR_DOCKER_HUB_USERNAME/ecommerce-product-service:latest
docker push YOUR_DOCKER_HUB_USERNAME/ecommerce-cart-service:latest
docker push YOUR_DOCKER_HUB_USERNAME/ecommerce-order-service:latest
docker push YOUR_DOCKER_HUB_USERNAME/ecommerce-frontend:latest
```
<img width="1494" height="378" alt="image" src="https://github.com/user-attachments/assets/4d68c24d-439d-48c6-ab78-81eb2c5f43df" />
<img width="1409" height="457" alt="image" src="https://github.com/user-attachments/assets/d2412fd7-e3a5-433a-bdbd-c2bf5e562494" />
<img width="2848" height="1268" alt="image" src="https://github.com/user-attachments/assets/40695a02-51ce-40be-98ea-83f7fbac4bef" />

---

## ☁️ Infrastructure with Terraform

Terraform provisions the following AWS resources:

| Resource | Details |
|---|---|
| `aws_vpc` | `10.0.0.0/16`, DNS enabled |
| `aws_internet_gateway` | Attached to VPC |
| `aws_subnet` | Public, `10.0.1.0/24`, auto-assign public IP |
| `aws_route_table` | Routes `0.0.0.0/0` → IGW |
| `aws_security_group` | Inbound: 80, 3001–3004, 22 · Outbound: all |
| `aws_instance` | Ubuntu 22.04, `t2.medium`, 20GB gp3 |

### Required Variables

| Variable | Description |
|---|---|
| `key_pair_name` | Name of existing EC2 key pair |
| `dockerhub_username` | Docker Hub username |
| `mongodb_uri` | MongoDB Atlas connection string |
| `jwt_secret` | JWT signing secret |
| `aws_region` | AWS region (default: `ap-south-1`) |

### Deploy

```bash
# 1. Configure AWS credentials
aws configure

# 2. Create EC2 key pair (one-time)
aws ec2 create-key-pair \
  --key-name ecommerce-key \
  --query 'KeyMaterial' \
  --output text > ecommerce-key.pem
chmod 400 ecommerce-key.pem

# 3. Initialize Terraform
cd terraform/
terraform init

# 4. Validate configuration
terraform validate

# 5. Preview changes
terraform plan \
  -var="key_pair_name=ecommerce-key" \
  -var="dockerhub_username=<YOUR_DOCKER_HUB_USERNAME>" \
  -var="mongodb_uri=<YOUR_MONGO_URI>" \
  -var="jwt_secret=<YOUR_JWT_SECRET>"

# 6. Apply (deploy)
terraform apply \
  -var="key_pair_name=ecommerce-key" \
  -var="dockerhub_username=<YOUR_DOCKER_HUB_USERNAME>" \
  -var="mongodb_uri=<YOUR_MONGO_URI>" \
  -var="jwt_secret=<YOUR_JWT_SECRET>" \
  -auto-approve
```
<img width="1190" height="630" alt="image" src="https://github.com/user-attachments/assets/c56d4f09-fb48-4271-accf-ff6583576f1f" />

### Terraform Outputs

```
ec2_public_ip          = "xx.xx.xx.xx"
ec2_public_dns         = "ec2-xx-xx-xx-xx.ap-south-1.compute.amazonaws.com"
frontend_url           = "http://xx.xx.xx.xx"
user_service_health    = "http://xx.xx.xx.xx:3001/health"
product_service_health = "http://xx.xx.xx.xx:3002/health"
cart_service_health    = "http://xx.xx.xx.xx:3003/health"
order_service_health   = "http://xx.xx.xx.xx:3004/health"
ssh_command            = "ssh -i ecommerce-key.pem ubuntu@xx.xx.xx.xx"
```

### Destroy Infrastructure

```bash
terraform destroy \
  -var="key_pair_name=ecommerce-key" \
  -var="dockerhub_username=<YOUR_DOCKER_HUB_USERNAME>" \
  -var="mongodb_uri=<YOUR_MONGO_URI>" \
  -var="jwt_secret=<YOUR_JWT_SECRET>" \
  -auto-approve
```

---

## 🚀 Local Development

### Prerequisites
- Node.js 18+
- MongoDB (local or Atlas)
- npm

### Environment Variables

**`backend/user-service/.env`**
```env
PORT=3001
MONGODB_URI=mongodb://localhost:27017/ecommerce_users
JWT_SECRET=your-jwt-secret-key
```

**`backend/product-service/.env`**
```env
PORT=3002
MONGODB_URI=mongodb://localhost:27017/ecommerce_products
```

**`backend/cart-service/.env`**
```env
PORT=3003
MONGODB_URI=mongodb://localhost:27017/ecommerce_carts
PRODUCT_SERVICE_URL=http://localhost:3002
```

**`backend/order-service/.env`**
```env
PORT=3004
MONGODB_URI=mongodb://localhost:27017/ecommerce_orders
CART_SERVICE_URL=http://localhost:3003
PRODUCT_SERVICE_URL=http://localhost:3002
USER_SERVICE_URL=http://localhost:3001
```

**`frontend/.env`**
```env
REACT_APP_USER_SERVICE_URL=http://localhost:3001
REACT_APP_PRODUCT_SERVICE_URL=http://localhost:3002
REACT_APP_CART_SERVICE_URL=http://localhost:3003
REACT_APP_ORDER_SERVICE_URL=http://localhost:3004
```

### Run Services

```bash
# Install dependencies
cd backend/user-service    && npm install && cd ../..
cd backend/product-service && npm install && cd ../..
cd backend/cart-service    && npm install && cd ../..
cd backend/order-service   && npm install && cd ../..
cd frontend                && npm install && cd ..

# Start all services (each in a separate terminal)
cd backend/user-service    && npm start   # → http://localhost:3001
cd backend/product-service && npm start   # → http://localhost:3002
cd backend/cart-service    && npm start   # → http://localhost:3003
cd backend/order-service   && npm start   # → http://localhost:3004
cd frontend                && npm start   # → http://localhost:3000
```
<img width="1408" height="939" alt="image" src="https://github.com/user-attachments/assets/51095754-7b23-460a-a5d3-756d6f940b36" />

### Health Checks

```bash
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health
curl http://localhost:3004/health
```

---

## 🔍 Verify Deployment (Post AWS Deploy)

```bash
EC2_IP="<your-ec2-public-ip>"

# Check all services
curl http://$EC2_IP/                  # Frontend
curl http://$EC2_IP:3001/health       # User Service
curl http://$EC2_IP:3002/health       # Product Service
curl http://$EC2_IP:3003/health       # Cart Service
curl http://$EC2_IP:3004/health       # Order Service

# SSH in and verify containers
ssh -i ecommerce-key.pem ubuntu@$EC2_IP
docker ps                              # All 5 containers should be UP
```

---

## 📝 License

This project is licensed under the MIT License.
