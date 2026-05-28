fluidPage(
  # App title ----
  titlePanel(
    div(HTML("<h2>Criteri per la scelta del grado del polinomio</h2>"),
        HTML("<h5>Scelta dei parametri per generazione di trend polinomiali con componente di errore WN distribuita secondo una normale con
             media 0 e varianza calcolata in percentuale scelta rispetto a quella del trend stimato. Le tabelle sottostanti mostrano le
             significativita' dei parametri e il valore dell'R^2 corretto (q si riferisce al grado del polinomio usato per la stima).</h5>")
    )
  ),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      fluidRow(
        column(width = 8,
        # Input: Selection of the function parameters ----
        tags$div(id = "critBS",
          sliderInput(inputId = "a0.crit",
                      label = "a0",
                      min = -100, max = 100, step = 0.1, value = 0),
          sliderInput(inputId = "a1.crit",
                      label = "a1",
                      min = -10, max = 10, step = 0.1, value = 0),
          sliderInput(inputId = "a2.crit",
                      label = "a2",
                      min = -0.5, max = 0.5, step = 0.0001, value = 0),
          sliderInput(inputId = "a3.crit",
                      label = "a3",
                      min = -0.1, max = 0.1, step = 0.0001, value = 0),
          sliderInput(inputId = "sd.crit",
                      label = "St. deviation",
                      min = 0.1, max = 0.3, step = 0.01, value = 0.1)
        ),
        bsTooltip(id = "critBS",
                  title = HTML("y = a<sub>0</sub> + a<sub>1</sub> &middot; t + a<sub>2</sub> &middot; t<sup>2</sup> + a<sub>3</sub> &middot; t<sup>3</sup> + e<sub>t</sub>"),
                  placement = "top",
                  trigger = "hover")
        ),
        column(width = 4,
        # Input: Selection for the differences ----
        radioButtons(inputId = "diffSelection",
                     label = "Diff successive",
                     choices = c("Serie storica", "Diff prima", "Diff seconda",
                                 "Diff terza", "Diff quarta"),
                     selected = "Serie storica"),
        # Input: Selection for the estimated model
        checkboxInput(inputId = "fittedSeries",
                      label = "Modello stimato",
                      value = F),
        actionButton(inputId = "reset.crit",
                     label = "Reset")
        )
      )
    ),
    
    
    # Main panel for displaying outputs ----
    mainPanel(
      fluidRow(
        column(width = 6,
               plotOutput(outputId = "plotDiff"),
               tableOutput(outputId="signAlfa")),
        column(width = 6,
               dygraphOutput(outputId = "plotR2"),
               tableOutput(outputId = "R2"))
      )
    )
  )
)