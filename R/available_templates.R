#' Get Named Vector of Available Post Templates
#'
#' Get a named vector of available R Markdown templates for new posts.
#'
#' @details
#' By default `distilltools` looks for R Markdown post templates in
#' `./inst/rmarkdown/templates/`. In order to be recognized, templates within
#' this path must be structured as: `template_name/skeleton/skeleton.Rmd`.
#'
#' The default path can be changed with
#' `options("distilltools.templates.path" = "custom/template/path/")`.
#' For the change to persist between R sessions this code should be placed
#' in a project local `.Rprofile`. Use `usethis::edit_r_profile("project")` to
#' create or edit this file.
#'
#' @seealso
#' `distilltools:create_post_from_template()`
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

  # If the user has any templates locally make those available too. The user
  # can specify a custom path to their templates with
  # `options(distilltools.templates.path = "user/defined/path")`
  if (is.null(getOption("distilltools.templates.path"))) {
    user_templates <- list.dirs(file.path("inst", "rmarkdown", "templates"),
                                full.names = FALSE,
                                recursive = FALSE)
  } else {
    user_templates <- list.dirs(getOption("distilltools.templates.path"),
                                full.names = FALSE,
                                recursive = FALSE)
  }
  user_templates <- tools::toTitleCase(gsub("_", " ", user_templates))
  user_templates_paths <-
    list.dirs("inst/rmarkdown/templates", recursive = FALSE)
  user_templates_paths <-
    paste0(user_templates_paths, "/skeleton/skeleton.Rmd")

  # Create vector to store templates in for use in Shiny UI
  templates_names <- c("Default", user_templates)
  templates <- c(default_template, user_templates_paths)
  names(templates) <- templates_names

  # Warn if user template files do not exist locally. This might happen if the
  # folder structure exists but there is no `skeleton.Rmd` file, if there is
  # a typo that violates the expected path, or if the expected path structure
  # is violated.
  if (any(file.exists(user_templates_paths) == FALSE)) {

    missing_templates <- templates[!file.exists(templates)]

    warning("No `skeleton.Rmd` file exists for the following templates: ",
            paste(names(missing_templates), collapse = ", "), ". ",
            "See `?available_templates` for the expected path structure."
            )
  }

  templates
}
