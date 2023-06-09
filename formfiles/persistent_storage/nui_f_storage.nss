/// ----------------------------------------------------------------------------
/// @file   nui_f_storage.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Persistent Storage formfile
/// ----------------------------------------------------------------------------

const string FORM_ID      = "persistent_storage";
const string PS_DATABASE  = "nui_ps_data";
const string FORM_VERSION = "0.2.2";

const int PS_ACCESS_EXCLUSIVE    = 1;
const int PS_ACCESS_CONTENTIOUS  = 2;

const int PS_CONTAINER_PUBLIC    = 1;
const int PS_CONTAINER_CHARACTER = 2;
const int PS_CONTAINER_CDKEY     = 3;

const int PS_CONTAINER_ITEMS_NONE = 1;
const int PS_CONTAINER_ITEMS_ANY  = 2;

const int PS_UNLIMITED = -1;
const int PS_NONE = -2;

const int PS_TRUE = 1;
const int PS_FALSE = -1;

const float PS_UNLIMITED_DISTANCE = -1.0;

const string PS_TITLE                         = "PS_TITLE";
const string PS_FORCE_SEARCH_BUTTON           = "PS_FORCE_SEARCH_BUTTON";
const string PS_FORCE_OBJECT_STATE            = "PS_FORCE_OBJECT_STATE";
const string PS_STORAGE_LIMIT                 = "PS_STORAGE_LIMIT";
const string PS_DISTANCE                      = "PS_DISTANCE";
const string PS_UNIQUE_ID                     = "PS_UNIQUE_ID";
const string PS_ACCESS_TYPE                   = "PS_ACCESS_TYPE";
const string PS_CONTAINER_TYPE                = "PS_CONTAINER_TYPE";
const string PS_OPEN_INVENTORY                = "PS_OPEN_INVENTORY";
const string PS_MAX_GOLD                      = "PS_MAX_GOLD";
const string PS_MAX_CONTAINER_ITEMS           = "PS_MAX_CONTAINER_ITEMS";
const string PS_MAX_CONTAINER_ITEMS_INVENTORY = "PS_MAX_CONTAINER_ITEMS_INVENTORY";
const string PS_ORIGINAL_NAME                 = "PS_ORIGINAL_NAME";

const string PS_DESTROYED           = "PS_DESTROYED";

const string PS_TARGETING_MODE      = "PS_TARGETING_MODE";
const string PS_SEARCH_STRING       = "PS_SEARCH_STRING";

const string PS_CONTAINER           = "PS_CONTAINER";

const string PS_GEOMETRY            = "PS_GEOMETRY";
const string PS_UUID_ARRAY          = "PS_UUID_ARRAY";
const string PS_USERS               = "PS_USERS";

#include "nui_i_library"
#include "util_i_strings"
#include "nui_c_storage"
#include "util_i_varlists"

object ps_GetContainer(object oPC)
{
    return GetLocalObject(oPC, PS_CONTAINER);
}

int ps_GetLocalIntOrDefault(object oPC, string sVarName, int nDefault)
{
    object oContainer = GetIsPC(oPC) ? ps_GetContainer(oPC) : oPC;
    int n = GetLocalInt(oContainer, sVarName);
    return n ? n : nDefault;
}

string ps_GetLocalStringOrDefault(object oPC, string sVarName, string sDefault)
{
    object oContainer = GetIsPC(oPC) ? ps_GetContainer(oPC) : oPC;
    string s = GetLocalString(oContainer, sVarName);
    return s != "" ? s : sDefault;
}

float ps_GetLocalFloatOrDefault(object oPC, string sVarName, float fDefault)
{
    object oContainer = GetIsPC(oPC) ? ps_GetContainer(oPC) : oPC;
    float f = GetLocalFloat(oContainer, sVarName);
    return f != 0.0 ? f : fDefault;
}

string ps_GetContainerID(object oPC)
{
    return ps_GetLocalStringOrDefault(oPC, PS_UNIQUE_ID, GetTag(ps_GetContainer(oPC)));
}

int ps_GetUseSearchButton(object oPC)
{
    return ps_GetLocalIntOrDefault(oPC, PS_FORCE_SEARCH_BUTTON, PS_FORCE_SEARCH_BUTTON_DEFAULT) == PS_TRUE;
}

int ps_GetSaveObjectState(object oPC)
{
    return ps_GetLocalIntOrDefault(oPC, PS_FORCE_OBJECT_STATE, PS_FORCE_OBJECT_STATE_DEFAULT) == PS_TRUE;
}

int ps_GetContainerType(object oPC)
{
    int nType = GetLocalInt(oPC, PS_CONTAINER_TYPE);
    object oContainer = ps_GetContainer(oPC);

    if (!nType && GetObjectType(oContainer) == OBJECT_TYPE_ITEM)
        return PS_CONTAINER_ITEM_TYPE_DEFAULT;
    else
        return PS_CONTAINER_TYPE_DEFAULT;
}

int ps_GetAccessType(object oPC)
{
    return ps_GetLocalIntOrDefault(oPC, PS_ACCESS_TYPE, PS_ACCESS_TYPE_DEFAULT);
}

int ps_GetMaxItems(object oPC)
{
    return ps_GetLocalIntOrDefault(oPC, PS_STORAGE_LIMIT, PS_STORAGE_LIMIT_DEFAULT);
}

int ps_GetMaxContainerItems(object oPC)
{
    return ps_GetLocalIntOrDefault(oPC, PS_MAX_CONTAINER_ITEMS, PS_MAX_CONTAINER_ITEMS_DEFAULT);
}

int ps_GetMaxContainterItemInventory(object oPC)
{
    return ps_GetLocalIntOrDefault(oPC, PS_MAX_CONTAINER_ITEMS_INVENTORY, PS_MAX_CONTAINER_ITEMS_INVENTORY_DEFAULT);
}

float ps_GetMaxDistance(object oPC)
{
    return ps_GetLocalFloatOrDefault(oPC, PS_DISTANCE, PS_DISTANCE_DEFAULT);
}

int ps_GetOpenInventory(object oPC)
{
    return ps_GetLocalIntOrDefault(oPC, PS_OPEN_INVENTORY, PS_OPEN_INVENTORY_DEFAULT) == PS_TRUE;
}

