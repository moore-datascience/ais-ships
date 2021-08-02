#'
#' file: mod_sel_vessel.R
#' loc: /efs/ECS/Shiny/ais-ships/app/modules
#' date: 7.30.21
#' 
#' @1:
#' Here we handle message that is triggered in the 'mod_sel_type()'
#' server logic every time a new vessel type is selected. We then
#' filter our rv$ships df for Vessels of desired type, then use this
#' to send first a message to update our select input. We then also
#' send a custom message to our React custom message handler of our 
#' selected type. This update will then trigger @2
#' 
#' @2:
#' Here we have recieved our updated selected vessel, either from
#' initial value update or from user selection. At this point we 
#' want to send our mod_mainmap() module an rv based message about 
#' our selection. 
#' 
#' @3:
#' This section of code is meant to be used to update our selected
#' vessels input value whenever the user makes a selection from the
#' React based search that is shown in a 'ReactPortal'. That JS process
#' sends a message to the 'observeEvent(input$search_clicked' handler,
#' which sends a message back into this module using rv[['vessel']], which
#' we then use to update our selected value, which triggers @2 and also
#' propegates change to mod_mainmap() 
#' 
#' 
#--------------------------/



mod_sel_vessel_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    shiny.semantic::selectInput(
      ns('vessel_selected'),
      label=NULL,
      choices = c('')
    )
    
  )
  
}



mod_sel_vessel_server <- function(input, output, session, id, rv){
  
  rv[['vessel']] <- reactiveValues()
  
  #' @1
  observeEvent(rv[['vessel']]$sel_type, ignoreNULL = T,{
    
    sel0 <- rv[['vessel']]$sel_type
    
    s0 <- rv$ships %>% filter(type==sel0) 

    updateSelectInput(
      session,
      'vessel_selected',
      label=NULL,
      choices = unique(s0$name) 
    )
    
    list0 <- list(
      type=sel0
    )
    
    session$sendCustomMessage("main_handler", list0)
    
  })
  
  #' @2
  observeEvent(input$vessel_selected,ignoreNULL = T,{
    
    vs0 <- input$vessel_selected
    
    rv[['map']]$select_name <- vs0
    
  })
  
  #' @3
  observeEvent(rv[['vessel']]$sel_vessel, ignoreNULL = T,{
    
    type0 <- rv[['vessel']]$sel_type
    sel0 <- rv[['vessel']]$sel_vessel[1]
    
    s0 <- rv$ships %>% filter(type==type0) 
    un0 <- unique(s0$name) 
    
    name0 <- s0 %>% filter(uid==sel0) %>% .$name %>% head(1)
    
    updateSelectInput(
      session,
      'vessel_selected',
      label=NULL,
      choices = un0,
      selected = name0
    )
    
  })
  
}



































