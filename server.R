library(shiny)
library(XML)
scrape2014 <- function(url) {
    doc <- htmlParse(url)
    temp<-getNodeSet(doc, "/*//span[@class=\"sorted-icon-wrap\"]")
    removeNodes(temp)
    
    var_names <- sapply(getNodeSet(doc, "//th"), 
                        xmlGetAttr, "class")
    var_names <- gsub(" playername-nolink", "", gsub("tbl-", "", var_names))
    tables <- readHTMLTable(doc)
    tab <- tables[[1]]
    
    var_teams <- sapply(getNodeSet(doc, "//td/span/img[@class='flag']"), 
                        xmlGetAttr, "src")
    tab$flag = paste("<img src=\"",var_teams,"\" />")
    tab$team = toupper(gsub(".png", "", gsub("http://img.fifa.com/images/flags/3/", "", var_teams)))
    colnames(tab) <- c(var_names, "flag", "team")
    tab <- tab[c("flag", "team", var_names)]
    return(tab)
}

bind2014 <- function(p) {
    url <- switch(p,
                  'gs' = "http://www.fifa.com/worldcup/statistics/players/goal-scored.html",
                  's' = "http://www.fifa.com/worldcup/statistics/players/shots.html",
                  'sp' = "http://www.fifa.com/worldcup/statistics/players/shots-positions.html",
                  'a' = "http://www.fifa.com/worldcup/statistics/players/attacking.html",
                  'de' = "http://www.fifa.com/worldcup/statistics/players/defending.html",
                  'di' = "http://www.fifa.com/worldcup/statistics/players/disciplinary.html",
                  'p' = "http://www.fifa.com/worldcup/statistics/players/passes.html",
                  'dis' = "http://www.fifa.com/worldcup/statistics/players/distance.html"
    )
    
    try <- scrape2014(url)
    for (i in 4:ncol(try)) { try[,i] <- as.numeric(as.character(try[,i]))}
    nms <- switch(p,
                  'gs' = c("F", "TEAM", "PLAYER", "MATCHES PLAYED", "MINUTES PLAYED", 
                           "TOTAL GOALS SCORED", "ASSISTS", "PENALTIES SCORED",
                           "GOALS SCORED WITH THE LEFT FOOT", "GOALS SCORED WITH THE RIGHT FOOT",
                           "HEADED GOALS"),
                  's' = c("F", "TEAM", "PLAYER", "MATCHES PLAYED", "MINUTES PLAYED", "SHOTS",
                          "ATTEMPTS ON TARGET", "ATTEMPTS OFF-TARGET", "WOODWORK"),
                  'sp' = c("F", "TEAM", "PLAYER", "MATCHES PLAYED", "MINUTES PLAYED", "ATTEMPTS",
                           "ATTEMPTS ON TARGET", "ATTEMPTS IN THE AREA", "ATTEMPTS OUTSIDE THE AREA", 
                           "ATTEMPTS ON-TARGET FROM INSIDE THE AREA", "ATTEMPTS ON-TARGET FROM OUTSIDE THE AREA"),
                  'a' = c("F", "TEAM", "PLAYER", "MATCHES PLAYED", "MINUTES PLAYED", "TOTAL GOALS SCORED",
                          "OFFSIDES", "SOLO RUNS INTO AREA", "LOST BALLS", "DELIVERIES IN PENALTY AREA", "TACKLES", "TACKLES SUFFERED"),
                  'de' = c("F", "TEAM", "PLAYER", "MATCHES PLAYED", "MINUTES PLAYED", "TACKLES", "TACKLES WON", 
                           "ATTEMPTED CLEARANCES", "CLEARANCE RATE", "SAVES", "BLOCKS", "RECOVERED BALLS"),
                  'di' = c("F", "TEAM", "PLAYER", "MATCHES PLAYED", "YELLOW CARDS", "SECOND YELLOW CARD AND RED CARD",
                           "RED CARDS", "FOULS COMMITTED", "FOULS SUFFERED", "FOULS CAUSING A PENALTY"),
                  'p' = c("F", "TEAM", "PLAYER", "MATCHES PLAYED", "MINUTES PLAYED", "TOTAL PASSES", "PASSES COMPLETED",
                          "PASSES COMPLETED (%)", "CROSSES", "CROSSES COMPLETED", "CROSSES COMPLETED (%)", "CORNERS",
                          "THROW-INS", "THROW-INS COMPLETED"),
                  'dis' = c("F", "TEAM", "PLAYER", "MATCHES PLAYED", "MINUTES PLAYED", "DISTANCE COVERED", 
                            "DISTANCE COVERED IN POSSESSION", "DISTANCE COVERED NOT IN POSSESSION", "TOP SPEED")
    )
    names(try) <- nms
    
    return(try)
    
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    plrs <- reactive({
        players <- bind2014(input$metric)
        if (input$team != "*") {
            players <- subset(players, TEAM == input$team)
        }
        return(players)
    })
    
    tms <- reactive({
#         library("plyr")
        t <- plrs()
        t[3] <- NULL
        t[,2] <- paste(t[,1], t[,2], sep="&nbsp;")
        t[1] <- NULL
#         return(t)
        return(aggregate(. ~ TEAM, data = t, FUN = sum))
#         t <- ddply(t, .(TEAM), colwise(sum))
    })
    
    url <- reactive({
        switch (input$metric,
                'gs' = "http://www.fifa.com/worldcup/statistics/players/goal-scored.html",
                's' = "http://www.fifa.com/worldcup/statistics/players/shots.html",
                'sp' = "http://www.fifa.com/worldcup/statistics/players/shots-positions.html",
                'a' = "http://www.fifa.com/worldcup/statistics/players/attacking.html",
                'de' = "http://www.fifa.com/worldcup/statistics/players/defending.html",
                'di' = "http://www.fifa.com/worldcup/statistics/players/disciplinary.html",
                'p' = "http://www.fifa.com/worldcup/statistics/players/passes.html",
                'dis' = "http://www.fifa.com/worldcup/statistics/players/distance.html"
        )
    })
    
    output$topScorers <- renderDataTable({
        plrs()
    })
    
    output$teamStats <- renderDataTable({
        tms()
    })
    
    output$teamStatsPlot <- renderPlot({
#         plot(tms()[,1], tms()[,4], col="blue", xlab = "Team", ylab = "Metric")
#         plot(tms())
        library(ggplot2)
        x <- rnorm(100, mean = 4, sd = 2)
        y <- rnorm(100, mean = 360, sd = 180)
        plot(x, y)
        #         t <- as.data.frame(tms())
#         ggplot(plrs())+
#             geom_point(aes(x=TEAM, y=names(plrs()[4])),size=3)
    })

    output$selMetric <- renderText({
        switch (input$metric,
                'gs' = "Goals Scored",
                's' = "Shots",
                'sp' = "Shots positions",
                'a' = "Attacking",
                'de' = "Defending",
                'di' = "Disciplinary",
                'p' = "Passes",
                'dis' = "Distance"
        )
    })
    
    output$selUrl <- renderText({
        url()
    })
    
})