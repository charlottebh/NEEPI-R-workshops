# Northeast Epi R Basics Workshop: Eastern Equine Encephalitis Example

# Alexander Keyel <alexander.keyel@health.ny.gov> and Lindsey Rickerman
# Wadsworth Center
# New York State Department of Health
# November 2026, Albany, NY


##### Set Up #####
# We start by opening the R project, and making sure Northeast_Epi_Analysis.R
# file is open
# All paths are local to the project directory

# Next we load the packages needed for this project
# Packages need to be installed before using
# install.packages(c("terra", 'dplyr', 'ggplot2'))
library(terra)         # For GIS applications
library(dplyr)         # For data manipulation
library(ggplot2)       # For plots

##### Quick note #####
# Officially, R standard coding practice is to use the assignment operator: <- 
# But an equals sign works the same: =
# and it's one fewer key stroke, so I use the = sign.

##### Read in and examine the data set #####
# Data used here are available from Oliver et al. 2020
# and have been put into a .csv format for easier use in R.
# The data set used here has been slightly modified for this example
# See: https://pmc.ncbi.nlm.nih.gov/articles/PMC7473153/

ny_eee = read.csv('Oliver_etal_2020_data.csv')

#Error in file(file, "rt") : cannot open the connection
#In addition: Warning message:
#  In file(file, "rt") :
#  cannot open file 'Oliver_etal_2020_data.csv': No such file or directory

# Oops, we forgot the path is relative to the project folder. Let's try again.
# Don't worry, making mistakes in R is normal, and it's all part of the process.
# It's OK if your code isn't perfect the first time you write it. You can edit it!
ny_eee = read.csv('data/Oliver_etal_2020_data.csv')

# Let's see what we've got
View(ny_eee) # Look at the data set in an Excel-like format. Can sort and filter!
# You can also click on the variable name in the side panel

# How big is the data set? This can be a useful check if your data is coming in correctly
nrow(ny_eee) # 54 rows
ncol(ny_eee) # 8 columns

# Now we're going to do some basic descriptive summaries of the data
# Can help for identifying problems
# Start by making some descriptive tables
table(ny_eee$Organism)
# Uh oh - there is an inconsistency in the data set:
# horse and Horse.

# A few ways to fix this (more in Appendix!):
# Go into the original data set, and use find and replace to replace 'horse' with 'Horse'
  # Easy, but modifies the original data, so can introduce errors into your source data 

# Use gsub to replace
ny_eee$Organism = gsub("^horse$", "Horse", ny_eee$Organism)
# Sometimes it's good to try this by assigning to a new column in case you make a mistake
# gsub uses regular expressions - this is not basic R and can be confusing.
# Basically, it takes you VERY literally, so if you ask it to replace "1", it will also get
# the 1 from 10! The ^ says to look for the beginning of a word and the $ says to look at the end
# And that helps keep it from accidentally matching things that aren't intended.
# Special characters such as . () and \ and / will also give you trouble.
# Read up on regular expressions in R before using gsub
table(ny_eee$Organism)

# Look at the other data inputs
table(ny_eee$County)
table(ny_eee$Town)

# We are not using the region column, so let's just drop it
ny_eee$Region = NULL

# Did it work?
View(ny_eee)

# Also, we're not looking at horse vaccination status, so we'll drop that column,
# and also the Date.Type column. You can drop two columns in one line.
ny_eee$Date.Type = ny_eee$Vaccination = NULL

# tidyverse approaches using select
#to.drop = c("Region", "Date.Type", "Vaccination")
#ny_eee = ny_eee %>%
#  dplyr::select(-any_of(to.drop))

#ny_eee = ny_eee %>%
#  dplyr::select(-c(Region, Date.Type, Vaccination))

# Note: in the code, I will often code package calls using ::
# This is not typically necessary, but helps to show which package is being used
# (only necessary if you want a function from a specific package that is not
# the default)
# so you will often see it as select, and not dplyr::select


# Now, we're going to focus on just the horse and human cases
ny_eee_subset = ny_eee[ny_eee$Organism %in% c('Horse', 'human'), ]
nrow(ny_eee_subset) # 31
View(ny_eee_subset) # It's good practice to inspect your data as you go along
# Sometimes there are surprises, especially if there is an error in your code!
# Oops, we got the case wrong on human and lost all our human cases.

