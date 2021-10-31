// ---------------------------------------------------------------------------------------
//                                  XXXXXXXX FORMFILE
// ---------------------------------------------------------------------------------------

// As of v1.0.0, all configuration options have been moved to a separate file to prevent
// overwriting server and system settings when new formfile versions are released.  The
// standard configuration file associated with this formfile is nuio_xxxx.nss.

// ---------------------------------------------------------------------------------------
//                          DO NOT MAKE ANY CHANGES BELOW THIS LINE
// ---------------------------------------------------------------------------------------

#include "nuio_xxx"
#include "nui_i_main"
#include "util_i_csvlists"

const string VERSION = "1.0.0";
const string IGNORE_FORM_EVENTS = "";

void NUI_HandleFormDefinition()
{
    string sFormID = "xxxx";

    NUI_CreateForm(sFormID);
        NUI_SetTitle(TITLE);
        NUI_BindGeometry("geometry");
    {
    } NUI_SaveForm();

    Notice("Defining form " + sFormID + " (Version " + VERSION + ")");
}

void UpdateBinds(string sBind, int nToken = -1, int bSetDefaults = FALSE)
{
    if (nToken == -1)
        nToken = NuiGetEventWindow();

    json jReturn = JsonNull();

    if (sBind == "geometry")
        jReturn = NUI_DefineRectangle(-1.0, -1.0, 600.0, 250.0);

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

    // Do form_open/default stuff here

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

    }
}
