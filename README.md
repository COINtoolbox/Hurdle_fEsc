# <img align="right" src="https://github.com/COINtoolbox/ActSNClass/blob/master/images/COIN_logo_very_small.png" width="350"> Hurdle  models and the escape of ionizing radiation
[![arxiv](http://img.shields.io/badge/arXiv-1805.07435-lightgrey.svg?style=plastic)](https://arxiv.org/abs/1805.07435)

M. W. Hattab, [de Souza, R. S.](https://www.rafaelsdesouza.com),  B. Ciardi,  J.-P. Paardekooper, S. Khochfar, C. Dalla Vecchia 2018.


We kindly ask you to include the full citation if you use this material in your research: [Hattab, de Souza et al., 2018 -  arXiv:astro-ph/1805.07435](https://arxiv.org/abs/1805.07435).


## Install R and Rstudio from 

* [http://www.r-project.org](http://www.r-project.org)
* [http://www.rstudio.com](http://www.rstudio.com)

# R Dependencies
    - mgcv
    - ggplot2
    
## Simulated catalogue 

The dataset used in this work is retrieved from the First Billion Years [FiBY](http://adsabs.harvard.edu/abs/2013MNRAS.429L..94P) simulation suite, and is based on the catalogue built by  [Paardekooper et al. 2015](http://adsabs.harvard.edu/abs/2015MNRAS.451.2544P). The post-process data used on this work is available at [dataset](https://github.com/COINtoolbox/Hurdle_fEsc/tree/master/data). 


### Code snipppet

We provide a script to reproduce the Figures 7-9 from our paper [here](https://github.com/COINtoolbox/Hurdle_fEsc/blob/master/script/hurdle_beta_binomial_gam_fesc.R). The script reads the data, perform the statistical analysis and display the results. 