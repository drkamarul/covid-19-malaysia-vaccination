#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(ggplot2)
library(plotly)
library(scales)

# Data
vaksin_my = read.csv("https://raw.githubusercontent.com/CITF-Malaysia/citf-public/main/vaccination/vax_malaysia.csv")
vaksin_my = data.frame(vaksin_my["date"], state = "Malaysia", subset(vaksin_my, select = dose1_daily:total_cumul))
vaksin_my_state = read.csv("https://raw.githubusercontent.com/CITF-Malaysia/citf-public/main/vaccination/vax_state.csv")
vaksin_my_state
vaksin_my$date = as.Date(vaksin_my$date)
vaksin_my_state$date = as.Date(vaksin_my_state$date)
vaksin_my_all = rbind(vaksin_my, vaksin_my_state)
vaksin_my_all = dplyr::arrange(vaksin_my_all, date, state)
states = unique(vaksin_my_all$state)
states = as.character(states)

# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("lumen"),
    # Application title
    titlePanel("Graf Vaksinasi di Malaysia"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            # select date range
            dateRangeInput(inputId = "dates", label = h3("Pilih tarikh"),
                           format = "dd-mm-yyyy",
                           min = min(vaksin_my$date),
                           max = max(vaksin_my$date),
                           start = min(vaksin_my$date),
                           end = max(vaksin_my$date)),
            
            selectInput(inputId = "state", label = h3("Pilih negeri"),
                        choices = states, selected = 1)
            
            
        ),

    # Show a plot of the generated distribution
        mainPanel(
            plotOutput(outputId = "carta", height = "800")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$carta <- renderPlot({
        colors = c("Dos 1" = "red", "Dos 2" = "blue")
        vaksin_my_sub = subset(vaksin_my_all, date >= input$dates[1] & date <= input$dates[2] & state == input$state)
        sel1 = vaksin_my_sub$dose1_cumul
        sel2 = vaksin_my_sub$dose2_cumul
        plot_vaksin = ggplot(vaksin_my_sub, aes(x = date)) +
            geom_line(aes(y = sel1, color = "Dos 1"), size = 2) +
            geom_line(aes(y = sel2, color = "Dos 2"), size = 2) +
            scale_x_date(date_breaks = "28 day", date_labels = "%d/%m/%y") +
            scale_y_continuous(labels = label_comma()) +
            labs(x = "Tarikh", y = "Jumlah Kumulatif", 
                 title = paste0("Jumlah Kumulatif Vaksinasi di ", input$state, " pada ", format(input$dates[2], "%d/%m/%Y")),
                 color = "Vaksinasi") +
            # annotate(geom = "text", x = input$dates[1] + 3, y = min(sel2) + 0.02*max(sel2),
            #          label = comma(max(sel2))) +
            # annotate(geom = "text", x = input$dates[1] + 3, y = min(sel1) + 0.02*max(sel2),
            #          label = comma(max(sel1))) +
            annotate(geom = "text", x = input$dates[2] - 3, y = max(sel2) + 0.02*max(sel2),
                     label = comma(max(sel2))) +
            annotate(geom = "text", x = input$dates[2] - 3, y = max(sel1) + 0.02*max(sel2),
                     label = comma(max(sel1))) +
            # annotate(geom = "text", x = input$dates[1] + 3, y = max(sel2), label = input$state) # for debug purpose
            theme_light()
        plot_vaksin
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
