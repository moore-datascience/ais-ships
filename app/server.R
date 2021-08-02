#'
#' file: server.R
#' loc: /efs/Shiny/ais-ships/app/
#' date: 7.30.21
#' 
#'
#--------------------------/



server <- function(input, output, session) {
  
  # Define initial RV ----
  # ---------------------------/
  
  rv <- reactiveValues()
  
  rv$ships <- ships
  
  
  #' Move to global.R in production to save time
  ### 
  # react_raw <- readLines('ships_react.html') %>%
  #   rem_comments(.) %>%
  #   rem_empty_lines(.) %>%
  #   paste(.,collapse = " ")
  # 
  # react1 <- babel_to_js(react_raw)
  # 
  # css0 <- process_scss('ships.scss')
  ###
  
  rv$react1 <- react1
  rv$scss <- css0
  
  # ---------------------------/
  # ----
  
  # Call Modules ----
  # ---------------------------/
  
  callModule(mod_map_server,id = 'map',rv=rv)
  
  callModule(mod_sel_type_server,id = 'type',rv=rv)
  
  callModule(mod_sel_vessel_server,id = 'vessel',rv=rv)
  
  callModule(mod_react_server,id = 'react',rv=rv)
  
  # ---------------------------/
  # ----
  
  # React <-> Shiny search functionality ----
  # ---------------------------/
  
  rv$search_value <- NULL
  
  observeEvent(input$search_button,{
    
    pripas_oe('search_button')
    
    list0 <- list(
      show='search'
    )
    
    session$sendCustomMessage("main_handler", list0)
    
  })
  
  observeEvent(input$search_input,{
    
    pripas_oe('search_input')
    
    in0 <- input$search_input

    name0 <- in0$text
    
    prev0 <- rv$search_value
    req(!identical(name0,prev0))
    rv$search_value <- name0
    
    type0 <- rv[['vessel']]$sel_type 
    
    ships <- rv$ships
    
    s0 <- ships %>% filter(type==type0)
    
    w0 <- which(grepl(name0,s0$name,ignore.case = TRUE))
    
    s1 <- s0[w0,] %>% 
      .[which(duplicated(.$uid)),] %>% 
      # select(uid,name,type,distance)
      select(uid,name,type,distance,date,speed,course,heading,
             port,length,width,date) %>% 
      mutate(distance=round(distance,1))
    
    glimpse(s1)
    
    list0 <- list(
      no_results='true'
    )
    
    if(dim(s1)[1]>0){
        
      l0 <- list()
      
      for(i in 1:dim(s1)[1]){
        
        s2 <- s1[i,]
        
        l0[[paste0('id-',s2$uid)]] <- s2
        
      }
      
      list0 <- list(
        results=l0
      )
      
    }
    
    session$sendCustomMessage("main_handler", list0)
    
  })
  
  observeEvent(input$search_clicked,{
    
    pripas_oe('search_clicked')
    
    in0 <- input$search_clicked
    
    code <- in0$code
    
    pripas('code: ',code)
    
    rv[['vessel']]$sel_vessel <- c(code,runif(1,1,10))
    
  })
  
  # ---------------------------/
  # ----
  
  # App Info Modal ----
  # ---------------------------/
  
  grid0 <- grid_template(
    default = list(
      areas = rbind(
        c("title", "title"),
        c("desc", "pkg"),
        c('extra','extra')
      ),
      cols_width = c("2fr","1fr"),
      rows_height = c("auto", "auto","auto")
    ),
    mobile = list(
      areas = rbind(
        "title",
        "desc",
        "extra",
        "pkg"
      ),
      rows_height = c("150px", "auto", "auto"),
      cols_width = c("100%")
    )
  )
  
  
  
  output$modalInfo <- renderUI({
    
    modal(
      id = "welcome-modal",
      # header = "About the App: AIS_Demo",
      h2(class = "ui header", icon("ship"), div(class = "content", "AIS Demo")),
      class = "medium",
      target = "info-button",
      
      tagList(
        
        grid(
          grid0,
          container_style = "grid-gap: 25px",
          area_styles = list(pkg = "padding-right: 20px"),
          
          title = div(
            class='about_title',
            
            h2('Welcome!'),
            
            p('The main goal of this application was to work with AIS data such that a user can select a ship type, have that populate a selectInput for the name of the vessels of that type, and finally have that propegated to the leaflet map where it displays two points that represent the largest amount of distance traveled by that ship for any given point in its recorded travel.')
            
          ),
          
          desc = div(
            class='about_desc',
            
            div(
              class = "ui raised segment", 
              style = "height: 100%",
              a(class="ui green ribbon label override", "Goals"), 
              
              p('Create a module based design with the most efficient possible means of communicating between them. To accomplish this I am using a method that I call "Sub-Nested Reactive Values".'),
              
              p('Incorporate React using {reactR} babel transformation via module uiOutput to offload as much Shiny UI rendering as possible. This is showcased in the bottom right hand corner info section, as well as the React Portal based search functionality'),
              
              p('Style the application using SCSS syntax with {sass} enabled preprocessing to machine readable css code using the {sass} package at the Global context level in production and at the server context level during development')
              
            )
            
          ),
          
          extra = div(
            class='about_extra',
            
            div(
              class = "ui raised segment", 
              style = "height: 100%",
              a(class="ui green ribbon label", "Features"), 
              
              p('Smooth map experience, with special attention payed to not interupting a users set zoom unless the two points were outside of their current viewport.'),
              
              p('Effiecient Reactive flow throughout the application. Fine control over when to process React and Scss code allows for live code updates to core frontend components.'),
              
              p('Advanced JS -> Shiny -> JS communication can be found in the main search functionality to populate React based outputs that can be clicked to register \'select vessel\' event back in Shiny. The search input is meant to pair efficient R data filtering capabilities with Reacts powerful virtual DOM capabilities.')
              
            ),
            
            div(
              class = "ui raised segment", 
              style = "height: 100%",
              a(class="ui green ribbon label", "Challenges"), 
              
              p('I had a difficult time implementing normal testing best practices in this app. I don\'t quite know for sure but my suspicion is that using React in this app has somehow interupted the way that {testthat} processes the shiny code.'),
              
              p('Rendering React components requires that the target rendering div exists in the DOM before the React app is called. This required using a dedicated shiny module and a uiOutput to create a slight delay between the main UI being rendered and the React javascript being processed.')
              
            )

          ),
          
          pkg = div(
            class='about_pkg',
            
            div(
              class = "ui raised segment", 
              style = "height: 100%",
              a(class="ui green ribbon label", "Packages used"), 
              
              div(
                class='about_pkg_cont',
                
                HTML(
                  paste0('<span>',
                         paste(pkgs_used,collapse = '</span><span>'),
                         '</span>')
                )
                
              )
              
            )
            
          )
          
        )
        
      )
      
    )
    
  })
  
  # ---------------------------/
  # ----
  
}
























