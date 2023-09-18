library(curl)
library(zip)
library(here)

#I'm not using rdrop2 because fun fact rdrop2 is in need of a maintainer and may be archived soon

#dropbox link to  'Dropbox (EITM)', 'EITM AR SPRC 2022 Docs', 'Data' folder
dropbox_link <- "https://www.dropbox.com/sh/e0i09i24n9qerew/AABMJb9ZdIo8vEExwTi9sJ4la?dl=1"
destination_dropbox <- file.path(here("20230605_state_histograms", "data_input"), "dropbox_data.zip")
#download dropbox folder as a zip file
curl::multi_download(url = dropbox_link, destfile = destination_dropbox)
#unzip the file
zip::unzip(zipfile = destination_dropbox, exdir = here("20230605_state_histograms", "data_input", "unzipped"))