int ps_GetMaxGold(object oPC)
{
    object oContainer = ps_GetContainer(oPC);
    if (GetObjectType(oContainer) == OBJECT_TYPE_ITEM)
        return PS_NONE;
    else
        return ps_GetLocalIntOrDefault(oPC, PS_MAX_GOLD, PS_MAX_GOLD_DEFAULT);
}

object ps_GetFirstUser(object oPC)
{
    return GetListObject(ps_GetContainer(oPC), 0, PS_USERS);
}

int ps_RemoveUser(object oPC)
{
    return RemoveListObject(ps_GetContainer(oPC), oPC, PS_USERS, TRUE);
}

string ps_GetOwner(object oPC, string sType = "")
{
    if (ps_GetAccessType(oPC) == PS_ACCESS_CONTENTIOUS && ps_GetContainerType(oPC) != PS_CONTAINER_PUBLIC)
        oPC = ps_GetFirstUser(oPC);

    if      (sType == "")      return GetObjectUUID(oPC) + ":" + GetPCPublicCDKey(oPC, TRUE);
    else if (sType == "uuid")  return GetObjectUUID(oPC);
    else if (sType == "cdkey") return GetPCPublicCDKey(oPC, TRUE);
    else                       return "";
}

int ps_GetIsColored(string s)
{
    string sPattern = "*<c???>*</c>*";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), "SELECT @string GLOB @pattern;");
    SqlBindString(sql, "@string", s);
    SqlBindString(sql, "@pattern", sPattern);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

void ps_BeginTransaction()
{
    SqlStep(SqlPrepareQueryCampaign(PS_DATABASE, "BEGIN TRANSACTION;"));
}

void ps_CommitTransaction()
{
    SqlStep(SqlPrepareQueryCampaign(PS_DATABASE, "COMMIT TRANSACTION;"));
}

sqlquery ps_PrepareQuery(string sQuery)
{
    return SqlPrepareQueryCampaign(PS_DATABASE, sQuery);
}

string ps_GetTableName(object oPC)
{
    return ps_GetContainerID(oPC);
}

void ps_InitializeDatabase(object oPC)
{
    string sTable = ps_GetTableName(oPC);
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name = @table;";
    sqlquery sql  = ps_PrepareQuery(sQuery);
    SqlBindString(sql, "@table", sTable);

    if (!SqlStep(sql))
    {
        sQuery = 
            "CREATE TABLE IF NOT EXISTS " + sTable + " (" +
            "owner TEXT NOT NULL DEFAULT '', " +
            "item_uuid TEXT NOT NULL DEFAULT '', " +
            "item_name TEXT NOT NULL DEFAULT '', " +
            "item_baseitem INTEGER NOT NULL DEFAULT '', " +
            "item_stacksize INTEGER NOT NULL DEFAULT '', " +
            "item_iconresref TEXT NOT NULL DEFAULT '', " +
            "item_data TEXT_NOT NULL DEFAULT '', " +
            "PRIMARY KEY(owner, item_uuid));";
        SqlStep(ps_PrepareQuery(sQuery));
    }
}

void ps_EnterDepositMode(object oPC)
{
    SetLocalInt(oPC, PS_TARGETING_MODE, TRUE);
    EnterTargetingMode(oPC, OBJECT_TYPE_ITEM);
}

