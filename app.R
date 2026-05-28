library(shiny)
library(shinydashboard)
library(shinyBS)
library(MASS)
library(dygraphs)
library(xts)
make.dummy = function(n, freq=12, start=1)
{
  dv=matrix(0,nrow=n, ncol=freq)
  for (i in 1:freq)
    if (start==1) {dv[,i][seq(i,n,freq)]=1}
  else if (i < start) {dv[,i][seq(i+1-start+freq,n,freq)]=1}
  else {dv[,i][seq(i+1-start,n,freq)]=1}
  return(dv)
}

wma = function(y, order=5, wts=c(1/8,1/4,1/4,1/4,1/8), centre=TRUE, plot=TRUE)
{
  if (centre==TRUE)
  {
    n=length(y)
    sy=rep(NA,n)
    ord=(order-1)/2
    for (i in (ord+1):(n-ord)) sy[i]=sum(wts*y[(i-ord):(i+ord)]) 
    if (plot==TRUE)
    { 
      plot(y,type="l")
      lines(sy, col="red")
    }
    return(ts(sy))
  }
  if (centre==FALSE)
  {
    n=length(y)
    sy=rep(NA,n)
    for (i in (ord):(n)) sy[i]=sum(wts*y[(i-ord+1):(i)]) 
    if (plot==TRUE)
    { 
      plot(y,type="l")
      lines(sy, col="red")
    }
    return(ts(sy))
  }
}

# user interface ----
ui = dashboardPage(
  dashboardHeader(title="Laboratorio di Serie Storiche", titleWidth=300),
  dashboardSidebar(width=300,
    sidebarMenu(
      menuItem(HTML("1. Stima del trend mediante funzioni<br>matematiche"), tabName="trend", startExpanded=F,
               menuSubItem(HTML("1.1 Criteri per la scelta del grado del<br>polinomio"), tabName="criteri"),
               menuSubItem(HTML("1.2 Trend polinomiale con cambi<br>strutturali"), tabName="dummy"),
               menuSubItem("1.3 Trend esponenziale", tabName="trendExp")
      ),
      menuItem(HTML("2. Stima della componente stagionale<br>mediante funzioni matematiche"), tabName="stagionalita", startExpanded=F,
               menuSubItem("2.1 Stagionalita' mediante variabili dummy", tabName="stagDummy")
      ),
      menuItem("3. Le medie mobili", tabName="medieMobili", startExpanded=F,
               menuSubItem("3.1 Effetto di Slutsky-Yule", tabName="slutskyMM"),
               menuSubItem("3.2 Conservazione del trend", tabName="conservazioneTrend"),
               menuSubItem("3.3 Eliminazione di un'onda periodica", tabName="elimOnda")
      )
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName="criteri",
              source("criteri.R")),
      tabItem(tabName="dummy",
              source("dummy.R")),
      tabItem(tabName="trendExp",
              source("trendExp.R")),
      tabItem(tabName="stagDummy",
              source("stagDummy.R")),
      tabItem(tabName="slutskyMM",
              source("slutskyYule.R")),
      tabItem(tabName="conservazioneTrend",
              source("consTrend.R")),
      tabItem(tabName="elimOnda",
              source("elimOnda.R"))
    )
  )
)

