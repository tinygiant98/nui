<style>
    r { color: red }
    o { color: orange }
    g { color: green }
    fg { color: forestgreen}
    b { color: dodgerblue }
    ctl  { color: orange;
           font-size: 110%; }
    warn { color: white;
           background-color: darkred }

    .top-link {
        transition:       all .25s ease-in-out;
        position:         fixed;
        bottom:           0;
        right:            0;
        display:          inline-flex;
        color:            #000000;

        cursor:           pointer;
        align-items:      center;
        justify-content:  center;
        margin:           0 2em 2em 0;
        border-radius:    50%;
        padding:          .25em;
        width:            1em;
        height:           1em;
        background-color: #F8F8F8;
    }
</style>

<a class="top-link hide" href="#top">↑</a>
<a name="top"></a>

## Description

NWN contains a scripting interface that allows users to build and display custom forms for their module players.  This system is called NUI (Nuklear User Interface) and is base on the Nuklear immediate-mode user interface originally built by `Vurtun`, modified by the developers of NWN to interact with the game's rendering engine and to add custom features.  This NUI system is a wrapper to make interaction with the game's system easier as well as provide capabilities to handle NUI events and build all form functionality into a single `formfile` that can be run as a stand-alone script, can be built as an `#include`, or can be run by the just-in-time compiler built into the game.  This compartmentalization should allow forms to be easily shared between modules.

## Requirements

NWN:EE >= 8193.35
>Some form properties and features may require a higher game-major version to function correctly, however this system only requires .35 or higher.  Additionally, individual formfiles may require a higher game-major version.

## Change Log

*** 0.5.1 ***
- Modified the form name constant in `nui_f_template.nss` to prevent a rare sqlite parsing error involving the use of angle brackets.

*** 0.5.0 ***
- Removed some constants in `nui_i_main` to permit including `nw_inc_nui`, allowing this nui system and the base game's nui implementation script to work together.  `nw_inc_nui` is now `#include`d in `nui_i_main`.
- Modified `NUI_DisplayForm()` prototype:
 - Modified default value for `sProfile` parameter changed from `"default"` to `""`.  Passing `""` will still call the `default` profile, so no behavior has changed and no code requires updating.
 - Added fourth parameter `int bSelfManage = FALSE` to direct the game to call the formfile directly instead of the module's NUI handler.
- Added ability for formfiles to be called directly instead of through the module's NUI event handler.  This feature defaults to `FALSE` (i.e. the game's NUI handler will normally be used) to maintain backward-compatibility.  To call formfiles directly, the following conditions must be met:
 - The formfile must be pre-compiled, not compiled-on-demand (i.e. it must `#include "nui_i_library"`)
 - The form must be opened using `NUI_DisplayForm(oPC, sFormID, sProfile, TRUE);`, where the fourth paramter (`TRUE`) tells the NUI system to call the formfile instead of the game's NUI handler.
- Modified `JsonNull()`, `JsonArray()` and `JsonObject()` function calls to their constant representations `JSON_NULL`, `JSON_ARRAY` and `JSON_OBJECT`.
- Added `NUI_AddLayout(json jLayout)`.  This function allows forms defined with functions in `nw_inc_nui` to be added to and used by this NUI system.  To use this feature, the normal form definition process is followed, except the primitive form layout is added instead of adding controls.  In the example below, `jLayout` is the form/window definition built using functions in `nw_inc_nui` as defined before calling `NuiWindow()`.
> After calling `NUI_CreateForm()`, set all form-level properties, such as resizable, accepts_input, etc.  After those are set, call `NUI_AddLayout()` and pass a form definition.
> You cannot modify control or form properties after adding a layout via `NUI_AddLayout()`.  `NUI_AddLayout()` should be the last call in the primary form definition process, followed only by optional profile and/or subform definitions.
```c
void DefineForm()
{
    NUI_CreateForm("<form_id>", "<form_version>");
        NUI_SetResizable(TRUE);
        NUI_BindTitle("frmTitle");
    {
        json jWidget, jCol;

        {
            jWidget = NuiLabel(NuiBind("lblTitle:value"), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
            jWidget = NuiStyleForegroundColor(jWidget, NuiBind("lblTitle:color"));
            jWidget = NuiHeight(jWidget, 35.0);

            jCol = JsonArrayInsert(JSON_ARRAY, NuiRow(JsonArrayInsert(JSON_ARRAY, jWidget)));
        }

        {
            jWidget = NuiText(NuiBind("txtSecondary:value"), FALSE);
            jWidget = NuiStyleForegroundColor(jWidget, NuiBind("txtSecondary:color"));
            jWidget = NuiHeight(jWidget, 75.0);

            JsonArrayInsertInplace(jCol, NuiRow(JsonArrayInsert(JSON_ARRAY, jWidget)));
        }

        NUI_AddLayout(NuiCol(jCol));
    }

    NUI_CreateSubform();
        // ... [optional]

    NUI_CreateDefaultProfile();
        // ... [optional]

    NUI_CreateProfile();
        // ... [optional]
}
```

*** 0.4.9 ***
- Fixed a bug that occurred in an edge case where the nui system was installed in a module, but no formfiles were found during the initialization process.  This bug manifests in a hard-to-track behavior where multiple sql statements, including statements not related to the nui system, were rolled back by the game because an open transaction was never closed by the nui system.

*** 0.4.8 ***
- Fixed a bug that caused the system to cease operation after creating the database, essentially telling the system the database was not created.  This prevent any system operation.  Bug created by tinygiant in 0.4.7.

*** 0.4.7 ***
- Modified `nui_InitializeDatabase()` to check for existing tables before setting the initialization variable on the module.

*** 0.4.6 ***
- Fixed incorrect prototype `NUI_DrawText()` to the correct `NUI_DrawTextbox`.  Thanks to discord user `Tildryn` for the bug report.

*** 0.4.5 ***
- Added convenience function `NUI()`.  This function replaces calls to `NUI_HandleEvents()`.  `NUI_HandleEvents()` is *not* being deprecated and will remain in the system as an available trigger, however, any new implementations can use `NUI()` with the same object parameter you would normally call `NUI_HandleEvents()` with to trigger the NUI system.
- Added missing prototype for `NUI_HandleEvents()`.
- Added convenience function `NUI_CloseLayout()`, which can be used in place of `NUI_CloseColumn()`, `NUI_CloseRow()`, `NUI_CloseGroup()`, or `NUI_CloseListbox()`.  It cannot be used in place of `NUI_CloseCanvas()`.
- Lots of updates to the system's README (this document).  Still plenty of work to go. Some drive-by formatting.

