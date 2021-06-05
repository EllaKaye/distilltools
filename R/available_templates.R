#' Get Named Vector of Available Post Templates
#'
#' Call this function to get a named vector of available templates for new
#' posts. Post templates must follow the following path convention:
#' `inst/rmarkdown/templates/template_name/skeleton/skeleton.Rmd`.
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

  # If the user has any templates locally make those available too
  user_templates <- list.dirs("inst/rmarkdown/templates",
                              full.names = FALSE,
                              recursive = FALSE)
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
