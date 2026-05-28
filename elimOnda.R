fluidPage(
  titlePanel(
    div(HTML("<h2>Eliminazione di un'onda periodica</h2>"),
        HTML("<h5>Generazione di serie storiche con componente stagionale di periodo scelto e componente di errore WN distribuita
             secondo una normale con media 0 e varianza calcolata in percentuale scelta rispetto a quella della stagionalita'.
             Successiva applicazione di una media mobile di ordine scelto e stima dei coefficienti secondo due possibili modelli
             (additivo e moltiplicativo). Nel caso in cui non vengano inseriti i pesi, verranno calcolati automaticamente secondo media
             aritmetica (es. ordine 3: pesi = 1/3, 1/3, 1/3).</h5>")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      numericInput(inputId = "selStagS",
                   label = "Selezione periodo stagionale",
                   min = 3, max = 12, value = 3),
      sliderInput(inputId = "sdStagS",
                  label = "St. deviation",
                  min = 0.1, max = 0.3, step = 0.01, value = 0.1),
      actionButton(inputId = "generateStagS",
                   label = "Genera nuova serie"),
      radioButtons(inputId = "selModelS",
                   label = "Selezione del modello",
                   choices = c("Additivo", "Moltiplicativo"),
                   selected = "Additivo"),
      fluidRow(
        column(width = 8,
               numericInput(inputId = "orderStagS",
                            label = "Ordine della media mobile",
                            min = 1, max = 13, value = 5)
        ),
        column(width = 4,
               actionButton(inputId = "centerStagS",
                            label = "Centratura"),
               style = "padding-top: 25px;"
        )
      ),
      textInput(inputId = "wtsStagS",
                label = "Pesi della media mobile:",
                placeholder = "ex.: 1/5,1/5,1/5,1/5,1/5 or 0.2,0.2,0.2,0.2,0.2"),
      actionButton(inputId = "updateStagS",
                   label = "Aggiorna grafico")
    ),
    mainPanel(
      fluidRow(
        column(width = 6,
               dygraphOutput("plotDest", height = "280px"),
               dygraphOutput("plotGrezzi", height = "280px")),
        column(width = 6,
               dygraphOutput("plotSpec", height = "280px"),
               dygraphOutput("plotIdeali", height = "280px"))
      )
    )
  )
)