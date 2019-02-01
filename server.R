# IMPREX Scoreboard
# server
# by Guillaume Thirel (Irstea)
# adapted from a work by Jeffrey Norville (Irstea)
rm(list = ls())

readRenviron(".Renviron")
REhost =     Sys.getenv('pgserver')
REport =     Sys.getenv('pgport')
REdbname =   Sys.getenv('pgdb')
REuser =     Sys.getenv('api_user')
RElanguage = Sys.getenv('api_language')
REpassword = Sys.getenv('pgpassword')
my_database = Sys.getenv('pgschema')
upload_pwd = Sys.getenv('uploadpassword')

sb_version = Sys.getenv('sb_version') 

options(shiny.maxRequestSize=50*1024^2) # 50 mb 

imprex_shiny <<- new.env(parent = baseenv())

db <- src_postgres(
  dbname = REdbname,
  host = REhost,
  port = REport,
  user = REuser,
  password = REpassword
)

selectInsertUnique <- function(tblName, tblValue, db) {
  sSelect <- paste("SELECT id from ",my_database,".\"",tblName,"\" where name = \'",tblValue,"\'",sep='')
  rSelect <- dbSendQuery(db$con, sSelect)
  df <- dbFetch(rSelect)
  dbClearResult(rSelect)
  
  if (dim(df)[1]==0) {
    sInsert <- paste("INSERT INTO ",my_database,".\"",tblName,"\" (name) VALUES (\'",tblValue,"\') RETURNING id",sep='')
    rInsert <- dbSendStatement(db$con, sInsert)
    df <- dbFetch(rInsert)
    dbClearResult(rInsert)
  }
  
  return(df$id)
  
}


