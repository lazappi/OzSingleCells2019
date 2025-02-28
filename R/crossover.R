
#' Summarise the crossver between two clusterings
#'
#' @param clusts data.frame with clustering information for each cell
#' @param clust1 name of the first clustering column
#' @param clust2 name of the second clustering column
#'
#' @return data.frame with summarise crossover information
summariseClusts <- function(clusts, clust1, clust2) {
    `!!` <- rlang::`!!`
    `:=` <- rlang::`:=`

    clust1 <- rlang::enquo(clust1)
    clust2 <- rlang::enquo(clust2)

    clusts %>%
        dplyr::mutate(
            !!rlang::quo_name(clust1) := factor(!!clust1),
            !!rlang::quo_name(clust2) := factor(!!clust2)
        ) %>%
        dplyr::filter(!is.na(!!clust1) & !is.na(!!clust2)) %>%
        dplyr::group_by(!!clust1, !!clust2) %>%
        dplyr::summarise(Count = n()) %>%
        dplyr::ungroup() %>%
        tidyr::complete(!!clust1, !!clust2) %>%
        dplyr::group_by(!!clust1) %>%
        dplyr::mutate(
            !!paste0(rlang::quo_name(clust1), "Total") :=
                sum(Count, na.rm = TRUE),
            !!paste0(rlang::quo_name(clust1), "Pct") :=
                Count / sum(Count, na.rm = TRUE)
        ) %>%
        dplyr::group_by(!!clust2) %>%
        dplyr::mutate(
            !!paste0(rlang::quo_name(clust2), "Total") :=
                sum(Count, na.rm = TRUE),
            !!paste0(rlang::quo_name(clust2), "Pct") :=
                Count / sum(Count, na.rm = TRUE)
        ) %>%
        dplyr::mutate(
            Jaccard = Count /
                (!!rlang::sym(paste0(quo_name(clust1), "Total")) +
                     !!rlang::sym(paste0(quo_name(clust2), "Total")) -
                     Count)
        )
}
