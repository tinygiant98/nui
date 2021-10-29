#include "nui_i_main"

// CONFIGURATION
string CONTROL_NAME = "cooldown_bars";
json  jCONTROL_NAME = JsonString(CONTROL_NAME);

void NUI_HandleAddSeries(string sFormID, string sControlID)
{
    Notice("Running NUI_HandleAddSeries in nui_c_cooldown");
    Notice("  > sFormID - " + sFormID);
    Notice("  > sControlID - " + sControlID);

    object oPC = OBJECT_SELF;

    json jSeries = GetLocalJson(oPC, "SERIESDATA#" + sFormID + "#" + sControlID);
    string sMinimumProperties = "color, tag, text, time, line_thickness";

    Notice("  > jSeries - " + JsonDump(jSeries));

    json jKeys = JsonObjectKeys(jSeries);
    int n, nKeys = JsonGetLength(jKeys);

    for (n = 0; n < nKeys; n++)
    {
        string sKey = JsonGetString(JsonArrayGet(jKeys, n));

        if (JsonObjectGet(jSeries, sKey) != JsonNull())
            sMinimumProperties = RemoveListItem(sMinimumProperties, sKey);
    }

    if (CountList(sMinimumProperties) > 0)
    {
        json jBuildData = NUI_GetBuildData(sFormID, sControlID);
        json jKeys = JsonObjectKeys(jBuildData);
        int n, nKeys = JsonGetLength(jKeys);

        for (n = 0; n < nKeys; n++)
        {
            string sKey = JsonGetString(JsonArrayGet(jKeys, n));

            if (JsonObjectGet(jSeries, sKey) != JsonNull())
                sMinimumProperties = RemoveListItem(sMinimumProperties, sKey);
        }
    }

    if (CountList(sMinimumProperties) > 0)
    {
        string sMessage = "Attempt to add series to form " + sFormID + " for control " +
            sControlID + " failed; minimum properties requirement not met.  The series did not " +
            "have the following properties set either in the jData structure passed to NUI_AddSeries " +
            "or set via NUI_SetCustomBuildProperty().\n\n  > jData -> " + JsonDump(jSeries);
        NUI_AbortFileFunction(sMessage);
    }
}

void NUI_HandleDropSeries()
{

}

void NUI_HandleDisplayForm(string sFormID)
{
    // Manipulate json here?

}

void NUI_HandleControlInsertion(string sID)
{
    Notice("Handling control insertion for " + sID);

    // Only add one main control here, so users can assign properties as required
    // without worrying about which control they're getting assigned to.  This should
    // be the main control for the custom control.  If there are additional controls
    // the other should be added first or added during form display above.
    // Worst case, just use a spacer for assigned properties, then manipulate as required
    // during form display or series addition.

    NUI_AddSpacer();
        NUI_AddCanvas();    // Maybe an NUI_AddBlankCanvas() function?
        NUI_CloseCanvas();

        NUI_SetID(sID);

        NUI_SetScissor(FALSE);  // Remove scissor from canvas definition?
        
        NUI_SetCustomControlProperty(NUI_PROPERTY_BUILDDATA, "type", jCONTROL_NAME);
        NUI_SetCustomControlProperty(NUI_PROPERTY_BUILDDATA, "orientation", JsonString(NUI_ORIENTATION_HORIZONTAL));
}

void NUI_HandleControlRegistration()
{
    NUI_RegisterCustomControl(CONTROL_NAME);
}

//void main() {}
