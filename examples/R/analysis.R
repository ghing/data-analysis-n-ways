library(assertthat)
library(dplyr)
library(stats)
library(downloader)
library(rgdal)
library(ggplot2)


test.results <- read.csv("../../data/il_lead_2004-2015_20160526.csv", as.is=TRUE) 

# Data checking

# Are all the dates valid?
test.results$COLLECTION_DATE <- as.Date(test.results$COLLECTION_DATE , "%m/%d/%Y")

# Are all the numbers valid
num.not.numbers <- length(test.results[is.nan(test.results$RESULT)])
assert_that(num.not.numbers == 0)

# Are the water system IDs and water system names consistent?
by.pwsid <- group_by(test.results, PWSID)
name.counts <- summarise(by.pwsid, num_names = n_distinct(PWSNAME))
multiple.names <- filter(name.counts, num_names > 1)
system.names <- distinct(select(test.results, PWSID, PWSNAME))
arrange(system.names[system.names$PWSID %in% multiple.names$PWSID,], PWSID)

# Summary statistics

# How many records are there in the data set?
num.test.results <- length(test.results$PWSID)
sprintf("There are %d tests in the data set", num.test.results)

# How many water systems are there in the data?
num.water.systems <- n_distinct(test.results$PWSID)
sprintf("There are %d water systems in the data set", num.water.systems)

# What's the earliest test date?
earliest.test.date <- min(test.results$COLLECTION_DATE)
sprintf("The earliest test date is %s", earliest.test.date)

# What's the last test date?
latest.test.date <- max(test.results$COLLECTION_DATE)
sprintf("The latest test date is %s", latest.test.date)

# What's the lowest lead level? In which system?
lowest.test.result <- min(test.results$RESULT)
systems.with.low.result <- filter(test.results, RESULT == lowest.test.result)
num.systems.with.low.result <- n_distinct(systems.with.low.result$PWSID)
sprintf("There are %d systems with the lowest lead level of %f", num.systems.with.low.result, lowest.test.result)

# What's the highest lead level? In which system?
highest.test.result <- max(test.results$RESULT)
systems.with.high.result <- filter(test.results, RESULT == highest.test.result)
num.systems.with.high.result <- n_distinct(systems.with.high.result$PWSID)
sprintf("There are %d systems with the highest lead level of %f", num.systems.with.high.result, highest.test.result)
systems.with.high.result

# Calculate the 90th percentile value for each water system, for each year

# First, calculate a year column
test.results$COLLECTION_YEAR <- as.numeric(format(test.results$COLLECTION_DATE, "%Y"))

# Then group by system and year
by.water.system.year <- group_by(test.results, PWSID, COLLECTION_YEAR)

# Custom aggegate function for calculating the 90th percentile
percentile90 <- function(results) {
  quantile(results, probs=seq(0, 1, 0.1))[10]
}

# For each group, calculate the 90th percentile value
test.percentile90s <- summarize(by.water.system.year, percentile90 = percentile90(RESULT))

# Which water systems exceeded the EPA standard?
exceeded.epa.standard <- filter(test.percentile90s, percentile90 >= 15)
exceeded.epa.standard

# How many times did these systems exceed the standard?
exceeded.epa.standard.by.system <- group_by(exceeded.epa.standard, PWSID)
exceeded.epa.standard.times <- summarize(exceeded.epa.standard.by.system, years_exceeded = n()) %>%
  arrange(desc(years_exceeded))
exceeded.epa.standard.times

# Which systems had at least one test above the EPA standard of 15ppb?
tests.above.15ppb <- filter(test.results, RESULT >= 15)
tests.above.15ppb.by.system <- group_by(tests.above.15ppb, PWSID)
systems.with.exceeding.results <- summarize(tests.above.15ppb.by.system, num_exceeding_results = n()) %>%
  arrange(desc(num_exceeding_results))
systems.with.exceeding.results

# Which systems had results showing very high levels of lead (>= 40ppb)
tests.above.40ppb <- filter(tests.above.15ppb, RESULT >= 40)
tests.above.40ppb.by.system <- group_by(tests.above.40ppb, PWSID)
systems.with.very.high.results <- summarize(tests.above.40ppb.by.system, num_exceeding_results = n()) %>%
  arrange(desc(num_exceeding_results))
systems.with.very.high.results

# How many water systems that exceeded the 90th percentile standard are in the Chicago Area

# First, load water systems
water.systems <- read.csv("../../data/illinois_water_systems.csv", as.is=TRUE) 

# Consider Chicago area to be Cook, DuPage, Lake, Kane, McHenry and Will counties
chicago.area.systems <- filter(water.systems, PRINCIPAL_COUNTY_SERVED == "Cook" | PRINCIPAL_COUNTY_SERVED == "DUPAGE" | PRINCIPAL_COUNTY_SERVED == "KANE" | PRINCIPAL_COUNTY_SERVED == "LAKE" | PRINCIPAL_COUNTY_SERVED == "MCHENRY" | PRINCIPAL_COUNTY_SERVED == "WILL")
exceeded.epa.standard.chicago.area <- exceeded.epa.standard[exceeded.epa.standard$PWSID %in% chicago.area.systems$PWSID, ]

# Is there a spatial trend?
water.systems.with.exceeding.counts <- merge(water.systems, exceeded.epa.standard.times, by = "PWSID")

u <- "https://raw.githubusercontent.com/codeforamerica/click_that_hood/master/public/data/illinois-counties.geojson"
downloader::download(url = u, destfile = "/tmp/illinois-counties.geojson")
illinois.counties <- readOGR(dsn = "/tmp/illinois-counties.geojson", layer = "OGRGeoJSON")
proj4string(illinois.counties)
ggplot() + geom_polygon(data = illinois.counties, aes(x=long, y=lat, group=group)) +
  geom_point(data = water.systems.with.exceeding.counts, aes(x=lng, y=lat, size=years_exceeded), color="red")