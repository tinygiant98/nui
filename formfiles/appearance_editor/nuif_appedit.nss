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

const string VERSION = "1.0.0";

const string PROPERTIES = "APPEARANCE_PROPERTIES";

void ToggleItemEquippedFlags();
void LoadColorCategoryOptions();
void LoadPartCategoryOptions();
void LoadItemParts();
object GetItem();
void UpdateBinds(string sBind, int nToken = -1, int bSetDefaults = FALSE);
json GetRaceAppearanceFromDatabase(int nGender, int nRace, int nPhenotype, string sPart);
json GetHelmetsFromDatabase();

void app_SetProperty(string sProperty, json jValue)
{
    json jProperties = GetLocalJson(OBJECT_SELF, PROPERTIES);

    if (jProperties == JsonNull())
        jProperties = JsonObject();

    jProperties = JsonObjectSet(jProperties, sProperty, jValue);
    SetLocalJson(OBJECT_SELF, PROPERTIES, jProperties);
}

json app_GetProperty(string sProperty)
{
    json jProperties = GetLocalJson(OBJECT_SELF, PROPERTIES);
    return JsonObjectGet(jProperties, sProperty);
}

int  GetItemCanBeEquipped() { return JsonGetInt(app_GetProperty("canEquipItem")); }
void SetItemCanBeEquipped(int bEquipable)
{
    app_SetProperty("canEquipItem", JsonInt(bEquipable));
    UpdateBinds("label_item_visible");
    UpdateBinds("label_item_label");
}


int  GetIsAppearanceSelected() { return JsonGetInt(app_GetProperty("isAppearanceSelected")); }
void SetIsAppearanceSelected(int bSelected)
{
    app_SetProperty("isAppearanceSelected", JsonInt(bSelected));
    UpdateBinds("toggle_appearance_toggled");
    UpdateBinds("toggle_equipment_toggled");
    UpdateBinds("combo_type_visible");
}

int  GetIsEquipmentSelected()              { return !JsonGetInt(app_GetProperty("isAppearanceSelected")); }
void SetIsEquipmentSelected(int bSelected) { SetIsAppearanceSelected(!bSelected); }

string GetColorSheetResref() { return JsonGetString(app_GetProperty("colorSheetResref")); }
void   SetColorSheetResref(string sResref) 
{ 
    app_SetProperty("colorSheetResref", JsonString(sResref));
    UpdateBinds("image_colorsheet_resref");
}

int  GetHasItemEquipped()         { return JsonGetInt(app_GetProperty("hasItemEquipped")); }
int  GetDoesNotHaveItemEquipped() { return !JsonGetInt(app_GetProperty("hasItemEquipped")); }
void SetHasItemEquipped(int bEquipped)
{
    app_SetProperty("hasItemEquipped", JsonInt(bEquipped));
    UpdateBinds("label_item_visible");
}

json GetColorCategoryOptions() { return app_GetProperty("colorCategoryOptions"); }
void SetColorCategoryOptions(json jOptions) 
{
    app_SetProperty("colorCategoryOptions", jOptions);
    UpdateBinds("toggle_colorcategory_label");
    UpdateBinds("list_colorcategory_rowcount");
}

json GetPartCategoryOptions() { return app_GetProperty("partCategoryOptions"); }
void SetPartCategoryOptions(json jOptions)
{
    app_SetProperty("partCategoryOptions", jOptions);
    UpdateBinds("toggle_partcategory_label");
    UpdateBinds("list_partcategory_rowcount");
}

json GetPartCategorySelected() { return app_GetProperty("partCategorySelected"); }
void SetPartCategorySelected(json jSelected, int nIndex = -1, int bSelected = TRUE)
{ 
    if (nIndex == -1)
    {
        app_SetProperty("partCategorySelected", jSelected);
        UpdateBinds("toggle_partcategory_value");
    }
    else
    {
        json jSelect = GetPartCategorySelected();
             jSelect = JsonArraySet(jSelect, nIndex, JsonBool(bSelected));

        if (bSelected == FALSE)
            app_SetProperty("partCategorySelected", jSelect);
        else
            SetPartCategorySelected(jSelect);
    }
}

json GetColorCategorySelected() { return app_GetProperty("colorCategorySelected"); }
void SetColorCategorySelected(json jSelected, int nIndex = -1, int bSelected = TRUE)
{ 
    if (nIndex == -1)
    {
        app_SetProperty("colorCategorySelected", jSelected);
        UpdateBinds("toggle_colorcategory_value");
    }
    else
    {
        json jSelect = GetColorCategorySelected();
             jSelect = JsonArraySet(jSelect, nIndex, JsonBool(bSelected));
        
        if (bSelected == FALSE)
            app_SetProperty("colorCategorySelected", jSelect);
        else
            SetColorCategorySelected(jSelect);
    }
}

int  GetSelectedColorCategoryIndex() { return JsonGetInt(app_GetProperty("selectedColorCategoryIndex")); }
void SetSelectedColorCategoryIndex(int nIndex)
{
    SetColorCategorySelected(JsonNull(), GetSelectedColorCategoryIndex(), FALSE);
    SetColorCategorySelected(JsonNull(), nIndex, TRUE);

    app_SetProperty("selectedColorCategoryIndex", JsonInt(nIndex));

    string sAppearanceResrefs = "skin,hair01,tattoo,tattoo";
    string sEquipmentResrefs = "tattoo,tattoo,tattoo,tattoo,armor01,armor01";
    string sResrefs, sPrefix = "gui_pal_";

    if (GetIsAppearanceSelected())
        sResrefs = sAppearanceResrefs;
    else if (GetIsEquipmentSelected())
        sResrefs = sEquipmentResrefs;

    SetColorSheetResref(sPrefix + GetListItem(sResrefs, nIndex));
}

