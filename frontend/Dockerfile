# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage with nginx
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html

# Custom nginx config to support React Router
RUN cat > /etc/nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /health {
        return 200 '{"service":"Frontend","status":"OK"}';
        add_header Content-Type application/json;
    }
}
EOF

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
