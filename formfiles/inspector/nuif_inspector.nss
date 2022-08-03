// ---------------------------------------------------------------------------------------
//                                  INSPECTOR FORMFILE
// ---------------------------------------------------------------------------------------

// As of v1.0.0, all configuration options have been moved to a separate file to prevent
// overwriting server and system settings when new formfile versions are released.  The
// standard configuration file associated with this formfile is nuio_xxxx.nss.

// ---------------------------------------------------------------------------------------
//                          DO NOT MAKE ANY CHANGES BELOW THIS LINE
// ---------------------------------------------------------------------------------------

//#include "nuio_inspector"
#include "nui_i_main"
#include "util_i_csvlists"

const string VERSION = "1.0.0";
const string IGNORE_FORM_EVENTS = "";

const string TITLE = "NUI Form Inspector";
const string sFormID = "nui_inspector";

void NUI_UpdateInspectionForm()
{
    // Should only be called during a form event.

    object oPC = NuiGetEventPlayer();
    int nInspectorToken = NuiFindWindow(oPC, sFormID);
    if (!nInspectorToken)
    {
        NUI_Debug("Inspector Update: Window Not Found", NUI_DEBUG_SEVERITY_ERROR);
        return;
    }

    int nToken = NuiGetEventWindow();
    string sEvent = NuiGetEventType();
    string sElem = NuiGetEventElement();
    int nIdx = NuiGetEventArrayIndex();
    string sWndId = NuiGetWindowId(oPC, nToken);
    json jPayld = NuiGetEventPayload();

    if (JsonGetInt(NuiGetBind(oPC, nInspectorToken, "debug_events")))
    {
        string msg = " >> NUI Inspector <<" +
            "\n  Event: " + sEvent + 
            "\n  Token: " + IntToString(nToken) +
            "\n  Window ID: " + sWndId +
            "\n  Element ID: " + sElem +
            (nIdx > -1 ? ("[" + IntToString(nIdx) + "]") : "") +
            "\n  Payload: " + JsonDump(jPayld);

        if (sEvent == "watch")
            msg += "\n  Watch Value: " + JsonDump(NuiGetBind(oPC, nToken, sElem));
        
        NUI_Debug(msg, NUI_DEBUG_SEVERITY_NOTICE);
    }

    int nTargetToken = JsonGetInt(NuiGetBind(oPC, nInspectorToken, "selected_window_token"));

    if (sEvent == "open" || (sEvent == "close" && sWndId != sFormID))
    {
        NUI_Debug(" >> NUI Inspector <<" +
            "\n  Refreshing Form Data", NUI_DEBUG_SEVERITY_NOTICE);

        json wndlst = JsonArray();
        int nth = 0;
        int itertoken = NuiGetNthWindow(oPC, nth);
        while (itertoken > 0)
        {
            if (sEvent != "close" || itertoken != nToken)
            {
                string name = NuiGetWindowId(oPC, itertoken);
                wndlst = JsonArrayInsert(wndlst, JsonArrayInsert(JsonArrayInsert(JsonArray(), JsonString(name)), JsonInt(itertoken)));
            }

            itertoken = NuiGetNthWindow(oPC, ++nth);
        }

        NuiSetBind(oPC, nInspectorToken, "window_id_list", wndlst);

        if (sEvent == "close" && nToken == nTargetToken)
        {
            // TODO
            // Remove window from listing?
            // Pick the next/previous window and refresh?
        }
    }

    if (sWndId != sFormID)
        return;

    int updateview = 0;

    if (sEvent == "watch" && sElem == "selected_window_token")
        updateview = 1;
    
    if (sEvent == "click" && sElem == "refresh")
        updateview = 1;

    if (sEvent == "watch" && sElem == "bindvalues_bool")
    {
        json labels = NuiGetBind(oPC, nToken, "bindlabels_bool");
        json watchval = NuiGetBind(oPC, nToken, sElem);

        int i; for (i = 0; i < JsonGetLength(labels); i++)
        {
            string bind = JsonGetString(JsonArrayGet(labels, i));

            json ourval = JsonArrayGet(watchval, i);
            json theirval = NuiGetBind(oPC, nTargetToken, bind);
            if (ourval != theirval)
            {
                NUI_Debug(" >> NUI Inspector <<" + 
                    "\n  Synchronising bind: " + bind, NUI_DEBUG_SEVERITY_NOTICE);
                NuiSetBind(oPC, nTargetToken, bind, ourval);
            }
        }
    }

    if (updateview)
    {
        // Grab all binds from target window and add to list view.
        json bindlabels_bool = JsonArray();
        json bindvalues_bool = JsonArray();
        json bindlabels_readonly = JsonArray();
        json bindvalues_readonly = JsonArray();

        int nth = 0;
        string bind = NuiGetNthBind(oPC, nTargetToken, FALSE, nth);
        while (bind != "")
        {
            // Never show bindlabels or values to avoid recursion terror.
            string prefix = GetSubString(bind, 0, 10);
            if (prefix != "bindlabels" && prefix != "bindvalues")
            {
                json bval = NuiGetBind(oPC, nTargetToken, bind);
                if (JsonGetType(bval) == JSON_TYPE_BOOL)
                {
                    bindlabels_bool = JsonArrayInsert(bindlabels_bool, JsonString(bind));
                    bindvalues_bool = JsonArrayInsert(bindvalues_bool, bval);
                }
                else
                {
                    string val = JsonDump(NuiGetBind(oPC, nTargetToken, bind));
                    bindlabels_readonly = JsonArrayInsert(bindlabels_readonly, JsonString(bind));
                    bindvalues_readonly = JsonArrayInsert(bindvalues_readonly, JsonString(val));
                }
            }

            bind = NuiGetNthBind(oPC, nTargetToken, FALSE, ++nth);
        }

        NuiSetBind(oPC, nInspectorToken, "bindlabels_bool", bindlabels_bool);
        NuiSetBind(oPC, nInspectorToken, "bindvalues_bool", bindvalues_bool);
        NuiSetBind(oPC, nInspectorToken, "bindlabels_readonly", bindlabels_readonly);
        NuiSetBind(oPC, nInspectorToken, "bindvalues_readonly", bindvalues_readonly);
        NUI_Debug(" >> NUI Inspector <<" +
            "\n  Bind list updated!", NUI_DEBUG_SEVERITY_NOTICE);
    }
}

