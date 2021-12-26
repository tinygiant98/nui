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

const string VERSION = "1.1.2";
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

const int MODE_APPEARANCE = 0;
const int MODE_ARMOR = 1;
const int MODE_ITEMS = 2;

const int STATUS_EQUIPPED = 1;
const int STATUS_INVENTORY = 2;
const int STATUS_LOOSE = 3;
const int STATUS_CREATURE = 4;

const string IGNORE_EVENTS = "mousedown,range,blur,focus,mousescroll";

void LoadColorCategoryOptions();
void LoadPartCategoryOptions();
void UpdateBinds(string sBind, int nToken = -1, int bSetDefaults = FALSE);
json GetCompositeModelData(string sField, string sClass, string sPosition = "");
json GetSimpleModelData(string sClass = "");
json GetLayeredModelData(string sClass = "");
json GetArmorAndAppearanceModelData(int nGender, int nRace, int nPhenotype, string sPart);
//void HandlePartCategoryToggles();
void HandleModelMatrixToggles();
void HandleItemLayerToggles();
void HandlePartCategoryToggles();
void HandleColorCategoryToggles(int bClear = FALSE);
void LoadParts(string sModel = "", string sPartCategory = "");
string Get2DAListByCriteria(string s2DA, string sReturnColumn,
                            string sCriteriaColumn = "", string sCriteria = "");
json GetLayeredModelData(string sClass = "");
void SetColorMatrixSelection();
sqlquery PrepareQuery(string sQuery);
void HighlightTarget(int bHighlight = TRUE, object oTarget = OBJECT_INVALID);
void SetPerPartCheckboxValue(int bChecked = TRUE);
void ToggleFormMode(string sType, int bForce = FALSE);
void UpdateTitleBlock();
void DisplayMessage(string sMessage, json jColor, float fTime = 3.0);
void DisplayNote(string sMessage, float fTime = 3.0);
void DisplayCaution(string sMessage, float fTime = 3.0);
void DisplayWarning(string sMessage, float fTime = 3.0);
void PopulateTargetData(object oTarget, vector vPosition);
void ModifyArmorColor(int nColorChannel, int nColorID, string sPartCategory = "");
void ModifyItemShape();
void UpdateItemIndicators(int bMute = FALSE);
void EnableColorCategoryPerPartIndicators(int bReset = FALSE);
void EnablePartCategoryPerPartIndicators(int bReset = FALSE);
void EnablePerPartCheckbox(int bEnabled = TRUE);
int GetIndicatorStatus(string sControl);
void SetPerPartColorVariable(object oItem, int nColorID, int nChannel = -1, string sPartCategoryOverride = "");
void EnablePerPartIndicator(string sControl, int bEnabled = TRUE);

int IncrementLocalInt(string sVarName, int nStep = 1)
{
    object oTarget = OBJECT_SELF;

    SetLocalInt(oTarget, sVarName, GetLocalInt(oTarget, sVarName) + nStep);
    return GetLocalInt(oTarget, sVarName);
}

int DecrementLocalInt(string sVarName, int nStep = -1)
{
    return IncrementLocalInt(sVarName, nStep);
}

int GetFormToken(string sFormID = "")
{
    if (sFormID == "")
        sFormID = FORM_ID;

    return NuiFindWindow(OBJECT_SELF, sFormID);
}

void SetProperty(string sProperty, json jValue, object oTarget = OBJECT_SELF)
{
    json jProperties = GetLocalJson(oTarget, PROPERTIES);

    if (jProperties == JsonNull())
        jProperties = JsonObject();

    jProperties = JsonObjectSet(jProperties, sProperty, jValue);
    SetLocalJson(oTarget, PROPERTIES, jProperties);
}

json GetProperty(string sProperty, object oTarget = OBJECT_SELF)
{
    json jProperties = GetLocalJson(oTarget, PROPERTIES);
    return JsonObjectGet(jProperties, sProperty);
}

void DeleteProperty(string sProperty, object oTarget = OBJECT_SELF)
{
    json jProperties = GetLocalJson(oTarget, PROPERTIES);
         jProperties = JsonObjectDel(jProperties, sProperty);

    SetLocalJson(oTarget, PROPERTIES, jProperties);
}

void DeleteProperties(object oTarget = OBJECT_SELF)
{
    DeleteLocalJson(oTarget, PROPERTIES);
}

void RepairFormLayout()
{
    Notice("Repairing form layout");

    int nToken = GetFormToken();

    json jG = NuiGetBind(OBJECT_SELF, nToken, "formGeometry");
    float h = JsonGetFloat(JsonObjectGet(jG, "h"));
    h += FloatToInt(h) % 2 == 0 ? 1.0 : -1.0;
    DelayCommand(1.0, NuiSetBind(OBJECT_SELF, nToken, "formGeometry", JsonObjectSet(jG, "h", JsonFloat(h))));
}

int  GetFormMode() { return JsonGetInt(GetProperty("formMode")); }
void SetFormMode(int nMode)
{
    json jLeft, jRight;
    if (nMode == MODE_APPEARANCE)
    {
        jLeft = NUI_GetFormRoot("_appedit_tab_appearance_left");
        jRight = NUI_GetFormRoot("_appedit_tab_appearance_right");
    }
    else if (nMode == MODE_ARMOR)
    {
        jLeft = NUI_GetFormRoot("_appedit_tab_appearance_left");
        jRight = NUI_GetFormRoot("_appedit_tab_appearance_right");
    }    
    else if (nMode == MODE_ITEMS)
    {
        jLeft = NUI_GetFormRoot("_appedit_tab_items_left");
        jRight = NUI_GetFormRoot("_appedit_tab_items_right");
    }

    int nToken = GetFormToken();
    NuiSetGroupLayout(OBJECT_SELF, nToken, "left_column", jLeft);
    NuiSetGroupLayout(OBJECT_SELF, nToken, "right_column", jRight);
    
    RepairFormLayout();
    /*
    // TODO this weird solution to an odd problem of control sizing on layout CHANGES
    // remove when a better solution is devised by niv?
    // This just up/downsizes the form by 1 pixel to force a control size refresh
    json jG = NuiGetBind(OBJECT_SELF, nToken, "geometry");
    float h = JsonGetFloat(JsonObjectGet(jG, "h"));
    h += FloatToInt(h) % 2 == 0 ? 1.0 : -1.0;
    NuiSetBind(OBJECT_SELF, nToken, "geometry", JsonObjectSet(jG, "h", JsonFloat(h)));
    // end weird solution
    */

    SetProperty("formMode", JsonInt(nMode));
}

int  GetIsAppearanceSelected() { return GetFormMode() == MODE_APPEARANCE; }
int  GetIsEquipmentSelected() { return GetFormMode() == MODE_ARMOR; }
int  GetIsItemsSelected()     { return GetFormMode() == MODE_ITEMS; }

string GetColorSheetResref() { return JsonGetString(GetProperty("colorSheetResref")); }
void   SetColorSheetResref(string sResref) 
{ 
    SetProperty("colorSheetResref", JsonString(sResref));
    UpdateBinds("image_colorsheet_resref");
}

string GetGroupOptions(string sFormID)
{
    sqlquery sqlBinds = NUI_GetBindTable(sFormID);

    string sBind, sIndexes;
    while (SqlStep(sqlBinds))
    {
        sBind = SqlGetString(sqlBinds, 3);
        sIndexes = AddListItem(sIndexes, NUI_GetValue(sBind), TRUE);
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
    SetColorMatrixSelection();
}

string GetPartCategoryOptions() { return JsonGetString(GetProperty("partCategoryOptions")); }
void LoadPartCategoryOptions()
{
    string sCategory;
    if (GetIsAppearanceSelected() == TRUE)
        sCategory = "appearance";
    else if (GetIsEquipmentSelected() == TRUE)
        sCategory = "equipment";
    else
    {
        Error("LoadPartCategoryOptions() called for category other than appearance or equipment");
        return;
    }

    int nToken = GetFormToken();
    string sFormID = "_appedit_tab_part_" + sCategory;
    json j = NUI_GetFormRoot(sFormID);

    NuiSetGroupLayout(OBJECT_SELF, nToken, "part_category_tab", j);
    SetProperty("partCategoryOptions", JsonString(GetGroupOptions(sFormID)));

    if (GetPartCategorySelected() == "")
        SetPartCategorySelected("chest");

    UpdateItemIndicators();
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
    DelayCommand(0.04, SetColorMatrixSelection());
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
        sResult = AddListItem(sResult, NUI_GetValue(sID));
    }

    return sResult;
}

