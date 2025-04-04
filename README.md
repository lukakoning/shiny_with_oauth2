# Shiny app behind OAuth2 Proxy

This repository shows an (experimental) example configuration for hosting and securing a Shiny application with authentication, using Docker, [Shiny Server](https://github.com/rstudio/shiny-server), and [OAuth2 Proxy](https://github.com/oauth2-proxy/oauth2-proxy). A GitHub OAuth app is used for demonstration purposes (but any other OAuth app may be used, e.g., Microsfot Entra ID, Google, Keycloak, etc.).

'Dockerfile' defines and builds the container for this purpose. 'app.R' defines a basic Shiny app which displays some information about the authenticated user.

Because the open-source version of Shiny Server by default does not pass on all headers, two files need to be modified ([see blog by Marian Caikovski on Medium](https://marian-caikovski.medium.com/retrieving-all-request-headers-in-shiny-web-applications-dc07b79c4a7f), or on [archive.is](https://archive.is/F6axd)). This allows the Shiny app to read headers which contain information about the authenticated user.

## Usage

To run, build the Docker container and run it with the relevant environment variables set (OAUTH2_CLIENT_ID, OAUTH2_CLIENT_SECRET, OAUTH2_COOKIE_SECRET). (Make a GitHub OAuth app at <https://github.com/settings/developers>; see [OAuth2 Proxy documentation](https://oauth2-proxy.github.io/oauth2-proxy/configuration/overview#generating-a-cookie-secret) for generating a Cookie secret.) Connect to the Nginx port (8080). You will be prompted to login via GitHub, after which you will be granted access to the app. You may impose restrictions to who can access the app via OAuth2 Proxy configuration or in the Shiny app itself (using the headers about the authenticated user).
