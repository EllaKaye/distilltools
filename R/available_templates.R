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
  names(default_template) <- "Default"

  # If the user has not specified a custom path to their templates then search
  # a default path for them
  if (is.null(getOption("distilltools.templates.path"))) {
    withr::local_options(list(
      distilltools.templates.path = file.path("inst", "rmarkdown", "templates")
    ))
  }

  # Get path and folder names of any templates the user has locally. Not all
  # users will have templates locally. A character of length 0 is implicitly
  # returned in this case.
  user_templates <- lapply(list(paths = TRUE, names = FALSE), function(x) {
    template_dirs <- list.dirs(getOption("distilltools.templates.path"),
                             full.names = x,
                             recursive = FALSE)
  })

  # Only return the default template if no user local templates are detected
  if (length(user_templates$paths) == 0) {
    default_template
  } else {
    # Return default and user templates otherwise

    # Construct paths to user template files
    user_template_files <- list.files(user_templates$paths,
                                      pattern = "\\.Rmd",
                                      recursive = TRUE)
    user_templates_paths <- paste0(user_templates$paths, "/",
                                   user_template_files)

    # Pretty up the template names
    user_templates$names <- tools::toTitleCase(
      gsub("_|-", " ", user_templates$names)
      )
    names(user_templates_paths) <- user_templates$names

    # Default and user templates
    templates <- c(default_template, user_templates_paths)

    # Warn if user template files do not exist locally. This might happen if
    # the folder structure exists but there is no `.Rmd` file present inside
    # it. In cases where the file does not exist the path to the folder will
    # still be returned, so it is necessary to use `!dir.exists()` in the if
    # statement.
    if (any(file.not.dir.exists(user_templates_paths) == FALSE)) {

      missing_templates <- templates[!file.not.dir.exists(templates)]

      warning("No R Markdown file exists for the following templates: ",
              paste(names(missing_templates), collapse = ", "), ". ",
              "See `?available_templates` for help."
      )
    }

    templates
  }

}
