
// For some reason, the toolset compiler wants to see these here (nwnsc doesn't care):
#include "nui_c_config"
#include "util_i_debug"
#include "util_i_csvlists"

string sQuery;
sqlquery sql;

sqlquery NUI_PrepareQuery(string sQuery, int bCampaign = FALSE, string sDatabase = "")
{
    if (NUI_USE_CAMPAIGN_DATABASE || bCampaign)
    {
        if (sDatabase == "")
            sDatabase = NUI_CAMPAIGN_DATABASE;

        sql = SqlPrepareQueryCampaign(sDatabase, sQuery);
    }
    else 
        sql = SqlPrepareQueryObject(GetModule(), sQuery);

    return sql;
}

void NUI_InitializeDatabase()
{
    sQuery = "CREATE TABLE IF NOT EXISTS " + NUI_FORMS + " (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "form TEXT NOT NULL UNIQUE, " +
            "json TEXT);";
    sql = NUI_PrepareQuery(sQuery);
    SqlStep(sql);

    sQuery = "CREATE TABLE IF NOT EXISTS " + NUI_PROFILES + " (" +
            "form TEXT NOT NULL, " +
            "name TEXT NOT NULL, " +
            "profile TEXT NOT NULL, " +
            "UNIQUE (form, name));";
    sql = NUI_PrepareQuery(sQuery);
    SqlStep(sql);

    sQuery = "CREATE TABLE IF NOT EXISTS " + NUI_DATA + " (" +
            "pc TEXT NOT NULL, " +
            "form TEXT NOT NULL, " +
            "control TEXT NOT NULL, " +
            "controlfile TEXT NOT NULL, " +
            "type TEXT NOT NULL, " +
            "data TEXT, " +
            "PRIMARY KEY (pc, form, control, type));";
    sql = NUI_PrepareQuery(sQuery);
    SqlStep(sql);

    sQuery = "CREATE TABLE IF NOT EXISTS " + NUI_CONTROL + " (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "control TEXT NOT NULL UNIQUE, " +
            "file TEXT NOT NULL);";
    sql = NUI_PrepareQuery(sQuery);
    SqlStep(sql);
}

sqlquery NUI_GetTOCForms()
{
    sQuery = "SELECT DISTINCT json_extract(" + NUI_FORMS + ".json, '$.title') t, " +
                    "json_extract(" + NUI_FORMS + ".json, '$.id') " +
             "FROM " + NUI_FORMS + ", json_each(" + NUI_FORMS + ".json, '$') " +
             "WHERE type = 'object' " +
                "AND json_extract(" + NUI_FORMS + ".json, '$.user_data.toc') = @toc " +
             "ORDER BY t ASC;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindInt(sql, "@toc", 1);

    return sql;
}

int NUI_GetSkipAutoBind(string sFormID)
{
    sQuery = "SELECT 1 " +
             "FROM " + NUI_FORMS + ", json_each(" + NUI_FORMS + ".json, '$') " +
             "WHERE type = 'object' " +
                "AND json_extract(" + NUI_FORMS + ".json, '$.user_data.skipAutoBind') = @skip " +
                "AND form = @form;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    SqlBindInt(sql, "@skip", 1);

    return SqlStep(sql);
}

