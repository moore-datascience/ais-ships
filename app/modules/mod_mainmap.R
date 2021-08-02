#'
#' file: mod_mainmap.R
#' loc: /efs/ECS/Shiny/ais-ships/app/modules
#' date: 7.30.21
#' 
#' The main purpose of this module is to render a leaflet map using
#' re-usable 'build_base_map()' function @1. The second part of this 
#' in section @2 is all about recieving the message in the chain of 
#' actions starting in 'mod_sel_type()' or 'mod_sel_vessel()' that
#' uses subnested reactiveValue 'rv[['map']]$select_name' to trigger
#' the process of the selected vessel to be added to the map. This then
#' uses the passed in rv$ships dataframe to find our target rows, then
#' use our leafletProxy value to remove previously rendered ships and
#' add new markers to the map. 
#' 
#' Once that is done, we use 'session$sendCustomMessage' to send a 
#' message to our 'main_handler' custom message handler in our react 
#' code to trigger the rendering of our preview information. 
#' 
#' Also note that in the @2 section, we do a small check to see if the 
#' current range of our leaflet map bounds is greater than the difference
#' of the two points we are about to render. Only if it is not do we alter
#' the zoom of our map with a fitBounds call. This is done to not disorient
#' the user with constant changes in the zoom of the map. If they are zoomed
#' out and want to see the big picture, we shouldn't force them into a closer
#' viewpoint unnecessarily.
#' 
#'
#--------------------------/



mod_mainmap_ui <- function(id){
  
  ns <- NS(id)
  
  tagList(
    
    leafletOutput(ns('mainmap'),height = '100vh')
    
  )
  
}



mod_map_server <- function(input, output, session, id, rv){
  
  
  rv[['map']] <- reactiveValues()
  
  
  #' @1
  output$mainmap <- renderLeaflet({
    
    pripas('output$mainmap <- renderLeaflet({ ... triggered')

    build_base_map("mainmap",base_la,base_lo,base_z,
                   add_gps=F,add_minimap='bottomleft')

  })
  
  proxy <- leafletProxy("mainmap")
  
  
  #' @2
  observeEvent(rv[['map']]$select_name,ignoreNULL = T,{ 
    
    name0 <- rv[['map']]$select_name
    
    req(nchar(name0)>0)
    
    type0 <- rv[['vessel']]$sel_type
    
    r0 <- rv$ships %>% filter(type==type0,name==name0)
    
    mid0 <- c(mean(r0$la),mean(r0$lo))
    
    z0 <- input$mainmap_zoom
    
    leaf <- proxy %>% 
      clearGroup('ships') %>% 
      addAwesomeMarkers(
        data = r0,
        lng = ~lo,
        lat = ~la,
        icon = awesomeIcons("ship", "fa"),
        group = 'ships'
      ) 
    
    mm0 <- input$mainmap_bounds
    
    diff_la <- abs(r0$la[1]-r0$la[2])
    diff_lo <- abs(r0$lo[1]-r0$lo[2])
    diff_la2 <- abs(mm0$south-mm0$north)
    diff_lo2 <- abs(mm0$west-mm0$east)

    dec_la <- diff_la<diff_la2
    dec_lo <- diff_lo<diff_lo2
    dec_fits <- dec_la && dec_lo
    
    if(dec_fits){
      
      leaf <- leaf %>% 
        setView(lat = mid0[1],
                lng = mid0[2],
                zoom = z0)
      
    }
    
    if(!dec_fits){
      
      leaf <- leaf %>% 
        fitBounds(
          lng1 = r0$lo[1],
          lat1 = r0$la[1],
          lng2 = r0$lo[2],
          lat2 = r0$la[2]
        )
    }
    
    dist0 <- r0$distance[2] %>% round(.,2)
    
    list0 <- list(
      distance=dist0,
      name = name0,
      records=r0,
      remove='loading_div'
    )
    
    session$sendCustomMessage("main_handler", list0)
    
    leaf
    
  })
  
}
  
  
  
  
  
  
  
  
  
  





































