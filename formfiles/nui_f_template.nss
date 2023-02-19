/// ----------------------------------------------------------------------------
/// @file   nuif_toc.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Table of Contents formfile.
/// ----------------------------------------------------------------------------

//#include "nui_i_library"
#include "nui_i_main"
#include "util_i_csvlists"
#include "util_i_debug"

const string FORM_ID = "<form_name>";
const string VERSION = "0.1.0";
const string IGNORE_FORM_EVENTS = "";


void DefineForm()
{
    //Form Definition
    NUI_CreateForm(FORM_ID);
    {
        NUI_AddColumn();


        NUI_CloseColumn();
    }

    // Profile Definition
    NUI_CreateDefaultProfile();
    {
        NUI_SetProfileBind("geometry", NUI_DefineRectangle(100.0, 100.0, 650.0, 610.0));
    }
}

void BindForm()
{
    json jValue, jBinds = NUI_GetOrphanBinds(FORM_ID);
    int nToken = NuiFindWindow(OBJECT_SELF, FORM_ID);

    int n; for (n; n < JsonGetLength(jBinds); n++)
    {
        string sBind = JsonGetString(JsonArrayGet(jBinds, n));

   
        NUI_SetBind(OBJECT_SELF, nToken, sBind, jValue);
    }
}

void HandleNUIEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

}

void HandleModuleEvents()
{

}
