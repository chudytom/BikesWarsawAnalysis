library(taskscheduleR)
#install.packages("taskscheduleR")
setwd("C:/Users/Lenovo/Documents/pracowaniaProjektowa")

taskscheduler_create(taskname = "rano1", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "07:30", startdate = format(Sys.Date(), "%d/%m/%Y"))

taskscheduler_create(taskname = "rano2", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "07:45", startdate = format(Sys.Date(), "%d/%m/%Y"))

taskscheduler_create(taskname = "rano3", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "08:00", startdate = format(Sys.Date(), "%d/%m/%Y"))

taskscheduler_create(taskname = "rano4", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "08:15", startdate = format(Sys.Date(), "%d/%m/%Y"))

taskscheduler_create(taskname = "poludnie1", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "12:00", startdate = format(Sys.Date(), "%d/%m/%Y"))

taskscheduler_create(taskname = "poludnie2", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "12:30", startdate = format(Sys.Date(), "%d/%m/%Y"))

taskscheduler_create(taskname = "wieczor1", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "16:45", startdate = format(Sys.Date(), "%d/%m/%Y"))

taskscheduler_create(taskname = "wieczor2", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "17:00", startdate = format(Sys.Date(), "%d/%m/%Y"))

taskscheduler_create(taskname = "wieczor3", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "17:15", startdate = format(Sys.Date(), "%d/%m/%Y"))



taskscheduler_create(taskname = "temporary", rscript = "C:/Users/Lenovo/Documents/pracowaniaProjektowa/pobierzDane.R", 
                     schedule = "DAILY", starttime = "00:01", startdate = format(Sys.Date()+1, "%d/%m/%Y"))

taskscheduler_delete(taskname = "rano1")




