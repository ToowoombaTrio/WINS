
#'Calculate Hours of Temperature Stress
#'
#' @details
#' Calculates hours temperature stress given a list of interpolated surfaces of
#' a BoM six-day forecast from \link{interpolate_hourly}.
#'
#' @param forecast_surface A list of interpolated hourly temperature surfaces
#' from \code{\link{interpolate_hourly}}.
#' @param location A given location for which the temperature threshold is to
#' be checked against.  Should be provided as an \code{\link[sf]{points}} or
#' \code{\link[sp]{polygon}} object.
#' @param threshold A numeric value against which interpolated temperatures are
#' checked for exceeding.
#'
#' @examples
#'
#' \dontrun{
#'
#' library(sp)
#' locations <-
#'  structure(
#'    list(
#'      longitude = c(
#'        151.9134,
#'        151.7387
#'      ),
#'      latitude = c(
#'        -27.7952,
#'        -27.5425
#'      )
#'    ),
#'    .Names = c("longitude",
#'               "latitude"),
#'    class = "data.frame",
#'    row.names = c(NA, -2L))
#'
#' xy <- locations[, c(1, 2)]
#'
#' locations <- SpatialPointsDataFrame(
#'  coords = xy,
#'  data = location,
#'  proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
#' )
#'
#' mungbean_stress <- calculate_hours(x, location = locations, 30)}
#'
#' @export

calculate_hours <-
  function(interpolated_surfaces,
           location,
           threshold) {
    # extract xy locations in rasters from locations object

    # align those with interpolated surfaces



    hours_of_high_temps <-
      c(hours_of_high_temps,
        length(interpolated_surfaces[, x][interpolated_surfaces[, x] >
                                            temp_threshold]))

  }
