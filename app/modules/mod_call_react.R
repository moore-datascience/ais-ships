#'
#' file: mod_call_react.R
#' loc: /efs/ECS/Shiny/ais-ships/app/modules
#' date: 7.30.21
#' 
#' The purpose of this file is to be a kind of 'hosting' area for React code. 
#' The reason that this is best served in a module format is to ensure that
#' the app UI is flush before the babel transformed React code attempts to
#' render. If there isn't this kind of delay, we will get an error saying 
#' that the DOM element for our target divs do no exist. 
#' 
#' This is also the point of adding our process scss -> css code, which takes
#' a second to register in the browser, which is why i have the loading screen
#' with the spinning sun. 
#'
#--------------------------/


mod_react_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    uiOutput(ns('app_ui'))
    
  )
  
}



mod_react_server <- function(input, output, session, id, rv){
  
  output$app_ui <- renderUI({
    
    pripas('output$app_ui <- renderUI({ triggered')
    
    react1 <- rv$react1
    css0 <- rv$scss
    
    tagList(
      
      tags$style(css0),
      
      HTML(react1)
      
    )
    
  })
  
}











