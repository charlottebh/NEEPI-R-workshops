# Northeast Epi R Basics Workshop: Excel to R

# Lindsey Rickerman <lindsey.rickerman@health.ny.gov> and Alexander Keyel <alexander.keyel@health.ny.gov>
# Wadsworth Center
# New York State Department of Health
# November 2026, Albany, NY

##### Set Up #####
# All paths are local to the project directory
# We need to set that directory so we can access the files

setwd('H:/Projects/ne_epi_conf_r/')

#!! NOTE !!#
# When you set your working directory, use a backslash (/)
# If you copy a path from file explorer, you can either change \ to /,
# or escape the forward slahes with another forward slash

setwd('H:\\Projects\\ne_epi_conf_r')

# If you have trouble with the syntax at first,
# you can go to Session > Set Working Directory,
# or the cog dropdown in the files pane
# You can also move the sync the files directory to see all files in your working directory
# Dropdown > Go To Working Directory
# The line of code will appear in the console

# Install and load packages
# readxl reads Excel files
install.packages("readxl")
library(readxl)

# Alternatively, the "pacman" library will install a package if absent
# and load the library if already installed
install.packages("pacman")
library(pacman)

p_load(readxl, tidyverse)

# Explore the package examples
readxl_example()
xlsx_example <- readxl_example("deaths.xlsx")
read_excel(xlsx_example)

# Explore worksheets in the workbook
# Default sheet is first unless specified
excel_sheets(xlsx_example)
df <- read_excel(xlsx_example, sheet = "arts")
View(df)

##### HELP #####
# General help
help.start()

# Help on function read_excel
help(read_excel)
?read_excel

read_excel(xlsx_example, sheet = "arts", skip = 4)
read_excel(xlsx_example, sheet = "arts", range = "A5:F15")

# Search the help system for instances of the string excel
help.search("excel")
??excel

# Examples of function read_excel
example(read_excel)

##### COMMON EXCEL FUNCTIONS IN R #####

# +--------------------+-------------------------------------------------------------------------------------+
# | Excel function     | Use                                                                                 |
# +--------------------+-------------------------------------------------------------------------------------+
# | CONCAT/CONCATENATE | Combines text from multiple ranges and/or strings                                   |
# +--------------------+-------------------------------------------------------------------------------------+
# | COUNTA             | Counts number of cells that are not empty                                           |
# +--------------------+-------------------------------------------------------------------------------------+
# | COUNTIF            | Counts the number of cells that meet the given criteria                             |
# +--------------------+-------------------------------------------------------------------------------------+
# | IF/IFS             | Checks whether a condition is met, and returns one value if true and one   if false |
# +--------------------+-------------------------------------------------------------------------------------+
# | INDEX              | Returns a value or reference at the intersection of a given row and   column        |
# +--------------------+-------------------------------------------------------------------------------------+
# | LEFT/RIGHT         | Returns given number of characters from start or end of string                      |
# +--------------------+-------------------------------------------------------------------------------------+
# | LEN                | Returns the number of characters within a string                                    |
# +--------------------+-------------------------------------------------------------------------------------+
# | MIN/MAX            | Returns smallest or largest number                                                  |
# +--------------------+-------------------------------------------------------------------------------------+
# | SUMIF/AVERAGEIF    | Adds or averages cells that meet given criteria                                     |
# +--------------------+-------------------------------------------------------------------------------------+
# | VLOOKUP            | Returns value in same given row from given column                                   |
# +--------------------+-------------------------------------------------------------------------------------+

# CONCAT/CONCATENATE
paste("Good", "afternoon,", "everyone!", sep = " ")
paste0("This", "Has", "No", "Spaces")

# COUNTA
sum(!is.na(df$`Lots of people`))

# COUNTIF
df |>
  drop_na(`Lots of people`) |>
  count(`...4`==TRUE)

#!! NOTE !!
# Column names with spaces need to be enclosed in backticks (``)

# It is helpful to keep raw data, especially if working with large datasets
# Keeping the raw data allows you to go back and compare changes
# TIP:
# Naming the raw data 'df_raw' or the clean data 'df_clean' will help you keep track
# It is also helpful to periodically save data to new variables
# It will help with reproducibility and prevent accidental over-writing
df_clean <- read_excel(xlsx_example, sheet = "arts", range = "A5:F15")
View(df_clean)

