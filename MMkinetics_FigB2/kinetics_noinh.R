library(ggplot2)
library(scales)
library(latex2exp)
library(colorspace)

wtP91 <- read.csv('wtP91.csv', header=T)
I211E <- read.csv('I211E.csv', header=T)
I211R <- read.csv('I211R.csv', header=T)
I211WL214V <- read.csv('I211WL214V.csv', header=T)
I211W <- read.csv('I211W.csv', header=T)



kinetics_list <- list(wtP91,I211E,I211R,I211WL214V,I211W)  # Add all your data frames here
df_names <- list("wtP91","I211E","I211R","I211WL214V","I211W")


# Create an empty list to store the plots
plot_list <- list()
par(mfrow = c(2, 3))  # Set the desired layout for the plots

# Loop over each data frame
for (i in seq_along(kinetics_list)) {
  kinetics <- kinetics_list[[i]]
  df_name <- df_names[i]

  # Subset the data frame
  kinetics <- subset(kinetics, Product < 1)
  kinetics <- subset(kinetics, Substrate < 0.00015)
  
  # Plot
  plot_obj <- plot(kinetics$Substrate, kinetics$Product, xlab = "Fluo-DDEP (M)", ylab = "Rate (1/s)")
  
  # Nonlinear regression with weighted least squares
  weights <- 1 / kinetics$Substrate  # Assign weights inversely proportional to Substrate
  invalid_weights <- is.na(weights) | is.infinite(weights)  # Check for invalid weights
  if (any(invalid_weights)) {
    kinetics <- kinetics[!invalid_weights, ]  # Remove data points with invalid weights
    weights <- weights[!invalid_weights]  # Remove corresponding weights
  }  
  
  bulk_mm.nls <- nls(Product ~ Vmax * Substrate / (Km + Substrate * (1 + Substrate/(500*10^-6))),
                     data = kinetics, start = list(Km = 30*10^-6, Vmax = 0.5),
                     weights = weights)
    summary(bulk_mm.nls)
  
  # Coefficients
  Km_bulk <- unname(coef(bulk_mm.nls)["Km"])
  Vmax_bulk <- unname(coef(bulk_mm.nls)["Vmax"])


  # Calculate x and y values
  x_bulk <- seq(0, max(kinetics$Substrate), by = max(kinetics$Substrate) / 1000)
  y_bulk <- Vmax_bulk * x_bulk / (Km_bulk + x_bulk*(1+x_bulk/(500*10^-6)))
  
  # Add line to plot
  lines(x_bulk, y_bulk, lty = "dotted", col = "blue")
  
  # Display ratio Vmax/Km
  Vmax_Km_ratio <- Vmax_bulk / Km_bulk
  
  Km_bulk <- signif(Km_bulk, digits = 4)
  Vmax_bulk <- signif(Vmax_bulk, digits = 4)
  Vmax_Km_ratio <- signif(Vmax_Km_ratio, digits=4)
  
  print(Vmax_bulk)
  print(Km_bulk)
  print(Vmax_Km_ratio)
  
  # Fit
  #kinetics$fit <- Vmax_bulk * kinetics$substrate / (Km_bulk + kinetics$substrate * (1 + (kinetics$substrate) / Ks_bulk))
  
  # Display parameter values
  df_name_char <- as.character(df_name)
 #mtext(paste("Variant:", df_name, "\nKm =", Km_bulk, "uM, \n"kcat =", Vmax_bulk, "\nkcat/Km=", Vmax_Km_ratio), side = 3, cex=0.8)
  mtext(substitute(paste("Variant:", df_name_value, "\n","Km =", Km_value, "M", "\n", "kcat =", Vmax_value, s^-1),
                   list(df_name_value = df_name_char, Km_value = Km_bulk, Vmax_value = Vmax_bulk)), side = 3, cex = 0.8)
 # Store the plot object in the list
 plot_list[[i]] <- plot_obj
 
}

# Plot all stored plots
for (i in seq_along(plot_list)) {
  plot(plot_list[[i]])
}




