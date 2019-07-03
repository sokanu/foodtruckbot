FROM node:10-alpine

WORKDIR /app

COPY . /app
COPY ./package*.json /app/

RUN npm install

EXPOSE 8080

# Entrypoint permissions
RUN chmod +x /app/docker-entrypoint.sh

CMD ["npm", "start"]