void NUI_HandleFormDefinition()
{
    NUI_CreateForm(sFormID, VERSION);
        NUI_SetTitle(TITLE);
        NUI_BindGeometry("geometry");
        NUI_SetOrientation(NUI_ORIENTATION_ROWS);
        NUI_SetResizable(TRUE);
        NUI_SetCollapsible(FALSE);
        NUI_SetTransparent(FALSE);
        NUI_SetBorderVisible(TRUE);
        NUI_SetCustomProperty("toc", jTRUE);
    {
        NUI_AddRow();
            NUI_AddSpacer();
            NUI_AddCombobox();
                NUI_BindElements("window_id_list");
                NUI_BindValue("selected_window_token");
            NUI_AddCheckbox();
                NUI_SetLabel("Print all events");
                NUI_BindValue("debug_events");
            NUI_AddSpacer();

        NUI_AddRow();
            NUI_AddListbox();
                NUI_BindRowCount("bindlabels_bool");
                NUI_SetRowHeight(25.0);
            {
                NUI_AddCheckbox();
                    NUI_BindLabel("bindlabels_bool");
                    NUI_BindValue("bindvalues_bool");
            } NUI_CloseListbox();
        
        NUI_AddRow();
            NUI_AddListbox();
                NUI_BindRowCount("bindlabels_readonly");
                NUI_SetRowHeight(25.0);
            {
                NUI_AddLabel();
                    NUI_BindValue("bindlabels_readonly");
                        NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                        NUI_BindTooltip("bindlabels_readonly");
                NUI_AddLabel();
                    NUI_BindValue("bindvalues_readonly");
                        NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                        NUI_BindTooltip("bindvalues_readonly");
            } NUI_CloseListbox();

        NUI_AddRow();
            NUI_AddSpacer();
            NUI_AddCommandButton("refresh");
                NUI_SetLabel("Refresh");
            NUI_AddSpacer();
    } NUI_SaveForm();
}

void UpdateBinds(string sBind, int nToken = -1, int bSetDefaults = FALSE)
{
    NUI_Debug("Updating Binds (nuif_inspector): " + sBind, NUI_DEBUG_SEVERITY_WARNING);

    if (nToken == -1)
        nToken = NuiGetEventWindow();

    json jReturn = JsonNull();

    if (sBind == "geometry")
        jReturn = NUI_DefineRectangle(10.0, 10.0, 400.0, 600.0);

    if (sBind == "debug_events")
        jReturn = jTRUE;

    if (bSetDefaults == TRUE)
        NUI_DelayBindValue(OBJECT_SELF, nToken, sBind, jReturn);
    else
        NUI_SetBindValue(OBJECT_SELF, nToken, sBind, jReturn);
}

void NUI_HandleFormBinds(string sProfile = "")
{
    NUI_Debug("NUI_HandleFormBinds (nuif_inspector)", NUI_DEBUG_SEVERITY_WARNING);

    object oPC = OBJECT_SELF;
    struct NUIBindData bd = NUI_GetBindData();
    int n;

    int nInspectorToken = NuiFindWindow(oPC, sFormID);

    // Set default behavior and bind watches here.
    NUI_SetBindWatch(oPC, nInspectorToken, "selected_window_token", TRUE);
    NUI_SetBindWatch(oPC, nInspectorToken, "bindvalues_bool", TRUE);

    for (n = 0; n < bd.nCount; n++)
    {
        struct NUIBindArrayData bad = NUI_GetBindArrayData(bd.jBinds, n);
        UpdateBinds(bad.sBind, bd.nToken, TRUE);
    }
}

void NUI_HandleFormEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    Warning("Form Event: " + ed.sEvent);

    if (HasListItem(IGNORE_FORM_EVENTS, ed.sEvent))
        return;

    NUI_UpdateInspectionForm();

    /*
    if (ed.sEvent == "watch")
    {

    }
    */
}
