FROM node:10-alpine
RUN apk update && apk add wget git jq bash && rm -rf /var/cache/apk/*

WORKDIR /usr/src/gotbot
COPY *.json ./
COPY client client
COPY lib lib
COPY test test
COPY *.ts ./

COPY run ./
COPY gotcron ./
COPY gulpfile.js ./
COPY .gitignore ./

RUN mkdir logs && mkdir data && mkdir client/stt.wiki

RUN chown -R node:node .

RUN chmod -R 777 data

VOLUME /usr/src/gotbot/data

USER node

EXPOSE 3030

RUN npm install
RUN npm test

CMD ./run
