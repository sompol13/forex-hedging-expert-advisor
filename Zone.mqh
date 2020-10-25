//+------------------------------------------------------------------+
//|                                                          Rod.mqh |
//|                       Copyright 2020, Sompol Techawattanalertkij |
//|                      https://github.com/sompol13/expert-advisors |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Sompol Techawattanalertkij"
#property link      "https://github.com/sompol13/expert-advisors"
#property version   "1.00"
#property strict

/**
 * Rod class represent the trading order.
 */
class Zone {
   
   // The public attributes.
   public:
      int mMagic;
      
      // The default constructure method.
      Zone() {
      }
      
      // The parametric constructure method.
      Zone(int magic) {
         mMagic = magic;
      }
};