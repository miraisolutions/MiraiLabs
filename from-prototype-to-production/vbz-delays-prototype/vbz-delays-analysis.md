VBZ Delays Analysis
================
Mirai Solutions
2019-09-20 09:18:41

## Introduction

References:

  - Data: <https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd>
  - Names translation:
    <https://github.com/OpenDataDayZurich2016/translations/blob/master/Translation_Data_Attributes.pdf>

## Data handling

Weekly data and corresponding resource
IDs:

``` r
base_url <- "https://data.stadt-zuerich.ch/dataset/vbz_fahrzeiten_ogd/resource"
vbz_resources <- c(
  "20190714_20190720" = "9beb05c6-0153-4ffa-a928-8ff899bf5f1c",
  "20190721_20190727" = "7883fd6e-e8f3-4ce4-82df-4944baa01a5b",
  "20190728_20190803" = "5bec146e-ba16-4a6a-8f6b-44e4ed14bdb9",
  "20190804_20190810" = "afdb312d-2855-4437-a8cd-f1c28dd97a79"
)
```

### Download data

Data are downloaded if not already available

``` r
raw_data_dir <- "data-raw"
dir.create(raw_data_dir)
## Warning in dir.create(raw_data_dir): 'data-raw' already exists
lapply(names(vbz_resources), function(x) {
  data_file <- sprintf("fahrzeiten_soll_ist_%s.csv", x)
  path <- file.path("data-raw", data_file)
  if (file.exists(path)) {
    message("skip download of ", path)
  } else {
    download.file(
      paste(base_url, vbz_resources[[x]], "download", data_file, sep = "/"),
      destfile = path
    )
    message("downloaded ", path)
  }
}) %>% invisible()
## skip download of data-raw/fahrzeiten_soll_ist_20190714_20190720.csv
## skip download of data-raw/fahrzeiten_soll_ist_20190721_20190727.csv
## skip download of data-raw/fahrzeiten_soll_ist_20190728_20190803.csv
## skip download of data-raw/fahrzeiten_soll_ist_20190804_20190810.csv
```

### Read all data

Load and transform data with package
[**vroom**](https://vroom.r-lib.org/).

``` r
files <- file.path(
  raw_data_dir, 
  sprintf("fahrzeiten_soll_ist_%s.csv", names(vbz_resources))            
)
cols_types <- vroom::cols(
  betriebsdatum = vroom::col_date("%d.%m.%y"),
  linie = "i" # integer
)
data <- vroom::vroom(
  files,
  col_types = cols_types, altrep_opts = FALSE,
  col_select = c(
    date = betriebsdatum,
    line = linie,
    scheduled_departure = dplyr::matches("soll_ab_von"),
    actual_departure = dplyr::matches("ist_ab_von"),
    scheduled_arrival = dplyr::matches("soll_an_nach"),
    actual_arrival = dplyr::matches("ist_an_nach")
  )
)
```

### Line data manipulation

  - Keep only tram lines (number \< 30).
  - Extract the weekday.
  - Define the hour as the scheduled departure time in hours from the
    beginning of the operating day (4AM). This implies that time after
    midnight is assigned and hour \> 24.

<!-- end list -->

``` r
data <- data %>%
  filter(line < 30) %>%
  mutate(
    weekday = lubridate::wday(
      date, label = TRUE, 
      locale = "en_US.UTF-8", week_start = 1
    ),
    hour = (scheduled_departure/3600),
    hour = ifelse(hour < 4, hour + 24, hour)
  ) %>% 
  select(grep("arr|dep", names(.), invert = TRUE, value = TRUE), everything())

data
## # A tibble: 2,623,464 x 8
##    date        line weekday  hour scheduled_depar… actual_departure
##    <date>     <int> <ord>   <dbl>            <dbl>            <dbl>
##  1 2019-07-14    10 Sun      5.11            18390            18333
##  2 2019-07-14    10 Sun      5.61            20190            20192
##  3 2019-07-14    10 Sun      5.86            21090            21103
##  4 2019-07-14    10 Sun      6.11            21990            22063
##  5 2019-07-14    10 Sun      6.36            22890            22883
##  6 2019-07-14    10 Sun      6.61            23790            23690
##  7 2019-07-14    10 Sun      6.86            24690            24733
##  8 2019-07-14    10 Sun      7.11            25590            25584
##  9 2019-07-14    10 Sun      7.36            26490            26473
## 10 2019-07-14    10 Sun      7.61            27390            27436
## # … with 2,623,454 more rows, and 2 more variables:
## #   scheduled_arrival <dbl>, actual_arrival <dbl>
```

### Save data by line

``` r
line_data_dir <- "line-data"
dir.create(line_data_dir)
## Warning in dir.create(line_data_dir): 'line-data' already exists
lapply(unique(data$line), function(l) {
  line_rds <- file.path(line_data_dir, sprintf("line-%d.rds", l))
  data %>%
    filter(line == l) %>%
    saveRDS(file = line_rds)
  message("saved ", line_rds)
}) %>% invisible()
## saved line-data/line-10.rds
## saved line-data/line-12.rds
## saved line-data/line-9.rds
## saved line-data/line-14.rds
## saved line-data/line-3.rds
## saved line-data/line-5.rds
## saved line-data/line-11.rds
## saved line-data/line-8.rds
## saved line-data/line-2.rds
## saved line-data/line-4.rds
## saved line-data/line-13.rds
## saved line-data/line-17.rds
## saved line-data/line-6.rds
## saved line-data/line-15.rds
## saved line-data/line-7.rds
```

## Analysis

### Load line data

Select the line and load the data

``` r
line <- 11
line_file <- file.path("line-data", sprintf("line-%d.rds", line))
data <- readRDS(line_file)
```

### Analysis of delays for line 11

Read departure and arrival data

### Delays by hour for each weekday

Compute delays in minutes as the mean of departure and arrival delays,
and compute delay counts by hour for each weekday

``` r
delays <- data %>%
  mutate(
    delay = ((actual_departure - scheduled_departure) +
               (actual_arrival - scheduled_arrival)) / 2 / 60
  ) %>% 
  group_by(
    weekday,
    hour = cut(hour, 0:48, labels = ifelse(0:47 < 24, 0:47, paste0("+", floor(0:47) - 24))),
    delay = cut(delay, c(-Inf, 1:5, Inf))
  ) %>% 
  summarize(count = n())

delays
## # A tibble: 801 x 4
## # Groups:   weekday, hour [155]
##    weekday hour  delay    count
##    <ord>   <fct> <fct>    <int>
##  1 Mon     4     (-Inf,1]    60
##  2 Mon     4     (1,2]        4
##  3 Mon     5     (-Inf,1]  1069
##  4 Mon     5     (1,2]      140
##  5 Mon     5     (2,3]       46
##  6 Mon     5     (3,4]        5
##  7 Mon     6     (-Inf,1]  1650
##  8 Mon     6     (1,2]      379
##  9 Mon     6     (2,3]      119
## 10 Mon     6     (3,4]       51
## # … with 791 more rows
```

### Visualize results

Barplot of normalized delay counts by hour for each weekday, conditional
on delays of at least 1 minute

``` r
delays %>% 
  filter(delay != "(-Inf,1]") %>%
  ggplot(aes(x = hour, y = count)) +
  geom_col(aes(fill = delay), position = "fill") +
  lemon::facet_rep_wrap(~weekday, ncol = 1, repeat.tick.labels = TRUE) +
  theme(legend.justification = "top")
```

![](vbz-delays-analysis_files/figure-gfm/delays-plot-1.png)<!-- -->