﻿//+------------------------------------------------------------------+
//|                                                  JST_Line_YA.mq4 |
//|                                          Copyright 2021, TTSS000 |
//|                                      https://twitter.com/ttss000 |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021, TTSS000"
#property link      "https://twitter.com/ttss000"
#property version   "1.6"                         // 2022/1/8
#property strict
#property indicator_chart_window

input int FontSize=10;
input string FontName = "Segoe UI";
input color JST_Color_Winter = clrCadetBlue;  // Lineの色
input color JST_Color_Summer = clrOlive;  // Line Summer の色
input int timediff_winter=7;
input bool bShowVLine=true;
input bool bShowDayOfWeek=true;
input string memo="true=bg line, false=invisible line";
input bool bDenomiBG=true;

//extern color Color_JST = clrCadetBlue;

int TimeFlag=0;
bool summer = false;

string vlinebasename="vline";
string vlinelabelbasename="VlineLabel";
string vlineDoWlabelbasename="VlineDoWLabel";
string strDoW[7] = {"Su", "M", "Tu", "W", "Th", "F", "Sa"};

int iDenominator = 1;
int iDenominator2 = 1;
int iDenominator_DoW = 1;
int scaleChart, scaleChart_prev;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int     OnInit()
{
  EventSetTimer(1);

  return  ( INIT_SUCCEEDED );
}

