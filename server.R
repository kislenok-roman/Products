
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(googlesheets)
library(dplyr)
library(readr)

shinyServer(function(input, output, session) {
  observe({
    sheet <- gs_key("1fVjg64j1l6ns12APBsqf2f_6NFMttFiU1SQmsX35HJY", verbose = FALSE)
    g1 <- gs_read_csv(sheet, "Группы", verbose = FALSE)
    groups <- unique(c("Телефоны", "Развлечения", "Обед работа", "Кредитка", "Ипотека", "Еда домой", "Коммуналка",
                "Девочки", "Машина", "Ремонт", "Хозтовары", "Лекарства", "Доход", "Другое", unlist(g1)))
    updateSelectInput(session, "group",
                      choices = groups
    )
  })

  output$balance <- renderText({
    sheet <- gs_key("1fVjg64j1l6ns12APBsqf2f_6NFMttFiU1SQmsX35HJY", verbose = FALSE)
    unlist(gs_read_csv(sheet, "Баланс", verbose = FALSE, col_types = cols(`Текущий долг` = col_character()))[, "Текущий долг"])
  })

  observeEvent(input$submit, {
    sheet <- gs_key("1fVjg64j1l6ns12APBsqf2f_6NFMttFiU1SQmsX35HJY", verbose = FALSE)
    gs_add_row(sheet, ws = "Список трат", input = c(input$name, input$group, sub("[.]", ",", input$amount), as.character(input$date), 1), verbose = FALSE)

  })
})
