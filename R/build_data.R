# Build tidy long-format data for the Leaf and Bloom Dates indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Figures 1 and 2 share one layout: Year plus four series. Each header maps to
# an event (leaf or bloom) and a statistic, matched by header string.
SERIES <- data.frame(
  header    = c("Leaf Mean", "Leaf 9-yr normal curve", "Bloom Mean", "Bloom 9-yr normal curve"),
  event     = c("leaf", "leaf", "bloom", "bloom"),
  statistic = c("annual_mean", "9yr_normal_curve", "annual_mean", "9yr_normal_curve"),
  stringsAsFactors = FALSE
)

reshape_years <- function(raw, what) {
  out <- bind_rows(lapply(seq_len(nrow(SERIES)), function(i) {
    tibble(
      year      = raw$Year,
      event     = SERIES$event[i],
      statistic = SERIES$statistic[i],
      value     = raw[[SERIES$header[i]]]
    )
  }))
  out <- out[trimws(out$value) != "", ]
  assert_conservation(raw, SERIES$header, nrow(out), what)
  out
}

# Figures 3 and 4 are site-level maps: one row per Latitude/Longitude.
reshape_sites <- function(raw, value_header, what) {
  out <- tibble(latitude = raw$Latitude, longitude = raw$Longitude, value = raw[[value_header]])
  out <- out[trimws(out$value) != "", ]
  assert_conservation(raw, value_header, nrow(out), what)
  out
}

# ---- Indicator constants -----------------------------------------------------

INDICATOR <- list(
  name                    = "Leaf and Bloom Dates",
  slug                    = "leaf-and-bloom-dates",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-leaf-and-bloom-dates/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/system/files/documents/2024-06/leaf-bloom-dates_documentation.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: First Leaf and Bloom Dates in the Contiguous 48 States, 1900-2023 ----

f1_path <- file.path(raw_dir, "leaf-bloom_fig-1.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

# Series are matched by header string, so a rename or reorder stops the build.
assert_headers(
  f1_raw,
  id_cols          = "Year",
  expected_headers = c("Leaf Mean", "Leaf 9-yr normal curve", "Bloom Mean", "Bloom 9-yr normal curve"),
  what             = "leaf-bloom_fig-1.csv"
)

f1 <- reshape_years(f1_raw, "leaf-bloom_fig-1.csv")

write_csv_stable(f1, file.path(out_dir, "first_leaf_bloom_deviation_contiguous_48.csv"))

# ---- Figure 2: First Leaf and Bloom Dates in Alaska, 1950-2023 ----

f2_path <- file.path(raw_dir, "leaf-bloom_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

# Series are matched by header string, so a rename or reorder stops the build.
assert_headers(
  f2_raw,
  id_cols          = "Year",
  expected_headers = c("Leaf Mean", "Leaf 9-yr normal curve", "Bloom Mean", "Bloom 9-yr normal curve"),
  what             = "leaf-bloom_fig-2.csv"
)

f2 <- reshape_years(f2_raw, "leaf-bloom_fig-2.csv")

write_csv_stable(f2, file.path(out_dir, "first_leaf_bloom_deviation_alaska.csv"))

# ---- Figure 3: Change in First Leaf Date Between 1951-1960 and 2014-2023 ----

f3_path <- file.path(raw_dir, "leaf-bloom_fig-3.csv")
f3_meta <- read_epa_preamble(f3_path)
f3_raw  <- read_epa_csv(f3_path)

# Series are matched by header string, so a rename or reorder stops the build.
assert_headers(
  f3_raw,
  id_cols          = c("Latitude", "Longitude"),
  expected_headers = c("Change in first leaf date"),
  what             = "leaf-bloom_fig-3.csv"
)

f3 <- reshape_sites(f3_raw, "Change in first leaf date", "leaf-bloom_fig-3.csv")

write_csv_stable(f3, file.path(out_dir, "first_leaf_change_by_site.csv"))

# ---- Figure 4: Change in First Bloom Date Between 1951-1960 and 2014-2023 ----

f4_path <- file.path(raw_dir, "leaf-bloom_fig-4.csv")
f4_meta <- read_epa_preamble(f4_path)
f4_raw  <- read_epa_csv(f4_path)

# Series are matched by header string, so a rename or reorder stops the build.
assert_headers(
  f4_raw,
  id_cols          = c("Latitude", "Longitude"),
  expected_headers = c("Change in first bloom date"),
  what             = "leaf-bloom_fig-4.csv"
)

f4 <- reshape_sites(f4_raw, "Change in first bloom date", "leaf-bloom_fig-4.csv")

write_csv_stable(f4, file.path(out_dir, "first_bloom_change_by_site.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

# One entry per output column, in order. Names are taken from the data frame so
# the dictionary cannot drift; type and description are looked up by name.
COLUMN_DOCS <- list(
  year      = list("integer", "Calendar year of the observation."),
  event     = list("string", "Phenological event: first leaf or first bloom."),
  statistic = list("string", "annual_mean is the yearly average deviation; 9yr_normal_curve is EPA's smoothed 9-year curve."),
  value     = list("number", "Value in the dataset's unit (days). Years: deviation from the 1981-2010 average. Maps: change in first-event date between 1951-1960 and 2014-2023."),
  latitude  = list("number", "Site latitude in decimal degrees."),
  longitude = list("number", "Site longitude in decimal degrees.")
)

describe <- function(df) {
  lapply(names(df), function(nm) col(nm, COLUMN_DOCS[[nm]][[1]], COLUMN_DOCS[[nm]][[2]]))
}

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "first_leaf_bloom_deviation_contiguous_48.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "leaf-bloom_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "UTF-8",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = describe(f1)
    ),
    list(
      file            = "first_leaf_bloom_deviation_alaska.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "leaf-bloom_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = "UTF-8",
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns         = describe(f2)
    ),
    list(
      file            = "first_leaf_change_by_site.csv",
      figure          = "Figure 3",
      figure_title    = f3_meta$title,
      source_file     = "leaf-bloom_fig-3.csv",
      source_sha256   = file_sha256(f3_path),
      source_encoding = "UTF-8",
      data_source     = f3_meta$data_source,
      web_update      = f3_meta$web_update,
      unit            = "days",
      rows            = nrow(f3),
      columns         = describe(f3)
    ),
    list(
      file            = "first_bloom_change_by_site.csv",
      figure          = "Figure 4",
      figure_title    = f4_meta$title,
      source_file     = "leaf-bloom_fig-4.csv",
      source_sha256   = file_sha256(f4_path),
      source_encoding = "UTF-8",
      data_source     = f4_meta$data_source,
      web_update      = f4_meta$web_update,
      unit            = "days",
      rows            = nrow(f4),
      columns         = describe(f4)
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
