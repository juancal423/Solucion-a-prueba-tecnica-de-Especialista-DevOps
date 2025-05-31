FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install --only=production

COPY app ./app

EXPOSE 3000
CMD ["npm", "start"]