string GetColorCategoryOptions() { return JsonGetString(GetProperty("colorCategoryOptions")); }
void LoadColorCategoryOptions()
{
    HandleColorCategoryToggles(TRUE);

    string sCategory;
    if (GetIsAppearanceSelected() == TRUE)
        sCategory = "appearance";
    else if (GetIsEquipmentSelected() == TRUE)
        sCategory = "equipment";

    int nToken = GetFormToken();
    json j = NUI_GetFormRoot("_appedit_tab_color_" + sCategory);
    
    NuiSetGroupLayout(OBJECT_SELF, nToken, "color_category_tab", j);
    SetProperty("colorCategoryOptions", JsonString(GetCategoriesFromDatabase()));
    
    if (GetColorCategorySelected() == "" || HasListItem(GetColorCategoryOptions(), GetColorCategorySelected()) == FALSE)
        SetColorCategorySelected("0");
    else
        SetColorCategorySelected(GetColorCategorySelected());

    EnablePerPartCheckbox(!GetIndicatorStatus(GetColorCategorySelected()));
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
        json jValue = bClear == TRUE ? jFALSE : JsonBool(sOption == sSelected);
        NUI_SetBindValue(OBJECT_SELF, nToken, "color_cat_value:" + sOption, jValue);
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

string GetShapeOptions() { return JsonGetString(GetProperty("shapeOptions")); }
void SetShapeOptions(string sOptions)
{
    SetProperty("shapeOptions", JsonString(sOptions));
}

string GetColorOptions() { return JsonGetString(GetProperty("colorOptions")); }
void SetColorOptions(string sOptions)
{
    SetProperty("colorOptions", JsonString(sOptions));
}

string GetShapeSelected() { return JsonGetString(GetProperty("shapeSelected")); }
void SetShapeSelected(string sShape)
{
    string sPrevious = GetShapeSelected();
    if (sPrevious != "")
        NuiSetBind(OBJECT_SELF, GetFormToken(), "shape_matrix_value:" + sPrevious, jFALSE);

    SetProperty("shapeSelected", JsonString(sShape));
    NuiSetBind(OBJECT_SELF, GetFormToken(), "shape_matrix_value:" + sShape, jTRUE);
}

string GetColorSelected() { return JsonGetString(GetProperty("colorSelected")); }
void SetColorSelected(string sColor)
{
    string sPrevious = GetColorSelected();
    if (sPrevious != "")
        NuiSetBind(OBJECT_SELF, GetFormToken(), "color_matrix_value:" + sPrevious, jFALSE);

    SetProperty("colorSelected", JsonString(sColor));
    NuiSetBind(OBJECT_SELF, GetFormToken(), "color_matrix_value:" + sColor, jTRUE);
}

json GetFormProfile() { return GetProperty("formProfile"); }
void SetFormProfile(string sProfileName) 
{
    SetProperty("formProfile", NUI_GetFormProfile(FORM_ID, sProfileName));
}

json GetFormProfileProperty(string sProperty)
{
    return JsonObjectGet(GetFormProfile(), sProperty);
}

void CreateDefaultProfile()
{
    NUI_CreateFormProfile(FORM_ID, "default");
    {
        json jGeometry = NUI_DefineRectangle(100.0, 100.0, 650.0, 610.0);

        NUI_SetProfileProperty("formGeometry", jGeometry);
        NUI_SetProfileProperty("enableData", jTRUE);
        NUI_SetProfileProperty("enableTargeting", jTRUE);
        NUI_SetProfileProperty("enableSelf", jTRUE);
        NUI_SetProfileProperty("enableOptions", jFALSE);

        NUI_SetProfileProperty("showData", jFALSE);
        NUI_SetProfileProperty("showTargeting", jTRUE);
        NUI_SetProfileProperty("showSelf", jFALSE);
        NUI_SetProfileProperty("showOptions", jFALSE);
        NUI_SetProfileProperty("showObjectTitle", jTRUE);
        NUI_SetProfileProperty("showObjectDescription", jFALSE);
        NUI_SetProfileProperty("showMessageCenter", jFALSE);

        NUI_SetProfileProperty("validObjectTypes", JsonInt(OBJECT_TYPE_ITEM));
        NUI_SetProfileProperty("validObjectLocation", JsonInt(STATUS_INVENTORY | STATUS_EQUIPPED | STATUS_LOOSE));
        NUI_SetProfileProperty("targetObjectVariable", JsonString("NUI_TARGET_OBJECT"));
        NUI_SetProfileProperty("targetObjectString", JsonString(ObjectToString(OBJECT_SELF)));      
    } NUI_SaveFormProfile();
}

int  GetTargetObjectSlot() { return JsonGetInt(GetProperty("targetObjectSlot")); }
void SetTargetObjectSlot(int nSlot = -1) { SetProperty("targetObjectSlot", JsonInt(nSlot)); }

int GetTargetObjectStatus() { return JsonGetInt(GetProperty("targetObjectStatus")); }
void SetTargetObjectStatus(int nStatus = -1) { SetProperty("targetObjectStatus", JsonInt(nStatus)); }

vector GetTargetObjectPosition()
{
    json j = GetProperty("targetObjectPosition");
    float x = JsonGetFloat(JsonObjectGet(j, "x"));
    float y = JsonGetFloat(JsonObjectGet(j, "y"));
    float z = JsonGetFloat(JsonObjectGet(j, "z"));

    return Vector(x, y, z);
}
void SetTargetObjectPosition(vector vPosition)
{
    json j = JsonObject();
         j = JsonObjectSet(j, "x", JsonFloat(vPosition.x));
         j = JsonObjectSet(j, "y", JsonFloat(vPosition.y));
         j = JsonObjectSet(j, "z", JsonFloat(vPosition.z));
    
    SetProperty("targetObjectPosition", j);
}

location GetTargetObjectLocation()
{
    json j = GetProperty("targetObjectLocation");
    object oArea = StringToObject(JsonGetString(JsonObjectGet(j, "area")));
    vector vPosition = GetTargetObjectPosition();
    float fFacing = JsonGetFloat(JsonObjectGet(j, "facing"));

    return Location(oArea, vPosition, fFacing);
}
void SetTargetObjectLocation(location l)
{
    string sArea = ObjectToString(GetAreaFromLocation(l));
    vector vPosition = GetPositionFromLocation(l);
    float fFacing = GetFacingFromLocation(l);

    json j = JsonObject();
         j = JsonObjectSet(j, "area", JsonString(sArea));
         j = JsonObjectSet(j, "facing", JsonFloat(fFacing));

    SetTargetObjectPosition(vPosition);
    SetProperty("targetObjectLocation", j);    
}

object GetTargetObjectOwner()
{
    string sObject = JsonGetString(GetProperty("targetObjectOwner"));
    if (sObject == "_NONE_")
        return OBJECT_INVALID;
    else    
        return StringToObject(sObject);
}

void SetTargetObjectOwner(object oOwner = OBJECT_INVALID)
{
    if (oOwner == OBJECT_INVALID)
        SetProperty("targetObjectOwner", JsonString("_NONE_"));
    else
        SetProperty("targetObjectOwner", JsonString(ObjectToString(oOwner)));
}

object GetTargetObject(int bFindCreature = FALSE)
{
    string sObject = JsonGetString(GetProperty("targetObject"));
    return StringToObject(sObject);
}

void SetTargetObject(object oTarget, int bDisplayMessage = TRUE)
{
    HighlightTarget(FALSE);
    HighlightTarget(FALSE, GetTargetObjectOwner());
    SetProperty("targetObject", JsonString(ObjectToString(oTarget)));

    //DeleteModuleEventsBlocked();

    // This delay command was necessary because objects that moved from
    // equipped slots to inventory were still being shows as equipped
    // until the OnItemUnequip function was complete.  Bug?
    DelayCommand(0.01, PopulateTargetData(oTarget, GetPosition(oTarget)));
 
    if (bDisplayMessage == TRUE)
        DisplayNote("New target object selected");
}

int GetItemLayerSelected() { return JsonGetInt(GetProperty("itemLayerSelected")); }
void SetItemLayerSelected(int nLayer = 2) 
{
    SetProperty("itemLayerSelected", JsonInt(nLayer));
    HandleItemLayerToggles();
}

void HandleItemLayerToggles()
{
    int n, nLayer = GetItemLayerSelected();
    for (n = 0; n < 3; n++)
    {
        string sBind = "layer_value:" + IntToString(n);
        NuiSetBind(OBJECT_SELF, GetFormToken(), sBind, JsonBool(n == nLayer));
    }
}

int GetItemModelType()
{
    object oTarget = GetTargetObject();
    return StringToInt(Get2DAString("baseitems", "modeltype", GetBaseItemType(oTarget)));
}

void DisplayMessage(string sMessage, json jColor, float fTime = 3.0)
{
    if (sMessage == "")
        return;

    if (jColor == JsonNull())
        jColor = NUI_DefineRGBColor(255, 255, 255);

    int nToken = GetFormToken();
    NUI_DelayBindValue(OBJECT_SELF, nToken, "message_center_value", JsonString(sMessage));
    NUI_DelayBindValue(OBJECT_SELF, nToken, "message_center_color", jColor);

    DelayCommand(3.0, NUI_DelayBindValue(OBJECT_SELF, nToken, "message_center_value", JsonNull()));
}

void DisplayNote(string sMessage, float fTime = 3.0)
{
    DisplayMessage(sMessage, NUI_DefineRGBColor(255, 255, 255), fTime);
}

void DisplayCaution(string sMessage, float fTime = 3.0)
{
    DisplayMessage(sMessage, NUI_DefineRGBColor(198, 221, 30), fTime);
}

void DisplayWarning(string sMessage, float fTime = 3.0)
{
    DisplayMessage(sMessage, NUI_DefineRGBColor(225, 78, 64), fTime);
}

void SetLinkGroupEnabled(int bEnabled = TRUE)
{
    if (bEnabled == FALSE)
        SetItemLayerSelected(-1);

    NuiSetBind(OBJECT_SELF, GetFormToken(), "link_group_enabled", JsonBool(bEnabled));
    UpdateItemIndicators(!bEnabled);
}

void DisableItemIcons()
{
    int n;
    for (n = 0; n < 3; n++)
        NuiSetBind(OBJECT_SELF, GetFormToken(), "item_icon_enabled:" + IntToString(n), jFALSE);
}

int UpdateItemIcons()
{
    object oTarget = GetTargetObject();
    int nBaseItemType = GetBaseItemType(oTarget);
    string sIcons, sClass = GetStringLowerCase(Get2DAString("baseitems", "itemclass", nBaseItemType));
    int bLinkEnabled, nValue = StringToInt(Get2DAString("baseitems", "modeltype", nBaseItemType));

    if (nValue == 0 || nValue == 1)
    {
        DisableItemIcons();
        int nShape = GetItemAppearance(oTarget, ITEM_APPR_TYPE_SIMPLE_MODEL, -1);
        string sShape = (nShape < 10 ? "00" : nShape < 100 ? "0" : "") + IntToString(nShape);

        sIcons = AddListItem(sIcons, "i" + sClass + "_" + sShape);

        bLinkEnabled = FALSE;
    }
    else if (nValue == 2)
    {
        string sPositions = "b,m,t";
        int n, nCount = CountList(sPositions);
        
        for (n = 0; n < nCount; n++)
        {
            string sShape = IntToString(GetItemAppearance(oTarget, ITEM_APPR_TYPE_WEAPON_MODEL, n));
            string sColor = IntToString(GetItemAppearance(oTarget, ITEM_APPR_TYPE_WEAPON_COLOR, n));
            
            sShape = (StringToInt(sShape) < 10 ? "0" : "") + sShape;
            string sIcon = "i" + sClass + "_" + GetListItem(sPositions, n) + "_" + sShape + sColor;

            sIcons = AddListItem(sIcons, sIcon);
        }

        bLinkEnabled = TRUE;
    }

    int n, nCount = CountList(sIcons), nToken = GetFormToken();
    for (n = 0; n < nCount; n++)
    {
        NuiSetBind(OBJECT_SELF, nToken, "item_icon:" + IntToString(n), JsonString(GetListItem(sIcons, n)));
        NuiSetBind(OBJECT_SELF, nToken, "item_icon_enabled:" + IntToString(n), jTRUE);
    }

    return bLinkEnabled;
}

void UpdateTitleBlock()
{
    object oTarget = GetTargetObject();
    int nType = GetObjectType(oTarget);

    string sType, sTLLabel, sTLValue, sTRLabel, sTRValue, sBLLabel, sBLValue, sBRLabel, sBRValue, sIcons;
    string sTitle = GetName(oTarget);
    string sTag = GetTag(oTarget);

    if (nType == OBJECT_TYPE_CREATURE)
    {
        if (GetIsDM(oTarget))
            sType = "DM";
        else if (GetIsPC(oTarget))
            sType = "PC";
        else
            sType = "NPC";
    
        sTitle += " (" + sType + ")";

        sTLLabel = "Tag: ";
        sTRLabel = "Gender: ";
        sBLLabel = "Race: ";
        sBRLabel = "Phenotype: ";

        sTLValue = (sType == "NPC" ? sTag : "Not Applicable");

        int nValue = GetGender(oTarget);
        sTRValue = GetStringByStrRef(StringToInt(Get2DAString("gender", "name", nValue)), nValue) + " (" + IntToString(nValue) + ")";

        nValue = GetRacialType(oTarget);
        sBLValue = Get2DAString("racialtypes", "label", nValue) + " (" + IntToString(nValue) + ")";

        nValue = GetPhenoType(oTarget);
        sBRValue = Get2DAString("phenotype", "label", nValue) + " (" + IntToString(nValue) + ")";
    }
    else if (nType == OBJECT_TYPE_ITEM)
    {
        int nBaseItemType = GetBaseItemType(oTarget);
        string sClass = GetStringLowerCase(Get2DAString("baseitems", "itemclass", nBaseItemType));
        sTitle += " (" + GetStringByStrRef(StringToInt(Get2DAString("baseitems", "name", nBaseItemType)), 0) + ")";

        sTLLabel = "Tag: ";
        sTRLabel = "Model Type: ";
        sBLLabel = "Class: ";
        sBRLabel = "Location: ";

        sTLValue = GetStringLowerCase(sTag);
        
        int nValue = StringToInt(Get2DAString("baseitems", "modeltype", nBaseItemType));
        sTRValue = (nValue == 0 ? "Simple" :
                    nValue == 1 ? "Layered" :
                    nValue == 2 ? "Composite" :
                    nValue == 3 ? "Armor" : "Unknown");
        
        SetLinkGroupEnabled(UpdateItemIcons());
        
        sBLValue = sClass;

        int nStatus = GetTargetObjectStatus();
        if (nStatus == STATUS_EQUIPPED)
        {
            string sSlot;
            int nSlot = GetTargetObjectSlot();
            if      (nSlot == INVENTORY_SLOT_HEAD) sSlot = "Head";
            else if (nSlot == INVENTORY_SLOT_CHEST) sSlot = "Chest";
            else if (nSlot == INVENTORY_SLOT_BOOTS) sSlot = "Boots";
            else if (nSlot == INVENTORY_SLOT_ARMS) sSlot = "Arms";
            else if (nSlot == INVENTORY_SLOT_RIGHTHAND) sSlot = "Right Hand";
            else if (nSlot == INVENTORY_SLOT_LEFTHAND) sSlot = "Left Hand";
            else if (nSlot == INVENTORY_SLOT_CLOAK) sSlot = "Cloak";
            else if (nSlot == INVENTORY_SLOT_LEFTRING) sSlot = "Left Ring";
            else if (nSlot == INVENTORY_SLOT_RIGHTRING) sSlot = "Right Ring";
            else if (nSlot == INVENTORY_SLOT_NECK) sSlot = "Neck";
            else if (nSlot == INVENTORY_SLOT_BELT) sSlot = "Belt";
            else if (nSlot == INVENTORY_SLOT_ARROWS) sSlot = "Arrows";
            else if (nSlot == INVENTORY_SLOT_BULLETS) sSlot = "Bullets";
            else if (nSlot == INVENTORY_SLOT_BOLTS) sSlot = "Bolts";

            sBRValue = sSlot;
        }
        else if (nStatus == STATUS_INVENTORY)
            sBRValue = "Inventory";
        else if (nStatus == STATUS_LOOSE)
        {
            vector vPosition = GetTargetObjectPosition();

            string sPosition = "[" + FloatToString(vPosition.x, 2, 1) + ", " +
                                     FloatToString(vPosition.y, 2, 1) + ", " +
                                     FloatToString(vPosition.z, 2, 1) + "]";

            sBRValue = sPosition;
        }
    }

    int nToken = GetFormToken();
    NUI_DelayBindValue(OBJECT_SELF, nToken, "block_title", JsonString(sTitle));
    
    NUI_DelayBindValue(OBJECT_SELF, nToken, "block_tl_label", JsonString(sTLLabel));
    NUI_DelayBindValue(OBJECT_SELF, nToken, "block_tl_value", JsonString(sTLValue));

    NUI_DelayBindValue(OBJECT_SELF, nToken, "block_tr_label", JsonString(sTRLabel));
    NUI_DelayBindValue(OBJECT_SELF, nToken, "block_tr_value", JsonString(sTRValue));

    NUI_DelayBindValue(OBJECT_SELF, nToken, "block_bl_label", JsonString(sBLLabel));
    NUI_DelayBindValue(OBJECT_SELF, nToken, "block_bl_value", JsonString(sBLValue));

    NUI_DelayBindValue(OBJECT_SELF, nToken, "block_br_label", JsonString(sBRLabel));
    NUI_DelayBindValue(OBJECT_SELF, nToken, "block_br_value", JsonString(sBRValue));
}

void PopulateTargetData(object oTarget, vector vPosition)
{
    if (oTarget == OBJECT_INVALID)
        return;

    int n, bFound = FALSE, nObjectType = GetObjectType(oTarget);
    if (nObjectType == OBJECT_TYPE_CREATURE)
    {
        SetTargetObjectStatus(STATUS_CREATURE);
        SetTargetObjectSlot();
        SetTargetObjectOwner();
        SetTargetObjectLocation(GetLocation(oTarget));
        ToggleFormMode("appearance");
    }
    else if (nObjectType == OBJECT_TYPE_ITEM)
    {
        object oOwner = GetItemPossessor(oTarget);
        if (vPosition == Vector() && GetIsObjectValid(oOwner))
        {
            SetTargetObjectOwner(oOwner);
            if (GetObjectType(oOwner) != OBJECT_TYPE_CREATURE)
            {
                SetTargetObjectSlot();
                SetTargetObjectStatus(STATUS_INVENTORY);
            }
            else
            {
                for (n = INVENTORY_SLOT_HEAD; n <= INVENTORY_SLOT_BOLTS; n++)
                {
                    object oEquipped = GetItemInSlot(n, oOwner);
                    if (oEquipped == oTarget)
                    {
                        SetTargetObjectSlot(n);
                        SetTargetObjectStatus(STATUS_EQUIPPED);
                        if (n == INVENTORY_SLOT_HEAD || n == INVENTORY_SLOT_CHEST)
                            ToggleFormMode("equipment");
                        else
                            ToggleFormMode("weapons");

                        bFound = TRUE;
                        break;
                    }
                }

                if (bFound == FALSE)
                {
                    if (GetBaseItemType(oTarget) == BASE_ITEM_ARMOR)
                        ToggleFormMode("equipment");
                    else
                        ToggleFormMode("weapons");

                    SetTargetObjectStatus(STATUS_INVENTORY);
                    SetTargetObjectSlot();
                }
            }
        }
        else
        {
            SetTargetObjectOwner();
            SetTargetObjectSlot();
            SetTargetObjectLocation(GetLocation(oTarget));
            SetTargetObjectStatus(STATUS_LOOSE);
            if (GetBaseItemType(oTarget) == BASE_ITEM_ARMOR)
                ToggleFormMode("equipment");
            else
                ToggleFormMode("weapons");
        }
    }

    int nStatus = GetTargetObjectStatus();
    if (nStatus == STATUS_CREATURE || nStatus == STATUS_LOOSE)
        HighlightTarget();
    else if (nStatus == STATUS_EQUIPPED)
        HighlightTarget(TRUE, GetTargetObjectOwner());
    else if (nStatus == STATUS_INVENTORY)
    {
        HighlightTarget(FALSE);
        HighlightTarget(FALSE, GetTargetObjectOwner());
    }

    UpdateTitleBlock();
}

void HandlePlayerTargeting()
{
    object oTarget = GetTargetingModeSelectedObject();
    if (oTarget != GetTargetObject())
        SetTargetObject(oTarget);
    else
        DisplayCaution("Selected target is current target");
}

void SetPlayerTargeting()
{
    int nObjectTypes = JsonGetInt(GetFormProfileProperty("validObjectTypes"));
    if (nObjectTypes == 0)
        nObjectTypes = OBJECT_TYPE_CREATURE | OBJECT_TYPE_ITEM;

    EnterTargetingMode(OBJECT_SELF, nObjectTypes);
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
    json jResult = JsonArray();
    int n, nCount = JsonGetLength(jPartIDs);
    for (n = 0; n < nCount; n++)
    {
        int nID = JsonGetInt(JsonArrayGet(jPartIDs, n));
        if (GetHasRequiredArmorFeat(GetTargetObject(), IntToString(nID)) == TRUE)
            jResult = JsonArrayInsert(jResult, JsonInt(nID));
    }

    return jResult;
}

json BuildToggleMatrix(json jIDs, string sIDPrefix, string sBindPrefix, int nColumns = 5, int nRows = 6)
{
    string sIndexes, mtb = "matrix_tb";

    NUI_CreateTemplateControl(mtb);
    {
        NUI_AddToggleButton();
            NUI_SetHeight(25.0);
            NUI_SetWidth(40.0);
    } NUI_SaveTemplateControl();

    NUI_CreateForm("");
    {
        int n, nCount = JsonGetLength(jIDs);
        float fSpacer = nCount > nRows * nColumns ? 0.0 : 12.0;

        NUI_AddRow();
        NUI_AddSpacer();
            NUI_SetWidth(fSpacer);

        for (n = 0; n < nCount; n++)
        {
            json jID = JsonArrayGet(jIDs, n);
            string sLabel = IntToString(JsonGetInt(jID));

            NUI_AddTemplateControl(mtb);
                NUI_SetID(sIDPrefix + ":" + sLabel);
                NUI_SetLabel(sLabel);
                NUI_BindValue(sBindPrefix + ":" + sLabel);

            if ((n + 1) % nColumns == 0)
            {
                NUI_AddRow();
                NUI_AddSpacer();
                    NUI_SetWidth(fSpacer);
            }

            sIndexes = AddListItem(sIndexes, sLabel);
        }
    }

    json jResult = JsonObject();
         jResult = JsonObjectSet(jResult, "indexes", JsonString(sIndexes));
         jResult = JsonObjectSet(jResult, "matrix", JsonObjectGet(NUI_GetBuildVariable(NUI_BUILD_ROOT), "root"));

    return jResult;
}

void BuildModelMatrix(json jPartIDs, int nColumns = 5, int nRows = 6, int bForce = FALSE)
{
    string sIndexes, sVarName = "appedit_modelmatrix:" +
        (GetIsAppearanceSelected() ? "appearance" : "equipment") + ":" +
        GetPartCategorySelected();    

    json jMatrix = GetProperty(sVarName);

    if (jMatrix == JsonNull() || bForce == TRUE)
    {
        json j = BuildToggleMatrix(jPartIDs, "model_matrix", "model_matrix_value", nColumns, nRows);

        sIndexes = JsonGetString(JsonObjectGet(j, "indexes"));
        jMatrix = JsonObjectGet(j, "matrix");

        SetProperty(sVarName, jMatrix);
        SetProperty(sVarName + ":select", JsonString(sIndexes));
    }
    else
        sIndexes = JsonGetString(GetProperty(sVarName + ":select"));

    SetPartOptions(sIndexes);
    NuiSetGroupLayout(OBJECT_SELF, GetFormToken(), "model_matrix", jMatrix);
}

int GetPartIndex(string sPart)
{
    if      (sPart == "head") return CREATURE_PART_HEAD;    
    else if (sPart == "robe") return ITEM_APPR_ARMOR_MODEL_ROBE;
    else
        return StringToInt(Get2DAListByCriteria("capart", TWODA_INDEX, "mdlname", sPart));
}

object ModifyAndDestroyItem(object oItem, int nModelType, int nPart, int nIndex, int nCopyVars = FALSE)
{
    int nStatus = GetTargetObjectStatus();

    if (nStatus == STATUS_INVENTORY || nStatus == STATUS_EQUIPPED)
    {
        IncrementLocalInt("APPEDIT_BLOCK_ACQUIRE_EVENT");
        IncrementLocalInt("APPEDIT_BLOCK_UNACQUIRE_EVENT");
    }

    if (nStatus == STATUS_EQUIPPED)
    {
        IncrementLocalInt("APPEDIT_BLOCK_EQUIP_EVENT");
        IncrementLocalInt("APPEDIT_BLOCK_UNEQUIP_EVENT");
    }

    object oCopy = CopyItemAndModify(oItem, nModelType, nPart, nIndex, nCopyVars);
    DestroyObject(oItem);

    return oCopy;
}

void ModifyCreaturePart(string sModel)
{   
    int nPart = GetPartIndex(GetPartCategorySelected());
    SetCreatureBodyPart(nPart, StringToInt(sModel), GetTargetObject());
}

void ModifyArmorPart(string sModel = "", string sPartCategory = "")
{
    object oArmor = GetTargetObject();
    string sPart = (sPartCategory == "" ? GetPartCategorySelected() : sPartCategory);
    int nPart = GetPartIndex(sPart);
    int nModelType = ITEM_APPR_TYPE_ARMOR_MODEL;
    
    oArmor = ModifyAndDestroyItem(oArmor, nModelType, nPart, StringToInt(GetPartSelected()), TRUE);

    int nSlot;
    if ((nSlot = GetTargetObjectSlot()) > -1)
        AssignCommand(GetTargetObjectOwner(), ActionEquipItem(oArmor, nSlot));

    SetTargetObject(oArmor, FALSE);
}

void LoadParts(string sModel = "", string sPartCategory = "")
{
    object oPC;
    if (GetFormMode() == MODE_APPEARANCE)
        oPC = GetTargetObject();
    else if (GetFormMode() == MODE_ARMOR)
        oPC = GetTargetObjectOwner();

    int nRace = GetRacialType(oPC);
    int nGender = GetGender(oPC);
    int nPhenotype = GetPhenoType(oPC);
    string sPart = (sPartCategory == "" ? GetPartCategorySelected() : sPartCategory);
    int bAppearance = GetIsAppearanceSelected();
    int bEquipment = !bAppearance;

    int nPart = GetPartIndex(sPart);

    if (sModel == "")
    {
        json jPartIDs = GetArmorAndAppearanceModelData(nGender, nRace, nPhenotype, sPart);
        if (GetTargetObjectStatus() == STATUS_EQUIPPED)
            jPartIDs = FilterArmorPartIDs(jPartIDs);

        BuildModelMatrix(jPartIDs);
    
        if (bAppearance == TRUE)
            SetPartSelected(IntToString(GetCreatureBodyPart(nPart, oPC)), FALSE);
        else if (bEquipment == TRUE)
            SetPartSelected(IntToString(GetItemAppearance(GetTargetObject(), ITEM_APPR_TYPE_ARMOR_MODEL, nPart)), FALSE);
    }
    else
    {
        if (bAppearance == TRUE)
            ModifyCreaturePart(sModel);
        else if (bEquipment == TRUE)
            ModifyArmorPart(sModel, sPartCategory);
    }
}

void LoadItemShapes()
{
    if (GetFormMode() != MODE_ITEMS)
        return;
    
    object oTarget = GetTargetObject();
    int nLayer = GetItemLayerSelected();
    int nModelType = GetItemModelType();
    string sClass = GetStringLowerCase(Get2DAString("baseitems", "itemclass", GetBaseItemType(oTarget)));
    string sItemLayers = "b,m,t";

    json jShapeIDs, jColorIDs;

    SetLinkGroupEnabled(nModelType == 2);

    string sIndexes, sPosition = GetListItem(sItemLayers, nLayer);
    json jMatrix, jBlank = NUI_GetFormRoot("_appedit_tab_blank");

    if (nModelType == 0)
        jShapeIDs = GetSimpleModelData(sClass);
    else if (nModelType == 1)
        jShapeIDs = GetLayeredModelData(sClass);
    else if (nModelType == 2)
    {
        jShapeIDs = GetCompositeModelData("shape", sClass, sPosition);
        jColorIDs = GetCompositeModelData("color", sClass, sPosition);
    }

    jMatrix = BuildToggleMatrix(jShapeIDs, "shape_matrix", "shape_matrix_value", 7, 5);
    sIndexes = JsonGetString(JsonObjectGet(jMatrix, "indexes"));
    jMatrix = JsonObjectGet(jMatrix, "matrix");

    SetShapeOptions(sIndexes);
    if (CountList(sIndexes) == 0)
        jMatrix = jBlank;
    
    NuiSetGroupLayout(OBJECT_SELF, GetFormToken(), "item_shape_matrix", jMatrix);

    if (nModelType == 2)
    {
        jMatrix = BuildToggleMatrix(jColorIDs, "color_matrix", "color_matrix_value", 7, 1);
        sIndexes = JsonGetString(JsonObjectGet(jMatrix, "indexes"));
        jMatrix = JsonObjectGet(jMatrix, "matrix");

        SetColorOptions(sIndexes);
        if (CountList(sIndexes) == 0)
            jMatrix = jBlank;

        NuiSetGroupLayout(OBJECT_SELF, GetFormToken(), "item_color_matrix", jMatrix);
    }
    else
    {
        SetColorOptions("");
        NuiSetGroupLayout(OBJECT_SELF, GetFormToken(), "item_color_matrix", jBlank);
    }
    
    if (nModelType = 0 || nModelType == 1)
    {
        int nShape = GetItemAppearance(oTarget, ITEM_APPR_TYPE_SIMPLE_MODEL, -1);
        SetShapeSelected(IntToString(nShape));
        return;
    }
    else
    {
        if (nLayer < 3)
        {
            int nShape = GetItemAppearance(oTarget, ITEM_APPR_TYPE_WEAPON_MODEL, nLayer);
            int nColor = GetItemAppearance(oTarget, ITEM_APPR_TYPE_WEAPON_COLOR, nLayer);
            
            SetShapeSelected(IntToString(nShape));
            SetColorSelected(IntToString(nColor));
        }
    }
}

void UpdateItemIndicators(int bMute = FALSE)
{
    object oTarget = GetTargetObject();
    int nToken = GetFormToken();

    if (bMute == TRUE)
    {
        string sLabels = "indicator_shape,indicator_color,text_shape,text_color";

        int n, i;
        for (i = 0; i < 3; i++)
        {
            int nCount = CountList(sLabels);

            for (n = 0; n < nCount; n++)
            {
                string sBind = "layer_" + GetListItem(sLabels, n) + "_enabled:" + IntToString(i);
                NuiSetBind(OBJECT_SELF, nToken, sBind, jFALSE);
            }
        }

        return;
    }

    int n;
    for (n = 0; n < 3; n++)
    {
        int nShape = GetItemAppearance(oTarget, ITEM_APPR_TYPE_WEAPON_MODEL, n);
        int nColor = GetItemAppearance(oTarget, ITEM_APPR_TYPE_WEAPON_COLOR, n);
        string s = IntToString(n);
     
        NuiSetBind(OBJECT_SELF, nToken, "layer_text_shape:" + s, JsonString(IntToString(nShape)));
        NuiSetBind(OBJECT_SELF, nToken, "layer_text_color:" + s, JsonString(IntToString(nColor)));
        
        NuiSetBind(OBJECT_SELF, nToken, "layer_indicator_shape_enabled:" + s, jTRUE);
        NuiSetBind(OBJECT_SELF, nToken, "layer_indicator_color_enabled:" + s, jTRUE);

        NuiSetBind(OBJECT_SELF, nToken, "layer_text_shape_enabled:" + s, jTRUE);
        NuiSetBind(OBJECT_SELF, nToken, "layer_text_color_enabled:" + s, jTRUE);
    }
}

void ToggleFormMode(string sType, int bForce = FALSE)
{
    int nMode = sType == "appearance" ? MODE_APPEARANCE :
                sType == "equipment" ?  MODE_ARMOR :
                                        MODE_ITEMS;
    
    SetFormMode(nMode);

    if (nMode == MODE_APPEARANCE || nMode == MODE_ARMOR)
    {
        LoadColorCategoryOptions();
        LoadPartCategoryOptions();

        string sOptions = GetPartCategoryOptions();
        if (HasListItem(sOptions, GetPartCategorySelected()) == FALSE)
            SetPartCategorySelected(GetListItem(sOptions, GetIsEquipmentSelected()));
        else
            SetPartCategorySelected(GetPartCategorySelected());
    }
    
    if (nMode == MODE_ARMOR)
    {
        EnablePartCategoryPerPartIndicators(TRUE);
    }
    else if (nMode == MODE_ITEMS)
    {
        if (GetItemLayerSelected() == -1)
            SetItemLayerSelected(2);
        else
            SetItemLayerSelected(GetItemLayerSelected());

        LoadItemShapes();
        UpdateItemIndicators();
    }
}

void form_open()
{
    int nLoader = NuiFindWindow(OBJECT_SELF, "appearance_editor_loader");
    int nEditor = NuiFindWindow(OBJECT_SELF, "appearance_editor");

    string sTables = DATABASE_TABLE_SIMPLE + "," + DATABASE_TABLE_COMPOSITE + "," + DATABASE_TABLE_ARMOR;
    string sValues = "simple,composite,armor";

    json jValue, jColor;
    json jGreen = NUI_DefineRGBColor(0, 255, 0);
    json jRed = NUI_DefineRGBColor(255, 0, 0);
    json jYellow = NUI_DefineRGBColor(255, 255, 0);

    int n, nTables, nCount = CountList(sTables);
    for (n = 0; n < nCount; n++)
    {
        string sTable = GetListItem(sTables, n);
        sQuery = "SELECT COUNT(*) FROM " + sTable + ";";
        sql = PrepareQuery(sQuery);
        SqlStep(sql);
        
        string sPrefix = "data_" + GetListItem(sValues, n);

        int nRecords = SqlGetInt(sql, 0);
        if (nRecords > 0)
        {
            nTables++;
            jValue = JsonString(IntToString(nRecords));
            jColor = jGreen;
        }
        else
        {
            jValue = JsonString("Not Loaded");
            jColor = jRed;
        }

        if (nLoader > 0)
        {
            NUI_SetBindValue(OBJECT_SELF, nLoader, sPrefix + "_value", jValue);
            NUI_SetBindValue(OBJECT_SELF, nLoader, sPrefix + "_color", jColor);
        }
    }

    if (nEditor > 0)
    {
        if      (nTables == 0)      jColor = jRed;
        else if (nTables == nCount) jColor = jGreen;
        else                        jColor = jYellow;

        NUI_SetBindValue(OBJECT_SELF, nEditor, "data_color", jColor);
    }

    DeleteLocalInt(GetModule(), "MODULE_LOAD_MAX");
    DeleteLocalInt(GetModule(), "MODULE_LOAD_COUNT");
}

void setTargetObject_click()
{
    SetPlayerTargeting();
}

void cb_self_mouseup()
{
    if (OBJECT_SELF != GetTargetObject())
        SetTargetObject(OBJECT_SELF);
    else
        DisplayCaution("Selected target is current target");
}

object ResetObjectPerPartColoring(object oItem, string sColorCategories, int nPart = -1)
{
    if (nPart == -1)
        nPart = GetPartIndex(GetPartCategorySelected());
    
    int n, nCount = CountList(sColorCategories);
    for (n = 0; n < nCount; n++)
    {
        string sColorCategory = GetListItem(sColorCategories, n);
        int nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nPart * ITEM_APPR_ARMOR_NUM_COLORS) + StringToInt(sColorCategory);
        oItem = ModifyAndDestroyItem(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, 255, TRUE);
    }

    return oItem;
}

