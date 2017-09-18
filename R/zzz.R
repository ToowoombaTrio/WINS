.onAttach <- function(libname, pkgname) {
  msg <-
    paste0(
      "\nWINS uses data provided by the Australian Government Bureau of\n",
      "Meteorology, which is released under the Creative Commons (CC)\n",
      "Attribution 3.0 licence or Public Access Licence (PAL) as\n",
      "appropriate, see <http://www.bom.gov.au/other/copyright.shtml> and\n",
      "hole-filled seamless SRTM data V4 aggregated to 250m available from\n",
      "<http://srtm.csi.cgiar.org>.\n"
    )
  packageStartupMessage(msg)
}
