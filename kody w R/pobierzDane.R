setwd("C:/Users/Lenovo/Documents/pracowaniaProjektowa")
library(jsonlite)
library(stringi)
library(dplyr)
library(readtext)

wsp <- read.csv("wsp", stringsAsFactors = FALSE)


#API-KEY :
apiKeys <- c("AIzaSyCp9t5tIYIA_uKp1Fi6BWrWgvnZ9PNGQWw", "AIzaSyAdd9dLAHhFG_rc8AseUm44Pl6RLUoQ31I", "AIzaSyAjQCGHOtTL-yZ6GYzAV7_hvVjwaYLo1kU",
                  "AIzaSyAjK_Ctr_UgPfSq4wWsn3OOjiQRlP0d7Eg", "AIzaSyAMMc9DUhOU1T_AlMff8Fat_2F6oX_1Lew", "AIzaSyDu-nG9wU4CSsaFTMCyTepzXz96N3ArV1M", 
                  "AIzaSyBbcrEAHx-G-ZDfBuZxRj1WEykzem0PJqk", "AIzaSyBvjWhoyCJDsLOHSM-VST7eMKvjPljSaQQ", "AIzaSyDSKcM90SZszA6w483cYzzxquu4V6cI9io",
                  "AIzaSyCkYbfYeBWej210phd0Y88CHS9lVlkss2s", "AIzaSyAd2EmKEllKzctuVJWPCu9eXFcR-E7oxuY",
                  "AIzaSyCzdxYlBe5joRNZCU4vAq6OK8tK_PCl2mk")
                  #"AIzaSyAXTNplpw_IhOlnAMB1JOcqrITO3DjHH5s")
# wczytaj indeks niewyczerpanego klucza z pliku zewnętrznego 
# lub
# apiKey <- apiKeys[1]

ind <- as.integer(readtext("indykator")$text)
apiKey <- apiKeys[ind]

# mode : driving, bicycling, transit
# traffic_model : best_guess, optimistic, pesimistic
# departure_time : now
# origins - vector c("wsp1,wsp2", "wsp1, wsp2")

#Do zapisywania
name <- as.character(format(Sys.time(), "%X"))
name <- stri_replace(name, "_", fixed= ":")
name <- stri_extract(name, regex = "^.*(?=(:))")
name <- paste( Sys.Date(), name)

#punkty celu 
dest <- c("52.233119, 20.998018", "52.177438,21.003087")
m <- length(dest)
df_fin <- data.frame()

for(i in seq(1,895,50)){
  
  Sys.sleep(1)
  origins <- wsp[i: min((i+49),895),]
  # ------------------------------------create result data.frame -------------------------------------

  n <- length(origins)
  
  df <- data.frame(matrix(NA, nrow = n*m, ncol = 10))
  names(df) <- c("destination", "origin", "origin_cord", "driving_distance", "driving_time_current", 
                 "driving_time_average", "bicycling_distance", "bicycling_time_current", "transit_distance",      
                 "transit_time_current")
  
  df$origin_cord <- rep(origins, each = m)

  
  #--------------------------- DRIVING
  origins <- paste(origins, collapse ="|")
  dest <- paste(dest, collapse ="|")
  mode <- "driving"
  addres <- paste0("https://maps.googleapis.com/maps/api/distancematrix/json?",
                   "origins=", origins,"&destinations=", dest ,
                   "&mode=", mode, "&traffic_model=best_guess&departure_time=now&key=", apiKey) 
  addres <- stri_replace_all(addres, "", fixed = " ")
  dane <- RJSONIO::fromJSON(addres)
  
  if(dane$status!="OK"){
    addres <- stri_replace_all(addres, apiKeys[ind+1], fixed = apiKey)
    ind <- (ind+1)%%12
    apiKey <- apiKeys[ind]
    dane <- RJSONIO::fromJSON(addres)
  }
  
  # fill df for driving

  df$destination <- rep(dane$destination_addresses, times = n)
  df$origin <- rep(dane$origin_addresses, each = m)
  
  z <- unlist(dane$rows)
  z[z[grepl("elements.status", names(z))]!="OK"]
  
  df$driving_distance <- round(as.numeric(z[grepl("elements.distance.value", names(z))])/1000,1)
  df$driving_time_current <- round(as.numeric(z[grepl("elements.duration_in_traffic.value", names(z))])/60)
  df$driving_time_average <-  round(as.numeric(z[grepl("elements.duration.value", names(z))])/60)

  #--------------------------- BICYCLING
 
  Sys.sleep(1)
  addres <- stri_replace_all(addres, "bicycling", fixed = "driving")
  dane <- RJSONIO::fromJSON(addres)
  
  if(dane$status!="OK"){
    addres <- stri_replace_all(addres, apiKeys[ind+1], fixed = apiKey)
    ind <- (ind+1)%%12
    apiKey <- apiKeys[ind]
    dane <- RJSONIO::fromJSON(addres)
  }
  
  z <- unlist(dane$rows)
  df$bicycling_distance <- round(as.numeric(z[grepl("elements.distance.value", names(z))])/1000,1)
  df$bicycling_time_current <-  round(as.numeric(z[grepl("elements.duration.value", names(z))])/60)

  #------------------------TRANSIT
  Sys.sleep(1)
  addres <- stri_replace_all(addres, "transit", fixed = "bicycling")
  dane <- RJSONIO::fromJSON(addres)
  
  if(dane$status!="OK"){
    addres <- stri_replace_all(addres, apiKeys[ind+1], fixed = apiKey)
    ind <- (ind+1)%%12
    apiKey <- apiKeys[ind]
    dane <- RJSONIO::fromJSON(addres)
  }
  
  z <- unlist(dane$rows)
  
  df$transit_distance[z[grepl("elements.status", names(z))]=="OK"] <- round(as.numeric(z[grepl("elements.distance.value", names(z))])/1000,1)
  df$transit_time_current[z[grepl("elements.status", names(z))]=="OK"] <- round(as.numeric(z[grepl("elements.duration.value", names(z))])/60)
    

  df %>%
    arrange(destination) -> df
  
  df_fin <- rbind(df_fin, df)
  write.csv(df_fin, name)
  write(ind, "indykator")
}


# -------- Zapisz

write.csv(df_fin, name)