void open_loader_click()
{
    string sFormID = "appearance_editor_loader";
    int nToken = GetFormToken();

    NUI_DisplayForm(OBJECT_SELF, sFormID);
    NUI_DestroyForm(OBJECT_SELF, nToken);
}

void HighlightTarget(int bHighlight = TRUE, object oTarget = OBJECT_INVALID)
{
    if (oTarget == OBJECT_INVALID)
        oTarget = GetTargetObject();

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

void OnSelectItemShape(string sControl)
{
    if (GetShapeSelected() == sControl)
        return;

    SetShapeSelected(sControl);
    ModifyItemShape();
}

void OnSelectItemColor(string sControl)
{
    if (GetColorSelected() == sControl)
        return;

    SetColorSelected(sControl);
    ModifyItemShape();
}

void OnSelectLayer(string sLayer)
{
    SetItemLayerSelected(StringToInt(sLayer));
    LoadItemShapes();
}

void OnSelectColorCategory(string sControl)
{
    SetColorCategorySelected(sControl);
    EnablePerPartCheckbox(!GetIndicatorStatus(sControl));
}

void OnSelectPartCategory(string sControl)
{
    if (NUI_GetKey(sControl) == "swap")
    {
        string sPart = GetPartCategorySelected();
        if (GetStringLeft(sPart, GetStringLength(sPart) - 1) != NUI_GetValue(sControl))
        {
            DisplayCaution("Cannot swap the selected category");
            return;
        }

        json jPerPartColoring = GetProperty(sPart, GetTargetObject());

        sPart = GetStringLeft(sPart, GetStringLength(sPart) - 1) +
            (GetStringRight(sPart, 1) == "l" ? "r" : "l");

        ModifyArmorPart(GetPartSelected(), sPart);

        if (jPerPartColoring == JsonNull())
            return;
        else
        {
            json jColorCategories = JsonObjectKeys(jPerPartColoring);
            int n, nCount = JsonGetLength(jColorCategories);
            for (n = 0; n < nCount; n++)
            {
                string sColorCategory = JsonGetString(JsonArrayGet(jColorCategories, n));
                int nColor = JsonGetInt(JsonObjectGet(jPerPartColoring, sColorCategory));

                ModifyArmorColor(StringToInt(sColorCategory), nColor, sPart);

                SetPerPartColorVariable(GetTargetObject(), nColor, StringToInt(sColorCategory), sPart);
                EnablePerPartIndicator(sColorCategory, nColor != 255);
            }

            SetProperty(sPart, jPerPartColoring);
        }
        return;
    }

    if (GetPartCategorySelected() == sControl)
    {
        UpdateBinds("part_cat_value:" + sControl);
        return;
    }

    SetPartCategorySelected(sControl);
    EnableColorCategoryPerPartIndicators(TRUE);
    EnablePerPartCheckbox(!GetIndicatorStatus(GetColorCategorySelected()));
}

void OnLinkItemModels()
{
    object oTarget = GetTargetObject();
    int n, nLayer = GetItemLayerSelected();

    int nShape = GetItemAppearance(oTarget, ITEM_APPR_TYPE_WEAPON_MODEL, nLayer);
    int nColor = GetItemAppearance(oTarget, ITEM_APPR_TYPE_WEAPON_COLOR, nLayer);

    for (n = 0; n < 3; n++)
    {
        if (n == nLayer)
            continue;

        oTarget = ModifyAndDestroyItem(oTarget, ITEM_APPR_TYPE_WEAPON_MODEL, n, nShape, TRUE);
        oTarget = ModifyAndDestroyItem(oTarget, ITEM_APPR_TYPE_WEAPON_COLOR, n, nColor, TRUE);  
    }

    if (GetTargetObjectStatus() == STATUS_EQUIPPED)
        AssignCommand(GetTargetObjectOwner(), ActionEquipItem(oTarget, GetTargetObjectSlot()));

    SetTargetObject(oTarget, FALSE);
    UpdateItemIndicators();
}

int GetPerPartCheckboxValue()
{
    return JsonGetInt(NUI_GetBindValue(OBJECT_SELF, GetFormToken(), "per_part_checkbox_value"));
}

void SetPerPartCheckboxValue(int bChecked = TRUE)
{
    NUI_SetBindValue(OBJECT_SELF, GetFormToken(), "per_part_checkbox_value", JsonBool(bChecked));
}

void EnablePerPartCheckbox(int bEnabled = TRUE)
{
    SetPerPartCheckboxValue(!bEnabled);
    NUI_SetBindValue(OBJECT_SELF, GetFormToken(), "per_part_checkbox_enabled", JsonBool(bEnabled));
}

void DisablePerPartCheckbox()
{
    EnablePerPartCheckbox(FALSE);
}

void DisablePerPartIndicators(string sType = "all")
{
    string sOptions;
    if (sType == "all" || sType == "color_categories")
        sOptions = MergeLists(sOptions, GetColorCategoryOptions());

    if (sType == "all" || sType == "part_categories")
        sOptions = MergeLists(sOptions, GetPartCategoryOptions());

    int n, nOptions = CountList(sOptions);
    int nToken = GetFormToken();
    for (n = 0; n < nOptions; n++)
    {
        string sOption = GetListItem(sOptions, n);
        NUI_SetBindValue(OBJECT_SELF, nToken, "indicator_enabled:" + sOption, jFALSE);
    }
}

void EnablePerPartIndicator(string sControl, int bEnabled = TRUE)
{
    int nToken = GetFormToken();
    NUI_SetBindValue(OBJECT_SELF, nToken, "indicator_enabled:" + sControl, JsonBool(bEnabled));
}

void DisablePerPartIndicator(string sControl)
{
    EnablePerPartIndicator(sControl, FALSE);
}

void EnableColorCategoryPerPartIndicators(int bReset = FALSE)
{
    if (bReset == TRUE)
        DisablePerPartIndicators("color_categories");

    object oTarget = GetTargetObject();
    string sPartCategory = GetPartCategorySelected();

    json jColorKeys = JsonObjectKeys(GetProperty(sPartCategory, oTarget));
    int n, nCount = JsonGetLength(jColorKeys);

    for (n = 0; n < nCount; n++)
    {
        string sColorCategory = JsonGetString(JsonArrayGet(jColorKeys, n));
        EnablePerPartIndicator(sColorCategory);
    }
}

void EnablePartCategoryPerPartIndicators(int bReset = FALSE)
{
    if (bReset == TRUE)
        DisablePerPartIndicators("part_categories");

    object oTarget = GetTargetObject();
    json jPerPartColoring = JsonObjectKeys(GetLocalJson(oTarget, PROPERTIES));

    int n, nCount = JsonGetLength(jPerPartColoring);
    for (n = 0; n < nCount; n++)
    {
        string sPartCategory = JsonGetString(JsonArrayGet(jPerPartColoring, n));
        EnablePerPartIndicator(sPartCategory);
    }
}

int GetPerPartColor()
{
    string sColorCategory = GetColorCategorySelected();
    string sPartCategory = GetPartCategorySelected();

    object oTarget = GetTargetObject();
    json jParts = GetProperty(sPartCategory, oTarget);

    if (jParts == JsonNull())
        return -1;

    json jColor = JsonObjectGet(jParts, sColorCategory);
    return jColor == JsonNull() ? -1 : JsonGetInt(jColor);
}

void DeletePerPartColor(string sType, string sControl = "")
{
    string sColorCategory = GetColorCategorySelected();
    string sPartCategory = GetPartCategorySelected();

    if (sType == "part_cat" && sControl != "")
        sPartCategory = sControl;
    else if (sType == "color_cat" && sControl != "")
        sColorCategory = sControl;

    object oTarget = GetTargetObject();

    json jProperties = GetLocalJson(oTarget, PROPERTIES);
    if (jProperties == JsonNull())
        return;

    json jParts = JsonObjectGet(jProperties, sPartCategory);
    if (jParts == JsonNull())
        return;

    if (sType == "part_cat")
    {
        json jColors = JsonObjectKeys(jParts);
        int n, nKeys = JsonGetLength(jColors);

        for (n = 0; n < nKeys; n++)
        {
            string sKey = JsonGetString(JsonArrayGet(jColors, n));
            ModifyArmorColor(StringToInt(sKey), 255, sPartCategory);
        }

        DisablePerPartIndicator(sPartCategory);
        jProperties = JsonObjectDel(jProperties, sPartCategory);

        SetLocalJson(oTarget, PROPERTIES, jProperties);
    }
    else if (sType == "color_cat")
    {
        json jColor = JsonObjectGet(jParts, sColorCategory);
        if (jColor != JsonNull())
        {
            ModifyArmorColor(StringToInt(sColorCategory), 255);
            jParts = JsonObjectDel(jParts, sColorCategory);
            
            if (JsonGetLength(jParts) == 0)
                jProperties = JsonObjectDel(jProperties, sPartCategory);
            else
                jProperties = JsonObjectSet(jProperties, sPartCategory, jParts);

            SetLocalJson(oTarget, PROPERTIES, jProperties);            
        }
    }
}

void SetPerPartColorVariable(object oItem, int nColorID, int nChannel = -1, string sPartCategoryOverride = "")
{
    string sChannel;
    if (nChannel == -1) sChannel = GetColorCategorySelected();
    else                sChannel = IntToString(nChannel);
    
    string sPartCategory;
    if (sPartCategoryOverride == "")
        sPartCategory = GetPartCategorySelected();
    else
        sPartCategory = sPartCategoryOverride;

    json jProperty = GetProperty(sPartCategory, oItem);
    if (jProperty == JsonNull())
        jProperty = JsonObject();

    if (nColorID == -1 || nColorID == 255)
    {
        jProperty = JsonObjectDel(jProperty, sChannel);
        if (JsonGetLength(jProperty) == 0)
        {
            DeleteProperty(sPartCategory, oItem);
            return;
        }
    }
    else
        jProperty = JsonObjectSet(jProperty, sChannel, JsonInt(nColorID));

    SetProperty(sPartCategory, jProperty, oItem);
}

int GetIndicatorStatus(string sControl)
{
    return JsonGetInt(NuiGetBind(OBJECT_SELF, GetFormToken(), "indicator_enabled:" + sControl));
}

void RemovePerPartColorVariable(object oItem)
{
    SetPerPartColorVariable(oItem, -1);
}

void ModifyItemShape()
{
    object oTarget = GetTargetObject();
    int nShape = StringToInt(GetShapeSelected());
    int nColor = StringToInt(GetColorSelected());
    int nLayer = GetItemLayerSelected();
    int nModelType = GetItemModelType();

    string sPositions = "b,m,t";

    if (nModelType == 0 || nModelType == 1)
        oTarget = ModifyAndDestroyItem(oTarget, ITEM_APPR_TYPE_SIMPLE_MODEL, -1, nShape);
    else if (nModelType == 2)
    {
        oTarget = ModifyAndDestroyItem(oTarget, ITEM_APPR_TYPE_WEAPON_MODEL, nLayer, nShape, TRUE);
        oTarget = ModifyAndDestroyItem(oTarget, ITEM_APPR_TYPE_WEAPON_COLOR, nLayer, nColor, TRUE);
    }

    if (GetTargetObjectStatus() == STATUS_EQUIPPED)
        AssignCommand(GetTargetObjectOwner(), ActionEquipItem(oTarget, GetTargetObjectSlot()));

    SetTargetObject(oTarget, FALSE);
}

void ModifyArmorColor(int nColorChannel, int nColorID, string sPartCategory = "")
{
    object oTarget = GetTargetObject();
    int bPerPart = sPartCategory != "" || GetPerPartCheckboxValue();

    int nPart, nIndex, nMode = GetFormMode();
    if (nMode == MODE_ARMOR && bPerPart == TRUE)
    {
        if (sPartCategory == "")
            nPart = GetPartIndex(GetPartCategorySelected());
        else
            nPart = GetPartIndex(sPartCategory);

        nIndex = ITEM_APPR_ARMOR_NUM_COLORS + (nPart * ITEM_APPR_ARMOR_NUM_COLORS) + nColorChannel;
    }
    else if (nMode == MODE_ITEMS)
        nIndex = StringToInt(GetPartCategorySelected());
    else
        nIndex = nColorChannel;

    oTarget = ModifyAndDestroyItem(oTarget, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex, nColorID, TRUE);
    if (GetTargetObjectStatus() == STATUS_EQUIPPED)
        AssignCommand(GetTargetObjectOwner(), ActionEquipItem(oTarget, GetTargetObjectSlot()));

    if (bPerPart == TRUE)
    {
        SetPerPartColorVariable(oTarget, nColorID, nColorChannel, sPartCategory);
        EnablePerPartIndicator(IntToString(nColorChannel), nColorID != 255);
    }

    SetTargetObject(oTarget, FALSE);
}

void SetColorMatrixSelection()
{
    int nIndex, nColor, nChannel = StringToInt(GetColorCategorySelected());
    if (GetIsAppearanceSelected() == TRUE)
        nColor = GetColor(GetTargetObject(), nChannel);
    else if (GetIsEquipmentSelected() == TRUE)
    {
        string sPartCategory = GetPartCategorySelected();
        json jColor = GetProperty(sPartCategory, GetTargetObject());

        if (jColor == JsonNull())
        {
            SetPerPartCheckboxValue(FALSE);
            nColor = GetItemAppearance(GetTargetObject(), ITEM_APPR_TYPE_ARMOR_COLOR, nChannel);
        }
        else
            nColor = JsonGetInt(JsonObjectGet(jColor, IntToString(nChannel)));
    }

    json jPoints;
    if (nColor == -1)
        jPoints = JsonNull();
    else
    {
        int nRow = nColor / COLOR_WIDTH_CELLS;
        int nColumn = FloatToInt(frac((nColor * 1.0) / COLOR_WIDTH_CELLS) * COLOR_WIDTH_CELLS);

        float fScale = GetPlayerDeviceProperty(OBJECT_SELF, PLAYER_DEVICE_PROPERTY_GUI_SCALE) / 100.0;
        float fTileWidth = 16.0 * fScale;
        float fTileHeight = 16.0 * fScale;

        float x = nColumn * fTileWidth;
        float y = nRow * fTileHeight;
        
        jPoints = NUI_GetRectanglePoints(x, y, fTileWidth, fTileHeight);
    }

    NUI_SetBindValue(OBJECT_SELF, GetFormToken(), "image_colorsheet_points", jPoints);
}

void OnSelectColor(json jPayload)
{
    object oPC = GetTargetObject();

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
        ModifyArmorColor(nChannel, nColorID);

    DelayCommand(0.04, SetColorMatrixSelection());
}

void OnSelectPart(string sPart)
{
    SetPartSelected(sPart, TRUE);
}

string GetMatrixNavigationIndex(string sOptions, string sOption, int nNext = TRUE)
{
    int nIndex = FindListItem(sOptions, sOption);
    
    if (nNext == TRUE)
    {
        if (nIndex >= CountList(sOptions) - 1) nIndex = 0;
        else                                   nIndex += 1;
    }
    else
    {
        if (nIndex <= 0) nIndex = CountList(sOptions) - 1;
        else             nIndex -= 1;
    }

    return GetListItem(sOptions, nIndex);
}

void OnPreviousShape()
{
    string sShape = GetMatrixNavigationIndex(GetShapeOptions(), GetShapeSelected(), FALSE);
    OnSelectItemShape(sShape);
}

void OnNextShape()
{
    string sShape = GetMatrixNavigationIndex(GetShapeOptions(), GetShapeSelected(), TRUE);
    OnSelectItemShape(sShape);
}

void OnPreviousColor()
{
    string sColor = GetMatrixNavigationIndex(GetColorOptions(), GetColorSelected(), FALSE);
    OnSelectItemColor(sColor);
}

void OnNextColor()
{
    string sColor = GetMatrixNavigationIndex(GetColorOptions(), GetColorSelected(), TRUE);
    OnSelectItemColor(sColor);
}

void OnPreviousPart()
{
    string sPart = GetMatrixNavigationIndex(GetPartOptions(), GetPartSelected(), FALSE);
    OnSelectPart(sPart);
}

void OnNextPart()
{
    string sPart = GetMatrixNavigationIndex(GetPartOptions(), GetPartSelected(), TRUE);
    OnSelectPart(sPart);
}

void form_close()
{
    HighlightTarget(FALSE);
    HighlightTarget(FALSE, GetTargetObjectOwner());
    DeleteLocalJson(OBJECT_SELF, PROPERTIES);

    string sEvents = "ACQUIRE,UNACQUIRE,EQUIP,UNEQUIP";
    int n, nCount = CountList(sEvents);
    for (n = 0; n < nCount; n++)
        DeleteLocalInt(OBJECT_SELF, "APPEDIT_BLOCK_" + GetListItem(sEvents, n) + "_EVENT");
}

sqlquery PrepareQuery(string sQuery)
{
    return NUI_PrepareQuery(sQuery, USE_CAMPAIGN_DATABASE, CAMPAIGN_DATABASE);
}

void AddModelToDatabase(int nType, json jModel, string sCategory = "")
{
    int n, nCount;
    if (nType == SIMPLE || nType == LAYERED)
    {
        string sValues, sType = sCategory;
        nCount = JsonGetLength(jModel);
        for (n = 0; n < nCount; n++)
        {
            string sFile = JsonGetString(JsonArrayGet(jModel, n));
            int nUnderscore = GetSubStringCount(sFile, "_");
            
            string sClass = GetStringLeft(sFile, FindSubStringN(sFile, "_", nUnderscore - 1));
            int nVariant = StringToInt(GetStringRight(sFile, GetStringLength(sFile) - GetStringLength(sClass) - 1));

            sValues += (sValues != "" ? "," : "") + "('" + sType + "'," +
                                        "'" + sClass   + "'," +
                                        "'" + IntToString(nVariant) + "'," +
                                        "'" + sFile + "')";
        }

        sQuery = "INSERT OR REPLACE INTO " + DATABASE_TABLE_SIMPLE + " (type, class, variant, file) " +
                    "VALUES " + sValues + ";";
        sql = PrepareQuery(sQuery);
        SqlStep(sql);
    }
    else if (nType == COMPOSITE)
    {
        string sValues;
        nCount = JsonGetLength(jModel);
        for (n = 0; n < nCount; n++)
        {
            // Expected file name format is [i]<class>_x_###
            // [i] is optional, in case this is based on tga instead of mdlname
            // x is a single letter - m, b, t
            // ### is a padded three digit number

            string sFile = JsonGetString(JsonArrayGet(jModel, n));
            string sPrevious = sFile;

            int nDelimiter = GetSubStringCount(sFile, "_");
            string sClass = GetStringLeft(sFile, FindSubStringN(sFile, "_", nDelimiter - 2));
            if (GetStringLeft(sClass, 1) == "i")
                sClass = GetStringRight(sClass, GetStringLength(sClass) - 1);

            string sPosition = GetSubString(sFile, FindSubStringN(sFile, "_", nDelimiter - 2) + 1, 1);
            int nNumber = StringToInt(GetStringRight(sFile, 3));
            int nShape = nNumber / 10;
            int nColor = nNumber - (nShape * 10);

            sValues += (sValues != "" ? "," : "") + "('" + sClass + "'," +
                                                    "'" + sPosition   + "'," +
                                                    "'" + IntToString(nShape) + "'," +
                                                    "'" + IntToString(nColor) + "'," +
                                                    "'" + sPrevious + "')";
        }

        sQuery = "INSERT OR REPLACE INTO " + DATABASE_TABLE_COMPOSITE + 
                    " (class, position, shape, color, file) " +
                 "VALUES " + sValues + ";";
        sql = PrepareQuery(sQuery);
        SqlStep(sql);
    }
    else if (nType == ARMORANDAPPEARANCE)
    {
        string sValues;

        nCount = JsonGetLength(jModel);
        for (n = 0; n < nCount; n++)
        {
            string sFile = JsonGetString(JsonArrayGet(jModel, n));
            string sGender = GetSubString(sFile, 1, 1);
            string sRace = GetSubString(sFile, 2, 1);
            string sPhenotype = GetSubString(sFile, 3, 1);
            string sPart = GetSubString(sFile, 5, GetStringLength(sFile) - 8);
            int nModel = StringToInt(GetStringRight(sFile, 3));

            sValues += (sValues != "" ? "," : "") + "('" + sGender + "'," +
                                                    "'" + sRace   + "'," +
                                                    "'" + sPhenotype + "'," +
                                                    "'" + sPart + "'," +
                                                    "'" + IntToString(nModel) + "'," +
                                                    "'" + sFile + "')";
        }        

        sQuery = "INSERT OR REPLACE INTO " + DATABASE_TABLE_ARMOR + 
                    " (gender, race, phenotype, part, model, file) " +
                 "VALUES " + sValues + ";";
        sql = PrepareQuery(sQuery);
        SqlStep(sql);
    }

    if (IncrementLocalInt("MODULE_LOAD_COUNT", nCount) >= GetLocalInt(GetModule(), "MODULE_LOAD_MAX"))
        form_open();
}

void InitializeDatabase(int nType = -1)
{
    if (nType == -1 || nType == SIMPLE || nType == LAYERED)
    {
        sQuery = "CREATE TABLE IF NOT EXISTS " + DATABASE_TABLE_SIMPLE + " (" +
            "type INTEGER, " +
            "class TEXT, " +
            "variant INTEGER, " +
            "file TEXT UNIQUE);";
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
            "file TEXT UNIQUE);";
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
            "file TEXT UNIQUE);";
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
    string sSubQuery = "SELECT variant " +
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

json GetCompositeModelData(string sField, string sClass, string sPosition = "")
{
    string sSubQuery = "SELECT DISTINCT " + sField + " " +
                "FROM " + DATABASE_TABLE_COMPOSITE + " " +
                "WHERE class = @class " +
                    (sPosition == "" ? "" : "AND position = @position ") +
                    "AND shape != 0 " +
                "ORDER BY " + sField + " ASC";
    
    sQuery = "SELECT json_group_array (json(" + sField + ")) " +
             "FROM (" + sSubQuery + ");";
    
    sql = PrepareQuery(sQuery);    
    SqlBindString(sql, "@class", sClass);
    
    if (sPosition != "")
        SqlBindString(sql, "@position", sPosition);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
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

    if (bReturnAllResults == TRUE)
    {
        int n, nCount = Get2DARowCount(s2DA);
        for (n = 0; n < nCount; n++)
        {
            string sResult = Get2DAString(s2DA, sReturnColumn, n++);
            if (sResult != "")
                sReturn = AddListItem(sReturn, GetStringLowerCase(sResult));
        }

        return sReturn;
    }

    if (bReturnIndices == TRUE)
    {
        int n, nCount = Get2DARowCount(s2DA);
        string sResult;

        for (n = 0; n < nCount; n++)
        {
            if (sReturnColumn == TWODA_INDEX)
            {
                sResult = GetStringLowerCase(Get2DAString(s2DA, sCriteriaColumn, n++));
                if (HasListItem(sCriteria, sResult) == TRUE)
                    sReturn = AddListItem(sReturn, IntToString(n - 1), TRUE);
            }
            else
            {
                sResult = Get2DAString(s2DA, sReturnColumn, n++);
                if (sResult != "")
                    sReturn = AddListItem(sReturn, IntToString(n - 1), TRUE);
            }
        }

        return sReturn;
    }

    if (bReturnByIndex == TRUE)
    {
        int n, nCount = CountList(sCriteria);
        for (n = 0; n < nCount; n++)
        {
            int nIndex = StringToInt(GetListItem(sCriteria, n));
            sReturn = AddListItem(sReturn, GetStringLowerCase(Get2DAString(s2DA, sReturnColumn, nIndex)), TRUE);
        }

        return sReturn;
    }

    if (bUseCriteria == TRUE)
    {
        int n, nCount = Get2DARowCount(s2DA);
        for (n = 0; n < nCount; n++)
        {
            string sTargetColumn = bUseCriteria == TRUE ? sCriteriaColumn : sReturnColumn;
            string sResult = Get2DAString(s2DA, sTargetColumn, n);

            if (sResult != "")
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
            }
        }
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

            json jResrefs = NUI_GetResrefArray(sPrefix, RESTYPE_MDL, nType);
            if (jResrefs == JsonNull())
            {
                jResrefs = NUI_GetResrefArray("i" + sPrefix, RESTYPE_TGA, nType);
                if (jResrefs == JsonNull())
                {
                    Notice("No " + (nType == BASE_CONTENT ? "custom " : "base game ") +
                        (sType == "0" ? "simple" : "layered") + " model content found for model file prefix '" + sPrefix + "'");
                    continue;
                }
            }

            IncrementLocalInt("MODULE_LOAD_MAX", JsonGetLength(jResrefs));
            DelayCommand(0.1, AddModelToDatabase(SIMPLE, jResrefs, sType));
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
                    jResrefs = NUI_GetResrefArray("i" + sPrefix, RESTYPE_TGA, nType);
                    if (jResrefs == JsonNull())
                    {
                        Notice("No " + (nType == BASE_CONTENT ? "base game " : "custom ") +
                            "composite model content found for model file prefix '" + sPrefix + "'");
                        continue;
                    }
                }

                IncrementLocalInt("MODULE_LOAD_MAX", JsonGetLength(jResrefs));
                DelayCommand(0.1, AddModelToDatabase(COMPOSITE, jResrefs));
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
                          
                    json jResrefs = NUI_GetResrefArray(sPrefix, RESTYPE_MDL, nType);
                    if (jResrefs == JsonNull())
                    {
                        Notice("No " + (nType == BASE_CONTENT ? "custom " : "base game ") +
                            "armor/appearance model content found for model file prefix '" + sPrefix + "'");
                        continue;
                    }

                    IncrementLocalInt("MODULE_LOAD_MAX", JsonGetLength(jResrefs));
                    DelayCommand(0.1, AddModelToDatabase(ARMORANDAPPEARANCE, jResrefs));
                }
            }
        }
    }
}