int  GetSelectedItemTypeIndex() { return JsonGetInt(app_GetProperty("selectedItemTypeIndex")); }
void SetSelectedItemTypeIndex(int nIndex = 0)
{
    app_SetProperty("selectedItemTypeIndex", JsonInt(nIndex));

    ToggleItemEquippedFlags();
    LoadColorCategoryOptions();
    LoadPartCategoryOptions();
    LoadItemParts();

    UpdateBinds("group_category_visible");
    UpdateBinds("label_item_label");
}

int  GetSelectedPartCategoryIndex() { return JsonGetInt(app_GetProperty("selectedPartCategoryIndex")); }
void SetSelectedPartCategoryIndex(int nIndex) 
{ 
    SetPartCategorySelected(JsonNull(), GetSelectedPartCategoryIndex(), FALSE);
    SetPartCategorySelected(JsonNull(), nIndex, TRUE);

    app_SetProperty("selectedPartCategoryIndex", JsonInt(nIndex));
}

json GetPartOptions() { return app_GetProperty("partOptions"); }
void SetPartOptions(json jOptions)
{ 
    app_SetProperty("partOptions", jOptions); 
    
    UpdateBinds("toggle_partselected_label");
    UpdateBinds("list_partselected_rowcount");
}

json GetPartSelected() { return app_GetProperty("partSelected"); }
void SetPartSelected(json jSelected, int nIndex = -1, int bSelected = TRUE)
{
    if (nIndex == -1)
    {
        app_SetProperty("partSelected", jSelected);
        UpdateBinds("toggle_partselected_value");
    }
    else
    {
        json jSelect = GetPartSelected();
             jSelect = JsonArraySet(jSelect, nIndex, JsonBool(bSelected));

        if (bSelected == FALSE)
            app_SetProperty("partSelected", jSelect);
        else
            SetPartSelected(jSelect);
    }  
}

int  GetSelectedPartIndex() { return JsonGetInt(app_GetProperty("selectedPartIndex")); }
void SetSelectedPartIndex(int nIndex)
{ 
    SetPartSelected(JsonNull(), GetSelectedPartIndex(), FALSE);
    SetPartSelected(JsonNull(), nIndex, TRUE);
    
    app_SetProperty("selectedPartIndex", JsonInt(nIndex));
}

json GetPartIDToIndex()            { return app_GetProperty("partIDToIndex"); }
void SetPartIDToIndex(json jArray) { app_SetProperty("partIDToIndex", jArray); }

void ToggleItemEquippedFlags()
{
    SetHasItemEquipped(GetIsAppearanceSelected() || GetIsObjectValid(GetItem()));
}

void LoadColorCategoryOptions()
{
    if (GetDoesNotHaveItemEquipped())
        return;

    string sAppearance, sBuild = SKIN + "," + HAIR + "," + TATTOO + " 1," + TATTOO + " 2";
    
    string sPrimary = ADJECTIVE_FOLLOWS == TRUE ? COLOR : sBuild;
    string sSecondary = ADJECTIVE_FOLLOWS == TRUE ? sBuild : COLOR;
    
    int p, s, pCount = CountList(sPrimary), sCount = CountList(sSecondary);
    for (p = 0; p < pCount; p++)
    {
        for (s = 0; s < sCount; s++)
        {
            string sLeft = GetListItem(sPrimary, p);
            string sRight = GetListItem(sSecondary, s);

            sAppearance = AddListItem(sAppearance, sLeft + " " + sRight);
        }
    }

    string sEquipment;
    sBuild = LEATHER + " 1," + LEATHER + " 2," +
             CLOTH   + " 1," + CLOTH   + " 2," +
             METAL   + " 1," + METAL   + " 2";

    sPrimary = ADJECTIVE_FOLLOWS == TRUE ? COLOR : sBuild;
    sSecondary = ADJECTIVE_FOLLOWS == TRUE ? sBuild : COLOR;
    
    pCount = CountList(sPrimary);
    sCount = CountList(sSecondary);
    for (p = 0; p < pCount; p++)
    {
        for (s = 0; s < sCount; s++)
        {
            string sLeft = GetListItem(sPrimary, p);
            string sRight = GetListItem(sSecondary, s);

            sEquipment = AddListItem(sEquipment, sLeft + " " + sRight);
        }
    }

    string sOptions;

    if (GetIsAppearanceSelected())
        sOptions = sAppearance;
    else if (GetIsEquipmentSelected())
        sOptions = sEquipment;

    json jOptions = JsonArray();
    json jSelected = JsonArray();

    int n, nCount = CountList(sOptions);
    for (n = 0; n < nCount; n++)
    {
        jOptions = JsonArrayInsert(jOptions, JsonString(GetListItem(sOptions, n)));
        jSelected = JsonArrayInsert(jSelected, JsonBool(FALSE));
    }

    SetColorCategoryOptions(jOptions);
    SetColorCategorySelected(jSelected);
    SetSelectedColorCategoryIndex(0);
}

void LoadPartCategoryOptions()
{
    if (GetDoesNotHaveItemEquipped())
        return;

    string sSides = RIGHT + "," + LEFT;
    string sSharedParts = BICEP + "," + FOREARM + "," + HAND + "," + THIGH + "," + SHIN + "," + FOOT;
    string sShoulders = SHOULDER;

    if (GetIsEquipmentSelected())
        sSharedParts = MergeLists(sShoulders, sSharedParts);

    string sAppearance = HEAD + "," + CHEST + "," + PELVIS;
    string sArmor = NECK + "," + CHEST + "," + BELT + "," + PELVIS;
    string sHelmet = HELMET;

    string sPrimary = ADJECTIVE_FOLLOWS == TRUE ? sSharedParts : sSides;
    string sSecondary = ADJECTIVE_FOLLOWS == TRUE ? sSides : sSharedParts;

    int p, s, pCount = CountList(sPrimary), sCount = CountList(sSecondary);
    for (p = 0; p < pCount; p++)
    {
        for (s = 0; s < sCount; s++)
        {
            string sLeft = GetListItem(sPrimary, p);
            string sRight = GetListItem(sSecondary, s);

            if (ADJECTIVE_FOLLOWS == TRUE ? p < pCount - 1 : s < sCount - 1)
                sAppearance = AddListItem(sAppearance, sLeft + " " + sRight);
            
            sArmor = AddListItem(sArmor, sLeft + " " + sRight);
        }
    }

    sArmor = AddListItem(sArmor, ROBE);

    string sOptions;

    if (GetIsAppearanceSelected())
        sOptions = sAppearance;
    else if (GetIsEquipmentSelected())
    {
        int nIndex = GetSelectedItemTypeIndex();
        if (nIndex == 0)
            sOptions = sArmor;
        else if (nIndex == 1)
            sOptions = sHelmet;
    }

    json jOptions = JsonArray();
    json jSelected = JsonArray();

    int n, nCount = CountList(sOptions);
    for (n = 0; n < nCount; n++)
    {
        jOptions = JsonArrayInsert(jOptions, JsonString(GetListItem(sOptions, n)));
        jSelected = JsonArrayInsert(jSelected, JsonBool(FALSE));
    }

    SetPartCategoryOptions(jOptions);
    SetPartCategorySelected(jSelected);
    SetSelectedPartCategoryIndex(0);
}