# Let's try again:
ny_eee_subset = ny_eee[ny_eee$Organism %in% c('Horse', 'Human'), ]
# This overwrites the old ny_eee_subset object.
nrow(ny_eee_subset) # 36 Or, you can look at the Global Environment panel in RStudio!
View(ny_eee_subset) # It's good practice to inspect your data as you go along

# How many human and horse cases do we have?
table(ny_eee_subset$Count, by = ny_eee_subset$Organism)
# 31 horse cases and 5 human cases
sum(ny_eee_subset$Count) # 36 cases total
max(ny_eee_subset$Count) # One row per case, so max is 1

# For this analysis, we will want presence/absence, not count. So we'll aggregate the data by county and town
ny_eee_agg = aggregate(ny_eee_subset$Count, by = list(ny_eee_subset$County, ny_eee_subset$Town),
                       max) # Using the max function here,
# but it doesn't really matter, because Count is 1 for everything.

# aggregate:
# What to aggregate: ny_eee_subset$Count
# What to aggregate by (must be a list): list(ny_eee_subset$County, ny_eee_subset$Town)
# What function to use in the aggregation: max

View(ny_eee_agg) # Column names are really uninformative with this function. We'll have to fix them.
colnames(ny_eee_agg) = c('County', 'Town', 'EEE_Present')

##### MAKING A MAP #####
# Let's look at our EEE data on a map - does it make sense?
towns = terra::vect("data/Cities_Towns/Cities_Towns.shp")
#towns = terra::vect("data/Cities_Towns/") # This also works, if there is only one shapefile in directory
# Check that our data layer read in correctly
# Note that plot here uses the same command that is used by other packages
# R dynamically looks at the data type, and makes the plot based on the data type.
plot(towns)

# Look for names for field
names(towns)

# Merge a shapefile with the EEE data
# Make sure the spatial layer is listed first, this will help ensure the type keeps the spatial part
eee_towns = merge(towns, ny_eee_agg,
                  by.x = c("NAME", "COUNTY"), by.y = c("Town", 'County'),
                  all.x = TRUE) 

# First line is what to merge
# Second line is what to merge by
# Third line says to keep all the records from towns.

# Check that it merged properly
# Unfortunately View with the spatial object doesn't actually show anything interesting
# Can get around it by Viewing a temporary data frame
View(as.data.frame(eee_towns))
# You may get this warninig - you can ignore it - this only applies to the temporary object,
# and not eee_towns itself.
# Warning message:
# In class(object) <- "environment" :
#   Setting class(x) to "environment" sets attribute to NULL; result will no longer be an S4 object

# Check that all our cases merged in properly
sum(ny_eee_agg$EEE_Present) # 27
sum(eee_towns$EEE_Present, na.rm = TRUE) # 28, all towns with cases are still represented in the data set
# Uh-oh - one too many. Go back to View to see what went wrong.
# Kingston is a city and a town, and merged twice. For this tutorial, we will drop the
# cities later, so not going to fix it here. 

# Quick-and-dirty plot to see where EEE is present in horses in NY (2013 - 2019).
plot(eee_towns, col = eee_towns$EEE_Present)

# Manually set the colors
eee_towns$color = 'gray90'
eee_towns$color[eee_towns$EEE_Present == 1] = 'firebrick4'
plot(eee_towns, col = eee_towns$color)

# Zoom in quickly on the part in the Hudson Valley - are those cases?
plot(eee_towns, col = eee_towns$color, xlim = c(550000,650000), ylim = c(4600000, 4700000))
# not as clean and intuitive as a GUI-based GIS software, but it can work!
# GUI: Graphical User Interface
# GIS: Geographic Information System, i.e. computer software for working with maps

# Correct NA's to be 0's for presence
eee_towns$EEE_Present[is.na(eee_towns$EEE_Present)] = 0

# OK to ignore this warning message:
#Warning message:
#  In class(object) <- "environment" :
#  Setting class(x) to "environment" sets attribute to NULL; result will no longer be an S4 object

# The warning is coming off the is.na(eee_towns$EEE_Present) command,
# and does not affect the eee_towns object.


##### ADDING RASTER DATA #####
# Next we'll read in some climate data - looking for a temperature relationship
# The data set we'll use is from PRISM, a climate data set maintained by the Oregon State University
# https://prism.oregonstate.edu/

