# Laboratorio di Serie Storiche con R: L'Approccio Classico

## Descrizione del Progetto
* Questo progetto consiste in un'applicazione interattiva sviluppata per supportare lo studio delle serie storiche mediante l'approccio classico.
* L'obiettivo principale è facilitare la comprensione dell'analisi delle serie storiche, rendendo i concetti più accessibili e intuitivi rispetto a uno studio puramente teorico.
* L'applicativo consente agli utenti di interagire con i dati attraverso vari widget (come slider e menù a tendina), aggiornando in tempo reale grafici e tabelle.

---

## Struttura dell'Applicazione
L'applicazione è suddivisa in tre sezioni principali, che riflettono i capitoli trattati nel lavoro di tesi:

### 1. Stima del Trend mediante Funzioni Matematiche
* **Criteri di scelta del grado del polinomio:** Permette di generare serie con trend polinomiali e valutare in modo congiunto i criteri per la scelta del grado (differenze successive, R^2 corretto, significatività delle stime).
* **Cambi strutturali:** Analizza la stima di trend in presenza di uno o più cambi strutturali, confrontando l'efficacia di modelli semplici con modelli più complessi basati su variabili dummy.
* **Trend esponenziale:** Confronta i vantaggi e gli svantaggi del modello moltiplicativo (linearizzabile ma con possibili stime distorte) e del modello additivo (non lineare ma spesso più preciso) per fenomeni a rapida crescita.

### 2. Stima della Stagionalità mediante Funzioni Matematiche
* **Variabili dummy:** Illustra come stimare la componente stagionale di una serie storica supponendo che il processo generatore sia composto da una funzione periodica e da una componente residua.
* **Coefficienti di stagionalità:** Mostra la differenza matematica e visiva tra i "coefficienti grezzi" e i "coefficienti ideali", i quali sono necessari per destagionalizzare correttamente la serie ottenendone gli scarti dalla media.

### 3. Le Medie Mobili
* **Effetto di Slutsky-Yule:** Esplora la riduzione della componente erratica (azione spianante) tramite le medie mobili e l'introduzione di oscillazioni spurie dovute alla correlazione delle componenti (Effetto Slutsky-Yule).
* **Conservazione del trend:** Permette di testare varie medie mobili (centrate o semplici) per verificare le condizioni necessarie alla conservazione matematica di trend costanti, lineari o quadratici.
* **Eliminazione di un'onda periodica:** Mostra il processo completo per depurare la serie dalla stagionalità mettendo in evidenza l'andamento tendenziale, passando per il calcolo di indici specifici, coefficienti grezzi e coefficienti ideali.

---

## Tecnologie Utilizzate
* **Linguaggio:** R 
* **Libreria:** Shiny (scelta per la realizzazione di interfacce utente interattive e la facilità di distribuzione sia in locale che su server remoti).

---

## Autore e Riferimenti Accademici
* **Autore:** Federico Perina (Matricola N° 2014183) 
* **Relatore:** Prof. Francesco Lisi 
* **Istituzione:** Università degli Studi di Padova, Dipartimento di Scienze Statistiche - Corso di Laurea Triennale in Statistica per l'Economia e l'Impresa.
* **Anno Accademico:** 2023/2024 
