
#' Interpolate
#'
#' @details
#' Interpolates weather data
#'
#' @param downscaled_temp Hourly temperature data from
#' \code{\link{make_hourly_forecast}}
#'
#' @examples
#' \dontrun{Qld_weather <- interpolate()}
#'
#' @export

interpolate <- function(downscaled_temp) {
  # Load DEM data
  load(system.file("extdata", "JSONurl_site_list.rda",
                   package = "bomrang"))

spline <- fields::Tps(data.frame(downscaled_temp$LONGITUDE,
                                 downscaled_temp$LATITUDE),
                      downscaled_temp$hours_of_high_temps)
grid <- fields::predictSurface(spline,
                               nx = 2000,
                               ny = 2000)
x <- raster::predict(spline,
                     cbind(151.9507,
                           -27.5598))
return(x)
}
