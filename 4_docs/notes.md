# dictionary source

# ARIMA model
STEPS
1. Convert the variables into time series;

2. Plot histograms of the time series variables to ensure normality, if not, transform the variables;

3. Determine p (AR; auto-regressive component, partial autocorrelation between the series and its lagged values), d (I; Integrated, differencing component, the non-stationarity of the time series data), q (MA; moving average component, the linear relationship between the current value of the time series and the error term). There are two ways to achieve this: automatic way and manual way.
  - 3.1 auto.arima
  - 3.2 manual way
  - 3.2.1 p: pacf(tsvar) [look for significant spikes]
  - 3.2.2 d: tsvar_diff <- diff(tsvar, differences = [1,2,3,...]); then plot.ts(vsvar_diff) [visual inspection: look for a graph where the data points and the variance stay roughly constant over time, like jumps up and down but the high and low points are kept constant over long term];
      we need to determine if the data after differencing is trend stationary, we could:
    -  3.2.2.1  adf.test(tsvar), if p-value < .05 --> stationary 
    -  3.2.2.1  kpss.test(tsvar), if p-value > .05 --> stationary
    - 3.2.3 q: acf(var) [look for significant spikes]
    
4. conduct models with trial-and-error: there are will be several combination of order (p, d, q), determine the final model based on lowest value from AIC(model).

source: https://a-little-book-of-r-for-time-series.readthedocs.io/en/latest/src/timeseries.html
soruce#2: https://fish-forecast.github.io/Fish-Forecast-Bookdown/3-4-fitting-arima-models.html