void CreateBlankLayout()
{
    NUI_CreateForm("_appedit_tab_blank");
    {
        NUI_AddSpacer();
    } NUI_SaveForm();
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
            string sLeftOption = NUI_GetKey(sOption);
            string sRightOption = NUI_GetValue(sOption);

            NUI_AddRow();
            if (sRightOption == "")
                NUI_AddSpacer();
            
            NUI_AddTemplateControl(tb);
                sPointer = IntToString(x++);
                NUI_SetID("color_cat:" + sPointer);
                NUI_SetLabel(sLeftOption);
                NUI_BindValue("color_cat_value:" + sPointer);

                if (sCategory == "equipment")
                {
                    NUI_AddCanvas();
                    {
                        NUI_DrawCircle(10.0, 13.0, 3.0);
                        NUI_SetFill(TRUE);
                        NUI_SetDrawColor(NUI_DefineRGBColor(25, 165, 10));
                        NUI_BindEnabled("indicator_enabled:" + sPointer);
                    } NUI_CloseCanvas();
                }

            if (sRightOption == "")
                NUI_AddSpacer();
            else
            {
                NUI_AddTemplateControl(tb);
                    sPointer = IntToString(x++);
                    NUI_SetID("color_cat:" + sPointer);
                    NUI_SetLabel(sRightOption);
                    NUI_BindValue("color_cat_value:" + sPointer);

                    if (sCategory == "equipment")
                    {
                        NUI_AddCanvas();
                        {
                            NUI_DrawCircle(10.0, 13.0, 3.0);
                            NUI_SetFill(TRUE);
                            NUI_SetDrawColor(NUI_DefineRGBColor(25, 165, 10));
                            NUI_BindEnabled("indicator_enabled:" + sPointer);
                        } NUI_CloseCanvas();
                    }
            }
        } 
        
        if (sCategory == "equipment")
        {
            NUI_AddRow();
            NUI_AddSpacer();
            NUI_AddCheckbox("per_part_coloring");
                NUI_SetLabel("Per Part Coloring");
                NUI_BindValue("per_part_checkbox_value");
                NUI_BindEnabled("per_part_checkbox_enabled");
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
                
                string sLeftPart = NUI_GetKey(sPart);
                string sRightPart = NUI_GetValue(sPart);

                string sLeftPointer = NUI_GetKey(sPointer);
                string sRightPointer = NUI_GetValue(sPointer);

                NUI_AddRow();
                if (sRightPart == "")
                    NUI_AddSpacer();

                NUI_AddTemplateControl(tb);
                    NUI_SetID("part_cat:" + sLeftPointer);
                    NUI_SetLabel(sLeftPart);
                    NUI_BindValue("part_cat_value:" + sLeftPointer);
                    NUI_BindEnabled("part_cat_enabled:" + sLeftPointer);

                    if (bEquipment == TRUE)
                    {
                        NUI_AddCanvas();
                        {
                            NUI_DrawCircle(10.0, 13.0, 3.0);
                            NUI_SetFill(TRUE);
                            NUI_SetDrawColor(NUI_DefineRGBColor(25, 165, 10));
                            NUI_BindEnabled("indicator_enabled:" + sLeftPointer);
                        } NUI_CloseCanvas();
                    }

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
                        if (bEquipment == TRUE)
                        {
                            NUI_AddCanvas();
                            {
                                NUI_DrawCircle(10.0, 13.0, 3.0);
                                NUI_SetFill(TRUE);
                                NUI_SetDrawColor(NUI_DefineRGBColor(25, 165, 10));
                                NUI_BindEnabled("indicator_enabled:" + sRightPointer);
                            } NUI_CloseCanvas();
                        }

                }
            }
        } NUI_SaveForm();
    }
}

