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
