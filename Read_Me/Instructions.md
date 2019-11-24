# In case of problem
Please contact Guillaume Thirel at guillaume.thirel@irstea.fr. 

# General information
The scoreboard has been tested with several configurations on Windows 7 and Windows 10. It is generally advised to install recent versions of the required softwares. 
The required softwares are:
- R
- RStudio (strongly advised)
- R packages: shiny, DT, dplyr, RPostgreSQL, lazyeval, ggplot2, DBI, png, grid and uuid (in principle automatically installed while running the scoreboard but they can also be installed manually)
- PostgreSQL 
- pgAdmin (strongly advised).

The following pages provide instructions for installation on Windows and Linux, as well as instructions about the format of the data files and cleaning of the database. 

# Installation on Windows

- Install PostgreSQL (9.5 or more recent)
- Install pgAdmin (1.22.1 or more recent)
- Download and unzip the scoreboard tool in your chosen folder (but if you are here, you must have already done that!)
- Create the imprex database on a local instance of postgres. For this, you need to (please note that the display of pgAdmin may change with more recent versions):
  - Open PostgreSQL/pgAdmin, go to a database, click on “Execute your SQL requests” or “Create script”)
  - Paste the following text:
    CREATE DATABASE imprex
    WITH OWNER = postgres
    ENCODING = 'UTF8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
  - Execute (with the green arrow or the lightning)
- Create the imprex database empty structure. For this, you need to:
  - Refresh postgreSQL (a new database must have been created)
  - Go to the imprex database and click on “Execute your SQL requests” or “Create script”
  - Open the scoreboard_empty_structure.sql file
  - Execute (with the green arrow or the lightning)
- Modify your PostgreSQL password in the .Renviron file (this is a hidden file, so you need to allow your system to see hidden files). This file also contains a modifiable password to protect the uploading in case you host it somewhere. 
- Install R (tested on 3.3.1, R3.4.0 and R3.4.2)
- Install RStudio (tested on 0.99.903 and 1.0.143)
- You can install manually the R packages listed above, otherwise they will automatically be installed by the scoreboard
- Open the ui.R and server.R files in Rstudio
- Execute one of the 2 files with the RunApp button in RStudio


# Installation on Linux
- Install postgreSQL
  - sudo apt-get install postgresql postgresql-contrib
- Add a password for the user Postgres
  - sudo –u postgre psql
  - in the prompt, after ‘postgres=#’, type this: alter user postgres with password ‘cemagref’;
  - type this to close psql: \q
- Creation of the database
  - sudo psql -f scoreboard_empty_structure.sql imprex
- Install pgadmin3 (or later versions)
  - sudo apt-get pgadmin3
- Install R
  - sudo nano /etc/apt/sources.list
  - For Ubuntu16.04, add this line at the end of the file :
    deb http://cran.univ-paris1.fr/bin/linux/ubuntu xenial/
  - add the public key of the repository
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
  - refresh the list of the repositories
    sudo apt-get update
  - sudo apt-get install r-base
  - sudo apt-get install libpq-dev
- Install RStudio
  - sudo apt-get install gdebi-core
  - wget https://download1.rstudio.org/rstudio-1.0.136-amd64.deb
  - sudo gdebi rstudio-1.0.136-amd64.deb


# Files formats and needed data and metadata
The scoreboard works with RDS and text files. 
One single data file can only contain data from one experiment evaluated on one score, with one initialisation, but it can include several stations. 
NA values must be entered as either: 
- NA
- -9999.

Users are invited to open the dummy files to better know what to put in. Please find below some important elements of explanation: 
- The RDS files are R data files. They contain a list of elements containing the metadata and data you want to upload. 
- 	The text file contains several lines with semi-column separated metadata (8 fields needed) and semi-column separated data. 
- In both formats, the metadata are read as characters. 
  - Provider : your name
  - CaseStudy: your case study (“Jucar River Basin” for instance)
  - ForecastSystem: your forecast system
  - ForecastType: the name you want to give to your experiment, e.g. the name of your model, with its time step if you can have several time steps. It is important to give a different name if you want to compare the new configuration with an older one. The score name should not appear here. 
  - ModelVariable: the name of the variable on which the score is evaluated. 
  - ScoreType: the name of the score
  - ScoreLeadTimeUnit: “Day”, “Week”, “Month”, etc. are examples. If every 15 days you make a seasonal forecast at a monthly time step for the next 6 months, you must put “Month”. 
  - VerificationPeriod: on which period you computed your score
- data:
  - LocationID: whatever code you use to design your station / grid point / area on which the score is computed. This is read as character
  - River_names: read as characters 
  - Station_names: read as characters
  - Latitude: read as numeric
  - Longitude: read as numeric
  - Score_Value: your actual score values! Read as numeric
  - LeadTime: the leadtime that is evaluated. If every 15 days you make a seasonal forecast at a monthly time step for the next 6 months, you must put here values from 1 to 6.
- Important notice: some fields must be very carefully filled. Indeed, the database uses some of them to link the different tables of the database. The fields are all the metadata fields (except VerificationPeriod for now) and the LocationID. To illustrate what I am saying, if provider 1 gives CRPSS and provider 2 provides CRPSkillScore, which are basically the same scores, they will not be comparable in the 3rd panel of the scoreboard


Cleaning the database
- Go to the imprex database and click on “Execute your SQL requests” or “Create script”
- Open the cleaning_of_database.sql file
- Execute (with the green arrow or the lightning)

