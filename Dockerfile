FROM node:10-alpine
LABEL Name="Node.js Demo App" Version=3.8.1
ENV NODE_ENV production
WORKDIR /app 

# For efficient layer caching with NPM, this *really* speeds things up
COPY package.json .

# NPM install for the server packages
RUN npm install --production --silent

# SSH server support for Azure App Service
RUN apk update \ 
  && apk add openssh \
  && echo "root:Docker!" | chpasswd
RUN ssh-keygen -A
ADD https://raw.githubusercontent.com/Azure-App-Service/node/master/10.14/sshd_config /etc/ssh/

# NPM is done, now copy in the the whole project to the workdir
COPY . .

# Fixes issues with build in Dockerhub
RUN chmod a+x ./dockerentry.sh

# Port 2222 is custom port for SSH, port 3000 for Express 
EXPOSE 2222 3000
ENTRYPOINT [ "./dockerentry.sh" ]