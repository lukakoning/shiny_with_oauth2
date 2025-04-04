library(shiny)

ui <- fluidPage(
  titlePanel("Shiny App behind OAuth2 Proxy"),
  br(),
  verbatimTextOutput("user_info"),
  shiny::verbatimTextOutput("request")
)

server <- function(input, output, session) {
  output$user_info <- renderText({
    req <- session$request
    user <- req$HTTP_X_USER
    email <- req$HTTP_X_EMAIL

    if (!is.null(email) & !is.null(user)) {
      paste0("You are logged in as: ", user, " (", email, ")")
    } else {
      "User info not available (are you running this app behind Nginx & OAuth2 Proxy?)"
    }
  })

  # Show full request object, including all headers
  output$request <- renderPrint({
    req <- session$request
    as.list.environment(req, all.names = TRUE)
  })
}

shinyApp(ui, server)
