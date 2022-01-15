//+------------------------------------------------------------------+
//|                                                  JST_Line_YA.mq4 |
//|                                          Copyright 2021, TTSS000 |
//|                                      https://twitter.com/ttss000 |
//+------------------------------------------------------------------+
// kikan kugiri wo kijun ni shite, sokode denomi de wa naku jikan kan kaku wo ireru
// wo zero ni suru de 24 made no kan kaku wo oite,
// denomi kan kaku wo koete itara 

#property copyright "Copyright 2021, TTSS000"
#property link      "https://twitter.com/ttss000"
#property version   "1.7"                         // 2022/1/15
#property strict
#property indicator_chart_window

#define MINIMUM_VLINEGAP_PIX 80
#define MINIMUM_VLINELABELGAP_PIX 100

#define WM_MDIGETACTIVE 0x00000229
#import "user32.dll"
  int GetParent(int hWnd);
  int SendMessageW(int hWnd,int Msg,int wParam,int lParam);
#import

//#include <MQL4Common.mqh>

input int FontSize=10;
input string FontName = "Segoe UI";
input color JST_Color_Winter = clrCadetBlue;  // Lineの色
input color JST_Color_Summer = clrOlive;  // Line Summer の色
input int timediff_winter=6;
input bool bShowVLine=true;
input bool bShowDayOfWeek=true;
input string memo="true=bg line, false=invisible line";
input bool bDenomiBG=true;
input bool bShowSatuaday=false;
input bool bTimeAtDayChangeOnly=false;
input int iNoDrawAreaX = 0;
input bool bForceChartBack=true;
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

int iHourIntervalVline = 1;
int iHourIntervalVlineLabel = 1;

int scaleChart, scaleChart_prev;
bool bRedrawFlag=false;
bool bForceVlineAndLabelDisable=false;

/*-- 変数の宣言 ----------------------------------------------------*/
//int ClientHandle = 0; //クライアントウィンドウハンドル保持用
//int ThisWinHandle = 0; //Thisウィンドウハンドル保持用
//int ParentWinHandle = 0; //Parentウィンドウハンドル保持用

