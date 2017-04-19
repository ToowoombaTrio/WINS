#' Get BOM Forecast
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
  # get BOM station list
  utils::download.file(
    "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
    destfile = paste0(tempdir(), "AAC_codes.dbf"),
    mode = "wb"
  )

  AAC_codes <-
    foreign::read.dbf(paste0(tempdir(), "AAC_codes.dbf"))

  xmlfile <-
    xml2::read_xml("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml")

  forecast_locations <- rvest::xml_nodes(xmlfile, "area") %>%
    purrr::map(xml2::xml_attrs) %>%
    purrr::map_df( ~ as.list(.))

  forecast_locations <- dplyr::left_join(forecast_locations,
                                         AAC_codes,
                                         by = c("aac" = "AAC",
                                                "description" = "PT_NAME"))
  forecast_locations <-
    stats::na.omit(forecast_locations[, c(1:2, 9:11)])

  # get all the <element>s
  recs <- xml2::xml_find_all(xmlfile, "//element")

  # extract and clean all the columns
  vals <- trimws(xml2::xml_text(recs))

  # extract and clean (if needed) the area names
  labs <- trimws(xml2::xml_attr(recs, "type"))
  indices <- c(0, rep(1:7, each = 4))

  forecast <- data.frame(
    rep(indices, 112),
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

  names(forecast) <-
    c("day_index",
      "aac",
      "location",
      "lon",
      "lat",
      "elev",
      "wvar",
      "value")
  forecast <- forecast[forecast$wvar != "forecast_icon_code", ]
  return(forecast)
}
