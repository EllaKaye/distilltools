#' Create a new blog post from a template
#'
#' This function is designed to work as close as possible to [distill::create_post()] (and draws on a lot of code from that function). The main difference is the compolusary argument `path` which gives the path of the template to create the post from. All other arguments work the same as [distill::create_post()] (unless specified in Arguments).
#'
#' @param path File path to .Rmd template for post
#' @param title Post title. If there is a title in the template, this will override it.
#'
#' @param author Post author. If not provided, it will be automatically drawn from template. If not in template, it will be automatically drawn from previous post.
#' @param collection Collection to create the post within (defaults to "posts")
#' @param slug Post slug (directory name). Automatically computed from title if not provided.
#' @param date Post date (defaults to current date)
#' @param date_prefix Date prefix for post slug (preserves chronological order for posts
#'   within the filesystem). Pass `NULL` for no date prefix.
#' @param draft Mark the post as a `draft` (don't include it in the article listing).
#' @param edit Open the post in an editor after creating it.
#'
#' @note This function must be called from with a working directory that is within a Distill website.
#' @note The output for a post must be `distill::distill_article`. If there is no output key in the provided template, this will be added to the yaml. If there is an `output` specified in the template yaml, it must be `distill::distill_article`, otherwise `create_post_from_template` will throw an error.
#' @note Unlike [distill::create_post()], `create_post_from_template` doesn't automatically provide a `description` key in the yaml.
#'
#' @examples
#' \dontrun{
#' library(distilltools)
#' # .Rmd templates stored in "templates" directory
#' create_post_from_template(here::here("templates", "post-template.Rmd"))
#' }
#'
#' @export
create_post_from_template <- function(path,
                                      title,
                                      collection = "posts",
                                      author = "auto",
                                      slug = "auto",
                                      date = Sys.Date(),
                                      date_prefix = date,
                                      draft = FALSE,
                                      edit = interactive()) {
  ## separate out yaml and body, deal mostly with yaml, add body back at end
  ## could tidy up this code significantly by writing helper functions
  # - extract_yaml()
  # - remove_last_newline()
  # - insert_yaml()
  # - replace_yaml()

  # determine site_dir (must call from within a site)
  # from distill::create_post
  site_dir <- find_site_dir(".")
  if (is.null(site_dir)) {
    stop("You must call create_post from within a Distill website")
  }

  # read in the template
  tmp <- readLines(path)

  # find the yaml
  yaml <- extract_yaml(tmp)

  # save the body
  body <- tmp[(length(yaml) + 1):length(tmp)]

  # output
  ## check if output is set
  output_index <- grep("^output:", yaml)
  yaml_has_output <- length(output_index) == 1

  ## if yaml_has_output, check it's distill::distill_article
  ## stop if not, leave yaml as is if so
  if (yaml_has_output) {
    # check it's distill::distill_article
    is_distill_article <- sum(grepl(
      "distill::distill_article",
      yaml[output_index:(output_index + 1)]
    )) == 1

    if (!is_distill_article) {
      stop("output in template must be `distill::distill_article`")
    }
  }

  ## if no output, add in output for distill article at end of yaml
  if (!yaml_has_output) {
    output_yaml <- "output:
    distill::distill_article:
      self_contained: false"

    # tmp <- c(tmp[1:(length(yaml) - 1)],
    #         output_yaml,
    #         tmp[length(yaml):length(tmp)])
    yaml <- insert_yaml(yaml, output_yaml, after = "at_end")
  }

  ## update yaml bounds and yaml
  # yaml_bounds <- grep("^---$", tmp)
  # yaml <- tmp[yaml_bounds[1]:yaml_bounds[2]]

  # more discovery
  # from distill::create_post
  site_config <- rmarkdown::site_config(site_dir)
  posts_dir <- file.path(site_dir, paste0("_", collection))
  posts_index <- file.path(
    site_dir,
    site_config$output_dir,
    collection,
    paste0(collection, ".json")
  )

  # auto-slug
  # from distill::create_post
  slug <- resolve_slug(title, slug)

  # resolve post dir
  # from distill::create_post
  post_dir <- resolve_post_dir(posts_dir, slug, date_prefix)

  # title
  ## check if there's a title in the yaml
  title_index <- grep("^title:", yaml)
  yaml_has_title <- length(title_index) == 1
  title_yaml <- paste("title:", title)

  ## if no title in yaml, add title to beginning of tmp
  if (!yaml_has_title) {
    # tmp <- c("---", title_yaml, tmp[2:length(tmp)])
    yaml <- insert_yaml(yaml, title_yaml, "start")
  }

  ## if title in yaml, replace title in tmp with supplied title
  if (yaml_has_title) {
    # tmp[title_index] <- title_yaml
    yaml <- replace_yaml(yaml, title_yaml, "title")
  }

  ## update yaml bounds and yaml
  # yaml_bounds <- grep("^---$", tmp)
  # yaml <- tmp[yaml_bounds[1]:yaml_bounds[2]]

  # author
  ## check if author in yaml
  author_index <- grep("^author:", yaml)
  yaml_has_author <- length(author_index) == 1

  ## supplied_author_yaml if author supplied
  if (!identical(author, "auto")) {
    # create yaml from supplied author (removing final \n)
    supplied_author_yaml <- yaml::as.yaml(list(author = author),
      indent.mapping.sequence = TRUE
    )
    supplied_author_yaml <- remove_last_char(supplied_author_yaml)
  }

  ## if author != "auto" and author not in template
  ## add supplied_author_yaml after title
  if (!identical(author, "auto") & !yaml_has_author) {
    # add author after title (assumes title on one line)
    # title_index <- grep("^title:", tmp)
    # tmp <- c(tmp[1:title_index],
    #         supplied_author_yaml,
    #         tmp[(title_index+1):length(tmp)])

    yaml <- insert_yaml(yaml, supplied_author_yaml, after = "title")
  }

  ## if author != auto and author in template
  ## replace author in template with supplied_author_yaml
  if (!identical(author, "auto") & yaml_has_author) {
    # find author in yaml
    # author_index <- grep("^author:", yaml)

    # find the yaml keys
    # new_keys_index <- grep("^[[:lower:]]", yaml)

    # index of next key after author
    # next_index <- which(new_keys_index == author_index) + 1
    # next_key <- new_keys_index[next_index]

    # replace author in tmp with supplied author
    # tmp <- c(tmp[1:(author_index - 1)],
    #         supplied_author_yaml,
    #         tmp[next_key:length(tmp)])
    yaml <- replace_yaml(yaml, supplied_author_yaml, "author")
  }

  ## if author = "auto" and author not in template
  ## set author in same way as distill::create_post with author = "auto"
  if (identical(author, "auto") & !yaml_has_author) {
    # code from distill::create_post
    # default to NULL
    author <- NULL

    # look for author of most recent post (in specified collection)
    if (file.exists(posts_index)) {
      posts <- read_json(posts_index)
    } else {
      posts <- list()
    }
    if (length(posts) > 0) {
      author <- list(author = posts[[1]]$author)
    }

    # if we still don't have an author, then auto-detect
    if (is.null(author)) {
      author <-
        list(author = list(list(name = fullname(fallback = "Unknown"))))
    }

    # author to yaml (removing final \n)
    author_yaml <-
      yaml::as.yaml(author, indent.mapping.sequence = TRUE)
    # author_yaml <- substr(author_yaml,
    #                      start = 1,
    #                      stop = nchar(author_yaml)-1)
    author_yaml <- remove_last_char(author_yaml)

    # add author after title (assumes title on one line)
    # title_index <- grep("^title:", tmp)
    # tmp <- c(tmp[1:title_index],
    #         author_yaml,
    #         tmp[(title_index+1):length(tmp)])
    yaml <- insert_yaml(yaml, author_yaml, after = "title")
  }

  ## if author == "auto" and author in template
  ## nothing to do - tmp stays as is

  ## update yaml bounds and yaml
  # yaml_bounds <- grep("^---$", tmp)
  # yaml <- tmp[yaml_bounds[1]:yaml_bounds[2]]

  # date
  ## check if date in yaml
  date_index <- grep("^date:", yaml)
  yaml_has_date <- length(date_index) == 1
  date_yaml <- yaml::as.yaml(list(date = format.Date(date, "%F")))
  # date_yaml <- substr(date_yaml,
  #                    start = 1,
  #                    stop = nchar(date_yaml)-1)
  date_yaml <- remove_last_char(date_yaml)

  ## if date in yaml, override with supplied date
  ## assume date on one line
  if (yaml_has_date) {
    # tmp[date_index] <- date_yaml
    yaml <- replace_yaml(yaml, date_yaml, "date")
  }

  ## if date not in yaml, add after author
  if (!yaml_has_date) {
    # author_index <- grep("^author:", tmp)
    # tmp <- c(tmp[1:author_index],
    #         date_yaml,
    #         tmp[(author_index+1):length(tmp)])
    yaml <- insert_yaml(yaml, date_yaml, after = "author")
  }

  ## update yaml bounds and yaml
  # yaml_bounds <- grep("^---$", tmp)
  # yaml <- tmp[yaml_bounds[1]:yaml_bounds[2]]


  # draft
  ## check if draft is in yaml
  draft_index <- grep("^draft:", yaml)
  yaml_has_draft <- length(draft_index) == 1
  draft_yaml <- paste("draft:", tolower(draft))

  ## if draft = TRUE and !yaml_has_draft
  ## add draft_yaml to end of yaml
  if (draft & !yaml_has_draft) {
    # tmp <- c(tmp[1:(length(yaml) - 1)],
    #         draft_yaml,
    #         tmp[length(yaml):length(tmp)])
    yaml <- insert_yaml(yaml, draft_yaml, after = "at_end")
  }

  ## if draft = FALSE and !yaml_has_draft
  ## nothing to do - leave yaml as is

  ## if yaml_has_draft, override tmp
  if (yaml_has_draft) {
    yaml <- replace_yaml(yaml, draft_yaml, "draft")
  }

  # back to distill::create_post code for saving tmp in right place
  # create the post directory
  if (dir_exists(post_dir)) {
    stop("Post directory '", post_dir, "' already exists.", call. = FALSE)
  }
  dir.create(post_dir, recursive = TRUE)

  # create the post file
  post_file <- file.path(post_dir, file_with_ext(slug, "Rmd"))
  con <- file(post_file, open = "w", encoding = "UTF-8")
  on.exit(close(con), add = TRUE)
  xfun::write_utf8(yaml, con)
  xfun::write_utf8(body, con)

  # messages to console for new collection
  bullet <- "v"
  circle <- "o"
  new_collection <-
    !(collection %in% names(site_collections(site_dir, site_config)))
  if (new_collection) {
    cat(
      paste0(bullet, " Created new collection at _", collection),
      "\n"
    )
  }
  cat(paste(
    bullet,
    "Created post at",
    paste0("_", collection, "/", basename(post_dir))
  ), "\n")
  # if the collection isn't registered then print a reminder to do this
  if (new_collection) {
    cat(paste0(
      circle,
      " ",
      "TODO: Register '",
      collection,
      "' collection in _site.yml\n"
    ))
    cat(
      paste0(
        circle,
        " ",
        "TODO: Create listing page for '",
        collection,
        "' collection\n\n"
      )
    )
    cat(
      "See docs at https://rstudio.github.io/distill/blog.html#creating-a-collection"
    )
  }

  # edit if requested
  if (edit) {
    edit_file(post_file)
  }

  # return path to post (invisibly)
  invisible(post_file)
}
