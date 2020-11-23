/**
 * What is the difference each trailing methods?
 *   - Classic is moving by 1 point.
 *   - Distance is keep distance to price.
 *   - Stepping is moving by step point.
 */
#property strict

string STR_OPTYPE[] = {
   "Buy",
   "Sell",
   "Buy Limit",
   "Sell Limit",
   "Buy Stop",
   "Sell Stop"
};

enum ENUM_CHARTSYMBOL {
   CurrentChartSymbol = 0,       // Chart
   AllOpenOrder = 1,             // Porfolio
};

enum ENUM_SLTP_MODE {
   Server = 0,                   // Show
   Client = 1,                   // Hide
};

enum ENUM_LOCKPROFIT_ENABLE {
   LP_DISABLE = 0,               // Disable
   LP_ENABLE = 1,                // Enable
};
  
enum ENUM_TRAILINGSTOP_METHOD {
   TS_NONE = 0,                  // Disable
   TS_CLASSIC = 1,               // Classic
   TS_STEP_DISTANCE = 2,         // Distance
   TS_STEP_BY_STEP = 3,          // Stepping
};

input int TakeProfit = 0;                                               // Take Profit
input int StopLoss = 300;                                               // Stop Loss
input ENUM_SLTP_MODE SLnTPMode = Server;                                // Stop Line

input ENUM_LOCKPROFIT_ENABLE LockProfitEnable = LP_DISABLE;             // Profit Lock
input int LockProfitAfter = 0;                                          // Trigger Point
input int ProfitLock = 0;                                               // Lock Point

input ENUM_TRAILINGSTOP_METHOD TrailingStopMethod = TS_NONE;            // Trailing Stop
input int TrailingStop = 50;                                           // Trigger Point
input int TrailingStep = 10;                                            // Step Point

input ENUM_CHARTSYMBOL ChartSymbolSelection = CurrentChartSymbol;       // Control
input bool inpEnableAlert = false;                                      // Alert

int GetOrders() {
   int buys = 0, sells = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (!OrderSelect(i, SELECT_BY_POS,MODE_TRADES)) break;
      if (ChartSymbolSelection == CurrentChartSymbol && OrderSymbol() != Symbol()) continue;
      if (OrderType() == OP_BUY) buys++;
      if (OrderType() == OP_SELL) sells++;
   }
   if (buys > 0) {
      return(buys);
   } else { 
      return(-sells);
   }
}
  
bool LockProfit (int TiketOrder, int TargetPoints, int LockedPoints) {
  if (LockProfitEnable == False || TargetPoints == 0 || LockedPoints == 0) return false;
  if (OrderSelect(TiketOrder, SELECT_BY_TICKET, MODE_TRADES) == false) return false;

  double CurrentSL = (OrderStopLoss() != 0) ? OrderStopLoss() : OrderOpenPrice();
  double point = MarketInfo(OrderSymbol(), MODE_POINT);
  int digits = (int) MarketInfo(OrderSymbol(), MODE_DIGITS);
  double minstoplevel = MarketInfo(OrderSymbol(), MODE_STOPLEVEL);
  double ask = MarketInfo(OrderSymbol(), MODE_ASK);
  double bid = MarketInfo(OrderSymbol(), MODE_BID);
  double PSL = 0;

  if ((OrderType() == OP_BUY) && (bid - OrderOpenPrice() >= TargetPoints * point) && (CurrentSL <= OrderOpenPrice())) {
    PSL = NormalizeDouble(OrderOpenPrice() + (LockedPoints * point), digits);
  } else if ((OrderType() == OP_SELL) && (OrderOpenPrice() - ask >= TargetPoints * point) && (CurrentSL >= OrderOpenPrice())) {
    PSL = NormalizeDouble(OrderOpenPrice() - (LockedPoints * point), digits);
  } else {
    return false;
  }

  Print(STR_OPTYPE[OrderType()], " #", OrderTicket(), " ProfitLock: OP=", OrderOpenPrice(), " CSL=", CurrentSL, " PSL=", PSL, " LP=", LockedPoints);

  if (OrderModify(OrderTicket(), OrderOpenPrice(), PSL, OrderTakeProfit(), 0, clrRed)) {
    return true;
  } else {
    return false;
  }
  return false;
}