json GetPartLists(json jPartIDs)
{
    json jPartNames = JsonArray();
    json jPartSelected = JsonArray();
    json jPartIDToIndex = JsonObject();
    json jReturn = JsonObject();
    int nIndex = 0;

    int n, nCount = JsonGetLength(jPartIDs);
    for (n = 0; n < nCount; n++)
    {
        int nPartID = JsonGetInt(JsonArrayGet(jPartIDs, n));
        jPartNames = JsonArrayInsert(jPartNames, JsonString(MODEL + " #" + IntToString(nPartID)));
        jPartSelected = JsonArrayInsert(jPartSelected, JsonBool(FALSE));
        jPartIDToIndex = JsonObjectSet(jPartIDToIndex, IntToString(nPartID), JsonInt(nIndex++));
    }

    jReturn = JsonObjectSet(jReturn, "partNames", jPartNames);
    jReturn = JsonObjectSet(jReturn, "partSelected", jPartSelected);
    SetPartIDToIndex(jPartIDToIndex);

    return jReturn;
}

object GetItem()
{
    if (GetSelectedItemTypeIndex() == 0)
        return GetItemInSlot(INVENTORY_SLOT_CHEST, OBJECT_SELF);
    else if (GetSelectedItemTypeIndex() == 1)
        return GetItemInSlot(INVENTORY_SLOT_HEAD, OBJECT_SELF);

    return OBJECT_INVALID;
}

void LoadBodyParts()
{
    object oPC = OBJECT_SELF;
    int nRace = GetRacialType(oPC);
    int nGender = GetGender(oPC);
    int nPhenotype = GetPhenoType(oPC);

    int nSelectedPartID, nPart;
    string sPart;

    switch (GetSelectedPartCategoryIndex())
    {
        case 0: nPart = CREATURE_PART_HEAD; sPart = "head"; break;
        case 1: nPart = CREATURE_PART_TORSO; sPart = "chest"; break;
        case 2: nPart = CREATURE_PART_PELVIS; sPart = "pelvis"; break;
        case 3: nPart = CREATURE_PART_RIGHT_BICEP; sPart = "bicepr"; break;
        case 4: nPart = CREATURE_PART_RIGHT_FOREARM; sPart = "forer"; break;
        case 5: nPart = CREATURE_PART_RIGHT_HAND; sPart = "handr"; break;
        case 6: nPart = CREATURE_PART_RIGHT_THIGH; sPart = "legr"; break;
        case 7: nPart = CREATURE_PART_RIGHT_SHIN; sPart = "shinr"; break;
        case 8: nPart = CREATURE_PART_LEFT_BICEP; sPart = "bicepl"; break;
        case 9: nPart = CREATURE_PART_LEFT_FOREARM; sPart = "forel"; break;
        case 10: nPart = CREATURE_PART_LEFT_HAND; sPart = "handl"; break;
        case 11: nPart = CREATURE_PART_LEFT_THIGH; sPart = "legl"; break;
        case 12: nPart = CREATURE_PART_LEFT_SHIN; sPart = "shinl"; break;
    }

    //json jPartIDs = JsonObjectGet(jAppearance, sPart);
    json jPartIDs = GetRaceAppearanceFromDatabase(nGender, nRace, nPhenotype, sPart);
    json jPartLists = GetPartLists(jPartIDs);
    
    nSelectedPartID = GetCreatureBodyPart(nPart, oPC);

    SetPartOptions(JsonObjectGet(jPartLists, "partNames"));
    SetPartSelected(JsonObjectGet(jPartLists, "partSelected"));
    SetSelectedPartIndex(JsonGetInt(JsonObjectGet(GetPartIDToIndex(), IntToString(nSelectedPartID))));
}