# See appendix for code for data download and unzipping of climate data files

# The raster file consists of 6 unzipped files.
# .tif has the data in image format
# .prj has the projection information
# Just keep all the files together is the important part.
# And when working with R, you'll just tell it about the .tif file,
# and the computer will use the other files as needed.

# Define the extracted file
extracted_file = "data/prism_tmean_us_25m_202606/prism_tmean_us_25m_202606.tif"
# See appendix for a way of automating the naming of the extracted_file
# Don't really want to code it out manually if you have a large number of these

# Read the June temperature in as a raster
june_mean_temp = terra::rast(extracted_file)
plot(june_mean_temp) # shows the monthly temperatures for june for all of the US

# Forgot the syntax? Just use ? before the function to look it up!
?crop
# Can crop to a custom extent
extent = terra::ext(-80, -70, 40, 46)
june_mean_temp_ny = terra::crop(june_mean_temp, extent)
plot(june_mean_temp_ny)

# Can also use an existing object, but they have to be in the same
# coordinate system - this does not work:
june_mean_temp_ny = terra::crop(june_mean_temp, towns)
# Error: [crop] extents do not overlap
# One file is using geographic coordinate systems (Lat/Lon), while another is using
# projected coordinates (UTMs)

# We will reproject to get them in the same coordinate system
crs(june_mean_temp, describe = TRUE)
crs(towns, describe = TRUE)
june_mean_temp_UTM = terra::project(june_mean_temp_ny, "EPSG:26918")
june_mean_temp_ny_utm = terra::crop(june_mean_temp_UTM, towns)

# Check that everything plotted correctly
plot(june_mean_temp_ny_utm)
plot(towns, add = TRUE)

# Create a sub-directory to contain the file
# WARNING: R gives you access to tools that can change directories/files.
# Use with caution! But creating sub-folders is generally pretty safe.
dir.create("Figures", showWarnings = FALSE)
# showWarnings is FALSE to prevent it from giving me a warning if the path
# already exists


# Output the plot as a .tif
tiff(filename = "Figures/june_mean_temperatures.tif", height = 1200, width = 1200,
     res = c(300), compression = c('lzw'))
plot(june_mean_temp_ny_utm)
plot(towns, add = TRUE)
dev.off()
# Height and width are the size of the output image
# res controls resolution. 300 dpi is usually good for publication-grade figures
# compression controls image compression. lzw is a loss-less compression, so you
# get a smaller file size without losing any data.

#NOTE: Any plot commands between tiff and dev.off will be written to the .tif object.
# If you create a new plot, it will overwrite the existing plot.

# Output the plot as a .pdf
pdf(file = "Figures/june_mean_temperatures.pdf")
plot(june_mean_temp_ny_utm)
plot(towns, add = TRUE)

plot(towns)
dev.off()
#NOTE: Any plot commands between pdf and dev.off will be written to the .pdf object.
# If you create a new plot, it will add it to a new page

# See appendix for an example of a pdf with multiple plots generated using a loop


##### Joining Raster Data to vector #####

# Let's pull out the climate data for each corresponding town
eee_towns$june_mean_temp = terra::extract(june_mean_temp_ny_utm, eee_towns, fun = 'mean', ID = FALSE)[[1]]
View(as.data.frame(eee_towns))

eee_towns$june_mean_temp = terra::extract(june_mean_temp_ny_utm, eee_towns, fun = 'mean', na.rm = TRUE, ID = FALSE)[[1]]
View(as.data.frame(eee_towns))
# adding the na.rm = TRUE argument told it to ignore the NA values; you can see the NA's on the Suffolk towns

# Let's break down what is going on here:
# we're using the extract function from the terra package.
# june_mean_temp_ny_utm is the raster layer that we want to extract from
# Raster layers are made up of cells - think of gridded data
# eee_towns is the vector layer we want the values joined to
# fun is what function we want to apply to the raster data. Here we chose a mean.
# you could also use minimum, maximum, or many other functions
# ID = FALSE says just give us the data values. This works here because the order is preserved,
# and we are immediately assigning back to the data layer that was used for the join.
# [[1]] is because R decides to make the output a list, but we just want the values from the list
# so it gets around the weird formatting that R has applied to the output.

