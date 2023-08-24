# This script compares the results of ARIMA under automatically running 10 years' lag and auto.arima to pick the lowest AIC.
# source: https://towardsdatascience.com/a-quick-introduction-on-granger-causality-testing-for-time-series-analysis-7113dc9420d2
setwd("/home/local/PSYCH-ADS/xuqian_chen/Github/agebias-chi")
datafolder <- "./2_pipeline/out"
arimafolder <- "./3_output/results/arima"
grangerfolder <- "./3_output/results/granger"
if (!dir.exists(arimafolder)) {
  dir.create(arimafolder)
}
if (!dir.exists(grangerfolder)) {
  dir.create(grangerfolder)
}
# auto.arima
# install.packages("forecast", dependencies = TRUE)
library(forecast)
library(tseries)
# Granger test
library(lmtest)
library(zoo)
library(stargazer)
# VAR
library(vars)

datapath <- file.path(datafolder,"merged.csv")
dfage <- read.csv(datapath)
# only keep the year > 1977
# dfage <- dfage[dfage$year >= 1977,]
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
# dvs <- c("positive","negative","competent","warm","incompetent","unwarm","virtue","vice")
ivs <- c("indi","coll", "tight","loose")
dvs <- c("virtue","positive","competent","warm")
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

# Create a data frame to store ARIMA and Granger test results
granger_results <- data.frame(
  IV = character(), 
  DV = character(), 
  best_lag = numeric(), 
  p_value = numeric(), 
  stringsAsFactors = FALSE
)
arima_results <- data.frame()
model_list_GDP <- list()
model_list <- list()
model_names <- c()
model_GDP_names <- c()
model_results <- data.frame(
    
    Predictor = character(),
    Order_p_d_q = character(),
    Coefficient = numeric(),
    SE = numeric(),
    t = numeric(),
    p = numeric(),
    stringsAsFactors = FALSE
  )
  model_GDP_results <- data.frame(
    Predictor = character(),
    Order_p_d_q = character(),
    Coefficient = numeric(),
    SE = numeric(),
    t = numeric(),
    p = numeric(),
    stringsAsFactors = FALSE
  )
