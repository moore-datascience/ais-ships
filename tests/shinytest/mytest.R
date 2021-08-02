app <- ShinyDriver$new("../../")
app$snapshotInit("mytest")

Sys.sleep(3)

app$setInputs(`type-vessel_type` = "Unspecified")
app$setInputs(`vessel-vessel_selected` = "Vts Gaoteborg")
app$setInputs(`vessel-vessel_selected` = "Tamina Spirit")
app$setInputs(`vessel-vessel_selected` = "Sound Castor")
app$setInputs(search_button = "click")
app$setInputs(`vessel-vessel_selected` = "Pure Orange")
app$setInputs(`vessel-vessel_selected` = "Blackpearl 7.5v")
app$setInputs(`vessel-vessel_selected` = "Kapitan Belyaev")
app$setInputs(`type-vessel_type` = "Fishing")
app$setInputs(`vessel-vessel_selected` = "Christina Michelle")
app$setInputs(`vessel-vessel_selected` = "Stjarnvik")
app$setInputs(`type-vessel_type` = "Pleasure")
app$setInputs(`vessel-vessel_selected` = "Anna Maria")
app$setInputs(`vessel-vessel_selected` = "Kapitan Borchardt")
app$setInputs(`vessel-vessel_selected` = "Ankawer Iv")
app$setInputs(`vessel-vessel_selected` = "Furuno Sverige Ab")
app$setInputs(`type-vessel_type` = "High Special")
app$setInputs(`vessel-vessel_selected` = "Rivo")
app$snapshot()



