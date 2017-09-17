
#' Downscale BoM Précis Daily Forecast Data to Hourly Values
#'
#' @details
#' Creates a dataframe of hourly temperature values based on the Australian
#' Bureau of Meteorology (BOM) daily précis weather forecasts by using
#' \code{\link{make_hourly_temps}} from \code{\link{chillR}}.
#'
#' @param forecast A BoM generated forecast as returned by
#' \code{\link{get_precis_forecast}}.
#'
#' @return
#' A list of \code{data.frame} objects sorted by Julian day for spatial
#' interpolation.
#'
#' @examples
#' \dontrun{Qld_hourly <- make_hourly_forecast()}
#'
#' @author Adam H Sparks
#' @importFrom rlang .data
#' @export
make_hourly_forecast <- function(forecast) {

  # drop day zero from data, only need next 6 days of the forecast
  forecast_weather <-
    precis_forecast[precis_forecast["index"] != 0, ]

  # create dataframe with aac and lat/lon values only to joining with final data
  aac_lat_lon <- unique(precis_forecast[, c(5, 6, 7, 8)])

  # extract the latitude values for hourly downscaling
  latitude <-
    as.vector(t(unique(forecast_weather[c("lat", "aac")])[-2]))

  # set up the year_file object for make_hourly_temps() ------------------------
  forecast_weather <- tidyr::separate(
    data = forecast_weather,
    col = .data$start_time_local,
    into = c("Year", "Month", "Day"),
    sep = "-"
  )
  forecast_weather <- dplyr::mutate_at(
    .tbl = forecast_weather,
    .vars = c("Year", "Month", "Day"),
    .funs = as.numeric
  )
  forecast_weather <- dplyr::select_at(
    .tbl = forecast_weather,
    .vars = c(
      "aac",
      "Year",
      "Month",
      "Day",
      "minimum_temperature",
      "maximum_temperature"
    )
  )
  names(forecast_weather)[5] <- "Tmin"
  names(forecast_weather)[6] <- "Tmax"

  # split the forecast weather into individual dataframes in a list ------------
  forecast_weather <-
    split(forecast_weather, forecast_weather["aac"])

  downscaled_list <- vector("list", length(forecast_weather))

  for (i in seq_len(length(forecast_weather))) {
    downscaled_list[[i]] <-
      chillR::make_hourly_temps(latitude = latitude[i],
                                year_file = forecast_weather[[i]])
  }

  downscaled_temp <-
    as.data.frame(data.table::rbindlist(downscaled_list))
  downscaled_temp <-
    tidyr::gather(downscaled_temp,
                  .data$Hour,
                  .data$temperature,
                  .data$Hour_1:.data$Hour_24)

  downscaled_temp <- dplyr::left_join(downscaled_temp, aac_lat_lon,
                                      by = "aac")

  # split the downscaled data into individual dataframes in a list of Jdays ----
  downscaled_temp <-
    split(downscaled_temp, downscaled_temp["JDay"])
  return(downscaled_temp)
}