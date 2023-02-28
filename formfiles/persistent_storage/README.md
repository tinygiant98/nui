#### **NUI System Formfile: Persistent Storage**

### Compatibility:

Developed and tested under 8193.34.

### Version History:

## 0.1.4:
- Forced gold withdraw and deposit button tooltips to update more often to prevent out-of-sync condition.
- Added gold withdraw/deposit functionality:
    If the `Amount...` textbox is empty, clicking the gold `Withdraw` button will withdraw all gold up to the amount listed in the `Gold:` container.  If there is no gold stored in the container, the gold `Withdraw` button will be disabled.  Similarly, clicking on the gold `Deposit` button will deposit all gold up to the amount the PC has, as long as it doesn't exceed the total storage capability of the container as defined by `nui_c_storage` or local override variables set on the container object.  If the PC has no gold, the gold `Deposit` button will be disabled.

## 0.1.3:
- Fixed typo in PS_CONTAINER_TYPE that prevented local overrides from reading correctly.

## 0.1.2:
- Fixed bug in sqlite query when using containers as personal storage (by character/by cdkey) which prevented the item list from displaying after an item was deposited.

## 0.1.1:

- Added configuration option: `PS_MAX_CONTAINER_ITEMS_DEFAULT`.
- Added configuration option: `PS_MAX_CONTAINER_ITEMS_INVENTORY_DEFAULT`.
- Modified available values and settings for various default settings and overrides due to the way local variables are handles by the game engine.  ***This could be a breaking change*** if local variables are used to control access.  To fix:

    `PS_STORAGE_DEFAULT` and `PS_STORAGE_LIMIT` should be set to `PS_UNLIMITED` in `nui_c_config` or `-1` if set as a variable (instead of the previous 0) to allow unlimited item storage.

    `PS_DISTANCE_DEFAULT` and `PS_DISTANCE` should be set to `PS_UNLIMITED` in `nui_c_config` or `-1.0` if set as a variable (instead of the previous 0.0) to allow unlimited distance between the player and the container.

    `PS_MAX_GOLD_DEFAULT` and `PS_MAX_GOLD` should be set to `PS_NONE` in `nui_c_config` or `-2` if set as a variable (instead of the previous 0) to prevent any gold storage.  Set to `PS_UNLIMITED` in `nui_c_config` or `-1` if set as a variable for unlimited gold storage.

- Changed configuration constant `PS_STORAGE_DEFAULT` to `PS_STORAGE_LIMIT_DEFAULT`.
- Changed configuration constant `PS_SEARCH_BUTTON_DEFAULT` to `PS_FORCE_SEARCH_BUTTON_DEFAULT`.
- Changed configuration constant `PS_OBJECT_STATE_DEFAULT` to `PS_FORCE_OBJECT_STATE_DEFAULT`.
- Changed configuration constant `PS_ACCESS_DEFAULT` to `PS_ACCESS_TYPE_DEFAULT`.
- Changed configuration constant `PS_CONTAINER_DEFAULT` to `PS_CONTAINER_TYPE_DEFAULT`.
- Added configuration constant `PS_NONE (-2)`.
- Added configuration constant `PS_UNLMITED (-1)`.
- Added configuration constant `PS_TRUE (1)`.
- Added configuration constant `PS_FALSE (-1)`.
- Added configuration constant `PS_UNLIMITED_DISTANCE (-1.0)`
- Updated `nui_c_config` constant descriptions for added configuration constants and clarity.

## 0.1.0:

Initial Release

### Usage:

This form can internally handle the following module events.  Additional events may be added by request:
- OnPlaceableUsed
- OnPlaceableOpen
- OnPlaceableClosed

- Direct Call:  set `nui_f_storage` as the event script for any of the above events.
- Event System Call:  call `NUI_HandleEvents(oPC);` from any script.  in this case, `oPC` must be the appopriate player characters (i.e. `GetLastOpenedBy()` in the `OnPlaceableOpen` event.)
