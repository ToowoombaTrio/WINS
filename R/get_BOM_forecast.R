

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
    foreign::read.dbf(paste0(tempdir(), "AAC_codes.dbf"), as.is = TRUE)
  AAC_codes <- AAC_codes[, c(2:3, 7:9)]

  # fetch BOM foreast for Qld
  xmlforecast <-
    xml2::read_xml("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml")

  # extract locations from forecast
  areas <- xml2::xml_find_all(xmlforecast, "//forecast/area")
  forecast_locations <-
    dplyr::bind_rows(lapply(xml2::xml_attrs(areas), as.list))

  # join locations with lat/lon values for mapping and interpolation
  forecast_locations <- dplyr::left_join(forecast_locations,
                                         AAC_codes,
                                         by = c("aac" = "AAC",
                                                "description" = "PT_NAME"))


  forecasts <-
    lapply(xml2::xml_find_all(xmlforecast, "//forecast/area"), as_list)

  forecasts <- plyr::llply(forecasts, unlist)

  names(forecasts) <- forecast_locations$aac

  # get all the <element>s
  elements <- xml2::xml_find_all(xmlforecast, "//element")

  # extract and clean all the columns
  values <- trimws(xml2::xml_text(elements))

  # extract and clean (if needed) the area names
  labs <- trimws(xml2::xml_attr(elements, "type"))

  y <- NULL
  for (i in unique(names(forecasts))) {
    x <- data.frame(
      keyName = names(forecasts[[i]]),
      value = forecasts[[i]],
      row.names = NULL
    )
    z <- names(forecasts[i])
    x <- data.frame(rep(z, nrow(x)), x)
    y <- dplyr::bind_rows(y, x)
  }


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

}
