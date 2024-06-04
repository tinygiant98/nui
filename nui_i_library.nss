/// ----------------------------------------------------------------------------
/// @file   nui_i_library.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Boilerplate code for creating a library dispatcher. Should only be
///     included in library scripts as it implements main().
/// ----------------------------------------------------------------------------

#include "nui_i_main"

// -----------------------------------------------------------------------------
//                              Function Protoypes
// -----------------------------------------------------------------------------

void DefineForm();
void BindForm();
void HandleNUIEvents();
void HandleModuleEvents();

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

// These are dummy implementations to prevent nwnsc from complaining that they
// do not exist. If you want to compile in the toolset rather than using nwnsc,
// comment these lines out.
//#pragma default_function(DefineForm)
//#pragma default_function(BindForm)
//#pragma default_function(HandleNUIEvents)
//#pragma default_function(HandleModuleEvents)

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void main()
{
    string sOperation = GetScriptParam(NUI_FUNCTION);

    if      (sOperation == NUI_DEFINE)    DefineForm();
    else if (sOperation == NUI_BIND)      BindForm();
    else if (sOperation == NUI_EVENT_NUI) HandleNUIEvents();
    else if (sOperation == NUI_EVENT_MOD) HandleModuleEvents();
    else                                  NUI();
}
