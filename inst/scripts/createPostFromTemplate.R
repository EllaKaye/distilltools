createPostFromTemplateAddin <- function() {

  # Generate UI for the gadget.
  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(
      shiny::textInput("title", "Title", placeholder = "Post Title", width = "99%"),
      shiny::fillRow(
        shiny::textInput("author", "Author", "auto", width = "98%"),
        shiny::dateInput("date", "Date", Sys.Date(), width = "98%"),
        shiny::textInput("collection", "Collection", "posts", width = "98%"),
        height = "70px"
      ),
      shiny::fillRow(flex = c(1, 2),
        shiny::dateInput("date_prefix", "Date Prefix", Sys.Date(), width = "98%"),
        shiny::textInput("slug", "Slug", "auto",
                         placeholder = "Post Slug (use 'auto' to compute from the title)",
                         width = "98%"),
        height = "70px"
      ),
      shiny::fillRow(
        shiny::selectInput("template", "Template",
                           choices = names(distilltools::available_templates()),
                           selected = "Default", multiple = FALSE, width = "98%"),
        shiny::selectInput("draft", "Draft",
                           choices = c("True", "False"),
                           selected = "False", multiple = FALSE, width = "98%"),
        height = "70px"
      )
    ),
    miniUI::gadgetTitleBar(NULL)
  )

  # Server code for the gadget.
  server <- function(input, output, session) {

    # Listen for "done".
    shiny::observeEvent(input$done, {

      distilltools::create_post_from_template(
        path = distilltools::available_templates()[[input$template]],
        title = input$title,
        collection = input$collection,
        author = input$author,
        slug = input$slug,
        date = input$date,
        date_prefix = input$date_prefix,
        draft = as.logical(input$draft),
        edit = interactive()
      )

      invisible(stopApp())
    })

    # Listen for "cancel".
    shiny::observeEvent(input$cancel, {
      shiny::stopApp()
    })

  }

  # Use a modal dialog as a viewer.
  viewer <- shiny::dialogViewer("Create Post", height = 500)
  shiny::runGadget(ui, server, viewer = viewer)

}

createPostFromTemplateAddin()
