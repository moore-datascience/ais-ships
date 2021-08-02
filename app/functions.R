



#' Print functions
#' ---------------

#' Stands for print-paste0
#' 
#' The idea for this very simple function is to take 
#' all values given and print them out
#'
#' @param ... Set of string values
#' @return the combined values, but print to console.
#' @examples
#' pripas('This is ',x,' some text we are combining')
#' 
pripas <- function(...){
  
  print(paste0(...))
  
}


#' Stands for print-paste0 for observe events
#' 
#' This function is meant to be an easy way to register a console
#' log for observeEvent functions
#'
#' @param name Name of the input
#' @return the input name, but wrapped in simple helper text, then
#'         logged to console using pripas function.
#' @examples
#' pripas_oe('x_value')
#' 
pripas_oe <- function(name){
  
  pripas('observeEvent(input$',name,',{ ... triggered')
  
}






#' Map functions
#' ---------------

arcgis_tile_url <- function(x){
  
  tile0 <- paste0('https://server.arcgisonline.com/ArcGIS/rest/services/',
                  x,'/MapServer/tile/{z}/{y}/{x}')
  
  return(tile0)
  
}



#' Generate base leaflet map with other options
#' 
#' The purpose of this function is simply for code legibility when
#' using function babel_to_js() below.
#' 
#' @importFrom leaflet leaflet addTiles addProviderTiles addLayersControl
#' @importFrom leaflet.extras addControlGPS addEasyButton addMiniMap addFullscreenControl
#'
#' @param map_id id for output
#' @param base_la,base_lo,base_z Starting location and zoom for map
#' @param zoom_ctl0 boolean of whether to show zoom controls
#' @param min_zoom0 if !NULL restrict min zoom for entire map
#' @param add_full boolean of whether to allow full-screen contorl
#' @param add_gps boolean of whether to add gps tooltip
#' @param add_minimap if !NULL add minimap with param defining position
#' 
#' @return Leaflet map output
#' @examples
#' build_base_map('mainmap',base_la=55,base_lo=24,base_z=8,add_minimap=T)
#' 
build_base_map <- function(map_id,base_la=NULL,base_lo=NULL,base_z=NULL,
                           zoom_ctl0=F,min_zoom0=NULL,add_full=F,
                           add_gps=F,add_minimap=NULL){
  
  tile_url1 <- arcgis_tile_url('World_Imagery')
  tile_url2 <- arcgis_tile_url('World_Topo_Map')

  leaf <- leaflet(map_id,
                  options = leafletOptions(
                    zoomControl = zoom_ctl0,
                    minZoom = min_zoom0
                  )) %>%
    
    addTiles(
      urlTemplate = tile_url1,
      group = "Sat"#,
      # options =tileOptions(minZoom=8)
    ) %>%
    
    addProviderTiles(
      "OpenStreetMap.DE",
      options =providerTileOptions(#opacity = 0.8,
        noWrap = TRUE,reuseTiles = TRUE),
      group = "Roads") %>%
    
    addTiles(
      urlTemplate = tile_url2,
      group = "Topo"#,
      # options =tileOptions(minZoom=10)
    ) %>%
    
    addLayersControl(
      baseGroups = c("Sat","Topo","Roads"),
      position = "topright")
  
  if(add_full){
    
    leaf <- leaf %>% addFullscreenControl()
    
  }
  
  if(add_gps){
    
    leaf <- leaf %>%
      addControlGPS(
        options = gpsOptions(
          position = "topleft",
          activate = TRUE,
          autoCenter = TRUE,
          # maxZoom = 60,
          maxZoom = NULL,
          setView = TRUE)
      ) %>%
      addEasyButton(easyButton(
        icon="fa-crosshairs", title="Locate Me",
        onClick=JS("function(btn, map){ map.locate({setView: true}); }")))
    
  }
  
  if(!is.null(base_la)){
    
    leaf <- leaf %>%
      setView(
        lng = base_lo,
        lat = base_la,
        zoom = base_z)
    
  }
  
  if(!is.null(add_minimap)){
    
    leaf <- leaf %>%
      addMiniMap(
        position = add_minimap,
        toggleDisplay = TRUE,
        minimized = T
      )
    
  }
  
  
  return(leaf)
  
}





#' Process text functions
#' ---------------


