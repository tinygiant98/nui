// ---------------------------------------------------------------------------------------
//                            APPEARANCE EDITOR FORMFILE
// ---------------------------------------------------------------------------------------

// As of v1.0.0, all configuration options have been moved to a separate file to prevent
// overwriting server and system settings when new formfile versions are released.  The
// standard configuration file associated with this formfile is nuio_appedit.nss.

// ---------------------------------------------------------------------------------------
//                          DO NOT MAKE ANY CHANGES BELOW THIS LINE
// ---------------------------------------------------------------------------------------

#include "nuio_appedit"

#include "nui_i_main"
#include "util_i_csvlists"
#include "util_i_debug"

const string VERSION = "1.1.0";
const string PROPERTIES = "APPEARANCE_EDITOR_PROPERTIES";
const string FORM_ID = "appearance_editor";

const int CUSTOM_CONTENT = 0;
const int BASE_CONTENT = 1;

const string TWODA_INDEX = "TWODA_INDEX";
const int SIMPLE = 0;
const int LAYERED = 1;
const int COMPOSITE = 2;
const int ARMORANDAPPEARANCE = 3;

int COLOR_WIDTH_CELLS = 16;
int COLOR_HEIGHT_CELLS = 11;

const string IGNORE_EVENTS = "mousedown,range,blur,focus,mousescroll";

void ToggleItemEquippedFlags();
void LoadColorCategoryOptions();
void LoadPartCategoryOptions();
object GetItem(int nSlot = -1);
void UpdateBinds(string sBind, int nToken = -1, int bSetDefaults = FALSE);
json GetArmorAndAppearanceModelData(int nGender, int nRace, int nPhenotype, string sPart);
void HandlePartCategoryToggles();
void HandleModelMatrixToggles();
void HandleColorCategoryToggles(int bClear = FALSE);
void LoadParts(string sModel = "", string sPartCategory = "");
void LoadItemParts(string sModel = "", string sPartCategory = "");
string Get2DAListByCriteria(string s2DA, string sReturnColumn,
                            string sCriteriaColumn = "", string sCriteria = "");
json GetLayeredModelData(string sClass = "");
void UpdateColorSelected();
sqlquery PrepareQuery(string sQuery);
void HighlightTarget(int bHighlight = TRUE);

string _GetKey(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1) return sPair;
    else              return GetSubString(sPair, 0, nIndex);
}

string _GetValue(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1) return "";
    else              return GetSubString(sPair, ++nIndex, GetStringLength(sPair));
}

int GetFormToken()
{
    return NuiFindWindow(OBJECT_SELF, FORM_ID);
}

void SetProperty(string sProperty, json jValue)
{
    json jProperties = GetLocalJson(OBJECT_SELF, PROPERTIES);

    if (jProperties == JsonNull())
        jProperties = JsonObject();

    jProperties = JsonObjectSet(jProperties, sProperty, jValue);
    SetLocalJson(OBJECT_SELF, PROPERTIES, jProperties);
}

json GetProperty(string sProperty)
{
    json jProperties = GetLocalJson(OBJECT_SELF, PROPERTIES);
    return JsonObjectGet(jProperties, sProperty);
}

int  GetIsAppearanceSelected() { return JsonGetInt(GetProperty("isAppearanceSelected")); }
void SetIsAppearanceSelected(int bSelected)
{
    SetProperty("isAppearanceSelected", JsonInt(bSelected));
    UpdateBinds("toggle_appearance_toggled");
    UpdateBinds("toggle_equipment_toggled");
    UpdateBinds("group_category_visible");
}

int  GetIsEquipmentSelected()              { return !JsonGetInt(GetProperty("isAppearanceSelected")); }
void SetIsEquipmentSelected(int bSelected) { SetIsAppearanceSelected(!bSelected); }

string GetColorSheetResref() { return JsonGetString(GetProperty("colorSheetResref")); }
void   SetColorSheetResref(string sResref) 
{ 
    SetProperty("colorSheetResref", JsonString(sResref));
    UpdateBinds("image_colorsheet_resref");
}

json GetOriginalAppearance() { return GetProperty("originalAppearance"); }
void SetOriginalAppearance(string sPartCategory, string sPart)
{
    string sProperty =  (GetIsAppearanceSelected() ? "appearance" : "equipment");
           sProperty += ":" + sPartCategory;

    json j = GetOriginalAppearance();
    if (j == JsonNull())
        j = JsonObject();

    j = JsonObjectSet(j, sProperty, JsonString(sPart));
    SetProperty("originalAppearance", j);
}

int  GetHasItemEquipped()         { return JsonGetInt(GetProperty("hasItemEquipped")); }
int  GetDoesNotHaveItemEquipped() { return !JsonGetInt(GetProperty("hasItemEquipped")); }
void SetHasItemEquipped(int bEquipped)
{
    SetProperty("hasItemEquipped", JsonInt(bEquipped));
    UpdateBinds("label_item_visible");
}

string GetGroupOptions(string sFormID)
{
    sqlquery sqlBinds = NUI_GetBindTable(sFormID);

    string sBind, sIndexes;
    while (SqlStep(sqlBinds))
    {
        sBind = SqlGetString(sqlBinds, 3);
        sIndexes = AddListItem(sIndexes, _GetValue(sBind), TRUE);
        UpdateBinds(sBind);
    }

    return sIndexes;
}

string GetPartCategorySelected() { return JsonGetString(GetProperty("partCategorySelected")); }
void SetPartCategorySelected(string sCategory)
{
    SetProperty("partCategorySelected", JsonString(sCategory));
    HandlePartCategoryToggles();

    LoadParts();
}

string GetPartCategoryOptions() { return JsonGetString(GetProperty("partCategoryOptions")); }
void SetPartCategoryOptions()
{
    string sCategory;
    if (GetIsAppearanceSelected() == TRUE)
        sCategory = "appearance";
    else if (GetIsEquipmentSelected() == TRUE)
        sCategory = "equipment";

    int nToken = GetFormToken();
    string sFormID = "_appedit_tab_part_" + sCategory;
    json j = NUI_GetFormRoot(sFormID);

    NuiSetGroupLayout(OBJECT_SELF, nToken, "part_category_tab", j);
    SetProperty("partCategoryOptions", JsonString(GetGroupOptions(sFormID)));

    if (GetPartCategorySelected() == "")
        SetPartCategorySelected("head");
}

void HandlePartCategoryToggles()
{
    string sOptions = GetPartCategoryOptions();
    string sSelected = GetPartCategorySelected();

    int nToken = GetFormToken();
    int n, nCount = CountList(sOptions);
    for (n = 0; n < nCount; n++)
    {
        string sOption = GetListItem(sOptions, n);
        NUI_SetBindValue(OBJECT_SELF, nToken, "part_cat_value:" + sOption, JsonBool(sOption == sSelected));
    }
}

string GetColorCategorySelected() { return JsonGetString(GetProperty("colorCategorySelected")); }
void SetColorCategorySelected(string sOption)
{
    SetProperty("colorCategorySelected", JsonString(sOption));
    HandleColorCategoryToggles();

    string sResrefs, sPrefix = "gui_pal_";
    if (GetIsAppearanceSelected() == TRUE)
        sResrefs = "skin,hair01,tattoo,tattoo";
    else if (GetIsEquipmentSelected() == TRUE)
        sResrefs = "tattoo,tattoo,tattoo,tattoo,armor01,armor01";

    SetColorSheetResref(sPrefix + GetListItem(sResrefs, StringToInt(sOption)));
    DelayCommand(0.04, UpdateColorSelected());
}

string GetCategoriesFromDatabase()
{
    string sCategory, sResult;
    if (GetIsAppearanceSelected() == TRUE)
        sCategory = "appearance";
    else if (GetIsEquipmentSelected() == TRUE)
        sCategory = "equipment";

    string sFormID = "_appedit_tab_color_" + sCategory;

    sQuery = "SELECT json_extract(value, '$.id') " +
             "FROM " + NUI_FORMS + ", json_tree(" + NUI_FORMS + ".json, '$') " +
             "WHERE type = 'object' " +
                "AND json_extract(value, '$.id') LIKE 'color_cat%' " +
                "AND form = @form;";

    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);

    while (SqlStep(sql))
    {
        string sID = SqlGetString(sql, 0);
        sResult = AddListItem(sResult, _GetValue(sID));
    }

    return sResult;
}

string GetColorCategoryOptions() { return JsonGetString(GetProperty("colorCategoryOptions")); }
void SetColorCategoryOptions()
{
    HandleColorCategoryToggles(TRUE);

    string sCategory;
    if (GetIsAppearanceSelected() == TRUE)
        sCategory = "appearance";
    else if (GetIsEquipmentSelected() == TRUE)
        sCategory = "equipment";
    // TODO add weapons ...

    int nToken = GetFormToken();
    json j = NUI_GetFormRoot("_appedit_tab_color_" + sCategory);
    
    NuiSetGroupLayout(OBJECT_SELF, nToken, "color_category_tab", j);
    SetProperty("colorCategoryOptions", JsonString(GetCategoriesFromDatabase()));
    
    if (GetColorCategorySelected() == "" || HasListItem(GetColorCategoryOptions(), GetColorCategorySelected()) == FALSE)
        SetColorCategorySelected("0");
    else 
        SetColorCategorySelected(GetColorCategorySelected());
}