void LoadItemParts()
{
    if (GetDoesNotHaveItemEquipped())
        return;

    int nSelectedPartID, nIndex;
    object oItem = GetItem();
    string sPart;
    json jPartIDs;

    if (GetSelectedItemTypeIndex() == 0)
    {
        switch (GetSelectedPartCategoryIndex())
        {
            case 0: nIndex = ITEM_APPR_ARMOR_MODEL_NECK; sPart = "neck"; break;
            case 1: nIndex = ITEM_APPR_ARMOR_MODEL_TORSO; sPart = "chest"; break;
            case 2: nIndex = ITEM_APPR_ARMOR_MODEL_BELT; sPart = "belt"; break;
            case 3: nIndex = ITEM_APPR_ARMOR_MODEL_PELVIS; sPart = "pelvis"; break;
            case 4: nIndex = ITEM_APPR_ARMOR_MODEL_RSHOULDER; sPart = "shor"; break;
            case 5: nIndex = ITEM_APPR_ARMOR_MODEL_RBICEP; sPart = "bicepr"; break;
            case 6: nIndex = ITEM_APPR_ARMOR_MODEL_RFOREARM; sPart = "forer"; break;
            case 7: nIndex = ITEM_APPR_ARMOR_MODEL_RHAND; sPart = "handr"; break;
            case 8: nIndex = ITEM_APPR_ARMOR_MODEL_RTHIGH; sPart = "legr"; break;
            case 9: nIndex = ITEM_APPR_ARMOR_MODEL_RSHIN; sPart = "shinr"; break;
            case 10: nIndex = ITEM_APPR_ARMOR_MODEL_RFOOT; sPart = "footr"; break;
            case 11: nIndex = ITEM_APPR_ARMOR_MODEL_LSHOULDER; sPart = "shol"; break;
            case 12: nIndex = ITEM_APPR_ARMOR_MODEL_LBICEP; sPart = "bicepl"; break;
            case 13: nIndex = ITEM_APPR_ARMOR_MODEL_LFOREARM; sPart = "forel"; break;
            case 14: nIndex = ITEM_APPR_ARMOR_MODEL_LHAND; sPart = "handl"; break;
            case 15: nIndex = ITEM_APPR_ARMOR_MODEL_LTHIGH; sPart = "legl"; break;
            case 16: nIndex = ITEM_APPR_ARMOR_MODEL_LSHIN; sPart = "shinl"; break;
            case 17: nIndex = ITEM_APPR_ARMOR_MODEL_LFOOT; sPart = "footl"; break;
            case 18: nIndex = ITEM_APPR_ARMOR_MODEL_ROBE; sPart = "robe"; break;
        }

        int nGender = GetGender(OBJECT_SELF);
        int nRace = GetRacialType(OBJECT_SELF);
        int nPhenotype = GetPhenoType(OBJECT_SELF);
        jPartIDs = GetRaceAppearanceFromDatabase(nGender, nRace, nPhenotype, sPart);

        nSelectedPartID = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, nIndex);
    }
    else if (GetSelectedItemTypeIndex() == 1)
    {
        sPart = "helmet";
        jPartIDs = GetHelmetsFromDatabase();
        nSelectedPartID = GetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, -1);
    }

    json jPartLists = GetPartLists(jPartIDs);

    SetPartOptions(JsonObjectGet(jPartLists, "partNames"));
    SetPartSelected(JsonObjectGet(jPartLists, "partSelected"));
    SetSelectedPartIndex(JsonGetInt(JsonObjectGet(GetPartIDToIndex(), IntToString(nSelectedPartID))));
}

void OnSelectAppearance()
{
    SetIsAppearanceSelected(TRUE);
    ToggleItemEquippedFlags();

    LoadColorCategoryOptions();
    LoadPartCategoryOptions();
    SetSelectedColorCategoryIndex(0);

    UpdateBinds("group_category_visible");
}

void OnSelectEquipment()
{
    SetIsAppearanceSelected(FALSE);
    ToggleItemEquippedFlags();

    LoadColorCategoryOptions();
    LoadPartCategoryOptions();
    LoadItemParts();
    SetSelectedColorCategoryIndex(0);

    UpdateBinds("group_category_visible");
}

void OnSelectColorCategory(int nIndex)
{
    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    SetSelectedColorCategoryIndex(nIndex);
}

void OnSelectPartCategory(int nIndex)
{
    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    SetSelectedPartCategoryIndex(nIndex);

    if (GetIsAppearanceSelected())
        LoadBodyParts();
    else if (GetIsEquipmentSelected())
        LoadItemParts();
}

void OnSelectItemType(int nIndex)
{
    SetSelectedItemTypeIndex(nIndex);
}

void ModifyItemColor(int nColorChannel, int nColorID)
{
    object oPC = OBJECT_SELF;

    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    int nSlot = GetSelectedItemTypeIndex() == 0 ? INVENTORY_SLOT_CHEST : INVENTORY_SLOT_HEAD;
    object oItem = GetItem();
    object oCopy = CopyItemAndModify(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, nColorChannel, nColorID, TRUE);

    DestroyObject(oItem);
    AssignCommand(oPC, ActionEquipItem(oCopy, nSlot));
}

int CanPCEquipItem(object oPC, object oItem)
{
    int nAC = GetItemACValue(oItem);
    if (nAC > 0)
    {
        int nFeat = nAC >= 6 ? FEAT_ARMOR_PROFICIENCY_HEAVY :
                    nAC >= 4 ? FEAT_ARMOR_PROFICIENCY_MEDIUM :
                               FEAT_ARMOR_PROFICIENCY_LIGHT;

        return GetHasFeat(nFeat, oPC);
    }

    return TRUE;
}

void ModifyItemPart(int nPart, int nPartID, int nPreviousPart = -1)
{
    object oPC = OBJECT_SELF;

    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    int nSlot = GetSelectedItemTypeIndex() == 0 ? INVENTORY_SLOT_CHEST : INVENTORY_SLOT_HEAD;
    object oItem = GetItem();
    int nModelType = GetSelectedItemTypeIndex() == 0 ? ITEM_APPR_TYPE_ARMOR_MODEL : ITEM_APPR_TYPE_SIMPLE_MODEL;
    object oCopy = CopyItemAndModify(oItem, nModelType, nPart, nPartID);

    if (CanPCEquipItem(oPC, oCopy) == FALSE)
    {
        SetItemCanBeEquipped(FALSE);
        DelayCommand(3.0, SetItemCanBeEquipped(TRUE));
        SetSelectedPartIndex(nPreviousPart);
        DestroyObject(oCopy);
        return;
    }

    SetItemCanBeEquipped(TRUE);

    DestroyObject(oItem);
    AssignCommand(oPC, ActionEquipItem(oCopy, nSlot));
}

