# non-exported functions from the distill package that are necessary for distill::create_post and, in turn, for distilltools::create_post_from_template

# from distill (non-exported function)
resolve_slug <- function(title, slug) {
  if (identical(slug, "auto")) {
    slug <- title
  }

  slug <- tolower(slug) # convert to lowercase
  slug <- gsub("\\s+", "-", slug) # replace spaces with -
  slug <- gsub("[^a-zA-Z0-9\\-]+", "", slug) # remove all non-word chars
  slug <- gsub("\\-{2,}", "-", slug) # replace multiple - with single -
  slug <- gsub("^-+", "", slug) # trim - from start of text
  slug <- gsub("-+$", "", slug) # trim - from end of text

  slug
}

# from distill (non-exported function)
resolve_post_dir <- function(posts_dir, slug, date_prefix) {

  # start with slug
  post_dir <- file.path(posts_dir, slug)

  # add date prefix
  if (!is.null(date_prefix)) {
    if (isTRUE(date_prefix)) {
      date_prefix <- Sys.Date()
    } else if (is.character(date_prefix)) {
      date_prefix <- parse_date(date_prefix)
    }
    if (is_date(date_prefix)) {
      date_prefix <- as.character(date_prefix, format = "%Y-%m-%d")
    } else {
      stop("You must specify either NULL or a date for date_prefix")
    }
    post_dir <- file.path(posts_dir, paste(date_prefix, slug, sep = "-"))
  }

  post_dir
}

# from distill (non-exported function)
find_site_dir <- function(input_file) {
  tryCatch(
    rprojroot::find_root(
      criterion = rprojroot::has_file("_site.yml"),
      path = dirname(input_file)
    ),
    error = function(e) NULL
  )
}

# from distill (non-exported function)
is_date <- function(x) {
  lubridate::is.Date(x) ||
    lubridate::is.POSIXct(x) ||
    lubridate::is.POSIXlt(x)
}

# from distill (non-exported function)
read_json <- function(file) {
  json <- readChar(file, nchars = file.info(file)$size, useBytes = TRUE)
  Encoding(json) <- "UTF-8"
  jsonlite::fromJSON(json, simplifyVector = FALSE)
}

# from distill (non-exported function)
# From whoami package (didn't want the httr dependency b/c this makes
# the package difficult to install for beginners on Linux due to
# libcurl-dev requirement)
fullname <- function(fallback = NULL) {
  if (Sys.info()["sysname"] == "Darwin") {
    user <- try(
      {
        user <- system("id -P", intern = TRUE)
        user <- str_trim(user)
        user <- strsplit(user, ":")[[1]][8]
      },
      silent = TRUE
    )
    if (ok(user)) {
      return(user)
    }

    user <- try(
      {
        user <- system("osascript -e \"long user name of (system info)\"",
          intern = TRUE
        )
        user <- str_trim(user)
      },
      silent = TRUE
    )
    if (ok(user)) {
      return(user)
    }
  } else if (.Platform$OS.type == "windows") {
    user <- try(suppressWarnings({
      user <- system("git config --global user.name", intern = TRUE)
      user <- str_trim(user)
    }), silent = TRUE)
    if (ok(user)) {
      return(user)
    }

    user <- try(
      {
        username <- username()
        user <- system(
          paste0(
            "wmic useraccount where name=\"", username,
            "\" get fullname"
          ),
          intern = TRUE
        )
        user <- sub("FullName", "", user)
        user <- str_trim(paste(user, collapse = ""))
      },
      silent = TRUE
    )

    if (ok(user)) {
      return(user)
    }
  } else {
    user <- try(
      {
        user <- system("getent passwd $(whoami)", intern = TRUE)
        user <- str_trim(user)
        user <- strsplit(user, ":")[[1]][5]
        user <- sub(",.*", "")
      },
      silent = TRUE
    )
    if (ok(user)) {
      return(user)
    }
  }

  user <- try(suppressWarnings({
    user <- system("git config --global user.name", intern = TRUE)
    user <- str_trim(user)
  }), silent = TRUE)
  if (ok(user)) {
    return(user)
  }

  fallback_or_stop(fallback, "Cannot determine full name")
}

