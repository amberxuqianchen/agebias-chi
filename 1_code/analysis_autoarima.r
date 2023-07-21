# This script compares the results of ARIMA under automatically running 10 years' lag and auto.arima to pick the lowest AIC.

setwd("/home/local/PSYCH-ADS/xuqian_chen/Github/agebias-chi")
datafolder <- "./2_pipeline/out"
outputfolder <- "./3_output/results/arima"
# auto.arima
# install.packages("forecast", dependencies = TRUE)
library(forecast)
library(tseries)
# Granger test
library(lmtest)
library(zoo)
library(stargazer)

datapath <- file.path(datafolder,"merged.csv")
dfage <- read.csv(datapath)

dfage$positive <- dfage$old_positive - dfage$young_positive
dfage$negative <- dfage$old_negative - dfage$young_negative
dfage$competent <- dfage$old_competent - dfage$young_competent
dfage$warm <- dfage$old_warm - dfage$young_warm
dfage$incompetent <- dfage$old_incompetent - dfage$young_incompetent
dfage$unwarm <- dfage$old_unwarm - dfage$young_unwarm
dfage$virtue <- dfage$old_virtue - dfage$young_virtue
dfage$vice <- dfage$old_vice - dfage$young_vice
dfage$indicoll <- dfage$indi - dfage$coll
dfage$tightloose <- dfage$tight - dfage$loose
# transform GPD per capita to log scale
dfage$gdp_per_capita_log <- log(dfage$GDP.per.capita)

# loop through dependent variables to run ARIMA, granger causality, and plot
dvs <- c("positive","negative","competent","warm","incompetent","unwarm","virtue","vice")
ivs <- c("indi","coll", "tight","loose")
# ivs <- c("indi","coll")
########
# Notes#
########
# non_seasonal_ar_order = model_fit$arma[1]
# non_seasonal_ma_order = model_fit$arma[2]

# seasonal_ar_order = model_fit$arma[3]
# seasonal_ma_order = model_fit$arma[4]

# period_of_data = model_fit$arma[5] # 1 for is non-seasonal data

# non_seasonal_diff_order = model_fit$arma[6]
# seasonal_diff_order =  model_fit$arma[7]
# ANOTHER WAY TO GET THE ORDER:
# arimaorder(fit)

select_lags<-function(x_var,y_var,max.lag=10) {
  # Initialize AIC and best lag variables
  best_aic <- Inf
  best_lag <- NA
  # Loop through possible lag lengths (up to 5 in this example)
  for (lag in 1:max.lag) {
    # Granger causality test
    granger_model <- lmtest::grangertest(y_var ~ x_var, order = lag)
    
    # Calculate AIC of this model
    granger_aic <- AIC(granger_model)
    
    # If this model's AIC is the best (lowest) so far, update best_aic and best_lag
    if (granger_aic < best_aic) {
      best_aic <- granger_aic
      best_lag <- lag
      }
  }
  # Return best lag length
  return(best_lag)
}
# Create a data frame to store ARIMA and Granger test results
results <- data.frame(
  IV = character(), 
  DV = character(), 
  AR_order = numeric(), 
  I_order = numeric(), 
  MA_order = numeric(),
  best_lag = numeric(), 
  p_value = numeric(), 
  stringsAsFactors = FALSE
)
# create a data frame to store results
granger_results <- data.frame(
  IV = character(), 
  DV = character(), 
  best_lag = numeric(), 
  p_value = numeric(), 
  stringsAsFactors = FALSE
)