void OnSelectColor(json jPayload)
{
    object oPC = OBJECT_SELF;
    int COLOR_WIDTH_CELLS = 16;
    int COLOR_HEIGHT_CELLS = 11;

    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    float fScale = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE) / 100.0;
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

    int nChannel, nColorID = nCellX + nCellY * COLOR_WIDTH_CELLS;

    if (GetIsAppearanceSelected())
    {
        switch (GetSelectedColorCategoryIndex())
        {
            case 0: nChannel = COLOR_CHANNEL_SKIN; break;
            case 1: nChannel = COLOR_CHANNEL_HAIR; break;
            case 2: nChannel = COLOR_CHANNEL_TATTOO_1; break;
            case 3: nChannel = COLOR_CHANNEL_TATTOO_2; break;
        }

        SetColor(oPC, nChannel, nColorID);
    }
    else if (GetIsEquipmentSelected())
    {
        switch (GetSelectedColorCategoryIndex())
        {
            case 0: nChannel = ITEM_APPR_ARMOR_COLOR_LEATHER1; break;
            case 1: nChannel = ITEM_APPR_ARMOR_COLOR_LEATHER2; break;
            case 2: nChannel = ITEM_APPR_ARMOR_COLOR_CLOTH1; break;
            case 3: nChannel = ITEM_APPR_ARMOR_COLOR_CLOTH2; break;
            case 4: nChannel = ITEM_APPR_ARMOR_COLOR_METAL1; break;
            case 5: nChannel = ITEM_APPR_ARMOR_COLOR_METAL2; break;
        }

        ModifyItemColor(nChannel, nColorID);
    }
}

void LoadBodyPart()
{
    object oPC = OBJECT_SELF;

    int nRace = GetRacialType(oPC);
    int nGender = GetGender(oPC);
    int nPhenotype = GetPhenoType(oPC);
    string sPart;
    int nPart, nModel;

    switch (GetSelectedPartCategoryIndex())
    {
        case 0: nPart = CREATURE_PART_HEAD; sPart = "head"; break;
        case 1: nPart = CREATURE_PART_TORSO; sPart = "chest"; break;
        case 2: nPart = CREATURE_PART_PELVIS; sPart = "pelvis"; break;
        case 3: nPart = CREATURE_PART_RIGHT_BICEP; sPart = "bicepr"; break;
        case 4: nPart = CREATURE_PART_RIGHT_FOREARM; sPart = "forer"; break;
        case 5: nPart = CREATURE_PART_RIGHT_HAND; sPart = "handr"; break;
        case 6: nPart = CREATURE_PART_RIGHT_THIGH; sPart = "legr"; break;
        case 7: nPart = CREATURE_PART_RIGHT_SHIN; sPart = "shinr"; break;
        case 8: nPart = CREATURE_PART_LEFT_BICEP; sPart = "bicepl"; break;
        case 9: nPart = CREATURE_PART_LEFT_FOREARM; sPart = "forel"; break;
        case 10: nPart = CREATURE_PART_LEFT_HAND; sPart = "handl"; break;
        case 11: nPart = CREATURE_PART_LEFT_THIGH; sPart = "legl"; break;
        case 12: nPart = CREATURE_PART_LEFT_SHIN; sPart = "shinl"; break;
    }

    json jPartIDs = GetRaceAppearanceFromDatabase(nGender, nRace, nPhenotype, sPart);

    nModel = JsonGetInt(JsonArrayGet(jPartIDs, GetSelectedPartIndex()));
    SetCreatureBodyPart(nPart, nModel, oPC);
}

void LoadArmorPart(int nPreviousPart = -1)
{
    ToggleItemEquippedFlags();
    if (GetDoesNotHaveItemEquipped())
        return;

    string sPart;
    int nIndex, nSelectedPartID;

    if (GetSelectedItemTypeIndex() == 0)
    {
        switch (GetSelectedPartCategoryIndex())
        {
            case 0: nIndex = ITEM_APPR_ARMOR_MODEL_NECK; sPart = "neck"; break;
            case 1: nIndex = ITEM_APPR_ARMOR_MODEL_TORSO; sPart = "chest"; break;
            case 2: nIndex = ITEM_APPR_ARMOR_MODEL_BELT; sPart = "belt"; break;
            case 3: nIndex = ITEM_APPR_ARMOR_MODEL_PELVIS; sPart = "pelvis"; break;
            case 4: nIndex = ITEM_APPR_ARMOR_MODEL_RSHOULDER; sPart = "shor"; break;
            case 5: nIndex = ITEM_APPR_ARMOR_MODEL_RBICEP; sPart = "bicepr"; break;
            case 6: nIndex = ITEM_APPR_ARMOR_MODEL_RFOREARM; sPart = "forer"; break;
            case 7: nIndex = ITEM_APPR_ARMOR_MODEL_RHAND; sPart = "handr"; break;
            case 8: nIndex = ITEM_APPR_ARMOR_MODEL_RTHIGH; sPart = "legr"; break;
            case 9: nIndex = ITEM_APPR_ARMOR_MODEL_RSHIN; sPart = "shinr"; break;
            case 10: nIndex = ITEM_APPR_ARMOR_MODEL_RFOOT; sPart = "footr"; break;
            case 11: nIndex = ITEM_APPR_ARMOR_MODEL_LSHOULDER; sPart = "shol"; break;
            case 12: nIndex = ITEM_APPR_ARMOR_MODEL_LBICEP; sPart = "bicepl"; break;
            case 13: nIndex = ITEM_APPR_ARMOR_MODEL_LFOREARM; sPart = "forel"; break;
            case 14: nIndex = ITEM_APPR_ARMOR_MODEL_LHAND; sPart = "handl"; break;
            case 15: nIndex = ITEM_APPR_ARMOR_MODEL_LTHIGH; sPart = "legl"; break;
            case 16: nIndex = ITEM_APPR_ARMOR_MODEL_LSHIN; sPart = "shinl"; break;
            case 17: nIndex = ITEM_APPR_ARMOR_MODEL_LFOOT; sPart = "footl"; break;
            case 18: nIndex = ITEM_APPR_ARMOR_MODEL_ROBE; sPart = "robe"; break;
        }

        int nGender = GetGender(OBJECT_SELF);
        int nRace = GetRacialType(OBJECT_SELF);
        int nPhenotype = GetPhenoType(OBJECT_SELF);
        json jPartIDs = GetRaceAppearanceFromDatabase(nGender, nRace, nPhenotype, sPart);

        nSelectedPartID = JsonGetInt(JsonArrayGet(jPartIDs, GetSelectedPartIndex()));

        ModifyItemPart(nIndex, nSelectedPartID, nPreviousPart);
    }
    else if (GetSelectedItemTypeIndex() == 1)
    {
        sPart = "helmet";
        nSelectedPartID = JsonGetInt(JsonArrayGet(GetHelmetsFromDatabase(), GetSelectedPartIndex()));
        ModifyItemPart(-1, nSelectedPartID);
    }
}

