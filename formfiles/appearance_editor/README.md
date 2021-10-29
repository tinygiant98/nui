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

## Installation

For toolset installation, import `appedit.erf`.  No compilation is required.  The NUI wrapper system must be installed for any formfile to work.  No compilation is required.

For other installation methods, such as nasher, copy the base files into whatever folder you want to use and include that folder in your configuration file.

## Language Option

The `appedit.erf` file will contain all language files for this form.  To select the language you want to use, after importing, open `nuio_appedit.nss`, read the `Language Configuation` block, and set the include directive appropriately.  No compilation is required.

## Setup

The system populates an external (campaign) database with model data from your module, so it will attempt to find all custom data.  This has not been tested with hak data, so feel free to test and provide feedback.  In order to populate this data, you must do the following:

In `nuio_appedit.nss`:

* Set `USE_CAMPAIGN_DATABASE` to `TRUE`
* Optionally, enter a campaign database name in `CAMPAIGN_DATABASE`.  If you leave this blank, it will use the database defined in the wrapper system option file `nui_i_config.nss`.
* Set `LOAD_MODEL_DATA` to `TRUE`

Rebuild and open your module.  The model data should populate when the form is registered during module startup.

> This process could take as long as two minutes for all the base-game data.  If your module is custom-content heavy, it could take longer.  Your module will appear to freeze when this occurs, just be patient.

* Once all model data has been loaded, set `LOAD_MODEL_DATA` to `FALSE` to prevent future reloads.  If your model data ever changes in the future, re-accomplish this process.
