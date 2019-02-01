-- Script for cleaning the database
-- copy the lines below in the execute SQL window in postgreSQL and execute

TRUNCATE scoreboard."tblCaseStudy" CASCADE ; 

TRUNCATE scoreboard."tblLocation" CASCADE ;
TRUNCATE scoreboard."tblForecastSystem" CASCADE ;
TRUNCATE scoreboard."tblForecastType" CASCADE ;
TRUNCATE scoreboard."tblLeadTimeUnit" CASCADE ;
TRUNCATE scoreboard."tblModelVariable" CASCADE ;
TRUNCATE scoreboard."tblScoreType" CASCADE ;
