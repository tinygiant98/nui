/// ----------------------------------------------------------------------------
/// @file   nui_f_colorpick.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Color Picker formfile.
/// ----------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
//                          DO NOT MAKE ANY CHANGES BELOW THIS LINE
// ---------------------------------------------------------------------------------------

#include "nui_c_colorpick"
#include "nui_i_library"
#include "util_i_csvlists"
#include "util_i_color"

const string VERSION = "0.1.1";
const string FORM_ID = "color_picker";
const string IGNORE_FORM_EVENTS = "mouseup,mousedown,mousescroll,close,range";

void cp_UpdateColorBinds(object oPlayer, int nToken)
{
    json jColor = NuiGetBind(oPlayer, nToken, "cpPicker:color");
    int r = JsonGetInt(JsonObjectGet(jColor, "r"));
    int g = JsonGetInt(JsonObjectGet(jColor, "g"));
    int b = JsonGetInt(JsonObjectGet(jColor, "b"));
    int a = JsonGetInt(JsonObjectGet(jColor, "a"));

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
    NuiSetBind(oPlayer, nToken, "cc", JsonString(GetColorCode(r, g, b) + " "));

    string sRHex = FormatInt(r, "\\x%02X");
    string sGHex = FormatInt(g, "\\x%02X");
    string sBHex = FormatInt(b, "\\x%02X");

    NuiSetBind(oPlayer, nToken, "ec", JsonString(sRHex + sGHex + sBHex));
}

void BindForm()
{
    json jBinds = NUI_GetOrphanBinds(FORM_ID);
    int nToken = NuiFindWindow(OBJECT_SELF, FORM_ID);

    int n; for (n; n < JsonGetLength(jBinds); n++)
    {
        string sValue, sBind = JsonGetString(JsonArrayGet(jBinds, n));
        json jValue = JsonNull();

        if (sValue != "")
            NUI_SetBind(OBJECT_SELF, FORM_ID, sBind, sValue);
        else if (jValue != JsonNull())
            NUI_SetBindJ(OBJECT_SELF, FORM_ID, sBind, jValue);
    }
}

void HandleNUIEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    if (HasListItem(IGNORE_FORM_EVENTS, ed.sEvent))
        return;

    if (ed.sEvent == "watch")
    {
        if (ed.sControlID == "cpPicker:color")
            cp_UpdateColorBinds(ed.oPC, ed.nToken);
    }
    else if (ed.sEvent == "click")
    {
        if (ed.sControlID == "cmdClose")
        {
            json jColor = NUI_GetBind(ed.oPC, FORM_ID, "cp_color");
            SetLocalJson(GetModule(), COLOR_VARNAME, jColor);
            NUI_CloseForm(ed.oPC, FORM_ID);
        }
    }
    else if (ed.sEvent == "open")
    {
        cp_UpdateColorBinds(ed.oPC, ed.nToken);
    }
}

void HandleModuleEvents()
{

}

void DefineForm()
{
    float fLabelHeight = 25.0;
    string sRed = NUI_DefineRGBColor(199, 27, 27);
    string sGreen = NUI_DefineRGBColor(51, 177, 30);
    string sBlue = NUI_DefineRGBColor(121, 122, 220);
    string sHex = NUI_DefineRGBColor(176, 209, 34);
    string sCode = NUI_DefineRGBColor(28, 197, 203);

    NUI_CreateForm(FORM_ID, VERSION);
        NUI_SetTitle("Color Picker");
        NUI_SetTOCTitle("Color Picker");
    {
        NUI_AddColumn();
            NUI_AddRow();
                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetWidth(190.0);
                        NUI_SetHeight(140.0);
                        NUI_SetPadding(0.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColorPicker("cpPicker");
                            NUI_SetWidth(200.0);
                            NUI_SetHeight(140.0);
                            NUI_BindColor("cpPicker:color", TRUE);
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetHeight(140.0);
                        NUI_SetPadding(0.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddRow();
                            NUI_AddColumn();
                                NUI_AddLabel();
                                    NUI_SetWidth(75.0);
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetForegroundColor(sRed);
                                    NUI_SetLabel("Red");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetForegroundColor(sGreen);
                                    NUI_SetLabel("Green");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetForegroundColor(sBlue);
                                    NUI_SetLabel("Blue");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetLabel("Alpha");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetLabel("NWN Code");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                    NUI_SetForegroundColor(sCode);
                            NUI_CloseColumn();

                            NUI_AddColumn();
                            {
                                int n; for (n; n < 4; n++)
                                {
                                    NUI_AddSpacer();
                                        NUI_SetWidth(10.0);
                                        NUI_SetHeight(fLabelHeight);
                                }
                            }
                            NUI_CloseColumn();

                            NUI_AddColumn();
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetWidth(65.0);
                                    NUI_SetForegroundColor(sRed);
                                    NUI_BindLabel("r");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetForegroundColor(sGreen);
                                    NUI_BindLabel("g");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetForegroundColor(sBlue);
                                    NUI_BindLabel("b");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_BindLabel("a");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddLabel();
                                NUI_AddTextbox();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_BindValue("cc");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                    NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                                    NUI_SetForegroundColor(sCode);
                            NUI_CloseColumn();

                            NUI_AddColumn();
                            {
                                int n; for (n; n < 4; n++)
                                {
                                    NUI_AddSpacer();
                                        NUI_SetWidth(10.0);
                                        NUI_SetHeight(fLabelHeight);
                                }
                            }
                            NUI_CloseColumn();

                            NUI_AddColumn();
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetWidth(80.0);
                                    NUI_SetLabel("Hue");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetLabel("Saturation");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetLabel("Value");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetForegroundColor(sHex);
                                    NUI_SetLabel("Hex");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetLabel("Escape Code");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                            NUI_CloseColumn();

                            NUI_AddColumn();
                            {
                                int n; for (n; n < 4; n++)
                                {
                                    NUI_AddSpacer();
                                        NUI_SetWidth(10.0);
                                        NUI_SetHeight(fLabelHeight);
                                }
                            }
                            NUI_CloseColumn();

                            NUI_AddColumn();
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_BindLabel("h");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_BindLabel("s");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_BindLabel("v");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddLabel();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_SetForegroundColor(sHex);
                                    NUI_BindLabel("hex");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                //NUI_AddLabel();
                                NUI_AddTextbox();
                                    NUI_SetHeight(fLabelHeight);
                                    NUI_BindValue("ec");
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                    NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                            NUI_CloseColumn();
                        NUI_CloseRow();
                    } NUI_CloseGroup();
                NUI_CloseColumn();
            NUI_CloseRow();

            NUI_AddRow(35.0);
                NUI_AddSpacer();
                    NUI_SetWidth(60.0);
                    NUI_AddCanvas();
                    {
                        string sPoints = NUI_GetRectanglePoints(0.0, 0.0, 60.0, 35.0);
                        NUI_DrawLine(sPoints);
                            NUI_SetFill(TRUE);
                            NUI_BindColor("cpPicker:color");
                    } NUI_CloseCanvas();
              
                NUI_AddLabel();
                    NUI_SetLabel("The quick brown fox jumped over the lazy dog.");
                    NUI_BindForegroundColor("cpPicker:color");

                NUI_AddCommandButton("cmdClose");
                    NUI_SetLabel("Select and Close");

            NUI_CloseRow();

        NUI_CloseColumn();
    }

    NUI_CreateDefaultProfile();
        NUI_SetProfileBind("geometry", NUI_DefineRectangle(100.0, 100.0, 590.0, 217.0));
        NUI_SetProfileBind("cpPicker:color", NUI_DefineRGBColor(255, 255, 255));
}
        