fluidPage(
  # App title ----
  titlePanel(
    div(HTML("<h2>Trend polinomiale con cambi strutturali</h2>"),
        HTML("<h5>Generazione di un trend lineare (o costante) con un possibile cambio strutturale a partire da t0 scelto e con componente di errore WN
             distribuita secondo una normale con media 0 e varianza calcolata in percentuale scelta rispetto a quella del trend stimato.
             I parametri a0 e a1 si riferiscono al trend che va da 0 a t0, mentre b0 e b1 al trend che va da t0 a 100. La tabella sottostante
             riporta le significativita' dei parametri e il valore dell'R^2 corretto</h5>")
    )
  ),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      fluidRow(
        column(width = 8,
               # Input: Selection of the function parameters ----
               tags$div(id = "parDumBS",
                        sliderInput(inputId = "t0.dum",
                                    label = "t0",
                                    min = 50, max = 100, step = 1, value = 100),
                        sliderInput(inputId = "a0.dum",
                                    label = "a0",
                                    min = -10, max = 10, step = 0.1, value = 0),
                        sliderInput(inputId = "a1.dum",
                                    label = "a1",
                                    min = -0.25, max = 0.25, step = 0.001, value = 0),
                        sliderInput(inputId = "b0.dum",
                                    label = "b0",
                                    min = -40, max = 40, step = 0.1, value = 0),
                        sliderInput(inputId = "b1.dum",
                                    label = "b1",
                                    min = -0.25, max = 0.25, step = 0.001, value = 0),
                        sliderInput(inputId = "sd.dum",
                                    label = "St. deviation",
                                    min = 0.1, max = 0.5, step = 0.001, value = 0.1)
               ),
               bsTooltip(id = "parDumBS", title = HTML("y = (a<sub>0</sub>+a<sub>1</sub>&middot;t)&middot;d1 + (b<sub>0</sub>+b<sub>1</sub>&middot;t)&middot;d2 + e<sub>t</sub>"), placement = "top", trigger = "hover")
        ),
        column(width = 4,
               # Input: Selection for the simple trend
               tags$div(id = "trendSemplBS",
                        checkboxInput(inputId = "trendSempl",
                                      label = "Stima trend lineare senza cambio",
                                      value = F)
               ),
               bsTooltip(id = "trendSemplBS", title = HTML("y = &alpha;<sub>0</sub> + &alpha;<sub>1</sub> &middot; t"), placement = "bottom", trigger = "hover"),
               # Input: Selection for the trend with dummy
               tags$div(id = "trendDummyBS",
                        checkboxInput(inputId = "trendDummy",
                                      label = "Stima trend lineare con cambio",
                                      value = F)
               ),
               bsTooltip(id = "trendDummyBS", title = HTML("y = (&alpha;<sub>0</sub>+&alpha;<sub>1</sub>&middot;t)&middot;d1 + (&beta;<sub>0</sub>+&beta;<sub>1</sub>&middot;t)&middot;d2"), placement = "bottom", trigger = "hover"),
               actionButton(inputId = "reset.dum",
                            label = "Reset")
        )
      )
    ),
    # Main panel for displaying outputs ----
    mainPanel(
      fluidRow(
        column(width = 6,
               dygraphOutput(outputId = "plotTrend"),
               tableOutput(outputId="summaryTrend")),
        column(width = 6,
               dygraphOutput(outputId = "plotRes"))
      )
    )
  )
)