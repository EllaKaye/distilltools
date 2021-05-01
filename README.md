# `distilltools`
`distilltools` is collection of tools to support the creation and styling of content on websites created using the [distill](https://rstudio.github.io/distill/) package in R.

It is in the very early stages of development. I am actively seeking contributions - both ideas and code - to help build the package to be broadly useful to a wide variety of `distill` users. I hope in time that `distilltools` can be for distill something like what [xaringanExtra](https://pkg.garrickadenbuie.com/xaringanExtra/#/) and [xaringanthemer](https://pkg.garrickadenbuie.com/xaringanthemer/) are for [xaringan](https://github.com/yihui/xaringan). Some of what I have in mind may sit better within the distill package itself, and I will be reaching out to the distill team about that.

# Installation
```
# install.packages("remotes")
remotes::install_github("EllaKaye/distilltools")
```

# Functionality

There are currently three functions in `distilltools`:

- `icon_link()` : creates the html for a link button with icon and text. Output of `icon_link` will need styling via the `icon-link` class to make it look like a button. For more details on this function, see [this blog post](https://www.jhelvy.com/posts/2021-03-25-customizing-distill-with-htmltools-and-css/#link-buttons-with-icons-text) from John Paul Helveston. For examples of styling the `icon-link` class, see [John Paul Helveston's css](https://github.com/jhelvy/jhelvy.com/blob/master/css/jhelvy.css) and [my css](https://github.com/EllaKaye/ellakaye-distill/blob/main/ek_theme.css).

- `create_talk()`: a wrapper around `distill::create_post()` that creates a post in the talk directory and includes buttons (made with `icon-link()`) for slides (both web and pdf), material, video and project. These can easily be edited in the resulting .Rmd file. This function was inspired by [Eric Ekholm's blog post](https://www.ericekholm.com/posts/2021-04-02-personalizing-the-distill-template/).

- `create_post_from_template()`: this function operates almost identically to `distill::create_post()` except for the addition of a `path` argument, which allows the user to pass in a path to an .Rmd file that can be used as a template for the post. 

## Future functionality
Plans for future functionality include:

- `create_highlight_theme()`. The `distill::create_theme()` function is a great way to style a distill website. Moreover, the default distill highlighting theme is excellent, and designed for accessibility. There are a few other highlighting syntax styles that can also be chosen. However, if you want a custom syntax highlighting theme (particularly one that goes with your new beautifully styled website), that is trickier. I plan to write a function to ease that process.
- incorporating more of [John Paul Helveston's functions](https://github.com/jhelvy/jhelvy.com/blob/master/R/functions.R).

# Contributing to `distilltools` 
I'm actively seeking contributions:

- Do you have a `distill` website? If so, what tools would you help you in the creation, upkeep and styling of your site?
- Do you have personal functions that you've written for your `distill` workflow? If they help you, they'll almost certainly be helpful to others to. Consider submitting (generalised) versions of them for inclusion in `distilltools`!

There are lots of other ways to support and contribute to `distilltools`. Please see the [contributing guide](.github/CONTRIBUTING.md) for more details.

## Code of Conduct
Please note that the `distilltools` project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.
