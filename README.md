
<<<<<<< HEAD
[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/John_Conner.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/John_Conner)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/John_Conner?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/John_Conner)

Saving Queensland crops from heat stress using OpenData since 2016!

## Install this package
To install this R package and recreate what we've done this weekend for Govhack2016. Install the package and check out our vignette that details how to recreate what we've done.

```r
install.packages("devtools", dependencies = TRUE)
devtools::install_github("ToowoombaTrio/John_Conner")
```
=======
<!-- README.md is generated from README.Rmd. Please edit that file -->
John\_Conner
============

[![Travis-CI Build Status](https://travis-ci.org/ToowoombaTrio/John_Conner.svg?branch=master)](https://travis-ci.org/ToowoombaTrio/John_Conner) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ToowoombaTrio/John_Conner?branch=master&svg=true)](https://ci.appveyor.com/project/ToowoombaTrio/John_Conner)

About
-----

John\_Conner is an R-package constructed as a part of GovHack 2016.

The JohnConner project was initiated by the Toowoomba Trio to tackle a major and growing problem faced by QLD vegetable growers. This challenge is identifying and responding to heat stress in their crops. High temperatures can cause considerable stress to crops, reducing yields and the quality of the produce grown. However, if the stress is identified early enough remedial action can be taken to minimise the damage and save the crop. The John Conner project provides a timely warning system for farmers when a heat stress event has likely occurred. Please watch our [YouTube video](https://m.youtube.com/watch?v=yECTDHx794E%20https://github.com/ToowoombaTrio/John_Conner) describing the John Conner Project. The John Conner project is built in the R environment, an open source statistical programing environment. It utilises the QLD SILO patch point weather data, available from the QLD government data portal, and models hourly data using a temperature from [chillR](https://www.google.com.au/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwiuzaPjw53OAhXHHZQKHTWSCO8QFggdMAA&url=https%3A%2F%2Fcran.r-project.org%2Fpackage%3DchillR&usg=AFQjCNEIRLgNXIVRHBXk0sqkM9Z1RiR_qw&sig2=nze6usBjw95mnsgL7u0vdQ). This downscaling is validated against the Bureau of Meteorology (BoM) hourly temperature data set, an official \#GovHack 2016 data set, to show that there is good agreement between the modelled hourly data and the observed BoM data.

Quick Start
===========

To install this R package and recreate what we've done this weekend for Govhack2016. Install the package and check out our vignette that details how to recreate what we've done.

``` r
if (!require("devtools")) {
  install.packages("devtools", repos = "http://cran.rstudio.com/") 
  library("devtools")
}

devtools::install_github("ToowoombaTrio/John_Conner")
library("JohnConner")
```
>>>>>>> master