void CreateItemsTabs()
{
    string sFormID = "_appedit_tab_items_left";

    NUI_CreateForm(sFormID);
    {
        float fRowHeight = 25.0;
        json jIndicatorColor = NUI_DefineRGBColor(25, 165, 10);
        json jTextColor = NUI_DefineRGBColor(8, 227, 243);

        NUI_AddRow();
            NUI_AddControlGroup();
                NUI_SetHeight(110.0);
                NUI_SetWidth(340.0);
                NUI_SetBorderVisible(FALSE);
                NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                NUI_SetOrientation(NUI_ORIENTATION_COLUMNS);
                NUI_BindEnabled("link_group_enabled");
            {
                NUI_AddColumn(20.0);
                NUI_AddColumn();

                string sLabels = "Bottom,Middle,Top";

                int n;
                for (n = 2; n >= 0; n--)
                {
                    string sID = IntToString(n);

                    NUI_AddRow(fRowHeight);
                    NUI_AddToggleButton("layer:" + sID);
                        NUI_SetMargin(0.0);
                        NUI_SetPadding(0.0);
                        NUI_SetLabel(GetListItem(sLabels, n));
                        NUI_BindValue("layer_value:" + sID);
                        NUI_AddCanvas();
                        {
                            NUI_DrawTriangle(10.0, 8.0, 10.0, 8.0);
                                NUI_SetFill(TRUE);
                                NUI_SetDrawColor(jIndicatorColor);
                                NUI_BindEnabled("layer_indicator_shape_enabled:" + sID);

                            NUI_DrawText(NUI_DefineRectangle(18.0, 5.0, 10.0, 15.0), "");
                                NUI_BindText("layer_text_shape:" + sID);
                                NUI_BindEnabled("layer_text_shape_enabled:" + sID);
                                NUI_SetDrawColor(jTextColor);

                            NUI_DrawCircle(140.0, 13.0, 4.0);
                                NUI_SetFill(TRUE);
                                NUI_SetDrawColor(jIndicatorColor);
                                NUI_BindEnabled("layer_indicator_color_enabled:" + sID);

                            NUI_DrawText(NUI_DefineRectangle(125.0, 5.0, 10.0, 15.0), "");
                                NUI_BindText("layer_text_color:" + sID);
                                NUI_BindEnabled("layer_text_color_enabled:" + sID);
                                NUI_SetDrawColor(jTextColor);
                        } NUI_CloseCanvas();
                }

                NUI_AddColumn();
                    NUI_AddSpacer();
                        NUI_SetWidth(25.0);
                        NUI_SetHeight(95.0);
                        NUI_AddCanvas();
                        {
                            json jWhite = NUI_DefineRGBColor(255, 255, 255);

                            json jPoints = NUI_GetLinePoints(0.0, 12.5, 12.5, 12.5);
                                 jPoints = NUI_AddLinePoint(jPoints, 12.5, 72.5);
                                 jPoints = NUI_AddLinePoint(jPoints, 0.0, 72.5);
                            NUI_DrawLine(jPoints);
                                NUI_SetDrawColor(jWhite);

                            jPoints = NUI_GetLinePoints(0.0, 42.5, 25.0, 42.5);
                            NUI_DrawLine(jPoints);
                                NUI_SetDrawColor(jWhite);
                        } NUI_CloseCanvas();
                NUI_AddColumn();
                    NUI_AddSpacer();
                        NUI_SetHeight(10.0);
                    NUI_AddCommandButton("link_item_models");
                        NUI_SetLabel("Link");
                        NUI_SetMargin(0.0);
                        NUI_SetPadding(0.0);
                        NUI_SetWidth(100.0);
                    NUI_AddSpacer();
                NUI_AddColumn(); NUI_AddSpacer();
            } NUI_CloseControlGroup();

        NUI_AddRow(25.0);
            NUI_AddCommandButton();
                NUI_SetID("previous_shape");
                NUI_SetLabel("Previous");
                NUI_SetWidth(100.0);
            NUI_AddLabel();
                NUI_SetValue(JsonString("Shapes"));
            NUI_AddCommandButton();
                NUI_SetID("next_shape");
                NUI_SetWidth(100.0);
                NUI_SetLabel("Next");
        NUI_AddRow();
            NUI_AddControlGroup();
                NUI_SetID("item_shape_matrix");
                NUI_SetWidth(340.0);
                NUI_SetHeight(150.0);
            {
                NUI_AddSpacer();
            } NUI_CloseControlGroup();

        NUI_AddRow(15.0);

        NUI_AddRow(25.0);
            NUI_AddCommandButton();
                NUI_SetID("previous_color");
                NUI_SetLabel("Previous");
                NUI_SetWidth(100.0);
            NUI_AddLabel();
                NUI_SetValue(JsonString("Colors"));
            NUI_AddCommandButton();
                NUI_SetID("next_color");
                NUI_SetWidth(100.0);
                NUI_SetLabel("Next");
        NUI_AddRow();
            NUI_AddControlGroup();
                NUI_SetID("item_color_matrix");
                NUI_SetHeight(50.0);
            {
                NUI_AddSpacer();
            } NUI_CloseControlGroup();
        NUI_AddRow();
            NUI_AddSpacer();
    } NUI_SaveForm();

    float fWidth = 256.0;
    float fHeight = 400.0;

    sFormID = "_appedit_tab_items_right";
    NUI_CreateForm(sFormID);
    {
        NUI_AddControlGroup();
            NUI_SetHeight(fHeight);
            NUI_SetWidth(fWidth);
        {
            NUI_AddSpacer();
                NUI_AddCanvas();
                {
                    int n;
                    for (n = 0; n < 3; n++)
                    {
                        string sImage = "item_icon:" + IntToString(n);
                        json jRect = NUI_DefineRectangle(0.0, 0.0, fWidth, fHeight);
                        NUI_DrawImage("", jRect, NUI_ASPECT_FIT, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
                            NUI_BindImage(sImage);
                            NUI_BindEnabled("item_icon_enabled:" + IntToString(n));
                    } 
                } NUI_CloseCanvas();
        } NUI_CloseControlGroup();
    } NUI_SaveForm();
}

void CreateAppearanceTabs()
{
    float fHeight = 32.0;

    string sFormID = "_appedit_tab_appearance_left";
    NUI_CreateForm(sFormID);
    {
        NUI_AddRow();
            NUI_AddControlGroup();
                NUI_SetID("color_category_tab");
                NUI_SetHeight(176.0);
                NUI_SetWidth(340.0);
            {
                NUI_AddSpacer();
            } NUI_CloseControlGroup();

        NUI_AddRow();
            NUI_AddControlGroup();
                NUI_SetID("part_category_tab");
                NUI_SetWidth(340.0);
            {
                NUI_AddSpacer();
            } NUI_CloseControlGroup();
    } NUI_SaveForm();

    sFormID = "_appedit_tab_appearance_right";
    NUI_CreateForm(sFormID);
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
                        NUI_SetDrawColor(NUI_DefineRGBColor(255, 255, 0));
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
    } NUI_SaveForm();
}

