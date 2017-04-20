
#' Get BOM Forecast for Queensland
#'
#'Fetch the BOM forecast and create a data frame object that can be used for
#'interpolating.
#'
#' @return
#' Data frame of a Australia BOM forecast for Queensland for max temperature,
#' min temperature and precipitation.
#'
#' @examples
#' \dontrun{
#' BOM_forecast <- get_BOM_forecast()
#' }
#' @export
#'
#' @importFrom dplyr %>%
get_BOM_forecast <- function() {
  # BOM station list - a .dbf file (part of a shapefile of station locations)
  # AAC codes can be used to add lat/lon to the forecast
  utils::download.file(
    "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
    destfile = paste0(tempdir(), "AAC_codes.dbf"),
    mode = "wb"
  )

  AAC_codes <-
    foreign::read.dbf(paste0(tempdir(), "AAC_codes.dbf"))

  # fetch BOM foreast for Qld
  xmlforecast <-
    xml2::read_xml("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml")

  # extract locations from forecast
  forecast_locations <- xml2::xml_find_all(xmlforecast, "//area") %>%
    purrr::map(xml2::xml_attrs) %>%
    purrr::map_df( ~ as.list(.))

  # join locations with lat/lon values for mapping and interpolation
  forecast_locations <- dplyr::left_join(forecast_locations,
                                         AAC_codes,
                                         by = c("aac" = "AAC",
                                                "description" = "PT_NAME"))

  # remove any rows with missing values, e.g. Districts or all of Qld.
  # Not all areas have a forecast, only the lowest level has a forecast
  # Higher levels do not
  forecast_locations <-
    stats::na.omit(forecast_locations[, c(1:2, 9:11)])

  # get all the <element>s
  recs <- xml2::xml_find_all(xmlforecast, "//element")

  # extract and clean all the columns
  vals <- trimws(xml2::xml_text(recs))

  # extract and clean (if needed) the area names
  labs <- trimws(xml2::xml_attr(recs, "type"))
  indices <- c(0, rep(1:7, each = 4))

  # create a dataframe of the forecast
  # the 29 won't change unless BOM decides to offer a longer or shorter forecast
  # day = 0 current, days 1 - 7 = a forecast with 4 elements for 29 total
  forecast <- data.frame(
    rep(indices, nrow(forecast_locations)),
    rep(as.vector(unlist(
      forecast_locations[, 1]
    )), each = 29),
    rep(as.vector(unlist(
      forecast_locations[, 2]
    )), each = 29),
    rep(as.vector(unlist(
      forecast_locations[, 3]
    )), each = 29),
    rep(as.vector(unlist(
      forecast_locations[, 4]
    )), each = 29),
    rep(as.vector(unlist(
      forecast_locations[, 5]
    )), each = 29),
    labs,
    vals
  )

  # name columns in the forecast dataframe something useful
  names(forecast) <-
    c("day_index",
      "aac",
      "location",
      "lon",
      "lat",
      "elev",
      "wvar",
      "value")

  # remove any rows that contain "forecast_icon_code", this is the first line
  # of any daily forecast and does not contain useable information
  forecast <- forecast[forecast$wvar != "forecast_icon_code", ]
}