# Let's do some descriptive statistics and plots with our climate data
summary(eee_towns$june_mean_temp)
# Min.   1st Qu.  Median  Mean   3rd Qu.   Max. 
# 15.42   17.95   18.82   18.87   19.61   23.16 
# Can use summary on multiple variables at once!
# Quick way to view data

# Create a histogram to visualize the distribution
hist(eee_towns$june_mean_temp, xlab = "Mean June Temperature", main = "")
# Adjust the breakpoints - these were good, but I just want to show that you can do this
hist(eee_towns$june_mean_temp, xlab = "Mean June Temperature", main = "",
     breaks = seq(15,24, 0.5))
# seq creates a sequence starting at the first number, ending at the second, and going by increments of the 3rd.


##### DESCRIPTIVE PLOTS OF CLIMATE DATA #####
# Compare climate of counties with EEE to counties without EEE
eee_counties = aggregate(eee_towns$EEE_Present, by = list(eee_towns$COUNTY), max, na.rm = TRUE)
colnames(eee_counties) = c("COUNTY", "EEE_Present_County")

eee_towns2 = merge(eee_towns, eee_counties, by = 'COUNTY', all.x = TRUE)

# clever tidyverse way to do this, with dplyr and group_by
# But lose the spatial properties of the data set
eee_towns2_tidy = as.data.frame(eee_towns) %>%
  dplyr::group_by(COUNTY) %>%
  dplyr::mutate(EEE_Present_County = max(EEE_Present, na.rm = TRUE)) %>%
  dplyr::ungroup()

# Use ggplot2 package (can also do basic plots in base R)
# Even though the package is ggplot2, the plot command is still ggplot
eee_plot = ggplot(data = eee_towns2, aes(x = COUNTY, y = 'june_mean_temp')) + 
  geom_boxplot(position = 'dodge')
eee_plot

#Error in `fortify()`:
#  ! `data` must be a <data.frame>, or an object coercible by `fortify()`, or a valid <data.frame>-like object
#coercible by `as.data.frame()`.
#Caused by error in `.prevalidate_data_frame_like_object()`:
#  ! `dim(data)` must return an <integer> of length 2.
#Run `rlang::last_trace()` to see where the error occurred.

# Well, that's not very intuitive!

# First guess: data are in wrong type
eee_towns2$COUNTY = as.factor(eee_towns2$COUNTY)
eee_towns2$june_mean_temp = as.numeric(eee_towns2$june_mean_temp)

eee_plot = ggplot(data = eee_towns2, aes(x = COUNTY, y = 'june_mean_temp')) + 
  geom_boxplot(position = 'dodge')
eee_plot

# Didn't fix the error!

# Second guess: it doesn't like the spatial type our data is in, and can't find the data frame
eee_towns3 = as.data.frame(eee_towns2)

# Copy and paste code from above and re-run
eee_plot = ggplot(data = eee_towns2, aes(x = COUNTY, y = 'june_mean_temp')) + 
  geom_boxplot(position = 'dodge')
eee_plot

# Anybody see the copy paste error we made here? Super common mistake
# and can be difficult to spot, because you 'know' what you meant, but the
# computer does what you code, not what you mean.
# Forgot to update to the eee_towns3 object!

eee_plot = ggplot(data = eee_towns3, aes(x = COUNTY, y = 'june_mean_temp')) + 
  geom_boxplot(position = 'dodge')
eee_plot

# Well, we got a plot this time. But we mixed up our syntax, didn't we?


eee_plot = ggplot(data = eee_towns3, aes(x = COUNTY, y = june_mean_temp)) + 
  geom_boxplot(position = 'dodge')

eee_plot

# We've got something, but it's ugly. Let's make it look nicer.
# Because ggplot creates objects, we can just modify that object.
eee_plot = eee_plot + 
  labs(x = "County", y = "Mean June Temperature (C)") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
eee_plot

# Something weird going on with NYC and Ontario, Seneca
View(eee_towns3) # Search on Queens and Ontario
# can see that there are cities that span multiple counties, so the county field
# had multiple entries for those cities.

# For this example, we're going to drop the cities, and just look at towns
eee_towns4 = eee_towns3[eee_towns3$MUNI_TYPE != 'city', ]

# Tidyverse way
eee_towns4_tidy = eee_towns3 %>%
  dplyr::filter(MUNI_TYPE != "city")

