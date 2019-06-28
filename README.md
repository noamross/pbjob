# pbjob

 <!-- badges: start -->
 [![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
  [![Travis build status](https://travis-ci.org/noamross/pbjob.svg?branch=master)](https://travis-ci.org/noamross/pbjob)
  <!-- badges: end -->

Run R scripts with Pushbullet Alerts

## Installation

``` r
remotes::install_github("noamross/pbjob")
```

## Setup

To use this package you need to use [Pushbullet](https://www.pushbullet.com/) on
your mobile device or browser and to set up the
[**RPushbullet**](https://github.com/eddelbuettel/rpushbullet) package. Details
in that package README, but in short, do this just once:

- Sign up for Pushbullet and install it on your devices/browsers if you haven't
  already.
- Log in to <https://www.pushbullet.com/#settings>, click on "Create Access
  Token", and get the token.
- Run `RPushbullet::pbSetup(<YOUR_ACCESS_TOKEN>)` to create a config file and
  select your default devices to send messages to.
- Restart R

##  Functions

The package has four functions, each of which has an accompanying RStudio Add-In

- `source_and pb(script_path)` runs a script and sends a Pushbullet alert when
  it is complete.  An alert is also sent if the script errors. If `script_path`
  is `NULL`, the RStudio interface is used to select a file.
- `bg_and_pb()` runs the script in a background session with the same alerts.
  It returns an [`r_process`](https://callr.r-lib.org/reference/r_bg.html) object.
- `source_current_and_pb()` and `bg_current_and_pb()` do the same but run
  the current active file in the RStudio editor.
  
Note that background sessions are child processes of the R session in which they
are launched, and will be killed is if you quit or restart R.

---

Please note that the 'pbjob' project is released with a 
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project, you agree to abide by its terms.
