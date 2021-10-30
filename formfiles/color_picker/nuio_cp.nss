// ---------------------------------------------------------------------------------------
//                         APPEARANCE EDITOR CONFIGURATION FILE
// ---------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
//                                LANGUAGE CONFIGURATION
// ---------------------------------------------------------------------------------------

// Place the include directive here for the language file you'll be using.  The language
// file should be named nuil_appedit_xx.nss, where xx represents the ISO 639-1 standard
// langauge code.  See the notes in each language file for system requirements, encoding
// and game settings to ensure that language displays correctly.
#include "nuil_cp_en"

// When the form is closed, the selected color will be saved to a Module-level variable 
// to allow for easy retrieval.  The NUI system primarily uses RGB structured json
// objects to store and use color values, so the result will be saved as json.  To
// retrieve the selected color, use GetLocalJson(GetModule(), COLOR_VARNAME);  The
// retrieved value will be an nui json color construct, similar to the return from
// functions such as NUI_DefineRGBColor().
string COLOR_VARNAME = "COLORPICKER_SELECTED_COLOR";
