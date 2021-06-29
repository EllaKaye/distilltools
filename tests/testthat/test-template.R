test_that("Default template can be found", {

  template_path <- system.file("rmarkdown",
                               "templates",
                               "default",
                               "skeleton",
                               "skeleton.Rmd",
                               package = "distilltools")

  expect_true({
    file.exists(template_path)
  })

})

test_that("User template can be found", {

  template <- system.file("rmarkdown",
                          "templates",
                          "default",
                          "skeleton",
                          "skeleton.Rmd",
                          package = "distilltools")

  tmpdir <- withr::local_tempdir()

  # When the default path is used
  default_template_path <- file.path(tmpdir,
                                     "templates")

  dir.create(default_template_path, recursive = TRUE)

  file.copy(template, default_template_path)

  file.rename(
    file.path(default_template_path, "skeleton.Rmd"),
    file.path(default_template_path, "default_path.Rmd")
  )

  expect_equal({
    withr::local_dir(file.path(tmpdir))
    names(available_templates())
  }, c("Default", "default_path"))

  # When a user-defined path is set with `options()`
  user_template_path <- file.path(tmpdir,
                                  "inst",
                                  "rmarkdown",
                                  "templates")

  dir.create(user_template_path, recursive = TRUE)

  file.copy(template, user_template_path)

  file.rename(
    file.path(user_template_path, "skeleton.Rmd"),
    file.path(user_template_path, "user_path.Rmd")
  )

  expect_equal({
    withr::local_dir(file.path(tmpdir))
    withr::local_options(list(
      distilltools.templates.path = file.path("inst",
                                              "rmarkdown",
                                              "templates")
      ))
    names(available_templates())
  }, c("Default", "user_path"))

})
