#By Joshua Ball
#Down samples images in the given directoy to 256x256, apply contrast enhancment and median filter.
directoryToImages <- "images//"

#Used to save images easily.
library(imager)    
#Used to resize the images to certian value and increase contrast
library(magick)
#Used to filter noise in images
library(EBImage)
library(wvtool)
#For parallelization
library(parallel)
cl <- parallel::makePSOCKcluster(11)#Utilizing 11 of 12 cores on my computer
doParallel::registerDoParallel(cl)
#To use foreach loop
library(foreach)
#set working directory to your respective folder
setwd("C:\\Users\\JoshPC\\Desktop\\food-101")


#Iterating through the images
food101Data <- list.files(path = directoryToImages,
                          full.names = TRUE, recursive = TRUE)
test <- list.files(path = "apple_pie//",
                   full.names = TRUE, recursive = TRUE)
#Moving our food101Data object into a dataframe
data <- data.frame
data <- food101Data

#Looking at data to ensure we have apple pie at the start and waffles at the end
head(data,10)
tail(data,10)
#iterating through data frame of images
#This is now parallized to use all my CPU cores. In practice should only take 20% of time as before.
foreach(x = 1:length(data), .packages=c("magick","imager","EBImage") ) %dopar% {
  #loading image in subdirectory 
  file <- image_read(data[x])
  #Printing for user to be able to follow progress 
  print(paste("Current image:", data[x]))
  #Resize image to 256x256
  resized <- image_scale(image_scale(file,256),256)
  #contrast image
  contrasted <- image_contrast(resized,sharpen=1)
  #convert to cimg format
  converted_contrasted_image <- magick2cimg(contrasted)
  #Apply median filter
  img_median = medianFilter(converted_contrasted_image,1)
  #Save image, overwriting old image
  save.image(img_median, file = gsub("JPG", "jpg", paste(data[x])))
  #Writing to a 'Report.txt' file as %dopar% foreach loops do not allow for printing/logging to console.
  sink("Report.txt", append=TRUE)
}
