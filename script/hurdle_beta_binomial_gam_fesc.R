rm(list=ls(all=TRUE))
library(mgcv)
library(ggplot2)

# Read data
Data = read.csv("..//data/fesc.csv")
x         = c("Mstar","Mvir","ssfr_stars","baryon_fraction","spin","QHI","C") # with variable names 
var.names <- c("M['*']","M[200]", "sSFR", "f[b]", "lambda","Q[HI]","C")   

n         = nrow(Data) # Number of Observations
n0        = sum(Data$f_esc == 0) # Number of zeros
p         = length(var.names) # Number of covariates

###################################################################################################################################################
###################################################################################################################################################
###################################################################################################################################################


####
#### Modelling using Hurdle Bionmial_Beta_GAM 
#### Two stages
#### 1) Model Prob(f_esc>0) through Bionmial_GAM with logistic link 
## Binomial_GAM


Binomial_GAM  <- gam(non.zero.f_esc ~ s(Mstar,bs="cr",k=12) +  s(Mvir,bs="cr",k=12)  +  
                                      s(ssfr_stars,bs="cr",k=12) + s(baryon_fraction,bs="cr",k=25) +  
                                      s(spin,bs="cr")  +  s(QHI,bs="cr",k=25)  + s(C,bs="cr",k=20),                    
                                      data=Data,family= binomial(link="logit"),method="REML") 
                            
### non.zero.f_esc is a 0/1 variable indicating when f_esc > 0 
summary(Binomial_GAM) 
######################################################################################
##    
##
gg          <-list()
gg_x        <- list()
gg_original <-list()
for(i in 1:p){
  nn     = 3*10^4; 
  R      = matrix(apply(Data[,x],2,median),nrow=1); 
  R      =  R%x% rep(1,nn);colnames(R) = x; 
  R      = as.data.frame(R)
  a      = quantile(Data[,x[i]],0.001); b= quantile(Data[,x[i]],0.999); I = Data[,x[i]] > a & Data[,x[i]] < b
  R[,i]  = seq(a,b,length=nn)    
  #
  # Predict and Produce confidence intervals:
  #
  Preds_nzero <- predict(Binomial_GAM,newdata = R,type="link",se=T,unconditional=T) 
  fit.link    <- Preds_nzero$fit 
  se          <- Preds_nzero$se  
  CI.L        <- fit.link-2*se 
  CI.R        <- fit.link+2*se 
  CI          <- cbind(fit.link,CI.L,CI.R) 
  CI          <- exp(CI)/(1+exp(CI)) # The first column correponds to the estimated probability of being non-zero.
  colnames(CI) <- c("Predictions","CI_L","CI_R")
  ##
  gg_x[[i]] <- data.frame(cbind(CI,x=R[,i]),var = rep(var.names[i],nn))
  gg_original[[i]] <- data.frame(x=Data[I,x[i]],y=Data[I,"non.zero.f_esc"],var = rep(var.names[i],sum(I)))
}        

# put altogether for facets
ggg_x<-c()
for(i in 1:p){
  ggg_x <- rbind(ggg_x,gg_x[[i]])
}  
ggg_original <- c()
for(i in 1:p){
  ggg_original <- rbind(ggg_original,gg_original[[i]])
}  

#



# Plot  via ggplot2
pdf("Binomial_GAM.pdf",width = 16,height = 8)
ggplot(ggg_x,aes(x=x,y=Predictions,group=var,fill=var))+
  geom_rug(data=filter(ggg_original,y==0),aes(x=x,y=y),color="gray75",size=0.15,alpha=0.75,sides="b") +
  geom_rug(data=filter(ggg_original,y==1),aes(x=x,y=y),color="gray75",size=0.15,alpha=0.75,sides="t") +
  geom_ribbon(aes(ymin=CI_L, ymax=CI_R),alpha=0.75) +
  geom_line(aes(x=x,y=Predictions),col="black",size=0.5)+
  scale_fill_manual(values=c('#1b9e77','#d95f02','#7570b3','#66a61e','#e6ab02','#a6761d','#666666')) +
  ylab(expression(paste("Probability of ",~f[esc] > 0,sep="")))+
  xlab("")+
  theme_bw() +
  theme(legend.background = element_rect(fill="white"),
        legend.key = element_rect(fill = "white",color = "white"),
        plot.background = element_rect(fill = "white"),
        legend.position="none",
        axis.title.y = element_text(vjust = 0.1,margin=margin(0,10,0,0)),
        axis.title.x = element_text(vjust = -0.25),
        text = element_text(size = 20,family="serif")) +
  facet_wrap(~var,scales = "free_x",ncol=4,labeller = label_parsed,strip.position="bottom")