# It's good to use your knowledge of the data to check as you go.
# In this case, I know there are 62 counties in NYS, and if you remove NYC,
# that leaves 57. (and no other city takes up an entire county, let alone 5!)
# Should be 57 counties - are there?
length(unique(eee_towns4$COUNTY)) 
# Yes, 57 
# Unique says just give me the unique entries
# length says how many entries are there?

eee_plot2 = ggplot(data = eee_towns4, aes(x = COUNTY, y = june_mean_temp)) + 
  geom_boxplot(position = 'dodge') + 
  labs(x = "County", y = "Mean June Temperature (C)") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
eee_plot2

# Let's color our plot by whether the county has had EEE before
eee_plot3 = ggplot(data = eee_towns4, aes(x = COUNTY, y = june_mean_temp, fill = EEE_Present_County)) + 
  geom_boxplot(position = 'dodge') + 
  labs(x = "County", y = "Mean June Temperature (C)") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
eee_plot3

# Not quite what I wanted, convert to factor
eee_towns4$EEE_Present_County = as.factor(eee_towns4$EEE_Present_County)

eee_plot3 = ggplot(data = eee_towns4, aes(x = COUNTY, y = june_mean_temp, fill = EEE_Present_County)) + 
  geom_boxplot(position = 'dodge') + 
  labs(x = "County", y = "Mean June Temperature (C)") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
eee_plot3

# We're going to add a second variable, to show scatter plots, correlation, and regression
extracted_file = "data/prism_tmean_us_25m_202601/prism_tmean_us_25m_202601.tif"
# extracted_file has been overwritten, and now is january data
# be careful with overwritten objects - can get bad values if there is an error somewhere and you pull old data!
jan_mean_temp = terra::rast(extracted_file) 

jan_mean_temp_ny = terra::crop(jan_mean_temp, extent) # Crop to same extent as before to make it smaller.
jan_mean_temp_UTM = terra::project(jan_mean_temp_ny, "EPSG:26918")
jan_mean_temp_ny_utm = terra::crop(jan_mean_temp_UTM, towns)

# Check that everything plotted correctly
plot(jan_mean_temp_ny_utm)
plot(towns, add = TRUE)

eee_towns2$jan_mean_temp = terra::extract(jan_mean_temp_ny_utm, eee_towns2, fun = 'mean', na.rm = TRUE, ID = FALSE)[[1]]
eee_towns4 = as.data.frame(eee_towns2[eee_towns2$MUNI_TYPE != 'city', ]) # Combine multiple steps into 1

# Compare two variables
# (yes, this is a pretty trivial comparison, but it shows code/syntax)

# Visually check for normality
hist(eee_towns4$jan_mean_temp)
hist(eee_towns4$june_mean_temp)

# Use Wilkes-Shapiro test
shapiro.test(eee_towns4$jan_mean_temp)  # p <<0.001
shapiro.test(eee_towns4$june_mean_temp) # p < 0.001

# If it WAS normal, we could use t-test to compare
t.test.result = t.test(eee_towns4$june_mean_temp, eee_towns4$jan_mean_temp,
                       alternative = 'two.sided', var.equal = FALSE,
                       paired = TRUE) # We have paired temperatures, so can use paired = TRUE
t.test.result

# Since it IS non-normally distributed, we'll use a paired Wilcoxon Rank Sum test
wilcox.result = wilcox.test(eee_towns4$june_mean_temp, eee_towns4$jan_mean_temp,
                            alternative = "two.sided", paired = TRUE)
wilcox.result

# Look at correlation between two variables
# Look at psych::pairs.panels() function if looking at correlation among several variables - makes a nice graphic
temp_cor = cor.test(eee_towns4$june_mean_temp, eee_towns4$jan_mean_temp)
temp_cor
temp_cor_rs = cor.test(eee_towns4$june_mean_temp, eee_towns4$jan_mean_temp, method = 'spearman')
temp_cor_rs

# Can do a simple regression
temp_reg = lm(june_mean_temp ~ jan_mean_temp, data = eee_towns4)
summary(temp_reg)

# Can do simple regression in a more complicated way
temp_reg_glm = glm(june_mean_temp ~ jan_mean_temp, data = eee_towns4)
summary(temp_reg_glm)
# Now without overall p-value or R2, but AIC by default.
# but gives tools for adding complexity, like logistic regression

