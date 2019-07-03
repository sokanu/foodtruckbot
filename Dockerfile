FROM node:10-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8080

# Entrypoint permissions
RUN chmod +x /app/docker-entrypoint.sh