*** 0.4.4 ***
- Added missing prototypes for functions introduced in 0.4.3.

*** 0.4.3 ***
- Added the following functions in preparation for future growth:  `NUI_SetSizeConstraint()`, `NUI_SetEdgeConstraint()`, `NUI_BindSizeConstraint()`, `NUI_BindEdgeConstraint()`.  See the prototypes for additional information and usage.
- Added `NUI_AddCustomControl()`.  This is *very* advanced usage and should only used in special cases.  The only argument this function takes is a json-parseable string representing an entire control.  After adding a control this way, properties cannot be added and the next command must be to add another control or close out the current control container.
- Added `NUI_SetCustomKey()`, which allows a custom key:value pair to be added to the json build at any point.  This is advanced usages.  The key:value pair set with this function may not be generally available during the form usage process, but will be available to advanced methods, such as sql querying.
- Changed the default value for the `collapsed` form property to `null` to allow the user to determine whether the property is set or not through normal definition.  Thanks to discord user `Tildryn` for this bugfix!
- Added `NUI_RepairGeometry()`.  This is advanced usage that can attempt to repair a window in the rare case that a window is not updated after a layout is swapped out, such as with tabbed forms or displaying subforms.  ***WARNING*** Do not rely on this function as it's likely going to be removed.  Considered this function deprecated.

*** 0.4.2 ***
- Modifed json-building methodology to account for characters present in file encodings other than cp1252.  This should allow any game-supported language to display correctly in forms built with this NUI system.  However, the following two rules must be followed for this to work:
> The game must be run in the language associated with the desired encoding (ex: Run the game in Polish)
> The scripts must be compiled with the desired encoding set (ex: Compile with file encoding = cp1250)

- Known Issue:  This change, while allowing other code pages to be used, does not allow `nuiString` to process escaped characters correctly.  If setting a bind, for example in `BindForm()`, you may new to use `jValue` instead of `sValue` for strings.

*** 0.4.1 ***
- Modified `NUI_GetKey()` and `NUI_GetValue()` to use regex instead of character looping.
- Added `nNth` parameter to `NUI_GetValue()` to allow for getting the nNth value in a key:value:value... list.  nNth = 1 retrieves the first value.
- Added `NUI_GetVersions()` which returns the current version of `nui_i_main.nss` and, optionally, the versions all forms loaded into the system.
- Fixed grammatical errors in prototype comments.
- Removed all remaining .34 shims.
- Added prototypes for `NUI_DumpEventData()`, `NUI_GetKey()`, `NUI_GetValue()`.
- Various minor efficiency/readability improvements (drive-by formatting).

*** 0.4.0 ***
- Breaking Change -> NWN 8193.35 is now the minimum requried game version.
- Add automatic handling for NUI_Initialize().  The only call required during the `OnModuleLoad` event is not `NUI_HandleEvents()`.
- Move `sQuery` and `sql` global variables into local scope to prevent conflict with custom user forms.
- Add `NUI_DumpEventData()` to allow event data to be dumped through `NUI_Debug()` as defined in `nui_c_config.nss`.
- Modify `NUI_SetResref()` to automatically assign image resrefs for image buttons for future growth.
- Add `NUI_Set|BindRotation()`, `NUI_Set|BindScale()`, `NUI_Set|BindShear()` and `NUI_Set|BindTranslation()` as future NUI properties.
- Add `NUI_Set|BindTitleColor()` to support title coloring added in .35.
- Add `NUI_AddProperty()` to support future widget addition to NUI.

*** 0.3.0 ***
- Add organic form inspection capability.  This does nothing without the `nui_f_inspector` formfile.  This is a breaking change because of an addition to `nui_c_config`, so the base NUI system minor version has been bumped.  See `nui_c_config` for appropriate configuration and `nui_f_inspector`'s readme for usage.
- Added missing prototype for `NUI_GetEventData()`.
- Added a missing build element for `tabbar` controls.
- Blocked `NUI_SetTooltip` for comboboxes because an attached tooltip prevents the combox from functioning properly.

*** 0.2.3 ***
- Added automatic setting of bind watches.  All `NUI_Bind*` functions (and `nuiBind`) can now be passed an optional `bWatch` parameter.  This default value is `FALSE`.  If `TRUE`, the bind will automatically be watched on form open without user intervention.  This function is only available during form definition.  *Drawlist bind watching is not available with this method.*  The inherent `geometry` bind is set to be watched automatically. 

> ***WARNING*** Do not set the value of watched binds inside the event handler for a watched bind.  This could lead to infinite loops and TMI.

*** 0.2.2 ***
- Modified `NUI_AddListbox` to default to one row instead of null, which allows the listbox to render if the user didn't set or bind the RowCount.
- Modified the automatic binding system to force the initial profile binding and the `BindForm()` formfile function to run after the form has opened, instead of before.  This prevents having to use `NUI_DelayBind` and `NUI_DelayBindJ` to get around the nui feature which clears all binds just before the form open event is fired.
- Added `NUI_SetProfileBindJ`, which has the same function as `NUI_SetProfileBind`, but accepts a json value instead of a json-parseable string.
- Deleted `NUI_DelayBind` and `NUI_DelayBindJ` functions as superfluous.  This could be a breaking change.  To fix, replace all `NUI_DelayBind` calls with `NUI_SetBind` and replace all `NUI_DelayBindJ` calls with `NUI_SetBindJ`.

*** 0.2.1 *** 
- Added `NUI_SetBindJ`, which has the same function as `NUI_SetBind`, but accepts a json value instead of a json-parseable string.

*** 0.2.0 *** 
- This version is a complete system re-write with many breaking changes.  It is not compatible with any 0.1.x formfiles.  However, migration to 0.2.x-compatible formfiles is relatively straight-forward.

## Acknowledgements

First things first.  Thanks to niv and all the great people at Beamdog and on the vault/nwnx discord servers for continuously supporting this game.  Many of the ideas in this system were created in consultation with multiple members of the Neverwinter Vault discord, including Squatting Monk, Zunath, Djinn, Daz and --HA--, among many others.  Thanks for the ideas and beta testing.

