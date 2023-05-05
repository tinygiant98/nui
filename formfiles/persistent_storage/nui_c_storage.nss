/// ----------------------------------------------------------------------------
/// @file   nui_c_storage.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Persistent Storage formfile configuration settings
/// ----------------------------------------------------------------------------

/// @note Most of the following global/default settings can be overriden on a
///     per-container basis by setting a local variable on the container
///     object as noted in the setting descriptions below.  Constants, such as
///     PS_TRUE, PS_NONE, etc. should be used in this configuration file, however,
///     actual values must be used when setting local overrides.  Those values
///     are provided below.

/// @warning This system uses player character UUIDs.  This can cause issues in
///     single-player modules if the player-character is not exported and the
///     UUID is not saved to the .bic file.

/// @brief By default, containers will be saved to a database table referenced
///     by the container object's tag.  The saved item data includes the UUID
///     and CD Key of the PC that deposited the item so the same container can
///     be used for multiple PCs.  To set a specific (unique) name to use as the
///     table name instead, set a local string called `PS_UNIQUE_ID` on the 
///     container object and set it to any unique string.

/// @brief Determines usage of the `Search` button.
///     Configuration File:
///         PS_TRUE to force players to click the `Search` button
///             before an inventory search will commence.  This is a good idea
///             for containers that you expect will have large inventories.
///         PS_FALSE to allow real-time searching as the player types
///             characters into the `Search` textbox.
///     Local Override (int): PS_FORCE_SEARCH_BUTTON
///          1 = PS_TRUE
///         -1 = PS_FALSE
const int PS_FORCE_SEARCH_BUTTON_DEFAULT = PS_FALSE;

/// @brief Determines whether item object state is saved to the database. The
///     object state includes variables and effects.
///     Configuration File:
///         PS_TRUE saves the object state
///         PS_FALSE does not save the object state
///     Local Override (int): PS_FORCE_OBJECT_STATE
///          1 = PS_TRUE
///         -1 = PS_FALSE
const int PS_FORCE_OBJECT_STATE_DEFAULT = PS_TRUE;

/// @brief Sets the item storage limit.
///     Configuration File:
///         PS_UNLIMITED to allow unlimited item storage.
///         Set to any positive integer to limit item storage to that amount.
///     Local Override (int): PS_STORAGE_LIMIT
///         -1 = PS_UNLIMITED
///         Set to any positive integer to limit item storage to that amount.
const int PS_STORAGE_LIMIT_DEFAULT = 200;

/// @brief Set the maximum distance (meters) a PC can travel from the container
///     before the form will auto-close.
///     Configuration File:
///         PS_UNLIMITED_DISTANCE to never auto-close the form
///         Set to any positive float to limit distance to that amount.
///     Local Override (float): PS_DISTANCE
///         -1.0 = PS_UNLIMITED_DISTANCE
///         Set to any positive float to limit distance to that amount.
const float PS_DISTANCE_DEFAULT = 2.0;

/// @brief Set the container access type.  Container inventories can be accessed
///     by two methods:  exclusive and contentious.
///     - Exclusive:  Multiple players may open the same container, but each
///         player will only see items they've previously deposited.  Players
///         may only withdraw items they've previously deposited.
///     - Contentious:  Multiple players may open the same container.  All
///         players will see all items deposited by any player.  Any player
///         can remove any item, regardless of who originally deposited the
///         item.
///
///     Configuration File:
///         PS_ACCESS_EXCLUSIVE for exclusive access
///         PS_ACCESS_CONTENTIOUS for contentious access
///     Local Override (int): PS_ACCESS_TYPE
///         1 = PS_ACCESS_EXCLUSIVE
///         2 = PS_ACCESS_CONTENTIOUS
const int PS_ACCESS_TYPE_DEFAULT = PS_ACCESS_EXCLUSIVE;

