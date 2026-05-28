# Laboratorio di Serie Storiche con R: L'Approccio Classico

## Descrizione del Progetto
* [cite_start]Questo progetto consiste in un'applicazione interattiva sviluppata per supportare lo studio delle serie storiche mediante l'approccio classico[cite: 78].
* [cite_start]L'obiettivo principale è facilitare la comprensione dell'analisi delle serie storiche, rendendo i concetti più accessibili e intuitivi rispetto a uno studio puramente teorico[cite: 82, 93].
* [cite_start]L'applicativo consente agli utenti di interagire con i dati attraverso vari widget (come slider e menù a tendina), aggiornando in tempo reale grafici e tabelle[cite: 79, 81].

---

## Struttura dell'Applicazione
[cite_start]L'applicazione è suddivisa in tre sezioni principali, che riflettono i capitoli trattati nel lavoro di tesi[cite: 87, 102, 105]:

### 1. Stima del Trend mediante Funzioni Matematiche
* [cite_start]**Criteri di scelta del grado del polinomio:** Permette di generare serie con trend polinomiali e valutare in modo congiunto i criteri per la scelta del grado (differenze successive, R^2 corretto, significatività delle stime)[cite: 116, 118, 122, 128].
* [cite_start]**Cambi strutturali:** Analizza la stima di trend in presenza di uno o più cambi strutturali, confrontando l'efficacia di modelli semplici con modelli più complessi basati su variabili dummy[cite: 169, 171, 177, 178].
* [cite_start]**Trend esponenziale:** Confronta i vantaggi e gli svantaggi del modello moltiplicativo (linearizzabile ma con possibili stime distorte) e del modello additivo (non lineare ma spesso più preciso) per fenomeni a rapida crescita[cite: 206, 212, 214, 217, 250].

### 2. Stima della Stagionalità mediante Funzioni Matematiche
* [cite_start]**Variabili dummy:** Illustra come stimare la componente stagionale di una serie storica supponendo che il processo generatore sia composto da una funzione periodica e da una componente residua[cite: 257, 260].
* [cite_start]**Coefficienti di stagionalità:** Mostra la differenza matematica e visiva tra i "coefficienti grezzi" e i "coefficienti ideali", i quali sono necessari per destagionalizzare correttamente la serie ottenendone gli scarti dalla media[cite: 263, 264, 270].

### 3. Le Medie Mobili
* [cite_start]**Effetto di Slutsky-Yule:** Esplora la riduzione della componente erratica (azione spianante) tramite le medie mobili e l'introduzione di oscillazioni spurie dovute alla correlazione delle componenti (Effetto Slutsky-Yule)[cite: 304, 307, 309].
* [cite_start]**Conservazione del trend:** Permette di testare varie medie mobili (centrate o semplici) per verificare le condizioni necessarie alla conservazione matematica di trend costanti, lineari o quadratici[cite: 358, 361, 363, 364].
* [cite_start]**Eliminazione di un'onda periodica:** Mostra il processo completo per depurare la serie dalla stagionalità mettendo in evidenza l'andamento tendenziale, passando per il calcolo di indici specifici, coefficienti grezzi e coefficienti ideali[cite: 438, 439, 442, 443, 444, 446].

---

## Tecnologie Utilizzate
* [cite_start]**Linguaggio:** R [cite: 73]
* [cite_start]**Libreria:** Shiny (scelta per la realizzazione di interfacce utente interattive e la facilità di distribuzione sia in locale che su server remoti)[cite: 79, 95, 97].

---

## Autore e Riferimenti Accademici
* [cite_start]**Autore:** Federico Perina (Matricola N° 2014183) [cite: 76]
* [cite_start]**Relatore:** Prof. Francesco Lisi [cite: 74]
* [cite_start]**Istituzione:** Università degli Studi di Padova, Dipartimento di Scienze Statistiche - Corso di Laurea Triennale in Statistica per l'Economia e l'Impresa[cite: 65, 66].
* [cite_start]**Anno Accademico:** 2023/2024 [cite: 75]
