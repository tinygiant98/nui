/// ----------------------------------------------------------------------------
/// @file   nui_f_inspector.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Form Inspector formfile.
/// ----------------------------------------------------------------------------

#include "nui_i_library"
#include "util_i_csvlists"
#include "util_i_debug"

const string FORM_ID = "nui_inspector";
const string VERSION = "0.1.1";
const string IGNORE_FORM_EVENTS = "";
const string DEBUG_PREAMBLE = "[Form Inspector]";

sqlquery fi_PrepareQuery(string sQuery)
{
    return SqlPrepareQueryObject(GetModule(), sQuery);
}

void fi_BeginTransaction()  { SqlStep(fi_PrepareQuery("BEGIN TRANSACTION;")); }
void fi_CommitTransaction() { SqlStep(fi_PrepareQuery("COMMIT TRANSACTION;")); }

sqlquery fi_GetForms(object oPC)
{
    int n, nToken;
    json jForms = JsonArray();
    json jTokens = JsonArray();

    while ((nToken = NuiGetNthWindow(oPC, n++)) > 0)
    {
        jForms = JsonArrayInsert(jForms, JsonString(NuiGetWindowId(oPC, nToken)));
        jTokens = JsonArrayInsert(jTokens, JsonInt(nToken));
    }

    string sQuery = 
        "WITH f AS (SELECT ROWID, value FROM json_each(@forms)), " +
        "t AS (SELECT ROWID, value FROM json_each(@tokens)), " +
        "rhs AS (SELECT f.value form, t.value token FROM f INNER JOIN t ON f.ROWID = t.ROWID), " +
        "c AS (SELECT IFNULL(json_extract(definition, '$.toc_title'), json_extract(definition, '$.id')) t, " +
        "json_extract(definition, '$.id') i FROM nui_forms, json_each(nui_forms.definition) " +
        "WHERE nui_forms.form IN (SELECT value FROM json_each(@forms))), " +
        "d AS (SELECT DISTINCT * FROM c), " +
        "lhs AS (SELECT d.t, d.i, rhs.token FROM d INNER JOIN rhs ON d.i = rhs.form) " +
        "SELECT json_group_array(json_array(t, token)), json_group_array(i), json_group_array(token) FROM lhs;";

    sqlquery sql = nui_PrepareQuery(sQuery);
    SqlBindJson(sql, "@forms", jForms);
    SqlBindJson(sql, "@tokens", jTokens);

    return sql;
}

sqlquery fi_GetEvents(object oPC)
{
    string sLHS = JsonDump(NUI_GetBind(oPC, FORM_ID, "lblFilterEvent:L:value"));
    string sRHS = JsonDump(NUI_GetBind(oPC, FORM_ID, "lblFilterEvent:R:value"));

    json jEvents = JsonParse(GetStringLeft (sLHS, GetStringLength(sLHS) - 1) + "," + 
                            GetStringRight(sRHS, GetStringLength(sRHS) - 1));

    sLHS = JsonDump(NUI_GetBind(oPC, FORM_ID, "chkFilterEvent:L:value"));
    sRHS = JsonDump(NUI_GetBind(oPC, FORM_ID, "chkFilterEvent:R:value"));

    json jSelected = JsonParse(GetStringLeft (sLHS, GetStringLength(sLHS) - 1) + "," + 
                               GetStringRight(sRHS, GetStringLength(sRHS) - 1));

    string sQuery =
        "WITH b AS (SELECT ROWID, value FROM json_each(@jBinds)), " +
        "     bs AS (SELECT ROWID, value FROM json_each(@jSelectedBinds)), " +
        "     bt AS (SELECT b.value FROM b INNER JOIN bs ON b.ROWID = bs.ROWID WHERE bs.value = false), " +
        "     e AS (SELECT ROWID, value FROM json_each(@jEvents)),  " +
        "     es AS (SELECT ROWID, value FROM json_each(@jSelectedEvents)),  " +
        "     et AS (SELECT lower(e.value) FROM e INNER JOIN es ON e.ROWID = es.ROWID WHERE es.value = true), " +
        "     ed AS (SELECT sEvent, sControlID, event_id FROM nui_fi_data WHERE sPlayer = @sPlayer AND " +
        "           nToken = @nToken AND sEvent IN et AND sControlID NOT IN bt ORDER BY event_id DESC) " +
        "SELECT json_group_array(json_array(sEvent || ' : ' || sControlID, event_id)), " +
        "json_group_array(event_id) FROM ed;";
    sqlquery sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@sPlayer", GetObjectUUID(oPC));
    SqlBindJson  (sql, "@nToken", NUI_GetBind(oPC, FORM_ID, "cboForms:value"));
    SqlBindJson  (sql, "@jEvents", jEvents);
    SqlBindJson  (sql, "@jSelectedEvents", jSelected);
    SqlBindJson  (sql, "@jBinds", NUI_GetBind(oPC, FORM_ID, "lblFilterBind:value"));
    SqlBindJson  (sql, "@jSelectedBinds", NUI_GetBind(oPC, FORM_ID, "chkFilterBind:value"));


    return sql;
}