void NUI_HandleFormDefinition()
{
    InitializeDatabase();
    CreateDefaultProfile();

    float fHeight = 32.0;
    string sFormID = FORM_ID;

    float fLabelHeight = 25.0;
    float fSpacing = 20.0;
    NUI_CreateTemplateControl("cb_label");
    {
        NUI_AddLabel();
            NUI_SetHeight(fLabelHeight);
            NUI_SetMargin(0.0);
            NUI_SetPadding(0.0);
    } NUI_SaveTemplateControl();

    NUI_CreateForm(sFormID, VERSION);
        NUI_SetResizable(TRUE);
        NUI_BindGeometry("formGeometry");
        NUI_SetTitle(TITLE);
        NUI_SetCollapsible(FALSE);
        NUI_SetCustomProperty("toc", jTRUE);
    {
        NUI_AddRow();
            NUI_AddCommandButton("open_loader");
                NUI_SetLabel("Data");
                NUI_SetWidth(75.0);
                NUI_SetHeight(75.0);
                NUI_SetTooltip("Open Model Data Loading Form");
                NUI_BindVisible("showData");
                NUI_BindEnabled("enableData");
                NUI_AddCanvas();
                {
                    NUI_DrawLine(JsonNull());
                        NUI_SetPoints(NUI_GetRectanglePoints(5.0, 5.0, 65.0, 65.0));
                        NUI_SetEnabled(TRUE);
                        NUI_BindDrawColor("data_color");
                        NUI_SetLineThickness(2.0);
                } NUI_CloseCanvas();

            NUI_AddControlGroup();
                NUI_SetOrientation(NUI_ORIENTATION_ROWS);
                NUI_SetBorderVisible(FALSE);
                NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
            {
                string sLabel;

                NUI_AddRow(fSpacing);
                    NUI_AddTemplateControl("cb_label");
                        NUI_BindValue("block_title");
                        NUI_SetRGBForegroundColor(8, 227, 243);
                        NUI_SetWidth(500.0);
                        NUI_BindVisible("showObjectTitle");
                
                NUI_AddRow(fSpacing);
                    NUI_AddTemplateControl("cb_label");
                        NUI_BindValue("block_tl_label");
                        NUI_SetWidth(50.0);
                        NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                        NUI_BindVisible("showObjectDescription");
                    NUI_AddTemplateControl("cb_label");
                        NUI_BindValue("block_tl_value");
                        NUI_SetRGBForegroundColor(45, 151, 185);
                        NUI_SetWidth(140.0);
                        NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                        NUI_BindVisible("showObjectDescription");
                    NUI_AddTemplateControl("cb_label");
                        NUI_BindValue("block_tr_label");
                        NUI_SetWidth(100.0);
                        NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                        NUI_BindVisible("showObjectDescription");
                    NUI_AddTemplateControl("cb_label");
                        NUI_SetWidth(180.0);
                        NUI_BindValue("block_tr_value");
                        NUI_SetRGBForegroundColor(45, 151, 185);
                        NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                        NUI_BindVisible("showObjectDescription");

                    NUI_AddSpacer();

                NUI_AddRow(fSpacing);
                    NUI_AddTemplateControl("cb_label");
                        NUI_BindValue("block_bl_label");
                        NUI_SetWidth(50.0);
                        NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                        NUI_BindVisible("showObjectDescription");
                    NUI_AddTemplateControl("cb_label");
                        NUI_BindValue("block_bl_value");
                        NUI_SetRGBForegroundColor(45, 151, 185);
                        NUI_SetWidth(140.0);
                        NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                        NUI_BindVisible("showObjectDescription");
                    NUI_AddTemplateControl("cb_label");
                        NUI_BindValue("block_br_label");
                        NUI_SetWidth(100.0);
                        NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                        NUI_BindVisible("showObjectDescription");
                    NUI_AddTemplateControl("cb_label");
                        NUI_SetWidth(180.0);
                        NUI_BindValue("block_br_value");
                        NUI_SetRGBForegroundColor(45, 151, 185);
                        NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                        NUI_BindVisible("showObjectDescription");

                    NUI_AddSpacer();
            } NUI_CloseControlGroup();

            NUI_AddImageButton("setTargetObject");
                NUI_SetWidth(75.0);
                NUI_SetHeight(75.0);
                NUI_SetLabel("gui_mp_examineu");
                NUI_SetTooltip("Select Target Object");
                NUI_BindEnabled("enableTargeting");
                NUI_BindVisible("showTargeting");

        NUI_AddRow(25.0);
            NUI_AddCommandButton();
                NUI_SetWidth(75.0);
                NUI_SetLabel("Options");
                NUI_BindEnabled("enableOptions");
                NUI_BindVisible("showOptions");

            NUI_AddLabel();
                NUI_BindValue("message_center_value");
                NUI_BindForegroundColor("message_center_color");
                NUI_BindVisible("showMessageCenter");

            NUI_AddCommandButton("cb_self");
                NUI_SetWidth(75.0);
                NUI_SetLabel("Self");
                NUI_BindEnabled("enableSelf");
                NUI_BindVisible("showSelf");

        NUI_AddRow();
            NUI_AddControlGroup();
                NUI_SetID("left_column");
                NUI_SetBorderVisible(FALSE);
                NUI_SetWidth(350.0);
                NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
            {
                NUI_AddSpacer();
            } NUI_CloseControlGroup();

            NUI_AddControlGroup();
                NUI_SetID("right_column");
                NUI_SetBorderVisible(FALSE);
                NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
            {
                NUI_AddSpacer();
            } NUI_CloseControlGroup();
    } NUI_SaveForm();

    CreateAppearanceTabs(); 
    CreateColorCategoryTabs();
    CreatePartCategoryTabs();
    CreateItemsTabs();
    CreateBlankLayout();

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

    if (sBind == "geometry_handler")
        jReturn = NUI_DefineRectangle(0.0, 0.0, 350.0, 580.0);
    else if (sBind == "handler_type_value")
        jReturn = JsonInt(0);
    else if (sBind == "image_colorsheet_resref")
        jReturn = JsonString(GetColorSheetResref());
    else
    {
        string sKey = NUI_GetKey(sBind);
        if (sKey == "part_cat_enabled")
            jReturn = jTRUE;
        else if (sKey == "part_cat_value" || sKey == "model_matrix_value")
            jReturn = JsonBool(GetPartCategorySelected() == NUI_GetValue(sBind));
        else if (sKey == "color_cat_value")
            jReturn = JsonBool(GetColorCategorySelected() == NUI_GetValue(sBind));
    }

    // Set profile defaults
    if (jReturn == JsonNull() && bSetDefaults == TRUE)
        jReturn = GetFormProfileProperty(sBind);

    if (jReturn != JsonNull())
        NUI_SetBindValue(OBJECT_SELF, nToken, sBind, jReturn);
}

