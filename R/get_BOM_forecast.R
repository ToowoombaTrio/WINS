
# get BOM XML file for Qld -----------------------------------------------------
# This gets the XML file from the website and then extracts the atributes
# (location infomation) and the values information (the forcast data) into two
# data frames neither of these data frams will make any sense as yet

xmlfile <- xmlTreeParse("ftp://ftp.bom.gov.au/anon/gen/fwo/IDQ11295.xml")
topxml <- xmlRoot(xmlfile)

topxml1 <- xmlSApply(topxml, function(x) xmlSApply(x, xmlAttrs))
xml_df1 <- data.frame(t(topxml1), row.names = NULL)

topxml2 <- xmlSApply(topxml, function(x) xmlSApply(x, xmlValue))
xml_df2 <- data.frame(t(topxml2), row.names = NULL)

## convert the location data frame into something that makes sense and is usable
# this esentally breaks down the nonsensical location data into somthing that
# is useful

# the first step is the break up the text string
mylist <- as.character(list(xml_df1[2]))

mychar <- gsub("\"", "sub", mylist)
bits <- unlist(strsplit(mychar, "sub"))

#second is to remove all the header data that we dont need
bits <- bits[-1]


bits <- as.list(bits[-c(seq(2, length(bits), 2))])
bits <- bits[-grep("\\QLD_", bits)]

# this goes through the location data and clasifies into state, region or
# location information, it then adds the data to a data frame

# Which state are we working with? This is the first field of the data frame.
state <- unlist(bits[which(bits[-1] == "region")])

# How many locations are in a district? Make a vector of the length, we
# subtract 1 from each because we don't need to duplicate it in the locations
# column later
length_districts <- as.numeric(abs(diff(which(bits == "public-district")))) - 1

# What are the district names? This is the second field of the data frame
districts <- unlist(bits[which(bits[-1] == "public-district")])

# rep each district using the calculated length and add 12 for the last district
# not in the vector of length_districts (only works with QLD at the moment,
# this will need to be automated to work with any changes in state or additions/
# subtractions to stations)
districts <- rep(districts, c(length_districts, 12))

# Set public districts to be removed from the list
remove <- unlist(bits[which(bits[-1] == "public-district")])

# Remove the public-district name from the bits list
bits <- bits[!bits %in% remove]

# Join the State field with the region field and location field
bits <- as.data.frame(cbind(rep(unlist(state), length(bits[-c(1:3)])),
                            unlist(districts),
                            unlist(bits[-c(1:3)])))
names(bits) <- c("state", "district", "location")
bits$state <- "QLD"

# Remove rows with the text "public-district" and "location"
bits <- bits[bits$location != "public-district", ]
bits <- bits[bits$location != "location", ]

test <- dplyr::left_join(bits, Australian_Post_Codes_Lat_Lon)

# we then need to convert the case of the Australian_Post_Codes_Lat_Lon names in the BOM location data to upper case
Australian_Post_Codes_Lat_Lon$location <- toupper(Australian_Post_Codes_Lat_Lon$location)

#this sets up a data frame for the lat and lon data to go into through the for loop below
location_lat_lon<-read.table(text = "", colClasses = c("character", "numeric", "numeric"), col.names = c("suburb", "lat", "lon"))

#this for loop looks through the lat and lon data for the Australian_Post_Codes_Lat_Lon that the BOM data covers and extracts the relivant lat and lon
#for Australian_Post_Codes_Lat_Lon that are missing it provides a NA
for (location in Australian_Post_Codes_Lat_Lon$location){
  data<-subset(qld_lat_lon, suburb == location, select = c(suburb, lat, lon))
  if (nrow(data)>1){
    data<-head(data,1)
  }
  if (nrow(data)<1){
    suburb<-location
    lat<-NA
    lon<-NA
    data<-rbind(data, data.frame(suburb, lat, lon))
  }
  location_lat_lon<-rbind(location_lat_lon, data)

}

###this little bit of script identifies any sites missing lat and lon data and puts them into a table####
###still need to build an email alert for missing sites so if BOM adds new foracst sites that we dont have lat and lon for we can add them###
location_lat_lon_NA_find<-location_lat_lon
location_lat_lon_NA_find[is.na(location_lat_lon)] <- 500
sites_with_missing_lat_and_lon<-subset(location_lat_lon_NA_find, lon == 500, select = c(suburb, lat, lon))

#this combines the sortted lat and lon data to out location data frame
Australian_Post_Codes_Lat_Lon<-cbind(Australian_Post_Codes_Lat_Lon, location_lat_lon$lat, location_lat_lon$lon)
Australian_Post_Codes_Lat_Lon<-rename(Australian_Post_Codes_Lat_Lon, c("location_lat_lon$lat" = "lat", "location_lat_lon$lon" = "lon"))


#####Now we are ready to bring in the forcast data#####
#firstly we need to break up the text into segmants that we can work with, this should give us one text string of data per site
mylist<-list(xml_df2[2])
as.character(mylist)
df<-as.data.frame(mylist)
mychar<-gsub("\"", "sub", mylist)
bits <- unlist(strsplit(mychar, 'sub'))
#then we remove the header information that we dont need
bits <-bits[-1]


#now we ste up for the for loop that will extact the data from the text string
bits<-bits[-c(seq(2,length(bits),2))]
master_run<-c(1:length(bits))

