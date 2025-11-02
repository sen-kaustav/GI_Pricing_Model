# GI Pricing Model

## Background :briefcase:

_**TODO:** Expand this section once we have a bit more structure in terms of what we wil be doing._

Aim is to try out different types of statistical and machine learning models on an GI Motor insurance dataset.

**Tasks:**

* Decide on the dataset to use.

* Carry out initial exploratory analysis.

* Start modelling!

* Probably end up with a dashboard using Shiny.

## Project setup :rocket:

We make use of the `renv` package to make sure that everyone is using a consistent set of packages.  This also makes it very straightforward to install all the necessary packages without having to manually install them individually.

The project has been setup using RStudio and uses git and github for version control. For those unfamiliar with git/github, [Happy Git and GitHub for the useR](https://happygitwithr.com/) provides an excellent introduction.

The below steps outline the worflow to adopt when working on this project:

* Always pull the latest codebase from github before making any incremental changes.
  <img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/7707abde-86b4-45ed-9748-348bd6cdd3bb" />
* Run `renv::restore()` to ensure you have the most up-to-date set of packages and any new dependencies.
* It is recommended to use `pak::pak()` to install any new packages. This provides an unified interface to install packages from CRAN, Github and other sources. However, use can also use `install.packages()` if that's your preferred approach. 
* Before pushing changes to github make sure to run `renv::sanpshot()`.

**Note:** If it is the first time your are taking a copy of this project, you might first need to install `renv`. 
