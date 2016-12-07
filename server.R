
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(googlesheets)
library(dplyr)
library(readr)
library(data.table)
library(forecast)

month_start <- function(d) {
  as.Date(paste0(substr(d, 1, 8), "01"))
}

shinyServer(function(input, output, session) {
  observe({
    sheet <- gs_key("1fVjg64j1l6ns12APBsqf2f_6NFMttFiU1SQmsX35HJY", verbose = FALSE)
    g1 <- gs_read_csv(sheet, "Группы", verbose = FALSE)
    groups <- unique(c(unlist(g1[, "Группа"]), "Телефоны", "Развлечения", "Обед работа", "Кредитка", "Ипотека", "Еда домой", "Коммуналка",
                "Девочки", "Машина", "Ремонт", "Хозтовары", "Лекарства", "Доход", "Другое"))
    updateSelectInput(session, "group",
                      choices = groups
    )
  })

  output$balance <- renderText({
    sheet <- gs_key("1fVjg64j1l6ns12APBsqf2f_6NFMttFiU1SQmsX35HJY", verbose = FALSE)
    unlist(gs_read_csv(sheet, "Баланс", verbose = FALSE, col_types = cols(`Текущий долг` = col_character()))[, "Текущий долг"])
  })

  if (FALSE) {
    sheet <- gs_key("1fVjg64j1l6ns12APBsqf2f_6NFMttFiU1SQmsX35HJY", verbose = FALSE)
    g1 <- as.data.table(gs_read_csv(sheet, "Список трат", verbose = FALSE, col_types = cols(`Сумма` = col_character())))
    g1[Прогноз == 1,
       list(Amount = sum(as.numeric(sub(",", ".", Сумма)))),
       by = list(dt = as.Date(paste0(substr(Дата, 1, 7), "-01")), Group = Группа)]
  }

  observeEvent(input$submit, {
    sheet <- gs_key("1fVjg64j1l6ns12APBsqf2f_6NFMttFiU1SQmsX35HJY", verbose = FALSE)

    gs_add_row(sheet, ws = "Список трат", input = c(input$name, input$group, sub("[.]", ",", input$amount), as.character(input$date), 1), verbose = FALSE)

    if (input$payType == "sber50") {
      # Добавляем доходы по кредитке и списание через 50 дней
      if (Sys.Date() < month_start(Sys.Date()) + 5) {
        base_date <- month_start(Sys.Date()) + 5
      } else {
        base_date <- seq(month_start(Sys.Date()), by = "1 month", length.out = 2)[2] + 5
      }
      base_date <- base_date + 20

      gs_add_row(sheet, ws = "Список трат", input = c("Предоставление кредита (Сбербанк)", "Доход", paste0("-", sub("[.]", ",", input$amount)), as.character(input$date), 0), verbose = FALSE)
      gs_add_row(sheet, ws = "Список трат", input = c("Погашение кредита (Сбербанк)", "Кредитка", sub("[.]", ",", input$amount), as.character(base_date), 0), verbose = FALSE)
    } else if (input$payType == "alpha100") {
      # по хорошему нужно искать дату не покрытого кредита и её считать датой погашения
      # но это долго
      gs_add_row(sheet, ws = "Список трат", input = c("Предоставление кредита (Альфа)", "Доход", paste0("-", sub("[.]", ",", input$amount)), as.character(input$date), 0), verbose = FALSE)
      gs_add_row(sheet, ws = "Список трат", input = c("Погашение кредита (Сбербанк)", "Кредитка", sub("[.]", ",", input$amount), as.character(input$date + 60), 0), verbose = FALSE)
    }
  })
})