int ps_CountStoredItems(object oPC)
{
    string sAnd, sOwner;

    int nType = ps_GetContainerType(oPC);
    if (nType == PS_CONTAINER_CHARACTER || nType == PS_CONTAINER_CDKEY)
    {
        sAnd = " AND owner GLOB @owner";
        if (nType == PS_CONTAINER_CHARACTER) sOwner = ps_GetOwner(oPC, "uuid") + ":*";
        else                                 sOwner = "*:" + ps_GetOwner(oPC, "cdkey");
    }

    string sQuery = 
        "SELECT COUNT(*) FROM " + ps_GetTableName(oPC) + " " +
        "WHERE item_uuid != 'gold'" + sAnd + ";";
    sqlquery sql = ps_PrepareQuery(sQuery);

    if (sAnd != "")
        SqlBindString(sql, "@owner", sOwner);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int ps_CountStoredGold(object oPC)
{
    int nType = ps_GetContainerType(oPC);
    string sWhere  = (nType == PS_CONTAINER_PUBLIC ? "" : " AND owner GLOB @owner");

    string sQuery = 
        "SELECT SUM(item_stacksize) FROM " + ps_GetTableName(oPC) + " " +
        "WHERE item_uuid == 'gold'" + sWhere + ";";
    sqlquery sql = ps_PrepareQuery(sQuery);
    
    if      (nType == PS_CONTAINER_CHARACTER) SqlBindString(sql, "@owner", ps_GetOwner(oPC, "uuid") + ":*");
    else if (nType == PS_CONTAINER_CDKEY)     SqlBindString(sql, "@owner", "*:" + ps_GetOwner(oPC, "cdkey"));

    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

string ps_GetIconResref(object oItem, json jItem, int nBaseItem)
{
    if (nBaseItem == BASE_ITEM_CLOAK)
        return "iit_cloak";
    else if (nBaseItem == BASE_ITEM_SPELLSCROLL || nBaseItem == BASE_ITEM_ENCHANTED_SCROLL)
    {
        if (GetItemHasItemProperty(oItem, ITEM_PROPERTY_CAST_SPELL))
        {
            itemproperty ip = GetFirstItemProperty(oItem);
            while (GetIsItemPropertyValid(ip))
            {
                if (GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL)
                    return Get2DAString("iprp_spells", "Icon", GetItemPropertySubType(ip));

                ip = GetNextItemProperty(oItem);
            }
        }
    }
    else if (Get2DAString("baseitems", "ModelType", nBaseItem) == "0")
    {
        json jSimpleModel = JsonPointer(jItem, "/ModelPart1/value");
        if (JsonGetType(jSimpleModel) == JSON_TYPE_INTEGER)
        {
            string sSimpleModelId = IntToString(JsonGetInt(jSimpleModel));
            while (GetStringLength(sSimpleModelId) < 3)
                sSimpleModelId = "0" + sSimpleModelId;

            string sDefaultIcon = Get2DAString("baseitems", "DefaultIcon", nBaseItem);
            switch (nBaseItem)
            {
                case BASE_ITEM_MISCSMALL:
                case BASE_ITEM_CRAFTMATERIALSML:
                    sDefaultIcon = "iit_smlmisc_" + sSimpleModelId;
                    break;
                case BASE_ITEM_MISCMEDIUM:
                case BASE_ITEM_CRAFTMATERIALMED:
                case 112:
                    sDefaultIcon = "iit_midmisc_" + sSimpleModelId;
                    break;
                case BASE_ITEM_MISCLARGE:
                    sDefaultIcon = "iit_talmisc_" + sSimpleModelId;
                    break;
                case BASE_ITEM_MISCTHIN:
                    sDefaultIcon = "iit_thnmisc_" + sSimpleModelId;
                    break;
            }

            int nLength = GetStringLength(sDefaultIcon);
            if (GetSubString(sDefaultIcon, nLength - 4, 1) == "_")
                sDefaultIcon = GetStringLeft(sDefaultIcon, nLength - 4);

            string sIcon = sDefaultIcon + "_" + sSimpleModelId;
            if (ResManGetAliasFor(sIcon, RESTYPE_TGA) != "")
                return sIcon;
        }
    }

    return Get2DAString("baseitems", "DefaultIcon", nBaseItem);
}

string ps_FormatGold(int nGold, int nForce = FALSE)
{
    if (nGold < 100000 || nForce)
        return FormatInt(nGold, "%,d");
    else if (nGold >= 1000000)
        return FormatFloat(nGold / 1000000.0, "%.1fM");
    else
        return FormatFloat(nGold / 1000.0, "%.1fk");
}

void ps_UpdateGoldBinds(object oPC, int nToken, int nTotal = -1)
{
    if (nTotal == -1)
        nTotal = ps_CountStoredGold(oPC);

    NuiSetBind(oPC, nToken, "gold_stored", JsonInt(nTotal));
    NuiSetBind(oPC, nToken, "gold_stored_label", JsonString("Gold: " + ps_FormatGold(nTotal)));

    if (nTotal > 100000)
        NuiSetBind(oPC, nToken, "gold_stored_tooltip", JsonString(ps_FormatGold(nTotal, TRUE)));
    else
        NuiSetBind(oPC, nToken, "gold_stored_tooltip", JsonString(""));

    int nGold = GetGold(oPC);

    NuiSetBind(oPC, nToken, "btn_withdraw_gold", JsonBool(nTotal > 0));
    NuiSetBind(oPC, nToken, "btn_deposit_gold", JsonBool(nGold > 0));

    int nAmount = StringToInt(JsonGetString(NuiGetBind(oPC, nToken, "gold_amount")));
    int nWithdraw = nAmount <= 0 || nAmount > nTotal ? nTotal : nAmount;
    int nDeposit  = nAmount <= 0 || nAmount > nGold  ? min(ps_GetMaxGold(oPC) - nTotal, nGold) : nAmount;

    NuiSetBind(oPC, nToken, "btn_withdraw_tooltip", JsonString("Withdraw " + ps_FormatGold(nWithdraw, TRUE) + " gold"));
    NuiSetBind(oPC, nToken, "btn_deposit_tooltip", JsonString("Deposit " + ps_FormatGold(nDeposit, TRUE) + " gold"));
    NuiSetBind(oPC, nToken, "txt_gold_amount", JsonBool(nGold > 0 || nTotal > 0));
}

/// @private Updates the amount of gold stored in a container.  If the container
///     doesn't allow gold, no action is taken.  Stored gold will be updated
///     *by* nGold, not *to* nGold.
/// @param nGold can be positive, negative. `0` is a special case to zero-out
///     the gold in the container (withdrawing all gold) for the owning character
int ps_UpdateGold(object oPC, int nToken, int nGold)
{
    if (ps_GetMaxGold(oPC) <= PS_NONE) return FALSE;

    string sGold = (nGold == 0 ? "@nGold" : "item_stacksize + @nGold");
    string sQuery = 
        "INSERT INTO " + ps_GetTableName(oPC) +
        "(owner, item_uuid, item_baseitem, item_stacksize) " +
        "VALUES (@owner, @item_uuid, @item_baseitem, @item_stacksize) " +
        "ON CONFLICT (owner, item_uuid) DO UPDATE " +
            "SET item_stacksize = " + sGold + ";";

    sqlquery sql = ps_PrepareQuery(sQuery);
    SqlBindString(sql, "@owner",          ps_GetOwner(oPC));
    SqlBindString(sql, "@item_uuid",      "gold");
    SqlBindInt   (sql, "@item_baseitem",  BASE_ITEM_GOLD);
    SqlBindInt   (sql, "@item_stacksize", nGold);
    SqlBindInt   (sql, "@nGold",          nGold);
    
    SqlStep(sql);

    ps_UpdateGoldBinds(oPC, nToken);
    return nGold;
}

int ps_WithdrawGold(object oPC, int nToken, int nGold)
{
    if (ps_GetMaxGold(oPC) <= PS_NONE) return FALSE;

    if (ps_GetContainerType(oPC) != PS_CONTAINER_PUBLIC)
        return ps_UpdateGold(oPC, nToken, -nGold);

    string sTable = ps_GetTableName(oPC);
    string sQuery =
        "DELETE FROM " + sTable + " WHERE ROWID IN (SELECT ROWID FROM " + sTable + " t1 " +
        "WHERE (SELECT SUM(t2.item_stacksize) FROM " + sTable + " t2 WHERE t1.item_stacksize >= " +
        "t2.item_stacksize) <= @target ORDER BY t1.item_stacksize ASC) AND item_uuid = 'gold' " +
        "RETURNING item_stacksize;";
    sqlquery sql = ps_PrepareQuery(sQuery);
    SqlBindInt(sql, "@target", nGold);

    int nRemoved, nRecords;
    while (SqlStep(sql))
    {
        nRemoved += SqlGetInt(sql, 0);
        nRecords++;
    }

    if (!nRecords || nGold - nRemoved > 0)
    {
        sQuery = 
            "UPDATE " + sTable + " SET item_stacksize = item_stacksize - @gold " + 
            "WHERE ROWID IN (SELECT ROWID FROM " + sTable + " WHERE item_stacksize >= " +
            "@gold AND item_uuid = 'gold' ORDER BY RANDOM() LIMIT 1);";
        sql = ps_PrepareQuery(sQuery);
        SqlBindInt(sql, "@gold", nGold - nRemoved);
        SqlStep(sql);
    }

    return TRUE;
}

void ps_UpdateItemList(object oPC, int nFlag = FALSE)
{
    /// @note This NUI_DisplaySubform only exists because of an nui issue where shortening a array bound to a listbox
    ///     a sufficient amount while scrolled near the bottom results in an nui error.  To fix this issue, the listbox
    ///     is implemented as a subform and reloaded here each time this function is called.  It effectively fixes the
    ///     problem, but should be removed when .35 is stable.  See additional sections affected by this in DefineForm().
    NUI_DisplaySubform(oPC, FORM_ID, "grpItems", "lstItems");

    string sAnd, sSearch = GetLocalString(oPC, PS_SEARCH_STRING);
    int n, nItems, nGold, nType = ps_GetContainerType(oPC);
    int nToken = NUI_GetFormToken(oPC, FORM_ID);

    string sWhere  = (nType == PS_CONTAINER_PUBLIC ? "" : " AND owner GLOB @owner");
    json   jWhere = JsonArrayInsert(JsonArray(), JsonString(sWhere));
           sWhere += (sSearch == ""      ? "" : " AND lower(item_name) GLOB @item");
           jWhere = JsonArrayInsert(jWhere, JsonString(sWhere));

    string sTable = ps_GetTableName(oPC);

    string sQuery = 
        "WITH gold AS (SELECT SUM(item_stacksize) pieces FROM " + sTable + " WHERE item_uuid == 'gold'$1 ), " +
        "items AS (SELECT item_uuid, IIF(item_stacksize > 1, item_name || ' (x' || item_stacksize || ')', item_name) name, " +
        "item_iconresref, json('false') selected FROM " + sTable + " WHERE item_uuid != 'gold'$2 " +
        "ORDER BY item_name ASC, item_baseitem ASC) SELECT COUNT(items.item_uuid) items, gold.pieces, " +
        "IIF(json_group_array(item_uuid) == json_array(null), json_array(), json_group_array(item_uuid)) uuid, " +
        "IIF(json_group_array(name) == json_array(null), json_array(), json_group_array(name)) name, " +
        "IIF(json_group_array(item_iconresref) == json_array(null), json_array(), json_group_array(item_iconresref)) resref, " +
        "IIF(json_group_array(json(selected)) == json_array(null), json_array(), json_group_array(json(selected))) selected " +
        "FROM gold LEFT JOIN items;";

    sqlquery sql = ps_PrepareQuery(SubstituteString(sQuery, jWhere));
    
    if (sSearch != "") SqlBindString(sql, "@item", "*" + GetStringLowerCase(sSearch) + "*");
    
    if      (nType == PS_CONTAINER_CHARACTER) SqlBindString(sql, "@owner", ps_GetOwner(oPC, "uuid") + ":*");
    else if (nType == PS_CONTAINER_CDKEY)     SqlBindString(sql, "@owner", "*:" + ps_GetOwner(oPC, "cdkey"));

    if (SqlStep(sql))
    {
        nItems = SqlGetInt(sql, 0);
        nGold = SqlGetInt(sql, 1);
        SetLocalJson(oPC, PS_UUID_ARRAY, SqlGetJson(sql, 2));
        NuiSetBind(oPC, nToken, "names", SqlGetJson(sql, 3));
        NuiSetBind(oPC, nToken, "icons", SqlGetJson(sql, 4));
        NuiSetBind(oPC, nToken, "selected", SqlGetJson(sql, 5));
    }

    int nMax = ps_GetMaxItems(oPC);
    if (nMax >= 0)
    {
        string sColor;
        float f = nItems * 1.0 / nMax;

        if      (f > 0.9)  sColor = NUI_DefineHexColor(COLOR_RED);
        else if (f > 0.75) sColor = NUI_DefineHexColor(COLOR_YELLOW);
        else               sColor = NUI_DefineHexColor(COLOR_GREEN);

        NuiSetBind(oPC, nToken, "progress", JsonFloat(f));
        NuiSetBind(oPC, nToken, "progress_color", JsonParse(sColor));
        NuiSetBind(oPC, nToken, "progress_tooltip", JsonString(IntToString(nItems) + " of " + IntToString(nMax) + " items stored"));
    }
    else
    {
        NuiSetBind(oPC, nToken, "progress", JsonFloat(0.0));
        NuiSetBind(oPC, nToken, "progress_tooltip", JsonString("This container has unlimited item storage"));
    }

    NuiSetBind(oPC, nToken, "btn_withdraw", JsonBool(FALSE));
    NuiSetBind(oPC, nToken, "btn_withdraw_all", JsonBool(nItems > 0 && ps_GetAccessType(oPC) != PS_ACCESS_CONTENTIOUS));
    NuiSetBind(oPC, nToken, "btn_deposit", JsonBool(nItems < nMax || nMax <= 0));

    ps_UpdateGoldBinds(oPC, nToken, nGold);

    if (!nFlag && ps_GetAccessType(oPC) == PS_ACCESS_CONTENTIOUS)
    {
        object oContainer = ps_GetContainer(oPC);
        int n; for (n; n < CountObjectList(oContainer, PS_USERS); n++)
        {
            object oUser = GetListObject(oContainer, n, PS_USERS);
            if (oUser != oPC && NuiFindWindow(oUser, FORM_ID))
                ps_UpdateItemList(oUser, TRUE);
        }
    }
}

int ps_CountInventoryItems(object oContainer)
{
    int n;
    object oItem = GetFirstItemInInventory(oContainer);
    while (GetIsObjectValid(oItem))
    {
        n++;
        oItem = GetNextItemInInventory(oContainer);
    }

    return n;
}

int ps_CountContainerItems(object oPC)
{
    string sQuery = "SELECT COUNT(*) FROM " + ps_GetTableName(oPC) + " " +
        "WHERE item_data != '' AND json_extract(item_data, '$.ItemList') IS NOT NULL;";
    sqlquery sql = ps_PrepareQuery(sQuery);
    return SqlStep(sql) ? SqlGetInt(sql, 0) : 0;
}

int ps_DepositContainerItem(object oPC, object oItem)
{
    if (!GetHasInventory(oItem))
        return TRUE;

    int nMaxContainerItems = ps_GetMaxContainerItems(oPC);
    if (nMaxContainerItems <= PS_NONE)
        return FALSE;
    else
    {
        if (nMaxContainerItems == PS_UNLIMITED || ps_CountContainerItems(oPC) < nMaxContainerItems)
        {
            int nMaxItems = ps_GetMaxContainterItemInventory(oPC);
            if (nMaxItems == PS_UNLIMITED)
                return TRUE;
            else
            {
                if (nMaxItems == PS_NONE)
                    return !GetIsObjectValid(GetFirstItemInInventory(oItem));
                else
                    return ps_CountInventoryItems(oItem) <= nMaxItems;
            }
        }
        else
            return FALSE;
    }
}

void ps_DepositItem(object oPC, object oItem)
{
    DeleteLocalInt(oPC, PS_TARGETING_MODE);

    if (!GetIsObjectValid(oItem) || GetLocalInt(oItem, PS_DESTROYED) || GetObjectType(oItem) != OBJECT_TYPE_ITEM)
        return;

    if (GetItemCursedFlag(oItem) || GetItemPossessor(oItem) != oPC)
        return;

    int nStoredItems = ps_CountStoredItems(oPC);
    int nMaxItems = ps_GetMaxItems(oPC);
    if (nMaxItems > 0 && nStoredItems >= nMaxItems)
    {
        SendMessageToPC(oPC, "Your storage is full, withdraw an item first.");
        return;
    }

    if (!ps_DepositContainerItem(oPC, oItem))
        return;

    int nItemBaseItem = GetBaseItemType(oItem);
    string sItemName  = GetIdentified(oItem) ? GetName(oItem) : GetStringByStrRef(StringToInt(Get2DAString("baseitems", "Name", nItemBaseItem))) + " (Unidentified)";
    json jItemData    = ObjectToJson(oItem, ps_GetSaveObjectState(oPC));

    if (ps_GetIsColored(sItemName))
    {
        JsonObjectSet(jItemData, PS_ORIGINAL_NAME, JsonString(sItemName));
        sItemName = UnColorString(sItemName);
    }

    string sQuery =
        "INSERT INTO " + ps_GetTableName(oPC) +
        "(owner, item_uuid, item_name, item_baseitem, item_stacksize, item_iconresref, item_data) " +
        "VALUES(@owner, @item_uuid, @item_name ->> '$', @item_baseitem, @item_stacksize, @item_iconresref, @item_data) " +
        "RETURNING item_uuid;";
    sqlquery sql = ps_PrepareQuery(sQuery);

    SqlBindString(sql, "@owner",           ps_GetOwner(oPC));
    SqlBindString(sql, "@item_uuid",       GetObjectUUID(oItem));
    SqlBindJson  (sql, "@item_name",       JsonString(sItemName));
    SqlBindInt   (sql, "@item_baseitem",   nItemBaseItem);
    SqlBindInt   (sql, "@item_stacksize",  GetItemStackSize(oItem));
    SqlBindString(sql, "@item_iconresref", ps_GetIconResref(oItem, jItemData, nItemBaseItem));
    SqlBindJson  (sql, "@item_data",       jItemData);
    
    if (SqlStep(sql))
    {
        if (SqlGetString(sql, 0) == "")
        {
            NUI_Debug("Error depositing item!", NUI_DEBUG_SEVERITY_ERROR);
            return;
        }
    }

    SetLocalInt(oItem, PS_DESTROYED, TRUE);
    DestroyObject(oItem);

    ps_UpdateItemList(oPC);
    if (++nStoredItems <= nMaxItems || nMaxItems <= 0)
        ps_EnterDepositMode(oPC);
}

/// @private void version of JsonToObject to prevent mass-withdraw overflow errors.
void ps_JsonToObject(json jObject, location l, object oOwner, int nObjectState)
{
    object oItem = JsonToObject(jObject, l, oOwner, nObjectState);
    json   jName = JsonObjectGet(jObject, PS_ORIGINAL_NAME);
    
    if (jName != JsonNull())
        SetName(oItem, JsonGetString(jName));
}

void ps_WithdrawItems(object oPC, int nToken, int bForceAll = FALSE)
{
    json jUUIDs = GetLocalJson(oPC, PS_UUID_ARRAY);
    if (!JsonGetLength(jUUIDs))
        return;

    string sWhere = (bForceAll ? "" : " WHERE truths.value = true");

    string sQuery =
        "WITH truths AS (SELECT ROWID, value FROM json_each(@truths)), " +
        "     uuids AS (SELECT rowid, value FROM json_each(@uuids)) " +
        "DELETE FROM " + ps_GetTableName(oPC) + " WHERE item_uuid IN " +
        "(SELECT uuids.value FROM uuids INNER JOIN truths ON uuids.ROWID " +
        "= truths.ROWID" + sWhere + ") RETURNING item_data;";

    sqlquery sql = ps_PrepareQuery(sQuery);
    SqlBindJson(sql, "@uuids", jUUIDs);
    SqlBindJson(sql, "@truths", NuiGetBind(oPC, nToken, "selected"));

    ps_BeginTransaction();

    location l = GetLocation(oPC);
    int nState = ps_GetSaveObjectState(oPC);

    while (SqlStep(sql))
    {
        json j = SqlGetJson(sql, 0);
        DelayCommand(0.0, ps_JsonToObject(j, l, oPC, nState));
    }

    ps_UpdateItemList(oPC);
    ps_CommitTransaction();
}

void ps_OnFormOpen()
{
    ps_InitializeDatabase(OBJECT_SELF);

    object oContainer = ps_GetContainer(OBJECT_SELF);
    int nAccess = ps_GetAccessType(OBJECT_SELF);
    int nType = ps_GetContainerType(OBJECT_SELF);

    NUI_SetBind(OBJECT_SELF, FORM_ID, "title", nuiString(ps_GetFormTitle(oContainer, OBJECT_SELF, nAccess, nType)));

    if (ps_GetOpenInventory(OBJECT_SELF))
        PopUpGUIPanel(OBJECT_SELF, GUI_PANEL_INVENTORY);

    ps_UpdateItemList(OBJECT_SELF);
}

void ps_OnFormClose()
{
    if (ps_GetAccessType(OBJECT_SELF) == PS_ACCESS_CONTENTIOUS)
        ps_RemoveUser(OBJECT_SELF);

    DeleteLocalInt(OBJECT_SELF, PS_TARGETING_MODE);
    DeleteLocalString(OBJECT_SELF, PS_SEARCH_STRING);
    DeleteLocalJson(OBJECT_SELF, PS_UUID_ARRAY);
    DeleteLocalObject(OBJECT_SELF, PS_CONTAINER);
}

void BindForm()
{
    json jBinds = NUI_GetOrphanBinds(FORM_ID);
    int n; for (n; n < JsonGetLength(jBinds); n++)
    {
        string sValue, sBind = JsonGetString(JsonArrayGet(jBinds, n));
        json jValue = JsonNull();
        
        if (sBind == "search") sValue = nuiString("");

        if (sValue != "")
            NUI_SetBind(OBJECT_SELF, FORM_ID, sBind, sValue);
        else if (jValue != JsonNull())
            NUI_SetBindJ(OBJECT_SELF, FORM_ID, sBind, jValue);
    }
}

void DefineForm()
{
    float fRowHeight = 30.0;

    NUI_CreateForm(FORM_ID, FORM_VERSION);
        NUI_SetTOCTitle("Peristent Storage");
        NUI_SetResizable(FALSE);
        NUI_SubscribeEvent(EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET);
        NUI_SubscribeEvent(EVENT_SCRIPT_PLACEABLE_ON_USED);
        NUI_SubscribeEvent(EVENT_SCRIPT_PLACEABLE_ON_OPEN);
        NUI_SubscribeEvent(EVENT_SCRIPT_PLACEABLE_ON_CLOSED);
        NUI_SubscribeEvent(EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM);
    {
        NUI_AddRow();
            NUI_AddColumn();
                NUI_SetWidth(350.0);

                NUI_AddRow();
                    NUI_SetHeight(20.0);
                    NUI_SetMargin(0.0);

                    NUI_AddProgressBar();
                        NUI_BindTooltip("progress_tooltip");
                        NUI_BindValue("progress");
                        NUI_BindForegroundColor("progress_color");
                NUI_CloseRow();

                NUI_AddRow();
                    NUI_SetHeight(fRowHeight);
                    NUI_SetMargin(0.0);

                    NUI_AddTextbox();
                        NUI_SetPlaceholder("Search...");
                        NUI_BindValue("search", TRUE);
                        NUI_SetLength(64);
                        NUI_SetMultiline(FALSE);
                    NUI_AddCommandButton("btn_clear");
                        NUI_SetLabel("X");
                        NUI_BindEnabled("btn_clear");
                        NUI_SetTooltip("Clear search criteria");
                        NUI_SetWidth(35.0);
                    NUI_AddCommandButton("btn_search");
                        NUI_SetLabel("Search");
                        NUI_SetWidth(60.0);
                        NUI_BindEnabled("btn_search");
                        NUI_SetTooltip("Search item list by criteria");
                        NUI_SetDisabledTooltip("Live search enabled");
                NUI_CloseRow();

                /// @note Due to the list size issue with NUI in .34, the item listbox had to be
                ///     implemented as a subform.  The commented out section immediately below
                ///     this AddRow() block is the original implementation and should be reinstanted
                ///     once (if?) .35 is stable.  Additionally, remove the subform definition
                ///     below.
                NUI_AddRow();
                    NUI_SetHeight(288.0);
                    NUI_SetMargin(0.0);

                    NUI_AddGroup("grpItems");
                        NUI_SetBorder(TRUE);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddSpacer();
                    } NUI_CloseGroup();
                NUI_CloseRow();

                /*
                NUI_AddRow();
                    NUI_AddListbox();
                        NUI_BindRowCount("icons");
                        NUI_SetRowHeight(32.0);
                    {
                        NUI_AddGroup();
                            NUI_SetBorder(TRUE);
                            NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                            NUI_SetTemplateWidth(32.0);
                            NUI_SetTemplateVariable(FALSE);
                        {
                            NUI_AddImage();
                                NUI_BindResref("icons");
                                NUI_SetAspect(NUI_ASPECT_FIT);
                                NUI_SetHorizontalAlignment(NUI_HALIGN_CENTER);
                                NUI_SetVerticalAlignment(NUI_VALIGN_MIDDLE);
                        } NUI_CloseGroup();
                        NUI_AddCheckbox();
                            NUI_BindLabel("names");
                            NUI_BindValue("selected");
                    } NUI_CloseListbox();
                NUI_CloseRow();
                */

                NUI_AddRow();
                    NUI_SetHeight(fRowHeight);
                    NUI_SetMargin(0.0);
                    
                    NUI_AddCommandButton("btn_withdraw");
                        NUI_SetLabel("Withdraw");
                        NUI_BindEnabled("btn_withdraw");
                        NUI_SetTooltip("Withdraw selected items");
                        NUI_SetDisabledTooltip("No items selected for withdrawal");
                        NUI_SetWidth(100.0);
                    NUI_AddCommandButton("btn_withdraw_all");
                        NUI_SetLabel("All");
                        NUI_BindEnabled("btn_withdraw_all");
                        NUI_SetTooltip("Withdraw all items");
                        NUI_SetDisabledTooltip("No items available for withdrawal");
                        NUI_SetWidth(45.0);
                    NUI_AddSpacer();
                    NUI_AddCommandButton("btn_deposit");
                        NUI_SetLabel("Deposit");
                        NUI_BindEnabled("btn_deposit");
                        NUI_SetTooltip("Select an item to deposit");
                        NUI_SetWidth(100.0);
                NUI_CloseRow();

                NUI_AddRow();
                    NUI_SetHeight(8.0);
                NUI_CloseRow();

                NUI_AddRow();
                    NUI_SetHeight(fRowHeight);
                    NUI_BindVisible("showGold");
                    NUI_SetMargin(0.0);

                    NUI_AddGroup();
                        NUI_SetBorder(TRUE);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                        NUI_SetWidth(100.0);
                        NUI_BindTooltip("gold_stored_tooltip");
                    {
                        NUI_AddLabel();
                            NUI_BindLabel("gold_stored_label");
                            NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_GOLD));
                            NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                            NUI_SetVerticalAlignment(NUI_VALIGN_MIDDLE);
                    } NUI_CloseGroup();

                    NUI_AddTextbox();
                        NUI_SetPlaceholder("Amount...");
                        NUI_BindEnabled("txt_gold_amount");
                        NUI_BindValue("gold_amount", TRUE);
                        NUI_BindTooltip("gold_amount_tooltip");
                        NUI_SetLength(64);
                        NUI_SetMultiline(FALSE);

                    NUI_AddCommandButton("btn_withdraw_gold");
                        NUI_SetLabel("Withdraw");
                        NUI_BindEnabled("btn_withdraw_gold");
                        NUI_BindTooltip("btn_withdraw_tooltip");
                        NUI_SetWidth(75.0);

                    NUI_AddCommandButton("btn_deposit_gold");
                        NUI_SetLabel("Deposit");
                        NUI_BindEnabled("btn_deposit_gold");
                        NUI_BindTooltip("btn_deposit_tooltip");
                        NUI_SetWidth(75.0);
                NUI_CloseRow();
            NUI_CloseColumn();
        NUI_CloseRow();
    }

    /// @note Remove this subform definition when .35 is stable.
    NUI_CreateSubform("lstItems");
    {
        NUI_AddRow();
            NUI_AddListbox();
                NUI_BindRowCount("icons");
                NUI_SetRowHeight(32.0);
                NUI_SetBorder(FALSE);
            {
                NUI_AddGroup();
                    NUI_SetBorder(TRUE);
                    NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    NUI_SetTemplateWidth(32.0);
                    NUI_SetTemplateVariable(FALSE);
                {
                    NUI_AddImage();
                        NUI_BindResref("icons");
                        NUI_SetAspect(NUI_ASPECT_FIT);
                        NUI_SetHorizontalAlignment(NUI_HALIGN_CENTER);
                        NUI_SetVerticalAlignment(NUI_VALIGN_MIDDLE);
                } NUI_CloseGroup();
                NUI_AddCheckbox();
                    NUI_BindLabel("names");
                    NUI_BindValue("selected", TRUE);
            } NUI_CloseListbox();
        NUI_CloseRow();
    }

    NUI_CreateDefaultProfile();
    {
        NUI_SetProfileBind("geometry", NUI_DefineRectangle(360.0, 0.0, 370.0, 470.0));
        NUI_SetProfileBind("search", nuiString(""));
        NUI_SetProfileBind("showGold", nuiBool(TRUE));
        NUI_SetProfileBind("showDMPanel", nuiBool(FALSE));
    }

    NUI_CreateProfile("noGold");
    {
        NUI_SetProfileBind("showGold", nuiBool(FALSE));
    }
}

void HandleNUIEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    if (ed.sEvent == "click")
    {
        if (ed.sControlID == "btn_withdraw")
            ps_WithdrawItems(ed.oPC, ed.nToken);
        else if (ed.sControlID == "btn_withdraw_all")
            ps_WithdrawItems(ed.oPC, ed.nToken, TRUE);  
        else if (ed.sControlID == "btn_deposit")
            ps_EnterDepositMode(ed.oPC);
        else if (ed.sControlID == "btn_deposit_gold")
        {
            int nAmount, nGold = GetGold(ed.oPC);
            string sAmount = JsonGetString(NuiGetBind(ed.oPC, ed.nToken, "gold_amount"));

            if (sAmount == "")
                nAmount = nGold;
            else 
                nAmount = clamp(StringToInt(sAmount), 0, nGold);            

            if ((nGold = ps_GetMaxGold(ed.oPC)) > -2)
                nAmount = min(nAmount, nGold - JsonGetInt(NuiGetBind(ed.oPC, ed.nToken, "gold_stored")));

            if (nAmount <= 0) return;

            if (ps_UpdateGold(ed.oPC, ed.nToken, nAmount))
                AssignCommand(ed.oPC, TakeGoldFromCreature(nAmount, ed.oPC, TRUE));

            DelayCommand(0.1, ps_UpdateGoldBinds(ed.oPC, ed.nToken));
        }
        else if (ed.sControlID == "btn_withdraw_gold")
        {
            int nAmount, nGold = JsonGetInt(NuiGetBind(ed.oPC, ed.nToken, "gold_stored"));
            string sAmount = JsonGetString(NuiGetBind(ed.oPC, ed.nToken, "gold_amount"));

            if (sAmount == "")
                nAmount = nGold;
            else 
                nAmount = clamp(StringToInt(sAmount), 0, nGold);

            if (nAmount <= 0) return;

            if (ps_WithdrawGold(ed.oPC, ed.nToken, nAmount))
                GiveGoldToCreature(ed.oPC, nAmount);

            ps_UpdateGoldBinds(ed.oPC, ed.nToken);
        }
        else if (ed.sControlID == "btn_search")
        {
            SetLocalString(ed.oPC, PS_SEARCH_STRING, JsonGetString(NuiGetBind(ed.oPC, ed.nToken, "search")));
            ps_UpdateItemList(ed.oPC);
        }
        else if (ed.sControlID == "btn_clear")
        {
            NuiSetBind(ed.oPC, ed.nToken, "search", JsonString(""));

            if (ps_GetUseSearchButton(ed.oPC))
            {
                DeleteLocalString(ed.oPC, PS_SEARCH_STRING);
                ps_UpdateItemList(ed.oPC);
            }
        }
    }
    else if (ed.sEvent == "watch")
    {
        if (ed.sControlID == "geometry")
        {
            SetLocalJson(ed.oPC, PS_GEOMETRY, NuiGetBind(ed.oPC, ed.nToken, "geometry"));
        }
        else if (ed.sControlID == "selected")
        {
            json jSelected = JsonFind(NuiGetBind(ed.oPC, ed.nToken, ed.sControlID), JsonBool(TRUE));
            NuiSetBind(ed.oPC, ed.nToken, "btn_withdraw", JsonBool(jSelected != JsonNull()));
        }
        else if (ed.sControlID == "search")
        {
            string sSearch = JsonGetString(NuiGetBind(ed.oPC, ed.nToken, "search"));
            int nSearch = GetStringLength(sSearch);

            NuiSetBind(ed.oPC, ed.nToken, "btn_clear", JsonBool(nSearch > 0));

            if (ps_GetUseSearchButton(ed.oPC))
            {
                NuiSetBind(ed.oPC, ed.nToken, "btn_search", JsonBool(nSearch > 0));
                if (!nSearch)
                {
                    DeleteLocalString(ed.oPC, PS_SEARCH_STRING);
                    ps_UpdateItemList(ed.oPC);
                }
            }
            else
            {
                NuiSetBind(ed.oPC, ed.nToken, "btn_search", JsonBool(FALSE));
                SetLocalString(ed.oPC, PS_SEARCH_STRING, sSearch);
                ps_UpdateItemList(ed.oPC);
            }
        }
        else if (ed.sControlID == "gold_amount")
        {
            string sAmount = JsonGetString(NuiGetBind(ed.oPC, ed.nToken, ed.sControlID));
            if (!GetIsNumeric(sAmount))
            {
                NuiSetBind(ed.oPC, ed.nToken, "btn_withdraw_gold", jFalse);
                NuiSetBind(ed.oPC, ed.nToken, "btn_deposit_gold", jFalse);
                NuiSetBind(ed.oPC, ed.nToken, "gold_amount_tooltip", JsonString("Error: Only Digits Allowed"));
                return;
            }

            NuiSetBind(ed.oPC, ed.nToken, "gold_amount_tooltip", JsonString(""));

            int nStored = JsonGetInt(NuiGetBind(ed.oPC, ed.nToken, "gold_stored"));
            int nAmount = clamp(StringToInt(sAmount), 0, max(nStored, GetGold(ed.oPC)));

            if (StringToInt(sAmount) > nAmount)
                NuiSetBind(ed.oPC, ed.nToken, ed.sControlID, JsonString(IntToString(nAmount)));

            ps_UpdateGoldBinds(ed.oPC, ed.nToken);
        }
    }
    else if (ed.sEvent == "open")
        ps_OnFormOpen();
    else if (ed.sEvent == "close")
        ps_OnFormClose();
}

