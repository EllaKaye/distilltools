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

test_that("Warn when template is missing", {

  tmpdir <- withr::local_tempdir()

  template_path <- file.path(tmpdir,
                             "inst",
                             "rmarkdown",
                             "templates",
                             "post_template")

  dir.create(template_path, recursive = TRUE)

  expect_warning({
    withr::local_dir(file.path(tmpdir))
    available_templates()
  }, "No `skeleton.Rmd` file exists for the following templates")

})

test_that("User template can be found", {

  template <- system.file("rmarkdown",
                          "templates",
                          "default",
                          "skeleton",
                          "skeleton.Rmd",
                          package = "distilltools")

  tmpdir <- withr::local_tempdir()

  template_path <- file.path(tmpdir,
                             "inst",
                             "rmarkdown",
                             "templates",
                             "post_template",
                             "skeleton")

  dir.create(template_path, recursive = TRUE)

  file.copy(template, template_path)

  expect_equal({
    withr::local_dir(file.path(tmpdir))
    names(available_templates())
  }, c("Default", "Post Template"))

})
