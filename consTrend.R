fluidPage(
  # App title ----
  titlePanel(
    div(HTML("<h2>Conservazione del trend</h2>"),
        HTML("<h5>Generazione di serie storiche con trend polinomiale e componente di errore WN distribuita secondo una normale di media 0 e
              varianza calcolata in percentuale scelta rispetto a quella del trend. Successiva applicazione di una media mobile di ordine scelto.
              Nel caso in cui non vengano inseriti i pesi, verranno calcolati automaticamente secondo media aritmetica
              (es. ordine 3: pesi = 1/3, 1/3, 1/3).</h5>")
    )
  ),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      radioButtons(inputId = "selTrendCT",
                   label = "Selezione del trend",
                   choices = c("Trend costante", "Trend lineare", "Trend quadratico"),
                   selected = "Trend costante"),
      sliderInput(inputId = "sdTrendCT",
                  label = "St. deviation",
                  min = 0.1, max = 0.5, step = 0.01, value = 0.1),
      actionButton(inputId = "generateCT",
                   label = "Genera nuova serie"),
      fluidRow(
        column(width = 8,
               numericInput(inputId = "orderCT",
                            label = "Ordine della media mobile",
                            min = 1, max = 13, value = 3)
        ),
        column(width = 4,
               actionButton(inputId = "centerCT",
                            label = "Centratura"),
               style = "padding-top: 25px;"
        )
      ),
      textInput(inputId = "wtsCT",
                label = "Pesi della media mobile:",
                placeholder = "ex.: 1/5,1/5,1/5,1/5,1/5 or 0.2,0.2,0.2,0.2,0.2"),
      actionButton(inputId = "updateCT",
                   label = "Aggiorna grafico")
    ),
    # Main panel for displaying outputs ----
    mainPanel(
      fluidRow(
        column(width = 7,
               dygraphOutput("plotCT"),
               h4("Condizioni per la conservazione del polinomio:"),
               tableOutput("consCT")),
        column(width = 5,
               dygraphOutput("resCT"))
      )
    )
  )
)