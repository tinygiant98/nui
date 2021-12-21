# Formfile: Appearance Editor

## Description

The Appearance Editor, originally authored by Zunath, is designed to allow a player to modify the color and model of their character and clothing/armor.  

## Files

Primary:

* Formfile: `nuif_appedit.nss`
* Options:  `nuio_appedit.nss`
* Language File: `nuil_appedit_en.nss` - English (default)
* Language File: `nuil_appedit.ru.nss` - Russian

Supporting:
* `gui_pal_armor01.tga` - required to show the metal color palette; somehow missing from the base game files
* `appedit_full.erf` - all form files, including configuration and language
* `appedit_base.erf` - only base files, no configuration or language files included.  Use for version updates.

## Installation

For toolset installation, import `appedit_full.erf`.  No compilation is required.  The NUI wrapper system must be installed for any formfile to work.  No compilation is required.

For other installation methods, such as nasher, copy the base files into whatever folder you want to use and include that folder in your configuration file.

For version updates, import `appedit_base.erf`.  This file will not contain configuration or language files and will prevent overwriting established configurations during version updates.

> *** NOTE *** This form is heavy on instruction count and will cause TMI if your module does not have an increased TMI limit.  If you're playing single-player, go into the game options and set the instruction limit to its maximum value.  If you're running NWNX, use the `NWNX_SetInstructionLimit()` function in the UTIL plugin to increase the instruction limit.

This NUI form integrates with several module-level events, so integration is somewhat detailed.  The NUI system itself should handle setting up the NUI event handling and inititalization functions.  However, for this form, you must also integrate player targeting and management for equipping, acquiring, unequipping and unacquiring items.

If your module does not integrate player targeting capability, you must add it by including this in your `OnModuleLoad` event script:

```c
    SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "<targeting_script>");
```
In this case, replace `<targeting_script>` with the name of whatever script you plan on using.  That script must contain the following at a minimum:

```c
#include "nui_i_main"

void main()
{
    NUI_RunTargetingEventHandler();
}
```

If your module already has a script to handle player targeting, you must add the following line to that script:

```c
    NUI_RunTargetingEventHandler();
```

Since this particular form integrates several module-level events, your module must call the module event handler for each of the events.  Your module's event handlers for the `OnEquipItem`, `OnUnequipItem`, `OnAcquireItem` and `OnUnaquireItem` must contain a reference to the NUI system's module event handler and must pass the PC object.  The PC object for each event will be obtained differently.  For example, for the `OnEquipItem` event, the PC object is obtained by running `GetPCItemLastEquippedBy()`.  Once the PC object has been obtained, call the module handler with this line (where `oPC` is the obtained PC object):

```c
    NUI_RunModuleEventHandler(oPC);
```

## Language Option

The `appedit_full.erf` file will contain all language files for this form.  To select the language you want to use, after importing, open `nuio_appedit.nss`, read the `Language Configuation` block, and set the include directive appropriately.  No compilation is required.

To create a new language file, copy `nuil_appedit_en.nss`, change the last two letters to the language code you're translating to, modify the string values and submit it for a pull request on the repo.

## Setup

The system populates an external (campaign) database with model data from your module, so it will attempt to find all custom data.  This has not been tested with hak data, so feel free to test and provide feedback.  In order to populate this data, you must do the following:

In `nuio_appedit.nss`:

* Set `USE_CAMPAIGN_DATABASE` to `TRUE`
* Optionally, enter a campaign database name in `CAMPAIGN_DATABASE`.  If you leave this blank, it will use the database defined in the wrapper system option file `nui_i_config.nss`.
* Set `LOAD_MODEL_DATA` to `TRUE`

Rebuild and open your module.  The model data should populate when the form is registered during module startup.

> This process could take as long as two minutes for all the base-game data.  If your module is custom-content heavy, it could take longer.  Your module will appear to freeze when this occurs, just be patient.

* Once all model data has been loaded, set `LOAD_MODEL_DATA` to `FALSE` to prevent future reloads.  If your model data ever changes in the future, re-accomplish this process.

## Usage

To open this form, use `NUI_DisplayForm("appearance_editor");`.
