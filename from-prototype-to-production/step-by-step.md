# MiraiLabs - From Prototype to Production

## Detailed workshop steps

Most of the R package development steps are carried out using the well-established R packages [devtools](https://devtools.r-lib.org/) and [usethis](https://usethis.r-lib.org/) for addressing common task of the package development workflow.


### Create the vbzdelays package

Set general author and license information:

``` r
options(
  usethis.description = list(
    `Authors@R` = 'person("Mirai", "Labs", email = "labs@mirai-solutions.com",
                          role = c("aut", "cre"))',
    License = "GPL-3"
  )
)
```

Create the package:

```r
devtools::create("~/Desktop/vbzdelays", fields = list(
  Title = "VBZ Delay Analysis",
  Description = "Analyze VBZ delays.",
  Depends = "R (>= 3.5.0)" # support for RDS version 3
))
```

This opens up an RStudio project for the newly-created package.


### Version control setup

Setup a local Git repository at the system shell via `git init` inside the package directory `vbzdelays`.

From the Git pane at the top-right of RStudio (You may have to close and re-open RStudio so that the Git pane shows up):

- Right-click and ignore the `.Rhistory` file
- Add all files and commit 

Create a remote repository `vbzdelays` on GitHub for your `<USERNAME>`, refusing to create initial files but copying the `.git` URL of the form `https://github.com/<USERNAME>/vbzdelays.git`.

From the shell, set the remote repository for the local version of  `vbzdelays` .

``` bash
git remote add origin https://github.com/<USERNAME>/vbzdelays.git
git push -u origin master
```


### Include line data from the prototype

Copy the line-data `.rds` files from the [prototype](https://github.com/miraisolutions/MiraiLabs/tree/master/from-prototype-to-production/vbz-delays-prototype/line-data) to `inst/line-data`.

Commit & push.


### Data-related functionality

In a new source file `R/data.R`, define a new exported function `get_line_data()`.

Enable markdown documentation via `usethis::use_roxygen_md()` and generate documentation (+ `NAMESPACE` information) via `devtools::document()` (or using the Build pane).

Install the package (Build pane) and check the documentation and example:

- `?get_line_data`
- `example("get_line_data", package = "vbzdelays")`

Commit & push.


### Data analysis functionality  

In a new source file `R/analysis.R`, split the prototype code by defining (internal) functions `compute_delay()` and `count_delays_by_weekday_hour()`, including the relevant `@import dplyr` tag (for the `NAMESPACE`).

Declare a dependency on dplyr via `usethis::use_package("dplyr")` (for the `DESCRIPTION`).

Generate documentation and install the package (see above).


### Unit test for `compute_delay()`

- Add test infrastructure to the package: `usethis::use_testthat()`
- Create a test script: `usethis::use_test("compute_delay")`
- Define some simple representative test data and the corresponding expectations
- Run the test using the button in the editor or the Build pane, or via `devtools::test()`


### Package-level checks

Run the built-in R sanity checks at package level (`R CMD check`) from the Build pane or via `devtools::check()`. Note that this will also run all available tests and examples. There should be no ERRORS nor WARNINGS.

Commit & push.


### Automated checks on Travis

Setup Travis CI to automate testing (and package-level checks in general) for continuous integration, triggered upon any push event on the GitHub repo. You need to first login at https://travis-ci.org/ (using your GitHub account)

- Setup Travis via `usethis::use_travis()`
- This will open your browser to allow you enabling access to the repo
- Commit & push the generated `.travis.yaml` file.

This will trigger the first run on Travis, which might take > 5 minutes (future runs will be much faster). The run should be successful.


### Create the README

A README file typically contains basic installation and usage instructions for a package, also displayed by GitHub at the repo home page.

- Create a skeleton via `usethis::use_readme_md()`
- Installation instruction from GitHub: `remotes::install_github("<USERNAME>/vbzdelays")`
- Add usage example for `vbzdelays::get_line_data()`

Commit & push.


### Failing Travis for broken unit-test

- Refactor `compute_delay()` using `mean()`.
- Commit & push => Travis will fail due to the broken unit test.
- Revert via `git revert HEAD` in the terminal.


### Plotting functionality  

In a new source file `R/plot.R`, define an (internal) function  `barplot_by_weekday_hour()` (core plot functionality) and an exported, documented `plot_delays_by_weekday_hour()` for creating the plot of a given line. Include the relevant `@import dplyr`, `@import ggplot2` tags.

Declare a dependency on ggplot2 via `usethis::use_package("ggplot2")`, generate documentation and install the package.

Checkout the documentation and example

- `?plot_delays_by_weekday_hour`,
- `example("plot_delays_by_weekday_hour", package = "vbzdelays")`

Define (and run) unit test via `usethis::use_test("barplot_by_weekday_hour")`.

Run package-level checks, reporting WARNING about undeclared dependency on package lemon => Fix via `usethis::use_package("lemon")`.

Commit & push.


### Line report functionality 

- Include R Markdown line report as `inst/reports/line-report.Rmd`, with parameter `line` defined in the YAML header.
- In a new source file `R/report.R`, define an exported, documented `render_line_report()`.
- Declare new dependency via `usethis::use_package("rmarkdown")`
- Generate documentation and install the package
- `?render_line_report`
- `example("render_line_report", package = "vbzdelays")`
- Update README with new example usage
- `report <- vbzdelays::render_line_report(line = 11, tempdir())`
- `browseURL(report)`

Run checks locally, commit & push.


### Website rendering functionality 

- Include website index and results chapter R Markdown as `inst/site/index.Rmd` and `inst/site/01-results-by-line.Rmd`.
- Define a new, exported and documented function `available_lines()` in `R/data.R`, used in the R Markdown above to loop over the available lines.
- In a new source file `R/site.R`, define an exported, documented `render_render_site()` function.
- Declare new dependency via `usethis::use_package("bookdown")`.
- Generate documentation, install.
- Test website rendering at the command line:
- `website <- vbzdelays::render_site(output_dir = tempfile("_site"))`
- `browseURL(website)`
- Update README with new example usage.

Run checks locally, commit & push.


### Setup GitHub Pages branch

In the terminal, run:
``` bash
git checkout --orphan gh-pages
git rm -rf .
echo "# Hello World" > index.md
git add index.md
git commit -m "Initial commit"
git push origin gh-pages
```

You should see an "Hello World" website at https://USERNAME.github.io/vbzdelays.

Switch back to the `master` branch.


### Continuous deployment on Travis

Setup Travis CI to automatically render and deploy the website to GitHub pages upon any push to the `master` branch.

See the slides for the creation of a Personal Access Token (PAT) on GitHub and definition of the secure variable `GITHUB_PAT` on Travis.

Add the following to `.travis.yaml`:

``` yaml
before_deploy:
- R CMD INSTALL $PKG_TARBALL
- Rscript -e "vbzdelays::render_site()"

deploy:
  provider: pages
  skip_cleanup: true
  github_token: $GITHUB_PAT # Set in the settings page of your repository, as a secure variable
  local_dir: _site
  on:
    branch: master
```

Commit & push, check the progress on Travis, and then browse to the rendered website  https://USERNAME.github.io/vbzdelays.


### First release

We want to start using semantic versioning for the vbzdelays package to track future updates and corresponding changes.

- Setup a changelog as `NEWS.md` file via `usethis::use_news_md()`, adding relevant information about this first version of the package.
- Define a new major version (1.0.0) via `usethis::use_version("major")`.
- Commit & push.
- Create release on GitHub as "v1.0.0", with title "vbzdelays 1.0.0" and as content the corresponding `NEWS.md` section.


### GitFlow setup

After creating a `develop` branch (on GitHub)

- Pull the branch and switch to it locally (e.g. on the Git pane of RStudio)
- _Bump_ the package revision to include .9000: `usethis::use_dev_version()`
- Commit & push

Setup branch restrictions and agile setup as GitHub project (check slides).


### New feature 

From `develop`, create on GitHub a novel branch for the new feature `feature/1-add-coverage-label`. Implement the feature in the local checkout of `feature/1-add-coverage-label`.

- Extend `analysis.R` and `plot.R`, run tests and examples to see the outcome.
- Add a bullet about the new feature in the development section of `NEWS.md`.
- Commit & push.
- Create a pull request to `develop` on GitHub, get it approved and  merged.


### New release 

We want to release the new feature(s) as a minor release with version 1.1.0

- Create branch `release/v1.1.0` from `develop`.
- Update the package version via `usethis::use_version("minor")` locally on branch `release/v1.1.0`.
- Commit & push.
- Create a pull request to `master` on GitHub, get it approved and merged.
- Create release on GitHub as "v1.1.0", with title "vbzdelays 1.1.0" and content of the corresponding `NEWS.md` section.
- Go back to a development version `usethis::use_dev_version()` locally, still on branch `release/v1.1.0`.
- Commit & push.
- Create a pull request to `develop` on GitHub, get it approved and merged.
- Delete the release branch.