# Conditional: IF/IFS
df_clean[(df_clean$Profession == 'musician') & (df_clean$`Date of birth` >= as.Date("1960-01-01")),]
df_clean[(df_clean$Profession == 'author' | df_clean$`Has kids` == TRUE),]

# INDEX
# Row 1
df_clean[1,]
# Column 3
df_clean[,3]
# Rows 1 and 3, column 2
df_clean[c(1, 3), 2]

# LEFT/RIGHT
my_string <- "This is text to extract, let's try"
substr(my_string, 1, 5)
substr(my_string, nchar(my_string)-4, nchar(my_string))
strsplit(my_string, split = ",")

# LEN
nchar(my_string)

# MIN/MAX
min(df_clean$Age)
max(df_clean$Age)

# SUMIF/AVERAGEIF
sum(df_clean$`Has kids`[df_clean$Age >= 60])
mean(df_clean$Age[df_clean$Profession == "musician"])

# VLOOKUP
df_clean$Name[df_clean$Age==max(df_clean$Age)]

##### CLEANING DATA #####
# 'Cleaning' data often is often a sequential set of operations
# It can refer to importing data, changing column names, filtering, de-duplication, and more

## CORE FUNCTIONS ##
# +-----------------------------------+------------------------------------------+-------------------+
# |              Function             |                  Utility                 |      Package      |
# +-----------------------------------+------------------------------------------+-------------------+
# | |>                              | “pipe” (pass) data from one function to  | magrittr          |
# |                                   | the next                                 |                   |
# +-----------------------------------+------------------------------------------+-------------------+
# | mutate()                          | create, transform, and re-define columns | dplyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | select()                          | keep, remove, select, or re-name columns | dplyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | rename()                          | rename columns                           | dplyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | clean_names()                     | standardize the syntax of column names   | janitor           |
# +-----------------------------------+------------------------------------------+-------------------+
# | as.character(), as.numeric(),     | convert the class of a column            | base R            |
# | as.Date(), etc.                   |                                          |                   |
# +-----------------------------------+------------------------------------------+-------------------+
# | across()                          | transform multiple columns at one time   | dplyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | tidyselect functions              | use logic to select columns              | tidyselect        |
# +-----------------------------------+------------------------------------------+-------------------+
# | filter()                          | keep certain rows                        | dplyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | distinct()                        | de-duplicate rows                        | dplyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | rowwise()                         | operations by/within each row            | dplyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | add_row()                         | add rows manually                        | tibble            |
# +-----------------------------------+------------------------------------------+-------------------+
# | arrange()                         | sort rows                                | dplyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | recode()                          | re-code values in a column               | dplyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | case_when()                       | re-code values in a column using more    | dplyr             |
# |                                   | complex logical criteria                 |                   |
# +-----------------------------------+------------------------------------------+-------------------+
# | replace_na(), na_if(), coalesce() | special functions for re-coding          | tidyr             |
# +-----------------------------------+------------------------------------------+-------------------+
# | age_categories() and cut()        | create categorical groups from a numeric | epikit and base R |
# |                                   | column                                   |                   |
# +-----------------------------------+------------------------------------------+-------------------+
# | match_df()                        | re-code/clean values using a             | matchmaker        |
# |                                   | data dictionary                          |                   |
# +-----------------------------------+------------------------------------------+-------------------+
# | which()                           | apply logical criteria; return indices   | base R            |
# +-----------------------------------+------------------------------------------+-------------------+

# View column names
names(df_clean)

# Change column names
df_clean |>
  rename(name = Name,
         profession = Profession,
         age = Age,
         has_kids = `Has kids`,
         date_of_birth = `Date of birth`,
         date_of_death = `Date of death`)

p_load(janitor)
df_clean_names <- df_clean |>
  clean_names()

# By column position
rename(newNameForFirstColumn  = 1,
       newNameForSecondColumn = 2)

# Via select() or summarize()
df_clean |>
  select(# NEW name             # OLD name
    date_of_birth     = `Date of birth`,    # rename and KEEP ONLY these columns
    date_of_death     = `Date of death`)

# Select or reorder columns
df_clean_names |>
  select(name, profession, date_of_birth, date_of_death) |>
  names()

## TIDYSELECT FUNCTIONS

