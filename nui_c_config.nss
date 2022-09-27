
// ---------------------------------------------------------------------------------------
//                             NUI WRAPPER CONFIGURATION FILE
// ---------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
//                                DATABASE CONFIGURATION
// ---------------------------------------------------------------------------------------

// This system is expected to use live data, reloading forms and controls every time the
// module loads.  Be default, all form data is kep in the module's sqlite database, however
// you can specify the use of a campaign database for this data by setting this value to
// TRUE.  Normally, however, this should remain FALSE as there is no method for avoiding
// form reloading on module load and all saving old data could do is potentially interfere
// with new versions of formfiles.
const int NUI_USE_CAMPAIGN_DATABASE = TRUE;

// If the above value is set to true, provide the name of the campaign database to be used
// for holding form data here.
const string NUI_CAMPAIGN_DATABASE = "nui_form_data";

// This is the table name for the sqlite table that holds all form definition data
const string NUI_FORMS = "nui_forms";
const string NUI_PROFILES = "nui_profiles";

// The following two tables hold data pertaining to custom controls.  If you are not building
// or using custom controls, do not modify these values.
const string NUI_CONTROL = "nui_controls";
const string NUI_DATA = "nui_data";

// ---------------------------------------------------------------------------------------
//                             EVENT HANDLING CONFIGURATION
// ---------------------------------------------------------------------------------------

// In order for this system to capture events, it must control the nui 
// event handling.  This is the default file to control event handling.
// If you set a different file for this, that file must include the
// the following line of code somewhere in it:
//   NUI_RunEventHandler();
string NUI_EVENT_HANDLER = "nui_event";

// -----------------------------------------------------------------------------
//                             Custom Functions
//      MODIFY THESE TO ENSURE COMPATIBILTY WITH YOUR MODULE'S EVENT SYSTEM
// -----------------------------------------------------------------------------

// This function will set the script set in the NUI_EVENT_HANDLER variable in
// the configuration file nui_i_config.nss.  You can modify this function directly,
// however, if you are only changing the script, you should designate the file script
// in the config file and not in this function.  See notes about the event handler
// in the config file.
void NUI_SetEventHandler()
{
    SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_NUI_EVENT, NUI_EVENT_HANDLER);
}

// This function will run various scripts that can be set during form definition. If
// your module uses something other than the standard loose-script methodology, modify
// this function to match your methodology.  For example, if you're using SM's 
// event management system, you would change this to RunLibraryScript(sScript, oPC);
int NUI_RunScript(string sScript, object oPC)
{
    ExecuteScript(sScript, oPC);
    return sScript != "";
}

// This system will save form data by PC object.  This datatype is a string.  You can decide
// how this string is encoded for your module here.  This will allow the saved data to be
// compatible with methodology for pc identification in your module.  It is very unlikely
// that your module will be querying the temporary form data tables, but the option is here
// in case it is needed.
string NUI_EncodePC(object oPC)
{
    return GetName(oPC);
}

// This system has some basic debugging functionality.  In order to make this system work
// under multiple modules without collision, the following function is provided to
// allow you to call whatever debugging system you'd like to call.  If you use
// squattingmonk's debug utility, no changes need to be made.
//
// NUI_DEBUG_SEVERITY_NONE     = 0;
// NUI_DEBUG_SEVERITY_CRITICAL = 1;
// NUI_DEBUG_SEVERITY_ERROR    = 2;
// NUI_DEBUG_SEVERITY_WARNING  = 3;
// NUI_DEBUG_SEVERITY_NOTICE   = 4;
// NUI_DEBUG_SEVERITY_DEBUG    = 5;

#include "util_i_debug"

void NUI_Debug(string sMessage, int nSeverity = 4)
{
    Debug(sMessage, nSeverity);
}

// ---------------------------------------------------------------------------------------
//                                FORMFILE CONFIGURATION
// ---------------------------------------------------------------------------------------

// This system will auto-initialize forms that meet specific parameters.
// Forms defined in "formfiles" should be in include format (i.e. there
// should be no void main() {}).

// Auto-initialized forms must be .nss files that have specific prefixes.
// Set this value to the script file prefix used for formfiles.  The default
// for all formfiles downloaded from the repo is `nuif_`.  If necessary,
// you can use multiple prefixes separated by commas.
string NUI_FORMFILE_PREFIX = "nuif_";

// Set this value to the function that should be called to define a form
// during auto-initialization.  All formfiles should contain this function.
// For example, if the following value is "NUI_HandleFormDefinition", the
// formfile should include a function called:
//      void NUI_HandleFormDefinition() {}
// which contains all the code required to generate json for a specific
// form.
string NUI_FORMFILE_DEFINITION_FUNCTION = "NUI_HandleFormDefinition";

// Set this value to the function that will be called to handle form
// events, if any are defined for this form.  All formfiles should contain
// this function, even if no events are defined for this form.
string NUI_FORMFILE_EVENTS_FUNCTION = "NUI_HandleFormEvents";

// Set this value to the function that will be called to handle form
// binds, if any are defined for this form.  All formfiles should contain
// this function, even if no binds are defined for this form.
string NUI_FORMFILE_BINDS_FUNCTION = "NUI_HandleFormBinds";

// Set this value to the function that will be called to handle form
// builds, if any are defined for this form.  All formfiles should contain
// this function, even if no builds are defined for this form.
string NUI_FORMFILE_BUILDS_FUNCTION = "NUI_HandleFormBuilds";

// TODO make this prettier
// FUTURE GROWTH, don't touch this stuff
string NUI_CONTROLFILE_PREFIX = "nui_c_";

string NUI_CONTROLFILE_REGISTRATION_FUNCTION = "NUI_HandleControlRegistration";

string NUI_CONTROLFILE_INSERTION_FUNCTION = "NUI_HandleControlInsertion";

string NUI_CONTROLFILE_ADDSERIES_FUNCTION = "NUI_HandleAddSeries";

string NUI_CONTROLFILE_DROPSERIES_FUNCTION = "NUI_HandleDropSeries";

// TODO maybe not this?
string NUI_IGNORE_EVENTS = ""; //"range,mousescroll,mousedown";