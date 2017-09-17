
#' Test BoM Précis Forecast for Changes and Send an Alert on Changes or Failure
#'
#' @details
#' Tests the current BoM forecast against the prior day's forecast for changes
#' and sends an e-mail alert on change or failure.
#'
#' @return
#'E-mail if issues are encountered.
#'
#' @examples
#' \dontrun{unit_test(AUS_forecast)}
#'
#' @author Keith Pembleton
#'
#' @export
unit_test_forecast <- function(AUS_forecast) {
  # Check the columns critical to to WINS ie max and min temp ------------------
  if (is.numeric(AUS_forecast$maximum_temperature) == FALSE ||
      is.numeric(AUS_forecast$minimum_temperature) == FALSE ||
      (sum(
        stats::na.omit(
          AUS_forecast$maximum_temperature - AUS_forecast$minimum_temperature
        ) >= 0
      ) > 0) == FALSE) {
    mailR::send.mail(
      from = project_email_address,
      to = report_email_addresses,
      subject = "Critical error in WINS unit testing",
      body = "Hello from the WINS project server. There is a critical issue\n",
      "with the precis forecast. WINS has aborted, immediate\n",
      "attention is required.\n",
      smtp = list(
        host.name = "smtp.gmail.com",
        port = 465,
        user.name = project_email_address,
        passwd = project_email_password,
        ssl = TRUE
      ),
      authenticate = TRUE,
      send = TRUE
    )

  }


  # Check for non critical additions and removals from the precis forecast -----


  current_location <-
    (unique(
      data.frame(AUS_forecast$town, AUS_forecast$lat, AUS_forecast$lon)
    ))
  yesterday_location <-
    (unique(
      data.frame(
        yesterdays_forecast$town,
        yesterdays_forecast$lat,
        yesterdays_forecast$lon
      )
    ))

  names(current_location) <-
    c("town", "AUS_forecast.lat", "AUS_forecast.lon")
  names(yesterday_location) <-
    c("town",
      "yesterdays_forecast.lat",
      "yesterdays_forecast.lon")

  added_sites <- dplyr::anti_join(current_location, yesterday_location)
  removed_sites <- dplyr::anti_join(yesterday_location, current_location)

  if (nrow(removed_sites) == 0) {
    removed_sites <- "none"
  }

  if (removed_sites != "none") {
    removed_sites <-
      paste(as.character(removed_sites$town),
            sep = "",
            collapse = "")
  }

  if (nrow(added_sites) == 0) {
    added_sites <- "none"
  }

  if (added_sites != "none") {
    added_sites <-
      paste(as.character(added_sites$town),
            sep = "",
            collapse = "")
  }



  difference_in_forecast_days <-
    "There are no differences in the forecast days"
  difference <-
    (max(as.numeric(as.character(
      AUS_forecast$index
    ))) - max(as.numeric(
      as.character(yesterdays_forecast$index)
    )))
  difference <- as.character(difference)

  if (difference > 0) {
    difference_char <- as.character(difference)
    difference_in_forecast_days <-
      paste(
        "BOM has added",
        difference_char,
        "days to their forecast. They now forecast for",
        max(as.numeric(as.character(
          AUS_forecast$index
        ))),
        "days"
      )
  }

  if (difference < 0) {
    difference_char <- as.character(abs(difference))
    difference_in_forecast_days <-
      paste(
        "BOM has removed",
        difference_char,
        "days from their forecast. They now forecast for",
        max(as.numeric(as.character(
          AUS_forecast$index
        ))),
        "days"
      )
  }

  current_headers <- colnames(AUS_forecast)
  yesterdays_headers <- colnames(yesterdays_forecast)
  parameters_different <-
    setdiff(current_headers, yesterdays_headers)
  if (length(parameters_different) == 0) {
    parameters_different <- "There are no parameters that are different"
  }
  parameters_different <-
    paste(
      "BOM has either added or removed the following parameters from the\n",
      "précis forecast:",
      parameters_different,
      ".\n"
    )


  if (length(parameters_different) > 0 ||
      difference != 0 ||
      removed_sites != "none" || added_sites != "none") {
    email_body <-
      paste(
        "Hello from the WINS project server.",
        parameters_different,
        difference_in_forecast_days,
        ". BOM has added the following sites:",
        added_sites,
        ", and has removed the follosing sites:",
        removed_sites,
        ". Checking the forecast is recomended"
      )


    mailR::send.mail(
      from = project_email_address,
      to = report_email_addresses,
      subject = "WINS unit testing report",
      body = email_body,
      smtp = list(
        host.name = "smtp.gmail.com",
        port = 465,
        user.name = project_email_address,
        passwd = project_email_password,
        ssl = TRUE
      ),
      authenticate = TRUE,
      send = TRUE
    )
  }
}