# server logic ----
server = function(input, output, session) {
  # criteri:
  observe({
    n = 60
    trend = input$a0.crit + input$a1.crit * seq(-29,n-30,1) + input$a2.crit * seq(-29,n-30,1)^2 + input$a3.crit * seq(-29,n-30,1)^3
    if (sd(trend) == 0) {
      noise = rnorm(n, mean=0, sd=input$sd.crit*3)
    } else {
      noise = rnorm(n, mean=0, sd=input$sd.crit*(sd(trend)))
    }
    y = trend + noise
    t = seq(-29,n-30,1)
    t2 = t^2
    t3 = t^3
    fit = lm(y ~ 1)
    fit2 = lm(y ~ 1 + t)
    fit3 = lm(y ~ 1 + t + t2)
    fit4 = lm(y ~ 1 + t + t2 + t3)
    R2 = c(summary(fit)$r.squared, summary(fit2)$r.squared, summary(fit3)$r.squared, summary(fit4)$r.squared)
    R2corr = c(summary(fit)$adj.r.squared, summary(fit2)$adj.r.squared, summary(fit3)$adj.r.squared, summary(fit4)$adj.r.squared)
    output$plotDiff = renderPlot({
      diffSelection = switch(input$diffSelection,
                             "Serie storica" = y,
                             "Diff prima" = c(NULL, diff(y)),
                             "Diff seconda" = c(NULL, NULL, diff(y, 1, 2)),
                             "Diff terza" = c(NULL, NULL, NULL, diff(y, 1, 3)),
                             "Diff quarta" = c(NULL, NULL, NULL, NULL, diff(y, 1, 4)))
      plot(diffSelection, type="l", ylab = "Values", main = input$diffSelection)
      if (input$diffSelection == "Serie storica") {
        if (input$fittedSeries == T) {
          plot(diffSelection, type="l", ylab = "Values", main = input$diffSelection, col = "grey")
          lines(y - noise, col="red")
        }
      }
    })
    output$plotR2 = renderDygraph({
      maxIndex = which.max(round(R2corr, 4))
      y.R2corr = data.frame(time = c(-0.1, seq_along(R2corr) - 1, 4), value = c(NA, R2corr, NA))
      dygraph(y.R2corr, main = "R^2 corretto") %>%
        dySeries("value", label = "Value", drawPoints = TRUE, pointSize = 4, color = "black", strokeWidth = 0) %>%
        dyAnnotation(maxIndex - 1, text = "Max", width = 35, tooltip = paste("Max R^2:", round(R2corr[maxIndex], 4))) %>%
        dyAxis("y", valueRange = c(min(R2corr) - 0.05, max(R2corr) + 0.2)) %>%
        dyOptions(digitsAfterDecimal = 4) %>%
        dyLegend(width = 150)
    })
    output$signAlfa = renderTable({
      signPar = data.frame(
        alpha0 = c(summary(fit)$coef[1,4], summary(fit2)$coef[1,4], summary(fit3)$coef[1,4], summary(fit4)$coef[1,4]),
        alpha1 = c(NA, summary(fit2)$coef[2,4], summary(fit3)$coef[2,4], summary(fit4)$coef[2,4]),
        alpha2 = c(NA, NA, summary(fit3)$coef[3,4], summary(fit4)$coef[3,4]),
        alpha3 = c(NA, NA, NA, summary(fit4)$coef[4,4]),
        row.names = c("q = 0", "q = 1", "q = 2", "q = 3")
      )
    },
    rownames = T,
    digits = 4
    )
    output$R2 = renderTable({
      R2tab = data.frame(
        R2 = R2,
        R2corr = R2corr,
        row.names = c("q = 0", "q = 1", "q = 2", "q = 3")
      )
    },
    rownames = T,
    digits = 4
    )
  })
  observeEvent(input$reset.crit, {
    updateSliderInput(session, "a0.crit", value = 0)
    updateSliderInput(session, "a1.crit", value = 0)
    updateSliderInput(session, "a2.crit", value = 0)
    updateSliderInput(session, "a3.crit", value = 0)
    updateSliderInput(session, "sd.crit", value = 0.1)
    updateCheckboxInput(session, "fittedSeries", value = F)
  })
  # scomposizione trend con cambi strutturali:
  observe({
    n = 100
    d0 = c(rep(1,input$t0.dum),rep(0,n-input$t0.dum))
    d1 = c(seq(1,input$t0.dum,1),rep(0,n-input$t0.dum))
    d2 = c(rep(0,input$t0.dum),rep(1,n-input$t0.dum))
    d3 = if (input$t0.dum == 100) {rep(0,n)} else {c(rep(0,input$t0.dum),seq(1,n - input$t0.dum,1))}
    trend = input$a0.dum * d0 + input$a1.dum * d1 + input$b0.dum * d2 + input$b1.dum * d3
    if (sd(trend) == 0) {
      noise = rnorm(n, mean=0, sd=input$sd.dum*3)
    } else {
      noise = rnorm(n, mean=0, sd=input$sd.dum*sd(trend))
    }
    y = trend + noise
    t = seq(1,n,1)
    fit.lin = lm(y ~ 1 + t)
    fit.dum = lm(y ~ -1 + d0 + d1 + d2 + d3)
    output$plotTrend = renderDygraph({
      y1 = data.frame(time = seq_len(n), value = y)
      y2 = data.frame(time = seq_len(n), value = cbind(y, fit.lin$fitted.values))
      y3 = data.frame(time = seq_len(n), value = cbind(y, fit.dum$fitted.values))
      y4 = data.frame(time = seq_len(n), value = cbind(y, fit.lin$fitted.values, fit.dum$fitted.values))
      if (input$trendSempl == T & input$trendDummy == T) {
        dygraph(y4, main = "Serie storica") %>%
          dySeries("value.y", label = "Serie") %>%
          dySeries("value.V2", label = "Trend senza cambio") %>%
          dySeries("value.V3", label = "Trend con cambio") %>%
          dyOptions(colors = c("grey","red", "blue")) %>%
          dyRangeSelector() %>%
          dyLegend(width = 260)
      } else if (input$trendSempl == T & input$trendDummy == F) {
        dygraph(y2, main = "Serie storica") %>%
          dySeries("value.y", label = "Serie") %>%
          dySeries("value.V2", label = "Trend senza cambio") %>%
          dyOptions(colors = c("grey","red")) %>%
          dyRangeSelector() %>%
          dyLegend(width = 280)
      } else if (input$trendSempl == F & input$trendDummy == T) {
        dygraph(y3, main = "Serie storica") %>%
          dySeries("value.y", label = "Serie") %>%
          dySeries("value.V2", label = "Trend con cambio") %>%
          dyOptions(colors = c("grey","blue")) %>%
          dyRangeSelector() %>%
          dyLegend(width = 280)
      } else {
        dygraph(y1, main = "Serie storica") %>%
          dySeries("value", label = "Serie") %>%
          dyOptions(colors = "black") %>%
          dyRangeSelector() %>%
          dyLegend(width = 150)
      }
    })
    output$plotRes = renderDygraph({
      res = data.frame(time = seq_len(n), value = cbind(fit.lin$residuals, fit.dum$residuals))
      dygraph(res, main = "Residui") %>%
        dySeries("value.1", label = "Trend senza cambio") %>%
        dySeries("value.2", label = "Trend con cambio") %>%
        dyOptions(colors = c("red","blue")) %>%
        dyRangeSelector() %>%
        dyLegend(width = 300)
    })
    output$summaryTrend = renderTable({
      summaryTrend = data.frame(
        alpha0 = c(summary(fit.lin)$coef[1,4], summary(fit.dum)$coef[1,4]),
        alpha1 = c(summary(fit.lin)$coef[2,4], summary(fit.dum)$coef[2,4]),
        beta0 = c(NA, if (input$t0.dum == 100) {NA} else {summary(fit.dum)$coef[3,4]}),
        beta1 = c(NA, if (input$t0.dum == 100) {NA} else {summary(fit.dum)$coef[4,4]}),
        R2corr = c(summary(fit.lin)$adj.r.squared, summary(fit.dum)$adj.r.squared),
        row.names = c("Trend singolo", "Trend con cambio")
      )
    },
    rownames = T,
    digits = 4
    )
  })
  observeEvent(input$reset.dum, {
    updateSliderInput(session, "t0.dum", value = 100)
    updateSliderInput(session, "a0.dum", value = 0)
    updateSliderInput(session, "a1.dum", value = 0)
    updateSliderInput(session, "b0.dum", value = 0)
    updateSliderInput(session, "b1.dum", value = 0)
    updateSliderInput(session, "sd.dum", value = 0.2)
  })
  # trend esponenziale:
  observe({
    n = 20
    trend = input$a0.exp * exp(input$a1.exp * seq(1,n,1))
    noise.molt = rlnorm(n, mean=0, sd=input$sd.exp)
    y = trend * noise.molt
    t = seq(1,n,1)
    fit.molt = lm(log(y) ~ 1 + t)
    fit.add = nls(y ~ a*exp(b*t), start=list(a=1000, b=0.8))
    output$plotSerieExp = renderDygraph({
      y1 = data.frame(time = seq_len(n), value = y)
      dygraph(y1, main = "Serie storica", group = "exp") %>%
        dySeries("value", label = "Serie") %>%
        dyOptions(colors = "black") %>%
        dyLegend(width = 150) %>%
        dyRangeSelector(height = 20)
    })
    output$plotMoltExp = renderDygraph({
      y.molt = data.frame(time = seq_len(n), value = cbind(y, exp(fit.molt$fitted.values)))
      dygraph(y.molt, main = paste("Modello moltiplicativo: ", HTML("y = &alpha;<sub>0</sub> * e<sup>&alpha;<sub>1</sub>&middot;t</sup> * &epsilon;<sub>t</sub>")), group = "exp") %>%
        dySeries("value.y", label = "Serie") %>%
        dySeries("value.V2", label = "Mod molt.") %>%
        dyOptions(colors = c("grey", "red")) %>%
        dyLegend(width = 280) %>%
        dyRangeSelector(height = 20)
    })
    output$plotAddExp = renderDygraph({
      y.add = data.frame(time = seq_len(n), value = cbind(y, predict(fit.add)))
      dygraph(y.add, main = paste("Modello additivo: ", HTML("y = &alpha;<sub>0</sub> * e<sup>&alpha;<sub>1</sub>&middot;t</sup> + &epsilon;<sub>t</sub>")), group = "exp") %>%
        dySeries("value.y", label = "Serie") %>%
        dySeries("value.V2", label = "Mod add.") %>%
        dyOptions(colors = c("grey", "blue")) %>%
        dyLegend(width = 280) %>%
        dyRangeSelector(height = 20)
    })
    output$plotResExp = renderDygraph({
      y.res = data.frame(time = seq_len(n), value = cbind(y - exp(fit.molt$fitted.values), residuals(fit.add)))
      dygraph(y.res, main = "Residui", group = "exp") %>%
        dySeries("value.1", label = "Mod molt.") %>%
        dySeries("value.2", label = "Mod add.") %>%
        dyOptions(colors = c("red", "blue")) %>%
        dyLegend(width = 280) %>%
        dyRangeSelector(height = 20)
    })
  })
  observeEvent(input$reset.exp, {
    updateSliderInput(session, "a0.exp", value = 1000)
    updateSliderInput(session, "a1.exp", value = 0.8)
    updateSliderInput(session, "sd.exp", value = 0.1)
  })
  # stagionalita' mediante dummy:
  observe({
    n = 60
    t = seq_len(n)
    dm = make.dummy(n, freq = 3, start = 1)
    stag = rep(runif(3, min = -10, max = 10), n/3)
    noise = rnorm(n, mean = 0, sd = 0.1*sd(stag))
    y = stag + noise
    fit = lm(y ~ -1 + dm)
    CG = fit$coefficients
    CI = CG - mean(CG)
    CI.vet = rep(CI, n/3)
    CG.vet = rep(CG, n/3)
    y.d = y - CI.vet
    output$plotStagD = renderDygraph({
      y1 = data.frame(time = seq_len(n), value = y)
      y.d1 = data.frame(time = seq_len(n), value = cbind(y, y.d))
      if (input$serieDestD == F) {
        dygraph(y1, main = "Serie storica", group = "stagDum") %>%
          dySeries("value", label = "Serie") %>%
          dyOptions(colors = "black") %>%
          dyRangeSelector(height = 20)
      } else {
        dygraph(y.d1, main = "Serie storica", group = "stagDum") %>%
          dySeries("value.y", label = "Serie") %>%
          dySeries("value.y.d", label = "Serie dest.") %>%
          dyOptions(colors = c("grey", "purple")) %>%
          dyRangeSelector(height = 20)
      }
    })
    output$plotCoeffResD = renderDygraph({
      coeffs = data.frame(time = seq_len(n), value = cbind(CG.vet, CI.vet))
      ress = data.frame(time = seq_len(n), value = fit$residuals)
      if (input$selPlotD == "Coefficienti") {
        dygraph(coeffs, main = "Coeff. grezzi ed ideali", group = "stagDum") %>%
          dySeries("value.CG.vet", label = "Grezzi", drawPoints = TRUE, pointSize = 3, strokePattern = "dotted") %>%
          dySeries("value.CI.vet", label = "Ideali", drawPoints = TRUE, pointSize = 3, strokePattern = "dotted") %>%
          dyOptions(colors = c("red", "blue")) %>%
          dyRangeSelector(height = 20)
      } else {
        dygraph(ress, main = "Residui", group = "stagDum") %>%
          dySeries("value", label = "Residui") %>%
          dyOptions(colors = "black") %>%
          dyRangeSelector(height = 20)
      }
    })
    Coeff = data.frame(
      mean = c(mean(CG), mean(CI)),
      d1 = c(CG[1], CI[1]),
      d2 = c(CG[2], CI[2]),
      d3 = c(CG[3], CI[3]),
      row.names = c("Grezzi", "Ideali")
    )
    output$coeffTable = renderTable({
      Coeff
    },
    rownames = TRUE,
    digits = 2
    )
  })
  observeEvent(input$generateStagD, {
    n = 60
    t = seq_len(n)
    dm = make.dummy(n, freq = input$selPerD, start = 1)
    stag = rep(runif(input$selPerD, min = -10, max = 10), n/input$selPerD + 1)[1:n]
    noise = rnorm(n, mean = 0, sd = input$sdStagD*sd(stag))
    y = stag + noise
    fit = lm(y ~ -1 + dm)
    CG = fit$coefficients
    CI = CG - mean(CG)
    CI.vet = rep(CI, n/input$selPerD + 1)
    CI.vet = CI.vet[1:n]
    CG.vet = rep(CG, n/input$selPerD + 1)
    CG.vet = CG.vet[1:n]
    y.d = y - CI.vet
    output$plotStagD = renderDygraph({
      y1 = data.frame(time = seq_len(n), value = y)
      y.d1 = data.frame(time = seq_len(n), value = cbind(y, y.d))
      if (input$serieDestD == F) {
        dygraph(y1, main = "Serie storica", group = "stagDum") %>%
          dySeries("value", label = "Serie") %>%
          dyOptions(colors = "black") %>%
          dyRangeSelector(height = 20)
      } else {
        dygraph(y.d1, main = "Serie storica", group = "stagDum") %>%
          dySeries("value.y", label = "Serie") %>%
          dySeries("value.y.d", label = "Serie dest.") %>%
          dyOptions(colors = c("grey", "purple")) %>%
          dyRangeSelector(height = 20)
      }
    })
    output$plotCoeffResD = renderDygraph({
      coeffs = data.frame(time = seq_len(n), value = cbind(CG.vet, CI.vet))
      ress = data.frame(time = seq_len(n), value = fit$residuals)
      if (input$selPlotD == "Coefficienti") {
        dygraph(coeffs, main = "Coeff. grezzi ed ideali", group = "stagDum") %>%
          dySeries("value.CG.vet", label = "Grezzi", drawPoints = TRUE, pointSize = 3, strokePattern = "dotted") %>%
          dySeries("value.CI.vet", label = "Ideali", drawPoints = TRUE, pointSize = 3, strokePattern = "dotted") %>%
          dyOptions(colors = c("red", "blue")) %>%
          dyRangeSelector(height = 20)
      } else {
        dygraph(ress, main = "Residui", group = "stagDum") %>%
          dySeries("value", label = "Residui") %>%
          dyOptions(colors = "black") %>%
          dyRangeSelector(height = 20)
      }
    })
    Coeff = data.frame(
      mean = c(mean(CG), mean(CI)),
      d1 = c(CG[1], CI[1]),
      d2 = c(CG[2], CI[2]),
      row.names = c("Grezzi", "Ideali")
    )
    if (input$selPerD > 2) {
      for (i in 3:input$selPerD) {
        colName = paste0("d", i)
        Coeff[[colName]] = c(CG[i], CI[i])
      }
    }
    output$coeffTable = renderTable({
      Coeff
    },
    rownames = TRUE,
    digits = 2
    )
  })
  # effetto di Slutsky-Yule:
  y.sy = reactiveVal(NULL)
  observe({
    y.sy(rnorm(100, 0, 1))
    output$slutskyMM = renderDygraph({
      y1 = data.frame(time = seq_len(100), value = y.sy())
      dygraph(y1, main = "Serie storica") %>%
        dySeries("value", label = "Serie") %>%
        dyOptions(colors = "black") %>%
        dyRangeSelector(height = 20)
    })
    output$acfWN = renderPlot({
      acf(y.sy(), main = "Serie storica")
    })
    output$acfMM = renderPlot({
      par(bg = NA)
    }, bg = "transparent")
    output$varRedMM = renderPrint({
      cat("Rapporto di riduzione della varianza residua:\n")
      print(NULL)
    })
  })
  observeEvent(input$generateMM, {
    y.sy(rnorm(100, 0, input$sdSerieMM))
    output$slutskyMM = renderDygraph({
      y1 = data.frame(time = seq_len(100), value = y.sy())
      dygraph(y1, main = "Serie storica") %>%
        dySeries("value", label = "Serie") %>%
        dyOptions(colors = "black") %>%
        dyRangeSelector(height = 20)
    })
    output$acfWN = renderPlot({
      acf(y.sy(), main = "Serie storica")
    })
    output$acfMM = renderPlot({
      par(bg = NA)
    }, bg = "transparent")
    output$varRedMM = renderPrint({
      cat("Rapporto di riduzione della varianza residua:\n")
      print(NULL)
    })
  })
  observeEvent(input$updateMM, {
    if (input$wtsMM == "") {
      wts = rep(1/input$orderMM, input$orderMM)
    } else {
      wts.str = unlist(strsplit(input$wtsMM, ","))
      wts = sapply(wts.str, function(x) eval(parse(text = x)))
      if (length(wts) != input$orderMM) {
        showModal(
          modalDialog(
            title = "Errore",
            "Il numero di pesi deve coincidere con l'ordine della media mobile!"
          )
        )
        return()
      }
    }
    y.mm = wma(y.sy(), order = input$orderMM, wts = wts, centre=T, plot=F)
    output$slutskyMM = renderDygraph({
      y.mm1 = data.frame(time = seq_len(100), value = cbind(y.sy(), y.mm))
      dygraph(y.mm1, main = "Serie storica") %>%
        dySeries("value.y.sy..", label = "Serie") %>%
        dySeries("value.y.mm", label = "Media mobile") %>%
        dyOptions(colors = c("grey", "red")) %>%
        dyRangeSelector(height = 20)
    })
    output$acfWN = renderPlot({
      acf(y.sy(), main = "Serie storica")
    })
    output$acfMM = renderPlot({
      acf(na.omit(y.mm), main = "Media Mobile", col="red")
    })
    output$varRedMM = renderPrint({
      cat("Rapporto di riduzione della varianza residua:\n")
      print(round(sum(wts^2), 4))
    })
  })
  updating = reactiveVal(FALSE)
  observeEvent(input$orderMM, {
    if (!updating()) {
      updateTextInput(session, "wtsMM", value = paste(fractions(rep(1/input$orderMM, input$orderMM)), collapse = ", "))
    }
  })
  observeEvent(input$centerMM, {
    if (input$orderMM %% 2 == 0) {
      updating(TRUE)
      p = input$orderMM
      updateNumericInput(session, "orderMM", value = p + 1)
      updateTextInput(session, "wtsMM", value = paste(fractions(c(1/(2*p), rep(1/p, p-1), 1/(2*p))), collapse = ", "))
      updating(FALSE)
    } else {
      showModal(
        modalDialog(
          title = "Errore",
          "L'ordine della media mobile deve essere pari!"
        )
      )
      return()
    }
  })
  # conservazione del trend:
  y.cons = reactiveVal(NULL)
  observe({
    n = 60
    a0 = runif(1, min = -50, max = 50)
    trend = a0 * rep(1, n)
    noise = rnorm(n, mean=0, sd=0.1)
    y.cons(trend + noise)
    output$plotCT = renderDygraph({
      y1 = data.frame(time = seq_len(n), value = y.cons())
      dygraph(y1, main = "Serie storica") %>%
        dySeries("value", label = "Serie") %>%
        dyOptions(colors = "black") %>%
        dyRangeSelector(height = 20)
    })
    output$consCT = renderTable({
      ConsTab = data.frame(
        Valore = c(NA, NA, NA),
        Conservazione = c(NA, NA, NA),
        row.names = c("Grado 0", "Grado 1", "Grado 2")
      )
    },
    rownames = T
    )
    output$resCT = renderDygraph({
      emp = data.frame(time = seq_len(n), value = rep(NA, n))
      dygraph(emp, main = "Residui")
    })
  })
  observeEvent(input$generateCT, {
    n = 60
    a0 = runif(1, min = -50, max = 50)
    a1.sample = c(runif(1, min = -5, max = -0.5), runif(1, min = 0.5, max = 5))
    a1 = sample(a1.sample, 1)
    a2.sample = c(runif(1, min = -0.5, max = -0.3), runif(1, min = 0.3, max = 0.5))
    a2 = sample(a2.sample, 1)
    selTrend = switch(input$selTrendCT,
                      "Trend costante" = a0 * rep(1, n),
                      "Trend lineare" = a0 + a1 * seq(-29, n-30, 1),
                      "Trend quadratico" = a0 + a1 * seq(-29, n-30, 1) + a2 * seq(-29, n-30, 1)^2)
    if (sd(selTrend) == 0) {
      noise = rnorm(n, mean=0, sd=input$sdTrendCT)
    } else {
      noise = rnorm(n, mean=0, sd=input$sdTrendCT*sd(selTrend))
    }
    y.cons(selTrend + noise)
    output$plotCT = renderDygraph({
      y1 = data.frame(time = seq_len(n), value = y.cons())
      dygraph(y1, main = "Serie storica") %>%
        dySeries("value", label = "Serie") %>%
        dyOptions(colors = "black") %>%
        dyRangeSelector(height = 20)
    })
    output$consCT = renderTable({
      ConsTab = data.frame(
        Valore = c(NA, NA, NA),
        Conservazione = c(NA, NA, NA),
        row.names = c("Grado 0", "Grado 1", "Grado 2")
      )
    },
    rownames = T
    )
    output$resCT = renderDygraph({
      emp = data.frame(time = seq_len(n), value = rep(NA, n))
      dygraph(emp, main = "Residui")
    })
  })
  observeEvent(input$updateCT, {
    if (input$wtsCT == "") {
      wts = rep(1/input$orderCT, input$orderCT)
    } else {
      wts.str = unlist(strsplit(input$wtsCT, ","))
      wts = sapply(wts.str, function(x) eval(parse(text = x)))
      if (length(wts) != input$orderCT) {
        showModal(
          modalDialog(
            title = "Errore",
            "Il numero di pesi deve coincidere con l'ordine della media mobile!"
          )
        )
        return()
      }
    }
    y.mm = wma(y.cons(), order = input$orderCT, wts = wts, centre = TRUE, plot = FALSE)
    output$plotCT = renderDygraph({
      y.mm1 = data.frame(time = seq_len(60), value = cbind(y.cons(), y.mm))
      dygraph(y.mm1, main = "Serie storica") %>%
        dySeries("value.y.cons..", label = "Serie") %>%
        dySeries("value.y.mm", label = "Media mobile") %>%
        dyOptions(colors = c("grey", "red")) %>%
        dyRangeSelector(height = 20)
    })
    output$resCT = renderDygraph({
      res = data.frame(time = seq_len(60), value = y.mm - y.cons())
      dygraph(res, main = "Residui") %>%
        dySeries("value", label = "Residui") %>%
        dyOptions(colors = "black") %>%
        dyRangeSelector(height = 20)
    })
    output$consCT = renderTable({
      h = input$orderCT
      if (input$orderCT == length(wts)) {
        # conservazione polinomio grado 0:
        gr0 = sum(wts)
        # conservazione polinomio grado 1:
        if (h%%2==1){
          gr1 = sum(wts*seq(-(h-1)/2,(h-1)/2,1))
        } else {
          gr1 = sum(wts*seq(-(h/2)+1,h/2,1))
        }
        # conservazione polinomio grado 2:
        if (h%%2==1){
          gr2 = sum(wts*seq(-(h-1)/2,(h-1)/2,1)^2)
        } else {
          gr2 = sum(wts*seq(-(h/2)+1,h/2,1)^2)
        }
        ConsTab = data.frame(
          Valore = c(gr0, gr1, gr2),
          Conservazione = c(if (gr0 == 1) {"<span>&#10003;</span>"} else {"<span>&#10007;</span>"},
                            if (gr1 == 0) {"<span>&#10003;</span>"} else {"<span>&#10007;</span>"},
                            if (gr2 == 0) {"<span>&#10003;</span>"} else {"<span>&#10007;</span>"}),
          row.names = c("Grado 0", "Grado 1", "Grado 2")
        )
      }
    },
    rownames = T,
    sanitize.text.function = function(x) x, escape = FALSE
    )
  })
  observeEvent(input$orderCT, {
    updateTextInput(session, "wtsCT", value = paste(fractions(rep(1/input$orderCT, input$orderCT)), collapse = ", "))
    output$consCT = renderTable({
      ConsTab = data.frame(
        Valore = c(NA, NA, NA),
        Conservazione = c(NA, NA, NA),
        row.names = c("Grado 0", "Grado 1", "Grado 2")
      )
    },
    rownames = T
    )
  })
  observeEvent(input$centerCT, {
    if (input$orderCT %% 2 == 1) {
      p = input$orderCT - 1
      updateTextInput(session, "wtsCT", value = paste(fractions(c(1/(2*p), rep(1/p, p-1), 1/(2*p))), collapse = ", "))
    } else {
      showModal(
        modalDialog(
          title = "Errore",
          "L'ordine della media mobile deve essere dispari!"
        )
      )
      return()
    }
  })
  # eliminazione onda periodica:
  y.el = reactiveVal(NULL)
  applicazioneMM = function(y, selStagS, order, wts){
    n = 60
    y.mm = wma(y, order = order, wts = wts, centre = T, plot = F)
    # modello additivo:
    IS = y - y.mm
    rst = rep(NA, selStagS - (n %% selStagS))
    IS.mat = matrix(c(IS, rst), ncol = selStagS, byrow=T)
    CG = rep(0, selStagS)
    for (i in 1:selStagS) CG[i] = mean(IS.mat[,i], na.rm=T)
    CGm = mean(CG)
    CI = CG - mean(CG)
    CIm = mean(CI)
    CI.vet = rep(CI, 20)[1:n]
    y.d = y - CI.vet
    # modello moltiplicativo:
    IS2 = y / y.mm
    rst2 = rep(NA, selStagS - (n %% selStagS))
    IS.mat2 = matrix(c(IS2, rst2), ncol = selStagS, byrow=T)
    CG2 = rep(0, selStagS)
    for (i in 1:selStagS) CG2[i] = mean(IS.mat2[,i], na.rm=T)
    CG2m = prod(CG2)^(1/selStagS)
    CI2 = CG2 / prod(CG2)^(1/selStagS)
    CI2m = prod(CI2)^(1/selStagS)
    CI.vet2 = rep(CI2, 20)[1:n]
    y.d2 = y / CI.vet2
    return(list(n = n, y.mm = y.mm, IS = IS, CG = CG, CGm = CGm, CI.vet = CI.vet, CIm = CIm,
                IS2 = IS2, CG2 = CG2, CG2m = CG2m, CI.vet2 = CI.vet2, CI2m = CI2m, y.d = y.d, y.d2 = y.d2))
  }
  observe({
    n = 60
    stag = rep(runif(3, min = 1, max = 40), n/3)
    noise = rnorm(n, mean = 0, sd = 0.1*sd(stag))
    y.el(stag + noise)
    output$plotDest = renderDygraph({
      y1 = data.frame(time = seq_len(n), value = y.el())
      dygraph(y1, main = "Serie storica") %>%
        dySeries("value", label = "Serie") %>%
        dyOptions(colors = "black") %>%
        dyRangeSelector(height = 20)
    })
    output$plotSpec = renderDygraph({
      emp = data.frame(time = seq_len(n), value = rep(NA, n))
      dygraph(emp, main = "Coeff specifici")
      
    })
    output$plotGrezzi = renderDygraph({
      emp = data.frame(time = seq_len(n), value = rep(NA, n))
      dygraph(emp, main = "Coeff grezzi")
    })
    output$plotIdeali = renderDygraph({
      emp = data.frame(time = seq_len(n), value = rep(NA, n))
      dygraph(emp, main = "Coeff Ideali")
    })
  })
  observeEvent(input$generateStagS, {
    n = 60
    stag = rep(runif(input$selStagS, min = 1, max = 40), 20)[1:60]
    noise = rnorm(n, mean = 0, sd = input$sdStagS*sd(stag))
    y.el(stag + noise)
    output$plotDest = renderDygraph({
      y1 = data.frame(time = seq_len(n), value = y.el())
      dygraph(y1, main = "Serie storica") %>%
        dySeries("value", label = "Serie") %>%
        dyOptions(colors = "black") %>%
        dyRangeSelector(height = 20)
    })
    output$plotSpec = renderDygraph({
      emp = data.frame(time = seq_len(n), value = rep(NA, n))
      dygraph(emp, main = "Coeff specifici")
      
    })
    output$plotGrezzi = renderDygraph({
      emp = data.frame(time = seq_len(n), value = rep(NA, n))
      dygraph(emp, main = "Coeff grezzi")
    })
    output$plotIdeali = renderDygraph({
      emp = data.frame(time = seq_len(n), value = rep(NA, n))
      dygraph(emp, main = "Coeff Ideali")
    })
  })
  observeEvent(input$updateStagS, {
    if (input$wtsStagS == "") {
      wts = rep(1/input$orderStagS, input$orderStagS)
    } else {
      wts.str = unlist(strsplit(input$wtsStagS, ","))
      wts = sapply(wts.str, function(x) eval(parse(text = x)))
      if (length(wts) != input$orderStagS) {
        showModal(
          modalDialog(
            title = "Errore",
            "Il numero di pesi deve coincidere con l'ordine della media mobile!"
          )
        )
        return()
      }
    }
    n = 60
    ress = applicazioneMM(y.el(), input$selStagS, input$orderStagS, wts)
    selModelS = switch(input$selModelS,
                       "Additivo" = ress$y.d,
                       "Moltiplicativo" = ress$y.d2)
    output$plotDest = renderDygraph({
      y.mm1 = data.frame(time = seq_len(n), value = cbind(y.el(), selModelS))
      dygraph(y.mm1, main = "Serie storica") %>%
        dySeries("value.V1", label = "Serie") %>%
        dySeries("value.selModelS", label = "Serie dest.") %>%
        dyOptions(colors = c("grey", "purple")) %>%
        dyRangeSelector(height = 20)
    })
    selISS = switch(input$selModelS,
                    "Additivo" = ress$IS,
                    "Moltiplicativo" = ress$IS2)
    output$plotSpec = renderDygraph({
      yIS = data.frame(time = seq_len(n), value = selISS)
      dygraph(yIS, main = "Coeff. specifici") %>%
        dySeries("value", label = "Coeff. spec") %>%
        dyOptions(colors = "red") %>%
        dyRangeSelector(height = 20)
    })
    selCGS = switch(input$selModelS,
                    "Additivo" = ress$CG,
                    "Moltiplicativo" = ress$CG2)
    selCGmS = switch(input$selModelS,
                     "Additivo" = ress$CGm,
                     "Moltiplicativo" = ress$CG2m)
    output$plotGrezzi = renderDygraph({
      yCG = data.frame(time = seq_len(n), value = cbind(rep(selCGS, 20)[1:60], rep(round(selCGmS, 2), 60)))
      dygraph(yCG, main = "Coeff. grezzi") %>%
        dySeries("value.1", label = "Coeff. grezzi") %>%
        dySeries("value.2", label = "mean", strokePattern = "dashed") %>%
        dyOptions(colors = c("blue", "black")) %>%
        dyHighlight(highlightSeriesBackgroundAlpha = 0.4) %>%
        dyRangeSelector(height = 20)
    })
    selCIS = switch(input$selModelS,
                    "Additivo" = ress$CI.vet,
                    "Moltiplicativo" = ress$CI.vet2)
    selCImS = switch(input$selModelS,
                     "Additivo" = ress$CIm,
                     "Moltiplicativo" = ress$CI2m)
    output$plotIdeali = renderDygraph({
      yCI = data.frame(time = seq_len(n), value = cbind(selCIS, rep(round(selCImS, 2), 60)))
      dygraph(yCI, main = "Coeff. ideali") %>%
        dySeries("value.selCIS", label = "Coeff. ideali") %>%
        dySeries("value.V2", label = "mean", strokePattern = "dashed") %>%
        dyOptions(colors = c("green", "black")) %>%
        dyHighlight(highlightSeriesBackgroundAlpha = 0.4) %>%
        dyRangeSelector(height = 20)
    })
  })
  observeEvent(input$orderStagS, {
    updateTextInput(session, "wtsStagS", value = paste(fractions(rep(1/input$orderStagS, input$orderStagS)), collapse = ", "))
  })
  observeEvent(input$centerStagS, {
    if (input$orderStagS %% 2 == 1) {
      p = input$orderStagS - 1
      updateTextInput(session, "wtsStagS", value = paste(fractions(c(1/(2*p), rep(1/p, p-1), 1/(2*p))), collapse = ", "))
    } else {
      showModal(
        modalDialog(
          title = "Errore",
          "L'ordine della media mobile deve essere dispari!"
        )
      )
      return()
    }
  })
}

# Run the app
shinyApp(ui=ui, server=server)