json fi_GetEventData(object oPC)
{
    string sQuery = "SELECT json_object('txtTimestamp:value', DATETIME(timestamp, 'unixepoch', 'localtime'), " +
        "'txtControlID:value', sControlID, 'lblEventID:value', event_id, 'txtEvent:value', sEvent, " +
        "'txtIndex:value', nIndex, 'txtPayload:value', json(jPayload)) FROM nui_fi_data " +
        "WHERE nToken = @nToken AND sPlayer = @sPlayer AND event_id = @event_id;";
    sqlquery sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@sPlayer", GetObjectUUID(oPC));
    SqlBindJson  (sql, "@nToken", NUI_GetBind(oPC, FORM_ID, "cboForms:value"));
    SqlBindJson  (sql, "@event_id", NUI_GetBind(oPC, FORM_ID, "cboEvents:value"));

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonObject();
}

void fi_UpdateForms(object oPC)
{
    sqlquery sql   = fi_GetForms(oPC);
    SqlStep(sql);

    json jElements = SqlGetJson(sql, 0);
    json jIDs      = SqlGetJson(sql, 1);
    json jTokens   = SqlGetJson(sql, 2);

    if (JsonGetLength(jElements) > 0)
    {
        NUI_SetBindJ(oPC, FORM_ID, "cboForms:elements", jElements);
        NUI_SetBindJ(oPC, FORM_ID, "varFormIDs", jIDs);
        NUI_SetBindJ(oPC, FORM_ID, "varFormTokens", jTokens);
    }
    else
    {
        NUI_SetBindJ(oPC, FORM_ID, "cboForms:elements", JsonArray());
        NUI_SetBindJ(oPC, FORM_ID, "varFormIDs", JsonArray());
        NUI_SetBindJ(oPC, FORM_ID, "varFormTokens", JsonArray());
    }
}

void fi_UpdateEvents(object oPC)
{
    json jIDs    = NUI_GetBind(oPC, FORM_ID, "varFormIDs");  
    json jTokens = NUI_GetBind(oPC, FORM_ID, "varFormTokens");

    int nIndex = JsonGetInt(JsonFind(jTokens, NUI_GetBind(oPC, FORM_ID, "cboForms:value")));
    NUI_SetBindJ(oPC, FORM_ID, "lblFormID:value", JsonArrayGet(jIDs, nIndex));
    NUI_SetBindJ(oPC, FORM_ID, "lblFormToken:value", JsonArrayGet(jTokens, nIndex));

    sqlquery sql = fi_GetEvents(oPC);
    if (SqlStep(sql))
    {
        NUI_SetBindJ(oPC, FORM_ID, "cboEvents:elements", SqlGetJson(sql, 0));
        NUI_SetBindJ(oPC, FORM_ID, "varEventIDs", SqlGetJson(sql, 1));
    }
}

json fi_GetBindList(object oPC, int nToken)
{
    string sBind;
    json jBinds = JsonArray();
    
    int n; while ((sBind = NuiGetNthBind(oPC, nToken, FALSE, n++)) != "")
        jBinds = JsonArrayInsert(jBinds, JsonString(sBind));

    string sQuery = "WITH b AS (SELECT value FROM json_each (@jBinds) ORDER BY lower(value) ASC) " +
        "SELECT json_group_array(value) FROM b;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindJson  (sql, "@jBinds", jBinds);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonArray();
}

