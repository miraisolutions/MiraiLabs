# Dataset creation ----

#' onLoad hook
#'
#' @param libname A character string giving the library directory where the package defining the namespace was found.
#' @param pkgname A character string giving the name of the package.
#'
#' @return Side effects only. Defines example data and support functions and puts them in the global environment.
#' @import dplyr reshape2 magrittr gapminder
#' @importFrom stats runif
.onLoad <- function(libname, pkgname){

    # Consider re-locating these files once in Renku
    if (Sys.getenv("TMP_PATH") != "") {
        tmp_path <- Sys.getenv("TMP_PATH")
        dir.create(tmp_path)
    } else {
        tmp_path <- Sys.getenv("HOME")
    }
    options(
        ads_file = file.path(tmp_path, "ads.csv"),
        users_file = file.path(tmp_path, "users.rds"),
        logging_file = file.path(tmp_path, "adspool.log"),
        stringsAsFactors = FALSE
    )

    # params ----
    n_customers <- 10 # number of customers - customer_id is a number in the range 1:n_customers
    n_users <- 10  # number of users - user_id is a number in the range 1:n_users
    n_history <- 5 # number of categories stored in browser history per user
    n_session <- 5 # number of sub-categories stored in session per user

    # for sampling reproducibility
    set.seed(100)

    countries <- gapminder::country_codes$country # using gapminder for accessing lsit of countries

    # ads ----
    # Pool of ads
    subcatsToAds_lst <- list("Videogame" = c("Mario Kart", "Fifa", "Assassin's Creed", "Fortnite", "The Sims", "Resident Evil", "World of Warcraft", "The Witcher", "Mindcraft"),
                             "Toy" = c("Doll", "Puppet", "Lego", "Colors", "Music", "Ball", "Teddybear"),
                             "Boardgame" = c("Risk", "Cluedo", "Monopoly", "Jenga", "Pictionary", "Taboo", "Pandemic", "Katan", "Labirint", "Scrabble", "Ticket to Ride", "Uno", "Apples to Apples", "Carcassonne", "Connect Four", "Cranium", "Guess Who?" ),
                             "Sport" = c("Football", "Tennis", "Soccer", "Volleyball", "Basketball", "Golf", "Baseball", "Swimming", "Cycling"),
                             "Politcs" = c("Internal Affairs", "International Affairs", "Education", "Economics", "Culture", "Infrastructure"),
                             "Economics" = c("Macroeconomics", "Microeconomics", "Personal Finance", "Insurance", "Banking", "International Finance"),
                             "Tabloid" = c("Daily Mail", "The Sun", "Globe", "People", "Daily Mirror", "OK", "Hello", "Life", "Entertainement"),
                             "Science" = c("Physics", "Engineering", "Neurobiology", "Biology", "Chemistry", "Geophysics", "Informatics", "Nanotechnology", "Anthropology", "Zoology", "Bothany"),
                             "Food" = c("Pasta", "Pizza", "Meat", "Fish", "Gluten Free", "Lactose Free", "Natural", "Bio"),
                             "Drinks" = c("Milk", "Juice", "Soft Drink", "Alchol", "Alchol Free", "Bio"),
                             "Personal Care" = c("Shampoo", "Conditioner", "Cream", "Deodorant", "Cosmetics"),
                             "Jobs" = c("Finance", "Academia", "Data Science", "Healthcare", "Infrastructure", "Education", "Sales"),
                             "Dating" = c("Man", "Female", "Young", "Mature", "International"),
                             "Real Estate" = c("House", "Flat", "Country House", "Buy", "Rent"),
                             "Apparel" = c("Dress", "Suit", "Skirt", "T-shirt", "Gown", "Trousers", "Jumper", "Jacket"),
                             "Footware" = c("High Heels", "Boots", "Trainers", "Sport Shoe", "Man Shoes", "Sandal"),
                             "Accessories" = c("Jewelry", "Bags", "Scarf", "Hat", "Gloves"),
                             "Audio" = c("Headsets", "Loudspeaker", "Mobile Phones", "Computer"),
                             "Video" = c("Mobile Phones", "Computer", "TV", "Screen", "Projector", "Camera"),
                             "House" = c("Fridge", "Washing Machine", "Dishwasher", "Humidifier", "Fan", "TV"),
                             "Rent" = c("Car", "Motorbike", "Bike", "Van"),
                             "Buy" = c("Car", "Motorbike", "Bike", "Van"),
                             "Sport" = c("Car", "Motorbike", "Bike"),
                             "Family" = c("Car", "Motorbike", "Bike", "Van")
    )

    catsToSubcats_lst <- list(
        "Games" = c("Videogame", "Toy", "Boardgame"),
        "News" = c("Sport", "Politcs", "Economics", "Tabloid", "Science"),
        "Consumables" = c("Food", "Drinks", "Personal Care"),
        "Services" = c("Jobs", "Dating", "Real Estate"),
        "Fashion" = c("Apparel", "Footware", "Accessories"),
        "Electronics" = c("Audio", "Video", "House"),
        "Vehicles" = c("Rent", "Buy", "Sport", "Family")
    )

    subcatsToAds <- melt(subcatsToAds_lst) %>%
        set_names(c("ads", "subcats")) %>%
        mutate(ads = as.character(ads))

    catsToSubcats <- melt(catsToSubcats_lst) %>%
        set_names(c("subcats", "cats")) %>%
        mutate(subcats = as.character(subcats))

    adsToCustomer <- subcatsToAds %>%
        select(ads) %>%
        distinct() %>%
        mutate("customer" = sample.int(n_customers,
                                     length(unique(subcatsToAds$ads)),
                                     replace = TRUE)) %>%
        mutate(ads = as.character(ads))

    ads <- left_join(left_join(subcatsToAds, catsToSubcats),
                     adsToCustomer) %>%
        mutate(id = as.integer(row.names(.)),
               name = ads,
               category = cats,
               subcategory = subcats,
               img_path = sprintf("%03d_%s.jpeg", id, gsub("\\W", "", ads)),
               customer_id = customer,
               click_count = as.integer(floor(runif(nrow(.), min = 0, max = 301))),
               click_rate = sample(1:3 * 1e-2, nrow(.), replace = TRUE)) %>%
        .[c("id", "name", "category", "subcategory", "img_path", "customer_id", "click_count", "click_rate")]
    # users ----

    users <- bind_cols(
        data.frame(user_id = seq(1, n_users)),
        sample_n(as.data.frame(countries),
                 n_users,
                 replace = TRUE))

    history <- sapply(users$user_id, function(i){
        history <- sample_n(ads %>%
                                select(category),
                            n_history)
    }) %>% set_names(users$user_id)

    session <- sapply(users$user_id, function(i){
        sample_n(ads %>%
                     filter(category %in% utils::tail(history[[i]], n = 1)) %>%
                     select(subcategory) %>%
                     distinct(),
                 n_session,
                 replace = TRUE)
    }) %>% set_names(users$user_id)

    users <- users %>%
        mutate(history = history,
               session =  session)

    # Expose backups in options for convenience re-creation during development
    options(
        ads.backup = ads,
        users.backup = users
    )

    # Update data in disk, ensuring persistence accross sessions.
    if (!file.exists(getOption("ads_file"))) write.ads(ads)
    if (!file.exists(getOption("users_file"))) write.users(users)
    if (!file.exists(getOption("logging_file"))) write.logs(sprintf("%s - adspool loaded", Sys.time()))
}
