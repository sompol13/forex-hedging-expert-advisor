/**
 * CloseSystem.mq5
 * Copyright 2020, Sompol Techawattanalertkij
 * https://github.com/sompol13/close-system
 */
#property copyright "Copyright 2020, Sompol Techawattanalertkij"
#property link "https://github.com/sompol13/expert-advisor-template"
#property version "1.0"
#property strict

input int frequencyOfTimer = 15; // Determine the frequency of timer event occurrence (seconds).
input double ceilingPrice = 0.81501; // The ceiling price of the zone to be play (significance).
input double middlePrice = 0.74497; // The middle price of the zone to be play (significance).
input double floorPrice = 0.66380; // The floor price of the zone to be play (significance).

/**
 * The function is called in indicators and EAs when the Init event occurs. 
 * It is used to initialize a running MQL5 program.
 */
int OnInit() {
   // Create a timer from input.
   EventSetTimer(frequencyOfTimer);
   // The EA success initialized.
   return(INIT_SUCCEEDED);
}

/**
 * The OnTimer() function is called when the timer event occurs.
 */
void OnTimer() {
   Print("OnTimer event occurs.");
}

/**
 * The function is called in indicators and EAs when the Deinit event occurs.
 * It is used to deinitialize a running MQL5 program.
 */
void OnDeinit(const int reason) {
   // Terminal the OnInit timer.
   EventKillTimer();
}