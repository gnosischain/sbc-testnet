FROM node:14-alpine

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install

COPY . .

ENTRYPOINT ["node"]

CMD ["./src/deploy.js"]
