
### API wrapper: tidyquant

library(tidyverse)
library(tidyquant)

# Quandl data can also be accessed without authentication (API key), only 20 queries a day
# (https://www.quandl.com/) 
quandl_api_key("Tb6eL7NCNyHrgscDvW3D")
bitcoin_quandl <- tibble(code = "BCHARTS/LOCALBTCUSD", symbol = "LOCALBTCUSD") %>%
    tq_get(get = "quandl", from = "2015-01-01")

bitcoin_quandl %>%
    ggplot(aes(x = date, y = close)) +
    geom_line() +
    labs(title = "Bitcoin Line Chart", y = "Closing Price USD", x = "") + 
    theme_tq()


# Typically the wrapper package offers more than just a friendly data interface
symbols <- c("AMZN", "GOOG", "IBM", "MSFT")
end <- Sys.Date()
start <- end - weeks(6)
ma_days <- 15

symbols %>%
    tq_get(get = "stock.prices", from = start - 2 * ma_days) %>%
    ggplot(aes(x = date, y = close, group = symbol)) +
    geom_candlestick(
        aes(open = open, high = high, low = low, close = close),
        colour_up = "darkgreen", colour_down = "darkred",
        fill_up = "darkgreen", fill_down = "darkred") +
    geom_ma(ma_fun = SMA, n = ma_days, color = "darkblue", size = 1) +
    coord_x_date(xlim = c(start, end)) +
    facet_wrap(~ symbol, ncol = 2, scales = "free_y") +
    theme_tq()


### Web client package: httr

library(httr)

# http://httpbin.org/
GET("http://httpbin.org/get")
# Setting the heading "Accept":
GET("http://httpbin.org/get", accept("application/xml"))
# This throws an error. Content-Type indicates the body format expected by the server:
POST("http://httpbin.org/post", body = list(iris = iris))
# Adapting the body format to the server's expectation, httr does the heavy work:
POST("http://httpbin.org/post", body = list(iris = iris), encode = "json")
DELETE("http://httpbin.org/delete")

# https://docs.quandl.com/docs/in-depth-usage
bitcoin_httr <- GET(url = "https://www.quandl.com/api/v3/datasets/BCHARTS/LOCALBTCUSD/data.csv",
                    api_key = "Tb6eL7NCNyHrgscDvW3D",
                    query = list(start_date = "2015-01-01"))

# https://funtranslations.com/api/dothraki
httr::POST(url = "https://api.funtranslations.com/translate/dothraki", 
           query = list(
               text = "I would like to eat a boiled dragon egg"
           )
)


### Command line tool: curl

system("curl -X GET http://httpbin.org/get")
system("curl -X GET http://httpbin.org/get -H 'Accept: application/json'")
system("curl -X POST http://httpbin.org/post -d data='hello' -H 'Content-Type: application/text'")

bitcoin_curl <- system("curl -X GET https://www.quandl.com/api/v3/datasets/BCHARTS/LOCALBTCUSD/data.csv -d start_date=2015-01-01", intern = TRUE)

system(
    sprintf("curl -X POST https://api.funtranslations.com/translate/dothraki -d text='%s'",
            "I would like to eat a boiled dragon egg"
    )
)