# +---------------+--------------------------------------------------------------------+
# | Function      | Utility                                                            |
# +---------------+--------------------------------------------------------------------+
# | everything()  | all other columns not mentioned                                    |
# +---------------+--------------------------------------------------------------------+
# | last_col()    | the last column                                                    |
# +---------------+--------------------------------------------------------------------+
# | where()       | applies a function to all columns and selects those which are TRUE |
# +---------------+--------------------------------------------------------------------+
# | contains()    | columns containing a character string                              |
# +---------------+--------------------------------------------------------------------+
# | starts_with() | matches to a specified prefix                                      |
# +---------------+--------------------------------------------------------------------+
# | ends_with()   | matches to a specified suffix                                      |
# +---------------+--------------------------------------------------------------------+
# | matches()     | to apply a regular expression (regex)                              |
# +---------------+--------------------------------------------------------------------+
# | num_range()   | a numerical range like x01, x02, x03                               |
# +---------------+--------------------------------------------------------------------+
# | any_of()      | matches IF column exists but returns no error if it is not found   |
# +---------------+--------------------------------------------------------------------+

df_clean_names |>
  select(where(is.numeric)) |>
  names()

df_clean_names |>
  select(contains("date")) |>
  names()

# Remove columns
df_clean_names |>
  select(-where(is.numeric)) |>
  names()

# De-duplication
df_clean_names |>
  distinct()

df_clean_names |>
  distinct(age)

# Column creation & transformation
df_clean_names |>
  mutate(new_col = 10)

df_clean_names |>
  mutate(months = age * 12)

# Grouped data
df_clean_names |>
  group_by(profession) |>
  mutate(avg_age = mean(age),
         age_norm = age / mean(age, na.rm = T))

# Transform multiple columns
df_clean_names |>
  mutate(across(.cols = c(age, date_of_birth, date_of_death), .fns = as.character))

# Add rows
df_new <- df_clean_names |>
  add_row(name = 'Patrick Stewart',
          profession = 'actor',
          age = 86,
          has_kids = NA,
          date_of_birth = as.Date('1940-07-13'),
          date_of_death = as.Date('2026-10-28'))

# Filter rows
df_new |>
  filter(profession == 'actor')

df_new |>
  filter(row_number() == 5)

df_new |>
  drop_na(has_kids)

# Arrange & sort
df_new |>
  arrange(name, desc(age))


##### WORKING WITH DATES #####

# +----------+---------------------------------------------+
# | Function | Utility                                     |
# +----------+---------------------------------------------+
# | %d       | Day number of month (5, 17, 28, etc.)       |
# +----------+---------------------------------------------+
# | %j       | Day number of the year (Julian day 001-366) |
# +----------+---------------------------------------------+
# | %a       | Abbreviated weekday (Mon, Tue, Wed, etc.)   |
# +----------+---------------------------------------------+
# | %A       | Full weekday (Monday, Tuesday, etc.)        |
# +----------+---------------------------------------------+
# | %w       | Weekday number (0-6, Sunday is 0)           |
# +----------+---------------------------------------------+
# | %u       | Weekday number (1-7, Monday is 1)           |
# +----------+---------------------------------------------+
# | %W       | Week number (00-53, Monday is week start)   |
# +----------+---------------------------------------------+
# | %U       | Week number (01-53, Sunday is week start)   |
# +----------+---------------------------------------------+
# | %m       | Month number (e.g. 01, 02, 03, 04)          |
# +----------+---------------------------------------------+
# | %b       | Abbreviated month (Jan, Feb, etc.)          |
# +----------+---------------------------------------------+
# | %B       | Full month (January, February, etc.)        |
# +----------+---------------------------------------------+
# | %y       | 2-digit year (e.g. 89)                      |
# +----------+---------------------------------------------+
# | %Y       | 4-digit year (e.g. 1989)                    |
# +----------+---------------------------------------------+
# | %h       | hours (24-hr clock)                         |
# +----------+---------------------------------------------+
# | %m       | minutes                                     |
# +----------+---------------------------------------------+
# | %s       | seconds                                     |
# +----------+---------------------------------------------+
# | %z       | offset from GMT                             |
# +----------+---------------------------------------------+
# | %Z       | Time zone (character)                       |
# +----------+---------------------------------------------+

# Current date (class=date)
Sys.Date()

# Current time (class=datetime)
Sys.time()

# Convert to date
as.Date('2026-10-11')
as.Date('10/11/2026', format = "%m/%d/%Y")
as.Date('Oct 11, 26', format = "%b %d, %y")

# Lubridate date functions
p_load(lubridate)

# Convert date from year, month, day
ymd("2026-10-11")
ymd("20261011")