void HandleColorCategoryToggles(int bClear = FALSE)
{
    string sOptions = GetColorCategoryOptions();
    string sSelected = GetColorCategorySelected();

    int nToken = GetFormToken();
    int n, nCount = CountList(sOptions);
    for (n = 0; n < nCount; n++)
    {
        string sOption = GetListItem(sOptions, n);
        json jValue = bClear == TRUE ? JsonBool(FALSE) : JsonBool(sOption == sSelected);
        NUI_SetBindValue(OBJECT_SELF, nToken, "color_cat_value:" + sOption, jValue);
    }
}

void HandleEquippedItemChanges()
{
    string sOptions = GetPartCategoryOptions();
    int n, nCount = CountList(sOptions);
    for (n = 0; n < nCount; n++)
    {
        string sOption = GetListItem(sOptions, n);
        DelayCommand(0.05, UpdateBinds("part_cat_enabled:" + sOption));
    }
}

string GetPartOptions() { return JsonGetString(GetProperty("partOptions")); }
void SetPartOptions(string sOptions)
{
    SetProperty("partOptions", JsonString(sOptions));
}

string GetPartSelected() { return JsonGetString(GetProperty("partSelected")); }
void SetPartSelected(string sPart, int bLoad = TRUE)
{
    SetProperty("partSelected", JsonString(sPart));
    HandleModelMatrixToggles();

    if (bLoad == TRUE)
        LoadParts(sPart);
}

void HandleModelMatrixToggles()
{
    string sOptions = GetPartOptions();
    string sSelected = GetPartSelected();

    int nToken = GetFormToken();
    int n, nCount = CountList(sOptions);
    for (n = 0; n < nCount; n++)
    {
        string sOption = GetListItem(sOptions, n);
        NUI_SetBindValue(OBJECT_SELF, nToken, "model_matrix_value:" + sOption, JsonBool(sOption == sSelected));
    } 
}

object GetTargetObject()
{
    string sObject = JsonGetString(GetProperty("targetObject"));
    return StringToObject(sObject);
}

void ToggleItemEquippedFlags()
{
    SetHasItemEquipped(GetIsAppearanceSelected() || GetIsObjectValid(GetItem()));
}

void SetTargetObject(object oTarget)
{
    HighlightTarget(FALSE);
    SetProperty("targetObject", JsonString(ObjectToString(oTarget)));
    HighlightTarget();

    ToggleItemEquippedFlags();
    SetIsAppearanceSelected(TRUE);

    LoadColorCategoryOptions();
    LoadPartCategoryOptions();
}

void HandlePlayerTargeting()
{
    object oPlayer = GetLastPlayerToSelectTarget();
    object oTarget = GetTargetingModeSelectedObject();
    vector vPosition = GetTargetingModeSelectedPosition();

    SetTargetObject(oTarget);
}

void SetPlayerTargeting()
{
    EnterTargetingMode(OBJECT_SELF, OBJECT_TYPE_CREATURE);
}

void LoadColorCategoryOptions()
{
    if (GetDoesNotHaveItemEquipped())
        return;

    SetColorCategoryOptions();
}

void LoadPartCategoryOptions()
{
    if (GetDoesNotHaveItemEquipped())
        return;

    SetPartCategoryOptions();
}

object GetItem(int nSlot = -1)
{
    if (nSlot == -1)
    {
        if (GetPartCategorySelected() == "helm")
            return GetItemInSlot(INVENTORY_SLOT_HEAD, GetTargetObject());
        else
            return GetItemInSlot(INVENTORY_SLOT_CHEST, GetTargetObject());
    }
    else
        return GetItemInSlot(nSlot, GetTargetObject());

    return OBJECT_INVALID;
}

int GetHasRequiredArmorFeat(object oTarget, string sModel)
{
    int nAC = StringToInt(Get2DAString("parts_chest", "acbonus", StringToInt(sModel)));
    if (nAC > 0)
    {
        int nFeat = nAC >= 6 ? FEAT_ARMOR_PROFICIENCY_HEAVY :
                    nAC >= 4 ? FEAT_ARMOR_PROFICIENCY_MEDIUM :
                               FEAT_ARMOR_PROFICIENCY_LIGHT;

        return GetHasFeat(nFeat, oTarget);
    }

    return TRUE;
}

json FilterArmorPartIDs(json jPartIDs)
{
    Notice("FilterArmorPartIDs :: Enter");
    Notice(" - jPartIDs - " + JsonDump(jPartIDs));

    json jResult = JsonArray();
    int n, nCount = JsonGetLength(jPartIDs);
    for (n = 0; n < nCount; n++)
    {
        int nID = JsonGetInt(JsonArrayGet(jPartIDs, n));
        if (GetHasRequiredArmorFeat(GetTargetObject(), IntToString(nID)) == TRUE)
            jResult = JsonArrayInsert(jResult, JsonInt(nID));
    }

    Notice(" - Filtered - " + JsonDump(jResult));
    return jResult;
}

void BuildModelSelectMatrix(json jPartIDs, int bForce = FALSE)
{
    string sIndexes, sVarName = "appedit_modelmatrix:" +
        (GetIsAppearanceSelected() ? "appearance" : "equipment") + ":" +
        GetPartCategorySelected();    

    json j = GetProperty(sVarName);
    if (j == JsonNull() || bForce == TRUE)
    {
        string mtb = "model_tb";
        int nRowMax = 5;

        NUI_CreateTemplateControl(mtb);
        {
            NUI_AddToggleButton();
                NUI_SetHeight(25.0);
                NUI_SetWidth(40.0);
        } NUI_SaveTemplateControl();

        NUI_CreateForm("");
        {
            if (GetIsEquipmentSelected() && GetPartCategorySelected() == "chest")
                jPartIDs = FilterArmorPartIDs(jPartIDs);

            int n, nCount = JsonGetLength(jPartIDs);
            float fSpacer = nCount > (7 * nRowMax) ? 0.0 : 12.0;

            Notice(" > fSpacer - " + FloatToString(fSpacer));

            NUI_AddRow();
            NUI_AddSpacer();
                NUI_SetWidth(fSpacer);

            if (nCount > 0)
            {
                for (n = 0; n < nCount; n++)
                {
                    json jPartID = JsonArrayGet(jPartIDs, n);
                    string sLabel = IntToString(JsonGetInt(jPartID));

                    NUI_AddTemplateControl(mtb);
                        NUI_SetID("model_matrix:" + sLabel);
                        NUI_SetLabel(sLabel);
                        NUI_BindValue("model_matrix_value:" + sLabel);

                    if ((n + 1) % nRowMax == 0)
                    {
                        NUI_AddRow();
                        NUI_AddSpacer();
                            NUI_SetWidth(fSpacer);
                    }

                    sIndexes = AddListItem(sIndexes, sLabel);
                }
            }
        }

        j = JsonObjectGet(NUI_GetBuildVariable(NUI_BUILD_ROOT), "root");

        //Notice(" > sIndexes - " + sIndexes);
        //Notice(" > json - " + JsonDump(j,2));

        SetProperty(sVarName, j);
        SetProperty(sVarName + ":select", JsonString(sIndexes));
    }
    else
        sIndexes = JsonGetString(GetProperty(sVarName + ":select"));

    SetPartOptions(sIndexes);

    int nToken = GetFormToken();
    NuiSetGroupLayout(OBJECT_SELF, nToken, "model_matrix", j);
}

int GetPartIndex(string sPart)
{
    if      (sPart == "head") return CREATURE_PART_HEAD;    
    else if (sPart == "robe") return ITEM_APPR_ARMOR_MODEL_ROBE;
    else
        return StringToInt(Get2DAListByCriteria("capart", TWODA_INDEX, "mdlname", sPart));
}

void LoadParts(string sModel = "", string sPartCategory = "")
{
    object oPC = GetTargetObject();

    int nRace = GetRacialType(oPC);
    int nGender = GetGender(oPC);
    int nPhenotype = GetPhenoType(oPC);
    string sPart = (sPartCategory == "" ? GetPartCategorySelected() : sPartCategory);
    int bAppearance = GetIsAppearanceSelected();
    int bEquipment = !bAppearance;

    int nPart = GetPartIndex(sPart);

    if (sModel == "")
    {
        json jPartIDs;
        if (GetPartCategorySelected() == "helm")
            jPartIDs = GetLayeredModelData("helm");
        else 
            jPartIDs = GetArmorAndAppearanceModelData(nGender, nRace, nPhenotype, sPart);
        
        // TODO when debug complete, remove TRUE
        BuildModelSelectMatrix(jPartIDs, TRUE);
    
        if (bAppearance == TRUE)
            SetPartSelected(IntToString(GetCreatureBodyPart(nPart, oPC)), FALSE);
        else if (bEquipment == TRUE)
        {
            int nModelType;
            if (GetPartCategorySelected() == "helm") nModelType = ITEM_APPR_TYPE_SIMPLE_MODEL;
            else                                     nModelType = ITEM_APPR_TYPE_ARMOR_MODEL;

            object oItem = GetItem();
            SetPartSelected(IntToString(GetItemAppearance(oItem, nModelType, nPart)));
        }
    }
    else
    {
        if (bAppearance == TRUE)
            SetCreatureBodyPart(nPart, StringToInt(sModel), oPC);
        else if (bEquipment == TRUE)
        {
            int bHelmet = GetPartCategorySelected() == "helm";

            object oItem = GetItem();
            int nModelType, nSlot = bHelmet == TRUE ? INVENTORY_SLOT_HEAD : INVENTORY_SLOT_CHEST;
            if (bHelmet == TRUE) nModelType = ITEM_APPR_TYPE_SIMPLE_MODEL;
            else                 nModelType = ITEM_APPR_TYPE_ARMOR_MODEL;

            object oCopy = CopyItemAndModify(oItem, nModelType, nPart, StringToInt(GetPartSelected()));
            DestroyObject(oItem);
            AssignCommand(oPC, ActionEquipItem(oCopy, nSlot));
        }
    }
}

