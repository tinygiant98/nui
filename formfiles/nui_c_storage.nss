/// ----------------------------------------------------------------------------
/// @file   nui_c_storage.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Persistent Storage formfile configuration settings
/// ----------------------------------------------------------------------------

/// @brief Set this to TRUE to force players to click the "Search" button
///     before an inventory search will commence.  This is a good idea for
///     large inventories.  This can be overriden on a per-container basis
///     by setting a local int `PS_FORCE_SEARCH_BUTTON` to TRUE on the
///     container/object.
const int PS_SEARCH_BUTTON_DEFAULT = FALSE;

/// @brief Set this to TRUE to save local variables, temporary item
///     properties, etc., when serializing items.  This can be overridden
///     on a per-container basis by setting a local int `PS_FORCE_OBJECT_STATE`
///     to TRUE on the container/object.
const int PS_OBJECT_STATE_DEFAULT = TRUE;

/// @brief Set this to an integer that represents the maximum number of items
///     any generic container can contain.  This can be overriden on a
///     per-container basis by setting a local int `PS_STORAGE_LIMIT` to the
///     desired quantity on the container/object.  Setting this value to `0` or
///     any negative number will allow unlimited item storage.
const int PS_STORAGE_DEFAULT = 200;

/// @brief Set this to the maximum distance a PC can be from the container
///     during use.  If the PC exceeds this distance from the container, the
///     form will automatically close. Set to 0.0 to allow infinite distance.
///     This can be overriden on a per-container basis by setting a local float
///     `PS_DISTANCE` to the desired distance on the container/object.
const float PS_DISTANCE_DEFAULT = 2.0;

/// @brief By default, containers will be saved to a database table referenced
///     by tag.  The item data includes the PC UUID that deposited the item,
///     so the same container can be used for multiple PCs.  To modify the
///     database table name for any specific container/object, create a local
///     string variable `PS_UNIQUE_ID` on the container/object.

/// @brief Container inventories can be accessed by two methods: exclusive
///     and contentious.  
///     - Exclusive:  Multiple players may open the same container, but each
///         player will only see items they've previously deposited.  Players
///         may only withdraw items they've previously deposited.
///     - Contentious:  Multiple players may open the same container.  All
///         players will see all items deposited by any player.  Any player
///         can remove any item, regardless of who originally deposited the
///         item.
///     This default access setting can be overridden on a per-container basis
///         by setting a local int `PS_ACCESS_TYPE` to `1` for exclusive access
///         or to `2` for contentious access.
///     Set this value to one ofthe following:
///         PS_ACCESS_EXCLUSIVE for exclusive access
///         PS_ACCESS_CONTENTIOUS for contentious access
const int PS_ACCESS_DEFAULT = PS_ACCESS_EXCLUSIVE;

/// @brief Containers can be of multiple types:
///     - Public:  Any player can open, deposit and withdraw items from this
///         container.  Whether they are limited to specific items is dependant
///         on the container's access setting.
///     - Character:  Creates a 'portable' storage container for any player
///         character.  Any container of this type will hold the same inventory
///         for any specific player.
///     - CD Key:  Creates a 'portable' storage container for any characters
///         owned by cd-key associated with the player character.  Any container
///         of this type will hold the inventory desposited by any character
///         sharing the player's cd key.
///     This default container setting can be overriden on a per-container basis
///         by setting a local int `PS_CONTAINER_TYPE` to `1` for public,
///         `2` for per-character, or `3` for per-cdkey.
///     Set this value to one of the following:
///         PS_CONTAINER_PUBLIC for public
///         PS_CONTAINER_CHARACTER for per-character
///         PS_CONTAINER_CD_KEY for per-cdkey.
const int PS_CONTAINER_DEFAULT = PS_CONTAINER_PUBLIC;

/// @brief The player's inventory window may be opened when a container is
///     opened.  Set this value to `TRUE` or `FALSE`.  This default container
///     setting can be overriden on a per-container bases by setting a local
///     int `PS_OPEN_INVENTORY` to `TRUE` to open the inventory panel, or
///     `FALSE` to prevent automatically opening the inventory panel.
const int PS_OPEN_INVENTORY_DEFAULT = TRUE;

/// @brief Containers can optionally store gold.  The this value to `TRUE`
///     or `FALSE`.  If FALSE, the form control's that manipulate gold storage
///     will not be visible for any container using this value.  This
///     default setting can be overriden on a per-container basis by setting
///     a local int `PS_MAX_GOLD` to the maximum gold storage capacity, or set
///     to `0` to prevent gold storage, or to `-1` to provide unlimited gold
///     storage.
const int PS_MAX_GOLD_DEFAULT = 1000000;

/// @brief Creates the form's title.
/// @param oContainer The container object being used.
/// @param oPC The player using oContainer.
/// @note A local string called `PS_TITLE` may be set on the object for easy
///     reference in this function.  The function below is an example and may
///     be modified in any way.  The returned value will be displayed as the
///     form's title.
string ps_GetFormTitle(object oContainer, object oPC, int nAccess, int nType)
{
    string sTitle;
    if ((sTitle = GetLocalString(oContainer, PS_TITLE)) != "")
        return sTitle;
    else
    {
        switch (nType)
        {
            case PS_CONTAINER_PUBLIC:
                return GetTag(oContainer);
            case PS_CONTAINER_CDKEY:
                return GetName(oPC) + "'s Player-Specific Storage";
            case PS_CONTAINER_CHARACTER:
                return GetName(oPC) + "'s Character-Specific Storage";
        }

        if (GetIsPC(OBJECT_SELF))
            return GetName(OBJECT_SELF) + "'s Storage";
    }

    return "Persistent Storage";
}
