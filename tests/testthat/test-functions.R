#'
#' file: test-functions.R
#' loc: /efs/Shiny/ais-ships/tests/testthat/
#' date: 7.30.21
#' 
#' Here we are testing the functions.R file, where the three functions
#' that are reasonably complicated are rep_code_params(), rep_code_params(),
#' and babel_to_js()
#'
#--------------------------/


root_tests <- "tests/testthat/test-functions/"

source('app/functions.R')



test_that("build_base_map creates expected HTML", {
  
  loc_leaf <- glue('{root_tests}leaf.txt')
  
  # Create baseline
  a <- as.character(build_base_map("x")) %>% paste(.,collapse = '\n')
  # writeLines(a,loc_leaf)
  
  leaf0 <- readLines(loc_leaf)
  
  leaf1 <- as.character(build_base_map("x")) %>% 
    paste(.,collapse = '\n') %>% 
    strsplit(.,'\n') %>% unlist()
  
  expect_equal(leaf1,leaf0)
  
})



test_that('Replacing params works correctly',{
 
  loc_react <- glue('{root_tests}ships_react_param.html')
  loc_react2 <- glue('{root_tests}ships_react_param2.html')
  
  tk <- list(
    init_type = 'Cargo'
  )
  
  js0 <- readLines(loc_react)

  tag <- '{P{'  
  wr <- which(grepl(tag,js0,fixed = T))
  
  js1 <- rep_code_params(js0,wr,tag,tk)
  
  # Create base file to compare against later
  # writeLines(js1,loc_react2)
  
  js2 <- readLines(loc_react2)

  expect_equal(js1,js2)  
  
  
  # Now test that an empty tk will produce an error
  tk <- list()
  
  expect_error(rep_code_params(js0,wr,tag,tk))
  
  
          
})



test_that('Converting scss to css works correctly',{
  
  loc_scss <- glue('{root_tests}ships.scss')
  loc_css <- glue('{root_tests}ships.css')
  
  css0 <- process_scss(loc_scss) %>% as.character()
  
  # Create base file to compare against later
  # writeLines(css0,glue('{root_tests}ships.css'))
  
  css1 <- readLines(loc_css) %>% 
            paste(.,collapse = '\n')
  
  expect_equal(css0,css1)
  
})



test_that('Babelizing JS works as expected',{
  
  loc_react <- glue('{root_tests}ships_react.html')
  loc_react2 <- glue('{root_tests}ships_react2.html')
  
  js0 <- readLines(loc_react)
  
  react0 <- babel_to_js(js0)
  
  # Create base file to compare against later
  # writeLines(react0,loc_react2)
  
  react1 <- readLines(loc_react2)
  
  expect_equal(react0,react1)
  
})










































