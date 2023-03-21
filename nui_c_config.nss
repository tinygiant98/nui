
/// ----------------------------------------------------------------------------
/// @file   nui_c_config.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  NUI Form Creation and Management System Configuration
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              FORM INSPECTOR
// -----------------------------------------------------------------------------

// The form inspection capability allows you to record data about a form's status,
// including bind values and how various events affect them.  To use the inspection
// capability, you must include the `nui_f_inspector` formfile in your module and
// set NUI_FI_RECORD_DATA to the desired value.

// *** WARNING *** Form inspection is very expensive.  Is it recommended that
//      you only use the form inspection capability during debug or set this
//      value to NUI_FI_WHEN_OPEN to prevent unnecessary traffic.
const int NUI_FI_NEVER     = 0;
const int NUI_FI_ALWAYS    = 1;
const int NUI_FI_WHEN_OPEN = 2;

const int NUI_FI_RECORD_DATA = NUI_FI_WHEN_OPEN;

// -----------------------------------------------------------------------------
//                             Custom Functions
//        MODIFY THESE TO ENSURE COMPATIBILTY WITH YOUR MODULE'S SYSTEMS
// -----------------------------------------------------------------------------

// This system has some basic debugging functionality.  In order to make this system work
// under multiple modules without collision, the following function is provided to
// allow you to call whatever debugging system you'd like to call.  If you use
// squattingmonk's debug utility, no changes need to be made.  The primary system does
// not provide any organic debug calls, but this function is available to all formfiles
// for debugging purposes.
//
const int NUI_DEBUG_SEVERITY_NONE     = 0;
const int NUI_DEBUG_SEVERITY_CRITICAL = 1;
const int NUI_DEBUG_SEVERITY_ERROR    = 2;
const int NUI_DEBUG_SEVERITY_WARNING  = 3;
const int NUI_DEBUG_SEVERITY_NOTICE   = 4;
const int NUI_DEBUG_SEVERITY_DEBUG    = 5;

//#include "util_i_debug"

void NUI_Debug(string sMessage, int nSeverity = 4)
{
    //Debug(sMessage, nSeverity);
}