//+------------------------------------------------------------------+
int ObjectType(string name){
  return ObjectGetInteger (0, name, OBJPROP_TYPE);
}
//+------------------------------------------------------------------+
datetime TimeMonth(datetime TargetTime) {
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.mon;
}
//+------------------------------------------------------------------+
datetime TimeDay(datetime TargetTime) {
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.day;
}
//+------------------------------------------------------------------+
datetime TimeMinute(datetime TargetTime) {
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.min;
}
//+------------------------------------------------------------------+
datetime TimeHour(datetime TargetTime) {
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.hour;
}
//+------------------------------------------------------------------+
datetime TimeDayOfWeek(datetime TargetTime) {
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.day_of_week;
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int     OnInit()
{
  //ClientHandle = (int)ChartGetInteger(0,CHART_WINDOW_HANDLE);
  //          Print ("SyncMain OnTimer ClientHandle0: "+ClientHandle);
  //if (ClientHandle != 0) ThisWinHandle = GetParent(ClientHandle);
  //          Print ("SyncMain OnTimer ClientHandle1: "+ClientHandle);
  //if (ThisWinHandle != 0) ParentWinHandle = GetParent(ThisWinHandle);

  if(bForceChartBack){
    ChartSetInteger(0,CHART_FOREGROUND, false);
  }

  EventSetTimer(1);
  //EventSetMillisecondTimer(333);
  Check_Denomi();

  return  ( INIT_SUCCEEDED );
}

//+------------------------------------------------------------------+
void Delete_Vlines_and_Labels()
{

  int obj_total= ObjectsTotal(0,0,-1) ;
  for (int k= obj_total; k>=0; k--){
    string name= ObjectName(0,k, 0, -1);
      if(StringFind(StringSubstr(name,0,StringLen(vlinebasename)),vlinebasename)>=0){
        if(OBJ_VLINE == ObjectGetInteger (0, name, OBJPROP_TYPE) || OBJ_TEXT == ObjectGetInteger (0, name, OBJPROP_TYPE)){
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
void OnDeinit(const int reason)
{
  string objectname_local;

  // object_comment = TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(Time[i])];
  // objectname_local = vlinebasename + object_comment;
  // objectname_local2 = vlinelabelbasename + object_comment;
  // objectname_local3 = objectname_local2+"DoW";

  if(reason == REASON_REMOVE || reason == REASON_PARAMETERS ||  reason == REASON_CHARTCHANGE  ||  reason == REASON_RECOMPILE){
    Delete_Vlines_and_Labels();
    Check_Denomi();
  }

  //if(reason == REASON_REMOVE || reason == REASON_PARAMETERS ||  reason == REASON_CHARTCHANGE  ||  reason == REASON_RECOMPILE){
  if(false){
    if(reason == REASON_REMOVE || reason == REASON_PARAMETERS   ||  reason == REASON_RECOMPILE){
      int bars=Bars(_Symbol,_Period);
      for(int i = 0 ; i < bars ; i++){
        objectname_local = vlinebasename 
            + TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(iTime(NULL,0,i))];;
        ObjectDelete(0,  objectname_local);
        objectname_local = vlinelabelbasename 
            + TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(iTime(NULL,0,i))];
        ObjectDelete(0,  objectname_local); 
        objectname_local = vlineDoWlabelbasename 
            + TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(iTime(NULL,0,i))]+"_DoW";
        // objectname_local3 = vlinelabelbasename + object_comment + "_DoW";

        ObjectDelete(0,  objectname_local); 
        objectname_local = vlinelabelbasename 
            + TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(iTime(NULL,0,i))]+"_DoW";
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

  if(bForceChartBack){
    ChartSetInteger(0,CHART_FOREGROUND, false);
  }
  if(bRedrawFlag){
    Check_Denomi();
    DrawJSTLine();
    //JST_BackGround();
    //Print ("DEBUG Timer");
    //ChartRedraw(NULL);
    bRedrawFlag = false;
  }
}
//+-------------------------------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  long value;

  if(id == CHARTEVENT_CHART_CHANGE || id == CHARTEVENT_KEYDOWN || (id == CHARTEVENT_CLICK && ChartGetInteger(0, CHART_MOUSE_SCROLL, 0, value))){
    //Print ("HERE 000");
    Check_Denomi();
    if(scaleChart_prev != scaleChart){
      Delete_Vlines_and_Labels();
    }
    bRedrawFlag = true;

    //JST_ResetToOriginal();
    //DrawJSTLine();
    //JST_ResetToOriginal();
    //JST_BackGround();
    //ChartRedraw(NULL);
  }
}
//++//
//+------------------------------------------------------------------+
//+-------------------------------------------------------------------------------------------+
//| My own Program De-initialization                                                                 |
//+-------------------------------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void DrawJSTLine(){
  // get visible time
  // get latest time get shift

  int obj_total= ObjectsTotal(0,0,-1);
  int iBarsInWindow = ChartGetInteger(0,CHART_VISIBLE_BARS,0);
  int iWindowFirstVisibleBar = ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0);
  datetime dtVline;
  int iCountVline = 0;
  int iCountVline2 = 0;
  int iHourIntervalCount = 0;
  int iHourIntervalCount2 = 0;
  int iBarShiftTmp;
  color colorChartBG;
  int iBarRatio;
  bool bOutofWin;
  int x_tmp, y_tmp;
  int x_tmp_Prev;
  bool bDateChange=false;
  int i_minitue0_prev=-1;
  int chart_visible_bars;
  int chart_first_visible_bar;
  int minute;
  string objectname_local;
  string objectname_local2;
  string objectname_local3;
  string object_comment;
  string object_comment_prev;
  string objectname_local_prev;
  string objectname_local_prev2;
  bool bVlineBack=true;
  bool bPrevVlineChangeToBack=false;
  
  int chart_id=0;

  //int wHandle = SendMessageW(ParentWinHandle,WM_MDIGETACTIVE,0,0);
  //Print ("main ce cli wHandle "+wHandle);
  //if(wHandle != ThisWinHandle){
  //  // if not activated
  //  return;
  //}

  if(false == ChartGetInteger(0,CHART_BRING_TO_TOP)){
    // Do Something...
    // chart is not active
    //return;
  }

  chart_first_visible_bar=ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0);
  chart_visible_bars=ChartGetInteger(0,CHART_VISIBLE_BARS,0);
  double chart_price_max=ChartGetDouble(0,CHART_PRICE_MAX,0);
  double chart_price_min=ChartGetDouble(0,CHART_PRICE_MIN,0);

  colorChartBG = ChartGetInteger(0,CHART_COLOR_BACKGROUND,OBJPROP_COLOR);

  //vlinelabelbasename
  //string vlabel_name = "VlineLabel" + StringSubstr(name,5,-1);
  //string vlinebasename="vline";
  //string vlinelabelbasename="VlineLabel";
  //string vlineDoWlabelbasename="VlineDoWLabel";

  // if minutes == 0 then vline
  int i_start = 0;
  if(0 < chart_first_visible_bar - chart_visible_bars){
    i_start = chart_first_visible_bar - chart_visible_bars;
  }

  //Print ("iBarsInWindow ="+iBarsInWindow);
  //Print ("iWindowFirstVisibleBar ="+iWindowFirstVisibleBar);


  //for(int i = i_start ; i < chart_first_visible_bar ; i++){
  for(int i = chart_first_visible_bar ; i_start <= i ; i--){
    //minute = (int)TimeMinute(iTime(NULL,0,i));
    minute = (int)TimeMinute(iTime(NULL,0,i));
    object_comment = TimeToString(iTime(NULL,0,i), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(iTime(NULL,0,i))];
    objectname_local = vlinebasename + object_comment;
    objectname_local2 = vlinelabelbasename + object_comment;
    objectname_local3 = vlineDoWlabelbasename + object_comment + "_DoW";

    //string vlabel_name = vlinelabelbasename + StringSubstr(name,5,-1);

    if(TimeDayOfWeek(iTime(NULL,0,i)) != TimeDayOfWeek(iTime(NULL,0,i+1))){
      bDateChange=true;
      iHourIntervalCount = 0;
      iHourIntervalCount2 = 0;
      //Print ("HERE date change");
    }else{
      bDateChange=false;
      //Print ("HERE date not change");
    }

    if(chart_first_visible_bar < iBarsInWindow){
      // right area is blank, almost the latest bar
      iBarRatio = 100*i/chart_first_visible_bar;
    }else{
      // the chart is scrolled back
      if(chart_first_visible_bar < i || i < (chart_first_visible_bar-iBarsInWindow)){
        bVlineBack=true;// out of window
      }else{
        iBarRatio = 100-100*(iWindowFirstVisibleBar-i)/iBarsInWindow;
      }
    }

    if(minute == 0 && bShowVLine){
      bPrevVlineChangeToBack=false;
      //Print ("minut 0"+object_comment);
      //Print ("iBarRatio000="+iBarRatio);
      if(0 <= i && 85 < iBarRatio && iBarRatio <= 100){
        //Print ("Here000");
        bVlineBack=true;
      }else{
        if(bDateChange){
          //Print ("Here001");
          bVlineBack=false;
        }
        // 
        ChartTimePriceToXY(0,0, iTime(NULL,0,i), iClose(NULL,0,i), x_tmp, y_tmp);
        if(0<i_minitue0_prev){
          ChartTimePriceToXY(0, 0,iTime(NULL,0,i_minitue0_prev), iClose(NULL,0,i_minitue0_prev), x_tmp_Prev, y_tmp);
        }else{
          x_tmp_Prev = -1;
        }
       
        int xdiff = x_tmp-x_tmp_Prev;
        if(xdiff<0){
          xdiff = -xdiff;
        }
        //Print (i+"  xdiff:"+xdiff);
        if(bDateChange){
          if(xdiff < MINIMUM_VLINEGAP_PIX && 0<i_minitue0_prev){
            bPrevVlineChangeToBack=true;
          }else{
            bPrevVlineChangeToBack=false;
          }
        }else{
          if(xdiff < MINIMUM_VLINEGAP_PIX && 0<i_minitue0_prev){
            //Print ("Here002");
            bVlineBack=true;
          }else{
            //Print ("Here003");
            bVlineBack=false;
          }
        }
      }
        //if(bDateChange){
        //  //Print ("Here001");
        //  bVlineBack=false;
        //}

      if (ObjectFind(0,objectname_local) < 0){
        //Print ("obj find "+objectname_local);
        //if(ObjectCreate(0,objectname_local, OBJ_VLINE, 0, iTime(0,0,i),0)){
        if(ObjectCreate(0,objectname_local, OBJ_VLINE, 0, iTime(NULL,0,i),0)){
          //Print ("obj create ok "+objectname_local);
        }else{
         //Print ("obj create fail "+objectname_local);
        }
      }
      TimeFlag = 0;  //force calc
      if(Summerflag(i)){
        // winter
        ObjectSetInteger(chart_id,objectname_local,OBJPROP_COLOR,JST_Color_Winter);    // ラインの色設定
      }else{
        ObjectSetInteger(chart_id,objectname_local,OBJPROP_COLOR, JST_Color_Summer );    // ラインの色設定
      }

      //ObjectSetInteger(chart_id,objectname_local,OBJPROP_BGCOLOR, clrYellow );    // ラインの色設定
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_STYLE,STYLE_DOT);  // ラインのスタイル設定
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_WIDTH,1);              // ラインの幅設定
      //ObjectSetInteger(chart_id,objectname_local,OBJPROP_BACK,false);           // オブジェクトの背景表示設定
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_BACK,bVlineBack);           // オブジェクトの背景表示設定
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_SELECTABLE,false);     // オブジェクトの選択可否設定
      //ObjectSetInteger(chart_id,objectname_local,OBJPROP_SELECTED,false);      // オブジェクトの選択状態
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_HIDDEN,false);         // オブジェクトリスト表示設定
      ObjectSetInteger(chart_id,objectname_local,OBJPROP_ZORDER,0);      // オブジェクトのチャートクリックイベント優先順位
      ObjectSetString(chart_id,objectname_local,OBJPROP_TEXT,object_comment);  // comment

      if(bForceVlineAndLabelDisable){
        ObjectSetInteger(chart_id,objectname_local,OBJPROP_BACK,true);           // オブジェクトの背景表示設定
      }


      if(!bDenomiBG){
        if(bVlineBack){
          ObjectSetInteger(chart_id,objectname_local,OBJPROP_COLOR, clrNONE);    // ラインの色設定
        }
      }
      if(bPrevVlineChangeToBack){
        object_comment_prev = TimeToString(iTime(NULL,0,i_minitue0_prev), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(iTime(NULL,0,i_minitue0_prev))];
        objectname_local_prev = vlinebasename + object_comment_prev;
        ObjectSetInteger(chart_id,objectname_local_prev,OBJPROP_BACK,true);
      }

      //iHourIntervalCount = ;
      //Print ("HERE denomi:"+iHourIntervalCount);
      //Print ("HERE denomi iHourIntervalVline:"+iHourIntervalVline);
      //if(iHourIntervalCount % iHourIntervalVline == 0){
      //Print ("HERE denomi:"+iHourIntervalCount);
      //Print ("HERE denomi iHourIntervalVline:"+iHourIntervalVline);

      //if(bDenomiBG){
      // ObjectSetInteger(0,objectname_local, OBJPROP_BACK, false);  //true
      //ObjectSetInteger(0,objectname_local2, OBJPROP_BACK, true);
      //}else{
      // ObjectSetInteger(0,objectname_local, OBJPROP_BACK, false);  // true
      //ObjectSetInteger(0,objectname_local, OBJPROP_COLOR, colorChartBG);
      //ObjectSetInteger(0,objectname_local2, OBJPROP_BACK, true);
      //ObjectSetInteger(0,objectname_local2, OBJPROP_COLOR, colorChartBG);
      //}
    
      // ======================= Create TexT ==================================
      if (ObjectFind(0,objectname_local2) < 0){
        ObjectCreate(0,objectname_local2, OBJ_TEXT, 0, iTime(NULL,0,i),chart_price_max);
   	    //ObjectCreate(indicator_sname, OBJ_LABEL, 0, 0, 0);
      }else{
        ObjectMove(0, objectname_local2, 0, iTime(NULL,0,i),chart_price_max);
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
      int x_tmp_Prev2 = x_tmp_Prev;

      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_BACK,bVlineBack);           // オブジェクトの背景表示設定
      x_tmp_Prev = x_tmp;
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_SELECTABLE,false);     // オブジェクトの選択可否設定
      //ObjectSetInteger(chart_id,objectname_local2,OBJPROP_SELECTED,false);      // オブジェクトの選択状態
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定
      ObjectSetInteger(chart_id,objectname_local2,OBJPROP_ZORDER,0);      // オブジェクトのチャートクリックイベント優先順位

      if(bForceVlineAndLabelDisable){
        ObjectSetInteger(chart_id,objectname_local2,OBJPROP_COLOR, clrNONE);    // ラインの色設定
      }

      if(!bDenomiBG){
        if(bVlineBack){
          ObjectSetInteger(chart_id,objectname_local2,OBJPROP_COLOR, clrNONE);    // ラインの色設定
        }
      }

      if(bPrevVlineChangeToBack){
        object_comment_prev = TimeToString(iTime(NULL,0,i_minitue0_prev), TIME_DATE|TIME_MINUTES)+strDoW[TimeDayOfWeek(iTime(NULL,0,i_minitue0_prev))];
        objectname_local_prev2 = vlinelabelbasename + object_comment_prev;
        ObjectSetInteger(chart_id,objectname_local_prev2,OBJPROP_BACK,true);
        ObjectSetInteger(chart_id,objectname_local_prev2,OBJPROP_COLOR, clrNONE);    // ラインの色設定
      }

      //if(iHourIntervalCount2 % iHourIntervalVlineLabel == 0 && !bTimeAtDayChangeOnly){
      //  Print ("HERE denomi2:"+iHourIntervalCount2);
      //  Print ("HERE denomi2 iHourIntervalVlineLabel:"+iHourIntervalVlineLabel);
     
      //  if(bDenomiBG){
      //    //ObjectSetInteger(0,objectname_local, OBJPROP_BACK, true);  //true
      //    ObjectSetInteger(0,objectname_local2, OBJPROP_COLOR, colorChartBG);
      //    ObjectSetInteger(0,objectname_local2, OBJPROP_BACK, true);
      //    x_tmp_Prev = x_tmp_Prev2;
      //  }else{
      //    //ObjectSetInteger(0,objectname_local, OBJPROP_BACK, true);  // true
      //    //ObjectSetInteger(0,objectname_local, OBJPROP_COLOR, colorChartBG);
      //    ObjectSetInteger(0,objectname_local2, OBJPROP_BACK, false);
      //    x_tmp_Prev = x_tmp_Prev2;
      //    ObjectSetInteger(0,objectname_local2, OBJPROP_COLOR, colorChartBG);
      //  }
      //}else{
      //  ObjectSetInteger(0,objectname_local2, OBJPROP_BACK, true);
      //}
      iHourIntervalCount++;
      iHourIntervalCount2++;
      iCountVline++;

      if(!bVlineBack){
        i_minitue0_prev = i;
      }
    } // minute=0


    // Day of week
    // iDenominator_DoW < 0 then only monday
    if(
        bShowDayOfWeek 
      && TimeDayOfWeek(iTime(NULL,0,i)) != TimeDayOfWeek(iTime(NULL,0,i+1))
      && (bShowSatuaday || 6 != TimeDayOfWeek(iTime(NULL,0,i)))
    ){
      // yobi kirikawari
      if(0< iDenominator_DoW || (iDenominator_DoW == -1 && 1 == TimeDayOfWeek(iTime(NULL,0,i)))){
        if (ObjectFind(0,objectname_local3) < 0){
          ObjectCreate(0,objectname_local3, OBJ_TEXT, 0, iTime(NULL,0,i),chart_price_min);
     	    //ObjectCreate(indicator_sname, OBJ_LABEL, 0, 0, 0);
        }else{
          ObjectMove(0, objectname_local3, 0, iTime(NULL,0,i),chart_price_min);
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
    
        ObjectSetString(chart_id,objectname_local3,OBJPROP_TEXT,strDoW[TimeDayOfWeek(iTime(NULL,0,i))]);   // 表示するテキスト
 
        //ObjectSetInteger(chart_id,objectname_local2,OBJPROP_STYLE,STYLE_DOT);  // ラインのスタイル設定
        //ObjectSetInteger(chart_id,objectname_local2,OBJPROP_WIDTH,1);              // ラインの幅設定
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_BACK,false);           // オブジェクトの背景表示設定
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_SELECTABLE,false);     // オブジェクトの選択可否設定
        //ObjectSetInteger(chart_id,objectname_local3,OBJPROP_SELECTED,false);      // オブジェクトの選択状態
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定
        ObjectSetInteger(chart_id,objectname_local3,OBJPROP_ZORDER,0);      // オブジェクトのチャートクリックイベント優先順位

        if(bTimeAtDayChangeOnly){

          // Create TexT
          if (ObjectFind(0,objectname_local2) < 0){
            ObjectCreate(0,objectname_local2, OBJ_TEXT, 0, iTime(NULL,0,i),chart_price_max);
   	        //ObjectCreate(indicator_sname, OBJ_LABEL, 0, 0, 0);
          }else{
            ObjectMove(0, objectname_local2, 0, iTime(NULL,0,i),chart_price_max);
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
          //ObjectSetInteger(chart_id,objectname_local2,OBJPROP_BACK,false);           // オブジェクトの背景表示設定
          ObjectSetInteger(chart_id,objectname_local2,OBJPROP_SELECTABLE,false);     // オブジェクトの選択可否設定
          //ObjectSetInteger(chart_id,objectname_local2,OBJPROP_SELECTED,false);      // オブジェクトの選択状態
          ObjectSetInteger(chart_id,objectname_local2,OBJPROP_HIDDEN,true);         // オブジェクトリスト表示設定
          ObjectSetInteger(chart_id,objectname_local2,OBJPROP_ZORDER,0);      // オブジェクトのチャートクリックイベント優先順位
          x_tmp_Prev = x_tmp;
        }
      }
    }


    //ChartTimePriceToXY(chart_id, 0, iTime(NULL,0,i), chart_price_max, x_tmp, y_tmp);

    //int x_diff = x_tmp_Prev - x_tmp;
    //if(x_diff < 0){
    //  x_diff = -x_diff;
    //}

    //if(Period()==PERIOD_M5){
    //  Print ("i, x_tmp, objectname_local2="+i+"   "+x_tmp+"   "+objectname_local2);
    //}
    //if(x_tmp < 0){
    //  ObjectSetInteger(0,objectname_local2, OBJPROP_BACK, true); // true
    //  ObjectSetInteger(0,objectname_local2, OBJPROP_COLOR, clrNONE);
    //}

    //if(iWindowFirstVisibleBar < iBarsInWindow){
      // right area is blank, almost the latest bar
    //  iBarRatio = 100*i/iWindowFirstVisibleBar;
    //}else{
      // the chart is scrolled back
    //  if(iWindowFirstVisibleBar < i || i < (iWindowFirstVisibleBar-iBarsInWindow)){
        // out of window
    //  }else{
    //    iBarRatio = 100-100*(iWindowFirstVisibleBar-i)/iBarsInWindow;
    //  }
    //}
    //Print ("iBarRatio000="+iBarRatio);
    //if(0 <= i && 85 < iBarRatio && iBarRatio <= 100){
    //  ObjectSetInteger(0,objectname_local2, OBJPROP_BACK, true); // true
    //  ObjectSetInteger(0,objectname_local2, OBJPROP_COLOR, clrNONE);
    //}
  } // for
}
//+------------------------------------------------------------------+