int GetIsWeaponsSelected()
{
    return FALSE;
}

void ToggleFormMode(string sType)
{
    int bChange = (sType == "equipment" && GetIsEquipmentSelected() == FALSE) ||
                  (sType == "appearance" && GetIsAppearanceSelected() == FALSE) ||
                  (sType == "weapons" && GetIsWeaponsSelected() == FALSE);

    if (bChange == FALSE)
    {
        UpdateBinds("toggle_" + sType + "_toggled");
        return;
    }

    SetIsAppearanceSelected(!GetIsAppearanceSelected());
    ToggleItemEquippedFlags();

    LoadColorCategoryOptions();
    LoadPartCategoryOptions();

    string sOptions = GetPartCategoryOptions();
    if (HasListItem(sOptions, GetPartCategorySelected()) == FALSE)
        SetPartCategorySelected(GetListItem(sOptions, GetIsEquipmentSelected()));
    else
        SetPartCategorySelected(GetPartCategorySelected());
    
    //SetSelectedColorCategoryIndex(0);

    UpdateBinds("group_category_visible");
}

void form_open()
{
    int nLoader = NuiFindWindow(OBJECT_SELF, "appearance_editor_loader");
    int nEditor = NuiFindWindow(OBJECT_SELF, "appearance_editor");

    if (nLoader > 0)
    {   
        string sTables = DATABASE_TABLE_SIMPLE + "," + DATABASE_TABLE_COMPOSITE + "," + DATABASE_TABLE_ARMOR;
        string sValues = "simple,composite,armor";

        int n, nCount = CountList(sTables);
        for (n = 0; n < nCount; n++)
        {
            string sTable = GetListItem(sTables, n);
            sQuery = "SELECT COUNT(*) FROM " + sTable + ";";
            sql = PrepareQuery(sQuery);

            SqlStep(sql);
            
            string sPrefix = "data_" + GetListItem(sValues, n);
            json jValue, jColor;

            if (SqlGetInt(sql, 0) > 0)
            {
                jValue = JsonString("Loaded");
                jColor = NUI_DefineRGBColor(0, 255, 0);
            }
            else
            {
                jValue = JsonString("Not Loaded");
                jColor = NUI_DefineRGBColor(255, 0, 0);
            }

            NUI_SetBindValue(OBJECT_SELF, nLoader, sPrefix + "_value", jValue);
            NUI_SetBindValue(OBJECT_SELF, nLoader, sPrefix + "_color", jColor);
        }
    }
}

void setTargetObject_click()
{
    SetPlayerTargeting();
}

void toggle_appearance_mouseup()
{
    ToggleFormMode("appearance");
}

void toggle_equipment_mouseup()
{
    ToggleFormMode("equipment");
}

void toggle_weapons_mouseup()
{
    ToggleFormMode("weapons");
}

void open_loader_click()
{
    string sFormID = "appearance_editor_loader";
    int nToken = GetFormToken();

    NUI_DisplayForm(OBJECT_SELF, sFormID);
    NUI_DestroyForm(OBJECT_SELF, nToken);
}

void HighlightTarget(int bHighlight = TRUE)
{
    object oTarget = GetTargetObject();

    if (bHighlight == FALSE)
    {
        effect e = GetFirstEffect(oTarget);
        while (GetIsEffectValid(e))
        {
            if (GetEffectTag(e) == "_appedit_highlight")
                RemoveEffect(oTarget, e);
            
            e = GetNextEffect(oTarget);
        }

        return;
    }

    effect e = EffectVisualEffect(VFX_DUR_LIGHT_WHITE_20);
    e = EffectLinkEffects(e, EffectVisualEffect(VFX_DUR_AURA_WHITE));
    e = ExtraordinaryEffect(e);
    e = TagEffect(e, "_appedit_highlight");
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, e, oTarget);
}

void OnSelectColorCategory(string sControl)
{
    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    SetColorCategorySelected(sControl);
}

void OnSelectPartCategory(string sControl)
{
    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    if (_GetKey(sControl) == "swap")
    {
        string sPart = GetPartCategorySelected();
        sPart = GetStringLeft(sPart, GetStringLength(sPart) - 1) +
            (GetStringRight(sPart, 1) == "l" ? "r" : "l");
        LoadParts(GetPartSelected(), sPart);
        return;
    }

    if (GetPartCategorySelected() == sControl)
    {
        UpdateBinds("part_cat_value:" + sControl);
        return;
    }

    SetPartCategorySelected(sControl);
}

void ModifyItemColor(int nColorChannel, int nColorID)
{
    object oPC = GetTargetObject();

    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    int nSlot = INVENTORY_SLOT_CHEST;
    int bPartly, nPart, nIndex;
    
    if (GetIsEquipmentSelected() == TRUE)
    {
        bPartly = JsonGetInt(NUI_GetBindValue(OBJECT_SELF, GetFormToken(), "per_part_coloring_value"));
        if (bPartly == TRUE)
        {
            nPart = GetPartIndex(GetPartCategorySelected());
            nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nPart * ITEM_APPR_ARMOR_NUM_COLORS) + nColorID;
        }
        else
            nIndex = nColorChannel;

        Notice(" > bPartly - " + (bPartly ? "TRUE":"FALSE"));
        Notice(" > nPart - " + IntToString(nPart) + " (" + GetPartCategorySelected() + ")");
        Notice(" > nIndex - " + IntToString(nIndex));
    }
    else
        nIndex = nColorChannel;

    object oItem = GetItem();
    object oCopy = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorID, TRUE);

    DestroyObject(oItem);
    AssignCommand(oPC, ActionEquipItem(oCopy, nSlot));
}

void UpdateColorSelected()
{
    int nColor, nChannel = StringToInt(GetColorCategorySelected());
    if (GetIsAppearanceSelected() == TRUE)
        nColor = GetColor(GetTargetObject(), nChannel);
    else if (GetIsEquipmentSelected() == TRUE)
        nColor = GetItemAppearance(GetItem(), ITEM_APPR_TYPE_ARMOR_COLOR, nChannel);

    if (nColor == -1)
        NUI_SetBindValue(OBJECT_SELF, GetFormToken(), "image_colorcategory_enabled", JsonBool(FALSE));
    else
    {
        int nRow = nColor / COLOR_WIDTH_CELLS;
        int nColumn = FloatToInt(frac((nColor * 1.0) / COLOR_WIDTH_CELLS) * COLOR_WIDTH_CELLS);

        float fScale = GetPlayerDeviceProperty(OBJECT_SELF, PLAYER_DEVICE_PROPERTY_GUI_SCALE) / 100.0;
        float fTileWidth = 16.0 * fScale;
        float fTileHeight = 16.0 * fScale;

        float x = nColumn * fTileWidth;
        float y = nRow * fTileHeight;

        json jPoints = NUI_GetRectanglePoints(x, y, fTileWidth, fTileHeight);

        int nToken = GetFormToken();
        NUI_SetBindValue(OBJECT_SELF, nToken, "image_colorsheet_enabled", JsonBool(TRUE));
        NUI_SetBindValue(OBJECT_SELF, nToken, "image_colorsheet_points", jPoints);
        NUI_SetBindValue(OBJECT_SELF, nToken, "image_colorsheet_color", NUI_DefineRGBColor(255, 255, 0));
        NUI_SetBindValue(OBJECT_SELF, nToken, "image_colorsheet_linethickness", JsonFloat(2.0));
    }
}

