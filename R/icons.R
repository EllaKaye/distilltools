#' Link "buttons" with icons and text
#'
#' Easily insert "buttons" with an icon and text into .Rmd documents
#'
#' Note that it will be necessary to add some CSS to in order to make the "buttons" look like buttons. For the `icon_link` function, this can be done by styling the `icon-link` class. At a minimum, a border property should be set. For a `distill` website, we recommend using the `distill::create_theme` function and writing additional CSS at the bottom of that file. See [here](https://rstudio.github.io/distill/website.html#theming) for details of how to implement that. See [here](https://github.com/jhelvy/jhelvy.com/blob/master/css/jhelvy.css) and [here](https://github.com/EllaKaye/ellakaye-distill/blob/main/emk_theme.css) for examples.
#'
#' @param icon The name of the icon. For Font Awesome icons, the name should correspond to current Version 5 long names (e.g. `"fab fa-github"`). [Academicons](https://jpswalsh.github.io/academicons/) can also be used and styled the same way (e.g. `"ai ai-google-scholar"`) but require a site header. See [here](https://www.jhelvy.com/posts/2021-03-25-customizing-distill-with-htmltools-and-css/#side-note-on-academic-icons) for details.
#' @author John Paul Helveston and Ella Kaye
#' @return For `make_icon`, a `shiny.tag` with the HTML `<i class = "icon"></i>`. For `icon_link`, a `shiny.tag` with the HTML `<a href=url class="icon-link" target = "_blank" rel = "noopener"><i class=icon></i> text</a>`
#' @export
#'
#' @examples make_icon("r-project")
make_icon <- function(icon) {
  return(htmltools::tag("i", list(class = icon)))
}

make_icon_text <- function(icon, text) {
  return(htmltools::HTML(paste0(make_icon(icon), " ", text)))
}


#' @param text A string of the text to appear on the button
#' @param url A url for where the button should link to
#' @export
#' @rdname make_icon
#' @examples icon_link("fab fa-github", "materials", "https://github.com/USER/REPO")
icon_link <- function(icon = NULL, text = NULL, url = NULL) {
  if (!is.null(icon)) {
    text <- make_icon_text(icon, text)
  }
  return(htmltools::a(href = url, text, class = "icon-link", target = "_blank", rel = "noopener"))
}
