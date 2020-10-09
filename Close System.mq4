//+------------------------------------------------------------------+
//|                                                          Rod.mqh |
//|                       Copyright 2020, Sompol Techawattanalertkij |
//|                      https://github.com/sompol13/expert-advisors |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Sompol Techawattanalertkij"
#property link      "https://github.com/sompol13/expert-advisors"
#property version   "1.00"
#property strict

input int frequencyOfTimer = 15;       // Determine the frequency of timer event occurrence (seconds).
input int takeProfitPoint = 400;       // The number of target points for each rod (points).
input double ceilingPrice = 0.81501;   // The ceiling price of the zone to be play (significance).
input double middlePrice = 0.74497;    // The middle price of the zone to be play (significance).
input double floorPrice = 0.66380;     // The floor price of the zone to be play (significance).  
input bool isDrawShortOrder = false;   // Put virtual long order horizontal line on current graph.
input bool isDrawLongOrder = true;     // Put virtual short order horizontal line on current graph.
input bool allowHedgingShort = false;  // Enable hedging that open short order at the same prices.
input bool allowShortBottom = false;   // Keep open short hedging even price is below middle price. 

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