void HandleModuleEvents()
{
    object oItem;
    int nEvent = GetCurrentlyRunningEvent(TRUE);

    if (nEvent == EVENT_SCRIPT_MODULE_ON_EQUIP_ITEM)
    {
        if (GetLocalInt(OBJECT_SELF, "APPEDIT_BLOCK_EQUIP_EVENT") > 0)
        {
            if (DecrementLocalInt("APPEDIT_BLOCK_EQUIP_EVENT") == 0)
                DeleteLocalInt(OBJECT_SELF, "APPEDIT_BLOCK_EQUIP_EVENT");
            return;
        }
        else
            oItem = GetPCItemLastEquipped();
    }
    else if (nEvent == EVENT_SCRIPT_MODULE_ON_UNEQUIP_ITEM)
    {
        if (GetLocalInt(OBJECT_SELF, "APPEDIT_BLOCK_UNEQUIP_EVENT") > 0)
        {
            if (DecrementLocalInt("APPEDIT_BLOCK_UNEQUIP_EVENT") == 0)
                DeleteLocalInt(OBJECT_SELF, "APPEDIT_BLOCK_UNEQUIP_EVENT");
            return;
        }
        else
            oItem = GetPCItemLastUnequipped();
    }
    else if (nEvent == EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM)
    {
        if (GetLocalInt(OBJECT_SELF, "APPEDIT_BLOCK_ACQUIRE_EVENT") > 0)
        {
            if (DecrementLocalInt("APPEDIT_BLOCK_ACQUIRE_EVENT") == 0)
                DeleteLocalInt(OBJECT_SELF, "APPEDIT_BLOCK_ACQUIRE_EVENT");
            return;
        }
        else
            oItem = GetModuleItemAcquired();
    }
    else if (nEvent == EVENT_SCRIPT_MODULE_ON_LOSE_ITEM)
    {
        if (GetLocalInt(OBJECT_SELF, "APPEDIT_BLOCK_UNACQUIRE_EVENT") > 0)
        {
            if (DecrementLocalInt("APPEDIT_BLOCK_UNACQUIRE_EVENT") == 0)
                DeleteLocalInt(OBJECT_SELF, "APPEDIT_BLOCK_UNACQUIRE_EVENT");
            return;
        }
        else
            oItem = GetModuleItemLost();
    }
    else
        return;

    if (GetIsObjectValid(oItem) == TRUE && oItem == GetTargetObject())
    {
        DelayCommand(0.1, PopulateTargetData(oItem, Vector()));
        DisplayCaution("Target object has changed locations");
    }
}

