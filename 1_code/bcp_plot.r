setwd("/home/local/PSYCH-ADS/xuqian_chen/Github/agebias-chi")
datafolder <- "./2_pipeline/out"
outputfolder <- "./3_output/figures"

library("bcp")
library("ggplot2")
library("dplyr")
datapath <- file.path(datafolder,"merged.csv")
dfage <- read.csv(datapath)

dfage$positive <- dfage$old_positive - dfage$young_positive
dfage$negative <- dfage$old_negative - dfage$young_negative
dfage$competent <- dfage$old_competent - dfage$young_competent
dfage$warm <- dfage$old_warm - dfage$young_warm
dfage$incompetent <- dfage$old_incompetent - dfage$young_incompetent
dfage$cold <- dfage$old_unwarm - dfage$young_unwarm
dfage$virtue <- dfage$old_virtue - dfage$young_virtue
dfage$vice <- dfage$old_vice - dfage$young_vice

set.seed(101)
# ==============================
# LOAD DATA
# ==============================
# plot positive attitude
fit = bcp(dfage$positive)
year_prob = cbind(dfage$year, fit$posterior.prob,fit$posterior.mean)
colnames(year_prob) = c("Year", "Prob","Means")
positive_year_prob = as.data.frame(year_prob) %>% arrange(desc(Prob))

# plot negative attitude
fit = bcp(dfage$negative)
year_prob = cbind(dfage$year, fit$posterior.prob,fit$posterior.mean)
colnames(year_prob) = c("Year", "Prob","Means")
negative_year_prob = as.data.frame(year_prob) %>% arrange(desc(Prob))

# plot both positive and negative attitude
ggplot()+
  geom_line(data = positive_year_prob,aes(Year,Means,color = "Positive"))+
  geom_line(data = negative_year_prob,aes(Year,Means,color = "Negative"))+
  annotate("text",x = positive_year_prob[1:3,1],y = positive_year_prob[1:3,3],label = positive_year_prob[1:3,1],size = 3)+
  annotate("text",x = negative_year_prob[1:3,1],y = negative_year_prob[1:3,3],label = negative_year_prob[1:3,1],size = 3)+
  labs(title = "Positive and Negative Attitudes (Old - Young)",x = "Year",y = "Posterior Means",color = "Attitude",caption = "Annotations indicate the top 3 years with the highest posterior probability")
# save plot
ggsave(file.path(outputfolder,"bcp_attitudes.png"),width = 6,height = 4)

# ==============================
# Stereotype Content Model - Positive
# ==============================
# plot competent
fit = bcp(dfage$competent)
year_prob = cbind(dfage$year, fit$posterior.prob,fit$posterior.mean)
colnames(year_prob) = c("Year", "Prob","Means")
competent_year_prob = as.data.frame(year_prob) %>% arrange(desc(Prob))

# plot warm
fit = bcp(dfage$warm)
year_prob = cbind(dfage$year, fit$posterior.prob,fit$posterior.mean)
colnames(year_prob) = c("Year", "Prob","Means")
warm_year_prob = as.data.frame(year_prob) %>% arrange(desc(Prob))

# plot both competent and warm
ggplot()+
  geom_line(data = competent_year_prob,aes(Year,Means,color = "Competent"))+
  geom_line(data = warm_year_prob,aes(Year,Means,color = "Warm"))+
  annotate("text",x = competent_year_prob[1:3,1],y = competent_year_prob[1:3,3],label = competent_year_prob[1:3,1],size = 3)+
  annotate("text",x = warm_year_prob[1:3,1],y = warm_year_prob[1:3,3],label = warm_year_prob[1:3,1],size = 3)+
  labs(title = "Competent and Warm (Old - Young)",x = "Year",y = "Posterior Means",color = "Stereotype Content",caption = "Annotations indicate the top 3 years with the highest posterior probability")

# save plot
ggsave(file.path(outputfolder,"bcp_stereotype_positive.png"),width = 6,height = 4)

# ==============================
# Stereotype Content Model - Negative
# ==============================
# plot incompetent
fit = bcp(dfage$incompetent)
year_prob = cbind(dfage$year, fit$posterior.prob,fit$posterior.mean)
colnames(year_prob) = c("Year", "Prob","Means")
incompetent_year_prob = as.data.frame(year_prob) %>% arrange(desc(Prob))

# plot cold
fit = bcp(dfage$cold)
year_prob = cbind(dfage$year, fit$posterior.prob,fit$posterior.mean)
colnames(year_prob) = c("Year", "Prob","Means")
cold_year_prob = as.data.frame(year_prob) %>% arrange(desc(Prob))

# plot both incompetent and cold
ggplot()+
  geom_line(data = incompetent_year_prob,aes(Year,Means,color = "Incompetent"))+
  geom_line(data = cold_year_prob,aes(Year,Means,color = "Cold"))+
  annotate("text",x = incompetent_year_prob[1:3,1],y = incompetent_year_prob[1:3,3],label = incompetent_year_prob[1:3,1],size = 3)+
  annotate("text",x = cold_year_prob[1:3,1],y = cold_year_prob[1:3,3],label = cold_year_prob[1:3,1],size = 3)+
  labs(title = "Incompetent and Cold (Old - Young)",x = "Year",y = "Posterior Means",color = "Stereotype Content",caption = "Annotations indicate the top 3 years with the highest posterior probability")

# save plot
ggsave(file.path(outputfolder,"bcp_stereotype_negative.png"),width = 6,height = 4)

# ==============================
# Moral Foundation Theory - Virtue
# ==============================
# plot virtue
fit = bcp(dfage$virtue)
year_prob = cbind(dfage$year, fit$posterior.prob,fit$posterior.mean)
colnames(year_prob) = c("Year", "Prob","Means")
virtue_year_prob = as.data.frame(year_prob) %>% arrange(desc(Prob))

# plot vice
fit = bcp(dfage$vice)
year_prob = cbind(dfage$year, fit$posterior.prob,fit$posterior.mean)
colnames(year_prob) = c("Year", "Prob","Means")
vice_year_prob = as.data.frame(year_prob) %>% arrange(desc(Prob))

# plot both virtue and vice
ggplot()+
  geom_line(data = virtue_year_prob,aes(Year,Means,color = "Virtue"))+
  geom_line(data = vice_year_prob,aes(Year,Means,color = "Vice"))+
  annotate("text",x = virtue_year_prob[1:3,1],y = virtue_year_prob[1:3,3],label = virtue_year_prob[1:3,1],size = 3)+
  annotate("text",x = vice_year_prob[1:3,1],y = vice_year_prob[1:3,3],label = vice_year_prob[1:3,1],size = 3)+
  labs(title = "Virtue and Vice (Old - Young)",x = "Year",y = "Posterior Means",color = "Moral Foundations",caption = "Annotations indicate the top 3 years with the highest posterior probability")

# save plot
ggsave(file.path(outputfolder,"bcp_moral.png"),width = 6,height = 4)
