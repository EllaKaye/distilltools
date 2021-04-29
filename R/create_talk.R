#' Create a talk page with icon links
#'
#' This function wraps [distill::create_post()], but defaults to the `_talk` collection and pre-populates the post with [icon_link()] functions to provide buttons for slides, materials and project. These appear in a code chunk and can be edited. The `edit` option in the call to [distill::create_post()] must be set to `FALSE`, so an `open` argument is provided instead that serves the same purpose.
#'
#' @param title Post title
#' @param collection collection to create the post within (defaults to "talks")
#' @param author Post author. Automatically drawn from previous post if not provided.
#' @param slug Post slug (directory name). Automatically computed from title if not provided
#' @param date Post date (defaults to current date)
#' @param date_prefix Date prefix for post slug (preserves chronological order for talks within the filesystem). Pass `NULL` for no date prefix
#' @param draft Mark the post as a `draft` (don't include in the article listing)
#' @param open logical. Open the created file?
#'
#' @note This function must be called from with a working directory that is within
#'  a Distill website.
#'
#' @author Eric Ekholm and Ella Kaye
#'
#' @examples
#' \dontrun{
#' library(distilltools)
#' create_talk("My Talk")
#' }
#' @export
create_talk <- function(title, collection = "talks",author = "auto", slug = "auto", date = Sys.Date(), date_prefix = date, draft = FALSE, open = TRUE) {

  tmp <- distill::create_post(title = title, collection = collection, author = author, slug = slug, date = date, date_prefix = date_prefix, draft = draft, edit = FALSE)

  # find and save the yaml
  talk <- readLines(tmp)
  yaml <- extract_yaml(talk)

  con <- file(tmp, open = "w")

  on.exit(close(con), add = TRUE)

  body <- '
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE)
```

```{r libraries}
library(distilltools)
```

```{r icon-links}
# [TODO]: fill in urls
# [TODO]: delete any unessary icons (or add more)
# [TODO]: css styling for .icon-link and .icon-link:hover
# [NOTE]: icons in same chunk will appear on same line
# [NOTE]: icons in different chunks will appear on a different lines
icon_link(icon = "fas fa-images",
          text = "slides (web)",
          url = "")

icon_link(icon = "fas fa-file-pdf",
          text = "slides (PDF)",
          url = "")

icon_link(icon = "fab fa-github",
          text = "materials",
          url = "")

icon_link(icon = "fas fa-play-circle",
          text = "video",
          url = "")

icon_link(icon = "fas fa-folder-open",
          text = "project",
          url = "")
```
  '

xfun::write_utf8(yaml, con)
xfun::write_utf8(body, con)

if (open == TRUE) usethis::edit_file(tmp)

}
