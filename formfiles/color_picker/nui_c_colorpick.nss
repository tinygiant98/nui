/// ----------------------------------------------------------------------------
/// @file   nui_c_colorpick.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Color Picker configuration file.
/// ----------------------------------------------------------------------------

// When the form is closed, the selected color will be saved to a module-level variable 
// to allow for easy retrieval.  The NUI system primarily uses RGB structured json
// objects to store and use color values, so the result will be saved as json.  To
// retrieve the selected color, use GetLocalJson(GetModule(), COLOR_VARNAME);  The
// retrieved value will be an nui json color construct, similar to the return from
// functions such as NUI_DefineRGBColor().
string COLOR_VARNAME = "COLORPICKER_SELECTED_COLOR";