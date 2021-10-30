// ---------------------------------------------------------------------------------------
//                            COLOR PICKER FORMFILE
// ---------------------------------------------------------------------------------------

// As of v1.0.0, all configuration options have been moved to a separate file to prevent
// overwriting server and system settings when new formfile versions are released.  The
// standard configuration file associated with this formfile is nuio_appedit.nss.

// ---------------------------------------------------------------------------------------
//                          DO NOT MAKE ANY CHANGES BELOW THIS LINE
// ---------------------------------------------------------------------------------------

#include "nuio_cp"
#include "nui_i_main"
#include "util_i_csvlists"

const string VERSION = "1.0.0";
const string IGNORE_FORM_EVENTS = "mouseup,mousedown,mousescroll,open,close,range";

void NUI_HandleFormDefinition()
{
    string sFormID = "color_picker";

    NUI_CreateTemplateControl("cp_label");
    {
        NUI_AddLabel();
            NUI_SetHeight(25.0);
    } NUI_SaveTemplateControl();

    NUI_CreateForm(sFormID);
        NUI_SetTitle(TITLE);
        NUI_BindGeometry("geometry");
        NUI_SetOrientation(NUI_ORIENTATION_ROWS);
    {
        NUI_AddColumn();

        NUI_AddControlGroup();
            NUI_SetWidth(200.0);
            NUI_SetHeight(140.0);
            NUI_SetPadding(0.0);
            NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
        {
            NUI_AddColorPicker();
                NUI_SetWidth(200.0);
                NUI_SetHeight(140.0);
                NUI_SetID("cp");
                NUI_BindColor("cp_color");
        } NUI_CloseControlGroup();
        
        NUI_AddColumn();

        NUI_AddControlGroup();
            NUI_SetOrientation(NUI_ORIENTATION_ROWS);
            NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
            NUI_SetHeight(140.0);
            NUI_SetPadding(0.0);
            /*
            NUI_AddCanvas();
            {
                NUI_DrawRectangle(170.0,5.0,2.0,131.0);
                NUI_DrawRectangle(174.0,100.0,186.0,2.0);
            } NUI_CloseCanvas();*/
        {
            NUI_AddColumn();
                NUI_AddTemplateControl("cp_label");
                    NUI_SetLabel(RED);
                    NUI_SetRGBForegroundColor(199, 27, 27);
                NUI_AddTemplateControl("cp_label");
                    NUI_SetLabel(GREEN);
                    NUI_SetRGBForegroundColor(51, 177, 30);
                NUI_AddTemplateControl("cp_label");
                    NUI_SetLabel(BLUE);
                    NUI_SetRGBForegroundColor(121, 122, 220);
                NUI_AddTemplateControl("cp_label");
                    NUI_SetLabel(ALPHA);

            NUI_AddColumn();
                NUI_AddTemplateControl("cp_label");
                    NUI_BindLabel("r");
                    NUI_SetRGBForegroundColor(199, 27, 27);
                NUI_AddTemplateControl("cp_label");
                    NUI_BindLabel("g");
                    NUI_SetRGBForegroundColor(51, 177, 30);
                NUI_AddTemplateControl("cp_label");
                    NUI_BindLabel("b");
                    NUI_SetRGBForegroundColor(121, 122, 220);
                NUI_AddTemplateControl("cp_label");
                    NUI_BindLabel("a");

            NUI_AddColumn();
                NUI_AddTemplateControl("cp_label");
                    NUI_SetLabel(HUE);
                NUI_AddTemplateControl("cp_label");
                    NUI_SetLabel(SATURATION);
                NUI_AddTemplateControl("cp_label");
                    NUI_SetLabel(VALUE);
                NUI_AddTemplateControl("cp_label");
                    NUI_SetLabel(HEX);
                    NUI_SetRGBForegroundColor(176, 209, 34);

            NUI_AddColumn();
                NUI_AddTemplateControl("cp_label");
                    NUI_BindLabel("h");
                NUI_AddTemplateControl("cp_label");
                    NUI_BindLabel("s");
                NUI_AddTemplateControl("cp_label");
                    NUI_BindLabel("v");
                NUI_AddTemplateControl("cp_label");
                    NUI_BindLabel("hex");
                    NUI_SetRGBForegroundColor(176, 209, 34);
        } NUI_CloseControlGroup();

        NUI_AddRow();
            NUI_AddSpacer();
            NUI_AddSpacer();
            NUI_AddCommandButton("command_close");
                NUI_SetLabel(CLOSE);
                NUI_SetHeight(35.0);
                NUI_SetVisible(TRUE);
    } NUI_SaveForm();

    Notice("Defining form " + sFormID + " (Version " + VERSION + ")");
}

