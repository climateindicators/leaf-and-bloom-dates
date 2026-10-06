# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-leaf-and-bloom-dates/index.html>  \
  sha256 `437386d35ff07dbec1f90b0c67a571878c2567f9add1f71b8fc948ddc16b022a`

Technical documentation: <https://19january2025snapshot.epa.gov/system/files/documents/2024-06/leaf-bloom-dates_documentation.pdf>

## Figure data

- `leaf-bloom_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/leaf-bloom_fig-1.csv>  \
  sha256 `316c7e6559b7d9788ae29c75e82962945b7882ad97a3f999855f7ac319747b49`  \
  encoding UTF-8, 124 data rows, columns: `Year`, `Leaf Mean`, `Leaf 9-yr normal curve`, `Bloom Mean`, `Bloom 9-yr normal curve`  \
  title: Figure 1. First Leaf and Bloom Dates in the Contiguous 48 States, 1900-2023  \
  data source: Schwartz, 2024; web update: June 2024; units: days deviation from 1981-2010 average

- `leaf-bloom_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/leaf-bloom_fig-2.csv>  \
  sha256 `73722c7ef58d69ec15d37d1877d8152fd1c55364829642d2541c20b910d88519`  \
  encoding UTF-8, 74 data rows, columns: `Year`, `Leaf Mean`, `Leaf 9-yr normal curve`, `Bloom Mean`, `Bloom 9-yr normal curve`  \
  title: Figure 2. First Leaf and Bloom Dates in Alaska, 1950-2023  \
  data source: Schwartz, 2024; web update: June 2024; units: days deviation from 1981-2010 average

- `leaf-bloom_fig-3.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/leaf-bloom_fig-3.csv>  \
  sha256 `3e1024f0c1731c950e104954a651b4d3d3bf6c6d21e5f1a412dec3df0fc7c93b`  \
  encoding UTF-8, 1278 data rows, columns: `Latitude`, `Longitude`, `Change in first leaf date`  \
  title: Figure 3. Change in First Leaf Date Between 1951-1960 and 2014-2023  \
  data source: Schwartz, 2024; web update: June 2024; units: degrees; degrees; days

- `leaf-bloom_fig-4.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/leaf-bloom_fig-4.csv>  \
  sha256 `1262e773dc166913e73417b84f0164542b7525abaff3dccb4a1f58764421c90f`  \
  encoding UTF-8, 1278 data rows, columns: `Latitude`, `Longitude`, `Change in first bloom date`  \
  title: Figure 4. Change in First Bloom Date Between 1951-1960 and 2014-2023  \
  data source: Schwartz, 2024; web update: June 2024; units: degrees; degrees; days