#' Remove empty lines from a string
#' 
#' The purpose of this function is simply for code legibility when
#' using function babel_to_js() below.
#'
#' @param str A concatenated string of arbirary length 
#' @return The same string but with all lines of nchar==0 removed
#' @examples
#' rem_empty_lines(c('This','','is','a','','test'))
#' 
rem_empty_lines <- function(str){
  w0 <- which(nchar(str)==0)
  if(length(w0)>0){str <- str[-w0]}
  return(str)
}



#' Remove commented lines from Javascript code
#' 
#' This function is important to function babel_to_js(), where the basic
#' goal is to remove all lines that start with '//', which are commented
#' out in the target javascript code. The purpose of this is both to prevent
#' errors during Babel -> JS transformation, as well as obfuscate any 
#' comments made for my purposes from being visible in a users browser. 
#'
#' @param str Concatenated string of JS code
#' @return The same string but with all lines that start with '//' removed
#' @examples
#' pripas_oe('x_value')
#' 
rem_comments <- function(str){
  
  str1 <- str %>% trimws(.) %>% substr(.,1,2)
  
  w0 <- which(str1=='//')
  
  if(length(w0)>0){str <- str[-w0]}
  return(str)
  
}



#' Replace embedded {P{value}P} values with token list values
#' 
#' The purpose of this function is to process markup .scss files into
#' pure css usable in the shiny app. It includes 
#'
#' @param raw_react Concatenated string of JS or Scss code
#' @param wr String on numeric values for line numbers with tag matches
#' @param tag Desired tag value to be replaced
#' @param tk List of key/pair 'token' values that will be replaced#' 
#' 
#' @return raw string value with all tag occurrences replaced with their
#'         appropriate key/values replaced
#' @examples
#' raw_react <- c(
#' "<script type='text/javascript'>",
#' "  const value = {P{value}P}",
#' "</script>"
#' )
#' 
#' wr <- 2
#' tag <- 'P'
#' tk <- list('value'='This is a test')
#' 
#' raw2 <- rep_code_params(raw_react,wr,tag,tk)
#' 
rep_code_params <- function(raw_react,wr,tag,tk=list()){
  
  tag0 <- tag %>% gsub('{','',.,fixed = T)
  
  raw_react22 <- raw_react
  # raw_react22 <- raw_scss
  
  swap_lines <- raw_react22[wr]
  
  for(k in 1:length(swap_lines)){
    
    # w_gs0 <- which(grepl(swap_lines[k],raw_react22,fixed = T))
    ###
    #' 1.14.21 Changed above bc of poss of possible
    #' multiple identical lines
    w_gs0 <- wr[k]
    ###
    
    line_now <- raw_react22[w_gs0]
    
    if(substr(trimws(line_now),1,2)=='//'){next()}
    
    vars <- unlist(gregexpr(pattern=tag,line_now,fixed = T))
    
    for(l in 1:length(vars)){
      
      occ1 <- unlist(gregexpr(pattern=tag,line_now,fixed = T))[1]
      
      s0 <- substr(line_now,occ1+2,nchar(line_now))
      v0 <- split_between(s0,'\\{',paste0('\\}',tag0,'\\}'))
      
      line_tag <- paste0("{",tag0,"{",v0,"}",tag0,"}")
      
      if(!(v0 %in% names(tk))){
        
        line_now <- gsub(line_tag,get(v0),line_now,fixed = T)
        
      } else {
        
        val0 <- tk[[as.character(v0)]]
        line_now <- gsub(line_tag,val0,line_now,fixed = T)
        
      }
      
    }
    
    raw_react22[w_gs0] <- line_now
    
  }
  
  rr0 <- raw_react22
  
  return(rr0)
  
}