void fi_PopulateBindFilter(object oPC)
{
    json jBinds = fi_GetBindList(oPC, JsonGetInt(NUI_GetBind(oPC, FORM_ID, "cboForms:value")));
    if (!JsonGetLength(jBinds))
    {
        NUI_SetBindJ(oPC, FORM_ID, "lblFilterBind:value", JsonArray());
        NUI_SetBindJ(oPC, FORM_ID, "chkFilterBind:value", JsonArray());
        return;
    }

    string sQuery =
        "WITH binds AS (SELECT value bind, true selected FROM json_each(@jBinds) ORDER BY lower(value)) " +
        "SELECT json_group_array(bind), json_group_array(selected) FROM binds;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindJson  (sql, "@jBinds", jBinds);

    if (SqlStep(sql))
    {
        NUI_SetBindJ(oPC, FORM_ID, "lblFilterBind:value", SqlGetJson(sql, 0));
        NUI_SetBindJ(oPC, FORM_ID, "chkFilterBind:value", SqlGetJson(sql, 1));
    }
}

void fi_PopulateEventBinds(object oPC, string sKey)
{
    int nEventID = JsonGetInt(NUI_GetBind(oPC, FORM_ID, "cboEvents:value"));
    string sQuery =
        "SELECT json(value) FROM nui_fi_data, json_each(nui_fi_data.binds_before) WHERE key = @key AND event_id = @event_id;";
    sqlquery sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@key", sKey);
    SqlBindInt   (sql, "@event_id", nEventID);

    json jBefore = SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();

    sQuery =
        "SELECT json(value) FROM nui_fi_data, json_each(nui_fi_data.binds_after) WHERE key = @key AND event_id = @event_id;";
    sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@key", sKey);
    SqlBindInt   (sql, "@event_id", nEventID);

    json jAfter = SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();

    if (jBefore == JsonNull())
        jBefore = JsonString("NULL");

    if (jAfter == JsonNull())
        jAfter = JsonString("NULL");

    NUI_SetBindJ(oPC, FORM_ID, "txtEventBind:Before:value", JsonString(JsonDump(jBefore, 2)));
    NUI_SetBindJ(oPC, FORM_ID, "txtEventBind:After:value", JsonString(JsonDump(jAfter, 2)));
}

void fi_UpdateBindFilter(object oPC)
{
    json jBinds = fi_GetBindList(oPC, JsonGetInt(NUI_GetBind(oPC, FORM_ID, "cboForms:value")));
    if (!JsonGetLength(jBinds))
    {
        NUI_SetBindJ(oPC, FORM_ID, "lblFilterBind:value", JsonArray());
        NUI_SetBindJ(oPC, FORM_ID, "chkFilterBind:value", JsonArray());
        return;
    }

    string sQuery =
        "WITH fb AS (SELECT ROWID, value FROM json_each(@filterBinds)), " +
        "     s  AS (SELECT ROWID, value FROM json_each(@selected)), " +
        "     t  AS (SELECT fb.value bind, s.value selected FROM fb INNER JOIN s ON fb.ROWID = s.ROWID), " +
        "     nb AS (SELECT value bind, true selected FROM json_each(@formBinds) WHERE value NOT IN (SELECT value FROM fb)), " +
        "     c  AS (SELECT * FROM t UNION SELECT * FROM nb) " +
        "SELECT json_group_array(bind), json_group_array(selected) FROM c;";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlBindJson(sql, "@filterBinds", NUI_GetBind(oPC, FORM_ID, "lblFilterBind:value"));
    SqlBindJson(sql, "@selected", NUI_GetBind(oPC, FORM_ID, "chkFilterBind:value"));
    SqlBindJson(sql, "@formBinds", jBinds);

    if (SqlStep(sql))
    {
        NUI_SetBindJ(oPC, FORM_ID, "lblFilterBind:value", SqlGetJson(sql, 0));
        NUI_SetBindJ(oPC, FORM_ID, "chkFilterBind:value", SqlGetJson(sql, 1));
    }
}