void UpdateColors(object oPlayer, int nToken)
{
    json jColor = NuiGetBind(oPlayer, nToken, "cp_color");
    int r = JsonGetInt(JsonObjectGet(jColor, NUI_PROPERTY_R));
    int g = JsonGetInt(JsonObjectGet(jColor, NUI_PROPERTY_G));
    int b = JsonGetInt(JsonObjectGet(jColor, NUI_PROPERTY_B));
    int a = JsonGetInt(JsonObjectGet(jColor, NUI_PROPERTY_A));

    struct RGB rgb = GetRGB(r, g, b);
    struct HSV hsv = RGBToHSV(rgb);
    int hex = RGBToHex(rgb);

    NuiSetBind(oPlayer, nToken, "r", JsonInt(r));
    NuiSetBind(oPlayer, nToken, "g", JsonInt(g));
    NuiSetBind(oPlayer, nToken, "b", JsonInt(b));
    NuiSetBind(oPlayer, nToken, "a", JsonInt(a));

    NuiSetBind(oPlayer, nToken, "h", JsonFloat(hsv.h));
    NuiSetBind(oPlayer, nToken, "s", JsonFloat(hsv.s));
    NuiSetBind(oPlayer, nToken, "v", JsonFloat(hsv.v));

    string sHex = IntToHexString(hex);
           sHex = GetStringRight(sHex, 6);

    NuiSetBind(oPlayer, nToken, "hex", JsonString(sHex));

    NuiSetBindWatch(oPlayer, nToken, "cp_color", TRUE);
}

void SetWatches(object oPC, int nToken)
{
    NuiSetBindWatch(oPC, nToken, "cp_color", TRUE);
}

void UpdateBinds(string sBind, int nToken = -1, int bSetDefaults = FALSE)
{
    if (nToken == -1)
        nToken = NuiGetEventWindow();

    json jReturn = JsonNull();

    if (sBind == "geometry")
        jReturn = NUI_DefineRectangle(-1.0, -1.0, 600.0, 250.0);
    else if (sBind == "cp_color")
        jReturn = NUI_DefineRGBColor(255, 255, 255);

    if (bSetDefaults == TRUE)
        NUI_DelayBindValue(OBJECT_SELF, nToken, sBind, jReturn);
    else
        NUI_SetBindValue(OBJECT_SELF, nToken, sBind, jReturn);
}

void NUI_HandleFormBinds()
{
    object oPC = OBJECT_SELF;
    struct NUIBindData bd = NUI_GetBindData();
    int n;

    SetWatches(OBJECT_SELF, NuiFindWindow(OBJECT_SELF, bd.sFormID));

    for (n = 0; n < bd.nCount; n++)
    {
        struct NUIBindArrayData bad = NUI_GetBindArrayData(bd.jBinds, n);
        UpdateBinds(bad.sBind, bd.nToken, TRUE);
    }
}

void NUI_HandleFormEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    if (HasListItem(IGNORE_FORM_EVENTS, ed.sEvent))
        return;

    if (ed.sEvent == "watch")
    {
        if (ed.sControlID == "cp_color")
            UpdateColors(ed.oPC, ed.nFormToken);
    }
    else if (ed.sEvent == "click")
    {
        if (ed.sControlID == "command_close")
        {
            json jColor = NuiGetBind(ed.oPC, ed.nFormToken, "cp_color");
            SetLocalJson(GetModule(), COLOR_VARNAME, jColor);
            NUI_DestroyForm(ed.oPC, ed.nFormToken);
        }
    }
}
