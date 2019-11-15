# SHyP (Scoreboard for Hydrometeorological Predictions) 
# Scoreboard utility for hydrological and meteorological predictions
# Created during the H2020 IMPREX project (grant 641811)
# First version by Jeffrey Norville (Irstea)
# Further developments and final version by Guillaume Thirel (Irstea)
# Contact: Guillaume dot Thirel at Irstea dot fr
# https://github.com/hydroGR/SHyP 
# Last modification: 15 November 2019

rm(list = ls())

readRenviron(".Renviron")
REhost =     Sys.getenv('pgserver')
REport =     Sys.getenv('pgport')
REdbname =   Sys.getenv('pgdb')
REuser =     Sys.getenv('api_user')
RElanguage = Sys.getenv('api_language')
REpassword = Sys.getenv('pgpassword')
my_database = Sys.getenv('pgschema')

sb_version = Sys.getenv('sb_version')

# installation of the packages the scoreboard needs
requested_packages = c("DT", "uuid", "shiny", "DBI", "RPostgreSQL", "lazyeval", "ggplot2", "dplyr", "png", "grid", "dbplyr")
for (tested_package in requested_packages) {
  if (!tested_package %in% installed.packages()[,1]){
    install.packages(tested_package)
  }
  print(tested_package)
  library(tested_package, character.only = TRUE)
}

shinyUI(
  fluidPage(
    div(style="float:right",
        paste("Scoreboard v", sb_version,". Connected to ", REdbname, " as ", REuser, ".", sep = "")
    ),
    div(style="padding: 1px 0px; width: '100%'",
        img(src = "imprex.png", height = 100)
    ),
    
    fluidRow(
      column(
        4,
        wellPanel(
          uiOutput("CaseStudy"),
          uiOutput("System"),
          conditionalPanel("input.inTabset != 'PanelPlots'",uiOutput("Setup")),
          conditionalPanel("input.inTabset == 'PanelPlots'",uiOutput("Setup2"))
        ),
        
        wellPanel(
          h4("Filter Criteria"),
          uiOutput("ModelVariable"),
          uiOutput("ForecastType"),
          conditionalPanel("input.inTabset != 'CompareSkillScores'", uiOutput("Locations"))
        )
        ,
        wellPanel(
          downloadButton("downloadPlot", "Download last plot"))
        
      ),
      
      column(
        8,
        tabsetPanel(id = "inTabset",
                    type = "tabs",
                    
                    tabPanel(
                      "Plot",
                      value="Plot",
                      wellPanel(
                        column(5,
                               uiOutput("ScoreTypeSingle")
                        ),
                        column(3,
                               p("Plots of a score over lead times for station(s)")#,
                        ),
                        hr()
                      ),
                      plotOutput("seriesPlot")
                      
                    ),
                    tabPanel(
                      "Panel plots",
                      value="PanelPlots",
                      wellPanel(
                        column(6,
                               uiOutput("ScoreTypes")
                               
                        ),
                        column(2,
                               p("Panel plots of scores over lead times for station(s)")#,
                        ),
                        hr()
                      ),
                      plotOutput("facetPlot")
                      
                    ),
                    
                    tabPanel(
                      "Compare Skill Scores",
                      value="CompareSkillScores",
                      wellPanel(
                        column(4,
                               p(strong("Reference System:")),
                               strong(uiOutput("ReferenceSystem"))
                        ),
                        column(4,
                               p(strong("Reference Forecast Setup:")),
                               strong(uiOutput("ReferenceSetup"))
                        ),
                        p("The \"Reference\" selection can be changed in the menu on the left"),
                        br()
                      ),
                      wellPanel(fluidRow(
                        column(4,
                               uiOutput("SystemToCompare"),
                               uiOutput("ScoreTypesInBoth") #,
                        ),
                        column(3,
                               uiOutput("SetupToCompare"),
                               uiOutput("LocationsAll")
                        ),
                        br()
                        
                      )),
                      
                      br(),
                      plotOutput("compareSkillScorePlot")
                      
                    ), # end tabPanel
                    
                    tabPanel(
                      "Summary",
                      value="Summary",
                      h4("Summary of database"),
                      p(""),
                      verbatimTextOutput("summary"), 
                      icon = icon("database")
                    ),

                    tabPanel(title = "Scores definitions"     , 
                             fluidRow(column(6, includeMarkdown("www/scores.md"))),
                             icon  = icon("cog")),

                                        ###########################
          
                    ### Upload Data
                    tabPanel("Upload data", 
                             value = "Uploaddata",
                             passwordInput("Uploaddata", "The upload of data into the scoreboard database is password protected. Please enter the password:"),
                             actionButton("go", "Enter"),
                             fluidRow(column(6, includeMarkdown("www/format_files.md"))),
                             uiOutput('resettableInput'),
                             uiOutput('resettableInput2'),
                             uiOutput('resettableInput3'), 
                             icon  = icon("upload"))
        ) # end tabSet
      )
    )
  )
)