void NUI_HandleFormBinds(string sProfileName)
{
    SetFormProfile(sProfileName);

    object oTarget;
    json jTargetObject = GetFormProfileProperty("targetObjectVariable");
    if (jTargetObject != JsonNull())
        oTarget = GetLocalObject(OBJECT_SELF, JsonGetString(jTargetObject));
    else
    {
        jTargetObject = GetFormProfileProperty("targetObjectString");
        if (jTargetObject != JsonNull())
            oTarget = StringToObject(JsonGetString(jTargetObject));
        else
            oTarget = OBJECT_SELF;
    }

    SetTargetObject(oTarget);

    struct NUIBindData bd = NUI_GetBindData();

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

    if (ed.sFormID == "appearance_editor_loader")
    {
        if (ed.sEvent == "click")
        {
            int nType = JsonGetInt(NUI_GetBindValue(ed.oPC, ed.nFormToken, "handler_type_value"));

            string sFunction = NUI_GetKey(ed.sControlID);
            string sType = NUI_GetValue(ed.sControlID);

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
                string sValue = NUI_GetValue(ed.sControlID);
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
        string sKey = NUI_GetKey(ed.sControlID);

        if (sKey == "part_cat" || sKey == "color_cat")
        {
            string sValue = NUI_GetValue(ed.sControlID);
            if (GetIndicatorStatus(sValue) == TRUE)
            {
                json jX = JsonObjectGet(JsonObjectGet(ed.jPayload, "mouse_pos"), "x");
                if (JsonGetFloat(jX) <= 20.0)
                    DeletePerPartColor(sKey, sValue);
            }

            if (sKey == "part_cat")
                OnSelectPartCategory(NUI_GetValue(ed.sControlID));
            else
                OnSelectColorCategory(NUI_GetValue(ed.sControlID));
        }
        else if (sKey == "model_matrix")
        {  
            string sValue = NUI_GetValue(ed.sControlID);
            if (sValue != "")
                OnSelectPart(sValue);
        }
        else if (sKey == "layer")
            OnSelectLayer(NUI_GetValue(ed.sControlID));
        else if (sKey == "shape_matrix")
            OnSelectItemShape(NUI_GetValue(ed.sControlID));
        else if (sKey == "color_matrix")
            OnSelectItemColor(NUI_GetValue(ed.sControlID));
        else if (ed.sControlID == "button_previous")
            OnPreviousPart();
        else if (ed.sControlID == "button_next")
            OnNextPart();
        else if (ed.sControlID == "image_colorsheet")
            OnSelectColor(ed.jPayload);
        else if (ed.sControlID == "previous_shape")
            OnPreviousShape();
        else if (ed.sControlID == "next_shape")
            OnNextShape();
        else if (ed.sControlID == "previous_color")
            OnPreviousColor();
        else if (ed.sControlID == "next_color")
            OnNextColor();
        else if (ed.sControlID == "link_item_models")
            OnLinkItemModels();
    }
}