void LoadPart(int nPreviousPart = -1)
{
    if (GetIsAppearanceSelected())
        LoadBodyPart();
    else if (GetIsEquipmentSelected())
        LoadArmorPart(nPreviousPart);
}

void OnSelectPart(int nIndex)
{
    int nPreviousPart = GetSelectedPartIndex();
    SetSelectedPartIndex(nIndex);
    LoadPart(nPreviousPart);
}

void OnPreviousPart()
{
    int nNewPartIndex = GetSelectedPartIndex() - 1;
    nNewPartIndex = max(0, nNewPartIndex);

    OnSelectPart(nNewPartIndex);
}

void OnNextPart()
{
    int nNewPartIndex = GetSelectedPartIndex() + 1;
    nNewPartIndex = min(nNewPartIndex, JsonGetLength(GetPartIDToIndex()) - 1);

    OnSelectPart(nNewPartIndex);
}

void OnFormOpen()
{
    SetIsAppearanceSelected(TRUE);
    ToggleItemEquippedFlags();
    LoadColorCategoryOptions();
    LoadPartCategoryOptions();
    SetSelectedColorCategoryIndex(0);
    SetSelectedPartCategoryIndex(0);
    SetSelectedPartIndex(0);
    SetSelectedItemTypeIndex(0);
    LoadBodyParts();
    SetItemCanBeEquipped(TRUE);
}

void OnFormClose()
{
    DeleteLocalJson(OBJECT_SELF, PROPERTIES);
}

void InitializedDatabase()
{
    sQuery = "CREATE TABLE IF NOT EXISTS " + DATABASE_TABLE + " (" +
        "gender TEXT, " +
        "race TEXT, " +
        "phenotype TEXT, " +
        "part TEXT, " +
        "models TEXT, " +
        "PRIMARY KEY (gender, race, phenotype, part));";
    sql = NUI_PrepareQuery(sQuery, USE_CAMPAIGN_DATABASE, CAMPAIGN_DATABASE);
    SqlStep(sql);
}

json SortJsonArray(json jArray)
{
    int n, x, nIndex, nCount = JsonGetLength(jArray);

    if (nCount <= 1)
        return jArray;

    for (n = 0; n < nCount; n++)
    {
        nIndex = n;
        for (x = n + 1; x < nCount; x++)
        {
            int n1 = JsonGetInt(JsonArrayGet(jArray, x));
            int n2 = JsonGetInt(JsonArrayGet(jArray, nIndex));

            if (n1 < n2)
                nIndex = x;
        }
        
        json jTemp = JsonArrayGet(jArray, nIndex);
        jArray = JsonArraySet(jArray, nIndex, JsonArrayGet(jArray, n));
        jArray = JsonArraySet(jArray, n, jTemp);
    }

    return jArray;
}

void AddRaceAppearanceToDatabase(string sGender, string sRace, string sPhenotype,
                                 string sPart, json jModels)
{
    sQuery = "INSERT INTO " + DATABASE_TABLE + " (gender, race, phenotype, part, models) " +
            "VALUES (@gender, @race, @phenotype, @part, @models) " +
            "ON CONFLICT (gender, race, phenotype, part) DO UPDATE SET models = @models;";
    sql = NUI_PrepareQuery(sQuery, USE_CAMPAIGN_DATABASE, CAMPAIGN_DATABASE);
    SqlBindString(sql, "@gender", sGender);
    SqlBindString(sql, "@race", sRace);
    SqlBindString(sql, "@phenotype", sPhenotype);
    SqlBindString(sql, "@part", sPart);
    SqlBindJson(sql, "@models", SORT_MODEL_ARRAYS ? SortJsonArray(jModels) : jModels);

    SqlStep(sql);

    SetLocalInt(GetModule(), "APPEARANCE_COUNT", GetLocalInt(GetModule(), "APPEARANCE_COUNT") - 1);
    if (GetLocalInt(GetModule(), "APPEARANCE_COUNT") == 0)
        Notice("Appearance loading complete.");
}

