/**
 * CloseSystem.mq5
 * Copyright 2020, Sompol Techawattanalertkij
 * https://github.com/sompol13/close-system
 */
#property copyright "Copyright 2020, Sompol Techawattanalertkij"
#property link "https://github.com/sompol13/expert-advisor-template"
#property version "1.0"

/**
 * The function is called in indicators and EAs when the Init event occurs. 
 * It is used to initialize a running MQL5 program.
 */
int OnInit() {
   // Set timer every minutes.
   EventSetTimer(60);
   // The EA success initialized.
   return(INIT_SUCCEEDED);
}

/**
 * The function is called in indicators and EAs when the Deinit event occurs.
 * It is used to deinitialize a running MQL5 program.
 */
void OnDeinit(const int reason) {
   // Release the OnInit timer.
   EventKillTimer();
}

/**
 * The OnTimer() function is called when the Timer event occurs.
 */
void OnTimer() {
   Print("OnTimer event occurs.");
}