//+------------------------------------------------------------------+
void Delete_Vlines_and_Labels()
{

  int obj_total= ObjectsTotal();
  for (int k= obj_total; k>=0; k--){
    string name= ObjectName(k);
      if(StringFind(StringSubstr(name,0,StringLen(vlinebasename)),vlinebasename)>=0){
        if(OBJ_VLINE == ObjectType(name) || OBJ_TEXT == ObjectType(name)){
          ObjectDelete(0,  name);
        }
      }
      if(StringFind(StringSubstr(name,0,StringLen(vlinelabelbasename)),vlinelabelbasename)>=0){
        if(OBJ_TEXT == ObjectType(name)){
          ObjectDelete(0,  name);
        }
      }
      if(StringFind(StringSubstr(name,0,StringLen(vlineDoWlabelbasename)),vlineDoWlabelbasename)>=0){
        if(OBJ_TEXT == ObjectType(name)){
          ObjectDelete(0,  name);
        }
      }
   }
}
//+------------------------------------------------------------------+
void    OnDeinit(const int reason)
{
  string objectname_local;

  // object_comment = TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(Time[i])];
  // objectname_local = vlinebasename + object_comment;
  // objectname_local2 = vlinelabelbasename + object_comment;
  // objectname_local3 = objectname_local2+"DoW";


  if(reason == REASON_REMOVE || reason == REASON_PARAMETERS ||  reason == REASON_CHARTCHANGE  ||  reason == REASON_RECOMPILE){
    Delete_Vlines_and_Labels();
  }

  //if(reason == REASON_REMOVE || reason == REASON_PARAMETERS ||  reason == REASON_CHARTCHANGE  ||  reason == REASON_RECOMPILE){
  if(false){
  if(reason == REASON_REMOVE || reason == REASON_PARAMETERS   ||  reason == REASON_RECOMPILE){
    for(int i = 0 ; i < Bars ; i++){
      objectname_local = vlinebasename 
          + TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(Time[i])];;
      ObjectDelete(0,  objectname_local);
      objectname_local = vlinelabelbasename 
          + TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(Time[i])];
      ObjectDelete(0,  objectname_local); 
      objectname_local = vlineDoWlabelbasename 
          + TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(Time[i])]+"_DoW";
      // objectname_local3 = vlinelabelbasename + object_comment + "_DoW";

      ObjectDelete(0,  objectname_local); 
      objectname_local = vlinelabelbasename 
          + TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(Time[i])]+"_DoW";
      // objectname_local3 = vlinelabelbasename + object_comment + "_DoW";

      ObjectDelete(0,  objectname_local); 

    }
  }
  }
  EventKillTimer();
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int     OnCalculate( const int       rates_total
                   , const int       prev_calculated
                   , const datetime &time       []
                   , const double   &open       []
                   , const double   &high       []
                   , const double   &low        []
                   , const double   &close      []
                   , const long     &tick_volume[]
                   , const long     &volume     []
                   , const int      &spread     []
                   )
{
  //JST_BackGround();
  //DrawJSTLine();
  //JST_BackGround();

  return  ( rates_total );
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
  //Check_Denomi();

  //if(true || scaleChart_prev != scaleChart){
  //  Delete_Vlines_and_Labels();
  //}
  DrawJSTLine();
  JST_BackGround();
  //Print ("DEBUG Timer");
}
//+-------------------------------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  long value;


  if(id == CHARTEVENT_CHART_CHANGE || id == CHARTEVENT_KEYDOWN || (id == CHARTEVENT_CLICK && ChartGetInteger(0, CHART_MOUSE_SCROLL, 0, value))){

    Check_Denomi();
    if(scaleChart_prev != scaleChart){
      Delete_Vlines_and_Labels();
    }

    //JST_ResetToOriginal();
    DrawJSTLine();
    //JST_ResetToOriginal();
    JST_BackGround();
  }
}
//++//
//+-------------------------------------------------------------------------------------------+
void Check_Denomi(){

  scaleChart_prev = scaleChart;
  scaleChart =  ChartGetInteger(0,CHART_SCALE,0);

  iDenominator_DoW = 1;

  if(PERIOD_M1 == Period()){
	  if(scaleChart == 0){
      iDenominator = 2;
    }else{
      iDenominator = 1;
    }
  }else if(PERIOD_M5 == Period()){
    if(scaleChart == 0){
      // vline
	    iDenominator = 8;
      // label
	    iDenominator2 = 8;
	  }else if(scaleChart == 1){
	    iDenominator = 4;
	    iDenominator2 = 2;
	  }else if(scaleChart == 2){
	    iDenominator = 2;
	    iDenominator2 = 1;
	  }else{
	    iDenominator = 1;
	    iDenominator2 = 1;
	  }
  }else if(PERIOD_M1 == Period()){
	   if(scaleChart == 0){
      iDenominator = 2;
    }else{
      iDenominator = 1;
    }
  }else if(PERIOD_M15 == Period()){
	   if(scaleChart <= 0){
  	  iDenominator = 24;
  	  iDenominator2 = 24;
    }else if(scaleChart <= 1){
  	  iDenominator = 16;
  	  iDenominator2 = 16;
    }else if(scaleChart <= 2){
  	  iDenominator = 8;
  	  iDenominator2 = 8;
    }else if(scaleChart <= 3){
  	  iDenominator = 4;
  	  iDenominator2 = 2;
    }else if(scaleChart <= 4){
  	  iDenominator = 2;
  	  iDenominator2 = 2;
    }else{
  	  iDenominator = 1;
  	  iDenominator2 = 1;
    }
  }else if(PERIOD_M30 == Period()){
   if(scaleChart <= 0){
  	  iDenominator = 48;
  	  iDenominator2 = 16;
    }else if(scaleChart <= 1){
  	  iDenominator = 32;
  	  iDenominator2 = 16;
    }else if(scaleChart <= 2){
  	  iDenominator = 16;
  	  iDenominator2 = 4;
    }else if(scaleChart <= 3){
      iDenominator = 8;
  	  iDenominator2 = 2;
    }else if(scaleChart <= 4){
      iDenominator = 3;
      iDenominator2 = 1;
    }else{
  	  iDenominator = 2;
  	  iDenominator2 = 1;
    }
  }else if(PERIOD_H1 == Period()){
	   if(scaleChart <= 0){
  	  iDenominator = 96;
  	  iDenominator2 = 32;
    }else if(scaleChart <= 1){
  	  iDenominator = 64;
  	  iDenominator2 = 32;
    }else if(scaleChart <= 2){
  	  iDenominator = 24;
  	  iDenominator2 = 8;
    }else if(scaleChart <= 3){
  	  iDenominator = 16;
  	  iDenominator2 = 4;
    }else if(scaleChart <= 4){
  	  iDenominator = 6;
  	  iDenominator2 = 2;
    }else{
  	  iDenominator = 3;
  	  iDenominator2 = 1;
    }
  }else if(PERIOD_H4 == Period()){
    if(scaleChart <= 0){
  	   iDenominator = 96;
  	   iDenominator2 = 32;
      iDenominator_DoW = -1;
    }else if(scaleChart <= 1){
  	   iDenominator = 64;
  	   iDenominator2 = 32;
      iDenominator_DoW = -1;
    }else if(scaleChart <= 2){
  	  iDenominator = 24;
  	  iDenominator2 = 8;
    }else if(scaleChart <= 3){
  	  iDenominator = 16;
  	  iDenominator2 = 4;
    }else if(scaleChart <= 4){
  	  iDenominator = 6;
  	  iDenominator2 = 2;
    }else{
  	  iDenominator = 3;
  	  iDenominator2 = 1;
    }
  }else if(PERIOD_D1 == Period()){
    if(scaleChart <= 0){
  	   iDenominator = 96;
  	   iDenominator2 = 32;
      iDenominator_DoW = -2;
    }else if(scaleChart <= 1){
  	   iDenominator = 64;
  	   iDenominator2 = 32;
      iDenominator_DoW = -2;
    }else{
      iDenominator = 96;
      iDenominator2 = 96;
      iDenominator_DoW = -1;
    }
  }else{
	  iDenominator = 6;
   iDenominator2 = 1;
      iDenominator_DoW = 1;
  }

}
//+-------------------------------------------------------------------------------------------+
//| reset to original                                                                         |
//+-------------------------------------------------------------------------------------------+
void JST_ResetToOriginal(){
  int obj_total= ObjectsTotal();
  color colorChartJST, colorChartJSTtmp;
  color colorChartBG;
  bool bcolorChartJSTSet = false;

  colorChartBG = ChartGetInteger(0,CHART_COLOR_BACKGROUND,OBJPROP_COLOR);
  for (int k= obj_total; k>=0; k--){
    string name= ObjectName(k);
    //ObjectSetInteger(0,name, OBJPROP_HIDDEN, false);

    //if (StringSubstr(name,0,17)=="[Background Box]") {ObjectDelete(name);}
    //if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0) ObjectSetInteger(0,name, OBJPROP_BACK, true);
    //if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0) ObjectSetInteger(0,name, OBJPROP_HIDDEN, false);
    if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0){
      colorChartJSTtmp = ObjectGetInteger(0,name,OBJPROP_COLOR);
      //colorChartJSTtmp = ChartGet(0,name,OBJPROP_COLOR);
      if(colorChartJSTtmp != colorChartBG && bcolorChartJSTSet == false){
        colorChartJST = colorChartJSTtmp;
        bcolorChartJSTSet = true;
        //Print ("JST Color = " + colorChartJSTtmp);
      }else{
        //Print ("BG Color = " + colorChartJSTtmp);
      }
    }
  }
  for (int k= obj_total; k>=0; k--){
    string name= ObjectName(k);
    //ObjectSetInteger(0,name, OBJPROP_HIDDEN, false);

    //if (StringSubstr(name,0,17)=="[Background Box]") {ObjectDelete(name);}
    //if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0) ObjectSetInteger(0,name, OBJPROP_BACK, true);
    //if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0) ObjectSetInteger(0,name, OBJPROP_HIDDEN, false);
    if( StringFind(StringSubstr(name,0,10),"vline")>=0){
      ObjectSetInteger(0,name, OBJPROP_BACK, false);
    }
    if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0){
      //ObjectSetInteger(0,name, OBJPROP_COLOR, Color_JST);
      ObjectSetInteger(0,name, OBJPROP_COLOR, colorChartJST);
    }
  }
}
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------------------------------+
//| My own Program De-initialization                                                                 |
//+-------------------------------------------------------------------------------------------+
void JST_BackGround(){
  int obj_total= ObjectsTotal();
  int iBarsInWindow = WindowBarsPerChart();
  int iWindowFirstVisibleBar = WindowFirstVisibleBar();
  datetime dtVline;
  int iCountVline = 0;
  int iCountVline2 = 0;
  int iBarShiftTmp;
  color colorChartBG;
  int iBarRatio;
  bool bOutofWin;

  colorChartBG = ChartGetInteger(0,CHART_COLOR_BACKGROUND,OBJPROP_COLOR);

  // for debug
  //if(0 <= StringFind(Symbol() , "EURUSD")){
  //  Print ("iBarsInWindow = " + iBarsInWindow);
  //  Print ("1st visible bar = " + iWindowFirstVisibleBar);
  //}
  if(iWindowFirstVisibleBar < 1){
    iWindowFirstVisibleBar = 1;
  }

  Check_Denomi();

  for (int k= obj_total; k>=0; k--){
    string name= ObjectName(k);
    //ObjectSetInteger(0,name, OBJPROP_HIDDEN, false);

    if( StringFind(StringSubstr(name,0,5),"vline")>=0){
      //if (StringSubstr(name,0,17)=="[Background Box]") {ObjectDelete(name);}
      //if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0) ObjectSetInteger(0,name, OBJPROP_BACK, true);
      //if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0) ObjectSetInteger(0,name, OBJPROP_HIDDEN, false);

      string vlabel_name = "VlineLabel" + StringSubstr(name,5,-1);

      dtVline = ObjectGetInteger(0,name, OBJPROP_TIME);
      iBarShiftTmp = iBarShift(0,0,dtVline,true);
      if(iWindowFirstVisibleBar < iBarsInWindow){
        // right area is blank, almost the latest bar
        iBarRatio = 100*iBarShiftTmp/iWindowFirstVisibleBar;
      }else{
        // the chart is scrolled back
        if(iWindowFirstVisibleBar < iBarShiftTmp || iBarShiftTmp < (iWindowFirstVisibleBar-iBarsInWindow)){
          // out of window
          bOutofWin = true;
        }else{
          bOutofWin = false;
          iBarRatio = 100-100*(iWindowFirstVisibleBar-iBarShiftTmp)/iBarsInWindow;
        }
      }
      ObjectSetInteger(0,name, OBJPROP_BACK, false);
      ObjectSetInteger(0,vlabel_name, OBJPROP_BACK, false);

      if(!bOutofWin && 0 <= iBarShiftTmp && 90 < iBarRatio && iBarRatio <= 100 ){
        ObjectSetInteger(0,name, OBJPROP_BACK, true);
        ObjectSetInteger(0,vlabel_name, OBJPROP_BACK, true);
      }
      if(iCountVline % iDenominator != 0){
        if(bDenomiBG){
          ObjectSetInteger(0,name, OBJPROP_BACK, true);
          ObjectSetInteger(0,vlabel_name, OBJPROP_BACK, true);
        }else{
          ObjectSetInteger(0,name, OBJPROP_BACK, true);
          ObjectSetInteger(0,name, OBJPROP_COLOR, colorChartBG);
          ObjectSetInteger(0,vlabel_name, OBJPROP_BACK, true);
          ObjectSetInteger(0,vlabel_name, OBJPROP_COLOR, colorChartBG);
        }
      }
      iCountVline++;
    }

    // v label
    if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0){
      dtVline = ObjectGetInteger(0,name, OBJPROP_TIME);
      iBarShiftTmp = iBarShift(0,0,dtVline,true);
      if(iWindowFirstVisibleBar < iBarsInWindow){
        // right area is blank
        iBarRatio = 100*iBarShiftTmp/iWindowFirstVisibleBar;
      }else{
        // the chart is scroll back
        if(iWindowFirstVisibleBar < iBarShiftTmp || iBarShiftTmp < (iWindowFirstVisibleBar-iBarsInWindow)){
          // out of window
          bOutofWin = true;
        }else{
          bOutofWin = false;
          iBarRatio = 100-100*(iWindowFirstVisibleBar-iBarShiftTmp)/iBarsInWindow;
        }
      }
      if(bDenomiBG){
        if(iCountVline2 % iDenominator2 != 0){
          ObjectSetInteger(0,name, OBJPROP_BACK, true);
          //ObjectSetInteger(0,name, OBJPROP_COLOR, colorChartBG);
          ObjectSetInteger(0,name, OBJPROP_COLOR, clrNONE);
        }else{
          ObjectSetInteger(0,name, OBJPROP_BACK, false);
        }
      }
      if(!bOutofWin && 0 <= iBarShiftTmp && 90 < iBarRatio && iBarRatio <= 100 ){
        ObjectSetInteger(0,name, OBJPROP_BACK, true);
        //ObjectSetInteger(0,name, OBJPROP_COLOR, colorChartBG);
        ObjectSetInteger(0,name, OBJPROP_COLOR, clrNONE);
        //ObjectSetString(0,name, OBJPROP_TEXT, "AAAAA");
        //Print ("iBarsInWindow = " + iBarsInWindow);
        //Print ("iWindowFirstVisibleBar = " + iWindowFirstVisibleBar);
        //Print ("iBarShiftTmp = " + iBarShiftTmp);
        //Print (dtVline);
      }

      iCountVline2++;
    }
    //if( StringFind(StringSubstr(name,0,10),"vline")>=0) ObjectSetInteger(0,name, OBJPROP_HIDDEN, false);
    //if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0) ObjectSetInteger(0,name, OBJPROP_ZORDER, 0);
    //if( StringFind(StringSubstr(name,0,10),"vline")>=0) ObjectSetInteger(0,name, OBJPROP_ZORDER, 0);
  }
}
//+------------------------------------------------------------------+
// >>---------<< サマータイム関数 >>--------------------------------------------------------------------<<
// copy right takulogu san
// http://fxbo.takulogu.com/mql4/backtest/summertime/
int Summerflag(int shift){ // TimeFlag と summer はグローバル関数
 int B=0;
 int CanM = (int)TimeMonth(iTime(NULL,0,shift)); //月取得
 int CanD = (int)TimeDay(iTime(NULL,0,shift)); //日取得
 int CanW = (int)TimeDayOfWeek(iTime(NULL,0,shift));//曜日取得
 if(TimeFlag!=CanD){ //>>日が変わった際に計算
  if(CanM>=3&&CanM<=11){ //------------------------------------------- 3月から11月範囲計算開始
   if(CanM==3){ //------------------------------------------- 3月の計算（月曜日が○日だったら夏時間）
    if(CanD<=8) { summer = false;}
    if(CanD==9) { if(CanW==1){summer = true;}else{summer = false;} }// 9日の月曜日が第3月曜日の最小日（第2日曜の最小が8日の為）
    if(CanD==10){ if(CanW<=2){summer = true;}else{summer = false;} }// 10日が火曜以下であれば,第3月曜日を迎えた週
    if(CanD==11){ if(CanW<=3){summer = true;}else{summer = false;} }// 11日が水曜以下であれば,第3月曜日を迎えた週
    if(CanD==12){ if(CanW<=4){summer = true;}else{summer = false;} }// 12日が木曜以下であれば,第3月曜日を迎えた週
    if(CanD>=13){ summer = true; } // 13日以降は上の条件のいずれかが必ず満たされる
   }
   if(CanM==11){ //------------------------------------------ 11月の計算（月曜日が○日だったら冬時間）
    if(CanD==1){ summer = true; }
    if(CanD==2){ if(CanW==1){summer = false;}else{summer = true;} }// 2日の月曜日が第2月曜日の最小日（第1日曜の最小が1日の為）
    if(CanD==3){ if(CanW<=2){summer = false;}else{summer = true;} }// 3日が火曜以下であれば,第2月曜日を迎えた週
    if(CanD==4){ if(CanW<=3){summer = false;}else{summer = true;} }// 4日が水曜以下であれば,第2月曜日を迎えた週
    if(CanD==5){ if(CanW<=4){summer = false;}else{summer = true;} }// 5日が木曜以下であれば,第2月曜日を迎えた週
    if(CanD==6){ if(CanW<=5){summer = false;}else{summer = true;} }// 6日が金曜以下であれば,第2月曜日を迎えた週
    if(CanD>=7){ summer = false; } // 7日以降が何曜日に来ても第2月曜日を迎えている(7日が日なら迎えていないが8日で迎える)
   }
  if(CanM!=3&&CanM!=11)summer = true;//　4月~10月は無条件で夏時間
  } //--------------------------------------------------------------- 3月から11月範囲計算終了
  else{summer = false;}//12月~2月は無条件で冬時間
  TimeFlag=CanD;
  } if(summer == true){B=0;}else{B=1;}
 return(B);
}
//+------------------------------------------------------------------+
void DrawJSTLine(){
  // get visible time
  // get latest time get shift
  int chart_visible_bars;
  int chart_first_visible_bar;
  int minute;
  string objectname_local;
  string objectname_local2;
  string objectname_local3;
  string object_comment;
  
  int chart_id=0;

  chart_first_visible_bar=ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0);
  chart_visible_bars=ChartGetInteger(0,CHART_VISIBLE_BARS,0);
  double chart_price_max=ChartGetDouble(0,CHART_PRICE_MAX,0);
  double chart_price_min=ChartGetDouble(0,CHART_PRICE_MIN,0);

  // if minutes == 0 then vline
  int i_start = 0;
  if(0 < chart_first_visible_bar - chart_visible_bars){
    i_start = chart_first_visible_bar - chart_visible_bars;
  }
  for(int i = i_start ; i < chart_first_visible_bar ; i++){
    //minute = (int)TimeMinute(iTime(NULL,0,i));
    minute = (int)TimeMinute(Time[i]);
    object_comment = TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(Time[i])];
    objectname_local = vlinebasename + object_comment;
    objectname_local2 = vlinelabelbasename + object_comment;
    objectname_local3 = vlineDoWlabelbasename + object_comment + "_DoW";

    if(minute == 0 && bShowVLine){

      if (ObjectFind(objectname_local) < 0){
        ObjectCreate(0,objectname_local, OBJ_VLINE, 0, Time[i],0);
     	  //ObjectCreate(indicator_sname, OBJ_LABEL, 0, 0, 0);
      }
      TimeFlag = 0;  //force calc
      if(Summerflag(i)){
        // winter
        ObjectSetInteger(chart_id,objectname_local,OBJPROP_COLOR,JST_Color_Winter);    // ラインの色設定
      }else{
        ObjectSetInteger(chart_id,objectname_local,OBJPROP_COLOR, JST_Color_Summer );    // ラインの色設定
      }
      
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_STYLE,STYLE_DOT);  // ラインのスタイル設定
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_WIDTH,1);              // ラインの幅設定
      //ObjectSetInteger(chart_id,objectname_local,OBJPROP_BACK,false);           // オブジェクトの背景表示設定
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_SELECTABLE,false);     // オブジェクトの選択可否設定
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_SELECTED,false);      // オブジェクトの選択状態
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_ZORDER,0);      // オブジェクトのチャートクリックイベント優先順位
      ObjectSetString(chart_id,objectname_local,OBJPROP_TEXT,object_comment);  // comment

      // Create TexT
      if (ObjectFind(objectname_local2) < 0){
        ObjectCreate(0,objectname_local2, OBJ_TEXT, 0, Time[i],chart_price_max);
   	    //ObjectCreate(indicator_sname, OBJ_LABEL, 0, 0, 0);
      }else{
        ObjectMove(0, objectname_local2, 0, Time[i],chart_price_max);
      }
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_FONTSIZE,FontSize);         // フォントサイズ

      // オブジェクトバインディングのアンカーポイント設定
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_ANCHOR,ANCHOR_UPPER);  

      ObjectSetString(chart_id,objectname_local2,OBJPROP_FONT,FontName); // フォント

      //input int FontSize=10;
      //input string FontName = "Segoe UI";
    
      string strHour;

      int iHour;
      if(Summerflag(i)){
        // winter
        ObjectSetInteger(chart_id,objectname_local2,OBJPROP_COLOR,JST_Color_Winter);    // ラインの色設定
        iHour = TimeHour(iTime(NULL,0,i))+timediff_winter;
      }else{
        ObjectSetInteger(chart_id,objectname_local2,OBJPROP_COLOR, JST_Color_Summer );    // ラインの色設定
        iHour = TimeHour(iTime(NULL,0,i))+timediff_winter-1;
      }
      if(23 < iHour){
        iHour -= 24;
      }
      if(iHour < 0){
        iHour += 24;
      }
      strHour = StringToInteger(iHour)+":00";

      ObjectSetString(chart_id,objectname_local2,OBJPROP_TEXT,strHour);   // 表示するテキスト

      //ObjectSetInteger(chart_id,objectname_local2,OBJPROP_STYLE,STYLE_DOT);  // ラインのスタイル設定
      //ObjectSetInteger(chart_id,objectname_local2,OBJPROP_WIDTH,1);              // ラインの幅設定
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_BACK,false);           // オブジェクトの背景表示設定
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_SELECTABLE,false);     // オブジェクトの選択可否設定
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_SELECTED,false);      // オブジェクトの選択状態
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_ZORDER,0);      // オブジェクトのチャートクリックイベント優先順位

    } // minute=0

    // Day of week
    // iDenominator_DoW < 0 then only monday
    if(bShowDayOfWeek && (TimeDayOfWeek(Time[i]) != TimeDayOfWeek(Time[i+1]))){
      // yobi kirikawari
      if(0< iDenominator_DoW || (iDenominator_DoW == -1 && 1 == TimeDayOfWeek(Time[i]))){
      
        if (ObjectFind(objectname_local3) < 0){
          ObjectCreate(0,objectname_local3, OBJ_TEXT, 0, Time[i],chart_price_min);
     	    //ObjectCreate(indicator_sname, OBJ_LABEL, 0, 0, 0);
        }else{
          ObjectMove(0, objectname_local3, 0, Time[i],chart_price_min);
        }
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_FONTSIZE,FontSize);         // フォントサイズ

        // オブジェクトバインディングのアンカーポイント設定
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_ANCHOR,ANCHOR_LOWER);  
        ObjectSetString(chart_id,objectname_local3,OBJPROP_FONT,FontName); // フォント

        if(Summerflag(i)){
          // winter
          ObjectSetInteger(chart_id,objectname_local3,OBJPROP_COLOR,JST_Color_Winter);    // ラインの色設定
        }else{
          ObjectSetInteger(chart_id,objectname_local3,OBJPROP_COLOR, JST_Color_Summer );    // ラインの色設定
        }

        //input int FontSize=10;
        //input string FontName = "Segoe UI";
    
        ObjectSetString(chart_id,objectname_local3,OBJPROP_TEXT,strDoW[TimeDayOfWeek(Time[i])]);   // 表示するテキスト
 
        //ObjectSetInteger(chart_id,objectname_local2,OBJPROP_STYLE,STYLE_DOT);  // ラインのスタイル設定
        //ObjectSetInteger(chart_id,objectname_local2,OBJPROP_WIDTH,1);              // ラインの幅設定
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_BACK,false);           // オブジェクトの背景表示設定
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_SELECTABLE,false);     // オブジェクトの選択可否設定
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_SELECTED,false);      // オブジェクトの選択状態
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_ZORDER,0);      // オブジェクトのチャートクリックイベント優先順位
      }
      ///// add here for DayStartOnly
      
      ///// to here

    }


  }
}
//+------------------------------------------------------------------+
