#'
#' file: ui.R
#' loc: /efs/Shiny/ais-ships/app/
#' date: 7.30.21
#' 
#'
#--------------------------/



#' JS libraries to be sourced in UI
#--------------------------/

ma_pref <- 'https://mooreapps.com/'
react_loc0 <- 'js/react.min.js.gz' %>% paste0(ma_pref,.)
react_loc1 <- 'js/react-dom.min.js.gz' %>% paste0(ma_pref,.)




css0 <- '
  body {
    overflow-y: hidden;
  }
  
  .ships_loading {
    position: absolute;
    inset: 0;
    background-color: #15354a;
    z-index: 10000;
  }               
  
  #init_spinner {
    width: 100vw;
    height: 100vh;
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: center;
  }      
  
  i.red.icon {
    color: #a6d5e0 !important;
  }
'


#------------------------------------------


ui <- semanticPage(
  theme = 'paper',
  margin = "0px",
  suppress_bootstrap = TRUE,
  
  ## React libraries
  tags$script(src=react_loc0),
  tags$script(src=react_loc1),
 
  mod_react_ui('react'),
  
  tags$style(css0),
  
  disconnectMessage(
    text = paste0("Your AIS-ships session has ended, please reload"),
    refresh = "Reload Now",
    background = "#323232",
    colour = "white",
    overlayColour = "grey",
    overlayOpacity = 0.3,
    refreshColour = "white",
    size = 28,
    width = "full",
    top = "center"
  ),
  
  
  div(
    id = 'main_div',
    class='ships',
    
    div(
      id='loading_div',
      class='ships_loading',
      
      div(
        id='init_spinner',
        
        div(icon("massive red sun loading"))
        
      )
      
    ),
    
    div(
      class='ships_title',

      h3('AIS Shipping Data'),
      
      span('Built by Ian E Moore')
      
    ),
    
    div(
      class='ships_stats',
      
      cards(
        class = "two",
        card(
          div(class="content",
            
            div(class="header", "Vessel Type"),
            
            div(
              class="description",
              
              mod_sel_type_ui('type')
              
            )
              
          )
          
        ),
        card(
          div(class="content",
              
            div(class="header", 
                
              span("Vessel Name")
                
            ),
            
            div(
              class="description",
             
              mod_sel_vessel_ui('vessel')
              
            )
            
          )
          
        )
        
      )
      
    ),

    div(
      class='ships_map',
        
      mod_mainmap_ui('map'),

      sem_animBtn(
        'search_button',
        icon('search'),
        icon('search plus'),
        'vertical',
        'fade basic black')
    ),
    
    
    div(id='ships_map_react'),
    
    div(id='shiny-react-portal'),
    
    uiOutput("modalInfo"),
    
    uiOutput("modalSearch"),
    
    div(
      id = "info-button",
      icon('fa-info-circle')
    )
    
  )
  
)













