void ps_CloseContainer(object oPC)
{
    if (NUI_GetFormToken(oPC, FORM_ID))
        NUI_CloseForm(oPC, FORM_ID);
}

/// @private Closes the form if the player moves too far away from the container.
void ps_OnPCHeartbeat(object oPC, object oContainer)
{
    object oLastContainer = GetLocalObject(oPC, PS_CONTAINER);
    if (oLastContainer == OBJECT_INVALID || oLastContainer != oContainer)
        return;

    if (GetObjectType(oContainer) == OBJECT_TYPE_ITEM)
        return;

    float fMax = ps_GetMaxDistance(oPC);
    if (fMax < 0.0) return;

    if (GetDistanceBetween(oLastContainer, oPC) > fMax)
        ps_CloseContainer(oPC);
    else
        AssignCommand(oPC, DelayCommand(2.0, ps_OnPCHeartbeat(oPC, oLastContainer)));
}

/// @private Closes the form for any using player that moves too far away from the
///     container.
void ps_OnContainerHeartbeat(object oContainer)
{
    if (GetObjectType(oContainer) == OBJECT_TYPE_ITEM)
        return;

    float fMax = ps_GetLocalFloatOrDefault(oContainer, PS_DISTANCE, PS_DISTANCE_DEFAULT);
    if (fMax < 0.0) return;
    
    int nAccess = ps_GetLocalIntOrDefault(oContainer, PS_ACCESS_TYPE, PS_ACCESS_TYPE_DEFAULT);
    if (nAccess == PS_ACCESS_CONTENTIOUS)
    {
        int n; for (n; n < CountObjectList(oContainer, PS_USERS); n++)
        {
            object oPC = GetListObject(oContainer, n, PS_USERS);
            if (GetDistanceBetween(oContainer, oPC) > fMax)
                ps_CloseContainer(oPC);
        }
    }

    if (CountObjectList(oContainer, PS_USERS))
        AssignCommand(oContainer, DelayCommand(2.0, ps_OnContainerHeartbeat(oContainer)));
}

