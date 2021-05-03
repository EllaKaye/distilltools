## Creating the icon_names table
## Note this is really hacky, but will do for now!

library(fontawesome)
library(dplyr)
library(stringr)

# get names for font awesome icons from `fontawesome` package
# https://github.com/rstudio/fontawesome/

fa_names <- fontawesome:::fa_tbl %>%
   select(name, full_name, style)

# to get academicon names, download academicons from
# https://jpswalsh.github.io/academicons/
# temporarily copy the svg folder from the download into the root of this directory
# get the names of the icons from the filenames in the svg folder

ai_files <- list.files("svg")
ai_names <- data.frame(name = ai_files) %>%
   mutate(name = str_remove(name, ".svg")) %>%
   mutate(full_name = paste0("ai ai-", name))

icon_names <- bind_rows(fa_names, ai_names) %>%
  distinct()

# then delete the folder of svg files from the package

usethis::use_data(icon_names, internal = TRUE, overwrite = TRUE)