// TODO: Continue refactor code here.
bool RZ_TrailingStop(int TiketOrder,int JumlahPoin,int Step=1,ENUM_TRAILINGSTOP_METHOD Method=TS_STEP_DISTANCE) {
   if (JumlahPoin==0) return false;

   if (OrderSelect(TiketOrder,SELECT_BY_TICKET,MODE_TRADES)==false) return false;

   double CurrentSL=(OrderStopLoss()!=0)?OrderStopLoss():OrderOpenPrice();
   double point=MarketInfo(OrderSymbol(),MODE_POINT);
   int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);
   double minstoplevel=MarketInfo(OrderSymbol(),MODE_STOPLEVEL);
   double ask=MarketInfo(OrderSymbol(),MODE_ASK);
   double bid=MarketInfo(OrderSymbol(),MODE_BID);
   double TSL=0;

   JumlahPoin=JumlahPoin+(int)minstoplevel;

   if ((OrderType()==OP_BUY) && (bid-OrderOpenPrice()>JumlahPoin*point))
     {
      if (CurrentSL<OrderOpenPrice())
         CurrentSL=OrderOpenPrice();

      if ((bid-CurrentSL)>=JumlahPoin*point)
        {
         switch(Method)
           {
            case TS_CLASSIC: // Classic, no step
               TSL=NormalizeDouble(bid-(JumlahPoin*point),digits);
               break;
            case TS_STEP_DISTANCE: // Step keeping distance
               TSL=NormalizeDouble(bid-((JumlahPoin-Step)*point),digits);
               break;
            case TS_STEP_BY_STEP: // Step by step (slow)
               TSL=NormalizeDouble(CurrentSL+(Step*point),digits);
               break;
            default:
               TSL=0;
           }
        }
     }

   else if ((OrderType()==OP_SELL) && (OrderOpenPrice()-ask>JumlahPoin*point))
     {
      if (CurrentSL>OrderOpenPrice())
         CurrentSL=OrderOpenPrice();

      if ((CurrentSL-ask)>=JumlahPoin*point)
        {
         switch(Method)
           {
            case TS_CLASSIC://Classic
               TSL=NormalizeDouble(ask+(JumlahPoin*point),digits);
               break;
            case TS_STEP_DISTANCE://Step keeping distance
               TSL=NormalizeDouble(ask+((JumlahPoin-Step)*point),digits);
               break;
            case TS_STEP_BY_STEP://Step by step (slow)
               TSL=NormalizeDouble(CurrentSL-(Step*point),digits);
               break;
            default:
               TSL=0;
           }
        }
     }

   if (TSL==0)
      return false;

   Print(STR_OPTYPE[OrderType()]," #",OrderTicket()," TrailingStop: OP=",OrderOpenPrice()," CSL=",CurrentSL," TSL=",TSL," TS=",JumlahPoin," Step=",Step);
   bool res=OrderModify(OrderTicket(),OrderOpenPrice(),TSL,OrderTakeProfit(),0,clrRed);
   if (res == true) return true;
   else return false;

   return false;
}
  
bool Execute() {
   double SL,TP;
   SL=TP=0.00;

   for(int i=0;i<OrdersTotal();i++)
     {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if (ChartSymbolSelection==CurrentChartSymbol && OrderSymbol()!=Symbol()) continue;

      double point=MarketInfo(OrderSymbol(),MODE_POINT);
      double minstoplevel=MarketInfo(OrderSymbol(),MODE_STOPLEVEL);
      double ask=MarketInfo(OrderSymbol(),MODE_ASK);
      double bid=MarketInfo(OrderSymbol(),MODE_BID);
      int digits=(int)MarketInfo(OrderSymbol(),MODE_DIGITS);

      //Print("Check SL & TP : ",OrderSymbol()," SL = ",OrderStopLoss()," TP = ",OrderTakeProfit());

      double ClosePrice=0;
      int Points=0;
      color CloseColor=clrNONE;

      //Get Points
      if (OrderType()==OP_BUY)
        {
         CloseColor=clrBlue;
         ClosePrice=bid;
         Points=(int)((ClosePrice-OrderOpenPrice())/point);
        }
      else if (OrderType()==OP_SELL)
        {
         CloseColor=clrRed;
         ClosePrice=ask;
         Points=(int)((OrderOpenPrice()-ClosePrice)/point);
        }

      //Set Server SL and TP
      if (SLnTPMode==Server)
        {
         if (OrderType()==OP_BUY)
           {
            SL=(StopLoss>0)?NormalizeDouble(OrderOpenPrice()-((StopLoss+minstoplevel)*point),digits):0;
            TP=(TakeProfit>0)?NormalizeDouble(OrderOpenPrice()+((TakeProfit+minstoplevel)*point),digits):0;
           }
         else if (OrderType()==OP_SELL)
           {
            SL=(StopLoss>0)?NormalizeDouble(OrderOpenPrice()+((StopLoss+minstoplevel)*point),digits):0;
            TP=(TakeProfit>0)?NormalizeDouble(OrderOpenPrice()-((TakeProfit+minstoplevel)*point),digits):0;
           }

         if (OrderStopLoss()==0.0 && OrderTakeProfit()==0.0)
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,Blue);
         else if (OrderTakeProfit()==0.0)
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TP,0,Blue);
         else if (OrderStopLoss()==0.0)
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),SL,OrderTakeProfit(),0,Red);
        }
      //Hidden SL and TP
      else if (SLnTPMode==Client)
        {
         if ((TakeProfit>0 && Points>=TakeProfit) || (StopLoss>0 && Points<=-StopLoss))
           {
            if (OrderClose(OrderTicket(),OrderLots(),ClosePrice,3,CloseColor))
              {
               if (inpEnableAlert)
                 {
                  if (OrderProfit()>0)
                     Alert("Closed by Virtual TP #",OrderTicket()," Profit=",OrderProfit()," Points=",Points);
                  if (OrderProfit()<0)
                     Alert("Closed by Virtual SL #",OrderTicket()," Loss=",OrderProfit()," Points=",Points);
                 }
              }
           }
        }

      if (LockProfitAfter>0 && ProfitLock>0 && Points>=LockProfitAfter)
        {
         if (Points<=LockProfitAfter+TrailingStop)
           {
            LockProfit(OrderTicket(),LockProfitAfter,ProfitLock);
           }
         else if (Points>=LockProfitAfter+TrailingStop)
           {
            RZ_TrailingStop(OrderTicket(),TrailingStop,TrailingStep,TrailingStopMethod);
           }
        }
      else if (LockProfitAfter==0)
        {
         RZ_TrailingStop(OrderTicket(),TrailingStop,TrailingStep,TrailingStopMethod);
        }

     }

   return false;

}
  
void OnInit() {
}
  
void OnTick() {
  if (Bars<100 || !IsTradeAllowed()) return;
  if (GetOrders() != 0) Execute();
}