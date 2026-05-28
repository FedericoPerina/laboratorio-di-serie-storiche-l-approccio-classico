fluidPage(
  # App title ----
  titlePanel(
    div(HTML("<h2>Effetto di Slutsky-Yule</h2>"),
        HTML("<h5>Stima mediante media mobile di una serie storica di 100 osservazioni generate da un WN distribuito secondo
             una normale di media 0 e varianza scelta. La scelta dell'ordine senza determinazione dei pesi fa si che i pesi vengano calcolati
             automaticamente secondo media aritmetica (es. ordine 3: pesi = 1/3, 1/3, 1/3). Sotto ai grafici viene riportato il rapporto
             di riduzione della varianza residua.</h5>")
    )
  ),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Selection of the function parameters ----
      sliderInput(inputId = "sdSerieMM",
                  label = "St. deviation",
                  min = 0.5, max = 3, step = 0.01, value = 1),
      actionButton(inputId = "generateMM",
                   label = "Genera nuova serie"),
      fluidRow(
        column(width = 8,
          numericInput(inputId = "orderMM",
                       label = "Ordine della media mobile",
                       min = 1, max = 13, value = 3)
        ),
        column(width = 4,
          actionButton(inputId = "centerMM",
                       label = "Centratura"),
          style = "padding-top: 25px;"
        )
      ),
      textInput(inputId = "wtsMM",
                label = "Pesi della media mobile:",
                placeholder = "ex.: 1/5,1/5,1/5,1/5,1/5 or 0.2,0.2,0.2,0.2,0.2"),
      actionButton(inputId = "updateMM",
                   label = "Aggiorna grafico")
    ),
    # Main panel for displaying outputs ----
    mainPanel(
      fluidRow(
        column(width = 6,
               dygraphOutput("slutskyMM"),
               verbatimTextOutput("varRedMM")),
        column(width = 6,
               plotOutput("acfWN", height = "200px"),
               plotOutput("acfMM", height = "200px"))
      )
    )
  )
)