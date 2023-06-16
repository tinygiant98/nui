/// ----------------------------------------------------------------------------
/// @file   nui_f_toc.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Table of Contents formfile
/// ----------------------------------------------------------------------------

#include "nui_i_library"
#include "util_i_csvlists"
#include "util_i_debug"

const string FORM_ID = "toc";
const string VERSION = "0.1.3";
const string IGNORE_FORM_EVENTS = "blur,focus,range,mousedown,mouseup";

void DefineForm()
{
    NUI_CreateForm(FORM_ID);
        NUI_SetTitle("Available Forms");
        NUI_SetResizable(TRUE);
        NUI_SetTOCTitle("Table of Contents");
    {
        NUI_AddColumn();
            NUI_AddRow();
                NUI_AddSpacer();
                NUI_AddSpacer();
                NUI_AddCommandButton("redefine_all");
                    NUI_SetLabel("Redefine All Forms");
            NUI_CloseRow();

            NUI_AddRow();
                NUI_SetHeight(40.0);
                NUI_AddSpacer();
                    NUI_SetWidth(5.0);
                NUI_AddLabel();
                    NUI_SetLabel("Form (Click to Open)");
                NUI_AddLabel();
                    NUI_SetLabel("Profiles");
                    NUI_SetWidth(200.0);
                NUI_AddLabel();
                    NUI_SetLabel("Redefine");
                    NUI_SetWidth(75.0);
                NUI_AddSpacer();
                    NUI_SetWidth(20.0);
            NUI_CloseRow();

            NUI_AddRow();
                NUI_AddListbox();
                    NUI_BindRowCount("cmdOpen:label");
                    //NUI_SetRowCount(10);
                    NUI_SetRowHeight(40.0);
                {
                    NUI_AddCommandButton("cmdOpen");
                        NUI_BindLabel("cmdOpen:label");
                    NUI_AddCombobox();
                        NUI_BindElements("combo_elements");
                        NUI_BindValue("combo_value");
                        //NUI_SetTemplateWidth(200.0);
                        //NUI_SetTemplateVariable(FALSE);
                        //NUI_SetTemplateWidth(50.0);
                        NUI_SetTemplateWidth(50.0);
                        //NUI_SetTemplateVariable(TRUE);
                        NUI_BindEnabled("combo_enabled");
                    NUI_AddCommandButton("cmdRedefine");
                        NUI_SetLabel("Redefine");
                        NUI_SetTemplateWidth(75.0);
                        NUI_SetTemplateVariable(FALSE);
                } NUI_CloseListbox();
            NUI_CloseRow();
        NUI_CloseColumn();
    }

    NUI_CreateDefaultProfile();
    {
        string sGeometry = NUI_DefineRectangle(1400.0, 200.0, 450.0, 700.0);
        NUI_SetProfileBind("geometry", sGeometry);
    }
}

void BindForm()
{
    string sQuery = "WITH definitions AS (SELECT json_extract(definition, '$.id') AS form, " +
        "json_extract(definition, '$.profiles') as profiles, json_extract(definition, '$.toc_title') " +
        "as toc_title, json_extract(definition, '$.formfile') AS formfile FROM nui_forms WHERE " +
        "json_extract(definition, '$.toc_title') IS NOT NULL), arrays AS (SELECT definitions.formfile, " +
        "definitions.form, definitions.toc_title, json_array(key, row_number() OVER (PARTITION BY " +
        "definitions.form ORDER BY CASE WHEN key = 'default' THEN 1 ELSE 2 END ASC, key ASC) - 1) AS idx " +
        "FROM definitions, json_each(profiles)), groups AS (SELECT formfile, form, toc_title, " +
        "json_group_array(json(idx)) as arry FROM arrays GROUP BY form ORDER BY form) SELECT " +
        "json_group_array(formfile), json_group_array(form), json_group_array(json(arry)), " +
        "json_group_array(toc_title) FROM groups;";
    sqlquery sql = nui_PrepareQuery(sQuery);
    SqlStep(sql);

    json jFormfiles = SqlGetJson(sql, 0); // array of formfiles
    json jFormIDs   = SqlGetJson(sql, 1); // array of form ids
    json jElements  = SqlGetJson(sql, 2); // array of arrays of arrays of element
    json jTitles    = SqlGetJson(sql, 3); // array of form toc titles
    
    //jElements = JsonParse("[[\"default\",0],[\"two\",1],[\"three\",3]]");

    NUI_SetBindJ(OBJECT_SELF, FORM_ID, "varFormIDs", jFormIDs);
    NUI_SetBindJ(OBJECT_SELF, FORM_ID, "varFormfiles", jFormfiles);
    DelayCommand(0.01, NUI_SetBindJ(OBJECT_SELF, FORM_ID, "cmdOpen:label", jTitles));

    string sValue;
    json jBinds = NUI_GetOrphanBinds(FORM_ID);
    int n; for (n; n < JsonGetLength(jBinds); n++)
    {
        string sBind = JsonGetString(JsonArrayGet(jBinds, n));
        json   jValue = JsonNull();

        if (sValue != "")
            NUI_SetBind(OBJECT_SELF, FORM_ID, sBind, sValue);
        else if (jValue != JsonNull())
            NUI_SetBindJ(OBJECT_SELF, FORM_ID, sBind, jValue);
    }

    //// Looks like value arrays have to be initialized after the elements arrays or they get erased?
    //NUI_SetBind(OBJECT_SELF, FORM_ID, "combo_value", "[0,0,0]");
}

void HandleNUIEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    if (HasListItem(IGNORE_FORM_EVENTS, ed.sEvent))
        return;

    if (ed.sEvent == "click")
    {
        if (ed.sControlID == "redefine_all")
        {
            NUI_DefineForms();

            json jFormIDs = NuiGetBind(ed.oPC, ed.nToken, "varFormIDs");
            int n; for (n; n < JsonGetLength(jFormIDs); n++)
            {
                string sFormID = JsonGetString(JsonArrayGet(jFormIDs, n));
                if (NuiFindWindow(ed.oPC, sFormID))
                    NUI_DisplayForm(ed.oPC, sFormID);
            }
        }
        else if (ed.sControlID == "cmdRedefine")
        {
            string sFormfile = JsonGetString(JsonArrayGet(NuiGetBind(ed.oPC, ed.nToken, "varFormfiles"), ed.nIndex));
            string sFormID = JsonGetString(JsonArrayGet(NuiGetBind(ed.oPC, ed.nToken, "varFormIDs"), ed.nIndex));
            NUI_DefineForms(sFormfile);

            if (NuiFindWindow(ed.oPC, sFormID) > 0)
                NUI_DisplayForm(ed.oPC, sFormID);
        }
        else if (ed.sControlID == "cmdOpen")
        {
            string sFormID = JsonGetString(JsonArrayGet(NuiGetBind(ed.oPC, ed.nToken, "varFormIDs"), ed.nIndex));
            NUI_DisplayForm(ed.oPC, sFormID);
        }
    }
}

void HandleModuleEvents()
{

}
