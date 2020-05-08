# Heroku Buildpack: R

[![Build Status][travis_img]][travis]

This is a [Heroku Buildpack][buildpacks] for applications which use [R][rproject] for statistical computing and [CRAN][cran] for R packages.

R is ‘GNU S’, a freely available language and environment for statistical computing and graphics which provides
a wide variety of statistical and graphical techniques: linear and nonlinear modelling, statistical tests, time
series analysis, classification, clustering, etc. Please consult the [R project homepage][rproject] for further information.

[CRAN][cran] is a network of ftp and web servers around the world that store identical, up-to-date, versions of code
and documentation for R.

It also includes support for the [Packrat][packrat] package manager and the [Shiny][shiny] and [Plumber][plumber] web application frameworks.

## Usage

To use this version, the buildpack URL is `https://github.com/virtualstaticvoid/heroku-buildpack-r.git#heroku-18`.

The buildpack will detect your application makes use of R if has one (or more) of the following files in the project directory:

* `init.R`
* `packrat/init/R`
* `run.R`
* `app.R`
* `plumber.R`

Additionally, when R is vendored into your slug:

* If the `run.R` file is found, the buildpack will be configured as a Shiny application.
* If the `plumber.R` file is found, the buildpack will be configured as a Plumber application.

If the `init.R` file is found, it is executed in order to install any additional R packages, and if the `packrat/init.R` file is found, `packrat` will be bootstrapped and any packages installed.

See the [detect](bin/detect) script for the matching logic used.

### Installing R Packages

The `init.R` file can be used to install R packages if required.

The following example file can be used. Provide the package names you want to install to the `my_packages` list:

```
# init.R
#
# Example R code to install packages if not already installed
#

my_packages = c("package_name_1", "package_name_2", ...)

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))
```

R packages can also be installed by providing a `tar.gz` package archive file, if a specific version is required, or
it is not a publicly published package. See [local-packages](test/local-packages) for an example.

```
# init.R
#
# Example R program to installed package from local path
#

install.packages("/app/PackageName-Version.tar.gz", repos=NULL, type="source")
```

*NOTE:* The path to the package archive needs to be an absolute path, based off the `/app` root path, which is the location of your applications files on Heroku.

*NOTE:* Using [Packrat][packrat] is the preferred way to manage your package dependencies and their respective versions.

### Installing Binary Dependencies

This version of the buildpack no longer supports the use of the `Aptfile` for installing additional system packages. There are various technical and security reasons why this is no longer possible.

If any of your R packages dependend on additional system libraries, such as `libgmp`, `libgomp`, `libgdal`, `libgeos` and `libgsl`, you will need to use the Heroku [container stack][container-stack] together with [heroku-docker-r][heroku-docker-r] instead.

### Heroku Console

You can run the R console application as follows:

```
$ heroku run R ...
```

Type `q()` to exit the console when you are finished.

You can also run the `Rscript` utility as follows:

```
$ heroku run Rscript ...
```

_Note that the Heroku slug is read-only, so any changes you make during the session will be discarded._

### Shiny Applications

Shiny applications must provide a `run.R` file, but can also include an `init.R` in order to install additional R packages. The Shiny package does not need to be installed, as it is included in the buildpack already.

The `run.R` file should contain at least the following code, in order to run the web application.
Notice the use of the `PORT` environment variable, provided by Heroku, which is used to configure Shiny and the host must be `0.0.0.0`.

```
# run.R
library(shiny)

port <- Sys.getenv('PORT')

shiny::runApp(
  appDir = getwd(),
  host = '0.0.0.0',
  port = as.numeric(port)
)
```

### Plumber Applications

Plumber applications must provide an `app.R` file, but can also include an `init.R` in order to install additional R packages. The Plumber package does not need to be installed, as it is included in the buildpack already.

The `app.R` file should contain at least the following code, in order to run the web application.
Notice the use of the `PORT` environment variable, provided by Heroku, which is used to configure Shiny and the host must be `0.0.0.0`.

```
# app.R
library(plumber)

port <- Sys.getenv('PORT')

server <- plumb("plumber.R")

server$run(
  host = '0.0.0.0',
  port = as.numeric(port)
)
```

### Scheduling a Recurring Job

You can use the [Heroku scheduler][scheduler] to schedule a recurring R process.

An example command for the scheduler, to run `prog.R`, would be `R -f /app/prog.R --gui-none --no-save`.

## Technical Details

### R Versions

The buildpack currently supports `R 3.6.3`. This is updated periodically when new versions of R are released.

### Buildpack Binaries

The binaries used by the buildpack are hosted on AWS S3 at [https://heroku-buildpack-r.s3.amazonaws.com][s3].

See the [heroku-buildpack-r-build][build2] repository for building the buildpack binaries yourself.

### Process Types

The buildpack includes the following default process types:

* `console`: Executes the `R` terminal application, which is typically used for debugging.
* `web`: Executes `run.R` to run Shiny or Plumber applications.

The `R` and `Rscript` executables are available like any other executable, via the `heroku run` command.

### Caching

To improve the time it takes to deploy the buildpack caches the R binaries and installed R packages.

If you need to purge the cache, it is possible by using [heroku-repo][heroku-repo] CLI plugin via the `heroku repo:purge_cache` command.

See the [purge-cache][purge] documentation for more information.

### CRAN Mirror Override

It is possible to override the default CRAN mirror used, by providing the URL via the `CRAN_MIRROR` environment variable.

E.g. Override the URL by setting the variable as follows.

```
heroku config:set CRAN_MIRROR=https://cloud.r-project.org/
```

Check the CRAN [mirror status][mirrors] page to ensure the mirror is available.

## Credits

* Original inspiration from [Noah Lorang's Rook on Heroku][rookonheroku] project.
* Script snippets from the [rstudio/r-builds][r-builds] project.
* Tests from the [rstudio/r-docker][r-docker] project.
* [fakechroot][fakechroot] library.
* [tcl/tk][tcltk] library.

## License

MIT License. Copyright (c) 2020 Chris Stefano. See [LICENSE](LICENSE) for details.

[build2]: https://github.com/virtualstaticvoid/heroku-buildpack-r-build2
[buildpacks]: https://devcenter.heroku.com/articles/buildpacks
[container-stack]: https://devcenter.heroku.com/categories/deploying-with-docker
[cran]: https://cran.r-project.org
[fakechroot]: https://github.com/dex4er/fakechroot/wiki
[heroku-docker-r]: https://github.com/virtualstaticvoid/heroku-docker-r
[heroku-repo]: https://github.com/heroku/heroku-repo
[mirrors]: https://cran.r-project.org/mirmon_report.html
[packrat]: http://rstudio.github.io/packrat
[plumber]: https://www.rplumber.io
[purge]: https://github.com/heroku/heroku-repo#purge-cache
[r-builds]: https://github.com/rstudio/r-builds
[r-docker]: https://github.com/rstudio/r-docker
[rookonheroku]: https://github.com/noahhl/rookonheroku
[rproject]: https://www.r-project.org
[s3]: https://heroku-buildpack-r.s3.amazonaws.com
[scheduler]: https://addons.heroku.com/scheduler
[shiny]: https://shiny.rstudio.com
[tcltk]: https://www.tcl.tk
[travis]: https://travis-ci.org/virtualstaticvoid/heroku-buildpack-r
[travis_img]: https://travis-ci.org/virtualstaticvoid/heroku-buildpack-r.svg?branch=master
