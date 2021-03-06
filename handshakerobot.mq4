//+------------------------------------------------------------------+
//|                                               HandshakeRobot.mq4 |
//|                                            Evgeniy Samarin, 2022 |
//|                                      https://github.com/Rockkley |
//+------------------------------------------------------------------+
#property copyright "Evgeniy Samarin, 2022"
#property link      "https://github.com/Rockkley"
#property version   "1.00"
#property strict


extern double risk = 10;
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason){}

void OnTick()
  {  
   double rsiFast = iRSI(_Symbol,_Period,7,PRICE_CLOSE,1);
   double rsiSlow = iRSI(_Symbol,_Period,21,PRICE_CLOSE,1);
   double dClose  = iClose(_Symbol,PERIOD_D1,1);
   double dOpen   = iOpen(_Symbol,PERIOD_D1,1);     
   double atr     = iATR(_Symbol,_Period,14,0)*3/_Point; 
   double bulls   = iBullsPower(_Symbol,_Period,14,PRICE_CLOSE,1);
   double bears   = iBearsPower(_Symbol,_Period,14,PRICE_CLOSE,1);
   double mafast  = iMA(_Symbol,_Period,50,0,MODE_SMA,PRICE_CLOSE,1);
   double maslow  = iMA(_Symbol,_Period,200,0,MODE_SMA,PRICE_CLOSE,1);
   
   if(OrderCount(OP_BUY)==0) 
   {
      if(rsiFast<50&&rsiSlow<50&&(dClose-dOpen>0||Close[1]-Open[1]>50)&&Hour()>9&&Hour()<17&&bulls>0&&mafast>maslow)
      {
         if (OrderSend(_Symbol,OP_BUY,LotSize(),Ask,50, NormalizeDouble(Ask-atr*2*_Point,_Digits), 
          NormalizeDouble(Ask+atr*4*_Point,_Digits),NULL,0,0,Green)>-1) 
          {
          Print("Открыта покупка");
          }
           else Print("Ошибка открытия покупки ");
      }}
      if(OrderCount(OP_SELL)==0) {
      if(rsiFast>50&&rsiSlow>50&&(dClose-dOpen<0||Close[1]-Open[1]<50)&&Hour()>9&&Hour()<17&&bears>0&&mafast<maslow)
      {
         if (OrderSend(_Symbol,OP_SELL,LotSize(),Bid,50,NormalizeDouble(Bid+atr*2*_Point,_Digits), 
            NormalizeDouble(Bid-atr*4*_Point,_Digits),NULL, 0,0,Red) >-1) 
          {
          Print("Открыта продажа");
          }
           else Print("Ошибка открытия продажи");
      }
   }
   if(OrdersTotal() != 0 )  
   
   {     OrderSelect( ( OrdersTotal() -1 ), SELECT_BY_POS, MODE_TRADES); 
   
      if(OrderType() == OP_BUY && Bid-OrderOpenPrice() > (OrderOpenPrice()-OrderStopLoss())/2 && OrderLots()==LotSize())
         {Print("ПОПЫТКА закрыть 1/4 часть покупки");
         OrderClose(OrderTicket(),LotSize()/4,Bid,10,Green);}
         
       if(OrderType() == OP_SELL && OrderOpenPrice()-Bid > (OrderStopLoss()-OrderOpenPrice())/2 && OrderLots()==LotSize())
         {Print("ПОПЫТКА закрыть 1/4 часть продажи");  
         OrderClose(OrderTicket(),LotSize()/4,Ask,10,Green);}
         
       if(OrderType() == OP_BUY && rsiSlow>70 && rsiFast>70 && Bid-OrderOpenPrice() > (OrderOpenPrice()-OrderStopLoss())/2 && OrderLots()==LotSize()/4)
         {Print("ПОПЫТКА закрыть 1/6 часть покупки"); 
         OrderClose(OrderTicket(),LotSize()/6,Bid,10,Green);}
         
       if(OrderType() == OP_SELL && rsiSlow<30 && rsiFast<30 && OrderOpenPrice()-Bid > (OrderStopLoss()-OrderOpenPrice())/2 && OrderLots()==LotSize()/4)
         {Print("ПОПЫТКА закрыть 1/6 часть продажи"); 
         OrderClose(OrderTicket(),LotSize()/6,Ask,10,Green);}
         
       if(OrderType() == OP_BUY && Bid-OrderOpenPrice() > OrderOpenPrice()-OrderStopLoss())
         {Print("ПОПЫТКА ПЕРЕНЕСТИ СТОП ПОКУПКИ при достижении профита в размере стоп-лосса");
         OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Red);}
         
       if(OrderType() == OP_SELL && OrderOpenPrice()-Bid > OrderStopLoss()-OrderOpenPrice())
         {Print("ПОПЫТКА ПЕРЕНЕСТИ СТОП ПРОДАЖИ при достижении профита в размере стоп-лосса");
         OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Red);} 
   }     
}
//+------------------------------------------------------------------+
double LotSize ()
{
double Balance = AccountBalance();
double LotVal = MarketInfo(_Symbol, MODE_TICKVALUE);
double Min_Lot = MarketInfo(_Symbol, MODE_MINLOT);
double Max_Lot = MarketInfo(_Symbol, MODE_MAXLOT);
double atr = iATR(_Symbol,_Period,14,0)*risk/_Point;
double Lot = NormalizeDouble(Balance*risk/100/(atr*2)*LotVal,2);

   if (Lot<Min_Lot) Lot=MathMax(Lot, MarketInfo(Symbol(), MODE_MINLOT));
   if (Lot> Max_Lot) Lot=MathMin(Lot, MarketInfo(Symbol(), MODE_MAXLOT));

return (Lot);
}

int OrderCount(int type)
{
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++ )
   {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
      {
        if (OrderSymbol() == _Symbol && OrderMagicNumber() == 0 && OrderType() == type)
      {
      count++;
      }
   }
}  
return(count);
}
  