#'
#' file: initTests.R
#' loc: /efs/Shiny/ais-ships/tests/
#' date: 7.30.21
#' 
#' The purpose of this file is to run some basic tests on the ais-ship
#' demo application, which at its core is very simple but rigorous test
#' should be done regardless. This will have 4 stages,
#' 
#' @1: First we test all non-reactive functions that are used in the
#'     app. These will mostly be found in the functions.R file in the
#'     root directory
#'
#' @2: Next we will test the flow of reactivity in the app using the 
#'     recordTest() function to make a basic test to check against in
#'     the future
#'     
#' @3: Then, because alot of this app is built around React, we will
#'     need a few more tests that allow for us to perform direct JS
#'     interactions using a Phantom Web Browser.
#'     
#' @4: Lastly we will test the app visuals, which means we will want 
#'     to be taking alot of screenshots and manually comparing whether
#'     a change has occured.
#' 
#' 
#'
#--------------------------/

library(usethis)
library(shinytest)
library(testthat)

context("Test Shiny app")

root_app <- "/efs/Shiny/ais-ships/"






# Test main server (Working) ----
#--------------------------/

test_that("reactives and output updates", {
  testServer(server, {
    
    session$setInputs(search_button=runif(1,1,10))
    
    session$setInputs(`type-vessel_type` = "Unspecified")
    session$setInputs(`vessel-vessel_selected` = "Vts Gaoteborg")
    session$setInputs(`vessel-vessel_selected` = "Tamina Spirit")
    session$setInputs(`vessel-vessel_selected` = "Sound Castor")
    session$setInputs(search_button = "click")
    
    
  })
})

#--------------------------/
# ----


# Test modules (Not Working) ----
#--------------------------/

rv <- reactiveValues()


summaryServer <- function(id, rv) {
  # stopifnot(is.reactive(rv))
 
  mod_sel_vessel_server(id,rv)
  
}

testServer(summaryServer, args = list(rv = rv), {
  
  session$setInputs(vessel_selected='Konya')
  
  print(rv)
  
  
})


#--------------------------/
# ----



# Record a basic test, then run ----
#--------------------------/

#' Lets start by recording a basic test, having it saved to 
#' tests/shinytest.
recordTest(root_app)

shinytest::testApp(root_app)


#--------------------------/
# ----




# open Shiny app and PhantomJS
app <- ShinyDriver$new("/efs/Shiny/ais-ships/")

Sys.sleep(2)

app$setInputs(`type-vessel_type` = "Tanker")

vals <- app$getAllValues()

str(vals)



test_that("output is correct", {
  
  # # set num_input to 30
  # app$setInputs(`type-vessel_type` = 'Tanker')
  # # get text_out
  # output <- app$getValue(name = "vessel-vessel_selected")
  # # test
  # expect_equal(output, "Pallas Glory")
  
  app$setInputs(`vessel-vessel_selected` = "Pola Murom")
  
  popup <- app$findElement(css = "h3")
  
  popup$getText()

  app$takeScreenshot()
  
  # test notification text
  testthat::expect_equal(popup$getText(), "Tanker")
  
})

# stop the Shiny app
app$stop()







library(shiny)
library(profvis)

profvis({
  runApp()
})