# Convert date from month, day, year
mdy("10/11/2026")
mdy("Oct 11 26")

# Convert date from day, month, year
dmy("11 10 2026")
dmy("11 October 2026")

# Convert date to year, month, or day
year("2026-10-11")
month("2026-10-11")
day("2026-10-11")

# Dates in Excel
df <- read_excel('MeaslesCasesWeekly.xls')
# View column names and types in side panel
df$week_start
as.Date(df$week_start[1])
# 2096-10-05
as.Date(df$week_start[1], origin = "1899-12-30")
# First day of 20th century = day 1

#~~ Fun Fact ~~#
# The 'as.Date' function uses '1970-01-01' as the origin
# Excel uses '1899-12-30'
# Incorrectly assumed 1900 was leap year
# 1900 Jan 1 - 1900 Feb 29 all one day ahead
# NOT an Excel bug
# Lotus 1-2-3 was original spreadsheet program
# It assumed 1900 was a leap year
# Excel adopted this for smooth transition

df <- read_excel('MeaslesCasesWeekly.xls', col_types = c('date', 'numeric'))

##### STRINGS & CHARACTERS #####
# Combine strings
first_names <- c("george", "whitney", "leonardo")
last_names  <- c("washington", "houston", "davinci")

# 'sep' displays between each input string
# 'collapse' displays between the elements produced
str_c(first_names, last_names, sep = " ", collapse = ";  ")

# 'cat' for new lines
cat(str_c(first_names, last_names, sep = " ", collapse = ";\n"))

str_glue("Data include {length(unique(case_map$Location))} states/territories and are current to {format(Sys.Date(), '%d %b %Y')}.")

str_glue("Data as of {current_date}.\nMost cases reported in {current_year}:\n{state} with {cases} cases.",
         current_date = format(Sys.Date(), '%d %b %Y'),
         current_year = format(Sys.Date(), '%Y'),
         state = case_map$Location[case_map$`2026`==max(case_map$`2026`)],
         cases = case_map$`2026`[case_map$`2026`==max(case_map$`2026`)])

# Pull from a data frame
# Subset data to first five rows
subset_df <- cdc_cases[1:5,]

subset_df |> 
  str_glue_data("{week_start}: {case_wk} ({round(case_wk / case_yr * 100, 2)}% total cases in {year})")

# Put in one line
str_c(subset_df$week_start, subset_df$case_wk, sep = " = ", collapse = ";  ")

# Unite columns
df <- data.frame(
  case_ID = c(1:6),
  symptoms  = c("jaundice, fever, chills",     # patient 1
                "chills, aches, pains",        # patient 2 
                "fever",                       # patient 3
                "vomiting, diarrhea",         # patient 4
                "bleeding from gums, fever",   # patient 5
                "rapid pulse, headache"),      # patient 6
  outcome = c("Recover", "Death", "Death", "Recover", "Recover", "Recover"))

df_split <- separate(df, symptoms, into = c("sym_1", "sym_2", "sym_3"), extra = "merge")

df_split |> 
  unite(
    col = "all_symptoms",         # name of the new united column
    c("sym_1", "sym_2", "sym_3"), # columns to unite
    sep = ", ",                   # separator to use in united column
    remove = TRUE,                # if TRUE, removes input cols from the data frame
    na.rm = TRUE                  # if TRUE, missing values are removed before uniting
  )

# Standardize case
# Uppercase
str_to_upper('New york')
# Lowercase
str_to_lower('New york')
# Title case
str_to_title('New york is home to millions of people')
# More nuanced capitalization (words like “to”, “the”, and “of” are not capitalized)
tools::toTitleCase('New york is home to millions of people')
# Sentence case
str_to_sentence("the State has a large population.")

##### PIVOT DATA #####
count_data <- readRDS("malaria_facility_count_data.rds")
count_data

# Wide to long
df_long <- count_data |>
  pivot_longer(
    cols = c(`malaria_rdt_0-4`, `malaria_rdt_5-14`, `malaria_rdt_15`, `malaria_tot`)
  )

df_long

count_data |>
  pivot_longer(
    cols = starts_with("malaria_")
  )

# By column position
count_data |>
  pivot_longer(
    cols = 6:9
  )

# By range of consecutive columns
count_data |>
  pivot_longer(
    cols = `malaria_rdt_0-4`:malaria_tot
  )

df_long <- count_data |>
  pivot_longer(
    cols = starts_with("malaria_"),
    names_to = "age_group",
    values_to = "counts"
  )

