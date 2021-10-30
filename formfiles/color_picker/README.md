# Formfile: Color Picker

## Description

The Color Picker is designed to allow a user to select a single color, see its value in RGB, HSV and Hex format, and return that value in an NUI-compatible json color object. 

## Files

Primary:

* Formfile: `nuif_cp.nss`
* Options:  `nuio_cp.nss`
* Language File: `nuil_cp_en.nss` - English (default)

Supporting:
* `cp_full.erf` - all form files, including configuration and language
* `cp_base.erf` - only base files, no configuration or language files included.  Use for version updates.

## Installation

For toolset installation, import `cp_full.erf`.  No compilation is required.  The NUI wrapper system must be installed for any formfile to work.

For other installation methods, such as nasher, copy the base files into whatever folder you want to use and include that folder in your configuration file.

For version updates, import `cp_base.erf`.  This file will not contain configuration or language files and will prevent overwriting established configurations during version updates.

## Language Option

The `cp_full.erf` file will contain all language files for this form.  To select the language you want to use, after importing, open `nuio_cp.nss`, read the `Language Configuation` block, and set the include directive appropriately.  No compilation is required.

To create a new language file, copy `nuil_cp_en.nss`, change the last two letter to the language code you're translating to, modify the string values and submit it for a pull request on the repo.

## Setup

None required.

## Usage

To open this form, use `NUI_DisplayForm("color_picker");`.