json NUI_GetJSONValueByPath(string sFormID, string sControlID, string sPath)
{
    // Only works for returning arrays and objects, not individual values?
    // probably need to return the atom instead of the value?
    // Need to handle removing type = object?

    if (sControlID == NUI_FORM || sControlID == NUI_WINDOW)
        sControlID = sFormID;

    sQuery = "SELECT json_extract(value, '$." + sPath + "') " +
        "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
        "WHERE type = 'object' " +
            "AND json_extract(value, '$.id') = @sControlID " +
            "AND json_extract(" + NUI_FORMS + ".json, '$.id') = @sFormID;";

    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@sFormID", sFormID);
    SqlBindString(sql, "@sControlID", sControlID);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

json NUI_GetFormRoot(string sFormID)
{
    sQuery = "SELECT json_extract(value, '$.root') " +
        "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
        "WHERE type = 'object' " +
            "AND form = @form;";
            //"AND json_extract(" + NUI_FORMS + ".json, '$.id') = @sFormID;";

    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

int NUI_ParentID(string sFormID, string sControlID)
{
    sQuery = "SELECT json_tree.parent " +
        "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
        "WHERE type = 'object' " + 
            "AND json_extract(value, '$.id') = @sControlID " +
            "AND json_extract(" + NUI_FORMS + ".json, '$.id') = @sFormID";

    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@sFormID", sFormID);
    SqlBindString(sql, "@sControlID", sControlID);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

string NUI_GetParentID(string sFormID, string sControlID)
{
    if (sControlID == NUI_FORM || sControlID == NUI_WINDOW)
        sControlID = sFormID;

    int nID = NUI_ParentID(sFormID, sControlID);

    string sQuery = "SELECT json_extract(value, '$.id') " +
        "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
        "WHERE type = 'object' " +
            "AND json_tree.id = @nParent " +
            "AND json_extract(" + NUI_FORMS + ".json, '$.id') = @sFormID;";

    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@sFormID", sFormID);
    SqlBindInt(sql, "@nParent", nID);

    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

json NUI_GetUserData(string sFormID, string sControlID)
{
    return NUI_GetJSONValueByPath(sFormID, sControlID, "user_data");
}

json NUI_GetBuildData(string sFormID, string sControlID)
{
    return NUI_GetJSONValueByPath(sFormID, sControlID, "build_data");
}

// TODO oh good lord, fix this nasty sql
sqlquery NUI_GetBindTable(string sFormID, string sControlID = "")
{
    string sChild = "SELECT json_tree.* " +
            "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
            "WHERE type = 'object' " +
                "AND json_extract(value, '$.bind') != 'NULL' " +
                "AND form LIKE '%" + sFormID + "%'";

    string sParent = "SELECT json_tree.* " +
            "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
            "WHERE type = 'object' " +
                (sControlID != "" ? "AND json_extract(value, '$.id') = @control " : "") +
                "AND form LIKE '%" + sFormID + "%'";

    sQuery = "SELECT IFNULL(json_extract(parent.value, '$.type'), '_form_'), " +
                "IFNULL(json_extract(parent.value, '$.bind_data'), '_nobind_'), " +
                "child.key, json_extract(child.value, '$.bind'), " +
                "json_extract(parent.value, '$.user_data') " +
            "FROM (" + sParent +") parent " +
            "INNER JOIN (" + sChild + ") child " +
                "ON child.parent = parent.id;";

    sql = NUI_PrepareQuery(sQuery);
    if (sControlID != "")
        SqlBindString(sql, "@control", sControlID);
    
    return sql;
}

json NUI_GetJSONBindTable(string sFormIDs)
{
    string sInClause;
    int n, nCount = CountList(sFormIDs);
    for (n = 0; n < nCount; n++)
        sInClause = AddListItem(sInClause, "'" + GetListItem(sFormIDs, n) + "'");

    string sChild = "SELECT json_tree.* " +
            "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
            "WHERE type = 'object' " +
                "AND json_extract(value, '$.bind') != 'NULL' " +
                "AND form IN (" + sInClause + ")";

    string sParent = "SELECT json_tree.* " +
            "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
            "WHERE type = 'object' " +
                "AND form IN (" + sInClause + ")";

    sQuery = "SELECT json_group_array(json_extract(child.value, '$.bind')) " +
            "FROM (" + sParent +") parent " +
            "INNER JOIN (" + sChild + ") child " +
                "ON child.parent = parent.id;";

    sql = NUI_PrepareQuery(sQuery);

    SqlStep(sql);
    return SqlGetJson(sql, 0);
    //return JsonArrayTransform(SqlGetJson(sql, 0), JSON_ARRAY_UNIQUE);
}

sqlquery NUI_GetCustomControlTable(string sFormID)
{
    sQuery = "SELECT json_extract(value, '$.id'), " +
                "json_extract(value, '$.build_data.type') " +
             "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
             "WHERE type = 'object' " +
                "AND json_extract(value, '$.build_data.type') IS NOT NULL " +
                "AND form = @form;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);

    return sql;
}

void NUI_GetJSONTree(string sFormID, string sControlID, string sKey = "id")
{
    sQuery = "SELECT json_tree.* " +
            "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
            "WHERE type = 'object' " +
                "AND json_extract(value, '$." + sKey + "') = @controlID " +
                "AND json_extract(" + NUI_FORMS + ".json, '$.id') = @sFormID;";

    sQuery = "SELECT json_tree.* " +
            "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
            "WHERE type = 'object' " +
                "AND json_extract(" + NUI_FORMS + ".json, '$.id') = @sFormID;";

    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@sFormID", sFormID);

    while (SqlStep(sql)){

    string sKey = SqlGetString(sql, 0);
    string sValue = SqlGetString(sql, 1);
    string sType = SqlGetString(sql, 2);
    string sAtom = SqlGetString(sql, 3);
    int nID = SqlGetInt(sql, 4);
    int nParent = SqlGetInt(sql, 5);
    string sFullkey = SqlGetString(sql, 6);
    string sPath = SqlGetString(sql, 7);

    Notice(" JSON TREE start =============================================================");
    Notice("" +
        "\n     key - " + sKey +
        "\n     value - " + sValue +
        "\n     type - " + sType +
        "\n     atom - " + sAtom +
        "\n     id - " + IntToString(nID) +
        "\n     parent - " + IntToString(nParent) +
        "\n     fullkey - " + sFullkey +
        "\n     path - " + sPath);
    Notice(" JSON TREE end =============================================================");
}}

string NUI_GetFormfile(string sFormID)
{
    sQuery = "SELECT json_extract(json, '$.formfile') " +
             "FROM " + NUI_FORMS + " " +
             "WHERE form = @form;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);

    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

string NUI_GetControlfile(string sControl)
{
    sQuery = "SELECT file " + 
             "FROM " + NUI_CONTROL + " " +
             "WHERE control = @control;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@control", sControl);

    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

void NUI_SetFormfile(string sFormID, string sFormfile)
{
    sQuery = "UPDATE " + NUI_FORMS + " " +
             "SET json = " +
                "(SELECT json_insert(json, '$.formfile', '" + sFormfile + "') " +
                "FROM " + NUI_FORMS + " " +
                "WHERE form = @form) " +
             "WHERE form = @form;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    SqlStep(sql);
}

void NUI_SaveFormJSON(string sFormID, json jWindow)
{
    sQuery = "INSERT INTO " + NUI_FORMS + " (form, json) " +
            "VALUES (@form, @json) " +
            "ON CONFLICT (form) DO UPDATE SET " +
                "json = @json;";

    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    SqlBindJson(sql, "@json", jWindow);
    SqlStep(sql);
}

json NUI_GetFormJSON(string sFormID)
{
    sQuery = "SELECT json " +
            "FROM " + NUI_FORMS + " " +
            "WHERE form = @form;";
    
    sql = NUI_PrepareQuery(sQuery);    
    SqlBindString(sql, "@form", sFormID);
    SqlStep(sql);

    json j = SqlGetJson(sql, 0);
    return j;
}

json NUI_GetJSONTreeFieldByKey(string sFormID, string sField, string sKey, string sValue)
{
    sQuery = "SELECT " + sField + " " +
            "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$.root') " +
            "WHERE type = 'object' " +
                "AND json_extract(value, '$." + sKey + "') = @sValue " +
                "AND json_extract(" + NUI_FORMS + ".json, '$.id') = @sFormID;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@sFormID", sFormID);
    SqlBindString(sql, "@sValue", sValue);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

json NUI_GetJSONTreeFieldByID(string sFormID, string sValue, string sField)
{
    sQuery = "SELECT " + sField + " " +
            "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$.root') " +
            "WHERE type = 'object' " +
                "AND json_extract(value, '$.id') = @sValue " +
                "AND json_extract(" + NUI_FORMS + ".json, '$.id') = @sFormID;";

    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@sFormID", sFormID);
    SqlBindString(sql, "@sValue", sValue);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

void NUI_PopulateBuildJSON(object oPC, string sFormID)
{
    json jRoot = NUI_GetFormRoot(sFormID);
    if (jRoot == JsonNull())
    {
        Notice("Unable to retrieve root for " + sFormID);
        return;
    }

    sql = NUI_GetCustomControlTable(sFormID);
    while (SqlStep(sql))
    {
        string sControlID = SqlGetString(sql, 0);
        string sControlfile = NUI_GetControlfile(SqlGetString(sql, 1));

        string sTypes = "index,root";
        int n, nCount = CountList(sTypes);

        for (n = 0; n < nCount; n++)
        {
            string sType = GetListItem(sTypes, n);
            json jData = sType == "index" ? JsonInt(0) : jRoot;

            sQuery = "INSERT INTO " + NUI_DATA + " (pc, form, control, controlfile, type, data) " +
                    "VALUES (@pc, @form, @control, @controlfile, @type, @data) " +
                    "ON CONFLICT (pc, form, control, type) DO UPDATE SET data = @data;";
            sqlquery sqlCC = NUI_PrepareQuery(sQuery);
            SqlBindString(sqlCC, "@pc", NUI_EncodePC(oPC));
            SqlBindString(sqlCC, "@form", sFormID);
            SqlBindString(sqlCC, "@control", sControlID);
            SqlBindString(sqlCC, "@controlfile", sControlfile);
            SqlBindString(sqlCC, "@type", sType);
            SqlBindJson(sqlCC, "@data", jData);

            SqlStep(sqlCC);
        }
    }
}

void NUI_ClearCustomControlData(object oPC, string sFormID)
{
    string sQuery = "DELETE from " + NUI_DATA + " " +
                    "WHERE pc = @pc " +
                        "AND form = @form;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@pc", NUI_EncodePC(oPC));
    SqlBindString(sql, "@form", sFormID);

    SqlStep(sql);
}

void NUI_IncrementBuildSeriesIndex(string sFormID, string sControlID)
{
    sQuery = "UPDATE " + NUI_DATA + " " +
             "SET data = data + 1 " +
             "WHERE pc = @pc " +
                "AND form = @form " +
                "AND control = @control " +
                "AND type = 'index';";
    
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@pc", NUI_EncodePC(OBJECT_SELF));
    SqlBindString(sql, "@form", sFormID);
    SqlBindString(sql, "@control", sControlID);

    SqlStep(sql);
}

int NUI_GetBuildSeriesIndex(string sFormID, string sControlID)
{
    sQuery = "SELECT data " +
             "FROM " + NUI_DATA + " " +
             "WHERE pc = @pc " +
                "AND form = @form " +
                "AND control = @control " + 
                "AND type = 'index';";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@pc", NUI_EncodePC(OBJECT_SELF));
    SqlBindString(sql, "@form", sFormID);
    SqlBindString(sql, "@control", sControlID);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : -1;
}

int NUI_GetAndIncrementBuildSeriesIndex(string sFormID, string sControlID)
{
    int nIndex = NUI_GetBuildSeriesIndex(sFormID, sControlID);
    NUI_IncrementBuildSeriesIndex(sFormID, sControlID);

    return nIndex;
}

int NUI_GetBuildSeriesCount(string sFormID, string sControlID, int nElements = 1)
{
    sQuery = "SELECT json_array_length(value, '$.draw_list'), " +
                "json_extract(value, '$.draw_list') " +
             "FROM " + NUI_DATA + ", json_tree(" + NUI_DATA + ".data, '$') " +
             "WHERE json_tree.type = 'object' " +
                "AND json_extract(value, '$.type') = 'spacer' " +
                "AND pc = @pc " +
                "AND form = @form " +
                "AND control = @control;";
    
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    SqlBindString(sql, "@pc", NUI_EncodePC(OBJECT_SELF));
    SqlBindString(sql, "@control", sControlID);

    return SqlStep(sql) ? SqlGetInt(sql, 0) / nElements : -1;
}

void NUI_RegisterCustomControl(string sControl)
{
    sQuery = "INSERT INTO " + NUI_CONTROL + "(control, file) " +
            "VALUES (@control, @file) " +
            "ON CONFLICT (control) DO UPDATE SET file = @file;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@control", sControl);
    SqlBindString(sql, "@file", GetLocalString(GetModule(), NUI_CURRENT_CONTROLFILE));

    SqlStep(sql);
}

json NUI_GetJSONSegmentByPath(string sFormID, string sPath)
{

    return JsonNull();
}
