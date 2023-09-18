# state_plots

this repo contains scripts for the histograms and chromosome maps for Vaidhy/STATE's "zero reads" issue

BEFORE YOU RUN ANY MARKDOWNS!!! you must download everything from dropbox with the dropbox_downloader.R file in the main directory.
  - I don't like reading things directly from Dropbox because when the files get too old in there you have to "wake them up" (bring them into memory you can use?) by opening them
  - and I hate going through and opening all the files i want
  - so I use my dropbox_downloader to copy all the files to my local machine
  - you might have to make a folder called "data_input" for them to copy into (or you could script that... i have always been too lazy to do that)

After you run dropbox_downloader.R the markdowns *should* run fine. But if you have any issues message Abby Coleman on Slack or email at acoleman@eitm.org.

the files to look at are the all_hists_in_one.Rmd for the histograms and chromosome_zero_read_mapx.Rmd for the chromosome maps (both in the main directory)
  - histograms: <img width="683" alt="Screenshot 2023-09-14 at 10 19 19 AM" src="https://github.com/eitm-org/vaidhy_quick_histogram/assets/85528557/505b06fd-a2f3-4b3e-bd1a-fab0696e0598">
  - chromosome maps: <img width="379" alt="image" src="https://github.com/eitm-org/vaidhy_quick_histogram/assets/85528557/88c9811b-8e78-400c-8a3e-70bd20479738">

documentation for the chromomaps package is [here](https://cran.r-project.org/web/packages/chromoMap/vignettes/chromoMap.html)
they have info about how to add the centromere location!!! and it looks so cute!!

the *one* bad thing about chromomaps is I don't think you can add it to a normal markdown output. like you just have to run the markdown output as a markdown, don't try to put it into an HTML. it is [impossible](https://stackoverflow.com/questions/69995135/save-chromomap-plots-in-base-r) to save the plots as other types of files. the plots are htmlwidgets, so if you know more about html you might be able to figure it out? but I (Abby) could not.
