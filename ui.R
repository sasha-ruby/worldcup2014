library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("World Cup 2014 Players Leaderboard"),
    
    # Sidebar with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(
            helpText("The application monitors various metrics of players' performance in World Cup 2014 matches."),
            helpText("Initially, it loads scoring related data for all participating teams."),
            helpText("It is possible to view data related to specific team, by simply selecting a team in the dropdown. The data table is reactive and refreshes automatically."),
            helpText("It is also possible to monitor other metrics by selecting the desired one in the Metric dropdown. The data table is reactive and refreshes automatically."),
            
            selectInput("team", label = h5("Select country"), 
                        choices = list(
                            "All" = "*",
                            "Algeria" = "ALG",
                            "Argentina" = "ARG",
                            "Australia" = "AUS",
                            "Belgium" = "BEL",
                            "Bosnia and Herzegovina" = "BIH",
                            "Brazil" = "BRA",
                            "Cameroon" = "CMR",
                            "Chile" = "CHI",
                            "Columbia" = "COL",
                            "Costa Rica" = "BRA",
                            "Cote d'Ivoire" = "BRA",
                            "Croatia" = "CRO",
                            "Ecuador" = "ECU",
                            "England" = "ENG",
                            "France" = "FRA",
                            "Germany" = "GER",
                            "Ghana" = "GHA",
                            "Greece" = "GRE",
                            "Honduras" = "HON",
                            "Iran" = "IRN",
                            "Italy" = "ITA",
                            "Japan" = "JPN",
                            "Korea Republic" = "KOR",
                            "Mexico" = "MEX",
                            "Netherlands" = "NED",
                            "Nigeria" = "NGA",
                            "Portugal" = "POR",
                            "Russia" = "RUS",
                            "Spain" = "ESP",
                            "Switzerland" = "SUI",
                            "Uruguay" = "URU",
                            "USA" = "USA"), selected = 1),
            
            selectInput("metric", label = h5("Select metric"), 
                        choices = list("Goals scored" = "gs",
                                       "Shots" = "s",
                                       "Shot positions" = "sp",
                                       "Attacking" = "a",
                                       "Defending" = "de",
                                       "Disciplinary" = "di",
                                       "Passes" = "p",
                                       "Distance" = "dis"
                        ), selected = "gs")
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            br(),
            h3(textOutput("selMetric")),
            br(),
            tabsetPanel(
                tabPanel("Teams Stats",
                         plotOutput("teamStatsPlot"),
                         dataTableOutput("teamStats")
                         ),
#                tabPanel("Team Stats",
#                    plotOutput("plotmpgvscyl"),
#                        dataTableOutput("teamStats")),
            tabPanel("Player Stats",
                        dataTableOutput("topScorers"))
            ),
            br(),
            h5("Source:"),
            textOutput("selUrl"),
            br()
        )
    )
))