dev.off()
####
####

#
#######################################################################################
#######################################################################################
## The Second Stage
### 2) Model  f_esc when f_esc > 0 throug Beta_GAM with logistic link
###
r <- 35
Beta_GAM    <- gam(f_esc ~ s(Mstar,bs="cr",k=r) +  s(Mvir,bs="cr",k=r)  +  s(ssfr_stars,bs="cr",k=r) + 
                     s(baryon_fraction,bs="cr",k=r) +
                     s(spin,bs="cr",k=r)  +  s(QHI,bs="cr",k=r)   +  s(C,bs="cr",k=r),
                   subset=f_esc>0,data=Data,family=betar(link="logit"),method="REML")

summary(Beta_GAM)
###########################
## 
##
gg          <-list()
gg_x        <- list()
gg_original <-list()
for(i in 1:p){
  nn     = 3*10^4+1; 
  R      = matrix(apply(Data[,x],2,median),nrow=1); 
  R      =  R%x% rep(1,nn);colnames(R) = x; 
  R      = as.data.frame(R)
  a      = quantile(Data[,x[i]],0.001); b= quantile(Data[,x[i]],0.999); I = Data[,x[i]] > a & Data[,x[i]] < b
  R[,i]  = seq(a,b,length=nn)
  #
  # Predict and Produce confidence intervals:
  #
  Preds_fesc  <- predict(Beta_GAM,newdata = R,type="link",se=T,unconditional=T) 
  fit.link    <- Preds_fesc$fit 
  se          <- Preds_fesc$se 
  CI.L        <- fit.link-2*se 
  CI.R        <- fit.link+2*se 
  CI          <- cbind(fit.link,CI.L,CI.R) 
  CI          <- exp(CI)/(1+exp(CI)) # The first column correponds to the estimated average of f_esc when f_esc > 0
  colnames(CI) <- c("Predictions","CI_L","CI_R")
  ##
  gg_x[[i]] <- data.frame(cbind(CI,x=R[,i]),var = rep(var.names[i],nn))
  gg_original[[i]] <- data.frame(x=subset(Data,f_esc >0&I)[,x[i]],y=subset(Data,f_esc >0&I)[,"f_esc"],var = rep(var.names[i],sum(Data$f_esc>0&I)))
}        

# put altogether for facets
ggg_x<-c()
for(i in 1:p){
  ggg_x <- rbind(ggg_x,gg_x[[i]])
}  
ggg_original <- c()
for(i in 1:p){
  ggg_original <- rbind(ggg_original,gg_original[[i]])
}  

# Plot  via ggplot2
pdf("Beta_GAM.pdf",width = 16,height = 8)
ggplot(ggg_x,aes(x=x,y=Predictions,group=var,fill=var))+
  geom_hex(data=ggg_original,fill="gray75",size=0.15,alpha=0.5,bins = 75,
           aes(x=x,y=y,alpha = ..count..))+
  scale_alpha_continuous(trans = log10_trans())+
  geom_ribbon(aes(ymin=CI_L, ymax=CI_R)) +
  geom_line(col="black",size=0.5)+
  scale_fill_manual(values=c('#1b9e77','#d95f02','#7570b3','#66a61e','#e6ab02','#a6761d','#666666')) +
  ylab(expression(paste("Average of ",~f[esc]," given that ", ~f[esc] > 0 ,sep="")))+
  xlab("")+
  scale_x_continuous(breaks = scales::pretty_breaks(n = 4)) +
  theme(legend.background = element_rect(fill="white"),
        legend.key = element_rect(fill = "white",color = "white"),
        plot.background = element_rect(fill = "white"),
        legend.position="none",
        axis.title.y = element_text(vjust = 0.1,margin=margin(0,10,0,0)),
        axis.title.x = element_text(vjust = -0.25),
        text = element_text(size = 20,family="serif"))+
  facet_wrap(~var,scales = "free_x",ncol=4,labeller = label_parsed,strip.position="bottom")