void fi_SelectBindDisplay(object oPC)
{
    json jBinds;
    int nView = JsonGetInt(NUI_GetBind(oPC, FORM_ID, "tglFilterView:value"));
    
    if (nView == 0)
        jBinds = NUI_GetBind(oPC, FORM_ID, "varChangedKeys");
    else if (nView == 1)
        jBinds = NUI_GetBind(oPC, FORM_ID, "varNewKeys");
    else if (nView == 2)
        jBinds = NUI_GetBind(oPC, FORM_ID, "varAllKeys");

    NUI_SetBindJ(oPC, FORM_ID, "lblEventBinds:value", jBinds);

    if (!JsonGetLength(jBinds))
    {
        NUI_SetBindJ(oPC, FORM_ID, "txtEventBind:Before:value", JsonNull());
        NUI_SetBindJ(oPC, FORM_ID, "txtEventBind:After:value", JsonNull());
    }
    else
        fi_PopulateEventBinds(oPC, JsonGetString(JsonArrayGet(jBinds, 0)));
}

void fi_UpdateBindDisplay(object oPC)
{
    json jBinds, jNewKeys, jChangedKeys;

    if (JsonGetInt(NUI_GetBind(oPC, FORM_ID, "chkUseFilterBind:value")))
    {
        string sQuery =
            "WITH b AS (SELECT ROWID, value FROM json_each(@jBinds)), " +
            "     bs AS (SELECT ROWID, value FROM json_each(@jSelected)), " +
            "     t AS (SELECT b.value FROM b INNER JOIN bs ON b.ROWID = bs.ROWID WHERE bs.value = true) " +
            "SELECT json_group_array(value) FROM t;";

        sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
        SqlBindJson(sql, "@jBinds", NUI_GetBind(oPC, FORM_ID, "lblFilterBind:value"));
        SqlBindJson(sql, "@jSelected", NUI_GetBind(oPC, FORM_ID, "chkFilterBind:value"));

        jBinds = SqlStep(sql) ? SqlGetJson(sql, 0) : JsonArray();
    }
    else
        jBinds = fi_GetBindList(oPC, JsonGetInt(NUI_GetBind(oPC, FORM_ID, "cboForms:value")));

    int nEventID = JsonGetInt(NUI_GetBind(oPC, FORM_ID, "cboEvents:value"));

    {
        string sQuery =
            "WITH ak AS (SELECT DISTINCT key, value FROM nui_fi_data, json_each(nui_fi_data.binds_after) WHERE event_id = @event_id ), " +
            "    bk AS (SELECT DISTINCT key, value FROM nui_fi_data, json_each(nui_fi_data.binds_before) WHERE event_id = @event_id ), " +
            "    nk AS (SELECT key FROM ak WHERE ak.key NOT IN (SELECT key FROM bk)), " +
            "    ck AS (SELECT key FROM ak WHERE ak.value != (SELECT value FROM bk WHERE key = ak.key)) " +
            "SELECT json_group_array(key) FROM nk;";
        sqlquery sql = nui_PrepareQuery(sQuery);
        SqlBindInt   (sql, "@event_id", nEventID);

        jNewKeys = SqlStep(sql) ? SqlGetJson(sql, 0) : JsonArray();
    }

    { 
        string sQuery =
            "WITH ak AS (SELECT DISTINCT key, value FROM nui_fi_data, json_each(nui_fi_data.binds_after) WHERE event_id = @event_id ), " +
            "    bk AS (SELECT DISTINCT key, value FROM nui_fi_data, json_each(nui_fi_data.binds_before) WHERE event_id = @event_id ), " +
            "    nk AS (SELECT key FROM ak WHERE ak.key NOT IN (SELECT key FROM bk)), " +
            "    ck AS (SELECT key FROM ak WHERE ak.value != (SELECT value FROM bk WHERE key = ak.key)) " +
            "SELECT json_group_array(key) FROM ck;";
        sqlquery sql = nui_PrepareQuery(sQuery);
        SqlBindInt   (sql, "@event_id", nEventID);

        jChangedKeys = SqlStep(sql) ? SqlGetJson(sql, 0) : JsonArray();
    }
    
    NUI_SetBindJ(oPC, FORM_ID, "varNewKeys", jNewKeys);
    NUI_SetBindJ(oPC, FORM_ID, "varChangedKeys", jChangedKeys);
    NUI_SetBindJ(oPC, FORM_ID, "varAllKeys", jBinds);

    fi_SelectBindDisplay(oPC);
}