/// @brief Set the container type. Containers can be of multiple types:
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
///
///     Configuration File:
///         PS_CONTAINER_PUBLIC for public.
///         PS_CONTAINER_CHARACTER for per-character.
///         PS_CONTAINER_CD_KEY for per-cdkey.
///     Local Override (int): PS_CONTAINER_TYPE
///         1 = PS_CONTAINER_PUBLIC
///         2 = PS_CONTAINER_CHARACTER
///         3 = PS_CONTAINER_CDKEY
const int PS_CONTAINER_TYPE_DEFAULT = PS_CONTAINER_PUBLIC;

/// @brief Set the default container type, if the container is an item.  Containers
///     can be of multiple types:
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
///
///     Configuration File:
///         PS_CONTAINER_PUBLIC for public.
///         PS_CONTAINER_CHARACTER for per-character.
///         PS_CONTAINER_CD_KEY for per-cdkey.
///     Local Override (int): PS_CONTAINER_TYPE
///         1 = PS_CONTAINER_PUBLIC
///         2 = PS_CONTAINER_CHARACTER
///         3 = PS_CONTAINER_CDKEY
const int PS_CONTAINER_ITEM_TYPE_DEFAULT = PS_CONTAINER_CHARACTER;

/// @brief Determines whether the player's inventory window will be opened
///     when a container is opened. 
///     Configuration File:
///         PS_TRUE to open the inventory window.
///         PS_FALSE to prevent the window from opening.  If the inventory
///             window is already open, this will not close it.
///     Local Override (int): PS_OPEN_INVENTORY
///          1 = PS_TRUE
///         -1 = PS_FALSE
const int PS_OPEN_INVENTORY_DEFAULT = PS_TRUE;

/// @brief Determines the maximum amount of gold a container can store.
///     If the container is set to store no gold, the form controls that
///     manipulate gold storage will not be visible on the form.
///     Configuration File:
///         PS_UNLIMITED to allow unlimited gold storage.
///         PS_NONE to prevent gold storage.         
///         Set to any positive integer to limit gold to that amount.
///     Local Override (int): PS_MAX_GOLD
///         -1 = PS_UNLIMITED
///         -2 = PS_NONE
///         Set to any positive integer to limit gold to that amount.
const int PS_MAX_GOLD_DEFAULT = 1000000;

/// @note Reference these terms for the following option:
///     Container: A persistent storage object in the game, such as a chest.
///     Container Item: An item which:
///                         Can have its own inventory
///                         Can be carried in a player's inventory

/// @brief Determines handling for container objects.  Containers can optionally 
///     store container items. 
///     Configuration File:
///         PS_UNLIMITED to allow storage of an unlimited number of container items.
///         PS_NONE to prevent storage of any container items.
///         Set to any positive integer to limit storage to that number of container
///             items.
///     Local Override (int): PS_MAX_CONTAINER_TIMES
///         -1 = PS_UNLIMITED
///         -2 = PS_NONE
///         Set to any positive integer to limit storage to that number of container
///             items.
const int PS_MAX_CONTAINER_ITEMS_DEFAULT = 10;

/// @brief Determines how many items can be stored in stored container items.
///     Configuration File:
///         PS_UNLIMITED to allow storage of any number of items within a container
///             item's inventory.  This will be naturally limited by the size of
///             the container item's inventory.
///         PS_NONE to prevent any items from being stored in a container item.  If
///             container item storage is allow and PS_NONE is used, only empty
///             container items can be stored.
///         Set to any positive integer to limit the number of items stored in
///             the inventory of a container item.
///     Local Override (int): PS_MAX_CONTAINER_ITEMS_INVENTORY
///         -1 = PS_UNLIMITED
///         -2 = PS_NONE
///         Set to any positive integer to limit the number of items stored in
///             the inventory of a container item.
///
/// @note This configuration option has no effect if PS_MAX_CONTAINER_ITEMS_DEFAULT
///     is set to PS_NONE or its local override is set to -1.
/// @warning Items that fail check involved with container item limitations do
///     not have default messages reported to the player.  The item will simply fail
///     to be stored.
const int PS_MAX_CONTAINER_ITEMS_INVENTORY_DEFAULT = 100;

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
