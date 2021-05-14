#' makeSeeIcon
#' Make See Icon
#'
#' @export
#'

makeSeeIcon <- function() {
  ui <-
    miniUI::miniPage(
      miniUI::gadgetTitleBar("Add Post"),
      miniUI::miniTabstripPanel(
        miniUI::miniTabPanel(
          "Arguments",
          icon = shiny::icon("keyboard"),
          miniUI::miniContentPanel(
            shiny::fillCol(
              shiny::textInput(inputId = "iconname", label = "Icon Name"),
            shiny::verbatimTextOutput("iconcode"),

            shiny::tags$hr()


            # shiny::uiOutput("iconcode")


            # shiny::htmlOutput("iconcode")
            )
          )
        )
      )
    )



  server <- function(input, output, session) {
    output$iconcode <- shiny::renderText({
      paste0(
        "<i class='fab fa-",
        input$iconname,
        "'></i>"
      )
    })









    shiny::observeEvent(input$done, {
      shiny::stopApp()
    })
    shiny::observeEvent(input$cancel, {
      shiny::stopApp()
    })
  }



  shiny::runGadget(
    ui,
    server,
    viewer = shiny::dialogViewer(
      dialogName = "Add Post",
      width = 600,
      height = 600
    )
    # viewer = paneViewer()
  )
}
