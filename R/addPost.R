#' addPost
#' Add Distill Post
#'
#' @export
#'

addPost <- function() {

  ui <-
    miniUI::miniPage(
      miniUI::gadgetTitleBar("Add Post"),
      miniUI::miniTabstripPanel(
        miniUI::miniTabPanel(
          "Parameters",
          icon = shiny::icon("keyboard"),
          miniUI::miniContentPanel(
            shiny::fillCol(
              shiny::textInput(inputId = "title1", label = "Title"),

              shiny::textInput(inputId = "collection1", label = "Collection"),

              shiny::textInput(inputId = "author1", label = "Author")

              # shiny::textInput(inputId = "slug1", label = "Slug"),

              # shiny::textInput(inputId = "date1", label = "Date"),

              # shiny::textInput(inputId = "date_prefix1", label = "Date Prefix"),

              # shiny::textInput(inputId = "draft1", label = "Draft"),

              # shiny::textInput(inputId = "edit1", label = "Edit")

            )
          )
        )
      )
    )



  server <- function(input, output, session) {


    #   title1 <- reactiveVal()
    #
    #   observeEvent( input$title1 , {
    #
    #     title1( input$title1 )
    #
    #
    #   })
    #
    #   title1 <- quote({
    # title1()
    #   })
    #
    # title1 <- reactive({
    #   title1
    # })









    shiny::observeEvent(input$done, {

      distill::create_post(
        title = input$title1,
        collection = input$collection1,
        author = input$author1
        # slug = "auto",
        # date = NULL,
        # date_prefix = NULL,
        # draft = FALSE,
        # edit = TRUE
      )


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
