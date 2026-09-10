FROM node:14.0-alpine3.10

WORKDIR /usr/src/app

RUN npm install pm2 -g

COPY . .

RUN npm install

EXPOSE 3000

CMD [ "pm2-runtime", "start", "ecosystem.config.js" ]

