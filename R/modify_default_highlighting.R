col2hex <- function(col) {

  col_rgb <- grDevices::col2rgb(col)
  grDevices::rgb(col_rgb[1,1], col_rgb[2,1], col_rgb[3,1], maxColorValue = 255)

}

# code adapted from the `coloratio` package by Matt Dray
# https://github.com/matt-dray/coloratio/blob/main/R/contrast.R
check_col_arg <- function(col) {

  if(
    (!grepl("^#", col) & !col %in% grDevices::colors()) |
    (grepl("^#", col) & !grepl("^#[0-9a-fA-F]{6}$", col))
  ) {
    stop('Inputs must be in colors() if named, or of the hex form "#RRGGBB".\n')
  }
}

#' Modify the default {distill} syntax highlighting theme
#'
#' Create a syntax highlighting theme by modifying the default from the \{distill\} package and write it to the current working directory.
#'
#' This is function modifies the default syntax highlighting theme from the \{distill\} package by replacing the five colours used in that scheme with colours of the user's choosing. It is *not* a fully-featured function to create a theme from scratch. However, it does place a `.theme` file in your working directory which can be further modified if more customisations are desired. Note that if a hex code in the default is replaced with another hex code, that change in colour is applied. However, if a `null` in the default is replaced with a hex code, that colour does *not* show up when the theme is applied.
#'
#' We strongly recommend that when users choose colours for the syntax highlighting theme to be applied to their Distill website/blog, they take WCAG guidelines for web accessibility into account by ensuring that the colour contrast ratio between each of the colours used and background colour is at least 4.5:1. This can be checked with a tool such as [WebAIM contrast checker](https://webaim.org/resources/contrastchecker/) or in R with [savonliquide::check_contrast()] or the `cr_get_ratio()` function from the [`coloratio`](https://github.com/matt-dray/coloratio) package, available on GitHub. We also recommend checking that your palette is colourblind-friendly, for example by using [prismatic::check_color_blindness()] function.
#'
#' @param name Name of the theme file (will be written as name.theme)
#' @param numeric Colour for numeric variables. Must be either a named colour in [grDevices::colors()] or of the hex form "#RRBBGG". Default is red "#AD0000" (approx "Bright Red").
#' @param strings Colour for strings. Must be either a named colour in [grDevices::colors()] or of the hex form "#RRBBGG". Default is green "#20794D" (approx "Eucalyptus").
#' @param functions Colour for function names. Must be either a named colour in [grDevices::colors()] or of the hex form "#RRBBGG". Default is purple "#4758AB" (approx "San Marino").
#' @param control Colour for control (e.g. `if`, `while`). Must be either a named colour in [grDevices::colors()] or of the hex form "#RRBBGG". Default is blue "#007BA5" (approx "Deep Cerulean").
#' @param constant Colour for constants (e.g. `TRUE`, `NULL`). Must be either a named colour in [grDevices::colors()] or of the hex form "#RRBBGG". Default is brown "#8F5902" (approx "Chelsea Gem").
#' @param overwrite logical. If `TRUE` (default), will overwrite `name.theme` if it already exists in the working directory.
#'
#' @includeRmd man/rmd-fragments/apply_highlighting.Rmd
#'
#' @export
#'
#' @examples \dontrun{
#' modify_default_highlighting("my_highlighting",
#'     "#B6005B", "#008643", "#005BB6", "#5A00B5", "#B65B00")
#' modify_default_highlighting("base_cols",
#'     "red", "orange", "yellow", "green", "blue")
#' }
modify_default_highlighting <- function(name = "highlighting",
                                        numeric = NULL,
                                        strings = NULL,
                                        functions = NULL,
                                        control = NULL,
                                        constant = NULL,
                                        overwrite = TRUE) {

  name_with_ext <- paste0(name, ".theme")

  if (!is.null(numeric)) {
    check_col_arg(numeric)
    if (numeric %in% grDevices::colors()) numeric <- col2hex(numeric)
  }

  if (!is.null(strings)) {
    check_col_arg(strings)
    if (strings %in% grDevices::colors()) strings <- col2hex(strings)
  }

  if (!is.null(functions)) {
    check_col_arg(functions)
    if (functions %in% grDevices::colors()) functions <- col2hex(functions)
  }
  if (!is.null(control)) {
    check_col_arg(control)
    if (control %in% grDevices::colors()) control <- col2hex(control)
  }
  if (!is.null(constant)) {
    check_col_arg(constant)
    if (constant %in% grDevices::colors()) constant <- col2hex(constant)
  }

  arrow_theme_path <- system.file(
    "rmarkdown/templates/arrow.theme",
    package = "distilltools"
  )

  theme <- readLines(arrow_theme_path)

  if (!is.null(numeric)) theme <- gsub("#AD0000", numeric, theme) # default red
  if (!is.null(strings)) theme <- gsub("#20794D", strings, theme) # default green
  if (!is.null(functions)) theme <- gsub("#4758AB", functions, theme) # default purple
  if (!is.null(control)) theme <- gsub("#007BA5", control, theme) # default blue
  if (!is.null(constant)) theme <- gsub("#8f5902", constant, theme) # default brown

  if (file.exists(name_with_ext) & !overwrite) {
    message("WARNING: ", name_with_ext, " already exists and was not overwritten.")
  } else {
    writeLines(theme, name_with_ext)
  }

}

# numeric <- "blue"
# strings <- "green2"
# functions <- "#D4006a"
# control <- NULL
# constant <- "#cc0000"
#
# modify_default_highlighting("my_theme", numeric, strings, functions, control, constant, overwrite = TRUE)

