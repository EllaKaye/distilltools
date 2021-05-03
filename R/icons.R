#' @export
#' @rdname icon_link
#' @examples make_icon("images")
#' @examples make_icon("fas fa-images")
#' @examples make_icon("far fa-images")
#' @examples make_icon("images", style = "regular")
make_icon <- function(icon, style = "default") {

  if (!(icon %in% c(icon_names$name, icon_names$full_name))) {
    message("the icon name is not in Font Awesome v5.15 or Academicons v1.9")
  }

  # when full name is given, return with icon name as class in <i> tag
  if (grepl(" ", icon)) {
    return(htmltools::tag("i", list(class = icon)))
  }

  # when short name is give
  else {
    # find icon(s) in icon_name table that match the short name
    # we are looking for duplicates
    # duplicates are all either solid/regular within font awesome icons
    # or duplicates between font awesome and academicons
    icons <- icon_names[icon_names$name == icon, ]

    # if only one full name matches the short name, set that to `icon`
    if (nrow(icons) == 1) {
      icon <- icons$full_name
    }

    # if more than one match for short name, need to pick one
    if (nrow(icons) > 1) {

      # get fa icon if both fa and ai (i.e. the one that specifies a style)
      icons <- icons[!is.na(icons$style), ]

      if (nrow(icons) == 1) {
        icon <- icons$full_name
      }

      # deal with case of two font awesome icons
      if (nrow(icons) > 1) {

        # if style is specified, check that the specified style is available for the icon
        if (style != "default" & !(style %in% icons$style)) {
          stop(paste0("style '", style, "' is not available for icon '", icon, "'"))
        }

        # default to picking the `solid` one if user hasn't specified style
        if (style == "default") {
          style <- "solid"
        }

        # set icon to full name in specified style
        icon <- icons[icons$style == style, "full_name"]

      }

    }
  }

  return(htmltools::tag("i", list(class = icon)))
}

make_icon_text <- function(icon, text, style = "default") {
  return(htmltools::HTML(paste0(make_icon(icon, style = style), " ", text)))
}


#' Link "buttons" with icons and text
#'
#' Easily insert "buttons" with an icon and text into .Rmd documents
#'
#' Note that it will be necessary to add some CSS to in order to make the "buttons" look like buttons. For the `icon_link` function, this can be done by styling the `icon-link` class. At a minimum, a border property should be set. For a `distill` website, we recommend using the `distill::create_theme()` function and writing additional CSS at the bottom of that file. See [here](https://rstudio.github.io/distill/website.html#theming) for details of how to implement that. See [here](https://github.com/jhelvy/jhelvy.com/blob/master/css/jhelvy.css) and [here](https://github.com/EllaKaye/ellakaye-distill/blob/main/emk_theme.css) for examples.
#'
#' The `make_icon` function returns an `<i>` tag, rather than the svg of the icon. This function is designed primarily to be called within `icon_link`, so we use the tag rather than the image directly to enable styling by css (in particular that the icon styling can change if hovered over). If you wish to insert an icon directly into your text or into a site header or footer, we recommend using a package that inserts the svg, such as [**fontawesome**](https://rstudio.github.io/fontawesome/) or [**icons**](https://pkg.mitchelloharawild.com/icons/). This ensures that the icons render offline, and there are also additional styling options available.
#'
#' There are three short icon names that appear in both font awesome and academicons. They are "mendeley", "orcid" and "researchgate". These functions default to the font awesome versions (since font awesome should work out-the-box with `distill` whereas academicons needs the stylesheet adding - see above), but the academicon versions can be accessed by using their full name, e.g. `"ai ai-orcid"`. Note that in early testing the font awesome icons for "orcid" and "mendeley" were troublesome for one of the authors, but the academicon versions worked fine.
#'
#' @param icon The name of the icon. For Font Awesome icons, the name should correspond to the current Version 5 name and can either be the the short name (e.g. `"github"`) or the full name (e.g. `"fab fa-github"`). [Academicons](https://jpswalsh.github.io/academicons/) can also be used and styled the same way (e.g. `"google-scholar"` or `"ai ai-google-scholar"`) but require a site header. See [here](https://www.jhelvy.com/posts/2021-03-25-customizing-distill-with-htmltools-and-css/#side-note-on-academic-icons) for details.
#' @param text A string of the text to appear on the button
#' @param url A url for where the button should link to
#' @param style The style of the font awesome icon, which can be "default", "solid" or "regular". This parameter is only used when the short name of the icon is used in the `icon` argument and there is more than one style available for that icon. In that case, the default becomes "solid".
#' @return For `make_icon`, a `shiny.tag` with the HTML `<i class = "icon"></i>`. For `icon_link`, a `shiny.tag` with the HTML `<a href=url class="icon-link" target = "_blank" rel = "noopener"><i class=icon></i> text</a>`
#' @author John Paul Helveston and Ella Kaye
#' @examples icon_link("github", "materials", "https://github.com/USER/REPO")
#' @examples icon_link("images", "slides", "https://USER.github.io/slides", style = "regular")
#' @export
icon_link <- function(icon = NULL, text = NULL, url = NULL, style = "default") {
  if (!is.null(icon)) {
    text <- make_icon_text(icon, text, style = style)
  }
  return(htmltools::a(href = url, text, class = "icon-link", target = "_blank", rel = "noopener"))
}

# icons that appear in fontawesome academicons
# icon_names %>%
#   add_count(name) %>%
#   filter(n > 1) %>%
#   filter(style == "brands")
# mendeley, orcid, researchgate

# icons with more than one style
# check at least one is solid
# icon_names %>%
#   add_count(name) %>%
#   filter(n > 1) %>%
#   nrow()
# # 311 rows
#
# icon_names %>%
#   add_count(name) %>%
#   filter(n == 2) %>%
#   nrow()
# # 308 rows
#
# icon_names %>%
#   add_count(name) %>%
#   filter(n == 2) %>%
#   count(style)
# # confirm that where there are two, either it's fa/ai double or fas/far double
#
# icon_names %>%
#   add_count(name) %>%
#   filter(n == 3)
# # font-awesome-logo-full cab be fab, fas or far
#