json GetRaceAppearanceFromDatabase(int nGender, int nRace, int nPhenotype, string sPart)
{
    string sGender = nGender == -1 ? "" : nGender == 0 ? "m" : "f";
    string sRace = nRace == -1 ? "" : GetStringLowerCase(Get2DAString("appearance", "race", nRace));
    string sPhenotype = nPhenotype == -1 ? "" : IntToString(nPhenotype);

    sQuery = "SELECT models " +
             "FROM " + DATABASE_TABLE + " " +
             "WHERE gender = @gender " +
                "AND race = @race " +
                "AND phenotype = @phenotype " +
                "AND part = @part;";
    sql = NUI_PrepareQuery(sQuery, USE_CAMPAIGN_DATABASE, CAMPAIGN_DATABASE);
    SqlBindString(sql, "@gender", sGender);
    SqlBindString(sql, "@race", sRace);
    SqlBindString(sql, "@phenotype", sPhenotype);
    SqlBindString(sql, "@part", sPart);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

json GetHelmetsFromDatabase()
{
    string sPart = "helmet";
    return GetRaceAppearanceFromDatabase(-1, -1, -1, sPart);
}

string Get2DAList(string s2DA, string sColumn = "", string sGoal = "", string sIndexes = "")
{
    int n, nCount, bIndex, nTolerance = 50;
    string sReturn;

    if (sColumn == "")
    {
        sColumn = "label";
        bIndex = TRUE;
    }

    if (sIndexes == "")
    {
        do {
            string sResult = Get2DAString(s2DA, sColumn, n++);

            if (sResult == "") nCount ++;
            else
            {
                if (bIndex == TRUE || (sGoal != "" && sResult == sGoal))
                    sReturn = AddListItem(sReturn, IntToString(n - 1));
                else
                    sReturn = AddListItem(sReturn, GetStringLowerCase(sResult), TRUE);

                nCount = 0;
            }
        } while (nCount <= nTolerance);
    }
    else
    {
        int n, nCount = CountList(sIndexes);
        for (n = 0; n < nCount; n++)
        {
            int nIndex = StringToInt(GetListItem(sIndexes, n));
            string sResult = Get2DAString(s2DA, sColumn, nIndex);

            sReturn = AddListItem(sReturn, GetStringLowerCase(sResult), TRUE);
        }
    }

    return sReturn;
}

string GetPartsList()
{
    string sParts = CountList(MODEL_PARTS) > 0 ? MODEL_PARTS : Get2DAList("capart", "mdlname");
           sParts = AddListItem(sParts, "head");

    return sParts;
}

void PopulateHelmetData()
{
    string sPrefix = "helm_";
    int nPrefix = GetStringLength(sPrefix);
            
    json jResult = JsonArray(), jResrefs = NUI_GetResrefArray(sPrefix, RESTYPE_MDL, TRUE);
    if (jResrefs == JsonNull())
        return;

    int n, nCount = JsonGetLength(jResrefs);
    for (n = 0; n < nCount; n++)
    {
        string sFile = JsonGetString(JsonArrayGet(jResrefs, n));
        string sPartNumber = GetStringRight(sFile, GetStringLength(sFile) - nPrefix);
        int nPartNumber = StringToInt(sPartNumber);

        jResult = JsonArrayInsert(jResult, JsonInt(nPartNumber));
    }

    if (jResult == JsonArray())
        return;
    else
        DelayCommand(0.1, AddRaceAppearanceToDatabase("", "", "", "helmet", jResult));
}

void PopulateAppearanceData(string sFormID)
{
    if (LOAD_MODEL_DATA == FALSE || USE_CAMPAIGN_DATABASE == FALSE)
    {
        Notice("Skipping appearance loading for form " + sFormID + ".  To reload all models, set " +
            "LOAD_MODEL_DATA to TRUE in " + NUI_GetFormfile(sFormID) + ".nss.");
        return;
    }        
    
    Notice("Initializing appearances for form " + sFormID + ".  This can take more than 60 seconds to complete " +
            "for all the base-game models.  Any customzied models can increase the required time dramatically. " +
            "To prevent reloading appearances on future module loads, set LOAD_MODEL_DATA to FALSE in " + 
            NUI_GetFormfile(sFormID) + ".nss");

    InitializedDatabase();  
    PopulateHelmetData();

    string sGenders = CountList(MODEL_GENDER) > 0 ? MODEL_GENDER : Get2DAList("gender", "gender");

    string sPlayableRaceIndexes = CountList(MODEL_RACE) > 0 ? MODEL_RACE : Get2DAList("racialtypes", "playerrace", "1");
    string sRaces = Get2DAList("appearance", "race", "", sPlayableRaceIndexes);

    string sPhenotypes = CountList(MODEL_PHENOTYPE) > 0 ? MODEL_PHENOTYPE : Get2DAList("phenotype");
    string sParts = GetPartsList();

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
                        continue;

                    int n, nCount = JsonGetLength(jResrefs);
                    for (n = 0; n < nCount; n++)
                    {
                        string sFile = JsonGetString(JsonArrayGet(jResrefs, n));
                        string sPartNumber = GetStringRight(sFile, GetStringLength(sFile) - nPrefix);
                        int nPartNumber = StringToInt(sPartNumber);

                        jResult = JsonArrayInsert(jResult, JsonInt(nPartNumber));
                    }

                    if (jResult == JsonArray())
                        continue;
                    else
                    {
                        DelayCommand(0.1, AddRaceAppearanceToDatabase(sGender, sRace, sPhenotype, sPart, jResult));
                        SetLocalInt(GetModule(), "APPEARANCE_COUNT", GetLocalInt(GetModule(), "APPEARANCE_COUNT") + 1);
                    }

                    jResult = JsonArray();
                }
            }
        }
    }
}