void OnSelectColor(json jPayload)
{
    object oPC = GetTargetObject();

    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    float fScale = GetPlayerDeviceProperty(OBJECT_SELF, PLAYER_DEVICE_PROPERTY_GUI_SCALE) / 100.0;
    json jMousePosition = JsonObjectGet(jPayload, "mouse_pos");
    json jX = JsonObjectGet(jMousePosition, "x");
    json jY = JsonObjectGet(jMousePosition, "y");

    float x = JsonGetFloat(jX);
    float y = JsonGetFloat(jY);

    float fTileWidth = 16.0 * fScale;
    float fTileHeight = 16.0 * fScale;

    int nCellX = FloatToInt(x * fScale / fTileWidth);
    int nCellY = FloatToInt(y * fScale / fTileHeight);

    nCellX = clamp(nCellX, 0, COLOR_WIDTH_CELLS);
    nCellY = clamp(nCellY, 0, COLOR_HEIGHT_CELLS);

    int nColorID = nCellX + nCellY * COLOR_WIDTH_CELLS;
    int nChannel = StringToInt(GetColorCategorySelected());

    if (GetIsAppearanceSelected())
        SetColor(oPC, nChannel, nColorID);
    else if (GetIsEquipmentSelected())
        ModifyItemColor(nChannel, nColorID);

    DelayCommand(0.04, UpdateColorSelected());
}

void OnSelectPart(string sPart)
{
    SetPartSelected(sPart, TRUE);
}

void OnPreviousPart()
{
    string sParts = GetPartOptions();
    string sPart = GetPartSelected();
    int nIndex = FindListItem(sParts, sPart);

    if (nIndex <= 0)
        nIndex = CountList(sParts) - 1;
    else
        nIndex -= 1;

    sPart = GetListItem(sParts, nIndex);
    OnSelectPart(sPart);
}

void OnNextPart()
{
    string sParts = GetPartOptions();
    string sPart = GetPartSelected();
    int nIndex = FindListItem(sParts, sPart);

    if (nIndex >= CountList(sParts) - 1)
        nIndex = 0;
    else
        nIndex += 1;

    sPart = GetListItem(sParts, nIndex);
    OnSelectPart(sPart);
}

void form_close()
{
    HighlightTarget(FALSE);
    DeleteLocalJson(OBJECT_SELF, PROPERTIES);
}

sqlquery PrepareQuery(string sQuery)
{
    return NUI_PrepareQuery(sQuery, USE_CAMPAIGN_DATABASE, CAMPAIGN_DATABASE);
}

string GetObjectAsString(json j, string sProperty)
{
    return JsonGetString(JsonObjectGet(j, sProperty));
}

void AddModelToDatabase(int nType, json jModel)
{
    if (nType == SIMPLE || nType == LAYERED)
    {
        string sType = GetObjectAsString(jModel, "type");
        string sClass = GetObjectAsString(jModel, "class");
        string sVariant = GetObjectAsString(jModel, "variant");
        string sFile = GetObjectAsString(jModel, "file");

        sQuery = "INSERT INTO " + DATABASE_TABLE_SIMPLE + " (type, class, variant, file) " +
                 "VALUES (@type, @class, @variant, @file);";
                 "ON CONFLICT (file) DO NOTHING;";
        sql = PrepareQuery(sQuery);
        SqlBindString(sql, "@type", sType);
        SqlBindString(sql, "@class", sClass);
        SqlBindString(sql, "@variant", sVariant);
        SqlBindString(sql, "@file", sFile);

        SqlStep(sql);
    }
    else if (nType == COMPOSITE)
    {
        string sClass = GetObjectAsString(jModel, "class");
        string sPosition = GetObjectAsString(jModel, "position");
        string sShape = GetObjectAsString(jModel, "shape");
        string sColor = GetObjectAsString(jModel, "color");
        string sFile = GetObjectAsString(jModel, "file");

        sQuery = "INSERT INTO " + DATABASE_TABLE_COMPOSITE + " (class, position, shape, color, file) " +
                 "VALUES (@class, @position, @shape, @color, @file) " +
                 "ON CONFLICT (class, position, shape, color) DO NOTHING;";
        sql = PrepareQuery(sQuery);
        SqlBindString(sql, "@class", sClass);
        SqlBindString(sql, "@position", sPosition);
        SqlBindString(sql, "@shape", sShape);
        SqlBindString(sql, "@color", sColor);
        SqlBindString(sql, "@file", sFile);

        SqlStep(sql);
    }
    else if (nType == ARMORANDAPPEARANCE)
    {
        string sGender = GetObjectAsString(jModel, "gender");
        string sRace = GetObjectAsString(jModel, "race");
        string sPhenotype = GetObjectAsString(jModel, "phenotype");
        string sPart = GetObjectAsString(jModel, "part");
        string sModel = GetObjectAsString(jModel, "model");
        string sFile = GetObjectAsString(jModel, "file");

        sQuery = "INSERT INTO " + DATABASE_TABLE_ARMOR + " (gender, race, phenotype, part, model, file) " +
                 "VALUES (@gender, @race, @phenotype, @part, @model, @file) " +
                 "ON CONFLICT (gender, race, phenotype, part, model) DO NOTHING;";
        sql = PrepareQuery(sQuery);
        SqlBindString(sql, "@gender", sGender);
        SqlBindString(sql, "@race", sRace);
        SqlBindString(sql, "@phenotype", sPhenotype);
        SqlBindString(sql, "@part", sPart);
        SqlBindInt(sql, "@model", StringToInt(sModel));
        SqlBindString(sql, "@file", sFile);

        SqlStep(sql);
    }
}

void InitializeDatabase(int nType = -1)
{
    if (nType == -1 || nType == SIMPLE || nType == LAYERED)
    {
        sQuery = "CREATE TABLE IF NOT EXISTS " + DATABASE_TABLE_SIMPLE + " (" +
            "type INTEGER, " +
            "class TEXT, " +
            "variant INTEGER, " +
            "file TEXT, " + 
            "PRIMARY KEY (file));";
        sql = PrepareQuery(sQuery);
        SqlStep(sql);
    }

    if (nType == -1 || nType == COMPOSITE)
    {
        sQuery = "CREATE TABLE IF NOT EXISTS " + DATABASE_TABLE_COMPOSITE + " (" +
            "class TEXT, " +
            "position TEXT, " + 
            "shape INTEGER, " +
            "color INTEGER, " +
            "file TEXT, " +
            "PRIMARY KEY (class, position, shape, color));";
        sql = PrepareQuery(sQuery);
        SqlStep(sql);
    }

    if (nType == -1 || nType == ARMORANDAPPEARANCE)
    {
        sQuery = "CREATE TABLE IF NOT EXISTS " + DATABASE_TABLE_ARMOR + " (" +
            "gender TEXT, " +
            "race TEXT, " +
            "phenotype TEXT, " +
            "part TEXT, " +
            "model INTEGER, " +
            "file TEXT, " +
            "PRIMARY KEY (gender, race, phenotype, part, model));";
        sql = NUI_PrepareQuery(sQuery, USE_CAMPAIGN_DATABASE, CAMPAIGN_DATABASE);
        SqlStep(sql);
    }
}

void ClearDatabaseTables(int nType = -1)
{
    string sTable, sTables = DATABASE_TABLE_SIMPLE + "," + DATABASE_TABLE_COMPOSITE + "," + DATABASE_TABLE_ARMOR;

    if (nType != -1)
    {
        if (nType == SIMPLE || nType == LAYERED)
            sTables = DATABASE_TABLE_SIMPLE;
        else if (nType == COMPOSITE)
            sTables = DATABASE_TABLE_COMPOSITE;
        else if (nType == ARMORANDAPPEARANCE)
            sTables = DATABASE_TABLE_ARMOR;
    }

    int n, nTables = CountList(sTables);
    for (n = 0; n < nTables; n++)
    {
        string sTable = GetListItem(sTables, n);
        sQuery = "DELETE FROM " + sTable + ";";
        sql = PrepareQuery(sQuery);

        SqlStep(sql);
    }
}