# from distill (non-exported function)
ok <- function(x) {
  !inherits(x, "try-error") &&
    !is.null(x) &&
    length(x) == 1 &&
    x != "" &&
    !is.na(x)
}

# from distill (non-exported function)
`%or%` <- function(l, r) {
  if (ok(l)) l else r
}

# from distill (non-exported function)
str_trim <- function(x) {
  gsub("\\s+$", "", gsub("^\\s+", "", x))
}

# from distill (non-exported function)
fallback_or_stop <- function(fallback, msg) {
  if (!is.null(fallback)) {
    fallback
  } else {
    stop(msg)
  }
}

# from distill (non-exported function)
dir_exists <- function(x) {
  utils::file_test("-d", x)
}

# from distill (non-exported function)
file_with_ext <- function(file, ext) {
  paste(tools::file_path_sans_ext(file), ".", ext, sep = "")
}

# from distill (non-exported function)
site_collections <- function(site_dir, site_config) {

  # collections defined in file
  collections <- site_config[["collections"]]
  if (is.null(collections)) {
    collections <- list()
  } else if (is.character(collections)) {
    collection_names <- names(collections)
    collections <- lapply(collections, function(collection) {
      list()
    })
    names(collections) <- collection_names
  }
  else if (is.list(collections)) {
    if (is.null(names(collections))) {
      stop("Site collections must be specified as a named list", call. = FALSE)
    }
  }

  # automatically include posts and articles
  ensure_collection <- function(name) {
    if (!name %in% names(collections)) {
      collections[[name]] <<- list()
    }
  }
  ensure_collection("posts")
  ensure_collection("articles")

  # add any collection with a listing
  input_files <- list.files(site_dir, pattern = "^[^_].*\\.[Rr]?md$", full.names = TRUE)
  sapply(input_files, function(file) {
    listings <- front_matter_listings(file, "UTF-8")
    sapply(listings, ensure_collection)
  })

  # filter on directory existence
  collections <- collections[file.exists(file.path(site_dir, paste0("_", names(collections))))]

  # add name field
  for (name in names(collections)) {
    collections[[name]][["name"]] <- name
  }

  # inherit some properties from the site
  lapply(collections, function(collection) {
    inherit_prop <- function(name) {
      if (is.null(collection[[name]])) {
        collection[[name]] <<- site_config[[name]]
      }
    }
    inherit_prop("title")
    inherit_prop("description")
    inherit_prop("copyright")
    collection
  })
}

# from distill (non-exported function)
front_matter_listings <- function(input_file, encoding, full_only = FALSE) {
  metadata <- rmarkdown::yaml_front_matter(input_file, encoding)
  if (!is.null(metadata$listing)) {
    if (is.list(metadata$listing)) {
      if (!full_only) {
        names(metadata$listing)
      } else {
        c()
      }
    } else {
      metadata$listing
    }
  } else {
    c()
  }
}

# from distill (non-exported function)
edit_file <- function(file) {
  if (rstudioapi::hasFun("navigateToFile")) {
    rstudioapi::navigateToFile(file)
  } else {
    utils::file.edit(file)
  }
}

# from distill (non-exported function)
parse_date <- function(date) {
  if (!is.null(date)) {
    parsed_date <- lubridate::mdy(date, tz = safe_timezone(), quiet = TRUE)
    if (is.na(parsed_date)) {
      parsed_date <- lubridate::ymd(date, tz = safe_timezone(), quiet = TRUE)
    }
    if (lubridate::is.POSIXct(parsed_date)) {
      date <- parsed_date
    }
  }
  date
}

# from distill (non-exported function)
safe_timezone <- function() {
  tz <- Sys.timezone()
  ifelse(is.na(tz), "UTC", tz)
}
