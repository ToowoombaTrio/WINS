####packages required####
#install.packages("toowoombatrio/bomrang")
#install.packages("mailR")
#install.packages("dplyr")

setwd("C:/Users/U8004449/Documents/USQ/WINs/WINS")

library(dplyr)
library(bomrang)
library(mailR)

#####project email adress and password
project_email_address <- "wins.testing.usq@gmail.com"
project_email_password <- ""

#####emails adresses for unit testing and subscriber reports
report_email_adresses <-
  c("Keith.Pembleton@usq.edu.au", "Adam.Sparks@usq.edu.au")


####bring in the precis forecast#####
AUS_forecast <- get_precis_forecast(state = "AUS")
head(AUS_forecast, 10)
####unit test the AUS forecast
###############load up yesterdays forecast for comparison###########
yesterdays_forecast <-
  read.csv(file = "yesterdays_forecast.csv", header = TRUE, sep = ",")

###load up a dummy data set for todays forecast that we know will cause errors
AUS_forecast <-
  read.csv(file = "dummy_forecast.csv", header = TRUE, sep = ",")

# Test the forecast for changes ------------------------------------------------
unit_test_forecast(AUS_forecast)

# Downscale the tested forecast ------------------------------------------------
downscaled_temp <- make_hourly_forecast(AUS_forecast)

# Interpolate the downscaled temperature ---------------------------------------
interpolate(downscaled_temp) # doesn't yet work!

# Save the forecast for checking tomorrow --------------------------------------
write.csv(AUS_forecast, file = "yesterdays_forecast.csv", row.names = FALSE)
