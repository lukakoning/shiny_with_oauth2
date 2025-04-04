FROM rocker/shiny:4.4.2

# See: https://oauth2-proxy.github.io/oauth2-proxy/configuration/overview
# ENV OAUTH2_CLIENT_ID=""
# ENV OAUTH2_CLIENT_SECRET=""
# ENV OAUTH2_COOKIE_SECRET=""

# Install Nginx & system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install OAuth2 Proxy
ENV OAUTH2_PROXY_VERSION=7.6.0
RUN wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v${OAUTH2_PROXY_VERSION}/oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-amd64.tar.gz && \
    tar -xvf oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-amd64.tar.gz && \
    mv oauth2-proxy-v${OAUTH2_PROXY_VERSION}.linux-amd64/oauth2-proxy /usr/local/bin/oauth2-proxy && \
    rm -rf oauth2-proxy*

# Copy Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy Shiny Server config
COPY shiny-customized.config /etc/shiny-server/shiny-server.conf
# Copy modified files to enable passing all headers
COPY /shiny-all-headers/sockjs.js /opt/shiny-server/lib/proxy/sockjs.js
COPY /shiny-all-headers/transport.js /opt/shiny-server/node_modules/sockjs/lib/transport.js

# Install R packages via renv (unused)
# RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org')"
# COPY renv.lock renv.lock
# ENV RENV_PATHS_LIBRARY renv/library
# RUN R -e "renv::restore()"

# Copy Shiny app
WORKDIR /srv/shiny-server
COPY app.R app.R
RUN chown -R shiny:shiny /srv/shiny-server

# Start everything
CMD /bin/bash -c "\
    sudo -u shiny shiny-server & \
    echo 'Waiting for Shiny to come up...' ; \
    while ! nc -z localhost 3838; do :; done; \
    echo 'Starting OAuth2 Proxy...' ; \
    oauth2-proxy \
      --provider=\"github\" \
      --client-id=\"${OAUTH2_CLIENT_ID}\" \
      --client-secret=\"${OAUTH2_CLIENT_SECRET}\" \
      --email-domain=\"*\" \
      --cookie-secret=\"${OAUTH2_COOKIE_SECRET}\" \
      --cookie-secure=true \
      --cookie-samesite=\"lax\" \
      --upstream=\"http://localhost:3838\" \
      --http-address=\"127.0.0.1:4180\" \
      --redirect-url=\"http://localhost:8080/oauth2/callback\" \
      --set-authorization-header=true \
      --set-xauthrequest=true \
      --pass-access-token=true \
      --pass-user-headers=true \
      --pass-authorization-header=true & \
    echo 'Starting NGINX...' ; \
    exec nginx -g 'daemon off;'"

# Expose NGINX port
EXPOSE 8080
