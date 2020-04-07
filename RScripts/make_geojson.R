# Load packages
library(sf)
library(readxl)
library(dplyr)

# Unzip and read in  bounadies data
dir.create("tmp")
unzip("example_data/MSOA Boundaries.zip", exdir = "tmp")
msoa <- read_sf("tmp/Middle_Layer_Super_Output_Areas_December_2011_Generalised_Clipped_Boundaries_in_England_and_Wales.shp")
unlink("tmp", recursive = TRUE)

# rad in excel data on populations
pop <- read_excel("example_data/mid2011msoaquinaryageestimates.xls", sheet = "Mid-2011 Persons")

# Format population data
pop <- pop[4:nrow(pop),c(1,3,4)]
names(pop) <- c("msoa","msoa_name","population")
pop <- pop[!is.na(pop$msoa_name),]

# Join population data to boundaaries
msoa <- left_join(msoa, pop, by = c("msoa11cd" = "msoa") )

# calcualte population density
msoa$population <- as.numeric(msoa$population)
msoa$hectares <- as.numeric(st_area(msoa)) / 10000
msoa$populationdensity <- msoa$population / msoa$hectares
msoa <- msoa[,c("msoa11cd","population","populationdensity")]

# reporject data to epsg:4326
msoa <- st_transform(msoa, 4326)

# save data as geojson file
write_sf(msoa,"example_data/msoa.geojson")
