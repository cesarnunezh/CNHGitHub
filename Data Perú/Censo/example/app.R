library(shiny)
library(shinydashboard)
library(highcharter)


valueBoxSpark <- function(value, title, sparkobj = NULL, subtitle, info = NULL, 
                          icon = NULL, color = "aqua", width = 4, href = NULL){
  
  shinydashboard:::validateColor(color)
  
  if (!is.null(icon))
    shinydashboard:::tagAssert(icon, type = "i")
  
  info_icon <- tags$small(
    tags$i(
      class = "fa fa-info-circle fa-lg",
      title = info,
      `data-toggle` = "tooltip",
      style = "color: rgba(255, 255, 255, 0.75);"
    ),
    # bs3 pull-right 
    # bs4 float-right
    class = "pull-right float-right"
  )
  
  boxContent <- div(
    class = paste0("small-box bg-", color),
    div(
      class = "inner",
      tags$small(title),
      if (!is.null(sparkobj)) info_icon,
      h3(value),
      if (!is.null(sparkobj)) sparkobj,
      p(subtitle)
    ),
    # bs3 icon-large
    # bs4 icon
    if (!is.null(icon)) div(class = "icon-large icon", icon, style = "z-index; 0")
  )
  
  if (!is.null(href)) 
    boxContent <- a(href = href, boxContent)
  
  div(
    class = if (!is.null(width)) paste0("col-sm-", width), 
    boxContent
  )
}

hc <- hchart(df, "area", hcaes(x, y), name = "lines of code")  %>% 
  hc_size(height = 100) %>% 
  hc_credits(enabled = FALSE) %>% 
  hc_add_theme(hc_theme_sparkline_vb()) 

hc2 <- hchart(df, "line", hcaes(x, y), name = "Distance")  %>% 
  hc_size(height = 100) %>% 
  hc_credits(enabled = FALSE) %>% 
  hc_add_theme(hc_theme_sparkline_vb()) 

hc3 <- hchart(df, "column", hcaes(x, y), name = "Daily amount")  %>% 
  hc_size(height = 100) %>% 
  hc_credits(enabled = FALSE) %>% 
  hc_add_theme(hc_theme_sparkline_vb()) 

vb <- valueBoxSpark(
  value = "1,345",
  title = toupper("Lines of code written"),
  sparkobj = hc,
  subtitle = tagList(HTML("&uarr;"), "25% Since last day"),
  info = "This is the lines of code I've written in the past 20 days! That's a lot, right?",
  icon = icon("code"),
  width = 4,
  color = "teal",
  href = NULL
)

vb2 <- valueBoxSpark(
  value = "1,345 KM",
  title = toupper("Distance Traveled"),
  sparkobj = hc2,
  subtitle = tagList(HTML("&uarr;"), "25% Since last month"),
  info = "This is the lines of code I've written in the past 20 days! That's a lot, right?",
  icon = icon("plane"),
  width = 4,
  color = "red",
  href = NULL
)

vb3 <- valueBoxSpark(
  value = "1,3 Hrs.",
  title = toupper("Thinking time"),
  sparkobj = hc3,
  subtitle = tagList(HTML("&uarr;"), "5% Since last year"),
  info = "This is the lines of code I've written in the past 20 days! That's a lot, right?",
  icon = icon("hourglass-half"),
  width = 4,
  color = "yellow",
  href = NULL
)



ui <- dashboardPage(
  dashboardHeader(),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      valueBoxOutput("vbox"),
      valueBoxOutput("vbox2"),
      valueBoxOutput("vbox3")
    )
  )
)

server <- function(input, output) {
  output$vbox <- renderValueBox(vb)
  output$vbox2 <- renderValueBox(vb2)
  output$vbox3 <- renderValueBox(vb3)
}

shiny::shinyApp(ui, server, options = list(launch.browser = .rs.invokeShinyPaneViewer))


