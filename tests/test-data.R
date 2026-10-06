# Regression checks on the generated data for the Leaf and Bloom Dates indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 4 dataset(s)", length(meta$datasets) == 4L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")
# Pinned from the source CSVs in data-raw/. A data update fails here and shows
# exactly which figure changed. Values are compared as strings to keep precision.
snap <- function(file, n, first, last, min, max) {
  d <- rd(file)
  v <- as.numeric(d$value)
  check(sprintf("%s: %d rows", file, n), nrow(d) == n)
  check(sprintf("%s: first row", file), identical(unname(unlist(d[1, ])), first))
  check(sprintf("%s: last row", file), identical(unname(unlist(d[nrow(d), ])), last))
  check(sprintf("%s: min value %s", file, min), identical(d$value[which.min(v)], min))
  check(sprintf("%s: max value %s", file, max), identical(d$value[which.max(v)], max))
}

snap("first_leaf_bloom_deviation_contiguous_48.csv", 496L,
     c("1900", "leaf", "annual_mean", "3.817582418"),
     c("2023", "bloom", "9yr_normal_curve", "0.5380444"),
     "-11.88713125", "10.10028653")
snap("first_leaf_bloom_deviation_alaska.csv", 296L,
     c("1950", "leaf", "annual_mean", "9.875"),
     c("2023", "bloom", "9yr_normal_curve", "-2.115774414"),
     "-16.4", "19.09677419")
snap("first_leaf_change_by_site.csv", 1278L,
     c("30.88", "-87.79", "2.075"),
     c("64.51", "-165.44", "-6.275"),
     "-25.45", "12.83333333")
snap("first_bloom_change_by_site.csv", 1278L,
     c("30.88", "-87.79", "3.05"),
     c("64.51", "-165.44", "-12.2"),
     "-33.5", "14.36666667")

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