void fi_UpdateEventData(object oPC)
{
    json jEventData = fi_GetEventData(oPC);

    json jKeys = JsonObjectKeys(jEventData);
    int n; for (n; n < JsonGetLength(jKeys); n++)
    {
        string sBind = JsonGetString(JsonArrayGet(jKeys, n));
        json  jValue = JsonObjectGet(jEventData, sBind);
        int    nType = JsonGetType(jValue);

        if (nType == JSON_TYPE_ARRAY || nType == JSON_TYPE_OBJECT)
            jValue = JsonString(JsonDump(jValue, 2));
        else if (nType = JSON_TYPE_NULL)
            jValue = JsonString("<null>");

        NUI_SetBindJ(oPC, FORM_ID, sBind, jValue);
    }
}

void fi_ResetEventTypeFilter(object oPC)
{
    json jSelected = JsonArray();
    string sSides = "L,R";

    int i; for (i; i < CountList(sSides); i++)
    {
        int n = 5; while (--n >= 0)
            jSelected = JsonArrayInsert(jSelected, JsonBool(TRUE));

        NUI_SetBindJ(oPC, FORM_ID, "chkFilterEvent:" + GetListItem(sSides, i) + ":value", jSelected);
    }
}

void fi_ResetBindFilter(object oPC, int bSelected = TRUE)
{
    json jSelected = JsonArray();

    int nBinds = JsonGetLength(NUI_GetBind(oPC, FORM_ID, "lblFilterBind:value"));
    while (--nBinds >= 0)
        jSelected = JsonArrayInsert(jSelected, JsonBool(bSelected));

    NUI_SetBindJ(oPC, FORM_ID, "chkFilterBind:value", jSelected);
}

void BindForm()
{
    json jValue, jBinds = NUI_GetOrphanBinds(FORM_ID);

    int n; for (n; n < JsonGetLength(jBinds); n++)
    {
        string sValue, sBind = JsonGetString(JsonArrayGet(jBinds, n));
        json jValue = JsonNull();

        if (sBind == "cboForms:elements")
        {
            fi_UpdateForms(OBJECT_SELF);
            fi_PopulateBindFilter(OBJECT_SELF);
            continue;
        }
        else if (sBind == "txtTest")
        {   
            json jObject = JsonObjectSet(JsonObject(), "key1:", JsonString("Value1"));
                 jObject = JsonObjectSet(jObject, "alpha", JsonInt(3));

            json jArray = ListToJson("howdy,how,do,you,do,today,?");
            jValue = JsonString(JsonDump(jObject, 2));
        }
        else if (sBind == "lblFilterEvent:L:value")
        {
            jValue = ListToJson("Blur,Click,Close,Focus,Open");
            NUI_SetBindJ(OBJECT_SELF, FORM_ID, "lblFilterEvent:L:value", jValue);

            jValue = ListToJson("MouseDown,MouseScroll,MouseUp,Range,Watch");
            NUI_SetBindJ(OBJECT_SELF, FORM_ID, "lblFilterEvent:R:value", jValue);
            continue;
        }
        else if (sBind == "chkFilterEvent:L:value")
        {
            fi_ResetEventTypeFilter(OBJECT_SELF);
            continue;
        }
        else if (sBind == "tglFilterEvent:value" || sBind == "chkUseFilterBind:value")
            jValue = JsonBool(TRUE);
        else if (sBind == "lblFilterBind:value" || sBind == "chkFilterBind:value")
            jValue = JsonArray();
        else if (sBind == "tglFilterView:value")
            jValue = JsonInt(0);

        if (sValue != "")
            NUI_SetBind(OBJECT_SELF, FORM_ID, sBind, sValue);
        else if (jValue != JsonNull())
            NUI_SetBindJ(OBJECT_SELF, FORM_ID, sBind, jValue);
    }
}

void HandleNUIEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    if (FALSE)
    {
        Notice(HexColorString("NUI Event Data:", COLOR_GREEN_LIGHT) +
            "\n  sEvent = " + ed.sEvent +
            "\n  oPC = " + GetName(ed.oPC) +
            "\n  sFormID = " + ed.sFormID +
            "\n  sControlID = " + ed.sControlID +
            "\n  nIndex = " + IntToString(ed.nIndex) +
            "\n  nToken = " + IntToString(ed.nToken) +
            "\n  jPayload = " + JsonDump(ed.jPayload));
    }

    if (ed.sEvent == "watch")
    {
        if (ed.sControlID == "cboForms:value")
        {
            fi_UpdateEvents(ed.oPC);
            fi_PopulateBindFilter(ed.oPC);
        }
        else if (ed.sControlID == "chkFilterEvent:L:value" || ed.sControlID == "chkFilterEvent:R:value")
            fi_UpdateEvents(ed.oPC);
        else if (ed.sControlID == "cboEvents:value")
        {
            fi_UpdateEventData(ed.oPC);
            fi_UpdateBindDisplay(ed.oPC);
        }
        else if (ed.sControlID == "chkUseFilterBind:value")
            fi_UpdateBindDisplay(ed.oPC);
        else if (ed.sControlID == "chkFilterBind:value")
        {
            fi_UpdateEvents(ed.oPC);

            if (JsonGetInt(NUI_GetBind(ed.oPC, FORM_ID, "chkUseFilterBind:value")))
                fi_UpdateBindDisplay(ed.oPC);
        }
        else if (ed.sControlID == "tglFilterView:value")
            fi_SelectBindDisplay(ed.oPC);
    }
    else if (ed.sEvent == "click")
    {
        if (ed.sControlID == "cmdResetEventTypeFilter")
            fi_ResetEventTypeFilter(ed.oPC);
        else if (ed.sControlID == "cmdResetBindFilter")
            fi_ResetBindFilter(ed.oPC, TRUE);
        else if (ed.sControlID == "cmdClearBindFilter")
            fi_ResetBindFilter(ed.oPC, FALSE);
    }
    else if (ed.sEvent == "mouseup")
    {
        if (ed.sControlID == "lblEventBinds:value")
        {
            string sBind = JsonGetString(JsonArrayGet(NuiGetBind(ed.oPC, ed.nToken, ed.sControlID), ed.nIndex));
            fi_PopulateEventBinds(ed.oPC, sBind);
        }
    }
}

void HandleModuleEvents()
{
    int nEvent = GetCurrentlyRunningEvent();

    if (nEvent == EVENT_SCRIPT_MODULE_ON_USER_DEFINED_EVENT)
    {
        if (NuiFindWindow(NuiGetEventPlayer(), FORM_ID) == 0)
            return;

        int nType = GetUserDefinedEventNumber();
        if (nType == NUI_FI_EVENT_UPDATE_FORMS)
            fi_UpdateForms(NuiGetEventPlayer());
        else if (nType == NUI_FI_EVENT_UPDATE_EVENTS)
            fi_UpdateEvents(NuiGetEventPlayer());
    }
}

