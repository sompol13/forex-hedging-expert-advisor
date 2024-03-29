//+------------------------------------------------------------------+
//|                                                      Mushrom.mqh |
//|                       Copyright 2020, Sompol Techawattanalertkij |
//|                      https://github.com/sompol13/expert-advisors |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Sompol Techawattanalertkij"
#property link      "https://github.com/sompol13/expert-advisors"
#property version   "1.00"
#property strict

input int frequencyOfTimer = 5;           // Determine the frequency of timer event occurrence (seconds).
input int takeProfitInteger = 450;        // The take profit points target for each zone (points).
input double defaultLotSize = 0.01;       // The default price or lot size for each orders (double).
input double ceilingPrice = 0.78052;      // The ceiling price of the zone to be play (significance).
input double middlePrice = 0.72273;       // The middle price of the zone to be play (significance).
input double floorPrice = 0.64290;        // The floor price of the zone to be play (significance).

// TODO: Try long-below & short-top.
// TODO: Avoid OrderSend too close 130.

int recentOrdersTotal = -1;
double takeProfitPoint = takeProfitInteger * Point;

/**
 * This function is called in indicators and EAs when the Init event occurs. 
 * It is used to initialize a running MQL5 program.
 */
int OnInit () {
   // Create a timer from input.
   EventSetTimer(frequencyOfTimer);
   // The EA success initialized.
   return (INIT_SUCCEEDED);
}

/**
 * A Custom function for select order by open price.
 */
bool selectOrderByOpenPrice (double normalizedZonePrice, string operation) {

   // Loop through open and pending orders.
   for (int i = 0; i < OrdersTotal(); i++) {
   
      // Skip loop if cannot select the order.
      if (!OrderSelect(i, SELECT_BY_POS)) {
         Print("An error occurs during selecting order #" + GetLastError());
      }
      
      // Skip loop if not match order currency pair.
      if (OrderSymbol() != Symbol()) continue;
      
      // Skip loop if not match order operation to find the opposite direction order.
      if (operation == "long") {
         if (OrderType() != OP_BUY
            && OrderType() != OP_BUYLIMIT 
            && OrderType() != OP_BUYSTOP) {
            continue;
         }
      } else if (operation == "short") {
         if (OrderType() != OP_SELL
            && OrderType() != OP_SELLLIMIT 
            && OrderType() != OP_SELLSTOP) {
            continue;
         }
      }
     
      Print(normalizedZonePrice == OrderOpenPrice());
      
      // Is any order open match zone price?
      if (normalizedZonePrice == OrderOpenPrice()) return true;
   }
   
   // The order was not found.
   return false;
}

/**
 * This function is called in EAs when the NewTick event occurs to handle a new quote.
 */
void OnTick () {
   
   // Avoid the work if amount of orders doesn't changes.
   if (OrdersTotal() == recentOrdersTotal) return;
   
   // Loop for defining variables of each zone.
   for (double zonePrice = ceilingPrice; zonePrice >= floorPrice; zonePrice -= takeProfitPoint) {
      
      // Define the variables that represent zone.
      double averageCurrentPrice = (Ask + Bid) / 2;
      double normalizedZonePrice = NormalizeDouble(zonePrice, Digits);
      bool isFirstZone = zonePrice == ceilingPrice;
      bool isLastZone = zonePrice - takeProfitPoint < floorPrice;
      double longTakePoint = NormalizeDouble(zonePrice + takeProfitPoint, Digits);
      double shortTakePoint = NormalizeDouble(zonePrice - takeProfitPoint, Digits);
      
      // Focusing on zone that close to current price.
      if (averageCurrentPrice < shortTakePoint || averageCurrentPrice > longTakePoint) continue;
      
      // Find the open or pending order by zone price (long).
      bool foundLongOrder = selectOrderByOpenPrice(normalizedZonePrice, "long");
       
      // Create a zone if not exists (long).
      if (!foundLongOrder) {
         if (Ask < normalizedZonePrice) {
             if (!OrderSend(Symbol(), OP_BUYSTOP, defaultLotSize, zonePrice, 3, 0.0, longTakePoint, NULL, 0, 0, clrBlue)) {
               Print("An error occurs during sending order #", GetLastError());
             }
         } else if (Ask > normalizedZonePrice) {
             if (!OrderSend(Symbol(), OP_BUYLIMIT, defaultLotSize, zonePrice, 3, 0.0, longTakePoint, NULL, 0, 0, clrBlue)) {
               Print("An error occurs during sending order #", GetLastError());
             }
         }
      }     
      
      // Find the open or pending order by zone price (short).
      bool foundShortOrder = selectOrderByOpenPrice(normalizedZonePrice, "short");
      
      // Create a zone if not exists (short).
      if (!foundShortOrder) {
         if (Bid > normalizedZonePrice) {
             if (!OrderSend(Symbol(), OP_SELLSTOP, defaultLotSize, zonePrice, 3, 0.0, shortTakePoint, NULL, 0, 0, clrRed)) {
               Print("An error occurs during sending order #", GetLastError());
             }
         } else if (Bid < normalizedZonePrice) {
             if (!OrderSend(Symbol(), OP_SELLLIMIT, defaultLotSize, zonePrice, 3, 0.0, shortTakePoint, NULL, 0, 0, clrRed)) {
               Print("An error occurs during sending order #", GetLastError());
             }
         }
      }
   }
   
   // Update last change orders total.
   recentOrdersTotal = OrdersTotal();
}

/**
 * This OnTimer() function is called when the timer event occurs.
 */
void OnTimer () {
}

/**
 * This function is called in indicators and EAs when the Deinit event occurs.
 * It is used to deinitialize a running MQL5 program.
 */
void OnDeinit (const int reason) {
   // Terminal the OnInit timer.
   EventKillTimer();
}