#' Process Scss style sheet
#' 
#' The purpose of this function is to process markup .scss files into
#' pure css usable in the shiny app. It includes ability to {import} text
#' from a desired file location and have that replace inline, as well as 
#' the ability to replace tagged values corresponding to tk list values
#' as described in 'rep_code_params' above.
#' 
#' @importFrom sass sass
#' @import rep_code_params()
#' @import rem_comments()
#'
#' @param scss_loc File location for target .scss file
#' @param tk list value containing key/value pairs to be replaced
#' 
#' @return Pure css code that has had empty lines removed, all occurences
#'         of {P{value}P} tags replaced, and finally converted to machine
#'         readable css code.
#'         
#' @examples
#' scss_loc <- 'test.scss'
#' # which could look like
#' '
#'  div {
#'    a {
#'    max-heigh: {P{max-heigh}P}
#'   }
#'  }
#' '
#' 
#' tk <- list('max-height'=''900px')
#' 
#' out0 <- process_scss(scss_loc,tk)
#' 
#' #would return#' 
#' 'div a {max-height: 900px}'
#' 
#' 
process_scss <- function(scss_loc,tk=list()){
  
  raw_scss <- readLines(scss_loc) %>% rem_comments(.)
  
  tagGP <- '{P{'
  wGP <- which(grepl(tagGP,raw_scss,fixed = T))
  if(length(wGP)>0){
    
    raw_scss <- rep_code_params(raw_scss,wr=wGP,tag=tagGP,tk)
    
  }
  
  tag_s <- '@import {'
  w_i <- which(grepl(tag_s,raw_scss,fixed = T))
  if(length(w_i)>0){
    
    # imp_build0 <- ''
    # imp_df0 <- data.frame(line=w_i,cont='')
    
    for(k in 1:length(w_i)){
      
      w_k <- which(grepl(tag_s,raw_scss,fixed = T))[1]
      
      line0 <- raw_scss[w_k] %>%
        str_split_fixed(.,' ',2) %>%
        unlist() %>% .[,2] %>%
        substr(.,3,(nchar(.)-2)) %>%
        strsplit(.,' ') %>% unlist()
      
      dec_f <- substr(line0,1,1) == '/'
      
      if(dec_f){
        
        root_f0 <- scss_loc %>%
          strsplit(.,'/',fixed = T) %>%
          unlist() %>% .[1:(length(.)-1)] %>%
          paste(.,collapse = '/')
        
        f_loc0 <- paste0(root_f0,line0)
        
      }
      
      if(!dec_f){
        
        f_loc0 <- paste0(root_app,line0)
        
      }
      
      
      if(file.exists(f_loc0)){
        
        imp0 <- readLines(f_loc0) %>% rem_empty_lines()
        
        scss0 <- raw_scss %>% .[1:(w_k-1)]
        scss1 <- raw_scss %>% .[(w_k+1):length(.)]
        
        raw_scss <- c(scss0,imp0,scss1)
        
      } else {
        
        raw_scss <- raw_scss[-w_k]
        
      }
      
      
    }
    
  }
  
  
  tagGP <- '{P{'
  wGP <- which(grepl(tagGP,raw_scss,fixed = T))
  if(length(wGP)>0){
    
    raw_scss <- rep_code_params(raw_scss,wr=wGP,tag=tagGP,tk)
    
  }
  
  # 7.3.21 Second import for subnested imports
  ###
  tag_s <- '@import {'
  w_i <- which(grepl(tag_s,raw_scss,fixed = T))
  if(length(w_i)>0){
    
    # imp_build0 <- ''
    # imp_df0 <- data.frame(line=w_i,cont='')
    
    for(k in 1:length(w_i)){
      
      w_k <- which(grepl(tag_s,raw_scss,fixed = T))[1]
      
      line0 <- raw_scss[w_k] %>%
        str_split_fixed(.,' ',2) %>%
        unlist() %>% .[,2] %>%
        substr(.,3,(nchar(.)-2)) %>%
        strsplit(.,' ') %>% unlist()
      
      dec_f <- substr(line0,1,1) == '/'
      
      if(dec_f){
        
        root_f0 <- scss_loc %>%
          strsplit(.,'/',fixed = T) %>%
          unlist() %>% .[1:(length(.)-1)] %>%
          paste(.,collapse = '/')
        
        f_loc0 <- paste0(root_f0,line0)
        
      }
      
      if(!dec_f){
        
        f_loc0 <- paste0(root0,line0)
        
      }
      
      
      if(file.exists(f_loc0)){
        
        imp0 <- readLines(f_loc0) %>% rem_empty_lines()
        
        scss0 <- raw_scss %>% .[1:(w_k-1)]
        scss1 <- raw_scss %>% .[(w_k+1):length(.)]
        
        raw_scss <- c(scss0,imp0,scss1)
        
      } else {
        
        raw_scss <- raw_scss[-w_k]
        
      }
      
      
    }
    
  }
  ###
  
  conv_css <- sass::sass(raw_scss)
  
  return(conv_css)
  
}



