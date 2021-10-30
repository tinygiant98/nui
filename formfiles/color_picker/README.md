# Formfile: Color Picker

## Description

The Color Picker is designed to allow a user to select a single color, see its value in RGB, HSV and Hex format, and return that value in an NUI-compatible json color object. 

## Files

Primary:

* Formfile: `nuif_cp.nss`
* Options:  `nuio_cp.nss`
* Language File: `nuil_cp_en.nss` - English (default)

Supporting:
* None

## Installation

For toolset installation, import `cp.erf`.  No compilation is required.  The NUI wrapper system must be installed for any formfile to work.

For other installation methods, such as nasher, copy the base files into whatever folder you want to use and include that folder in your configuration file.

## Language Option

The `cp.erf` file will contain all language files for this form.  To select the language you want to use, after importing, open `nuio_cp.nss`, read the `Language Configuation` block, and set the include directive appropriately.  No compilation is required.

To create a new language file, copy `nuil_cp_en.nss`, change the last two letter to the language code you're translating to, modify the string values and submit it for a pull request on the repo.

## Setup

None required.

## Usage

To open this form, use `NUI_DisplayForm("color_picker");`.