for (i in 1:length(dvs)){
    for (j in 1:length(ivs)){
      x_ts <- ts(dfage[,ivs[j]])
      y_ts <- ts(dfage[,dvs[i]])
      gdp_ts <- ts(dfage$gdp_per_capita_log)
      # run ARIMA with GDPpc as controlling variable
      xreg <- cbind(gdp_ts,x_ts)
      fit <- auto.arima(y_ts,xreg = xreg)
      ar <- fit$arma[1]
      ma <- fit$arma[2]
      diff <- fit$arma[6]
      model <- arima(y_ts,order = c(ar,diff,ma),xreg = xreg)

      # lable the ivnames 
      names(model$coef)[names(model$coef) == "xreg1"] <- "GDP per capita"
      names(model$coef)[names(model$coef) == "xreg2"] <- ivs[j]
      # save the model
      model_name <- paste(dvs[i], " (", ar, ",", diff, ",", ma, ")", sep="")
      stargazer(model, summary=FALSE, type="text", out=file.path(outputfolder, paste(dvs[i], ivs[j], sep = "_") %>% paste0("_GDP_arima.txt")), notes=model_name)

      # stargazer(model,summary = FALSE, type = "text", out = file.path(outputfolder,paste(dvs[i],ivs[j],sep = "_") %>% paste0("_arima.txt")))
      model_list[[paste(ivs[j],dvs[i],sep = "+GDP->")]] <- model
      
      # run ARIMA without GDPpc as controlling variable
      xreg <- cbind(x_ts)
      fit <- auto.arima(y_ts,xreg = xreg)
      ar <- fit$arma[1]
      ma <- fit$arma[2]
      diff <- fit$arma[6]
      model <- arima(y_ts,order = c(ar,diff,ma),xreg = xreg)

      # lable the ivnames 
      names(model$coef)[names(model$coef) == "xreg"] <- ivs[j]
      # save the model
      model_name <- paste(dvs[i], " (", ar, ",", diff, ",", ma, ")", sep="")
      stargazer(model, summary=FALSE, type="text", out=file.path(outputfolder, paste(dvs[i], ivs[j], sep = "_") %>% paste0("_arima.txt")), notes=model_name)

      # stargazer(model,summary = FALSE, type = "text", out = file.path(outputfolder,paste(dvs[i],ivs[j],sep = "_") %>% paste0("_arima.txt")))
      model_list[[paste(ivs[j],dvs[i],sep = "->")]] <- model
      # there are aliased (perfectly correlated or duplicate) coefficients between indi and negative
     
      x_fit <- auto.arima(x_ts)
      y_fit <- auto.arima(y_ts)
      resid_x <- residuals(x_fit)
      resid_y <- residuals(y_fit)
      bestlag <- select_lags(resid_x,resid_y)
      try({
        granger_model <- grangertest(dfage[,ivs[j]]~dfage[,dvs[i]],order = bestlag)
        granger_list[[paste(ivs[j],dvs[i],sep = "->")]] <- round(granger_model$`Pr(>F)`[2],digits = 2)
      }, silent=TRUE)
      

      # append to granger_results
      granger_results <- rbind(granger_results, 
                              data.frame(IV = ivs[j], 
                                          DV = dvs[i], 
                                          best_lag = bestlag, 
                                          p_value = round(granger_model$`Pr(>F)`[2],digits = 2)
                                   )
                        )
      # Append to results data frame
    results <- rbind(results, 
      data.frame(
        IV = ivs[j], 
        DV = dvs[i], 
        AR_order = ar, 
        I_order = diff, 
        MA_order = ma,
        best_lag = bestlag, 
        p_value = round(granger_model$`Pr(>F)`[2],digits = 2)
      )
    )
      # bestlag_r <- select_lags(dfage[,ivs[j]],dfage[,dvs[i]])
      # granger_model <- grangertest(dfage[,dvs[i]],dfage[,ivs[j]],order = bestlag)
      # granger_list[[paste(ivs[j],dvs[i],sep = "<-")]] <- round(granger_model$`Pr(>F)`[2],digits = 2)
      # granger_lags[[paste(ivs[j],dvs[i],sep = "->")]] <- grangertest(residuals(model),dfage[,ivs[j]],maxlag = 10)$"Pr(>F)"[1:10]

  
  }
}
# after the loops, save the results to a .csv file
write.csv(granger_results, file = file.path(outputfolder, "granger_results.csv"), row.names = FALSE)
# After loops, save the results to a .csv file
write.csv(results, file = file.path(outputfolder, "arima_granger_results.csv"), row.names = FALSE)
# organize the granger causality test results
granger_df <- data.frame(model_name = names(granger_list),pvalue = unlist(lapply(granger_list,function(x) x$"Pr(>F)"[2])))
granger_df <- data.frame(model_name = names(granger_list),
                         pvalue = unlist(lapply(granger_list, function(x) {
                           if (is.list(x) || is.data.frame(x)) {
                             if("Pr(>F)" %in% names(x)) {
                               return(x[["Pr(>F)"]][2])
                             } else {
                               return("the first NA")  # or other default value
                             }
                           } else {
                             return("the second NA")  # or other default value
                           }
                         })))

# organize the ARIMA model results, including essential stats, lagged years, AIC
model_df <- data.frame(model_name = names(model_list),aic = unlist(lapply(model_list,function(x) x$aic)),lag = unlist(lapply(model_list,function(x) x$arma[4])),stats = unlist(lapply(model_list,function(x) x$coef[3])))
model_df$DV <- sapply(strsplit(as.character(model_df$model_name), "->"), "[", 1)
model_df$IV <- sapply(strsplit(as.character(model_df$model_name), "->"), "[", 2)

# save
stargazer(model_list,summary = FALSE, type = "text", out = file.path(outputfolder,"arima_model.txt"))
print("finish arima_model.txt")
stargazer(model_df,summary = FALSE, type = "text", out = file.path(outputfolder,"arima_summary.txt"))