eee_reg = glm(EEE_Present ~ june_mean_temp + jan_mean_temp, data = eee_towns4,
              family = 'binomial')
summary(eee_reg)


###### APPENDIX #######
# Useful stuff that we did not have time to cover today, but can be a pointer for
# future applications

library(MetBrewer)     # Alternative color-blind friendly color palette
# https://github.com/BlakeRMills/MetBrewer

# Libraries not included in this tutorial, but may be of interest
library(lubridate)     # For dates
library(zoo)           # For moving averages
library(lme4)          # For mixed model statistics
# Not used here, because this isn't basic R or simple stats!
library(ranger)        # For using Random Forest models, more options than randomForest package
# Also not basic, but useful
library(MASS)          # Good for fitting negative binomial models,
# and stepwise model selection based on AIC
library(psych)         # pairs.panels function is nice for correlation visualization
library(exact2x2)      # Good for analyzing contingency tables
# library(tidyr)       # Loads the tidyverse functions; commented out to avoid masking functions used here


# Load a color-blind friendly palette to use in plots
# http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/#a-colorblind-friendly-palette
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
# Can call colors directly from this palette

# Alternative options through MetBrewer:
colorblind_palettes
met.brewer('Isfahan1')

# May want to set working directory here. I'm working from an R project,
# so it's already set for me.
# setwd("Your/Directory/Path/Here") # Obviously replace with your actual path
# Or go to Session: Set Working Directory : Choose Directory

### Getting additional details about your data and data manipulation #### 

# Sometimes you want details about the data
str(ny_eee)

# Sometimes you just want the column names!
names(ny_eee)

# Sometimes you just want to see the header quick, to see that it came in OK
head(ny_eee)

# Other ways to do replacements:
# Convert to upper case
ny_eee$Organism2 = toupper(ny_eee$Organism)
# This just adjusts the case, and then slight case mis-matches don't matter.
# tolower() is alo an option.
table(ny_eee$Organism2)

# Manually replace by position
# May be hard to find the index, if you get the index wrong, you risk corrupting the data
# Not really recommended
ny_eee$Organism[21] = "Cow"
# Yes, it's supposed to be Horse, but if I fix it, I can't show you the other ways to find it!

# Replace by position using grep
# grep isn't really a basic - can be quite complex
position = grep("Cow", ny_eee$Organism)
ny_eee$Organism[position] = "Pig"

# Use gsub to replace
ny_eee$Organism = gsub("^Pig$", "Horse", ny_eee$Organism)
# Sometimes it's good to try this by assigning to a new column in case you make a mistake
# gsub uses regular expressions - this is not basic R and can be confusing.
# Basically, it takes you VERY literally, so if you ask it to replace "1", it will also get
# the 1 from 10! The ^ says to look for the beginning of a word and the $ says to look at the end
# And that helps keep it from accidentally matching things that aren't intended.
# Special characters such as . () and \ and / will also give you trouble.
# Read up on regular expressions in R before using gsub

# Additional data cleaning:
# Mosquito data were missing dates, and Excel did something funky there - will need to clean that up
# Let's just make them all NA, so we don't get confused
# Non-tidyverse way:
ny_eee$Date[ny_eee$Organism == 'Mosquito'] = NA
# ny_eee$Date:                       The variable to change
# [ny_eee$Organism == "Mosquito"]: The rows to change
# = NA                               The new value to assign

# Did it work?
View(ny_eee)

# Tidyverse way to replace NA values
# Commented out because it won't work with the terra spatial data object
# But will work with normal data frames
#eee_towns_tidy = as.data.frame(eee_towns) %>%
#  mutate(
#    EEE_Present = tidyr::replace_na(EEE_Present, 0)
#  )

# rep is a helpful function that repeats a number or vector multiple times.
rep(10, 5)
rep(c(1,2,3,4,5), 5)

# sort is another useful function, that sorts data
sort(rep(c(seq(1,5)),5))

# quick warning about sort for characters:
char.example = c("10", "20", "1", "2")
sort(char.example)
# "1"  "10" "2"  "20"
# Was this the order you were expecting?
# It goes alphabetical, so treats 1 as ahead of 2, regardless of what comes next.
sort(as.numeric(char.example))
# 1  2 10 20 # That's better!


#### Troubleshooting Merges #####