void DefineForm()
{
    NUI_CreateForm(FORM_ID, VERSION);
        NUI_SetTitle("NUI Form Inspector");
        NUI_SetResizable(TRUE);
        //NUI_SetCollapsible(TRUE);
        NUI_SetTOCTitle("Form Inspector");
        NUI_SubscribeEvent(EVENT_SCRIPT_MODULE_ON_USER_DEFINED_EVENT);
    {
        NUI_AddColumn();
            NUI_AddRow();
                NUI_AddCombobox();
                    NUI_BindElements("cboForms:elements");
                    NUI_BindValue("cboForms:value", TRUE);
                    NUI_SetWidth(200.0);
                    NUI_SetTooltip("Tooltip");

                NUI_AddLabel(); // ID label;
                    NUI_SetLabel("Form ID:");
                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                    NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_CYAN));
                    NUI_SetWidth(60.0);
                NUI_AddSpacer();
                    NUI_SetWidth(10.0);
                NUI_AddLabel();
                    NUI_BindLabel("lblFormID:value");
                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                    NUI_SetWidth(150.0);
                    NUI_BindTooltip("lblFormID:value");

                NUI_AddLabel(); // Token label;
                    NUI_SetLabel("Token:");
                    NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                    NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_CYAN));
                    NUI_SetWidth(60.0);
                NUI_AddSpacer();
                    NUI_SetWidth(10.0);
                NUI_AddLabel();
                    NUI_BindLabel("lblFormToken:value");
                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                    NUI_SetWidth(20.0);

                NUI_AddSpacer();
            NUI_CloseRow();

            NUI_AddRow();
                NUI_AddColumn(180.0);
                    NUI_AddGroup();
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddLabel();
                                    NUI_SetLabel("Event Type Filter:");
                                    NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_CYAN));
                                    NUI_SetHeight(25.0);
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddCommandButton("cmdResetEventTypeFilter");
                                    NUI_SetLabel("All");
                                    NUI_SetWidth(35.0);
                                    NUI_SetHeight(25.0);
                            NUI_CloseRow();
                            
                            NUI_AddListbox();
                                NUI_SetRowCount(5);
                                NUI_SetRowHeight(20.0);
                                NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                                NUI_SetHeight(125.0);
                                NUI_SetBorder(FALSE);
                            {
                                NUI_AddCheckbox();
                                    NUI_BindValue("chkFilterEvent:L:value", TRUE);
                                    NUI_BindLabel("lblFilterEvent:L:value");
                                    NUI_SetTemplateWidth(65.0);
                                    NUI_SetTemplateVariable(FALSE);
                                NUI_AddCheckbox();
                                    NUI_BindValue("chkFilterEvent:R:value", TRUE);
                                    NUI_BindLabel("lblFilterEvent:R:value");
                            } NUI_CloseListbox();

                            NUI_AddRow();
                                NUI_AddLabel();
                                    NUI_SetLabel("Bind Filter:");
                                    NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_CYAN));
                                    NUI_SetHeight(25.0);
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddCommandButton("cmdResetBindFilter");
                                    NUI_SetLabel("All");
                                    NUI_SetWidth(35.0);
                                    NUI_SetHeight(25.0);
                                NUI_AddCommandButton("cmdClearBindFilter");
                                    NUI_SetLabel("None");
                                    NUI_SetWidth(45.0);
                                    NUI_SetHeight(25.0);
                            NUI_CloseRow();

                            NUI_AddListbox();
                                NUI_BindRowCount("lblFilterBind:value");
                                NUI_SetRowHeight(25.0);
                            {
                                NUI_AddCheckbox();
                                    NUI_BindValue("chkFilterBind:value", TRUE);
                                    NUI_BindLabel("lblFilterBind:value");
                                    NUI_BindTooltip("lblFilterBind:value");
                            } NUI_CloseListbox();
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                NUI_AddColumn();
                    NUI_AddGroup();
                    {
                        NUI_AddRow();
                            NUI_AddColumn();
                                NUI_AddRow(40.0);
                                    NUI_AddLabel();
                                        NUI_SetLabel("NUI Events:");
                                        NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                        NUI_SetWidth(100.0);
                                        NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_CYAN));
                                    NUI_AddSpacer();
                                        NUI_SetWidth(5.0);
                                    NUI_AddCombobox();
                                        NUI_SetWidth(200.0);
                                        NUI_BindElements("cboEvents:elements");
                                        NUI_BindValue("cboEvents:value", TRUE);
                                NUI_CloseRow();

                                float fLabelWidth = 100.0;
                                string sLabels = "Timestamp,ControlID,Index";
                                int n; for (n; n < CountList(sLabels); n++)
                                {
                                    string sLabel = GetListItem(sLabels, n);

                                    NUI_AddRow(30.0);
                                        NUI_AddLabel();
                                            NUI_SetLabel(sLabel + ":");
                                            NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                            NUI_SetWidth(fLabelWidth);
                                            NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_GREEN_LIGHT));
                                        NUI_AddSpacer();
                                            NUI_SetWidth(5.0);
                                        NUI_AddTextbox();
                                            NUI_SetStatic();
                                            NUI_BindValue("txt" + sLabel + ":value");
                                            NUI_SetWidth(200.0);
                                            NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                                    NUI_CloseRow();
                                }
                                
                                NUI_AddRow();
                                    NUI_AddLabel();
                                        NUI_SetLabel("Payload:");
                                        NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                        NUI_SetVerticalAlignment(NUI_VALIGN_TOP);
                                        NUI_SetWidth(fLabelWidth);
                                        NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_GREEN_LIGHT));
                                    NUI_AddSpacer();
                                        NUI_SetWidth(5.0);
                                    NUI_AddTextbox();
                                        NUI_SetStatic();
                                        NUI_SetMultiline();
                                        NUI_SetWordWrap();
                                        NUI_BindValue("txtPayload:value");
                                        NUI_SetWidth(200.0);
                                        NUI_SetHeight(150.0);
                                        NUI_SetScrollbars(NUI_SCROLLBARS_AUTO);
                                NUI_CloseRow();

                                NUI_AddSpacer();
                                    NUI_SetHeight(50.0);

                                NUI_AddRow();
                                    NUI_AddColumn();
                                        NUI_AddLabel();
                                            NUI_SetLabel("View Filter:");
                                            NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_CYAN));
                                            NUI_SetHeight(25.0);
                                            NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                    NUI_CloseColumn();

                                    NUI_AddColumn();
                                        NUI_AddToggleGroup();
                                            NUI_SetElements("Changed Binds,Added Binds,All Binds");
                                            NUI_BindValue("tglFilterView:value", TRUE);
                                            NUI_SetDirection(NUI_ORIENTATION_COLUMN);
                                            NUI_SetWidth(200.0);
                                            NUI_BindTooltip("tglFilterView:tooltip");
                                        NUI_AddCheckbox();
                                            NUI_SetLabel("Use Bind Filter");
                                            NUI_BindValue("chkUseFilterBind:value", TRUE);
                                    NUI_CloseColumn();
                                NUI_CloseRow();
                            NUI_CloseColumn();

                            NUI_AddColumn(10.0);
                            NUI_CloseColumn();

                            NUI_AddColumn(160.0);
                                NUI_AddLabel();
                                    NUI_SetLabel("Event Binds:");
                                    NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_CYAN));
                                    NUI_SetHeight(40.0);
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);

                                NUI_AddListbox();
                                    NUI_BindRowCount("lblEventBinds:value");
                                    NUI_SetRowHeight(25.0);
                                    NUI_SetWidth(150.0);
                                    NUI_BindValue("lstEventBinds:value", TRUE);
                                {
                                    NUI_AddLabel("lblEventBinds:value");
                                        NUI_BindLabel("lblEventBinds:value");
                                        NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                        NUI_BindTooltip("lblEventBinds:value");
                                        NUI_SetTemplateWidth(145.0);
                                        NUI_SetTemplateVariable(FALSE);
                                       //NUI_AddCanvas();
                                       //{
                                       //    NUI_DrawLine(NUI_GetRectanglePoints(1.0, 1.0, 149.0, 24.0));
                                       //    //NUI_DrawCircle(10.0, 10.0, 5.0);
                                       //    NUI_SetColor(NUI_DefineHexColor(COLOR_RED_LIGHT));
                                       //} NUI_CloseCanvas();
                                } NUI_CloseListbox();
                            NUI_CloseColumn();

                            NUI_AddColumn(10.0);
                            NUI_CloseColumn();

                            NUI_AddColumn();
                                NUI_AddLabel();
                                    NUI_SetLabel("Bind Value Before Event:");
                                    NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_GREEN_LIGHT));
                                    NUI_SetHeight(40.0);
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddTextbox();
                                    NUI_SetStatic();
                                    NUI_SetMultiline();
                                    NUI_SetWordWrap();
                                    NUI_SetHeight(200.0);
                                    NUI_BindValue("txtEventBind:Before:value");
                                NUI_AddLabel();
                                    NUI_SetLabel("Bind Value After Event:");
                                    NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_GREEN_LIGHT));
                                    NUI_SetHeight(40.0);
                                    NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_AddTextbox();
                                    NUI_SetStatic();
                                    NUI_SetMultiline();
                                    NUI_SetWordWrap();
                                    NUI_SetHeight(200.0);
                                    NUI_BindValue("txtEventBind:After:value");
                        NUI_CloseRow();

                    } NUI_CloseGroup();
                NUI_CloseColumn();
            NUI_CloseRow();
        NUI_CloseColumn();
    }

    NUI_CreateDefaultProfile();
    {
        string sGeometry = NUI_DefineRectangle(10.0, 10.0, 1015.0, 575.0);
        NUI_SetProfileBind("geometry", sGeometry);
    }
}