void ps_OpenContainer(object oPC, object oContainer = OBJECT_INVALID)
{
    //ps_OnFormClose();

    if (oContainer == OBJECT_INVALID)
        oContainer = oPC == OBJECT_SELF ? GetLocalObject(oPC, NUI_OBJECT) : OBJECT_SELF;
    SetLocalObject(oPC, PS_CONTAINER, oContainer);

    if (ps_GetAccessType(oPC) == PS_ACCESS_CONTENTIOUS)
        AddListObject(oContainer, oPC, PS_USERS, TRUE);

    if (GetObjectType(oContainer) != OBJECT_TYPE_ITEM)
    {
        DelayCommand(2.0, ps_OnPCHeartbeat(oPC, oContainer));
        DelayCommand(2.0, ps_OnContainerHeartbeat(oContainer));
    }

    NUI_DisplayForm(oPC, FORM_ID, ps_GetMaxGold(oPC) > -2 ? "default" : "noGold");
}

void HandleModuleEvents()
{
    object oPC = OBJECT_SELF;

    switch (GetCurrentlyRunningEvent())
    {
        case EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET:
        {
            object oPC = GetLastPlayerToSelectTarget();

            if (!GetLocalInt(oPC, PS_TARGETING_MODE) || NuiFindWindow(oPC, FORM_ID) == 0)
                return;

            ps_DepositItem(oPC, GetTargetingModeSelectedObject());
        } break;
        case EVENT_SCRIPT_PLACEABLE_ON_USED:
            if (!GetIsPC(oPC)) oPC = GetLastUsedBy();
        case EVENT_SCRIPT_PLACEABLE_ON_OPEN:
            if (!GetIsPC(oPC)) oPC = GetLastOpenedBy();
            ps_OpenContainer(oPC);
            break;
        case EVENT_SCRIPT_PLACEABLE_ON_CLOSED:
            if (!GetIsPC(OBJECT_SELF)) oPC = GetLastClosedBy();
            ps_CloseContainer(oPC);
            break;
        case EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM:
            ps_OpenContainer(GetItemActivator(), GetItemActivated());
            break;
        default:
    }
}
