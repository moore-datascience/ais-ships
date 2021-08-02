


# git remote add origin https://github.com/moore-datascience/ais-ships.git

install.packages('shiny')
install.packages('remotes')
install.packages('dplyr')
install.packages('stringr')


renv:init()


require(remotes)

install_version(
  "shiny.semantic",
  version = "0.4.0",
  repos = "http://cran.us.r-project.org"
)



library(rsconnect)

root0 <- '/efs/'
root_ais <- paste0(root0,'Shiny/ais-ships/app')

rsconnect::setAccountInfo(name='ianmoore',
                          token='FB2EA1821D2670F941D970A8919C913B',
                          secret=Sys.getenv('SHINYAPP.IO_SECRET'))


df0 <- rsconnect::appDependencies()

renv::snapshot()

rsconnect::deployApp(
  account = 'ianmoore',
  root_ais,
  appName = 'AIS-Demo',
  appTitle = 'Ships-AIS'
)
























