fluidPage(
  # App title ----
  titlePanel(
    div(HTML("<h2>Trend esponenziale</h2>"),
        HTML("<h5>Scelta dei parametri per generazione di un trend esponenziale con componente di errore distribuita secondo una log-normale con
             media 0 e varianza calcolata in percentuale scelta rispetto a quella del trend stimato. I grafici mostrano rispettivamente la serie
             generata, quella stimata mediante modello moltiplicativo ed additivo, ed i corripettivi residui.</h5>")
    )
  ),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Selection of the function parameters ----
      tags$div(id = "parExp",
               sliderInput(inputId = "a0.exp",
                           label = "a0",
                           min = 800, max = 1200, step = 1, value = 1000),
               sliderInput(inputId = "a1.exp",
                           label = "a1",
                           min = 0.5, max = 0.95, step = 0.01, value = 0.8),
               sliderInput(inputId = "sd.exp",
                           label = "St. deviation",
                           min = 0.05, max = 0.15, step = 0.001, value = 0.1)
      ),
      bsTooltip(id = "parExp", title = HTML("y = a<sub>0</sub> * e<sup>a<sub>1</sub>&middot;t</sup> * e<sub>t</sub>"), placement = "top", trigger = "hover"),
      actionButton(inputId = "reset.exp",
                   label = "Reset")
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      fluidRow(
        column(width = 6,
               dygraphOutput(outputId = "plotSerieExp", height = "280px"),
               dygraphOutput(outputId = "plotAddExp", height = "280px")),
        column(width = 6,
               dygraphOutput(outputId = "plotMoltExp", height = "280px"),
               dygraphOutput(outputId = "plotResExp", height = "280px"))
      )
    )
  )
)