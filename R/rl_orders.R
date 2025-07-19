#' IUCN Red List taxa by order
#'
#' Retrieve species assessments by taxonomic order.
#' If `order_name = NULL`, it returns a list of available orders.
#' If `order_name` is provided, it retrieves assessments for species in the specified order.
#'
#' @param order_name Character. The order name (e.g., "Carnivora").
#' Use [rl_orders()] to list available orders.
#' @inheritParams rl_biogeographical_realms
#' @return A tibble containing orders or species assessments.
#'
#' @examples \dontrun{
#' # List all available orders
#' rl_orders()
#'
#' # Get assessments for Carnivora order
#' rl_orders(order_name = "Carnivora")
#'
#' # Get latest Primates assessments published in 2022
#' rl_orders(
#'   order_name = "Primates",
#'   year_published = 2022,
#'   latest = TRUE
#' )
#'}
#' @export
rl_orders <- function(order_name = NULL,
                      year_published = NULL,
                      latest = NULL,
                      scope_code = NULL,
                      page = 1,
                      pad_with_na = FALSE) {

  base_url <- "https://api.iucnredlist.org/api/v4/taxa/order"

  if (is.null(order_name)) {
    resp <- perform_request(base_url = base_url) %>%
      httr2::resp_body_json()%>%
      json_to_df(pad_with_na = pad_with_na) %>%
      t() %>% as.data.frame()
    colnames(resp) <- "order_names"
    rownames(resp) <- NULL
    return(dplyr::as_tibble(resp))
  }

  rl_paginated_query(
    param_list = list(order_name = order_name,
                      year_published = year_published %||% NA,
                      latest = latest %||% NA,
                      scope_code = scope_code %||% NA,
                      page = page %||% NA),
    base_url = base_url,
    endpoint_name = "order_name",
    pad_with_na = pad_with_na)
}
