# MiraiLabs2Dependencies
This project contains the R dependencies used by the MiraiLabs2 project. 
The purpose of this project is to generate a Docker image with all the R 
dependencies required by MiraiLabs2. 
Thus MiraiLabs2 can build from this Docker image, 
which is pre-built with all the R dependencies, 
reducing the build time of MiraiLabs2 in about 30 minutes.

## Introduction

This is a Renku project - basically a git repository with some
bells and whistles. You'll find we have already created some
useful things like `data` and `notebooks` directories and
a `Dockerfile`.

## Working with the project

The simplest way to start your project is right from the Renku
platform - just click on the `Environments` tab and start a new session.
This will start an interactive environment right in your browser.

To work with the project anywhere outside the Renku platform,
click the `Settings` tab where you will find the
git repo URLs - use `git` to clone the project on whichever machine you want.

### Changing interactive environment dependencies

Initially we install a very minimal set of packages to keep the images small.
However, you can add python and conda packages in `requirements.txt` and
`environment.yml`, and R packages to `install.R` (listed as, for example,
`install.packages("ggplot2")`), to your heart's content. If you need more fine-grained
control over your environment, please see [the documentation](https://renku.readthedocs.io/en/latest/user/advanced_interfaces.html#dockerfile-modifications).

## Project configuration

Project options can be found in `.renku/renku.ini`. In this
project there is currently only one option, which specifies
the default type of environment to open, in this case `/rstudio`.

## Moving forward

Once you feel at home with your project, we recommend that you replace
this README file with your own project documentation! Happy data wrangling!
