FROM node:10

RUN apt-get update -y
RUN apt-get install build-essential -y
RUN apt-get install jq -y
RUN apt-get install python-dev -y
RUN apt-get install python-pip -y
RUN pip2 install awscli

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 8080

# Entrypoint permissions
RUN chmod +x /app/docker-entrypoint.sh