df_long

# Long to wide
linelist <- readRDS("linelist_cleaned.rds")

df_wide <- linelist |>
  count(age_cat, gender)

df_wide

table_wide <- df_wide |>
  pivot_wider(
    id_cols = age_cat,
    names_from = gender,
    values_from = n
  )

table_wide

##### GROUPING DATA #####
ll_by_outcome <- linelist |>
  group_by(outcome)

ll_by_outcome

# Unique groups
linelist |>
  group_by(outcome) |>
  tally()

linelist |>
  group_by(outcome, gender) |>
  tally()

# New columns
# Group based on column created *within* the group_by()
linelist |>
  group_by(
    age_class = ifelse(age >= 18, "adult", "child")) |>
  tally(sort = T)

# Add/drop groups
# Grouped by outcome
by_outcome <- linelist |>
  group_by(outcome)

# Add grouping by gender
by_outcome_gender <- by_outcome |>
  group_by(gender, .add = TRUE)

# Ungroup
linelist |>
  group_by(outcome, gender) |>
  tally() |>
  ungroup()

linelist |>
  group_by(outcome, gender) |>
  tally() |>
  ungroup(gender) # remove the grouping by gender, leave grouping by outcome

# Summarize
linelist |>
  summarise(
    n_cases  = n(),
    mean_age = mean(age_years, na.rm=T),
    max_age  = max(age_years, na.rm=T),
    min_age  = min(age_years, na.rm=T),
    n_males  = sum(gender == "m", na.rm=T))

linelist |>
  group_by(outcome) |>
  summarise(
    n_cases  = n(),
    mean_age = mean(age_years, na.rm=T),
    max_age  = max(age_years, na.rm=T),
    min_age  = min(age_years, na.rm=T),
    n_males    = sum(gender == "m", na.rm=T))

# Counts & tallies
linelist |>
  tally()

linelist |>
  group_by(outcome) |>
  tally(sort = TRUE)

linelist |>
  count(outcome)

linelist |>
  count(age_class = ifelse(age >= 18, "adult", "child"), sort = T)

linelist |>
  # produce counts by unique outcome-gender groups
  count(gender, hospital) |>
  # gather rows by gender (3) and count number of hospitals per gender (6)
  count(gender, name = "hospitals per gender" ) 

# Add counts
linelist |>
  as_tibble() |>                  # convert to tibble for nicer printing 
  add_count(hospital) |>          # add column n with counts by hospital
  select(hospital, n, everything()) # re-arrange for demo purposes

# Add totals
linelist |>                                 # case linelist
  tabyl(age_cat, gender) |>                 # cross-tabulate counts of two columns
  adorn_totals(where = "row") |>            # add a total row
  adorn_percentages(denominator = "col") |> # convert to proportions with column denominator
  adorn_pct_formatting() |>                 # convert proportions to percents
  adorn_ns(position = "front") |>           # display as: "count (percent)"
  adorn_title(                                # adjust titles
    row_name = "Age Category",
    col_name = "Gender")

# Filter grouped data
linelist %>%
  group_by(hospital) %>%
  arrange(hospital, date_hospitalisation) %>%
  slice_head(n = 5) |>
  arrange(hospital) |>                           # for display
  select(case_id, hospital, date_hospitalisation)  # for display

linelist |>
  as_tibble() |>
  add_count(hospital) |>         # add "number of rows admitted to same hospital as this row" 
  select(hospital, n, everything())

# Mutate grouped data
linelist |>
  group_by(hospital) |>
  mutate(
    group_delay_admit = round(mean(days_onset_hosp, na.rm=T), 1),
    diff_to_group     = round(days_onset_hosp - group_delay_admit, 1)) %>%
  select(case_id, hospital, days_onset_hosp, group_delay_admit, diff_to_group)

##### JOINING DATA #####
linelist_mini <- linelist |>                # start with original linelist
  select(case_id, date_onset, hospital) |>  # select columns
  head(10)                                    # only take the first 10 rows

hosp_info = data.frame(
  hosp_name     = c("central hospital", "military", "military", "port", "St. Mark's", "ignace", "sisters"),
  catchment_pop = c(1950280, 40500, 10000, 50280, 12000, 5000, 4200),
  level         = c("Tertiary", "Secondary", "Primary", "Secondary", "Secondary", "Primary", "Primary")
)

# Pre-clean to make even match
unique(linelist_mini$hospital)
unique(hosp_info$hosp_name)