#this is seeting up the heading for the data frame that the forcast data will go into
day_1<-paste(c(weekdays(Sys.Date()+1), format(Sys.Date()+1, "%b"), format(Sys.Date()+1, "%d")), collapse="_")
day_2<-paste(c(weekdays(Sys.Date()+2), format(Sys.Date()+2, "%b"), format(Sys.Date()+2, "%d")), collapse="_")
day_3<-paste(c(weekdays(Sys.Date()+3), format(Sys.Date()+3, "%b"), format(Sys.Date()+3, "%d")), collapse="_")
day_4<-paste(c(weekdays(Sys.Date()+4), format(Sys.Date()+4, "%b"), format(Sys.Date()+4, "%d")), collapse="_")
day_5<-paste(c(weekdays(Sys.Date()+5), format(Sys.Date()+5, "%b"), format(Sys.Date()+5, "%d")), collapse="_")
day_6<-paste(c(weekdays(Sys.Date()+6), format(Sys.Date()+6, "%b"), format(Sys.Date()+6, "%d")), collapse="_")

col_names<-c(paste("minR", day_1), paste("maxR", day_1), paste("minT", day_1), paste("maxT", day_1), paste("description", day_1), paste("chance_of_rain", day_1),
             paste("minR", day_2), paste("maxR", day_2), paste("minT", day_2), paste("maxT", day_2), paste("description", day_2), paste("chance_of_rain", day_2),
             paste("minR", day_3), paste("maxR", day_3), paste("minT", day_3), paste("maxT", day_3), paste("description", day_3), paste("chance_of_rain", day_3),
             paste("minR", day_4), paste("maxR", day_4), paste("minT", day_4), paste("maxT", day_4), paste("description", day_4), paste("chance_of_rain", day_4),
             paste("minR", day_5), paste("maxR", day_5), paste("minT", day_5), paste("maxT", day_5), paste("description", day_5), paste("chance_of_rain", day_5),
             paste("minR", day_6), paste("maxR", day_6), paste("minT", day_6), paste("maxT", day_6), paste("description", day_6), paste("chance_of_rain", day_6))

colClasses<-c("numeric", "numeric", "numeric", "numeric", "character", "numeric")
colClasses<-c(rep(colClasses, 6))

#creates an emty data frame for us
data<-read.table(text="", colClasses = colClasses, col.names = col_names)


##for loop to extract the forcast data, this gets a bit complex with for loops within for loops, the first for loop isolates a single text line of data to work on
for (m in master_run){
  forcast<-gsub("%", "sub", bits[m])
  forcast<-unlist(strsplit(forcast, 'sub'))
  #this little bit here removes the forcast for today, it is not in the same formate as the others and its format changes from the morning forcast to the afternoon forcast
  #generally it is just a bear to deal with so I have ignored
  forcast<-forcast[-1]

  #this sets up for a for loop to work through the single line of text to extract the data
  run<-c(1:length(forcast))

  #this for loop works though the line of text and pulls our the rainfall, temperature, description and chance of rain forcast
  for(x in run){
    bit<-unlist(strsplit(forcast[x], ' mm'))
    rain<-(substring(bit[1], 1))

    #rain gets a bit complex as BOM reports is as either a single value or as a porential rain these if functions deal with both of these cases
    if(grepl("to", rain) == "TRUE"){
      rain<-as.numeric(unlist(strsplit(rain, ' to ')))
      maxR<-rain[2]

      Rain1<-as.character(rain[1])
      Rain1<-unlist(strsplit(Rain1,""))
      Rain1_length<-length(Rain1)
      Rain_run<-c(Rain1_length:1)

      minRop<-0
      minR<-0
      for (z in Rain_run){
        factor<-(which(Rain_run == z)-1)
        minRop<-as.numeric(Rain1[z])*10^factor+minRop
        if (minRop < maxR){
          minR<-minRop
        }
      }
    } else {
      maxR<-0
      minR<-0
    }
    #now that rain is out we remove that data from our text string
    bit<-bit[-1]
    #this extracts the temps which is relativly simple
    bit<-paste(substr(bit,1,4), "sub", substr(bit, 5, nchar(bit)), sep = "")
    bit<-unlist(strsplit(bit, 'sub'))
    minT<-substr(bit[1],1,2)
    maxT<-substr(bit[1],3,4)

    #now that temps are our we can remove this bit from the text
    bit<-bit[-1]

    #this deals with the forcast description, It can get complicated as BOM can give one to two different descriptions, the if function deals with these cases
    #and once extracted removes the description from the text string
    bit<-unlist(strsplit(bit, '[.]'))
    if(length(bit) > 2){
      description<-paste(bit[1], bit[2], sep = ",")
      bit<-bit[-1]
      bit<-bit[-1]
    } else {
      description<-bit[1]
      bit<-bit[-1]
    }
    #now we can easily extract the chance of ranfall forcast
    chance_of_rain<-(as.numeric(bit[1])/100)


    #we now combine the forcast data for that day into a dataframe
    day_df<-data.frame(minR, maxR, minT, maxT, description, chance_of_rain)
    assign(paste("day_df", x, sep = '_'), day_df)

  }

  #after the loop has worked through for the week all the data gets combined into a dataframe for the week
  week_df<-cbind(day_df_1, day_df_2, day_df_3, day_df_4, day_df_5, day_df_6)
  colnames(week_df)<-col_names

  #then the weekly data gets added to the rest of the forcast data for the other Australian_Post_Codes_Lat_Lon
  data<-rbind(data,week_df)
}

#this combines the location data with forcast data into one data frame
Wins_data<-cbind(Australian_Post_Codes_Lat_Lon, data)
head(Wins_data)



