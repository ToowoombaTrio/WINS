
#' Downscale BoM weather and forecasts to hourly data for spatial interpolation
#'
#'
#' @details
#'An R function which formats Australian Bureau of Meteorology (BoM) hourly
#'weather data and Queensland's Scientific Information for Land Owners (SILO)
#'daily weather data for validation of temporal downscaling of SILO temperature
#'data to hourly values.
#'
#' @examples
#' \dontrun{downscale()}
#'
#' @importFrom foreach %dopar%
#'
#' @export
downscale <- function() {
  station_number <- NULL
  Hour <- NULL
  SILO_TMP <- NULL
  Hour_01 <- NULL
  Hour_24 <- NULL

  opt <- settings::options_manager(warn = 2,
                                   timeout = 300,
                                   stringsAsFactors = FALSE)
  weather <- # Use previous weather data here

  forecast <- # Use BOM forecast here

  i <- NULL
  j <- NULL
  lat <- df <- JDay <- NULL
  temp2 <- vector(mode = "list")

  cl <- parallel::makeCluster(2)
  doParallel::registerDoParallel(cl)

  itx <- NULL

  merged <- as.data.frame(data.table::rbindlist(foreach::foreach(i = itx) %dopar% {

    # Calculate hourly temps from SILO daily data ---------------------------
    SILO_hourly <- chillR::make_hourly_temps(lat, df)
    SILO_hourly$station_number <-
      as.character(rep(j, nrow(SILO_hourly)))
    names(SILO_hourly) <-
      c(
        "Tmin",
        "Tmax",
        "JDay",
        "Hour_01",
        "Hour_02",
        "Hour_03",
        "Hour_04",
        "Hour_05",
        "Hour_06",
        "Hour_07",
        "Hour_08",
        "Hour_09",
        "Hour_10",
        "Hour_11",
        "Hour_12",
        "Hour_13",
        "Hour_14",
        "Hour_15",
        "Hour_16",
        "Hour_17",
        "Hour_18",
        "Hour_19",
        "Hour_20",
        "Hour_21",
        "Hour_22",
        "Hour_23",
        "Hour_24",
        "station_number"
      )
    SILO_hourly <- tidyr::gather(SILO_hourly, Hour, SILO_TMP,
                                 Hour_01:Hour_24)
    SILO_hourly <- SILO_hourly[, -c(1:2)]

    SILO_hourly <- plyr::arrange(SILO_hourly, JDay, Hour)
    temp <- plyr::arrange(temp, JDay, Hour)

    temp2[[i]] <- plyr::join(
      temp,
      SILO_hourly,
      by = c("station_number", "JDay",
             "Hour"),
      type = "left"
    )

  }))
  parallel::stopCluster(cl)
  settings::reset(opt)
  return(merged)
}
