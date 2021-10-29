
// This system will auto-initialize forms that meet specific parameters.
// Forms defined in "formfiles" should be in include format (i.e. there
// should be no void main() {}).

// In order for this system to capture events, it must control the nui 
// event handling.  This is the default file to control event handling.
// If you set a different file for this, that file must include the
// the following line of code somewhere in it:
//   NUI_RunEventHandler();
string NUI_EVENT_HANDLER = "nui_event";

// Auto-initialized forms must be .nss files that have specific prefixes.
// Set this value to the script file prefix used for formfiles.
string NUI_FORMFILE_PREFIX = "nuif_";

// Set this value to the function that should be called to define a form
// during auto-initialization.  All formfiles should contain this function.
// For example, if the following value is "HandleFormDefinition", the
// formfile should include a function called:
//      void HandleFormDefinition() {}
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

string NUI_CONTROLFILE_PREFIX = "nui_c_";

string NUI_CONTROLFILE_REGISTRATION_FUNCTION = "NUI_HandleControlRegistration";

string NUI_CONTROLFILE_INSERTION_FUNCTION = "NUI_HandleControlInsertion";

string NUI_CONTROLFILE_ADDSERIES_FUNCTION = "NUI_HandleAddSeries";

string NUI_CONTROLFILE_DROPSERIES_FUNCTION = "NUI_HandleDropSeries";

string IGNORE_EVENTS = "range,mousescroll,mousedown";