>Note: The nui system files will not function without other utility includes from squattingmonk's sm-utils.  You can find these utilities at [Squatting Monk's sm-utils repo](https://github.com/squattingmonk/sm-utils). Many of the utilities are required for this system, but I recommend installing all of them as they add quite a bit of functionality to any module.  These utilities include functions for pattern matching (globs), variable handling (locals and database), function libraries, comma-separated lists, text coloring, maths, unit tests, player targeting, time management and display, script chunk creation, debugging and much more.

## Initial Setup

### Configuration

There are a minimal number of configuration options in `nui_c_config.nss`.  If you are unsure of what they mean or how they are used, leave them alone.  Comments are provided for each configuration option.

The function `NUI_HandleEvents()` or `NUI()` must be run somewhere during your module's `OnModuleLoad` event.  `NUI()` is a convenience function that calls `NUI_HandleEvents()`.  It can be as simple as this:

```c
#include "nui_i_main"

void main()
{
    NUI();
}
```

Additionally, you must integrate the NUI system into your module's NUI event handler, if you have one.  You must `#include "nui_i_main"` and add this line to it somewhere:

```c
#include "nui_i_main"

void main()
{
    NUI();
}
```

That's it!  The basic system should now run.

## Description
This system is designed to allow builders/scripters to fully define NUI forms, controls, layouts, events, profiles and data binds.  Much like `nw_inc_nui.nss`, it is simply a set of functions/wrappers that create the required json structures which define a form.  This version uses a different method in that all definition data is string-based versus json-based, and all json is built using the game's built-in sqlite engine.  In addition, this system also handles all NUI events and, optionally, any other game event that might affect a form.

## Form Definition Approach
NUI uses a top-down approach to building forms.  The base structures are defined first: the form, columns, rows, control groups, etc.  After that, individual controls are placed into structures.  Properties are assigned to individual controls/structures as they are added to the form's layout.

As a form is defined, keep in mind that any function that defines a property will only apply to the most recent control that was defined; e.g. if you define two command buttons, you must assign the desired properties to the first command button before defining the second command button.  This prevents having to carry multiple arguments between various functions.  An example of how this works will be provided later.

>In many of the examples below, you will see various blocks created by using `{ }` which may seem out of place.  Although these blocks define separate scopes and allow re-use of variable names, they are primarily used to designate various window build areas to make visual distinction between areas easier.

## Definitions
* **Form** - in the context of this document, any time the word *form* is used, it will refer to a custom NUI window.  This word is used to prevent confusion between custom NUI windows and the game window.

* **Control** - the various components that can be added to a form to define its structure, content and purpose.  These include components such as textboxes, labels, images, comboboxes, etc.  These may also be referred to as widgets.

* **Property** - the various settings that can be applied to a control or form that define or change the form or control's appearance or behavior.  Most properties can be applied to any control, but not every control will use every applied property.

* **Canvas** - a special type of property that allows a drawing to be applied on top of any control.  Canvases are transparent and can be applied to any control, such as a control group, spacer or command button, but cannot be applied to a structure, such as a row, column or the form object itself.  Any one control may only have one canvas, but a canvas can contain any number of drawings.

* **Drawing** - a set of lines, shapes, text, images and other components that can be drawn on a canvas.  You can put more than one drawing on a single canvas.

* **Vector** - a json-parseable string that defines a set of values used for a specific purpose.  The vector structures available in this system are defined below.

* **Bind** - the ability to attach a desired variable to a specific property of a control.  This allows the value of the bound variable to change and the changes will be reflected immediately on the form.  Bound variables can also be used to return values that have been set on the form by a player.

* **Event** - an occurrence involving the form, such as a mouse click, form closing or bound variable change.  This may also refer to general game events, such as `OnUnaquireItem`, if the builder chooses to subscribe to game events.

## Function Naming Conventions
* All public functions start with `NUI_` to ensure deconflication from other module systems, and are all prototyped for ease of use in the toolset's script editor or via the nwscript language server.  All private functions start with `nui_`.  If you find yourself referring to a private function, you likely need to re-evaluate your design.  Additionally, private functions have no error checking because they're, well, private.  Using them without fully undertanding their purpose could introduce bugs into your form build/function.

* **Add** Functions that start with `NUI_Add` are used to add controls or structures to the current form.

* **Set** Functions that start with `NUI_Set` are used to statically set a property on a form or control.

* **Bind** Functions that atart with `NUI_Bind` are used to dynamically bind a variable name to a form or control property.

* **Close** Functions that start with `NUI_Close` are used to conclude the definition of complex controls and structures.  These are only used for control groups, listboxes, canvases, rows and columns.

## Vector Structures
Some of the controls on NUI forms take vector structures as arguments.  The following helper/convenience functions server to build these vector structures.

* `NUI_DefinePoint(float x, float y)` - takes two float (decimal) arguments and returns a json-parseable string containing the two coordinates.

* `NUI_DefineRectangle(float x, float y, float w, float h)` - takes four float (decimal) arguments to define a specific rectangular area.  For forms, this function can be used to define where the form will appear on the user's screen.  For drawings, this function can be used to define the location of the canvas on the control.  Additionally, rectangle vectors may be used for image regions and form display constraints.

* `NUI_DefineCircle(float x, float y, float r)` - takes a circle center coordinate and radius argument and returns a json-parseable string suitable for defining a rectangle that contains the circle centered at (x, y) with radius r.

* `NUI_DefineRGBColor(int r, int g, int b, int a = 255)` - takes three (optionally four) integer arguments to define a color vector.  These vectors can be used to define foreground colors for various controls as well as line and fill colors for drawings.

* `NUI_DefineHSVColor(float h, float s, float v)` - takes three float arguments to define a color vector based on hue, saturation and value.  These values will be converted to an RGB vector compatible with the NUI system.

* `NUI_DefineHexColor(int nColor)` - takes a single integer argument representing a hex color and converts it to an RGB vector compatible with the NUI system.

* `NUI_DefineRandomRGBColor()` - requires no arguments and returns a random RGB vector compatible with the NUI system.

## Properties
Forms and controls can have several properties assigned to modify their appearance.  Although any property can be assigned to any control, not every property will affect every control.  The following describes how various properties interact with the form and its controls.  Many properties and arguments can be bound to variables specific to individual players.  Binding functions will be discussed here, however, the concept of binding and advanced binding techniques will be discussed later.  Any property that can be bound to a variable can also be set statically, but the form will be less dynamic with static properties.

>Most properties, especially at the form level, have a default value.  All default values will be noted below.  No action is required, and no function need be called, if the default behavior is desired.  Additionally, any default labeled `automatic` means that the system will calculate an appropriate value if none is assigned.

>All properties are optional unless otherwise noted with <r>**(Required)**</r>.  All required properties have a default value except for form geometry.

>All bound properties can be `watched`.  A watched property will trigger an NUI event when the value is changed.  Typically, watched values are used to determine when a user interacts with the form, such as a checkbox is checked or text is typed into a textbox.  To automatically set a bind to be watched, set the second argument of any `NUI_BindXXX()` function to `TRUE`.  To manually watch or unwatch a bind, use `NUI_SetBindWatch()`.

><warn>Setting a bind value in the event handler for watched binds could lead to infinite loops, as the value set in code will trigger another bind watch NUI event.</warn>

### Form-level Properties
The following properties apply only to the form object.

<a id="title"></a>
* <ctl>**Title**</ctl> <b>Default: Bind -> `"title"` `""` (empty string)</b>.  The string provided to this property will appear in the title bar of the form, if the the title bar is displayed.  This property can be bound.
    
    - `NUI_SetTitle(string sTitle)`
    - `NUI_BindTitle(string sVarName, int bWatch = FALSE)`

<a id="title_color"></a>
* <ctl>**Title Color**</ctl> <b>Default: White</b>. The color vector provided to this property will determine the form's title text color.

    - `NUI_SetTitleColor(string sColor)`
    - `NUI_BindTitleColor(string sVarName, int bWatch = FALSE)`

<a id="geometry"></a>
* <ctl>**Geometry**</ctl> <r>**(Required)**</r> <b>Default: Bind -> `"geometry"`</b>.  The geometry provided to this property will determine where the form appears on the player's screen.  Setting the `x` and/or the `y` values to `-1` will cause the window to appear in the center of the user's screen.

    - `NUI_SetGeometry(string sRectangle)` - accepts a rectangle vector created with `NUI_DefineRectangle()`.
    - `NUI_SetCoordinateGeometry(float x, float y, float w, float h)` - allows a user to set the window geometry without first defining a rectangle vector.
    - `NUI_BindGeometry(string sVarName, int bWatch = FALSE)` - designates the variable that will contain a rectangle vector.

<a id="transparent"></a>
* <ctl>**Transparent**</ctl>  <b>Default: `false`</b>.  If set to `TRUE`, the form's background will not be rendered, however the title bar and all controls will still have black backgrounds rendered if they are visible.

    - `NUI_SetTransparent(int bTransparent = TRUE)`
    - `NUI_BindTransparent(string sVarName, int bWatch = FALSE)`

<a id="collapsible"></a>
* <ctl>**Collapsible**</ctl>  <b>Default: `null`</b>. If set to `FALSE`, the player will not have the ability to collapse the form.  When a form is collapsed, only the title bar is visible. If set to `TRUE`, the form will appear as a title bar only (collapsed) when the form is opened.  If set to `NULL`, the form will appear with a collapse button (down arrow) and will be open.

    - `NUI_SetCollapsible(int bCollapsible = TRUE)`
    - `NUI_BindCollapsible(string sVarName, int bWatch = FALSE)`

<a id="resizable"></a>
* <ctl>**Resizable**</ctl> <b>Default: `TRUE`</b>.  If set to `TRUE`, a small resize handle will appear in the lower right corner of the form when the form is not collapsed.  This handle will allow the player to resize the window.  Resizing can have a detrimental effect to the look of the form as the game's NUI system attempts to resize and move control to best fit into the new form space.  To help control this, use [size constaint](#size_constraint).

    - `NUI_SetResizable(int bResizable = TRUE)`
    - `NUI_BindResizable(string sVarName, int bWatch = FALSE)`

<a id="accepts_input"></a>
* <ctl>**Accepts Input**</ctl> <b>Default: `TRUE`</b>.  If set to `FALSE`, the form will never react to mouse hover or input events and any mouse input will "fall-through" to the NWN game window.

    - `NUI_SetAcceptsInput(int bAcceptsInput = TRUE)`
    - `NUI_BindAcceptsInput(string sVarName, int bWatch = FALSE)`

<a id="size_constraint"></a>
* <ctl>**Size Constraint**</ctl> <b>Default: `NULL`</b>.  If set to `NULL`, size constraints will not affect the form's rendering.  Setting any individual value to a float less than or equal to `0.0` will ignore the size constraint for that specific parameter while honoring any parameters set to a positive number.  Setting a maximum parameter on any axis (width, height) to a value less than or equal to the minimum paramater on the same axis will prevent the form from being resized in the dimension.  This property can be bound to a json structure containing the following values which can be defined using `NUI_DefineRectangle()`:
    - `x` = Minimum Width
    - `y` = Minimum Height
    - `w` = Maximum Width
    - `h` = Maximum Height

    - `NUI_SetSizeConstraint(float fMinWidth, float fMinHeight, float fMaxWidth, float fMaxHeight)`
    - `NUI_BindSizeConstraint(string sVarName, int bWatch = FALSE)`

<a id="edge_constraint"></a>
* <ctl>**Edge Constraint**</ctl> <b>Default: `NULL`</b>.  If set to `NULL`, edge constraints will not affect the form's rendering.  Setting any individual value to a float less than or equal to `0.0` will ignore the edge constraint for that specific parameter while honoring any parameters set to a positive number.  Setting any paramater to a value greater than `0.0` will prevent the form from rendering in an area within the distance of the edge of the screen.  This property can be bound to a json structure containing the following values which can be defined using `NUI_DefineRectangle()`:
    - `x` = Left Margin
    - `y` = Top Margin
    - `w` = Right Margin
    - `h` = Bottom Margin

    - `NUI_SetEdgeConstraint(float fLeft, float fRight, float fTop, float fBottom)`
    - `NUI_BindEdgeConstraint(string sVarName, int bWatch = FALSE)`

## Controls and Properties
Controls are the primary method of interaction between the player and form.  The properties listed with these controls are control-specific.  For generic properties that apply to all controls, such as dimensional properties, colors, enabling and visibility, see [properties](#properties).  If control-specific properties are not listed for a specific control, only generic properties are available.

* <ctl>**Spacer**</ctl> Spacers are transparent controls used to optimize positions of controls on a form.  If a control is to be centered on a form, inserting a spacer on either said of the control will force the control into the center of the column or row, depending on orientation.  Additionally, spacers may be used resolve spacing problems as they can act greedily at times and take up layout space that otherwise would have been left in by the layout system.

    <fg>**Controls:**</fg>
    - `NUI_AddSpacer()` - adds a spacer.

    <fg>**Properties:**</fg>
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)
    
* <ctl>**Label**</ctl>  Labels are non-interactive controls used to convey information or define a control's use for the player.  Typically, a label will be associated with another control, but this is not required.

    <fg>**Controls:**</fg>
    - `NUI_AddLabel()`

    <fg>**Properties:**</fg> [[dimensions]](#common-dimensional-properties) [[interaction]](#common-interaction-properties)
    - `NUI_[Set|Bind]Label()` - text that will be displayed on the label [**...**](#label)
    - `NUI_[Set|Bind]HorizontalAlignment()` [**...**](#alignment)
    - `NUI_[Set|Bind]VerticalAlignment()` [**...**](#alignment)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Textbox**</ctl>  NUI has two types of textboxes: interactive and static.  An interactive textbox allows the user to input text.  This requires a bound value.  Interactive textboxes without bound values will not work correctly.  Static textboxes are much like labels, but with borders and a scrollbar.  By default, this system builds interactive textboxes, but you can modify it with the `NUI_SetStatic()` function.

    <fg>**Controls:**</fg>
    - `NUI_AddTextbox()` - adds an interactive textbox.
    - `NUI_SetStatic()` - set textbox to non-interactive.

    <fg>**Properties:**</fg> (interactive textboxes)
    - `NUI_[Set|Bind]Placeholder()` - placeholder text displayed when the textbox is empty. [**...**](#placeholder)
    - `NUI_[Set|Bind]Value()` - the textbox's value; a bound value is required for interactive textboxes. [**...**](#value)
    - `NUI_SetLength()` - maximum number of characters the user can enter. [**...**](#length)
    - `NUI_SetMultiline()` - allow the user to enter newlines. [**...**](#multiline)
    - `NUI_SetWordWrap()` - allow the textbox to wrap text values. [**...**](#wordwrap)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

    <fg>**Properties:**</fg> (non-interactive textboxes)
    - `NUI_[Set|Bind]Value()` [**...**](#value)
    - `NUI_SetBorder()` [**...**](#border)
    - `NUI_SetScrollbars()` [**...**](#scrollbars)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Command Button**</ctl> Command buttons are controls that perform specific functions when clicked by the player.  When clicked, the control background temporarily changes to show the button was clicked.

    <fg>**Controls:**</fg>
    - `NUI_AddCommandButton()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Label()` - text that will be displayed on the button. [**...**](#label)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Image Button**</ctl> An image button is the same as a command button, however, instead of a caption an image is displayed on the button.

    <fg>**Controls:**</fg>
    - `NUI_AddImageButton()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Resref()` - resref of image to display, less the file extension. [**...**](#resref)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Toggle Button**</ctl>  A toggle button is similar to a command button, but will latch when clicked, returning a value of `0` (not latched) or `1` (latched).  When latched, the control's background will be a dark blue textured pattern.  Toggle buttons without value binds will not latch.

    <fg>**Controls:**</fg>
    - `NUI_AddToggleButton()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Label()` - text that will be displayed on the button. [**...**](#label)
    - `NUI_[Set|Bind]Value()` - whether the toggle button is toggled. [**...**](#value)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)


* <ctl>**Checkbox**</ctl> A checkbox is a combination control that contains both a square (checkbox) and a label to the right of the square, which defines its purpose.

    <fg>**Controls:**</fg>
    - `NUI_AddCheckbox()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Label()` - text that will be displayed to the left of the checkbox. [**...**](#label)
    - `NUI_[Set|Bind]Value()` - whether the checkbox is checked. [**...**](#value)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Image**</ctl> An image control displays an image.

    <fg>**Controls:**</fg>
    - `NUI_AddImage()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Resref()` - resref of image to display, less the file extension. [**...**](#resref)
    - `NUI_[Set|Bind]Aspect()` - NUI_ASPECT_* [**...**](#aspect)
    - `NUI_[Set|Bind]HorizontalAlignment()` - NUI_HALIGN_* [**...**](#alignment)
    - `NUI_[Set|Bind]VerticalAlignment()` - NUI_VALIGN_* [**...**](#alignment)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Combobox**</ctl>  A combobox is a dropdown list of options from which a player can select one.  The selected option will appear in the combobox after selection.

    <fg>**Controls:**</fg>
    - `NUI_AddComboBox()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Elements()` - elements to be displayed in the combobox. [**...**](#elements)
    - `NUI_[Set|Bind]Value()` - the element currently selected. [**...**](#value)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Slider**</ctl> Creates a line with a pointer (slider) on it.  The bounds and step of the slider can be defined as floats or ints.

    <fg>**Controls:**</fg>
    - `NUI_AddIntSlider()`
    - `NUI_AddFloatSlider()`

    <fg>**Properties:**</fg>
    - `NUI_SetIntSliderBounds()` [**...**](#bounds)
    - `NUI_SetFloatSliderBounds()` [**...**](#bounds)
    - `NUI_BindSliderBounds()` [**...**](#bounds)
    - `NUI_[Set|Bind]Value()` - current value of the slider. [**...**](#value)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Progress Bar**</ctl>  Creates a progress bar which displays a value between 0.0 and 1.0.

    <fg>**Controls:**</fg>
    - `NUI_AddProgressBar()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Value()` [**...**](#value)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Listbox**</ctl>  Listboxes display a list of repeated row templates, but populated with different data for each row.  The player can select a single item in a listbox to return the index of the item selected.  Once a listbox is added, the controls that make up the row template can be added.  Once all the controls are added, `NUI_CloseListbox()` must be called.

    <fg>**Controls:**</fg>
    - `NUI_AddListbox()`
    - `NUI_CloseListbox()`

    <fg>**Properties:**</fg>
    - `NUI_SetRowHeight()` [**...**](#rowheight)
    - `NUI_SetBorder()` [**...**](#border)
    - `NUI_SetScrollbars()` [**...**](#scrollbars)
    - `NUI_[Set|Bind]RowCount()` [**...**](#rowcount)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Color Picker**</ctl>  The color picker control displays a simple color picker that allows the player to designate a color.

    <fg>**Controls:**</fg>
    - `NUI_AddColorPicker()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Value()` [**...**](#value)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Option Group**</ctl>  An option group contains a set of radio buttons (circles with text next to them).  Only one radio button within an option group may be selected at a time.

    <fg>**Controls:**</fg>
    - `NUI_AddOptionGroup()`

    <fg>**Properties:**</fg>
    - `NUI_SetDirection()` [**...**](#direction)
    - `NUI_[Set|Bind]Elements()` [**...**](#elements)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Chart**</ctl>  A chart control can display either a bar or line graph.

    <fg>**Controls:**</fg>
    - `NUI_AddChart()`

    <fg>**Properties:**</fg>
    - `NUI_SetChartSeries()` [**...**](#chart-series)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

* <ctl>**Control Group**</ctl>  Control Groups are controls which contain other controls.  Control groups can be thought of as miniature forms within the main form.  Because of the nature of control groups and how the build process in the this system works, `NUI_CloseControlGroup()` must be called when the definition of the control group, including its controls, is complete.  A control group must be assigned an [id](#id) if it will be the target of a layout change/subform display.

    <fg>**Controls:**</fg>
    - `NUI_AddControlGroup()`
    - `NUI_CloseControlGroup()`

    <fg>**Properties:**</fg>
    - `NUI_SetBorder()` [**...**](#border)
    - `NUI_SetScrollbars()` [**...**](#scrollbars)
    - [Common Dimensional Properties](#common-dimensional-properties)
    - [Common Interaction Properties](#common-interaction-properties)

### Common Dimensional Properties
The following properties control the sizing of form controls and must be assigned constant values (binding is not allowed for these properties).  These properties can be applied to any control.  If width, height or aspect are not defined for any specific control, row or column, the game will make its best guess for layout sizes and dimensions.  If you are unhappy with the result, setting dimensions on a few key controls will help constrain the overall layout solution.

<a id="width"></a>
* <ctl>**Width**</ctl> <b>Default: automatic</b>.  Sets the width of the control in pixels.  This property cannot be bound.  See notes at `Aspect` below.

    - `NUI_SetWidth(float fWidth)`

<a id="height"></a>
* <ctl>**Height**</ctl> <b>Default: automatic</b>.  Sets the height of the control in pixels.  This property cannot be bound.  See notes at `Aspect` below.

    - `NUI_SetHeight(float fHeight)`

<a id="aspect"></a>
* <ctl>**Aspect**</ctl> <b>Default: `NUI_ASPECT_FIT`</b>. Sets the aspect (ratio of x/y or width/height) applied to various images and controls.  For controls, this property cannot be bound, for images it can.
    > <warn>A maximum of two of the properties `width`, `height` and `aspect` can be set on any individual control.  Since they relate to each other, the system cannot resolve a conflict if all three are set and **the form will not render**.</warn>

    For images:  An int value designating one of the following pre-defined constants:
    * NUI_ASPECT_FIT
    * NUI_ASPECT_FILL
    * NUI_ASPECT_FIT100
    * NUI_ASPECT_EXACT
    * NUI_ASPECT_EXACTSCALED
    * NUI_ASPECT_STRETCH
    
    - `NUI_SetAspect(int nAspect)`

    For controls:  A float (decimal) value designating the x/y or width/height ratio, such as `16.0/9.0`.

    - `NUI_SetAspectRatio(float fAspect)`

<a id="margin"></a>
* <ctl>**Margin**</ctl> <b>Default: automatic.</b>  Sets the spacing outside of a control and determines how close other controls can be to the current control.

    - `NUI_SetMargin(float fMargin)`

<a id="padding"></a>
* <ctl>**Padding**</ctl> <b>Default: automatic.</b>  Sets the spacing inside the control.

    - `NUI_SetPadding(float fPadding)`

<a id="interaction_convenience_functions"></a>
* <ctl>**Convenience Functions</ctl>

    - `NUI_SetDimensions(float fWidth, float fHeight)` - Set height and width properties in one function.
    - `NUI_SetSquare(float fSide)` - Set height and width properties to the same value.

#### Common Interaction Properties
The following proprties control the user's interaction with controls.  These properties can be set on any control, including rows and columns.

<a id="enabled"></a>
* <ctl>**Enabled**</ctl> <b>Default: `TRUE`</b>.  Disabled controls cannot be interacted with and will not send NUI events.  If bound, this property will default to `FALSE` until the bind is explicitly set to `TRUE`.

    - `NUI_SetEnabled(int bEnabled = TRUE)`
    - `NUI_BindEnabled(string sVarName)`

<a id="visible"></a>
* <ctl>**Visible**</ctl> <b>Default: `TRUE`</b>.  Determines whether a control is visible on the form.  Invisible controls take up layout space as if their were visible, but they are not rendered, cannot be interacted with and do not signal events.  If bound, this property will default to `FALS` until the bind is explicity set to `TRUE`.

    - `NUI_SetVisible(int bVisible = TRUE)`
    - `NUI_BindVisible(string sVarName)`

<a id="id"></a>
* <ctl>**ID**</ctl> <b>Default: none</b>.  A control's id is returned with NUI event information.  If a control is not assigned an ID, NUI events will not fire for that control.  For convenience, IDs can be added with any `Add*` (e.g. `AddCommandButton("command_button_1")`) function instead of being set separately.

    - `NUI_SetID(string sID)`

    > Setting IDs is an important step in the form definition process.  For the game's implementation, controls must have IDs assigned in order to trigger events.  Controls without IDs assigned will not trigger user events, such as click. Avoid setting IDs for controls that do not require events as any control with an event will signal multiple NUI events when interacted with.

#### Control-specific Properties
The following properties are control-specific.  See the [controls and properties](#controls-and-properties) section above for details on which properties apply to specific controls.  Given that an NUI form's structure is json-based, any property can be assigned to any control, however, only specified properties will have any effect on the control.

<a id="border"></a>
* <ctl>**Border**</ctl> <b>Default: `TRUE`</b>.  If set to `FALSE`, the form or control's border will not be visible.

    - `NUI_SetBorder(int bVisible = TRUE)`
    - `NUI_BindBorder(string sVarName, int bWatch = FALSE)`

<a id="value"></a>
* <ctl>**Value**</ctl> <b>Default: `NULL`</b>.  Value is a unique property that does not do any conversion to the passed string.  The string must be a json-parseable string, usually created with a convenience function such as `nuiString()` or `nuiFloat()`.  This value will be set directly into the control's json and allows some flexibility in how the control's value is assigned.

    - `NUI_SetValue(string sValue)`
    - `NUI_BindValue(string sVarName, int bWatch = FALSE)`

<a id="tooltip"></a>
* <ctl>**Tooltip**</ctl> <b>Default: none</b>.  Sets the tooltip that appears when a player hovers a mouse pointer over an enabled control.  If `bDisabledTooltip` is passed as `TRUE`, this function will also set the control's `DisabledTooltip` property to `sTooltip`.

    - `NUI_SetTooltip(string sTooltip, int bDisabledTooltip = FALSE)`
    - `NUI_BindTooltip(string sVarName, int bWatch = FALSE)`

<a id="disabled-tooltip"></a>
* <ctl>**Disabled Tooltip**</ctl> <b>Default: none</b>.  Sets the tooltip that appears when a player hovers a mouse pointer over a disabled control.

    - `NUI_SetDiabledTooltip(string sTooltip)`
    - `NUI_BindDisabledTooltip(string sVarName, int bWatch = FALSE)`

<a id="foreground-color"></a>
* <ctl>**Foreground Color**</ctl> <b>Default: (255, 255, 255, 255)</b>. Sets the control's foreground color.  This has different effects for different controls.  For text-based controls, it changes the color of the text.  For progress bars, it changes the color of the progress bar.

    - `NUI_SetForegroundColor(string sColor)`
    - `NUI_BindForegroundColor(string sVarName, int bWatch = FALSE)`

<a id="alignment"></a>
* <ctl>**Alignment**</ctl> Text and images can be aligned, both vertically and horizontally, within their controls.  

    - `NUI_SetHorizontalAlignment(int nAlignment)`
    - `NUI_BindHorizontalAlignment(string sVarName, int bWatch = FALSE)`

        - NUI_HALIGN_CENTER
        - NUI_HALIGH_LEFT
        - NUI_HALIGN_RIGHT

    - `NUI_SetVerticalAlignment(int nAlignment)`
    - `NUI_BindVerticalAlignment(string sVarName, int bWatch = FALSE)`

        - NUI_VALIGN_MIDDLE
        - NUI_VALIGN_TOP
        - NUI_VALIGN_BOTTOM

<a id="resref"></a>
* <ctl>**Resref**</ctl> Sets the resref for image-based controls.

    - `NUI_SetResref()`
    - `NUI_BindResref(string sVarName, int bWatch = FALSE)`

<a id="placeholder"></a>
* <ctl>**Placeholder**</ctl> <b>Default: none</b>.  Sets the placeholder text displayed in a non-static textbox.  This text will disappear when the player starts typing a value into the textbox and will re-appear if the player deletes all text from the textbox.

    - `NUI_SetPlaceholder()`
    - `NUI_BindPlaceholder(string sVarName, int bWatch = FALSE)`

<a id="length"></a>
* <ctl>**Length**</ctl> <b>Default: `50`</b>.  Sets the maximum number of characters a player can type into a textbox.

    - `NUI_SetLength()`
    - `NUI_BindLength(string sVarName, int bWatch = FALSE)`

<a id="multiline"></a>
* <ctl>**Multiline**</ctl> <b>Default: `FALSE`</b>.  Determines whether a textbox is considered multiline. For static textboxes, this implies an automatic word-wrap feature.  Non-static textboxes do not have automatic word-wrap and users must manually insert line-breaks and paragraphs by pressing enter.

    - `NUI_SetMultiline()`

<a id="rowcount"></a>
* <ctl>**Row Count**</ctl> <b>Default: `0`</b>.  Sets the row count of a listbox.

    - `NUI_SetRowCount()`
    - `NUI_BindRowCount(string sVarName, int bWatch = FALSE)`

<a id="rowheight"></a>
* <ctl>**Row Height**</ctl> <b>Default `25.0`</b>.  Sets the row height of a listbox.

    - `NUI_SetRowHeight()`
    - `NUI_BindRowHeight(string sVarName, int bWatch = FALSE)`

<a id="checked"></a>
* <ctl>**Checked**</ctl> <b>Default `FALSE`</b>.  Sets whether a checkbox control is checked or blank.

    - `NUI_SetChecked()` - must be set to `true` or `false`.
    - `NUI_BindChecked(string sVarName, int bWatch = FALSE)` - must be bound to a boolean value.

<a id="scissor"></a>
* <ctl>**Scissor**</ctl>  <b>Default: `FALSE`</b>.  Used only for canvases, this properties determines whether any portion of the drawing which overflows the size dimensions of the control it is based on will be trimmed to the control dimensions.

    - `NUI_SetScissor()`

<a id="scrollbars"></a>
* <ctl>**Scroll Bars**</ctl>

    - `NUI_SetScrollbars()`

<a id="canvas"></a>
* <ctl>**Canvas**</ctl> A canvas allows drawings to be applied to a control.  A canvas is the top display layer of a control, so adding drawings such as images may cover up other parts of the control, such as labels.

    <fg>**Controls:**</fg>
    - `NUI_AddCanvas`
    - `NUI_DrawLine()`
    - `NUI_DrawRectangle()`
    - `NUI_DrawCircle()`
    - `NUI_DrawText()`
    - `NUI_DrawCurve()`
    - `NUI_DrawArc()`
    - `NUI_DrawImage()`
    - `NUI_CloseCanvas()`

    <fg>**Properties:**</fg>

# Using Formfiles
Formfiles are a type of `.nss` that contain several functions which define, bind and react to events for a specific form or forms.  For those experienced with tag-based scripting, the idea is similar in that all code for a single form can be contained in a single script. Formfiles can be created as pre-compiled scripts (for performance) or as compile-on-demand scripts.  Pre-compiled scripts must `#include "nui_i_library"` in order to be setup correctly.  This script contains the formfile's `void main()` function, so a `main` function should not be included in your formfile.  If `nui_i_library` is not included, the formfile is assumed to be compiled-on-demand and will be compiled as required using script chunks.  Compile-on-demand formfiles, however, are still required to `#include "nui_i_main"` in place of `#include "nui_i_library"`.

// TODO 

Following is a basic formfile.  Other examples of varying complexity, including a template formfile, can be found in this repo's `formfiles` folder.  A formfile has four required functions to work under this sytem.  The functions need not contain any code at all, but they must exist.
- `void DefineForm()` - Contains all code required to define the form, subforms and profiles
- `void BindForm()` - Optional code to set intial binds after the form opens; usually used for binds that aren't already set in a profile.
- `void HandleNUIEvents()` - Handles all NUI-related events, such as bind watches, form open/close, mouse events, etc.
- `void HandleModuleEvents()` - Handles all non-NUI-related events, such as triggers from organic module events.  NWNX event management can be integrated into this function.
```cpp
#include "nui_i_main"

void DefineForm()
{
    NUI_CreateForm("textbox_form");
        // You can subscribe to module-level and NWNX events here.  Although NWNX events are only lightly
        //  integrated here as the system is designed around the base game functions.  However, responding
        //  to NWNX events works almost exactly the same as responding to a traditional module function.
        NUI_SubscribeEvent(EVENT_SCRIPT_MODULE_ON_MODULE_LOAD);

        // Setting the geometry will override the default "geometry" bind and will also prevent any geometry binding that may be set in a profile.
        NUI_SetGeometry(-1.0, -1.0, 400.0, 500.0);
    {
        NUI_AddTextbox();
            NUI_SetWidth(350.0);
            NUI_SetHeight(450.0);
            NUI_SetMultiline(TRUE);
            NUI_SetMaxLength(500);
            NUI_SetWordWrap(TRUE);
            NUI_BindPlaceholder("textbox_placeholder");
            NUI_BindValue("textbox_value");
    } NUI_SaveForm();
}

void BindForm()
{
    // Orphan binds are any binds that exist in the form's definition, but were not assigned values in the profile the form is currently using.
    // Only orphan binds will be looped in this function.  To override other binds, you can add code below the loop (or replace the loop with your own code).
    json jBinds = NUI_GetOrphanBinds(FORM_ID);
    int n; for (n; n < JsonGetLength(jBinds); n++)
    {
        string sValue, sBind = JsonGetString(JsonArrayGet(jBinds, n));
        json jValue = JsonNull();
   
        // Add code here to set any binds that you want set which aren't already included in a profile bind.
        //  You can set sValue to a json-parseable string, usually created with nuiString, nuiFloat, and the
        //  other nuiXXX() functions.  If you want to set the json value directly, set jValue.
        if (sBind == "some_bind_name")
            jValue = JsonString("some bind value");
        else if (sBind == "some_other_bind_name")
            sValue = nuiString("yet another bind value");

        // This section assigns the binds.  If using this example code, do not change this section.
        if (sValue != "")
            NUI_SetBind(OBJECT_SELF, FORM_ID, sBind, sValue);
        else if (jValue != JsonNull())
            NUI_SetBindJ(OBJECT_SELF, FORM_ID, sBind, jValue);
    }
}

void HandleNUIEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    // NUIEventData provides the following elements:
    //  object oPC - the PC object interacting with the subject form
    //  int    nFormToken - the token of the subject form
    //  string sFormID - the form ID as assigned during the form definition process
    //  string sEvent - the event type (click, mousedown, mouseup, mousescroll, open, close, watch)
    //  string sControlID - the ID of the control that triggered the event
    //  int    nIndex - the index of the control in a list, if the control is in a list
    //  json   jPayload - the event payload, which varies by event (usually includes mouse position)

    // When building/debugging formfiles, you can use NUI_DumpEventData(ed); to dump the event
    //  data to be displayed through whatever debugging system you are using as attached through
    //  NUI_Debug() in `nui_c_config.nss`.
    if (ed.sEvent == "open")
        Notice("Look, ma! I opened the '" + ed.sFormID + "' form!");      
}

void HandleModuleEvents()
{
    int nEvent = GetCurrentlyRunningEvent();
    if (nEvent == EVENT_SCRIPT_MODULE_ON_MODULE_LOAD)
        //Run OnModuleLoad code here
    {}
}

```

# Binding

> The term `bind` in this context refers to the variable set in a bind function such as `NUI_BindGeometry("my_geometry");`.  In this example, the `bind` is `"my_geometry"`.

There is no requirement to use this system's functions to set binds, however this system provides several functions to make binding easier for the novice scripter.  No matter the method used, binding requires some basic knowledge of the `json` datatype and converting various primitive types into `json`.  The conversion functions are base-game functions and not part of this system:

### **Bind Data**

When a bind script or function is run by this system, bind data is made available to the script/function.  This data is retrieved using two functions that return read-only data structures.

The primary structure is retrieved using this method:
```c
struct NUIBindData bd = NUI_GetBindData();
```
This will retrieve a custom structure that contains data necessary to set bind values.  The following elements are included:

* sFormID - the form ID as assigned during the form definition process
* nToken - the token of the focus form
* jBinds - a JsonArray of NUIBindArrayData[] (see below)
* nCount - the number of elements in jBinds

The second structure is a child of the primary structure.  It is retrieved using data from the primary structure (as shown above) and should be called in a loop to retrieve desired data from the `jBinds` array:
```c
struct NUIBindData bd = NUI_GetBindData();
int n;

for (n = 0; n < bd.nCount; n++)
{
    struct NUIBindArrayData bad = NUI_GetBindArrayData();

    // Set binds here
}
```
This will retrieve a custom structure that contains data necessary to set bind values.  The following elements are included:

* sType - the type of control that has a bind from the `NUI_ELEMENT_*` constants list in `nui_i_const.nss`
* sProperty - the control property that has the bind value from the `NUI_PROPERTY_*` constants list in `nui_i_const.nss`
* sBind - the bind variable assigned during the form definition process
* jUserData - a JsonObject of user data (if any) as assigned in the form definition process

### **Setting a Bound Value**

Once bind data has been calculated and is ready to be set, there are two options available for setting the data to the bound variable.

The first is using the general binding function `NUI_SetBind()`.  It requires four arguments:
* `oPC` - the PC object interacting with the subject form
* `nToken` - the token of the subject form
* `sBind` - the bind variable that is being set
* `sValue` - a json-parseable string that represents that value being bound.

```c
NUI_SetBind(oPC, nFormToken, sBind, sValue)
```

The third option is to directly set the bind with the base-game function `NuiSetBind()`.

# Events

