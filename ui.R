
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fillPage(
  fillRow(
    mainPanel(
      tabsetPanel(
        tabPanel("Ввод",
                 textInput("name", "Трата"),
                 selectInput("group", "Группа", c("Группа" = "")),
                 numericInput("amount", "Сумма", 100),
                 dateInput("date", "Дата", value = Sys.Date(), language = "ru"),
                 actionButton("submit", "Добавить"),
                 div(
                   "Баланс: ",
                   textOutput("balance", inline = TRUE)
                 )
        ),
        tabPanel("Прогноз трат", span("")),
        id = "panel",
        type = "pills"
      )
    )
  )
))
