#this function is applied over the rows of a nested dataframe 
#nested dataframe is grouped by chromosome, and has a data variable that stores the depths as a tibble
get_histograms <- function(row, bin_width = 10, binwidth_caption = TRUE, graph_caption = "Depths 0-50.") {
  df <- row$data
  chrom <- row$chrom
  chrom_num <- gsub("\\D", "", chrom)
  histogram <- ggplot(df, aes(x = depth)) +
    geom_histogram(color = "darkgray", fill = "gray", binwidth = bin_width) +
    theme_bw() +
    ggtitle(paste("Chromosome", chrom_num, "Depths")) +
    labs(caption = graph_caption) +
    xlim(c(-1, 50)) +
    xlab("Depth") +
    ylab("Count")
  
  if (binwidth_caption == TRUE) {
    histogram <- histogram +
      labs(subtitle = paste("Binwidth:", bin_width))
  } 
  
  
  return(histogram)
}

read_data <- function(file_path) {
  df <- read.table(file_path) %>%
    #remove v2 and v3-- positional columns
      #don't need them for histogram analysis
    dplyr::select(-c("V3", "V2"))
  split <- strsplit(file_path, "/")[[1]]
  file_name <- split[[length(split)]]
  df["sample"] <- str_extract(file_name, "STATE_[[:digit:]]{3}_[[:digit:]]{8}")
  return(df)
}

read_chrom_map_data <- function(file_path) {
  #read in the run file
  df <- read.table(file_path)
  #set a variable for sample so you can keep the sample apart when you combine
    #all the samples into one dataframe
  split <- strsplit(file_path, "/")[[1]]
  file_name <- split[[length(split)]]
  df["sample"] <- str_extract(file_name, "STATE_[[:digit:]]{3}_[[:digit:]]{8}")
  df_new <- df %>%
    #rename variables so they have meaning
    rename(chrom = V1,
           start_pos = V2,
           end_pos = V3,
           depth = V4) %>%
    group_by(chrom) %>%
    mutate(rownum_in_chrom = row_number(),
           last_chrom_row = case_when(rownum_in_chrom == max(rownum_in_chrom) ~ 1,
                                      TRUE ~ 0)) %>%
    ungroup() %>%
    #set a depth_bool variable (0 for depth 0, 1 for depth > 0)
    mutate(depth_bool = case_when(depth == 0 ~ "zero depth",
                               TRUE ~ "greater than zero depth"),
           #first_bin will be set to 0 if this is the first bin (positionally)
            #with this depth_bool
           first_bin = case_when(row_number() == 1 ~ 1,
                                 lag(depth_bool) != depth_bool ~ 1,
                                 TRUE ~ 0),
           #last_bin will be set to 0 if this is the last bin (positionally)
            #with this depth_bool
           last_bin = case_when(last_chrom_row == 1 ~ 1,
                                lead(depth_bool) != depth_bool ~ 1,
                                TRUE ~ 0)) %>%
    #only look at the bins that are the first and last of their depths
      #because we only need the starting and ending positions for chunks of 0 or >0 depths
    filter(first_bin == 1 | last_bin == 1) %>%
    #make sure your dataframe is arranged by chromosome and position
    arrange(chrom, start_pos) %>%
    #get the end position from the last bin
      #lead(end_pos) will take the end_pos (end position) variable from the last bin in this depth_bool chunk
      #because you just organized this dataframe by chromosome and position
    mutate(chunk_end_pos = case_when(first_bin == 1 ~ lead(end_pos),
                                     TRUE ~ end_pos)) %>%
    #now that our first_bin rows have a variable that stores the end_position for their chunk, 
      #we can remove all end last_bin rows
    filter(first_bin == 1) %>%
    #take out the variables you don't need
    dplyr::select(sample, chrom, depth_bool, start_pos, chunk_end_pos) %>%
    #rename end_pos so it matches start_pos
      #end_pos and start_pos now refer to the end and start positions for each depth_bool chunk
    rename(end_pos = chunk_end_pos)
  
  return(df_new)
}

make_ridge_hists <- function(row) {
  data <- row$data
  chrom <- row$chrom
  return_plot <- ggplot(data, aes(x = depth, y = sample)) +
    geom_density_ridges() +
    ggtitle(chrom) +
    xlim(c(-1, 50)) +
    labs(subtitle = "Depths 0-50")
  return(return_plot)
}

make_chrom_graphs <- function(row) {
  chrom <- row$chrom
  print(chrom)
  data <- row$data %>%
    arrange(sample_short)
  
  chr_df <- data %>%
    group_by(sample_short) %>%
    summarise(start_pos = min(start_pos),
              end_pos = max(end_pos)) %>%
    dplyr::select(sample_short, start_pos, end_pos)
  
  annot_df <- data %>%
    mutate(element_name = paste(start_pos, "to", end_pos, sep = "")) %>%
    rename(chromosome_name = sample_short,
           element_start = start_pos,
           element_end = end_pos,
           data = depth_bool) %>%
    dplyr::select(element_name, chromosome_name, element_start, element_end, data)
  
  chr_file <- file.path(tempdir(), "chr_file.txt")
  write.table(chr_df, file = chr_file, col.names = FALSE, row.names = FALSE, sep = "\t")
  
  annot_file <- file.path(tempdir(), "annot_file.txt")
  write.table(annot_df, file = annot_file, col.names = FALSE, row.names = FALSE, sep = "\t")
  
  graph <- chromoMap(chr_file, annot_file, segment_annotation = T, data_type = "categorical", 
                     data_based_color_map = T, legend = T, lg_x = 400, lg_y = 170, 
                     data_colors = list(c("hotpink1", "steelblue1")), title = chrom, 
                     title_font_size = 10)
  # graph <- chromoMapOutput(paste(chrom, "map", sep = "_"))
  return(graph)
}