void JST_BackGround(){
  int obj_total= ObjectsTotal(0,0,-1);
  int iBarsInWindow = ChartGetInteger(0,CHART_VISIBLE_BARS,0);
  int iWindowFirstVisibleBar = ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0);
  datetime dtVline;
  int iCountVline = 0;
  int iCountVline2 = 0;
  int iBarShiftTmp;
  color colorChartBG;
  int iBarRatio;
  bool bOutofWin;

  //int wHandle = SendMessageW(ParentWinHandle,WM_MDIGETACTIVE,0,0);
  //Print ("main ce cli wHandle "+wHandle);
  //if(wHandle != ThisWinHandle){
    // if not activated
  //  return;
  //}

  if(false == ChartGetInteger(0,CHART_BRING_TO_TOP)){
    // Do Something...
    // chart is not active
    return;
  }

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
    string name= ObjectName(0,k,0,-1);
    //ObjectSetInteger(0,name, OBJPROP_HIDDEN, false);
    iBarShiftTmp = -1; iBarRatio = -1; bOutofWin = true;
    if( StringFind(StringSubstr(name,0,5),"vline")>=0){
      //if (StringSubstr(name,0,17)=="[Background Box]") {ObjectDelete(name);}
      //if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0) ObjectSetInteger(0,name, OBJPROP_BACK, true);
      //if( StringFind(StringSubstr(name,0,10),"VlineLabel")>=0) ObjectSetInteger(0,name, OBJPROP_HIDDEN, false);

      string vlabel_name = "VlineLabel" + StringSubstr(name,5,-1);

      dtVline = ObjectGetInteger(0,name, OBJPROP_TIME);
      //Print ("dtVline 000="+dtVline);
      iBarShiftTmp = iBarShift(NULL,PERIOD_CURRENT,dtVline,false);

      //Print ("iBarShiftTmp000="+iBarShiftTmp);

      if(iWindowFirstVisibleBar < iBarsInWindow){
        // right area is blank, almost the latest bar
        iBarRatio = 100*iBarShiftTmp/iWindowFirstVisibleBar;
        //Print ("iBarRatio004="+iBarRatio);
        bOutofWin = false;
      }else{
        // the chart is scrolled back
        if(iWindowFirstVisibleBar < iBarShiftTmp || iBarShiftTmp < (iWindowFirstVisibleBar-iBarsInWindow)){
          // out of window
          bOutofWin = true;
        }else{
          bOutofWin = false;
          iBarRatio = 100-100*(iWindowFirstVisibleBar-iBarShiftTmp)/iBarsInWindow;
          //Print ("iBarRatio000="+iBarRatio);
        }
      }
      ObjectSetInteger(0,name, OBJPROP_BACK, true);  //false
      ObjectSetInteger(0,vlabel_name, OBJPROP_BACK, false);

      //Print ("004 bOutofWin,iBarShiftTmp,iBarRatio ="+bOutofWin+"  "+iBarShiftTmp+"  "+iBarRatio);

      if(!bOutofWin && 0 <= iBarShiftTmp && 85 < iBarRatio && iBarRatio <= 100 ){
        ObjectSetInteger(0,name, OBJPROP_BACK, true);  // true
        ObjectSetInteger(0,vlabel_name, OBJPROP_BACK, true);  //true
        //ObjectSetInteger(0,vlabel_name, OBJPROP_COLOR, colorChartBG);
        ObjectSetInteger(0,vlabel_name, OBJPROP_COLOR, clrNONE);
        //Print ("iBarRatio005="+iBarRatio);
      }
      if(iCountVline % iDenominator != 0){
        if(bDenomiBG){
          ObjectSetInteger(0,name, OBJPROP_BACK, true);  //true
          ObjectSetInteger(0,vlabel_name, OBJPROP_BACK, true);
        }else{
          ObjectSetInteger(0,name, OBJPROP_BACK, true);  // true
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
      iBarShiftTmp = iBarShift(NULL,PERIOD_CURRENT,dtVline,true);
      //Print ("iBarShiftTmp="+iBarShiftTmp);
      if(iWindowFirstVisibleBar < iBarsInWindow){
        // right area is blank
        iBarRatio = 100*iBarShiftTmp/iWindowFirstVisibleBar;
        //Print ("iBarRatio001="+iBarRatio);
        bOutofWin = false;
      }else{
        // the chart is scroll back
        if(iWindowFirstVisibleBar < iBarShiftTmp || iBarShiftTmp < (iWindowFirstVisibleBar-iBarsInWindow)){
          // out of window
          bOutofWin = true;
        }else{
          bOutofWin = false;
          iBarRatio = 100-100*(iWindowFirstVisibleBar-iBarShiftTmp)/iBarsInWindow;
          //Print ("iBarRatio002="+iBarRatio);
        }
      }
      if(bDenomiBG){
        if(iCountVline2 % iDenominator2 != 0){
          ObjectSetInteger(0,name, OBJPROP_BACK, true);  // true
          //ObjectSetInteger(0,name, OBJPROP_COLOR, colorChartBG);
          ObjectSetInteger(0,name, OBJPROP_COLOR, clrNONE);
        }else{
          ObjectSetInteger(0,name, OBJPROP_BACK, false);  //false
        }
      }
      //Print ("bOutofWin,iBarShiftTmp,iBarRatio ="+bOutofWin+"  "+iBarShiftTmp+"  "+iBarRatio);

      //Print ("iBarRatio="+iBarRatio);
      if(!bOutofWin && 0 <= iBarShiftTmp && 85 < iBarRatio && iBarRatio <= 100 ){
        //Print ("here 90 percent");

        ObjectSetInteger(0,name, OBJPROP_BACK, true); // true
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
//+-------------------------------------------------------------------------------------------+
void Check_Denomi(){

  bForceVlineAndLabelDisable=false;

  scaleChart_prev = scaleChart;
  scaleChart =  ChartGetInteger(0,CHART_SCALE,0);

  //Print("scaleChart:"+scaleChart);
  iDenominator_DoW = 1;

  if(PERIOD_M1 == Period()){
	  if(scaleChart == 0){
      iDenominator = 2;
      iHourIntervalVline = 1;
      iHourIntervalVlineLabel = 4;
    }else{
      iDenominator = 1;
      iHourIntervalVline = 1;
      iHourIntervalVlineLabel = 1;
    }
  }else if(PERIOD_M5 == Period()){
    if(scaleChart == 0){
      // minimum scale
      // vline
      iDenominator = 8;
      // label
	   iDenominator2 = 8;
      iHourIntervalVline = 12;
      iHourIntervalVlineLabel = 8;
	  }else if(scaleChart == 1){
	    iDenominator = 4;
	    iDenominator2 = 2;
      iHourIntervalVline = 6;
      iHourIntervalVlineLabel = 8;
	  }else if(scaleChart == 2){
	    iDenominator = 2;
	    iDenominator2 = 1;
      iHourIntervalVline = 2;
      iHourIntervalVlineLabel = 8;
	  }else{
	    iDenominator = 1;
	    iDenominator2 = 1;
      iHourIntervalVline = 1;
      iHourIntervalVlineLabel = 1;
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
      bForceVlineAndLabelDisable=true;
  	  iDenominator = 96;
  	  iDenominator2 = 32;
    }else if(scaleChart <= 1){
      bForceVlineAndLabelDisable=true;
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
      bForceVlineAndLabelDisable=true;
  	   iDenominator = 96;
  	   iDenominator2 = 32;
      iDenominator_DoW = -1;
    }else if(scaleChart <= 1){
      bForceVlineAndLabelDisable=true;
  	   iDenominator = 64;
  	   iDenominator2 = 32;
      iDenominator_DoW = -1;
    }else if(scaleChart <= 2){
      bForceVlineAndLabelDisable=true;
  	  iDenominator = 24;
  	  iDenominator2 = 8;
    }else if(scaleChart <= 3){
      bForceVlineAndLabelDisable=true;
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
  int obj_total= ObjectsTotal(0,0,-1);
  color colorChartJST, colorChartJSTtmp;
  color colorChartBG;
  bool bcolorChartJSTSet = false;

  colorChartBG = ChartGetInteger(0,CHART_COLOR_BACKGROUND,OBJPROP_COLOR);
  for (int k= obj_total; k>=0; k--){
    string name= ObjectName(0,k,0,-1);
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
    string name= ObjectName(0,k,0,-1);
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