granger_results <- data.frame(
  IV = character(),
  DV = character(),
  best_lag = numeric(),
  F_value = character(),
  p_value = numeric(),
  reverse_F_value = character(),
  reverse_p_value = numeric(),
  stringsAsFactors = FALSE
)
for (j in 1:length(dvs)){
    for (i in 1:length(ivs)){
      x_ts <- ts(dfage[,ivs[i]])
      y_ts <- ts(dfage[,dvs[j]])
      gdp_ts <- ts(dfage$gdp_per_capita_log)
      # run ARIMA with GDPpc as controlling variable
      xreg <- cbind(gdp_ts,x_ts)
      fit <- auto.arima(y_ts,xreg = xreg)
      ar <- fit$arma[1]
      ma <- fit$arma[2]
      diff <- fit$arma[6]
      model <- arima(y_ts,order = c(ar,diff,ma),xreg = xreg)

      # lable the ivnames 
      names(model$coef)[names(model$coef) == "gdp_ts"] <- "GDP per capita"
      names(model$coef)[names(model$coef) == "x_ts"] <- ivs[i]
      # save the model
      model_name <- paste(dvs[j], " (", ar, ",", diff, ",", ma, ")", sep="")
      model_GDP_names <- c(model_GDP_names,model_name)
      model_list_GDP[[paste(dvs[j],"~",ivs[i])]] <- model
      # Calculate standard error, z-values and p-values
      standard_error <- sqrt(diag(vcov(model)))['x_ts']
      z_value <- coef(model)[ivs[i]]/standard_error
      p_value <- 2 * (1 - pnorm(abs(z_value)))
      # append to model_results
      model_GDP_results <- rbind(model_GDP_results, 
                                data.frame(Predictor = ivs[i], 
                                            Order_p_d_q = paste(ar, diff, ma, sep = ","), 
                                            Coefficient = round(coef(model)[ivs[i]],3), 
                                            SE = round(standard_error,3),
                                            t = round(z_value,3),
                                            p = round(p_value,3)
                                            )
                                )
      # run ARIMA without GDPpc as controlling variable
      xreg <- cbind(x_ts)
      fit <- auto.arima(y_ts,xreg = xreg)
      ar <- fit$arma[1]
      ma <- fit$arma[2]
      diff <- fit$arma[6]
      model <- arima(y_ts,order = c(ar,diff,ma),xreg = xreg)

      # lable the ivnames 
      names(model$coef)[names(model$coef) == "xreg"] <- ivs[i]

      # save the model
      model_name <- paste(dvs[j], " (", ar, ",", diff, ",", ma, ")", sep="")
      model_names <- c(model_names,model_name)
      model_list[[paste(dvs[j],"~",ivs[i])]] <- model
      # there are aliased (perfectly correlated or duplicate) coefficients between indi and negative

    # Calculate standard error, z-values and p-values
      standard_error <- sqrt(diag(vcov(model)))['xreg']
      z_value <- coef(model)[ivs[i]]/standard_error
      p_value <- 2 * (1 - pnorm(abs(z_value)))
      # append to model_results
      model_results <- rbind(model_results, 
                                data.frame(Predictor = ivs[i], 
                                            Order_p_d_q = paste(ar, diff, ma, sep = ","), 
                                            Coefficient = round(coef(model)[ivs[i]],3), 
                                            SE = round(standard_error,3),
                                            t = round(z_value,3),
                                            p = round(p_value,3)
                                            )
                                )

      x_fit <- auto.arima(x_ts)
      y_fit <- auto.arima(y_ts)
      # fit <- auto.arima(dfage[,dvs[i]],xreg = dfage[,ivs[j]])
      # ar <- fit$arma[1]
      bestlag <- ar

      # try({
      #   # granger_model <- grangertest(dfage[,dvs[j]]~dfage[,ivs[i]],order = bestlag)
      #   granger_model <- grangertest(y_ts~x_ts,order = bestlag)
      #   granger_results <- rbind(granger_results, 
      #                   data.frame(IV = ivs[i], 
      #                               DV = dvs[j], 
      #                               best_lag = bestlag, 
      #                               # best_lag = optimal_lag, 
      #                               p_value = round(granger_model$`Pr(>F)`[2],digits = 3)
      #                         )
      #             )
      # }, silent=TRUE)
      # try({
      #   # granger_model <- grangertest(dfage[,ivs[i]]~dfage[,dvs[j]],order = bestlag)
      #   granger_model <- grangertest(x_ts~y_ts,order = bestlag)
      #   granger_results <- rbind(granger_results, 
      #                   data.frame(IV = dvs[j], 
      #                               DV = ivs[i], 
      #                               best_lag = bestlag, 
      #                               # best_lag = optimal_lag, 
      #                               p_value = round(granger_model$`Pr(>F)`[2],digits = 3)
      #                               )
      #             )
      # }, silent=TRUE)
      
      ## var way of granger

      # # Combine your series into a data frame, this will be the input to the VAR function
      diff_x_order <- x_fit$arma[6]
      diff_y_order <- y_fit$arma[6]
      # differencing order of x and y should be the same because it will influence the length of x and y after differencing
      diff_order <- max(diff_x_order,diff_y_order)
      if(diff_order == 0) {
        diff_x <- x_ts
        diff_y <- y_ts
      } else {
        diff_x <- diff(x_ts,differences = diff_order)
        diff_y <- diff(y_ts,differences = diff_order)
      }
      df <- data.frame(y = diff_y,x = diff_x)
      # Remove rows with NA values
      df <- df[complete.cases(df), ]

      # Fit a VAR model
      # #1 The argument 'ic' specifies the information criterion to use for selecting the lag length
      # In this case, we're using the Akaike information criterion (AIC)
      # var_model <- VAR(df, ic = "AIC")
      # # Perform Granger causality test using the estimated VAR model
      # granger_test <- causality(var_model, cause = "x")
      # # Get the test statistic and p-value
      # statistic <- granger_test$Granger$statistic
      # p_value <- granger_test$Granger$p.value
      # optimal_lag <- var_model$p

      # #2: Determine the best order for the VAR model
      # var_result <- VARselect(df, lag.max = 10, type = "both")
      # # Access the optimal lag according to AIC
      # optimal_lag <- var_result$selection["AIC(n)"]
      # granger_model <- grangertest(diff_y~diff_x,order = optimal_lag)
      # p_value <- granger_model$`Pr(>F)`[2]
      # # append to granger_results
      # granger_results <- rbind(granger_results, 
      #                         data.frame(IV = paste(ivs[i],"(diff)"), 
      #                                     DV = paste(dvs[j],"(diff)"), 
      #                                     # best_lag = bestlag, 
      #                                     best_lag = optimal_lag, 
      #                                     p_value = round(p_value,digits = 3)
      #                              )
      #                   )
      # granger_model <- grangertest(diff_x~diff_y,order = optimal_lag)
      # p_value <- granger_model$`Pr(>F)`[2]
      # # append to granger_results
      # granger_results <- rbind(granger_results, 
      #                         data.frame(IV = paste(dvs[j],"(diff)"), 
      #                                     DV = paste(ivs[i],"(diff)"), 
      #                                     # best_lag = bestlag, 
      #                                     best_lag = optimal_lag, 
      #                                     p_value = round(p_value,digits = 3)
      #                              )
      #                   )
      # #3: use VAR model and causality function to test granger causality
      var_result <- VARselect(df, lag.max = 10,  type = "both")
      optimal_lag <- var_result$selection["AIC(n)"]

      var_model <- VAR(df, p = optimal_lag)
      granger_test <- causality(var_model, cause = "x")
      p_value <- granger_test$Granger$p.value
      f_value <- granger_test$Granger$statistic[[1]]
      df1 <- granger_test$Granger$parameter[[1]]
      df2 <- granger_test$Granger$parameter[[2]]
      reverse_granger_test <- causality(var_model, cause = "y")
      reverse_p_value <- reverse_granger_test$Granger$p.value
      reverse_f_value <- reverse_granger_test$Granger$statistic[[1]]
      reverse_df1 <- reverse_granger_test$Granger$parameter[[1]]
      reverse_df2 <- reverse_granger_test$Granger$parameter[[2]]
      # append to granger_results
      granger_results <- rbind(granger_results, 
                              data.frame(IV = ivs[i], 
                                          DV = dvs[j], 
                                          best_lag = optimal_lag, 
                                          F_value = paste("F(",df1,", ",df2,") = ",round(f_value,2),sep = ""),
                                          p_value = round(p_value,digits = 2),
                                          reverse_F_value = paste("F(",reverse_df1,", ",reverse_df2,") = ",round(reverse_f_value,2),sep = ""),
                                          reverse_p_value = round(reverse_p_value,digits = 2)
                                          )
                                )
      # bestlag_r <- select_lags(dfage[,ivs[j]],dfage[,dvs[i]])
      # granger_model <- grangertest(dfage[,dvs[i]],dfage[,ivs[j]],order = bestlag)
      # granger_list[[paste(ivs[j],dvs[i],sep = "<-")]] <- round(granger_model$`Pr(>F)`[2],digits = 2)
      # granger_lags[[paste(ivs[j],dvs[i],sep = "->")]] <- grangertest(residuals(model),dfage[,ivs[j]],maxlag = 10)$"Pr(>F)"[1:10]

  
  }
}
# after the loops, save the results to a .csv file
write.csv(granger_results, file = file.path(grangerfolder, "diff_granger_results_onlypos_causality.csv"), row.names = FALSE)
write.csv(model_results, file = file.path(arimafolder, "arima_results_onlypos_1977.csv"), row.names = FALSE)
write.csv(model_GDP_results, file = file.path(arimafolder, "arima_results_logGDP_onlypos_1977.csv"), row.names = FALSE)
# save
stargazer(model_list,summary = FALSE, type = "text", column.labels=model_names,star.cutoffs = c(.05, .01,.001), out = file.path(arimafolder,"arima_model_onlypos_1977.txt"))
stargazer(model_list_GDP,summary = FALSE, type = "text",column.labels=model_GDP_names,star.cutoffs = c(.05, .01,.001), out = file.path(arimafolder,"arima_model_logGDP_onlypos_1977.txt"))