# text <- readLines(here::here("Rmd", "test_post.Rmd"))

# text is a vector of strings, one element for each line of the text
# e.g. the output of readLines() on a .Rmd file
# assumes only one block of yaml, and no lines of "---" preceding it
extract_yaml <- function(text) {
  yaml_bounds <- grep("^---$", text)
  yaml <- text[yaml_bounds[1]:yaml_bounds[2]]
  yaml
}

# yaml <- extract_yaml(text)

# remove the last character from the end of a string
# useful after a call to yaml::as.yaml to remove "\n"
# "\n" is extraneous when we will be using writeLines
remove_last_char <- function(string) {
  string <- substr(string, start = 1, stop = nchar(string) - 1)
  string
}

# authors <- yaml::as.yaml(list(author = c("Ella Kaye", "John Paul Helveston")))
# authors_yaml <- remove_last_char(authors)

# given a yaml vector, insert a new key and value(s)
# inserted at end, by default, or after a given key
# use after = "start" to insert at the beginning of the yaml
insert_yaml <- function(yaml, new_yaml, after = "at_end") {

  # if a key is given in after, check if it's in yaml
  if (!(after %in% c("start", "at_end"))) {
    after_key_index <- grep(paste0("^", after, ":"), yaml)
    yaml_has_key <- length(after_key_index) == 1

    # stop if not
    if (!yaml_has_key) {
      stop(paste0(after, " is not a key in yaml"))
    }

    # find the yaml keys
    new_keys_index <- grep("^[[:lower:]]", yaml)
    # make things easier if "after' is last key
    new_keys_index <- c(new_keys_index, length(yaml))

    # index of next key after
    next_index <- which(new_keys_index == after_key_index) + 1
    next_key <- new_keys_index[next_index]

    # insert before key after 'after'
    yaml <- c(
      yaml[1:(next_key - 1)],
      new_yaml,
      yaml[next_key:length(yaml)]
    )
  }

  if (identical(after, "at_end")) {
    yaml <- c(
      yaml[1:(length(yaml) - 1)],
      new_yaml,
      "---"
    )
  }

  if (identical(after, "start")) {
    yaml <- c(
      "---",
      new_yaml,
      yaml[2:length(yaml)]
    )
  }

  yaml
}

# insert_yaml(text_yaml, authors_yaml, "start")

# given a yaml vector, replace a key with new_yaml
replace_yaml <- function(yaml, new_yaml, key) {

  # check if key is in yaml, stop if not
  key_index <- grep(paste0("^", key, ":"), yaml)
  yaml_has_key <- length(key_index) == 1

  # stop if not
  if (!yaml_has_key) {
    stop(paste0(key, " is not a key in yaml"))
  }

  # find the yaml keys
  new_keys_index <- grep("^[[:lower:]]", yaml)
  # make things easier if "after' is last key
  new_keys_index <- c(new_keys_index, length(yaml))

  # index of next key after
  next_index <- which(new_keys_index == key_index) + 1
  next_key <- new_keys_index[next_index]

  # replace yaml for key with new_yaml
  yaml <- c(
    yaml[1:(key_index - 1)],
    new_yaml,
    yaml[next_key:length(yaml)]
  )

  yaml
}

# text <- readLines(here::here("Rmd", "test_post.Rmd"))
# yaml <- extract_yaml(text)
# yaml

# replace_yaml(yaml, authors_yaml, "output")
