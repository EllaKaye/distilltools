#' Get named vector of available post templates
#'
#' Get a named vector of available R Markdown templates for new posts.
#'
#' @details
#' By default `available_templates()` looks for R Markdown post templates in
#' `./templates`. The template file name will be used to name the template. For
#' example, `./templates/my_template.Rmd` will be named "my_template". This
#' name can be used to access the path for "my_template" (see examples), and
#' will also be displayed in the list of available templates in the "Create
#' post from template" RStudio addin.
#'
#' The default directory `available_templates()` looks for R Markdown post
#' templates in can be changed with
#' `options("distilltools.templates.path" = "custom/templates/path/")`.
#' For the change to persist between R sessions this code should be placed
#' in a project local `.Rprofile`. Use `usethis::edit_r_profile("project")` to
#' create or edit this file.
#'
#' In addition to local templates, `available_templates()` will always make
#' available a default template named "Default" that matches the one from
#' `distill::create_post()`. This template can be selected in the "Create
#' post from template" RStudio addin as well.
#'
#' @seealso
#' [create_post_from_template()], [distill::create_post()]
#'
#' @examples
#' \dontrun{
#' # Return the path of a template using its name
#' available_templates()[["Default"]]
#' }
#'
#' @export
available_templates <- function() {

  # Get path to the default distilltools post template so it is accessible in
  # the addin
  default_template <- system.file("rmarkdown",
                                  "templates",
                                  "default",
                                  "skeleton",
                                  "skeleton.Rmd",
                                  package = "distilltools")
  names(default_template) <- "Default"

  # If the user has not specified a custom path to their templates then search
  # a default path for them
  if (is.null(getOption("distilltools.templates.path"))) {
    withr::local_options(list(
      distilltools.templates.path = file.path("templates")
    ))
  }

  # Get path and file names of any templates the user has locally. Recursive
  # is set to FALSE to reinforce that this function will not look for RMarkdown
  # files located in subdirectories of the templates path. Not all users will
  # have templates locally. A character of length 0 is implicitly returned in
  # this case.
  user_templates <- lapply(list(paths = TRUE, names = FALSE), function(x) {
    template_files <- list.files(getOption("distilltools.templates.path"),
                                 pattern = "\\.Rmd",
                                 full.names = x,
                                 recursive = FALSE)
  })

  # Only return the default template if no user local templates are detected
  if (length(user_templates$paths) == 0) {
    default_template
  } else {
    # Return default and user templates otherwise

    # Remove .Rmd extension from user template names
    user_template_names <- tools::file_path_sans_ext(user_templates$names)
    names(user_templates$paths) <- user_template_names

    # Default and user templates
    templates <- c(default_template, user_templates$paths)

    templates
  }

}