json GetModelData(string sType, string sClass)
{
    string sSubQuery = "SELECT * " +
            "FROM " + DATABASE_TABLE_SIMPLE + " " +
            "WHERE type = @type " +
                "AND class = @class " +
            "ORDER BY variant ASC";

    sQuery = "SELECT json_group_array (json(variant)) " +
             "FROM (" + sSubQuery + ");";

    sql = PrepareQuery(sQuery);
    SqlBindString(sql, "@type", sType);
    SqlBindString(sql, "@class", sClass);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

json GetSimpleModelData(string sClass = "")
{
    return GetModelData("0", sClass);
}

json GetLayeredModelData(string sClass = "")
{
    return GetModelData("1", sClass);
}

sqlquery GetCompositeModelData(string sClass, string sShapes)
{
    sQuery = "SELECT class, position, shape, color, file " +
             "FROM " + DATABASE_TABLE_COMPOSITE + " " +
             "WHERE class = @class " +
                "AND shape IN (" + sShapes + ") " +
             "ORDER BY shape, color ASC;";
    sql = PrepareQuery(sQuery);
    SqlBindString(sql, "@class", sClass);

    return sql;
}

json GetArmorAndAppearanceModelData(int nGender, int nRace, int nPhenotype, string sPart)
{

    string sGender = GetStringLowerCase(Get2DAString("gender", "gender", nGender));
    string sRace = GetStringLowerCase(Get2DAString("appearance", "race", nRace));
    string sPhenotype = IntToString(nPhenotype);

    string sSubQuery = "SELECT * " +
             "FROM " + DATABASE_TABLE_ARMOR + " " +
             "WHERE gender = @gender " +
                "AND race = @race " +
                "AND phenotype = @phenotype " +
                "AND part = @part " +
             "ORDER BY model ASC";
 
    sQuery = "SELECT json_group_array (json(model)) " +
             "FROM (" + sSubQuery + ");";  

    sql = PrepareQuery(sQuery);
    SqlBindString(sql, "@gender", sGender);
    SqlBindString(sql, "@race", sRace);
    SqlBindString(sql, "@phenotype", sPhenotype);
    SqlBindString(sql, "@part", sPart);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

// Return a command-delimited list of results from a given 2da file.  See the comments below to determine how to
// use this function.
string Get2DAListByCriteria(string s2DA, string sReturnColumn,
                            string sCriteriaColumn = "", string sCriteria = "")
{
    string sReturn;
    int bUseCriteria = sCriteriaColumn != "";
    int bReturnByIndex = sCriteriaColumn == TWODA_INDEX && sCriteria != "";
    int bReturnIndices = (sCriteriaColumn == TWODA_INDEX && sCriteria == "") ||
                         (sReturnColumn == TWODA_INDEX && sCriteriaColumn != "" && sCriteria != "");
    int bReturnAllResults = sCriteriaColumn == "" && sCriteria == "";

    // Ok, this requires a comment because it's rather cryptic
    // To get a list of everything from sReturnColumn in s2DA, leave sCriteraColumn and sCritera as empty strings
    // To get a list of indices (the first column) in which sReturnColumn is not "" (****/blank), set sCriteriaColumn
    //      to the constant TWODA_INDEX and leave sCriteria blank
    // To get a list of indices (the first column) in which sCriteriaColumn = sCritera, set sReturnColumn to TWODA_INDEX
    // To get a list of what's in sReturnColumn by row/index number, set sCriteriaColumn to the constant TWODA_INDEX
    //      and pass a command delimited string list of row/index numbers into sCriteria
    // To get a list of whats in sReturnColumn based on the value of a different column, set sCriteriaColumn to the
    //      column name and sCriteria to the value you want to find in the sCriteriaColumn column.  For example, if you
    //      want to return the value from column "itemclass" in "baseitems.2da", but only if the column "modeltype" in
    //      the same 2da file is "1", use the following:  Get2DAListByCriteria("baseitems", "itemclass", "modeltype", "1");

    // Since there's no non-NWNX/third-party method to determine how many rows are in any given 2da file, set
    //  nTolerance to the number of blank lines (in a row) you're willing to search before you call it a day.
    //  For example, if this is set to 15, if Get2DAListByCriteria returns 15 blank lines in a row, the function will
    //  stop attempting to read additional rows and return whatever has already been found.
    int n, nCount, nTolerance = 15;
    
    if (bReturnAllResults == TRUE)
    {
        do {
            string sResult = Get2DAString(s2DA, sReturnColumn, n++);
            if (sResult != "")
            {
                sReturn = AddListItem(sReturn, GetStringLowerCase(sResult));
                nCount = 0;
            }
            else
                nCount++;
        } while (nCount <= nTolerance);

        return sReturn;
    }

    if (bReturnIndices == TRUE)
    {
        n = 0; nCount = 0;
        string sResult;

        do {
            if (sReturnColumn == TWODA_INDEX)
            {
                sResult = GetStringLowerCase(Get2DAString(s2DA, sCriteriaColumn, n++));
                if (HasListItem(sCriteria, sResult) == TRUE)
                    sReturn = AddListItem(sReturn, IntToString(n - 1), TRUE);

                if (sResult == "") nCount ++;
                else               nCount = 0;
            }
            else
            {
                sResult = Get2DAString(s2DA, sReturnColumn, n++);
                if (sResult != "")
                {
                    sReturn = AddListItem(sReturn, IntToString(n - 1), TRUE);
                    nCount = 0;
                }
                else
                    nCount++;
            }                
        } while (nCount <= nTolerance);

        return sReturn;
    }

    if (bReturnByIndex == TRUE)
    {
        nCount = CountList(sCriteria);
        for (n = 0; n < nCount; n++)
        {
            int nIndex = StringToInt(GetListItem(sCriteria, n));
            sReturn = AddListItem(sReturn, GetStringLowerCase(Get2DAString(s2DA, sReturnColumn, nIndex)), TRUE);
        }

        return sReturn;
    }

    if (bUseCriteria == TRUE)
    {
        n = 0;
        nCount = 0;

        do {
            string sTargetColumn = bUseCriteria == TRUE ? sCriteriaColumn : sReturnColumn;
            string sResult = Get2DAString(s2DA, sTargetColumn, n);

            if (sResult == "") nCount++;
            else
            {
                if (bUseCriteria == TRUE)
                {
                    if (HasListItem(sCriteria, sResult) == TRUE)
                    {
                        if (sReturnColumn == TWODA_INDEX)
                            sReturn = AddListItem(sReturn, IntToString(n));
                        else
                            sReturn = AddListItem(sReturn, GetStringLowerCase(Get2DAString(s2DA, sReturnColumn, n)));
                    }
                }
                else
                    sReturn = AddListItem(sReturn, GetStringLowerCase(sResult));

                nCount = 0;
            }

            n++;
        } while (nCount <= nTolerance);
    }

    return sReturn;
}

void PopulateSimpleModelData(int nType = BASE_CONTENT)
{
    string sTypes = "0,1";
    int t, tCount = CountList(sTypes);
    for (t = 0; t < tCount; t++)
    {
        string sType = GetListItem(sTypes, t);
        string sClasses = Get2DAListByCriteria("baseitems", "itemclass", "modeltype", sType);
        
        int n, nClasses = CountList(sClasses);
        for (n = 0; n < nClasses; n++)
        {
            string sClass = GetListItem(sClasses, n);
            string sPrefix = sClass + "_";
            int nPrefix = GetStringLength(sPrefix);

            json jResrefs = NUI_GetResrefArray(sPrefix, RESTYPE_MDL, nType);
            if (jResrefs == JsonNull())
            {
                Notice("No " + (nType == BASE_CONTENT ? "custom " : "base game ") +
                    (sType == "0" ? "simple" : "layered") + " model content found for model file prefix '" + sPrefix + "'");
                continue;
            }

            int r, rCount = JsonGetLength(jResrefs);
            for (r = 0; r < rCount; r++)
            {
                string sFile = JsonGetString(JsonArrayGet(jResrefs, r));
                string sNumber = GetStringRight(sFile, GetStringLength(sFile) - nPrefix);
                int nNumber = StringToInt(sNumber);

                json jModel = JsonObject();
                     jModel = JsonObjectSet(jModel, "type", JsonString(sType));
                     jModel = JsonObjectSet(jModel, "class", JsonString(GetStringLowerCase(sClass)));
                     jModel = JsonObjectSet(jModel, "variant", JsonString(IntToString(nNumber)));
                     jModel = JsonObjectSet(jModel, "file", JsonString(sFile));

                DelayCommand(0.1, AddModelToDatabase(SIMPLE, jModel));
            }
        }
    }
}

void PopulateCompositeModelData(int nType = BASE_CONTENT)
{
    string sTypes = "2";
    int t, tCount = CountList(sTypes);
    for (t = 0; t < tCount; t++)
    {
        string sType = GetListItem(sTypes, t);
        string sClasses = Get2DAListByCriteria("baseitems", "itemclass", "modeltype", sType);
        int c, nClasses = CountList(sClasses);

        string sPositions = "b,m,t";
        int p, nPosition = CountList(sPositions);
        
        for (c = 0; c < nClasses; c++)
        {
            string sClass = GetListItem(sClasses, c);
            for (p = 0; p < nPosition; p++)
            {
                string sPosition = GetListItem(sPositions, p);
                string sPrefix = sClass + "_" + sPosition + "_";
                int nPrefix = GetStringLength(sPrefix);
            
                json jResrefs = NUI_GetResrefArray(sPrefix, RESTYPE_MDL, nType);
                if (jResrefs == JsonNull())
                {
                    Notice("No " + (nType == BASE_CONTENT ? "custom " : "base game ") +
                        "composite model content found for model file prefix '" + sPrefix + "'");
                    continue;
                }

                int r, nResrefs = JsonGetLength(jResrefs);
                for (r = 0; r < nResrefs; r++)
                {
                    string sFile = JsonGetString(JsonArrayGet(jResrefs, r));
                    string sNumber = GetStringRight(sFile, GetStringLength(sFile) - nPrefix);
                    int nNumber = StringToInt(sNumber);
                    int nShape = nNumber / 10;
                    int nColor = nNumber - (nShape * 10);

                    json jModel = JsonObject();
                         jModel = JsonObjectSet(jModel, "class", JsonString(GetStringLowerCase(sClass)));
                         jModel = JsonObjectSet(jModel, "position", JsonString(sPosition));
                         jModel = JsonObjectSet(jModel, "shape", JsonString(IntToString(nShape)));
                         jModel = JsonObjectSet(jModel, "color", JsonString(IntToString(nColor)));
                         jModel = JsonObjectSet(jModel, "file", JsonString(sFile));

                    DelayCommand(0.1, AddModelToDatabase(COMPOSITE, jModel));
                }
            }
        }
    }
}

void PopulateArmorAndAppearanceModelData(int nType = BASE_CONTENT)
{
    string sGenders = CountList(MODEL_GENDER) > 0 ? MODEL_GENDER : Get2DAListByCriteria("gender", "gender");
    string sRaceIndices = Get2DAListByCriteria("racialtypes", TWODA_INDEX, "playerrace", "1");
    string sRaces = CountList(MODEL_RACE) > 0 ? MODEL_RACE : Get2DAListByCriteria("appearance", "race", TWODA_INDEX, sRaceIndices);
    string sPhenotypes = CountList(MODEL_PHENOTYPE) > 0 ? MODEL_PHENOTYPE : Get2DAListByCriteria("phenotype", "label", TWODA_INDEX);
    string sParts = Get2DAListByCriteria("capart", "mdlname");
           sParts = AddListItem(sParts, "head");

    int g, nGenders = CountList(sGenders);
    int r, nRaces = CountList(sRaces);
    int p, nPhenotypes = CountList(sPhenotypes);
    int t, nParts = CountList(sParts);

    json jResult = JsonArray();

    for (g = 0; g < nGenders; g++)
    {
        string sGender = GetListItem(sGenders, g);

        for (r = 0; r < nRaces; r++)
        {
            string sRace = GetListItem(sRaces, r);

            for (p = 0; p < nPhenotypes; p++)
            {
                string sPhenotype = GetListItem(sPhenotypes, p);

                for (t = 0; t < nParts; t++)
                {
                    string sPart = GetListItem(sParts, t);
                    string sPrefix = "p" + sGender + sRace + sPhenotype + "_" + sPart;
                    int nPrefix = GetStringLength(sPrefix);
                          
                    json jResrefs = NUI_GetResrefArray(sPrefix, RESTYPE_MDL, TRUE);
                    if (jResrefs == JsonNull())
                    {
                        Notice("No " + (nType == BASE_CONTENT ? "custom " : "base game ") +
                            "armor/appearance model content found for model file prefix '" + sPrefix + "'");
                        continue;
                    }

                    int n, nCount = JsonGetLength(jResrefs);
                    for (n = 0; n < nCount; n++)
                    {
                        string sFile = JsonGetString(JsonArrayGet(jResrefs, n));
                        string sModel = GetStringRight(sFile, GetStringLength(sFile) - nPrefix);
                        int nModel = StringToInt(sModel);

                        json jModel = JsonObject();
                             jModel = JsonObjectSet(jModel, "gender", JsonString(sGender));
                             jModel = JsonObjectSet(jModel, "race", JsonString(GetStringLowerCase(sRace)));
                             jModel = JsonObjectSet(jModel, "phenotype", JsonString(sPhenotype));
                             jModel = JsonObjectSet(jModel, "part", JsonString(sPart));
                             jModel = JsonObjectSet(jModel, "model", JsonString(IntToString(nModel)));
                             jModel = JsonObjectSet(jModel, "file", JsonString(sFile));

                        DelayCommand(0.1, AddModelToDatabase(ARMORANDAPPEARANCE, jModel));
                    }
                }
            }
        }
    }
}

void CreateColorCategoryTabs()
{
    string sFormPrefix = "_appedit_tab_color_";
    string sCategories = "appearance,equipment";

    string tb = "toggle_button";
    NUI_CreateTemplateControl(tb);
    {
        NUI_AddToggleButton();
            NUI_SetWidth(157.0);
            NUI_SetHeight(25.0);
    } NUI_SaveTemplateControl();

    // Appearance stuff
    string sFormID = sFormPrefix + "appearance";
    string sAppearanceOptions = SKIN + ":" + HAIR + "," + TATTOO + " 1:" + TATTOO + " 2";
    string sEquipmentOptions = LEATHER + " 1:" + LEATHER + " 2," +
                               CLOTH   + " 1:" + CLOTH   + " 2," +
                               METAL   + " 1:" + METAL   + " 2";

    int n, nCount = CountList(sCategories);
    for (n = 0; n < nCount; n++)
    {
        string sCategory = GetListItem(sCategories, n);
        string sOptions = (sCategory == "appearance" ? sAppearanceOptions :
                           sCategory == "equipment" ? sEquipmentOptions :
                           "");
        
        if (sOptions == "")
            return;

        NUI_CreateForm("_appedit_tab_color_" + sCategory);

        int c, x, cCount = CountList(sOptions);
        for (c = 0; c < cCount; c++)
        {
            string sPointer, sOption = GetListItem(sOptions, c);
            string sLeftOption = _GetKey(sOption);
            string sRightOption = _GetValue(sOption);

            NUI_AddRow();
            if (sRightOption == "")
                NUI_AddSpacer();
            
            NUI_AddTemplateControl(tb);
                sPointer = IntToString(x++);
                NUI_SetID("color_cat:" + sPointer);
                NUI_SetLabel(sLeftOption);
                NUI_BindValue("color_cat_value:" + sPointer);
                //NUI_BindEnabled("color_cat_enabled:" + sPointer);

            if (sRightOption == "")
                NUI_AddSpacer();
            else
            {
                NUI_AddTemplateControl(tb);
                    sPointer = IntToString(x++);
                    NUI_SetID("color_cat:" + sPointer);
                    NUI_SetLabel(sRightOption);
                    NUI_BindValue("color_cat_value:" + sPointer);
                    //NUI_BindEnabled("color_cat_enabled:" + sPointer);
            }
        } 
        
        if (sCategory == "equipment")
        {
            NUI_AddRow();
            NUI_AddSpacer();
            NUI_AddCheckbox("per_part_coloring");
                NUI_SetLabel("Per Part Coloring");
                NUI_BindValue("per_part_coloring_value");
            NUI_AddSpacer();
        }
    
        NUI_SaveForm();
    }
}

void CreatePartCategoryTabs()
{
    string sCategories = "appearance,equipment";
    int c, cCount = CountList(sCategories);
    for (c = 0; c < cCount; c++)
    {
        string sCategory = GetListItem(sCategories, c);
        string sFormID = "_appedit_tab_part_" + sCategory;
        int bAppearance = sCategory == "appearance";
        int bEquipment = sCategory == "equipment";

        string sParts, sPointers, sTemp;
        if (bAppearance == TRUE)        
        {
            sParts = AddListItem(sParts, HEAD);
            sPointers = AddListItem(sPointers, "head");
        }
        
        if (bEquipment == TRUE) 
        {
            sParts = AddListItem(sParts, HELMET);
            sPointers = AddListItem(sPointers, "helm");
            
            sParts = AddListItem(sParts, NECK);
            sPointers = AddListItem(sPointers, "neck");

            sParts = AddListItem(sParts, ROBE);
            sPointers = AddListItem(sPointers, "robe");
        }

        sParts = AddListItem(sParts, CHEST);
        sPointers = AddListItem(sPointers, "chest");

        if (bEquipment == TRUE)
        {
            sParts = AddListItem(sParts, LEFT_SHOULDER + ":" + RIGHT_SHOULDER); 
            sPointers = AddListItem(sPointers, "shol:shor");       
        }

        sParts = AddListItem(sParts, LEFT_BICEP + ":" + RIGHT_BICEP);
        sPointers = AddListItem(sPointers, "bicepl:bicepr");

        sParts = AddListItem(sParts, LEFT_FOREARM + ":" + RIGHT_FOREARM);
        sPointers = AddListItem(sPointers, "forel:forer");

        sParts = AddListItem(sParts, LEFT_HAND + ":" + RIGHT_HAND);
        sPointers = AddListItem(sPointers, "handl:handr");

        if (bEquipment == TRUE)
        {
            sParts = AddListItem(sParts, BELT);
            sPointers = AddListItem(sPointers, "belt");
        }

        sParts = AddListItem(sParts, PELVIS);
        sPointers = AddListItem(sPointers, "pelvis");
        
        sParts = AddListItem(sParts, LEFT_THIGH + ":" + RIGHT_THIGH);
        sPointers = AddListItem(sPointers, "legl:legr");
        
        sParts = AddListItem(sParts, LEFT_SHIN + ":" + RIGHT_SHIN);
        sPointers = AddListItem(sPointers, "shinl:shinr");

        if (bEquipment == TRUE)
        {
            sParts = AddListItem(sParts, LEFT_FOOT + ":" + RIGHT_FOOT);
            sPointers = AddListItem(sPointers, "footl:footr");
        }

        string tb = "category_toggle";
        NUI_CreateTemplateControl(tb);
        {
            NUI_AddToggleButton();
                NUI_SetWidth(150.0);
                NUI_SetHeight(25.0);
        } NUI_SaveTemplateControl();

        NUI_CreateForm(sFormID);
        {
            int n, nCount = CountList(sParts);
            for (n = 0; n < nCount; n++)
            {
                string sPart = GetListItem(sParts, n);
                string sPointer = GetListItem(sPointers, n);
                
                string sLeftPart = _GetKey(sPart);
                string sRightPart = _GetValue(sPart);

                string sLeftPointer = _GetKey(sPointer);
                string sRightPointer = _GetValue(sPointer);

                NUI_AddRow();
                if (sRightPart == "")
                    NUI_AddSpacer();

                NUI_AddTemplateControl(tb);
                    NUI_SetID("part_cat:" + sLeftPointer);
                    NUI_SetLabel(sLeftPart);
                    NUI_BindValue("part_cat_value:" + sLeftPointer);
                    NUI_BindEnabled("part_cat_enabled:" + sLeftPointer);

                if (sRightPart == "")
                    NUI_AddSpacer();
                else
                {
                        NUI_SetWidth(125.0);
                    NUI_AddCommandButton();
                        NUI_SetHeight(25.0);
                        NUI_SetWidth(30.0);
                        NUI_SetID("part_cat:swap:" + GetStringLeft(sLeftPointer, GetStringLength(sLeftPointer) - 1));
                        NUI_SetLabel("<->");
                        NUI_SetTooltip("Copy Model");
                    NUI_AddTemplateControl(tb);
                        NUI_SetWidth(135.0);
                        NUI_SetID("part_cat:" + sRightPointer);
                        NUI_SetLabel(sRightPart);
                        NUI_BindValue("part_cat_value:" + sRightPointer);
                        NUI_BindEnabled("part_cat_enabled:" + sRightPointer);
                }
            }
        } NUI_SaveForm();
    }
}

void CreateColumnTabs()
{
    string sColumns = "left,right";
    int n, nCount = CountList(sColumns);
    for (n = 0; n < nCount; n++)
    {
        string sColumn = GetListItem(sColumns, n);
        string sFormID = "_appedit_tab_" + sColumn;
        NUI_CreateForm(sFormID);
        {
            NUI_AddControlGroup();
                NUI_SetID("appedit_" + sColumn + "_top");
            {
                NUI_AddSpacer();
            } NUI_CloseControlGroup();

            NUI_AddControlGroup();
                NUI_SetID("appedit_" + sColumn + "_bottom");
            {
                NUI_AddSpacer();
            } NUI_CloseControlGroup();
        } NUI_SaveForm();
    }
}

void NUI_HandleFormDefinition()
{
    float fHeight = 32.0;
    string sFormID = FORM_ID;

    NUI_CreateForm(sFormID);
        NUI_SetResizable(TRUE);
        NUI_BindGeometry("geometry");
        NUI_SetTitle(TITLE);
        NUI_SetCollapsible(FALSE);
        NUI_SetCustomProperty("toc", JsonBool(TRUE));
    {
        NUI_AddRow();
            NUI_AddCommandButton("open_loader");
                NUI_SetLabel("Data");
                NUI_SetWidth(64.0);
                NUI_SetHeight(64.0);
                //NUI_SetHeight(fHeight);
                NUI_SetTooltip("Open Model Data Loading Form");

            NUI_AddSpacer();

            NUI_AddToggleButton("toggle_appearance");
                NUI_SetLabel(APPEARANCE);
                NUI_SetHeight(fHeight);
                NUI_BindValue("toggle_appearance_toggled");
        
            NUI_AddToggleButton("toggle_equipment");
                NUI_SetLabel(EQUIPMENT);
                NUI_SetHeight(fHeight);
                NUI_BindValue("toggle_equipment_toggled");

            NUI_AddToggleButton("toggle_weapons");
                NUI_SetLabel("Weapons");
                NUI_SetHeight(fHeight);
                NUI_BindValue("toggle_weapons_toggled");
                NUI_SetEnabled(FALSE);

            NUI_AddSpacer();

            NUI_AddImageButton("setTargetObject");
                NUI_SetWidth(64.0);
                NUI_SetHeight(64.0);
                NUI_SetLabel("gui_mp_examineu");
                NUI_SetTooltip("Select Target Object");

        NUI_AddRow();
            NUI_AddLabel("label_item");
                NUI_BindValue("label_item_label");
                NUI_BindVisible("label_item_visible");
                NUI_SetHeight(20.0);

        NUI_AddRow();
            NUI_AddControlGroup();
                NUI_SetID("left_column");
                NUI_SetBorderVisible(FALSE);
                NUI_BindVisible("group_category_visible");
                NUI_SetWidth(350.0);
            {
                NUI_AddRow();
                    NUI_AddControlGroup();
                        NUI_SetID("color_category_tab");
                        NUI_SetHeight(176.0);
                    {
                        NUI_AddSpacer();
                    } NUI_CloseControlGroup();

                NUI_AddRow();
                    NUI_AddControlGroup();
                        NUI_SetID("part_category_tab");
                    {
                        NUI_AddSpacer();
                    } NUI_CloseControlGroup();
            } NUI_CloseControlGroup();


            NUI_AddControlGroup();
                NUI_SetID("right_column");
                NUI_SetBorderVisible(FALSE);
                NUI_BindVisible("group_category_visible");
            {
                NUI_AddRow();
                    NUI_AddImage("image_colorsheet");
                        NUI_BindResref("image_colorsheet_resref");
                        NUI_SetHeight(176.0);
                        NUI_SetWidth(256.0);
                        NUI_SetImageVerticalAlignment(NUI_VALIGN_TOP);
                        NUI_SetImageHorizontalAlignment(NUI_HALIGN_LEFT);
                        NUI_SetImageAspect(NUI_ASPECT_EXACTSCALED);
                        NUI_AddCanvas();
                        {
                            NUI_DrawLine(JsonNull());
                                NUI_BindPoints("image_colorsheet_points");
                                NUI_SetEnabled(TRUE);
                                NUI_BindDrawColor("image_colorsheet_color");
                                NUI_SetLineThickness(2.0);
                        } NUI_CloseCanvas();

                NUI_AddRow();
                    NUI_AddControlGroup();
                        NUI_SetID("model_matrix");
                    {
                        NUI_AddSpacer();
                    } NUI_CloseControlGroup();

                NUI_AddRow();
                    NUI_AddCommandButton("button_previous");
                        NUI_SetHeight(fHeight);
                        NUI_SetWidth(128.0);
                        NUI_SetLabel(PREVIOUS_LABEL != "" ? PREVIOUS_LABEL :
                                     ADJECTIVE_FOLLOWS == TRUE ? MODEL + " " + PREVIOUS : 
                                     PREVIOUS + " " + MODEL);
                    
                    NUI_AddCommandButton("button_next");
                        NUI_SetHeight(fHeight);
                        NUI_SetWidth(128.0);
                        NUI_SetLabel(NEXT_LABEL != "" ? NEXT_LABEL : 
                                     ADJECTIVE_FOLLOWS == TRUE ? MODEL + " " + NEXT :
                                     NEXT + " " + MODEL);
            } NUI_CloseControlGroup();
    } NUI_SaveForm();

    Notice("Defining form " + sFormID + " (Version " + VERSION + ")");
    InitializeDatabase(); 

    CreateColumnTabs(); 
    CreateColorCategoryTabs();
    CreatePartCategoryTabs();

    sFormID = "appearance_editor_loader";
    NUI_CreateTemplateControl("handler_button");
    {
        NUI_AddCommandButton();
            NUI_SetWidth(300.0);
            NUI_SetHeight(35.0);
    } NUI_SaveTemplateControl();

    NUI_CreateForm(sFormID);
        NUI_BindGeometry("geometry_handler");
        NUI_SetTitle("Appearance Editor Data Loading");
        NUI_SetResizable(TRUE);
    {
        NUI_AddRow();

        fHeight = 25.0;
        NUI_AddControlGroup();
            NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
            NUI_SetWidth(320.0);
            NUI_SetHeight(fHeight * 7.0);
        {
            NUI_AddRow();
            NUI_AddLabel();
                NUI_SetHeight(fHeight);
                NUI_SetValue(JsonString("Model Data Status"));

            NUI_AddRow();
            NUI_AddCommandButton();
                NUI_SetHeight(10.0);
                NUI_SetEnabled(FALSE);
                NUI_SetWidth(300.0);

            NUI_AddRow();
            NUI_AddLabel();
                NUI_SetHeight(fHeight);
                NUI_SetValue(JsonString("Simple/Layered Models"));
                NUI_SetWidth(200.0);

            NUI_AddLabel();
                NUI_SetHeight(fHeight);
                NUI_BindValue("data_simple_value");
                NUI_BindForegroundColor("data_simple_color");
                NUI_SetWidth(90.0);
        
            NUI_AddRow();
            NUI_AddLabel();
                NUI_SetHeight(fHeight);
                NUI_SetValue(JsonString("Composite Models"));
                NUI_SetWidth(200.0);

            NUI_AddLabel();
                NUI_SetHeight(fHeight);
                NUI_BindValue("data_composite_value");
                NUI_BindForegroundColor("data_composite_color");
                NUI_SetWidth(90.0);

            NUI_AddRow();
            NUI_AddLabel();
                NUI_SetHeight(fHeight);
                NUI_SetValue(JsonString("Armor/Appearance Models"));
                NUI_SetWidth(200.0);

            NUI_AddLabel();
                NUI_SetHeight(fHeight);
                NUI_BindValue("data_armor_value");
                NUI_BindForegroundColor("data_armor_color");    
                NUI_SetWidth(90.0);   
        } NUI_CloseControlGroup();

        NUI_AddRow();
            NUI_AddSpacer();
                NUI_SetHeight(10.0);

        NUI_AddRow();

        NUI_AddControlGroup();
            NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
            NUI_SetWidth(320.0);
        {
            NUI_AddRow();
            NUI_AddSpacer();
            NUI_AddCombobox("combo_type");
                NUI_SetWidth(200.0);
                NUI_AddComboboxEntryList("All Model Types,Simple/Layered,Composite,Armor/Appearance");
                NUI_BindValue("handler_type_value");
            NUI_AddSpacer();

            NUI_AddRow();
            NUI_AddTemplateControl("handler_button");
                NUI_SetID("handler_load:all");
                NUI_SetLabel("Load Custom and NWN Models");

            NUI_AddRow();
            NUI_AddTemplateControl("handler_button");
                NUI_SetID("handler_load:custom");
                NUI_SetLabel("Load Custom Models");
            
            NUI_AddRow();
            NUI_AddTemplateControl("handler_button");
                NUI_SetID("handler_load:base");
                NUI_SetLabel("Load NWN Models");

            NUI_AddRow();
            NUI_AddTemplateControl("handler_button");
                NUI_SetID("clear_data");
                NUI_SetLabel("Clear Database Tables");
        } NUI_CloseControlGroup();

        NUI_AddRow();
            NUI_AddSpacer();
                NUI_SetHeight(10.0);

        NUI_AddRow();
            NUI_AddCommandButton("open_form:editor");
            NUI_SetWidth(320.0);
            NUI_SetHeight(70.0);
            NUI_SetLabel("Open Appearance Editor");
    } NUI_SaveForm();
}

void UpdateBinds(string sBind, int nToken = -1, int bSetDefaults = FALSE)
{
    if (nToken == -1)
        nToken = GetFormToken();

    json jReturn = JsonNull();

    if (sBind == "geometry")
        jReturn = NUI_DefineRectangle(0.0, 0.0, 650.0, 610.0);
    else if (sBind == "geometry_handler")
        jReturn = NUI_DefineRectangle(0.0, 0.0, 350.0, 580.0);
    else if (sBind == "handler_type_value")
        jReturn = JsonInt(0);
    else if (sBind == "toggle_appearance_toggled")
        jReturn = JsonInt(GetIsAppearanceSelected());
    else if (sBind == "toggle_equipment_toggled")
        jReturn = JsonInt(GetIsEquipmentSelected());
    else if (sBind == "list_colorcategory_rowcount")
        jReturn = JsonInt(CountList(GetColorCategoryOptions()));
    else if (sBind == "image_colorsheet_resref")
        jReturn = JsonString(GetColorSheetResref());
    else if (sBind == "group_category_visible")
        jReturn = JsonBool(GetHasItemEquipped());
    else if (sBind == "label_item_visible")
        //jReturn = JsonBool(GetDoesNotHaveItemEquipped());
        jReturn = JsonBool(FALSE);
    else if (sBind == "label_item_label")
        jReturn = JsonString(CANNOT_EQUIP);
    else
    {
        string sKey = _GetKey(sBind);
        if (sKey == "part_cat_enabled")
        {
            if (_GetValue(sBind) == "helm")
            {
                jReturn = JsonBool(GetIsObjectValid(GetItem(INVENTORY_SLOT_HEAD)));
                if (GetPartCategorySelected() == "helm" && jReturn == jFALSE)
                    SetPartCategorySelected("neck");
            }
            else if (GetIsEquipmentSelected() == TRUE)
                jReturn = JsonBool(GetIsObjectValid(GetItem(INVENTORY_SLOT_CHEST)));
            else
                jReturn = JsonBool(TRUE);
        }
        else if (sKey == "part_cat_value" || sKey == "model_matrix_value")
            jReturn = JsonBool(GetPartCategorySelected() == _GetValue(sBind));
        else if (sKey == "color_cat_value")
            jReturn = JsonBool(GetColorCategorySelected() == _GetValue(sBind));
    }

    NUI_SetBindValue(OBJECT_SELF, nToken, sBind, jReturn);
}

void NUI_HandleFormBinds()
{
    object oPC = OBJECT_SELF;
    struct NUIBindData bd = NUI_GetBindData();

    // Set default values here...
    SetTargetObject(OBJECT_SELF);

    int n;
    for (n = 0; n < bd.nCount; n++)
    {
        struct NUIBindArrayData bad = NUI_GetBindArrayData(bd.jBinds, n);
        UpdateBinds(bad.sBind, bd.nToken, TRUE);
    }
}

void NUI_HandleFormEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    if (HasListItem(IGNORE_EVENTS, ed.sEvent))
        return;

    //Notice("** EVENT MARKER - " + ed.sEvent + " **");

    if (ed.sEvent == "open")
    {

    }

    if (ed.sFormID == "appearance_editor_loader")
    {
        if (ed.sEvent == "click")
        {
            int nType = JsonGetInt(NUI_GetBindValue(ed.oPC, ed.nFormToken, "handler_type_value"));

            string sFunction = _GetKey(ed.sControlID);
            string sType = _GetValue(ed.sControlID);

            if (sFunction == "clear_data")
            {
                if      (nType == 0) ClearDatabaseTables();
                else if (nType == 1) ClearDatabaseTables(SIMPLE);
                else if (nType == 2) ClearDatabaseTables(COMPOSITE);
                else if (nType == 3) ClearDatabaseTables(ARMORANDAPPEARANCE);

                form_open();
            }
            else if (sFunction == "handler_load")
            {
                if (sType == "all")
                {
                    if (nType == 0)
                    {
                        DelayCommand(0.1, PopulateSimpleModelData(BASE_CONTENT));
                        DelayCommand(0.1, PopulateSimpleModelData(CUSTOM_CONTENT));
                        DelayCommand(0.1, PopulateCompositeModelData(BASE_CONTENT));
                        DelayCommand(0.1, PopulateCompositeModelData(CUSTOM_CONTENT));
                        DelayCommand(0.1, PopulateArmorAndAppearanceModelData(BASE_CONTENT));
                        DelayCommand(0.1, PopulateArmorAndAppearanceModelData(CUSTOM_CONTENT));   
                    }
                    else if (nType == 1)
                    {
                        DelayCommand(0.1, PopulateSimpleModelData(BASE_CONTENT));
                        DelayCommand(0.1, PopulateSimpleModelData(CUSTOM_CONTENT));
                    }
                    else if (nType == 2)
                    {
                        DelayCommand(0.1, PopulateCompositeModelData(BASE_CONTENT));
                        DelayCommand(0.1, PopulateCompositeModelData(CUSTOM_CONTENT));
                    }
                    else if (nType == 3)
                    {
                        DelayCommand(0.1, PopulateArmorAndAppearanceModelData(BASE_CONTENT));
                        DelayCommand(0.1, PopulateArmorAndAppearanceModelData(CUSTOM_CONTENT)); 
                    }
                }
                else
                {
                    int nContent = (sType == "custom" ? CUSTOM_CONTENT : BASE_CONTENT);

                    if (nType == 0)
                    {
                        DelayCommand(0.1, PopulateSimpleModelData(nContent));
                        DelayCommand(0.1, PopulateCompositeModelData(nContent));
                        DelayCommand(0.1, PopulateArmorAndAppearanceModelData(nContent));   
                    }
                    else if (nType == 1)
                        DelayCommand(0.1, PopulateSimpleModelData(nContent));
                    else if (nType == 2)
                        DelayCommand(0.1, PopulateCompositeModelData(nContent));
                    else if (nType == 3)
                        DelayCommand(0.1, PopulateArmorAndAppearanceModelData(nContent));   
                }

                form_open();
            }
            else if (sFunction == "open_form")
            {
                string sValue = _GetValue(ed.sControlID);
                if (sValue == "editor")
                {
                    NUI_DisplayForm(ed.oPC, FORM_ID);
                    NUI_DestroyForm(ed.oPC, ed.nFormToken);
                }
            }
        }
    }
    else if (ed.sEvent == "mouseup")
    {
        string sKey = _GetKey(ed.sControlID);

        if (sKey == "part_cat")
            OnSelectPartCategory(_GetValue(ed.sControlID));
        else if (sKey == "model_matrix")
        {  
            string sValue = _GetValue(ed.sControlID);
            if (sValue != "")
                OnSelectPart(sValue);
        }
        else if (sKey == "color_cat")
            OnSelectColorCategory(_GetValue(ed.sControlID));
        else if (ed.sControlID == "button_previous")
            OnPreviousPart();
        else if (ed.sControlID == "button_next")
            OnNextPart();
        else if (ed.sControlID == "image_colorsheet")
            OnSelectColor(ed.jPayload);
    }
    else if (ed.sEvent == "watch")
    {
        //Notice("  >> sControlID - " + ed.sControlID);
        //Notice("  >> bind value - " + JsonDump(NuiGetBind(ed.oPC, ed.nFormToken, ed.sControlID)));
    }
}

//void main () {}