# Align values
hosp_info <- hosp_info |>
  mutate(
    hosp_name = case_when(
      # criteria                         # new value
      hosp_name == "military"          ~ "Military Hospital",
      hosp_name == "port"              ~ "Port Hospital",
      hosp_name == "St. Mark's"        ~ "St. Mark's Maternity Hospital (SMMH)",
      hosp_name == "central hospital"  ~ "Central Hospital",
      TRUE                             ~ hosp_name
    )
  )

# dplyr join
# Join based on common values between column "ID" (first data frame) and column "identifier" (second data frame)
joined_data <- left_join(df1, df2, by = c("ID" = "identifier"))

# Join based on common values in column "ID" in both data frames
joined_data <- left_join(df1, df2, by = "ID")

# Join based on same first name, last name, and age
joined_data <- left_join(df1, df2, by = c("name" = "firstname", "surname" = "lastname", "Age" = "age"))

# Left & right joins
# Left join = first data frame written is baseline
# Right join = second data frame written is baseline

linelist_mini |>
  left_join(hosp_info, by = c("hospital" = "hosp_name"))

# Two new columns, catchment_pop and level have been added on the left side of linelist_mini
# All original rows of the baseline data frame linelist_mini are kept
# Any original rows of linelist_mini for “Military Hospital” are duplicated
# because it matched to two rows in the secondary data frame, so both combinations are returned
# The join identifier column of the secondary dataset (hosp_name) has disappeared
# because it is redundant with the identifier column in the primary dataset (hospital)
# When a baseline row did not match to any secondary row, NA (blank) fills in the columns from the secondary data frame
# Rows in the secondary data frame with no match to the baseline data frame (“sisters” and “ignace” hospitals) were dropped

# Full join
# Most inclusive of the joins - it returns all rows from both data frames
linelist_mini |>
  full_join(hosp_info, by = c("hospital" = "hosp_name"))

# All baseline rows are kept (linelist_mini)
# Rows in the secondary that do not match to the baseline are kept,
# with values in the corresponding baseline columns case_id and onset filled in with missing values
# Rows in the baseline data frame that do not match to the secondary are kept,
# with secondary columns catchment_pop and level filled-in with missing values
# In the case of one-to-many or many-to-one matches, all possible combinations are returned (lengthening the final data frame)
# Only the identifier column from the baseline is kept (hospital)

# Inner join
# Most restrictive of the joins - it returns only rows with matches across both data frames
linelist_mini |>
  inner_join(hosp_info, by = c("hospital" = "hosp_name"))

# Semi join
# “Filtering join” - uses another dataset to perform filtering
# Keeps all observations in the baseline data frame that have a match in the secondary data frame
hosp_info |>
  semi_join(linelist_mini, by = c("hosp_name" = "hospital"))

# Anti join
# “Filtering join” - returns rows in the baseline data frame that do not have a match in the secondary data frame
hosp_info |>
  anti_join(linelist_mini, by = c("hosp_name" = "hospital"))

# Binding & aligning
# Bind rows
# Create core table
hosp_summary <- linelist |>
  group_by(hospital) |>                       # Group data by hospital
  summarise(                                    # Create new summary columns of indicators of interest
    cases = n(),                                  # Number of rows per hospital-outcome group     
    ct_value_med = median(ct_blood, na.rm=T))     # median CT value per group

# Create totals
totals <- linelist |>
  summarise(
    cases = n(),                               # Number of rows for whole dataset     
    ct_value_med = median(ct_blood, na.rm=T))  # Median CT for whole dataset

# Bind data frames together
combined <- bind_rows(hosp_summary, totals)

# Bind columns
# Case information
case_info <- linelist |>
  group_by(hospital) |>
  summarise(
    cases = n(),
    deaths = sum(outcome == "Death", na.rm=T)
  )

contact_fu <- data.frame(
  hospital = c("St. Mark's Maternity Hospital (SMMH)", "Military Hospital", "Missing", "Central Hospital", "Port Hospital", "Other"),
  investigated = c("80%", "82%", NA, "78%", "64%", "55%"),
  per_fu = c("60%", "25%", NA, "20%", "75%", "80%")
)

# Match aligns rows of a data frame in the same order as in another
match(case_info$hospital, contact_fu$hospital)

contact_fu_aligned <- contact_fu[match(case_info$hospital, contact_fu$hospital),]

bind_cols(case_info, contact_fu)

