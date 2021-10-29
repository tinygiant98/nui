#include "nui_i_main"

int BEHAVIOR_DECAY = 0;
int BEHAVIOR_GROW = 1;

// CONFIGURATION

// Form ID, must be unique to all forms in your module.
string FORM_ID = "c";


// FORM CONFIGURATION
// Set the origin of the form; this is the top left corner of the form.
// This form is designed to be modal, so it should likely be attached
//  to the edge of the player window since the player will not be able to
//  close the window.  Note that these values are not constants, so you
//  can assign a function to these values to determine approriate location
//  based on user graphics settings, etc.
float FORM_ORIGIN_X = 300.0;
float FORM_ORIGIN_Y = 0.0;
float FORM_WIDTH = 375.0;
float FORM_HEIGHT = 45.0;   // will grow/shrink as required, this is a minimum 






















string CONTROL_ID = "cooldown_bar";

int   SERIES_MAXIMUM = -1;
float SERIES_LINEWIDTH = 15.0;
float SERIES_HEIGHT = 15.0;
int   SERIES_BEHAVIOR = BEHAVIOR_DECAY;

string DRAWLIST_PATH = "/root/children/0/children/0/children/0/draw_list";

struct SeriesData {
    json jTime;
    json jTag;
    int nBehavior;
    
};

struct SeriesData GetSeriesData(json jData, int nIndex)
{
    struct SeriesData sd;
    
    json jSeries = JsonArrayGet(jData, nIndex);

    sd.jTag = JsonObjectGet(jSeries, "tag");
    sd.jTime = JsonObjectGet(jSeries, "time");

    return sd;
}

/*
json HandleBehavior()
{


    json jData = NUI_GetBuildData(FORM_ID, CONTROL_ID);
    int n, nCount = JsonGetLength(jData);

    json jControlData = JsonObjectGet(jData, "control");
    json jSeriesData = JsonObjectGet(jData, "series");

    // Do control-level stuff here, if any


    // Do series loop stuff here
    for (n = 0; n < nCount; n++)
    {
        struct SeriesData sd = GetSeriesData(jData, n);

    }


}*/


// TODO accept multiple bars with varying timers.
// Remove bars (optionally) when they get to 0 (or 100%)
// Set a script to run on the bar when count is complete
// Set color for bar
// Optionally allow timer display (seconds remaining)

// Need a custom data set for this capability
// Max, min, time, script, count up/down, color
// Should be a "series" for each bar

void HandleBehavior(int nToken, int n = 1)
{
    float fMax = 330.0;
    float fMin = 2.0;

    json jParameters = NUI_GetUserData("c", "cooldown_line");

    float fSeconds = JsonGetFloat(JsonObjectGet(jParameters, "time"));
    float fStep = (fMax - fMin) / fSeconds;

    string sText = IntToString(FloatToInt(fSeconds) - n) + "s";

    json jPoints = NuiGetBind(OBJECT_SELF, nToken, "cooldown_points");
    float x2 = JsonGetFloat(JsonArrayGet(jPoints, 2)) - fStep;
          x2 = fmax(0.0, x2);

    jPoints = JsonArraySet(jPoints, 2, JsonFloat(x2));
    NuiSetBind(OBJECT_SELF, nToken, "cooldown_points", jPoints);
    NuiSetBind(OBJECT_SELF, nToken, "countdown_text", JsonString(sText));

    if (x2 <= 0.0)
    {
        NuiDestroy(OBJECT_SELF, nToken);
        return;
    }

    DelayCommand(1.0, HandleBehavior(nToken, ++n));
}

void NUI_HandleFormDefinition()
{
    NUI_CreateForm(FORM_ID);
        NUI_BindGeometry("geometry");
        NUI_SetModal(TRUE);
        NUI_SetResizable(FALSE);
        NUI_SetCollapsible(FALSE);
        NUI_SetBorderVisible(FALSE);
    {
        NUI_AddCustomControl("cooldown_bars", "cooldown_base");
            NUI_SetHeight(10.0);
            NUI_SetWidth(30.0);
            NUI_SetCustomControlProperty(NUI_PROPERTY_BUILDDATA, "line_thickness", JsonFloat(10.0));    // change this to user-friendly function name
            NUI_SetCustomProperty("custom_control", JsonBool(TRUE));

/*
            NUI_AddCanvas();                
            {
                NUI_DrawLine(JsonNull());
                    NUI_SetID("cooldown_line_1");
                    NUI_BindPoints("cooldown_points_1");
                    NUI_SetLineThickness(20.0);
                    NUI_BindDrawColor("cooldown_color_1");
                
                NUI_DrawText(JsonNull(), "");
                    NUI_BindText("cooldown_label_1");
                    NUI_BindDrawColor("cooldown_label_color_1");

                NUI_DrawText(JsonNull(), "");
                    NUI_BindText("cooldown_time_1");
                    NUI_BindDrawColor("cooldown_time_color_1");
            } NUI_CloseCanvas();
            NUI_SetScissor(FALSE);
*/
    } NUI_SaveForm();
}

void NUI_HandleFormBinds()
{
    object oPC = OBJECT_SELF;
    struct NUIBindData bd = NUI_GetBindData();
    int n;

    for (n = 0; n < bd.nCount; n++)
    {
        struct NUIBindArrayData bad = NUI_GetBindArrayData(bd.jBinds, n);

        json jReturn;

        if (bad.sBind == "geometry")
            jReturn = NUI_DefineRectangle(FORM_ORIGIN_X, FORM_ORIGIN_Y, FORM_WIDTH, FORM_HEIGHT);
            
        NUI_SetBindValue(oPC, bd.nToken, bad.sBind, jReturn);
    }
}

void NUI_HandleFormEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    if (ed.sEvent == "open")
        {}//NUI_PopulateBuildJSON(FORM_ID, CONTROL_ID, "cooldown_bars");
    else if (ed.sEvent == "mouseup" && ed.sControlID == "cooldown_base")
        NuiDestroy(ed.oPC, ed.nFormToken);
}

void NUI_HandleFormBuilds()
{
    string sVarName = "SERIESDATA#" + FORM_ID + "#" + CONTROL_ID;

    // Can this be passed as an argument?
    json jSeriesData = GetLocalJson(OBJECT_SELF, sVarName);
    DeleteLocalJson(OBJECT_SELF, sVarName);

    int nIndex = NUI_GetAndIncrementBuildSeriesIndex(FORM_ID, CONTROL_ID);
    int nCount = NUI_GetBuildSeriesCount(FORM_ID, CONTROL_ID, 3);
}

//void main() {}
