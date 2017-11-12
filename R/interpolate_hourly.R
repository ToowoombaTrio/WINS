
#' Interpolate BoM Précis Daily Forecast Data That Have Been Downscaled to Hourly
#'
#' @details
#' Interpolates forecast data that have been downscaled using the
#' \code{\link{make_hourly_forecast}} function and returns a list of
#' hourly #' surfaces for the next six-days forecast at 250x250m resolution.
#' List names are the Julian day followed by the hour, e.g., "316.1" being the
#' 316th day of the year and the first hour of the 24 hours.
#'
#' @param downscaled_temp Hourly temperature data from
#' \code{\link{make_hourly_forecast}}
#'
#' @examples
#'
#' \dontrun{Qld_weather <- interpolate_hourly(x)}
#'
#' @export

interpolate_hourly <- function(downscaled_temp) {

  # Load DEM
  Oz_dem <- NULL
  load(system.file("extdata", "Oz_dem.rda", package = "WINS"))

  # perform thin plate splining on the temperature data
  spline_list <- lapply(downscaled_temp, function(x)
    fields::Tps(x[c("lon", "lat", "elev")], x["temperature"]))

  # interpolate the daily/hourly surfaces
  tps_pred <- lapply(spline_list, function(y)
    raster::interpolate(
      model = y,
      object = Oz_dem,
      xyOnly = FALSE
    ))

  # return a list of interpolated surfaces by day by hour
  return(tps_pred)
}
