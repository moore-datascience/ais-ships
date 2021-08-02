#'
#' file: mod_sel_type.R
#' loc: /efs/ECS/Shiny/ais-ships/app/modules
#' date: 7.30.21
#' 
#' The main purpose of this module is simply to render a select input
#' for the desired ship type, which when triggered @1 sends a message via 
#' rv[['vessel']] to the mod_sel_vessel() module that either triggers
#' the initial population of the 'vessel_selected' input, or updates 
#' with new values based on user selection. 
#' 
#' Note: We also need to set rv$search_value <- NULL so that we will 
#' reset the blocking mechanism that stops us from re-sending duplicate
#' information to ReactPortal in the main servers input$search_input
#' observeEvent.
#'
#--------------------------/


mod_sel_type_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    shiny.semantic::selectInput(
      ns('vessel_type'),
      label=NULL,
      choices = c('Cargo','Tanker','Unspecified','Tug','Fishing',
                  'Passenger','Pleasure','Navigation','High Special')
      
    )
    
  )
  
}


mod_sel_type_server <- function(input, output, session, id, rv){

  rv[['type']] <- reactiveValues()
  
  #' @1
  observeEvent(input$vessel_type, ignoreInit = F,{
    
    pripas_oe('vessel_type')
    
    type0 <- input$vessel_type
    
    pripas('type: ',type0)
    
    rv[['vessel']]$sel_type <- type0
    
    rv$search_value <- NULL
    
  })

}
