shinyServer(function(input, output, session) {
  
  if (!isPostgresqlIdCurrent(db$con)) {
    db <- src_postgres(
      dbname = REdbname,
      host = REhost,
      port = REport,
      user = REuser,
      password = REpassword
    )
  }
  
  sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblCaseStudy\"", sep = "")
  rSelect <- dbSendQuery(db$con, sSelect) 
  tblCaseStudy <- dbFetch(rSelect)
  dbClearResult(rSelect)
  
  sSelect <- paste("SELECT id, \"idForecastSystem\", \"idForecastType\", \"idModelVariable\", \"idScoreType\", \"idLeadTimeUnit\", \"idCaseStudy\", \"importDateTime\", \"provider\", \"verificationperiod\" FROM ",
                   my_database,".\"tblExperiment\"", sep = "")
  rSelect <- dbSendQuery(db$con, sSelect) 
  tblExperiment <- dbFetch(rSelect)
  dbClearResult(rSelect)
  
  sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblForecastSystem\"", sep = "")
  rSelect <- dbSendQuery(db$con, sSelect) 
  tblForecastSystem <- dbFetch(rSelect)
  dbClearResult(rSelect)
  
  sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblForecastType\"", sep = "")
  rSelect <- dbSendQuery(db$con, sSelect) 
  tblForecastType <- dbFetch(rSelect)
  dbClearResult(rSelect)
  
  sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblLeadTimeUnit\"", sep = "")
  rSelect <- dbSendQuery(db$con, sSelect) 
  tblLeadTimeUnit <- dbFetch(rSelect)
  dbClearResult(rSelect)
  
  sSelect <- paste("SELECT id, code, river, station, latitude, longitude FROM ",my_database,".\"tblLocation\"", sep = "")
  rSelect <- dbSendQuery(db$con, sSelect) 
  tblLocation <- dbFetch(rSelect)
  if (dim(tblLocation)[1] != 0){
    tblLocation$Stations = NA
    tblLocation$Stations = paste(tblLocation$river, tblLocation$station, sep = "\n at ")
  }
  dbClearResult(rSelect)
  
  sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblModelVariable\"", sep = "")
  rSelect <- dbSendQuery(db$con, sSelect)
  tblModelVariable <- dbFetch(rSelect)
  dbClearResult(rSelect)
  
  sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblScoreType\"", sep = "")
  rSelect <- dbSendQuery(db$con, sSelect)
  tblScoreType <- dbFetch(rSelect)
  dbClearResult(rSelect)
  
  # define hierarchical Filters
  output$CaseStudy <- renderUI({
    sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblCaseStudy\"", sep = "")
    rSelect <- dbSendQuery(db$con, sSelect)
    tblCaseStudy <- dbFetch(rSelect)
    dbClearResult(rSelect)
    
    if(length(tblCaseStudy) != 0){
      CaseStudy = setNames(tblCaseStudy$id, tblCaseStudy$name)
      
      selectInput("rtnCaseStudy",
                  "Case Study:", 
                  choices = CaseStudy, multiple = F)
    } else {
      selectInput("rtnCaseStudy",
                  "Case Study:", 
                  choices = "", multiple = F) 
    }
  })
  
  output$System <- renderUI({
    x <- input$rtnCaseStudy
    if (!is.null(x)){
      if (x != "") {
        tmpSystem <- select(tblExperiment, c(idCaseStudy, idForecastSystem) )
        tmpSystem <- filter(tmpSystem, idCaseStudy==x)
        sSelect <- paste("SELECT FS.name, FS.id FROM ",my_database,".\"tblForecastSystem\" as FS, ",my_database,
                         ".\"tblExperiment\" as E WHERE FS.id IN (", 
                         paste(unique(tmpSystem$idForecastSystem), sep = "", collapse = ","), ")", sep= "")
        
        rSelect <- dbSendQuery(db$con, sSelect)
        System <- dbFetch(rSelect)
        dbClearResult(rSelect)
        selectInput("rtnForecastSystem", "System:", choices = structure(System$name), multiple = F, selected = 1)
        
      }
    }
  })
  
  output$resettableInput <- renderUI({
    req(input$go)
    isolate(input$Uploaddata)
    if(isolate(input$Uploaddata)==upload_pwd){
      fileInput('file1', "Select your file(s) below:", width="80%", multiple = TRUE)
    }
  })
  output$resettableInput2 <- renderUI({
    req(input$go)
    isolate(input$Uploaddata)
    if(isolate(input$Uploaddata)==upload_pwd){
      selectInput('uploadFormat', label = "Select upload format",
                  choices = c(
                    "RDS" = 'rds',
                    "txt" = 'txt'),
                  selected = 'txt')
    }
  })
  output$resettableInput3 <- renderUI({
    req(input$go)
    isolate(input$Uploaddata)
    if(isolate(input$Uploaddata)==upload_pwd){
      wellPanel(h4("Summary"),verbatimTextOutput("filename"))
    }
  })
  

  output$Setup <- renderUI({
    x <- input$rtnForecastSystem
    y <- input$rtnCaseStudy
    if (!any(
      is.null(x),
      is.null(y)
    )) {
      if (x != "" & y != "") {
        tmpSetup <- select(tblExperiment, c(idCaseStudy, idForecastSystem, idForecastType) )
        tmpSetup <- filter(tmpSetup, idForecastSystem==tblForecastSystem$id[tblForecastSystem$name == x] & idCaseStudy==y)
        sSelect <- paste("SELECT FT.name, FT.id FROM ",my_database,".\"tblForecastType\" as FT WHERE FT.id IN ", sep= "")
        aa <- apply(data.frame(tmpSetup$idForecastType), 2, function(x) {
          paste("(", paste(x, sep = "", collapse = ","), ")", sep = "")
        })
        bb <- paste(sSelect, aa, sep = "")
        rSelect <- dbSendQuery(db$con, bb)
        
        Setup <- dbFetch(rSelect)
        dbClearResult(rSelect)
        selectInput("rtnForecastType","Forecast Setup: ", 
                    choices = structure(Setup$name), 
                    multiple=F, selected = 2)
      }
    }
  })
  
  output$Setup2 <- renderUI({
    x <- input$rtnForecastSystem
    y <- input$rtnCaseStudy
    if (!any(
      is.null(x),
      is.null(y)
    )) {
      if (x != "" & y != "") {
        tmpSetup <- select(tblExperiment, c(idCaseStudy, idForecastSystem, idForecastType) )
        tmpSetup <- filter(tmpSetup, idForecastSystem==tblForecastSystem$id[tblForecastSystem$name == x] & idCaseStudy==y)
        sSelect <- paste("SELECT FT.name, FT.id FROM ",my_database,".\"tblForecastType\" as FT WHERE FT.id IN ", sep= "")
        aa <- apply(data.frame(tmpSetup$idForecastType), 2, function(x) {
          paste("(", paste(x, sep = "", collapse = ","), ")", sep = "")
        })
        bb <- paste(sSelect, aa, sep = "")
        rSelect <- dbSendQuery(db$con, bb)
        
        Setup2 <- dbFetch(rSelect)
        dbClearResult(rSelect)
        selectInput("rtnForecastType2","Forecast Setup: ",
                    choices = structure(Setup2$name),
                    multiple=T, selected = 1)
      }
    }
  })
  
  output$Locations <- renderUI({
    x <- input$rtnCaseStudy
    y <- input$rtnForecastSystem
    z <- input$rtnForecastType 
    if (!any(
      is.null(x),
      is.null(y),
      is.null(z)
    )) {
      if (x != "" & y != "" & z != "") {
        Locations <- select(tblExperiment, c(id, idCaseStudy, idForecastSystem, idForecastType) )
        Locations <- filter(Locations, idCaseStudy == x, idForecastSystem==tblForecastSystem$id[tblForecastSystem$name == y], 
                            idForecastType == tblForecastType$id[tblForecastType$name == z])
        sSelect <- paste("SELECT L.id, L.code FROM ",my_database,".\"tblLocation\" as L, ",my_database,".\"tblScores\" as TS WHERE TS.\"idExperiment\" = ", 
                         Locations$id, " AND TS.\"idLocation\" = L.id",sep = "")
        rSelect <- dbSendQuery(db$con, sSelect)
        Locations <- unique(dbFetch(rSelect))
        dbClearResult(rSelect)
        Locations$Stations = NA
        for (loc in Locations$id){
          Locations$Stations[Locations$id == loc] = tblLocation$Stations[tblLocation$id == loc]
        }
        selectInput("rtnLocid","Location(s): ", choices = structure(Locations$Stations), multiple=T)
      }}
  })
  
  output$ScoreTypes <- renderUI({
    if(!is.null(tblScoreType)) {
      ScoreTypes <- structure(tblScoreType$name)
    }
    x <- input$rtnCaseStudy
    y <- input$rtnForecastSystem
    z <- input$rtnForecastType
    if (any(
      is.null(x),
      is.null(y),
      is.null(z)
      
    ))
      return()
    tabScoreTypes <- select(tblExperiment, c(id, idCaseStudy, idForecastSystem, idForecastType, idScoreType) )
    tabScoreTypes <- filter(tabScoreTypes, idCaseStudy == x, idForecastSystem==tblForecastSystem$id[tblForecastSystem$name == y], 
                            idForecastType == tblForecastType$id[tblForecastType$name == z])
    
    ScoreTypes = tblScoreType[tblScoreType$id %in% tabScoreTypes$idScoreType,]
    selectInput("rtnScoreTypes","Score Type(s): ", choices = structure(ScoreTypes$name), multiple=T)
  })
  
  output$ScoreTypeSingle <- renderUI({
    if(!is.null(tblScoreType)) {
      ScoreType <- structure(tblScoreType$name)
    }
    x <- input$rtnCaseStudy
    y <- input$rtnForecastSystem
    z <- input$rtnForecastType
    if (any(
      is.null(x),
      is.null(y),
      is.null(z)
    ))
      return()
    tabScoreType <- select(tblExperiment, c(id, idCaseStudy, idForecastSystem, idForecastType, idScoreType) )
    tabScoreType <- filter(tabScoreType, idCaseStudy == x, idForecastSystem==tblForecastSystem$id[tblForecastSystem$name == y], 
                           idForecastType == tblForecastType$id[tblForecastType$name == z])
    
    ScoreType = tblScoreType[tblScoreType$id %in% tabScoreType$idScoreType,]
    selectInput("rtnScoreType","Score Type:", choices = structure(ScoreType$name), multiple=F)
  })
  
  output$ModelVariable <- renderUI({
    if (length(tblModelVariable) != 0){
      ModelVariable <- tblModelVariable$name
      selectInput("rtnModelVariable","Variable: ", choices = ModelVariable, multiple=F)
    }
  })
  
  ########################" TAB 3 Compare Skill Scores
  
  output$ReferenceSystem <- renderUI({
    paste("> ", input$rtnForecastSystem)
  })
  
  output$ReferenceSetup <- renderUI({
    paste("> ", input$rtnForecastType)
  })
  
  output$SystemToCompare <- renderUI({
    x <- input$rtnCaseStudy
    if(length(tblForecastSystem) != 0){
      if (any(
        !is.null(x)
      )) {if (x != "") {
      tabtemp <- select(tblExperiment, c(id, idCaseStudy, idForecastSystem))
      tabtemp <- filter(tabtemp, idCaseStudy == x)
      System <- tblForecastSystem$name[tblForecastSystem$id %in% tabtemp$idForecastSystem]
      selectInput("rtnSystemToCompare", "Compared system:", choices = System, multiple = F, selected = System[2]) #selected = none?
    }}}})
  
  output$SetupToCompare <- renderUI({
    z <- input$rtnSystemToCompare
    if (any(
      !is.null(z)
    )) {if (z != "") {
      tabSetupCompare <- select(tblExperiment, c(idCaseStudy, idForecastSystem, idForecastType) )
      tabSetupCompare <- filter(tabSetupCompare, idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == z])
      SetupCompare = tblForecastType[tblForecastType$id %in% tabSetupCompare$idForecastType,]
      selectInput("rtnSetupToCompare","Forecast Setup: ", 
                  choices = structure(SetupCompare$name), 
                  multiple=F)
    }
    }
  })  
  
  get.overlapping.locs <- reactive({
    a <- input$rtnForecastSystem
    b <- input$rtnForecastType
    c <- input$rtnSystemToCompare
    d <- input$rtnSetupToCompare
    e <- input$rtnScoreTypesMeetingCrit
    if(!is.null(a) &
       !is.null(b) &
       !is.null(c) &
       !is.null(d) &
       !is.null(e)){
      sqlOverlappingLocations = select(tblExperiment, c(id, idForecastSystem, idForecastType, idScoreType, idCaseStudy))
      subset_ref = filter(sqlOverlappingLocations, idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == a], 
                          idForecastType == tblForecastType$id[tblForecastType$name == b], 
                          idScoreType %in% tblScoreType$id[tblScoreType$name %in% e], idCaseStudy == input$rtnCaseStudy)
      subset_compare = filter(sqlOverlappingLocations, idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == c], 
                              idForecastType == tblForecastType$id[tblForecastType$name == d], 
                              idScoreType %in% tblScoreType$id[tblScoreType$name %in% e], idCaseStudy == input$rtnCaseStudy)
      sSelect <- paste("SELECT L.id FROM ",my_database,".\"tblLocation\" as L, ",my_database,
                       ".\"tblScores\" as TS WHERE L.id = TS.\"idLocation\" AND TS.\"idExperiment\" IN ", sep = "")
      aa <- apply(data.frame(subset_ref$id), 2, function(x) {
        paste("(\'", paste(x, sep = "", collapse = "\',\'"), "\')", sep = "")
      })
      bb <- paste(sSelect, aa, sep = "")
      rSelect <- dbSendQuery(db$con, bb)
      Locations_ref <- unique(dbFetch(rSelect))
      dbClearResult(rSelect)
      
      sSelect <- paste("SELECT L.id FROM ",my_database,".\"tblLocation\" as L, ",my_database,
                       ".\"tblScores\" as TS WHERE L.id = TS.\"idLocation\" AND TS.\"idExperiment\" IN ", sep = "")
      aa <- apply(data.frame(subset_compare$id), 2, function(x) {
        paste("(\'", paste(x, sep = "", collapse = "\',\'"), "\')", sep = "")
      })
      bb <- paste(sSelect, aa, sep = "")
      rSelect <- dbSendQuery(db$con, bb)
      Locations_compare <- unique(dbFetch(rSelect))
      dbClearResult(rSelect)
      df = data.frame(locationID = Locations_ref$id[Locations_ref$id %in% Locations_compare$id])
      
      return(df)
    }
    else {
      return()
    }
  })
  
  get.overlapping.scoretypes <- reactive({
    a <- input$rtnForecastSystem
    b <- input$rtnForecastType
    c <- input$rtnSystemToCompare
    d <- input$rtnSetupToCompare
    
    if (any(is.null(a), is.null(b), is.null(c), is.null(d))){return()}
    sqlOverlappingScoreTypes = select(tblExperiment, c(idScoreType, idCaseStudy, idForecastSystem, idForecastType))
    subset_ref = filter(sqlOverlappingScoreTypes, idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == a], 
                        idForecastType == tblForecastType$id[tblForecastType$name == b])
    subset_compare = filter(sqlOverlappingScoreTypes, idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == c], 
                            idForecastType == tblForecastType$id[tblForecastType$name == d])
    df = data.frame(scoreType = subset_ref$idScoreType[as.vector(subset_ref$idScoreType) %in% as.vector(subset_compare$idScoreType)])
    return(df)
  })
  
  output$LocationsAll <- renderUI({
    if(!is.null(get.overlapping.locs())){
      LocationsAll_vect <- as.vector(get.overlapping.locs()) 
    }
    else {
      return()
    }
    sSelect <- paste("SELECT L.\"code\" FROM ",my_database,".\"tblLocation\" as L WHERE L.id IN ", sep = "")
    aa <- apply(data.frame(LocationsAll_vect$locationID), 2, function(x) {
      paste("(\'", paste(x, sep = "", collapse = "\',\'"), "\')", sep = "")
    })
    bb <- paste(sSelect, aa, sep = "")
    rSelect <- dbSendQuery(db$con, bb)
    LocationsInBoth <- unique(dbFetch(rSelect))
    dbClearResult(rSelect)
    LocationsInBoth$Stations = NA
    for (loc in LocationsInBoth$code){
      LocationsInBoth$Stations[LocationsInBoth$code == loc] = tblLocation$Stations[tblLocation$code == loc]
    }
    selectInput("rtnLocationsMeetingCrit","Location(s): ", choices = structure(LocationsInBoth$Stations), multiple=T)
  })
  
  output$ScoreTypesInBoth <- renderUI({
    
    if(!is.null(get.overlapping.scoretypes())){
      ScoreTypesInBoth_vect <- as.vector(get.overlapping.scoretypes())
    }
    else {
      return()
    }
    ScoreTypesInBoth = tblScoreType[tblScoreType$id %in% ScoreTypesInBoth_vect$scoreType,]
    selectInput("rtnScoreTypesMeetingCrit","Score Type(s): ", choices = structure(ScoreTypesInBoth$name), multiple=T)
  })
  
  #for first plot  
  filtInput <- reactive({
    validate(
      need(input$rtnLocid != "", "Please select at least one location from Filter Criteria"), 
      need(input$rtnScoreType != "", "Please select one score type")
      
    )
    selected_experiments <- filter(tblExperiment, idCaseStudy == input$rtnCaseStudy & 
                                     idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == input$rtnForecastSystem] & 
                                     idForecastType == tblForecastType$id[tblForecastType$name == input$rtnForecastType] & 
                                     idModelVariable == tblModelVariable$id[tblModelVariable$name == input$rtnModelVariable] & 
                                     idScoreType == tblScoreType$id[tblScoreType$name == input$rtnScoreType])
    list_stations = tblLocation$id[tblLocation$Stations %in% input$rtnLocid]
    sSelect <- paste("SELECT TS.id, TS.\"idExperiment\", TS.\"idLocation\", TS.\"scoreValue\", TS.\"leadTimeValue\" FROM ",
                     my_database,".\"tblScores\" as TS WHERE TS.\"idExperiment\" IN (", 
                     paste(rep(selected_experiments$id, length(list_stations)), sep = "", collapse = ","), ") AND TS.\"idLocation\" IN (", 
                     paste(list_stations, sep = "", collapse = ","), ")", sep = "")
    
    remote = data.frame()
    rSelect <- dbSendQuery(db$con, sSelect)
    remote <- rbind(remote, unique(dbFetch(rSelect)))
    dbClearResult(rSelect)
    remote$scoreValue[remote$scoreValue == -9999.] = NA
    
    getit <- structure(collect(remote))
  })
  
  filtSkillScores <- reactive({
    validate(
      need(input$rtnLocid != "", "Please select at least one location and one or more scores (below)"),
      need(input$rtnScoreTypes != "", "Please select at least one score type"),
      need(input$rtnForecastType2 != "", "Please select at least one forecast setup")
    )
    x <- input$rtnCaseStudy
    y <- input$rtnForecastSystem
    z <- input$rtnForecastType2
    s <- input$rtnScoreTypes
    m <- input$rtnModelVariable
    selected_experiments <- filter(tblExperiment, idCaseStudy == x & 
                                     idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == y] & 
                                     idForecastType %in% tblForecastType$id[tblForecastType$name %in% z] & 
                                     idScoreType %in% tblScoreType$id[tblScoreType$name %in% s] & 
                                     idModelVariable == tblModelVariable$id[tblModelVariable$name == m])
    
    list_stations = tblLocation$id[tblLocation$Stations %in% input$rtnLocid]
    sSelect <- paste("SELECT TS.id, TS.\"idExperiment\", TS.\"idLocation\", TS.\"scoreValue\", TS.\"leadTimeValue\" FROM ",
                     my_database,".\"tblScores\" as TS WHERE TS.\"idExperiment\" IN (",
                     paste(rep(selected_experiments$id, length(list_stations)), sep = "", collapse = ","), ") AND TS.\"idLocation\" IN (",
                     paste(list_stations, sep = "", collapse = ","), ")", sep = "")
    remote = data.frame()
    rSelect <- dbSendQuery(db$con, sSelect)
    remote <- rbind(remote, unique(dbFetch(rSelect)))
    dbClearResult(rSelect)
    remote$scoreValue[remote$scoreValue == -9999.] = NA
    
    getit <- structure(collect(remote))
  })
  
  ############ this builds the dataset needed for compareSkillScorePlot
  compareSkillScores <- reactive({
    a <- input$rtnForecastSystem
    b <- input$rtnForecastType
    c <- input$rtnSystemToCompare
    d <- input$rtnSetupToCompare
    e <- input$rtnScoreTypesMeetingCrit
    selected_experiments <- filter(tblExperiment, idCaseStudy == input$rtnCaseStudy & 
                                     ((idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == a] &
                                         idForecastType == tblForecastType$id[tblForecastType$name == b]) |
                                        (idForecastType == tblForecastType$id[tblForecastType$name == d] &
                                           idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == c])) &
                                     idModelVariable == tblModelVariable$id[tblModelVariable$name == input$rtnModelVariable] &
                                     idScoreType %in% tblScoreType$id[tblScoreType$name %in% e])
    sSelect <- paste("SELECT TS.id, TS.\"idExperiment\", TS.\"idLocation\", TS.\"scoreValue\", TS.\"leadTimeValue\" FROM ",
                     my_database,".\"tblScores\" as TS WHERE TS.\"idExperiment\" IN ",sep = "") 
    aa <- apply(data.frame(selected_experiments$id), 2, function(x) {
      paste("(\'", paste(x, sep = "", collapse = "\',\'"), "\')", sep = "")
    })
    bb <- apply(data.frame(tblLocation$id[tblLocation$Stations %in% input$rtnLocationsMeetingCrit]), 2, function(x) {
      paste("(\'", paste(x, sep = "", collapse = "\',\'"), "\')", sep = "")
    })
    cc <- paste(sSelect, aa, " AND TS.\"idLocation\" IN ", bb, sep = "")
    rSelect <- dbSendQuery(db$con, cc)
    remote <- dbFetch(rSelect)
    dbClearResult(rSelect)
    remote$scoreValue[remote$scoreValue == -9999.] = NA
    
    getit <- structure(collect(remote))
    
  }) #end reactive
  
  assign("getseriesPlot", value = reactive({
    validate(
      need(!is.null(filtInput()), "Select one or more data elements from the Filter to begin")
    )
    
    if (nrow(filtInput()) == 0 || length(filtInput()) == 0) {
      plot(1, 1, col = "white")
      text(1, 1,"Select one or more data elements from the Filter to begin")
    }
    else if (nrow(filtInput()) == 0 || length(filtInput()) == 0) {
      text(1, 1, "filtInput() was empty, try a different combo")
    } else {      
      filtered.input <- filtInput() 
      LeadTimeUnit = tblLeadTimeUnit$name[tblLeadTimeUnit$id == 
                                            tblExperiment$idLeadTimeUnit[tblExperiment$id == unique(filtered.input$idExperiment)]]
      loc.sum <- NULL 
      loc.sum <- summarySE(filtered.input,
                           measurevar = "scoreValue",
                           groupvars = c("idLocation", "leadTimeValue"),  # GT
                           na.rm = TRUE)
      loc.sum$idLocation <- as.factor(loc.sum$idLocation)
    }
    loc.sum$Stations = NA
    mes_locs = unique(loc.sum$idLocation)
    for (loc in mes_locs) {
      loc.sum$Stations[loc.sum$idLocation == loc] = tblLocation$Stations[which(tblLocation$id == loc)]
    }
    
    return(list(loc.sum = loc.sum, LeadTimeUnit = LeadTimeUnit, filtered.input = filtered.input, 
                width = 1, height = 1, 
                date = Sys.time()))
  }), envir = imprex_shiny)

  output$seriesPlot <- renderPlot({ #this is tab 1
    loc.sum = imprex_shiny$getseriesPlot()$loc.sum
    filtered.input = imprex_shiny$getseriesPlot()$filtered.input
    LeadTimeUnit = imprex_shiny$getseriesPlot()$LeadTimeUnit

    if (nrow(filtInput()) == 0) {
      plot(1, 1, col = "white")
      text(1, 1, "The database doesn't have information on this combination of variables (yet)")
    } else {
      pd <- position_dodge(0.2)
      ggplot(loc.sum,
             aes(color = Stations, x = leadTimeValue, y = scoreValue)) +
        geom_line(size = 1) +
        geom_point(aes(color = Stations)) + 
        xlab(paste("Lead Times (", LeadTimeUnit,")", sep="")) + 
        ylab(paste("SCORE: ", tblScoreType$name[tblScoreType$id ==
                                                  tblExperiment$idScoreType[tblExperiment$id == unique(filtered.input$idExperiment)]])) +
        theme_bw() + 
        theme(panel.grid.major = element_line(colour = NA)) +
        theme(axis.text = element_text(size=14, vjust=0.5)) +
        theme(legend.text = element_text(size=13, vjust=0.5)) +
        theme(title = element_text(size = 14))
    } 
  })
  
  assign("getfacetPlot", reactive({
    validate(
      need(!is.null(filtSkillScores()), "Select one or more data elements from the Filter to begin")
    )
    if (nrow(filtSkillScores()) == 0 || length(filtSkillScores()) == 0) {
      plot(1, 1, col = "white")
      text(1,1,"Select one or more data elements from the Filter to begin")
    }
    else if (nrow(filtSkillScores()) == 0 || length(filtSkillScores()) == 0) {
      text(1, 1, "filtInput() was empty, try a different combo")
    } else {
      filtered.input <- filtSkillScores() # debug rename in summarySE
      LeadTimeUnit = tblLeadTimeUnit$name[tblLeadTimeUnit$id %in%
                                            tblExperiment$idLeadTimeUnit[tblExperiment$id %in% unique(filtered.input$idExperiment)]]
      loc.sum <- summarySE(
        filtered.input,
        measurevar = "scoreValue",
        groupvars = c("idLocation", 
                      "leadTimeValue", "idExperiment"), # GT
        na.rm = TRUE
      )
      # loc.sum = cbind(loc.sum, ScoreType = tblScoreType$name[tblScoreType$id %in% tblExperiment$idScoreType[tblExperiment$id %in% loc.sum$idExperiment]])
      temp1 = merge(loc.sum, tblExperiment[, c("id", "idScoreType", "idForecastType", "idForecastSystem")], 
                      by.x = "idExperiment", by.y = "id")
      temp2 = merge(temp1, tblScoreType, by.x = "idScoreType", by.y = "id")
      names(temp2)[names(temp2) == "name"] = "ScoreType"
      temp3 = merge(temp2, tblForecastSystem, by.x = "idForecastSystem", by.y = "id")
      temp3 = merge(temp3, tblForecastType, by.x = "idForecastType", by.y = "id")
      temp3$SystemSetup = paste(temp3$name.x, temp3$name.y, sep = " ")
      temp3$name.x = NULL
      temp3$name.y = NULL
      loc.sum = temp3
      rm(temp1) ; rm(temp2) ; rm(temp3)
      loc.sum$idLocation <- as.factor(loc.sum$idLocation)
    }
    loc.sum$Stations = NA
    mes_locs = unique(loc.sum$idLocation)
    for (loc in mes_locs) {
      loc.sum$Stations[loc.sum$idLocation == loc] = tblLocation$Stations[which(tblLocation$id == loc)]
    }
    return(list(loc.sum = loc.sum, LeadTimeUnit = LeadTimeUnit, 
                width = length(unique(loc.sum$idLocation))*length(unique(loc.sum$leadTimeValue))/6, height = length(unique(loc.sum$ScoreType)), 
                date = Sys.time()))
  }), envir = imprex_shiny)
  
  output$facetPlot <- renderPlot({ #this is tab 2
    
    loc.sum = imprex_shiny$getfacetPlot()$loc.sum
    LeadTimeUnit = imprex_shiny$getfacetPlot()$LeadTimeUnit
    
    if (nrow(filtSkillScores()) == 0) {
      plot(1, 1, col = "white")
      text(1, 1, "The database doesn't have information on this combination of variables (yet)")
    } else {
      zz = ggplot(loc.sum, aes(x = leadTimeValue, y = scoreValue ), size = 1) 
      
      for (exp in unique(loc.sum$SystemSetup)){
        for (sc in unique(loc.sum$ScoreType)) {
          zz = zz + geom_line(aes(color = SystemSetup), data = loc.sum[(loc.sum$SystemSetup == exp) & (loc.sum$ScoreType == sc), ], size = 1)
        }
      }
      
      zz + facet_grid(ScoreType ~ Stations, scales = "free_y") + #margin = TRUE
        geom_hline(aes(yintercept=0), colour="grey", linetype="dashed", size = 1) +
        geom_point(aes(color = SystemSetup), size = 2) + 
        xlab(paste("Lead Times (",LeadTimeUnit,")", sep="")) + 
        ylab("Scores") +
        theme_bw() + 
        theme(panel.grid.major = element_line(colour = NA)) +
        theme(axis.text = element_text(size=14, vjust=0.5)) +
        theme(legend.text = element_text(size=13, vjust=0.5)) +
        theme(title = element_text(size = 14)) + 
        scale_x_discrete(limits = loc.sum$leadTimeValue) + 
        theme(panel.spacing.x = unit(2 / (length(unique(loc.sum$idLocation)) - 1), "lines")) +
        theme(panel.spacing.y = unit(2 / (length(unique(loc.sum$ScoreType)) - 1), "lines")) +
        theme(strip.text = element_text(size=14, vjust=0.5))

    }
  })
  
  assign("getcompareSkillScorePlot", reactive({
    validate(
      need(!is.null(input$rtnScoreTypesMeetingCrit), "Select one or more ScoreType(s) to begin"),
      need(!is.null(input$rtnLocationsMeetingCrit), "Select one or more Location(s) to begin")
    )
    a <- input$rtnForecastSystem
    b <- input$rtnForecastType
    c <- input$rtnSystemToCompare
    d <- input$rtnSetupToCompare
    e <- input$rtnScoreTypesMeetingCrit
    
    df <- compareSkillScores()
    LeadTimeUnit = tblLeadTimeUnit$name[tblLeadTimeUnit$id == 
                                          tblExperiment$idLeadTimeUnit[tblExperiment$id == unique(df$idExperiment[1])]]
    if (length(df)<1){
      return()
    }
    df$reference = NA
    df$scoreType = NA

    df$reference[df$idExperiment %in% tblExperiment$id[
      tblExperiment$idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == a] & 
        tblExperiment$idForecastType == tblForecastType$id[tblForecastType$name == b] &
        tblExperiment$idScoreType %in% tblScoreType$id[tblScoreType$name %in% e]]] = "ref"
    df$reference[df$idExperiment %in% tblExperiment$id[
      tblExperiment$idForecastSystem == tblForecastSystem$id[tblForecastSystem$name == c] & 
        tblExperiment$idForecastType == tblForecastType$id[tblForecastType$name == d] &
        tblExperiment$idScoreType %in% tblScoreType$id[tblScoreType$name %in% e]]] = "new"

    list_experiments = unique(df$idExperiment)
    for (exp in df$idExperiment){
      df$scoreType[df$idExperiment == exp] = tblScoreType$name[tblScoreType$id == tblExperiment$idScoreType[tblExperiment$id == exp]]
    }

    #step 0, if comparing same ForecastTypes(aka Setups), they should be all 0s
    if (input$rtnSetupToCompare==input$rtnForecastType & input$rtnForecastSystem==input$rtnSystemToCompare){
      agg <- c("idLocation", "leadTimeValue", "reference", "scoreType", "idExperiment")
      df.sum <- summarySE(data = df, measurevar = "scoreValue", groupvars = agg, na.rm = F) 
      df3 <- df.sum
      df3$scoreValue <- 0 # hard-coded to avoid NAs
      
    } else {
      #step 1, aggregate dataset
      agg <- c("idLocation", "leadTimeValue", "reference", "scoreType", "idExperiment")
      df.sum <- summarySE(data = df, measurevar = "scoreValue", groupvars = agg, na.rm = T)
      
      #step 2
      df3 <- skillScore(df.sum)
      
    }
    df3$Stations = NA
    mes_locs = unique(df3$idLocation)
    for (loc in mes_locs) {
      df3$Stations[df3$idLocation == loc] = tblLocation$Stations[which(tblLocation$id == loc)]
    }
    return(list(df3 = df3, LeadTimeUnit = LeadTimeUnit, 
                width = length(unique(df3$leadTimeValue))/6, height = length(unique(df3$scoreType)), 
                date = Sys.time()))
    
  }), envir = imprex_shiny)
  
  output$compareSkillScorePlot <- renderPlot({ #this is tab 3
    
    df3 = as.data.frame(imprex_shiny$getcompareSkillScorePlot()$df3, col.names = names(imprex_shiny$getcompareSkillScorePlot()$df3))
    LeadTimeUnit = imprex_shiny$getcompareSkillScorePlot()$LeadTimeUnit

    if (length(unique(df3$Stations)) < 13) {
      ggplot(df3,  aes(color = Stations, x = leadTimeValue, y = scoreValue ))+
        geom_line(size = 1) +
        geom_point(aes(color = Stations)) +
        theme_bw() +
        labs(col = "") +
        geom_hline(aes(yintercept=0), colour="grey", linetype="dashed") +
        facet_grid(scoreType~ ., scales = "free_y") +
        xlab(paste("Lead Times (",LeadTimeUnit,")", sep="")) +
        ylab("Skill Scores") +
        theme(panel.grid.major = element_line(colour = NA)) +
        theme(axis.text = element_text(size=14, vjust=0.5)) +
        theme(legend.text = element_text(size=14, vjust=0.5)) +
        theme(title = element_text(size = 14)) +
        scale_x_discrete(limits = df3$leadTimeValue) +
        ylim(-3, 3) +
        theme(panel.spacing.x = unit(2 / (length(unique(df3$Stations)) - 1), "lines")) +
        theme(panel.spacing.y = unit(2 / (length(unique(df3$scoreType)) - 1), "lines")) +
        theme(strip.text = element_text(size=14, vjust=0.5)) +
        annotate("text", size = 6, x = 2, y = 0.85, label = "Compared Syst. > Ref. Syst.") +
        annotate("text", size = 6, x = 2, y = -0.85, label = "Compared Syst. < Ref. Syst.")
    } else {
      ggplot(df3,  aes(color = "black", x = leadTimeValue, y = scoreValue )) + 
        geom_boxplot(aes(color = "black", group = cut_width(leadTimeValue, 1))) +
        geom_hline(aes(yintercept=0), colour="grey", linetype="dashed") +
        facet_grid(scoreType ~ ., scales = "free_y") + 
        xlab(paste("Lead Times (",LeadTimeUnit,")", sep="")) + 
        ylab("Skill Scores") +
        theme_bw() + 
        theme(legend.position = "none") +
        theme(panel.grid.major = element_line(colour = NA)) +
        theme(axis.text = element_text(size=14, vjust=0.5)) +
        theme(legend.text = element_text(size=13, vjust=0.5)) +
        theme(title = element_text(size = 14)) + 
        scale_x_discrete(limits = df3$leadTimeValue) + 
        ylim(-3, 3) +
        theme(panel.spacing.y = unit(2 / (length(unique(df3$scoreType)) - 1), "lines")) +
        theme(strip.text = element_text(size=14, vjust=0.5)) + 
        annotate("text", size = 6, x = 2, y = 0.85, label = "Compared Syst. > Ref. Syst.") +
        annotate("text", size = 6, x = 2, y = -0.85, label = "Compared Syst. < Ref. Syst.")
    }
  })
  
  output$summary <- renderPrint({ #this is tab 4
    cat("A total of \n")
    cat(c("- ", length(unique(tblExperiment$idForecastSystem)), "forecast systems \n"))
    cat(c("- ", length(unique(tblExperiment$idForecastType)), "forecast types \n"))
    cat(c("- ", length(unique(tblExperiment$idModelVariable)), "model variables \n"))
    cat(c("- ", length(unique(tblExperiment$idScoreType)), "score types \n"))
    cat(c("- ", length(unique(tblExperiment$idCaseStudy)), "case studies \n"))
    cat("are present in the database.")
  })
  
  values <- reactiveValues( #this is for tab 6
    file1 = NULL
  )
  
  observe({ #this is for tab 6
    input$uploadFormat
    values$my_files <- NULL
  })
  
  observe({ #this is for tab 6
    values$file1 <- input$file1
    
    if(is.null(values$file1)){
      return(NULL)
    }
    else {
      for (my_files in input$file1$datapath){
        
        if(input$uploadFormat == 'rds'){
          file.content <- readRDS(file = my_files)
          meta_data = data.frame(Provider = file.content$Provider, tblCaseStudy = file.content$CaseStudy, 
                                 tblForecastSystem = file.content$ForecastSystem, tblForecastType = file.content$ForecastType, 
                                 tblModelVariable = file.content$ModelVariable, tblScoreType = file.content$ScoreType, 
                                 tblScoreLeadTimeUnit = file.content$ScoreLeadTimeUnit, VerificationPeriod = file.content$VerificationPeriod)
          my_data = file.content$data
          my_data[my_data == "Inf" | my_data == "-Inf" | my_data == "+Inf"] = NA
        } else if(input$uploadFormat == 'txt'){
          pp = "" ; i = 0
          while (pp[1] != "!") {
            i = i + 1
            pp = scan(file = my_files, nlines = 1, skip = i-1, sep = ";", what = "character")
            if (pp[1] == "Provider") {meta_data = data.frame(Provider = pp[2])}
            if (pp[1] == "CaseStudy") {meta_data = data.frame(meta_data, tblCaseStudy = pp[2])}
            if (pp[1] == "ForecastSystem") {meta_data = data.frame(meta_data, tblForecastSystem = pp[2])}
            if (pp[1] == "ForecastType") {meta_data = data.frame(meta_data, tblForecastType = pp[2])}
            if (pp[1] == "ModelVariable") {meta_data = data.frame(meta_data, tblModelVariable = pp[2])}
            if (pp[1] == "ScoreType") {meta_data = data.frame(meta_data, tblScoreType = pp[2])}
            if (pp[1] == "ScoreLeadTimeUnit") {meta_data = data.frame(meta_data, tblScoreLeadTimeUnit = pp[2])}
            if (pp[1] == "VerificationPeriod") {meta_data = data.frame(meta_data, VerificationPeriod = pp[2])}
          }
          my_data = read.csv(my_files, header = TRUE, skip = i, sep = ";", dec=".")
          my_data[my_data == "Inf" | my_data == "-Inf" | my_data == "+Inf"] = NA
          names(my_data) = c("LocationID", "River_names", "Station_names", "Latitude", "Longitude", "Score_Value", "LeadTime")
        }
        #before inserting in the database, let's check if it does not already exist (i.e. if you do not try to upload twice the same data)
        bool_insert = TRUE
        if(dim(tblExperiment)[1] != 0){
          for (nb_exp in 1:dim(tblExperiment)[1]) {
            if (
              (meta_data$tblCaseStudy == tblCaseStudy$name[tblCaseStudy$id == tblExperiment$idCaseStudy[nb_exp]]) & 
              (meta_data$tblScoreLeadTimeUnit == tblLeadTimeUnit$name[tblLeadTimeUnit$id == tblExperiment$idLeadTimeUnit[nb_exp]]) & 
              (meta_data$tblForecastSystem == tblForecastSystem$name[tblForecastSystem$id == tblExperiment$idForecastSystem[nb_exp]]) & 
              (meta_data$tblForecastType == tblForecastType$name[tblForecastType$id == tblExperiment$idForecastType[nb_exp]]) & 
              (meta_data$tblModelVariable == tblModelVariable$name[tblModelVariable$id == tblExperiment$idModelVariable[nb_exp]]) & 
              (meta_data$tblScoreType == tblScoreType$name[tblScoreType$id == tblExperiment$idScoreType[nb_exp]]) &
              (meta_data$VerificationPeriod == tblExperiment$verificationperiod[nb_exp])
            ) {bool_insert = FALSE}
          }
        }
        
        
        if (bool_insert) {
          if (!isPostgresqlIdCurrent(db$con)) {
            db <- src_postgres(
              dbname = REdbname,
              host = REhost,
              port = REport,
              user = REuser,
              password = REpassword
            )
          }
          id1 = selectInsertUnique("tblCaseStudy", meta_data$tblCaseStudy, db)
          id2 = selectInsertUnique("tblForecastSystem", meta_data$tblForecastSystem, db)
          id3 = selectInsertUnique("tblForecastType", meta_data$tblForecastType, db)
          id4 = selectInsertUnique("tblModelVariable", meta_data$tblModelVariable, db)
          id5 = selectInsertUnique("tblScoreType", meta_data$tblScoreType, db)
          id6 = selectInsertUnique("tblLeadTimeUnit", meta_data$tblScoreLeadTimeUnit, db)
          sInsert_tblExperiment <- paste("INSERT INTO ",my_database,
                                         ".\"tblExperiment\" (\"idCaseStudy\",\"idForecastSystem\",\"idForecastType\",\"idModelVariable\",
                                       \"idScoreType\",\"idLeadTimeUnit\",\"verificationperiod\",\"importDateTime\",\"provider\") VALUES (",
                                         id1,",",id2,",",id3,",",id4,",",id5,",\'",id6,"\',\'",meta_data$VerificationPeriod,"\',\'",Sys.time(),
                                         "\',\'",meta_data$Provider,"\') RETURNING id",sep='')
          rInsert_tblExperiment <- dbSendStatement(db$con, sInsert_tblExperiment)
          idExperiment <- dbFetch(rInsert_tblExperiment)
          dbClearResult(rInsert_tblExperiment)
          
          #selection des location uniques
          id <- !duplicated(my_data$LocationID)
          data_locationID <- as.character(my_data$LocationID[id])
          data_river <- as.character(my_data$River_names[id])
          data_station <- as.character(my_data$Station_names[id])
          data_latitude <- as.character(my_data$Latitude[id])
          data_longitude <- as.character(my_data$Longitude[id])
          #insertion des locations dans la DB
          sInsert_tblLocation <- paste("INSERT INTO ",my_database,
                                       ".\"tblLocation\" (\"code\",\"river\",\"station\",\"latitude\",\"longitude\") VALUES ",sep='')
          aa <- apply(cbind(data.frame(data_locationID),data.frame(data_river),data.frame(data_station),
                            data.frame(data_latitude),data.frame(data_longitude)), 1, function(x) {
                              paste("(", "\'", paste(x, sep = "", collapse = "\',\'"), "\')", sep = "")
                            })
          bb <- paste(aa, sep = "", collapse = ",")
          sInsert_tblLocation = paste(sInsert_tblLocation, bb, " ON CONFLICT DO NOTHING", sep = "")
          dbSendStatement(db$con,sInsert_tblLocation)
          
          idLocation = array(NA, length(data_locationID))
          sSelect <- paste("SELECT id, code from ",my_database,".\"tblLocation\" where code IN ",sep='')
          aa <- apply(data.frame(data_locationID), 2, function(x) {
            paste("(\'", paste(x, sep = "", collapse = "\',\'"), "\')", sep = "")
          })
          bb <- paste(sSelect,aa, sep = "")
          rSelect <- dbSendQuery(db$con, bb)
          idLocation <- dbFetch(rSelect)
          dbClearResult(rSelect)
          
          tab_idLocation = apply(data.frame(my_data$LocationID), 1, function(x) {idLocation$id[idLocation$code == x]})
          # insertion des donnees
          my_data$Score_Value[is.na(my_data$Score_Value)] = -9999.
          
          sInsert_tblScores <- paste("INSERT INTO ",my_database,
                                     ".\"tblScores\" (\"idExperiment\",\"idLocation\",\"scoreValue\",\"leadTimeValue\") VALUES ", sep = "")
          aa <- apply(cbind(data.frame(tab_idLocation),my_data[,c("Score_Value", "LeadTime")]), 1, function(x) {
            paste("(", idExperiment, ",", paste(x, sep = "", collapse = ","), ")", sep = "")
          })
          bb <- paste(aa, sep = "", collapse = ",")
          sInsert_tblScores = paste(sInsert_tblScores, bb)
          dbSendStatement(db$con,sInsert_tblScores)
          
          
          
          #let's reload everything
          if (isPostgresqlIdCurrent(db$con)) {
            dbDisconnect(db$con)
          }
          
          db <- src_postgres(
            dbname = REdbname,
            host = REhost,
            port = REport,
            user = REuser,
            password = REpassword
          )
          
          sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblCaseStudy\"", sep = "")
          rSelect <- dbSendQuery(db$con, sSelect) # use existing conn, seems to work w difft API
          tblCaseStudy <- dbFetch(rSelect)
          dbClearResult(rSelect)
          
          sSelect <- paste("SELECT id, \"idForecastSystem\", \"idForecastType\", \"idModelVariable\", \"idScoreType\",
                         \"idLeadTimeUnit\", \"idCaseStudy\", \"importDateTime\", \"provider\", \"verificationperiod\" FROM ",
                           my_database,".\"tblExperiment\"", sep = "")
          rSelect <- dbSendQuery(db$con, sSelect) # use existing conn, seems to work w difft API
          tblExperiment <- dbFetch(rSelect)
          dbClearResult(rSelect)
          sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblForecastSystem\"", sep = "")
          rSelect <- dbSendQuery(db$con, sSelect) # use existing conn, seems to work w difft API
          tblForecastSystem <- dbFetch(rSelect)
          dbClearResult(rSelect)
          
          sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblForecastType\"", sep = "")
          rSelect <- dbSendQuery(db$con, sSelect) # use existing conn, seems to work w difft API
          tblForecastType <- dbFetch(rSelect)
          dbClearResult(rSelect)
          
          sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblLeadTimeUnit\"", sep = "")
          rSelect <- dbSendQuery(db$con, sSelect) # use existing conn, seems to work w difft API
          tblLeadTimeUnit <- dbFetch(rSelect)
          dbClearResult(rSelect)
          
          sSelect <- paste("SELECT id, code, river, station, latitude, longitude FROM ",my_database,".\"tblLocation\"", sep = "")
          rSelect <- dbSendQuery(db$con, sSelect) # use existing conn, seems to work w difft API
          tblLocation <- dbFetch(rSelect)
          if (dim(tblLocation)[1] != 0){
            tblLocation$Stations = NA
            tblLocation$Stations = paste(tblLocation$river, tblLocation$station, sep = " at ")
          }
          dbClearResult(rSelect)
          
          sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblModelVariable\"", sep = "")
          rSelect <- dbSendQuery(db$con, sSelect) # use existing conn, seems to work w difft API
          tblModelVariable <- dbFetch(rSelect)
          dbClearResult(rSelect)
          
          sSelect <- paste("SELECT name, id FROM ",my_database,".\"tblScoreType\"", sep = "")
          rSelect <- dbSendQuery(db$con, sSelect) # use existing conn, seems to work w difft API
          tblScoreType <- dbFetch(rSelect)
          dbClearResult(rSelect)
          
          output$filename <- renderText({
            return(paste("Database updated with data from uploaded file:", values$file1$name, 
                         ". \n Please update the web page (press F5) to update the drop down menus and before uploading any other file. \n", sep = ""))
          }) } else {
            output$filename <- renderText({
              return(paste("Data already in the database. File:", values$file1$name,"was not uploaded. \n"))
            })
          }
      }
    }
  })
  

  
  output$downloadPlot <- downloadHandler(
    
    # test avec logo
    filename = function() {
      paste("data-", Sys.time(), ".pdf", sep="")
    },
    content = function(file) {
      img_imprex = readPNG("www/imprex.png")
      g <- rasterGrob(img_imprex, interpolate=TRUE, just = "center")

      if (!("SystemSetup" %in% names(last_plot()$data)) & ("N" %in% names(last_plot()$data))) {
        toto = imprex_shiny$getseriesPlot()$height
        tata = imprex_shiny$getseriesPlot()$width      
      }
      if ("SystemSetup" %in% names(last_plot()$data)) {
        toto = imprex_shiny$getfacetPlot()$height
        tata = imprex_shiny$getfacetPlot()$width
      }
      if (!("SystemSetup" %in% names(last_plot()$data)) & !("N" %in% names(last_plot()$data))) {
        toto = imprex_shiny$getcompareSkillScorePlot()$height
        tata = imprex_shiny$getcompareSkillScorePlot()$width      
      }
      
      heights = c(0.7,8.5,1)*29.7*toto/10.2/6
      widths = c(9,3,2,0.4)*21*tata/14.4/2

      copyright = textGrob(paste("This plot was created with the Imprex scoreboard v", sb_version," implemented by Irstea.", sep = ""),  
                           gp = gpar(face = "italic", cex = 1, col = "#2EACDB"), hjust = 0.5, vjust = 0.5)
      title = textGrob(paste("Case study:", tblCaseStudy$name[tblCaseStudy$id == input$rtnCaseStudy]), gp = gpar(face = "bold", cex = 1.5))
      
      lo = grid.layout(3, 4, widths = widths, heights = heights, default.units = "in")
      
      pdf(file, width = sum(widths), height = sum(heights))
      
      # Position the elements within the viewports
      grid.newpage()
      pushViewport(viewport(layout = lo))
      
      # The plot
      pushViewport(viewport(layout.pos.row=2, layout.pos.col = 1:3))
      print(last_plot(), newpage=FALSE)
      popViewport()
      
      # The logo
      pushViewport(viewport(layout.pos.row=3, layout.pos.col = 3, just = "left"))
      print(grid.draw(g), newpage=FALSE)
      popViewport()

      # The copyright
      pushViewport(viewport(layout.pos.row=3, layout.pos.col = 1))
      print(grid.draw(copyright), newpage=FALSE, justify = "left")
      popViewport()
      
      # The Title
      pushViewport(viewport(layout.pos.row=1, layout.pos.col = 1:2))
      print(grid.draw(title), newpage=FALSE, justify = "left")
      popViewport()
      
      dev.off()
      
    }
    
  )
  
  
})