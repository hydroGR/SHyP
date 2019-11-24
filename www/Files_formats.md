# Files formats and needed data and metadata

The scoreboard database can be updated with RDS and text files. 
One single data file can only contain data from one experiment evaluated on one score, with one initialisation, but it can include several stations. 

NA values must be entered as either: 
- NA
- -9999.

You are invited to open the example files to better know what to put in. Some important elements of explanation are provided here: 

- The RDS files are R data files. They contain a list of elements containing the metadata and data you want to upload. 

- The text files contain several lines with semi-column separated metadata (8 fields needed) and semi-column separated data. 

- In both formats, the metadata are read as characters:
  - Provider: your name
  - CaseStudy: your case study (please see the end of the document for the complete list of the IMPREX case study names)
  - ForecastSystem: your forecast system
  - ForecastType: the name you want to give to your experiment, e.g. the name of your model, with its time step if you can have several time steps. It is important to give a different name if you want to compare the new configuration with an older one. The score name should not appear here. 
  - ModelVariable: the name of the variable on which the score is evaluated. 
  - ScoreType: the name of the score
  - ScoreLeadTimeUnit: 'Day', 'Week', 'Month', etc. are examples. If every 15 days you make a seasonal forecast at a monthly time step for the next 6 months, you must put “Month”. 
  - VerificationPeriod: on which period you computed your score

- Data must include the following:
  - LocationID: whatever code you use to design your station / grid point / area on which the score is computed. This is read as character
  - River_names: read as characters 
  - Station_names: read as characters
  - Latitude: read as numeric
  - Longitude: read as numeric
  - Score_Value: your actual score values! Read as numeric
  - LeadTime: the leadtime that is evaluated. If every 15 days you make a seasonal forecast at a monthly time step for the next 6 months, you must put here values from 1 to 6.

- Important notice: some fields must be very carefully filled. Indeed, the database uses some of them to link the different tables of the database. The fields are all the metadata fields (except VerificationPeriod for now) and the LocationID. To illustrate what I am saying, if provider 1 gives CRPSS and provider 2 provides CRPSkillScore, which are basically the same scores, they will not be comparable in the 3rd panel of the scoreboard

List of IMPREX case study names (please use these exact names - in case you use the scoreboard for another application and want people to stick to case studies, please modify the names below accordingly):
Central European Rivers
Bisagno River basin
Jucar River basin
Lake Como basin
Llobregat River basin
Messara River basin
Segura River basin
South-East French catchments
Thames River basin
Umealven River
