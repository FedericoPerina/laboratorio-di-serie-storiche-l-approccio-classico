fluidPage(
  titlePanel(
    div(HTML("<h2>Stima della stagionalita' mediante dummy</h2>"),
        HTML("<h5>Scelta del periodo stagionale per generazione di una serie storica con componente stagionale e con componente di errore WN
             distribuita secondo una normale con media 0 e varianza calcolata in percentuale scelta rispetto a quella della stagionalita'.
             E' possibile visualizzare la serie destagionalizzata nel primo grafico, ed inoltre si ha una tabella che riporta medie dei
             coefficienti grezzi ed ideali oltre a tutti i corrispettivi valori.</h5>")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      numericInput(inputId = "selPerD",
                   label = "Selezione periodo",
                   min = 2, max = 12, value = 3),
      sliderInput(inputId = "sdStagD",
                  label = "St. deviation",
                  min = 0.1, max = 0.5, step = 0.01, value = 0.1),
      actionButton(inputId = "generateStagD",
                   label = "Genera nuova serie"),
      checkboxInput(inputId = "serieDestD",
                    label = "Serie destagionalizzata",
                    value = F),
      radioButtons(inputId = "selPlotD",
                   label = "Selezione del grafico",
                   choices = c("Coefficienti", "Residui"),
                   selected = "Coefficienti")
    ),
    mainPanel(
      fluidRow(
        column(width = 6,
               dygraphOutput("plotStagD")),
        column(width = 6,
               dygraphOutput("plotCoeffResD")),
        tableOutput("coeffTable")
      )
    )
  )
)