dev.off()

#######################################################################################
#######################################################################################
### Hurdle model:Putting things together
###
### Fitted values:
####
#### Produce hurdle plots, using delta method
gg          <-list()
gg_x        <- list()
gg_original <-list()
for(i in 1:p){
  nn     = 3*10^4+1; 
  R      = matrix(apply(Data[,x],2,median),nrow=1); 
  R      = R%x% rep(1,nn);colnames(R) = x; 
  R      = as.data.frame(R)
  a      = quantile(Data[,x[i]],0.001); b= quantile(Data[,x[i]],0.999); I = Data[,x[i]] > a & Data[,x[i]] < b
  R[,i]  = seq(a,b,length=nn)
  #
  fit_Binomial = predict(Binomial_GAM,newdata=R,type="response",se=T,unconditional=T) 
  fit_Beta     = predict(Beta_GAM,newdata=R,type="response",se=T,unconditional=T)     
  mu_Binomial  = fit_Binomial$fit
  mu_Beta      = fit_Beta$fit
  se_Binomial  = fit_Binomial$se 
  se_Beta      = fit_Beta$se
  ##
  mu_Hurdle    = mu_Binomial*mu_Beta
  se_Hurdle    = sqrt(se_Binomial^2*mu_Beta^2  + mu_Binomial^2*se_Beta^2 + se_Binomial^2*se_Beta^2)
  ## 
  phi <- Beta_GAM$family$getTheta(TRUE)
  sd.y       <-  sqrt(mu_Binomial*(mu_Beta*(1-mu_Beta)/(1+phi) + (1-mu_Binomial)*mu_Beta^2))
  #
  CI.L        <- mu_Hurdle-2*se_Hurdle 
  CI.R        <- mu_Hurdle+2*se_Hurdle 
  CI          <- cbind(mu_Hurdle,CI.L,CI.R,sd.y) 
  colnames(CI) <- c("Predictions","CI_L","CI_R","SD")
  ##
  gg_x[[i]] <- data.frame(cbind(CI,x=R[,i]),var = rep(var.names[i],nn))
  gg_original[[i]] <- data.frame(x=Data[I,x[i]],y=Data[I,"f_esc"],var = rep(var.names[i],sum(I)))
}        

# put altogether for facets
ggg_x<-c()
for(i in 1:p){
  ggg_x <- rbind(ggg_x,gg_x[[i]])
}  
ggg_original <- c()
for(i in 1:p){
  ggg_original <- rbind(ggg_original,gg_original[[i]])
}  

# Plot  via ggplot2
pdf("Hurdle_GAM.pdf",width = 16,height = 8)
ggplot(ggg_x,aes(x=x,y=Predictions,group=var,fill=var))+
  geom_hex(data=ggg_original,fill="gray75",size=0.15,alpha=0.5,bins = 75,
           aes(x=x,y=y,alpha = ..count..))+
  geom_line(aes(x=x,y=SD),size=0.75,linetype="dashed")+
  geom_ribbon(aes(ymin=CI_L, ymax=CI_R)) +
  scale_fill_manual(values=c('#1b9e77','#d95f02','#7570b3','#66a61e','#e6ab02','#a6761d','#666666')) +
  geom_line(col="black",size=0.5)+
  ylab(expression(paste(~f[esc],sep="")))+
  xlab("")+
  theme(legend.background = element_rect(fill="white"),
        legend.key = element_rect(fill = "white",color = "white"),
        plot.background = element_rect(fill = "white"),
        legend.position="none",
        axis.title.y = element_text(vjust = 0.1,margin=margin(0,10,0,0)),
        axis.title.x = element_text(vjust = -0.25),
        text = element_text(size = 20,family="serif"))+
  facet_wrap(~var,scales = "free_x",ncol=4,labeller = label_parsed,strip.position="bottom")
dev.off()