void NUI_HandleFormDefinition()
{
    float fHeight = 32.0;
    string sFormID = "appearance_editor";

    NUI_CreateForm(sFormID);
        NUI_SetResizable(TRUE);
        NUI_BindGeometry("geometry");
        NUI_SetTitle(TITLE);
    {
        NUI_AddRow();
            NUI_AddSpacer();

            NUI_AddToggleButton("toggle_appearance");
                NUI_SetLabel(APPEARANCE);
                NUI_SetHeight(fHeight);
                NUI_BindValue("toggle_appearance_toggled");
        
            NUI_AddToggleButton("toggle_equipment");
                NUI_SetLabel(EQUIPMENT);
                NUI_SetHeight(fHeight);
                NUI_BindValue("toggle_equipment_toggled");

            NUI_AddSpacer();

        NUI_AddRow();
            NUI_AddSpacer();

            NUI_AddCombobox("combo_type");
                NUI_AddComboboxEntryList(ARMOR + "," + HELMET);
                NUI_SetHeight(fHeight);
                NUI_BindValue("combo_type_value");
                NUI_BindVisible("combo_type_visible");

            //NUI_AddCommandButton("command_outfits");
            //    NUI_SetLabel("Outfits");
            //    NUI_SetHeight(fHeight);

            NUI_AddSpacer();

        NUI_AddRow();
            NUI_AddLabel("label_item");
                NUI_BindLabel("label_item_label");
                NUI_BindVisible("label_item_visible");
                NUI_SetHeight(20.0);

        NUI_AddRow();
            NUI_AddControlGroup();
                NUI_SetBorderVisible(FALSE);
                NUI_BindVisible("group_category_visible");
            {
                NUI_AddRow();
                    NUI_AddListbox();
                        NUI_SetID("list_colorcategory");
                        NUI_BindRowCount("list_colorcategory_rowcount");
                        NUI_SetRowHeight(25.0);
                    {
                        NUI_AddToggleButton("toggle_colorcategory");
                            NUI_BindLabel("toggle_colorcategory_label");
                            NUI_BindValue("toggle_colorcategory_value");
                    } NUI_CloseListbox();
             
                NUI_AddRow();
                    NUI_AddListbox();
                        NUI_SetID("list_partcategory");
                        NUI_BindRowCount("list_partcategory_rowcount");
                        NUI_SetRowHeight(25.0);
                    {
                        NUI_AddToggleButton("toggle_partcategory");
                            NUI_BindLabel("toggle_partcategory_label");
                            NUI_BindValue("toggle_partcategory_value");
                    } NUI_CloseListbox();
            } NUI_CloseControlGroup();


            NUI_AddControlGroup();
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

                NUI_AddRow();
                    NUI_AddListbox();
                        NUI_SetID("list_partselected");
                        NUI_BindRowCount("list_partselected_rowcount");
                        NUI_SetRowHeight(25.0);
                    {
                        NUI_AddToggleButton("toggle_partselected");
                            NUI_BindLabel("toggle_partselected_label");
                            NUI_BindValue("toggle_partselected_value");
                            //NUI_BindForegroundColor("toggle_partselected_color");
                    } NUI_CloseListbox();

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
    PopulateAppearanceData(sFormID);
}

void UpdateBinds(string sBind, int nToken = -1, int bSetDefaults = FALSE)
{
    if (nToken == -1)
        nToken = NuiGetEventWindow();

    json jReturn;

    if (sBind == "geometry")
        jReturn = NUI_DefineRectangle(0.0, 0.0, 575.57895, 650.2632);
    else if (sBind == "toggle_appearance_toggled")
        jReturn = JsonInt(GetIsAppearanceSelected());
    else if (sBind == "toggle_equipment_toggled")
        jReturn = JsonInt(GetIsEquipmentSelected());
    else if (sBind == "list_colorcategory_rowcount")
        jReturn = JsonInt(JsonGetLength(GetColorCategoryOptions()));
    else if (sBind == "toggle_colorcategory_label")
        jReturn = GetColorCategoryOptions();
    else if (sBind == "toggle_colorcategory_value")
        jReturn = GetColorCategorySelected();
    else if (sBind == "list_partcategory_rowcount")
        jReturn = JsonInt(JsonGetLength(GetPartCategoryOptions()));
    else if (sBind == "toggle_partcategory_label")
        jReturn = GetPartCategoryOptions();
    else if (sBind == "toggle_partcategory_value")
        jReturn = GetPartCategorySelected();
    else if (sBind == "image_colorsheet_resref")
        jReturn = JsonString(GetColorSheetResref());
    else if (sBind == "list_partselected_rowcount")
        jReturn = JsonInt(JsonGetLength(GetPartOptions()));
    else if (sBind == "toggle_partselected_label")
        jReturn = GetPartOptions();
    else if (sBind == "toggle_partselected_value")
        jReturn = GetPartSelected();
    else if (sBind == "combo_type_value")
        jReturn = JsonInt(GetSelectedItemTypeIndex());
    else if (sBind == "combo_type_visible")
        jReturn = JsonInt(GetIsEquipmentSelected());
    else if (sBind == "group_category_visible")
        jReturn = JsonBool(GetHasItemEquipped());
    else if (sBind == "label_item_visible")
            jReturn = GetItemCanBeEquipped() == FALSE ? JsonInt(TRUE) :
                    JsonInt(GetDoesNotHaveItemEquipped());
    else if (sBind == "label_item_label")
            jReturn = GetItemCanBeEquipped() == FALSE ? JsonString(CANNOT_EQUIP) :
                    GetSelectedItemTypeIndex() == 0 ? JsonString(NO_EQUIPMENT) : 
                                                        JsonString(NO_HELMET);

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

    OnFormOpen();
    NUI_SetBindWatch(oPC, bd.nToken, "combo_type_value");

    for (n = 0; n < bd.nCount; n++)
    {
        struct NUIBindArrayData bad = NUI_GetBindArrayData(bd.jBinds, n);
        UpdateBinds(bad.sBind, bd.nToken, TRUE);
        //DelayCommand(0.3, UpdateBinds(bad.sBind, bd.nToken, TRUE));
    }
}

void NUI_HandleFormEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    int nDebug = TRUE;

    if (ed.sEvent == "open")
    {

    }
    else if (ed.sEvent == "close")
        OnFormClose();
    else if (ed.sEvent == "mouseup")
    {
        if (ed.sControlID == "toggle_appearance")
            OnSelectAppearance();
        else if (ed.sControlID == "toggle_equipment")
            OnSelectEquipment();
        else if (ed.sControlID == "toggle_colorcategory")
            OnSelectColorCategory(ed.nIndex);
        else if (ed.sControlID == "toggle_partcategory")
            OnSelectPartCategory(ed.nIndex);
        else if (ed.sControlID == "toggle_partselected")
            OnSelectPart(ed.nIndex);
        else if (ed.sControlID == "button_previous")
            OnPreviousPart();
        else if (ed.sControlID == "button_next")
            OnNextPart();
        else if (ed.sControlID == "image_colorsheet")
            OnSelectColor(ed.jPayload);
    }
    else if (ed.sEvent == "watch")
    {
        if (ed.sControlID == "combo_type_value")
            OnSelectItemType(JsonGetInt(NuiGetBind(ed.oPC, ed.nFormToken, ed.sControlID)));
    }
}
