

### Welcome to AIS_Ships

This app is built using AIS or 'Automatic Identification System' data, which is used by all ships at sea. The goal of this project was to take this set of data with ~3.2 million rows for ~1200 ships, and identify for what two points each ship would have traveled the greatest distance. 

Then using this cleaned data the goals of the application was to give the user the ability to select from a dropdown input the type of vessel, and from there use this to populate a second dropdown input with the names of all ships of that type. Then this should update a leaflet map that shows the two points associated with this greatest distance traveled, and in a small note pane render what the total distance traveled for that time period was. 



#### Setup:
- Because shiny.semantic 4.0.4 is required, we will use the {renv} package to finely control the package versions that we are using. 

- The final product should be uploaded to Github and hosted on Shinyapps.io, so we will be using the {rsconnect} package to upload the application.




#### Goals
- The application should focus on using modules effectively, so I am showcasing my method for communicating between modules that uses a central 'rv <- reactiveValues()', but then inside each module we define a 'sub-nested' reactiveValues function s.t. 'rv[['map']] <- reactiveValues()' is specific to the map module, but assigning any rv[['map']]$value from anywhere else in the app triggers our desired endpoint. 

- This application will showcase my ability to use the {reactR} package in conjunction with 'react' and 'react-dom' javascript packages to seamlessly convert Babel formatted React code and use directly in the shiny app with a single module based uiOutput responsible for hosting all the React code we need to use throughout the app. This allows us to use React to offload as much of the UI rendering as possible, and greatly increase the efficiency of the app. 

- This app will also showcase my use of the {sass} package to style the entire app with .scss code, then convert to normal css and insert directly into the ui element. This allows for much greater efficiency in the styling of the app, and allows us to take advantage of the greater world of Sass offerings, like mixins, interpolation, and loops. 


#### Best Practices
- Properly commented functions file.
- Clean and easy to understand module design
- Version control with git
- renv package management
- Re-use of functions and modules from previous projects

