# Merge a shapefile with the EEE data
# Make sure the spatial layer is listed first, this will help ensure the type keeps the spatial part
eee_towns = merge(towns, ny_eee_agg,
                  by.x = c("NAME", "COUNTY"), by.y = c("Town", 'County'),
                  all.x = TRUE) 

# Got this error first time I ran it - I had not re-named ny_eee_agg,
# so had to go back and run the col.names line of code
# Error in fix.by(by.y, y) : 'by' must specify uniquely valid columns
# R-speak for saying that the column names you want to merge by aren't in one of the data sets

# Getting an error with Tidyverse left_join, so probably safer to use base R merge
# when joining to terra data objects
#eee_towns_tv = left_join(towns, ny_eee_agg,
#                         by.x = c("NAME", "COUNTY"), by.y = c("Town", 'County'))
#Error in UseMethod("left_join") : 
#  no applicable method for 'left_join' applied to an object of class "SpatVector"

###### Data Extraction #####

# NOTE: During the workshop I'm going to skip these lines - run prior to workshop 
# and the data cropped to NYS are in the 'data' subfolder for this example

# Also: you can use loops and text substitution to automate data downloads!
# That's what we did in the actual project, but wanted to simplify it here for the example.

prism_path = "https://data.prism.oregonstate.edu/time_series/us/an/4km/tmean/monthly"
year = 2026
june_file = "prism_tmean_us_25m_202606.zip"

# Using paste function (sprintf function would also work)
full_path = paste(prism_path, year, june_file, sep = "/") # use collapse argument in paste when converting vectors to string
local_file = paste("data", june_file, sep = "/")

download.file(full_path, local_file)
# trying URL 'https://data.prism.oregonstate.edu/time_series/us/an/4km/tmean/monthly/2026/prism_tmean_us_25m_202606.zip'
# Content type 'application/zip' length 2548397 bytes (2.4 MB)
# downloaded 2.4 MB

# And unzip the zipfile into a labeled sub-folder
unzip(local_file, exdir = 'data/prism_tmean_us_25m_202606')

# And we should get 6 unzipped files.
# .tif has the data in image format
# .prj has the projection information
# Just keep all the files together is the important part.
# And when working with R, you'll just tell it about the .tif file,
# and the computer will use the other files as needed.

# Define the extracted file
extracted_file = "data/prism_tmean_us_25m_202606/prism_tmean_us_25m_202606.tif"

# can also do the fancy way, if doing an automated procedure with many files
part1 = substr(local_file, 6, nchar(local_file) - 4) # Trim off data/ and the file extension
# substr can subset a string/character. 1 says start at the beginning
# nchar says get the number of characters in an object
# -4 is to drop the last four characters
part2 = '.tif'
extracted_file = paste('data/', part1, '/', part1, part2, sep = "")

# And download and unzip a second file
jan_file = "prism_tmean_us_25m_202601.zip"
jan_path = paste(prism_path, year, jan_file, sep = "/") # use collapse argument in paste when converting vectors to string
jan_file = paste("data", jan_file, sep = "/")
download.file(jan_path, jan_file)
unzip(jan_file, exdir = 'data')


#### More on folder creation #####
# use recursive = TRUE if you need to create sub-folders within the directory
dir.create("MoreFigures/2026")
# Warning message:
#   In dir.create("MoreFigures/2026") :
#   cannot create dir 'MoreFigures\2026', reason 'No such file or directory'
# Nothing happens

dir.create("MoreFigures/2026", recursive = TRUE)
# Now it works

#### Creating multiple plots in a pdf using a loop ####
# .pdf is really useful if you want multiple plots in the same document
# A powerful way to scan through data is to use a loop,
# and loop through variables of interest and write them all to the same pdf.
# Here we will loop through counties and highlight each, but
# one could also loop through years, and show which towns had EEE in each year
# This is slow, so we won't run it, but it's here as an example
pdf(file = "Figures/NYS_county_highlight.pdf")

# Loop through data
counties = sort(unique(eee_towns$COUNTY))
counties # Always good to inspect to make sure it's correct and what you expect

for (this.county in counties){
  # Reset color field
  eee_towns$county_color = 'white'
  
  # Subset to a single year
  eee_towns$county_color[eee_towns$COUNTY == this.county] = 'firebrick4'
  
  # Plot data
  plot(eee_towns, col = eee_towns$county_color, main = this.county)
}

dev.off()
