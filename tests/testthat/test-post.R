test_that("Post from template can be created", {

  skip_if_pandoc_not_installed()

  tmpdir <- withr::local_tempdir()

  blog_path <- file.path(tmpdir, "testblog")

  template <- system.file("rmarkdown",
                          "templates",
                          "default",
                          "skeleton",
                          "skeleton.Rmd",
                          package = "distilltools")

  expect_error({
    distill::create_blog(blog_path, "Test Blog", edit = FALSE)
  }, NA)

  expect_error({
    withr::local_dir(blog_path)
    create_post_from_template(template, "My Post", edit = FALSE)
  }, NA)
})
