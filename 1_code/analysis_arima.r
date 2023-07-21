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
# ivs <- c("indi","coll", "tight","loose")
ivs <- c("indi","coll")
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

granger_list <- list()
granger_lags <- list()
model_list <- list()
select_lags<-function(x_var,y_var,max.lag=10) {
    # Create time series objects for each variable
    x_ts <- ts(x_var)
    y_ts <- ts(y_var)
    # Fit ARIMA models to each time series
    x_fit <- auto.arima(x_ts)
    y_fit <- auto.arima(y_ts)
    x_ar = x_fit$arma[1]
    x_ma = x_fit$arma[2]
    x_diff = x_fit$arma[6]
    y_ar = y_fit$arma[1]
    y_ma = y_fit$arma[2]
    y_diff = y_fit$arma[6]
    x_model <- arima(x_ts, order=c(x_ar, x_diff, x_ma))
    y_model <- arima(y_ts, order=c(y_ar, y_diff, y_ma))
    # Extract residuals from each ARIMA model
    x <- residuals(x_model)
    y<- residuals(y_model)

    y<-as.numeric(y)
    y.lag<-embed(y,max.lag+1)[,-1,drop=FALSE]
    x.lag<-embed(x,max.lag+1)[,-1,drop=FALSE]
    
    t<-tail(seq_along(y),nrow(y.lag))
    
    # ms=lapply(1:max.lag,function(i) lm(y[t]~y.lag[,1:i]+x.lag[,1:i]))
    ms = lapply(1:max.lag, function(i) arima(y[t], xreg=cbind(y.lag[,1:i],x.lag[,1:i]), order=c(ar,diff,ma)))
    pvals<-mapply(function(i) anova(ms[[i]],ms[[i-1]])[2,"Pr(>F)"],max.lag:2)

    ind<-which(pvals<0.05)[1]
    ftest<-ifelse(is.na(ind),1,max.lag-ind+1)
    
    aic<-as.numeric(lapply(ms,AIC))
    bic<-as.numeric(lapply(ms,BIC))
    structure(list(ic=cbind(aic=aic,bic=bic),pvals=pvals,xresid=ts(x),yresid = ts(y),
      selection=list(aic=which.min(aic),bic=which.min(bic),ftest=ftest)))
}


for (i in 1:length(dvs)){
    for (j in 1:length(ivs)){
      # run ARIMA with GDPpc as controlling variable
      xreg <- cbind(dfage$gdp_per_capita_log,dfage[,ivs[j]])
      fit <- auto.arima(dfage[,dvs[i]],xreg = xreg)
      ar <- fit$arma[1]
      ma <- fit$arma[2]
      diff <- fit$arma[6]
      model <- arima(dfage[,dvs[i]],order = c(ar,diff,ma),xreg = xreg)

      # lable the ivnames 
      names(model$coef)[names(model$coef) == "xreg1"] <- "GDP per capita"
      names(model$coef)[names(model$coef) == "xreg2"] <- ivs[j]
      # save the model

      model_name <- paste(dvs[i], " (", ar, ",", diff, ",", ma, ")", sep="")
      stargazer(model, summary=FALSE, type="text", out=file.path(outputfolder, paste(dvs[i], ivs[j], sep = "_") %>% paste0("_GDP_arima.txt")), notes=model_name)

      # stargazer(model,summary = FALSE, type = "text", out = file.path(outputfolder,paste(dvs[i],ivs[j],sep = "_") %>% paste0("_arima.txt")))
      model_list[[paste(ivs[j],dvs[i],sep = "->")]] <- model
      
      # run ARIMA without GDPpc as controlling variable
      xreg <- dfage[,ivs[j]]
      fit <- auto.arima(dfage[,dvs[i]],xreg = xreg)
      ar <- fit$arma[1]
      ma <- fit$arma[2]
      diff <- fit$arma[6]
      model <- arima(dfage[,dvs[i]],order = c(ar,diff,ma),xreg = xreg)

      # lable the ivnames 
      names(model$coef)[names(model$coef) == "xreg"] <- ivs[j]

      # save the model
      model_name <- paste(dvs[i], " (", ar, ",", diff, ",", ma, ")", sep="")
      stargazer(model, summary=FALSE, type="text", out=file.path(outputfolder, paste(dvs[i], ivs[j], sep = "_") %>% paste0("_arima.txt")), notes=model_name)

      # from threat paper: run granger causality test with removed the time dependencies from each individual series using the previous ARIMA procedure

      # run granger causality test on the residuals, loop through lags of 1 to 10 and select the best lag based on AIC
      # bestlag <- select_lags(dfage[,dvs[i]],dfage[,ivs[j]],10)$selection$aic

      # there are aliased (perfectly correlated or duplicate) coefficients between indi and negative
      try({
        granger_model <- grangertest(dfage[,ivs[j]]~dfage[,dvs[i]],order = diff)
        granger_list[[paste(ivs[j],dvs[i],sep = "->")]] <- round(granger_model$`Pr(>F)`[2],digits = 2)
      }, silent=TRUE)
      # bestlag_r <- select_lags(dfage[,ivs[j]],dfage[,dvs[i]])
      # granger_model <- grangertest(dfage[,dvs[i]],dfage[,ivs[j]],order = bestlag)
      # granger_list[[paste(ivs[j],dvs[i],sep = "<-")]] <- round(granger_model$`Pr(>F)`[2],digits = 2)
      # granger_lags[[paste(ivs[j],dvs[i],sep = "->")]] <- grangertest(residuals(model),dfage[,ivs[j]],maxlag = 10)$"Pr(>F)"[1:10]

  
  }
}

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