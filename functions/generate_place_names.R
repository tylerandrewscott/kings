

packs <- c('tidyverse','qdapDictionaries')
need <- packs[!packs %in% installed.packages()[,'Package']]
if(length(need)>0){install.packages(need)}
lapply(packs, require, character.only = TRUE)

generate_place_names <- function(underscore = F){
   
   #gazetter downloads main page:
   #https://www.census.gov/geographies/reference-files/time-series/geo/gazetteer-files.html
   
   #national counties gazetter file downloaded from
   #https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2021_Gazetteer/2021_Gaz_counties_national.zip
   
   #national places gazetter file downloaded from
   #https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2021_Gazetteer/2021_Gaz_place_national.zip
   
   place_names <- as_tibble(read.table(
      "data_raw/2021_Gaz_place_national.txt",
      sep="\t", quote = "", header=TRUE)) %>% filter(USPS == "CA") %>% 
      mutate(NAME = tolower(NAME)) 
   
   places <- gsub("\\s+\\w*$", "", x = place_names$NAME)
   
   common_names <- c("airport", "alpine", "bend", "cherokee", "commerce",
                     "cottonwood", "crest", "home garden",
                     "lakeside", "live oak", "nice", "oceanside",
                     "orange", "pike", "ponderosa", "riverbank", "strawberry",
                     "vineyard", "volcano", "walnut", "winters")
   patt <- paste0("^", common_names, "$", collapse="|")
   
   places <- str_squish(places[!grepl(patt, places)])
   
   cnty_names <- as_tibble(read.table("data_raw/2021_Gaz_counties_national.txt",
      sep="\t", quote = "", header = TRUE)) %>% filter(USPS == "CA") %>% 
      mutate(NAME = tolower(NAME))
   
   counties <- ifelse(cnty_names$NAME == "orange county" | 
                         cnty_names$NAME == "lake county",
                      cnty_names$NAME,
                    str_squish(str_remove(cnty_names$NAME, pattern = "county")))
   
   names <- unique(tolower(c(counties, places)))
   
   #removing parenthetical parts
   names <- gsub("\\s*\\([^\\)]+\\)","",names)
   
   #removing periods
   names <- gsub("\\.","",names)
   
   #split at / or ,
   names <- unlist(strsplit(names, "\\s*(,|/)\\s*"))
   
   #removing empty entries
   names <- stri_remove_empty_na(names)
   
   if(underscore == T){
      names <- gsub("\\s+", "_", x = names)
   }
   
   return(names)
}