#' Process Babel Javascript
#' 
#' The purpose of this function is to transform raw Babel Javascript
#' and return {reactR} processed React Javascript code capable of being
#' run in browser without the use of babel.js
#' 
#' @importFrom reactR babel_transform
#'
#' @param react_raw Concatenated string of html that contains occurrences
#'                  of '<script type="text/babel">'
#' 
#' @return Processed javascript code of the same length, but with all sections 
#'         with babel code converted into machine readable JS code. 
#'         
#' @examples
#' 
#' 
#' 
#' 
babel_to_js <- function(react_raw){
  
  h1 <- react_raw #%>% paste(.,collapse = '\n')
  
  tag0 <- '<script type="text/babel">'
  w_babel0 <- which(grepl(tag0,h1))
  
  tag1 <- '<script defer type="text/babel">'
  w_babel1 <- which(grepl(tag1,h1))
  
  w_babel <- c(w_babel0,w_babel1)
  
  if(length(w_babel)==0){return(NULL)}
    
    
  b_lines <- h1[w_babel]
  
  for(b in 1:length(b_lines)){
    
    ###
    tag0 <- '<script type="text/babel">'
    tag1 <- '<script defer type="text/babel">'
    tag_rep <- '<script type="text/javascript">'
    ###
    
    
    line0 <- b_lines[b]
    
    wv <- unlist(gregexpr(pattern=tag0,line0,fixed = T))
    
    ###
    if(wv==-1){
      wv <- unlist(gregexpr(pattern=tag1,line0,fixed = T))
    }
    ###
    
    goB <- T
    
    for(v in 1:length(wv)){
      
      wv2 <- unlist(gregexpr(pattern=tag0,line0,fixed = T))[1]
      
      if(wv2==-1){
        
        tag0 <- tag1
        tag_rep <- '<script defer type="text/javascript">'
        wv2 <- unlist(gregexpr(pattern=tag1,line0,fixed = T))[1]
        
        if(wv2==-1){
          
        next()
          
        }
        
      }
      
      b0 <- wv2
      
      sub0 <- substr(line0,b0+nchar(tag0),nchar(line0))
      
      w_end <- unlist(gregexpr('</script>',sub0,fixed = T))[1]
      
      if(w_end<10){
        
        line0 <- line0 %>%
          gsub(paste0(tag0,'</script>'),'',.,fixed = T)
        
        next()
        
      }
      
      chunk <- substr(sub0,1,w_end-1)
      
      if(substr(chunk,1,3)=='-->'){chunk <- substr(chunk,4,nchar(chunk))}
      
      new_chunk <- reactR::babel_transform(chunk) %>%
        strsplit(.,'\n           ',fixed = T) %>%
        unlist() %>% trimws() %>% paste(.,collapse = ' ')
      
      pre_c <- substr(line0,1,b0-1)
      post_c <- substr(line0,b0+nchar(tag0)+w_end+8,nchar(line0))
      
      line0 <- paste0(pre_c,tag_rep,new_chunk,'</script>',post_c)
      
    }
    
    h1[w_babel[b]] <- line0
    
  }
  
  tag1 <- paste0('<script crossorigin src="https://unpkg.com/babel-',
                 'standalone@6.26.0/babel.min.js"></script>')
  
  h1 <- h1 %>% gsub(tag1,'',.,fixed = T)
  
  react0 <- h1
  
  return(react0)
  
}









#' Semantic Animated Button
#' 
#' The purpose of this function is to provide an easy way to generate
#' an animated semantic based button
#' 
#' @import shiny.semantic
#'
#' @param input_id Shiny input id
#' @param cont_vis What should be displayed when not hovered on
#' @param cont_hide What should be shown when hovered or clicked
#' @param type The type of animated button ex. 'vertical'
#' @param style Extra styling for button ex. 'fade basic black'
#' @param active Whether the button should render with hidden content displayed
#' @param onclick_text Javascript text if desired
#' @param margin_right Account for natural mis-aligned margin
#' 
#' @return HTML chunk with proper button styling
#'         
#' @examples
#' sem_animBtn(
#'   'close_app',
#'   icon('arrow alternate circle left'),
#'   icon('red arrow alternate circle left outline'),
#'   vertical',
#'   fade basic black'
#' )
#' 
sem_animBtn <- function(input_id,cont_vis,cont_hide,type=NULL,style=NULL,
                        active=NULL,onclick_text=NULL,margin_right=.6){
  
  c_vis <- span(HTML(as.character(cont_vis)))
  c_hide <- span(HTML(as.character(cont_hide)))
  
  tag0 <- div(
    id = input_id,
    class=paste0("ui ",type," animated ",style," icon button "),
    onclick = onclick_text,
    tabindex="0",
    
    div(
      class=paste0("visible content"),
      style=paste0('margin-top: 0; margin-right: ',margin_right,'em;'),
      c_vis
    ),
    
    div(
      class=paste0("hidden content"),
      c_hide
    )
    
  )
  
  return(tag0)
  
}






























