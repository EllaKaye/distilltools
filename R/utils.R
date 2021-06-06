# file.exists() returns TRUE when the path points to a directory. This function
# returns FALSE if the file that exists is a directory or if nothing exists in
# the path. But it still returns TRUE when a file exists.
file.not.dir.exists <- function(path) {
  sapply(path, function(x) {
    file.exists(x) && !dir.exists(x)
  })
}

# Utilities for running RStudio addin scripts located in `inst/scripts` -------
# Keeping addins that are just wrappers for {distilltools} functions to a
# separate script keeps this package more lightweight since users do not have
# to install {miniUI} or {shiny}. The RStudio IDE will remind users to install
# these packages when they run the addins if they are not installed.

# Modified from {blogdown}
in_root <- function(expr) {
  xfun::in_dir(rprojroot::find_rstudio_root_file(), expr)
}

# Taken from {blogdown}
pkg_file <- function(..., must_work = TRUE) {
  system.file(..., package = "distilltools", mustWork = must_work)
}

# Taken from {blogdown}
source_addin <- function(file) {
  in_root(sys.source(
    pkg_file("scripts", file),
    envir = new.env(parent = globalenv()),
    keep.source = FALSE
  ))
}
