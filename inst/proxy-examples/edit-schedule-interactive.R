library(shiny)
library(tuicalendr)

ui <- fluidPage(
  tags$h2("Create, edit and remove schedule interactively"),
  
  tags$p("Click on the calendar to create a new schedule, then you will be able to edit or delete it."),
  
  fluidRow(
    column(
      width = 9,
      calendarOutput("my_calendar")
    ),
    column(
      width = 3,
      uiOutput("schedule_add"),
      uiOutput("schedule_update"),
      uiOutput("schedule_delete")
    )
  )
)

server <- function(input, output) {
  
  # Create calendar
  
  output$my_calendar <- renderCalendar({
    cal <- calendar(
      defaultDate = Sys.Date(),
      useNav = TRUE,
      readOnly = FALSE,
      useCreationPopup = TRUE
    ) %>%
      set_month_options(narrowWeekend = TRUE) %>%
      add_schedule(
        id = "r_intro",
        calendarId = "courses",
        title = "R - introduction",
        body = "What is R?",
        start = paste(Sys.Date(), "08:00:00"),
        end = paste(Sys.Date(), "12:30:00"),
        category = "time"
      )
  })
  
  
  # Interactive counter to give ID to schedules created/edited/deleted
  schedule_count <- reactiveVal(0)
  
  
  
  # Display changes
  
  output$schedule_add <- renderUI({
    if (!is.null(input$my_calendar_add)) {
      new <- input$my_calendar_add
      tags$div(
        "Schedule",
        tags$b(paste0("schedule_", schedule_count())),
        "have been added with:",
        tags$ul(
          lapply(
            seq_along(new),
            function(i) {
              tags$li(
                tags$b(names(new)[i], ":"),
                new[[i]]
              )
            }
          )
        )
      )
    }
  })
  
  output$schedule_update <- renderUI({
    if (!is.null(input$my_calendar_update)) {
      changes <- input$my_calendar_update$changes
      tags$div(
        "Schedule",
        tags$b(input$my_calendar_update$schedule$id),
        "have been updated with:",
        tags$ul(
          lapply(
            seq_along(changes),
            function(i) {
              tags$li(
                tags$b(names(changes)[i], ":"),
                changes[[i]]
              )
            }
          )
        )
      )
    }
  })
  
  output$schedule_delete <- renderUI({
    if (!is.null(input$my_calendar_delete)) {
      remove <- input$my_calendar_delete
      tags$div(
        "Schedule",
        tags$b(input$my_calendar_delete$id),
        "have been deleted with:",
        tags$ul(
          lapply(
            seq_along(remove),
            function(i) {
              tags$li(
                tags$b(names(remove)[i], ":"),
                remove[[i]]
              )
            }
          )
        )
      )
    }
  })
  
  # Update the calendar
  
  observeEvent(input$my_calendar_add, {
    # Add an id
    new_count <- schedule_count() + 1
    cal_proxy_add(
      proxy = "my_calendar",
      id = paste("schedule_", new_count),
      .list = input$my_calendar_add
    )
    schedule_count(new_count)
  })
  
  observeEvent(input$my_calendar_update, {
    cal_proxy_update(
      proxy = "my_calendar",
      .list = input$my_calendar_update
    )
  })
  
  observeEvent(input$my_calendar_delete, {
    cal_proxy_delete(
      proxy = "my_calendar",
      .list = input$my_calendar_delete
    )
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)
