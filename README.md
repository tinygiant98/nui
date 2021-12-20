## Change Log

*** 0.1.0 *** - This marks the first version-controlled wrapper.  Breaking changes will be kept to a minimum for all the primary form-definition functions.

## Acknowledgements

First things first.  Thanks to niv and all the great people at Beamdog for continuously supporting this game.  Many of the ideas in this system were created in consultation with multiple members of the Neverwinter Vault discord, including Zunath, The WonderMaker, Daz and --HA--, among many others.  Thanks for the ideas and beta testing.

>Note: The nui system files will not function without other utility includes from squattingmonk's sm-utils.  These utilities can be sourced from this repo under the `utils` folder.  However, when this system reaches its final resting place, you might have to visit squattingmonk's nwn-core-framework or sm-utils repo to obtain these files.  Specificially, the following files are required:  util_i_color.nss, util_i_csvlists.nss, util_i_debug.nss, util_i_math.nss, util_i_string.nss

>*** WARNING *** This documentation is still a work-in-progress.  If anything in this documentation doesn't work the way you expect, refer to the code or find me on the Neverwinter Vault Discord...

## Installation

### Methods

* nasher - If you use `nasher` as you module build tool, you can clone this repo and place the location of the cloned repo into an `include` directive in your module's `nasher.cfg` configuration file.  If you already utilize Squatting Monk's `sm-utils`, you will need to `exclude` the utils folder to ensure utility files are not overwritten.

* erf - If you are using the toolset to build your module, download `nui.erf` and import it into your module, then compile/build.  If you don't have the sm-util files in your module, download and import `nui_utils.erf`.

### Configuration

There are multiple configuration options in `nui_i_config.nss`.  If you are unsure of what they mean or how they are used, leave them alone.  The default configuration file is designed to ensure all standard formfiles will run correctly without compilation.

The NUI function `NUI_Initialize()` must be run somewhere during your module's `OnModuleLoad` event.  It can be as simple as this:

```c
#include "nui_i_main"

void main()
{
    NUI_Initialize();
}
```

Additionally, you must integrate the NUI system into your module's NUI event handler, if you have one.  If you don't already have one, this system will set it up for you automatically.  If you do already have one, go to the configuration file `nui_i_config`, find the `NUI_SetEventHandler()` function, and comment out (or change) the line that assigns the event handler.

If you already have an NUI event handler, you must `#include "nui_i_main"` and add this line to it somewhere:

```c
    NUI_RunEventHandler();
```

That's it!  The basic system should now run.

## Known Bugs/Issues
The following issues are limitations of the NUI implementation and not causes by code in this repo.  Feel free to add any bugs you find in the issues section of this repo and they can be tested to determine if they're caused by this repo or by the game's implementation.

**Drawing/Canvas** Controls that have drawings/canvases added to them will prevent other controls within the column/row from rendering.  One solution is to wrap controls with canvases in a control group.  Another is to put them in a separate column/row within the same control group.

**Drawing/Canvas** Images and text rendered via `NUI_DrawText` and `NUI_DrawImage` will be drawn on the top layer of the window and are not bound by window/control limits if applied to a control that can scroll (control groups, etc.).  Additionally, images rendered via `NUI_DrawImage` will be drawn on top of any other controls, so they cannot be used as background images.

## Description
This system is designed to allow builders/scripters to fully define NUI forms, controls, layouts, events and data binds.  The vast majority of commands are easy to use, however there is some advanced usage, particularly in the area of drawing various shapes on top of controls and running form events, that requires more in depth knowledge of json structures.  Those requirements will be described in detail below.

## Form Definition Approach
The system uses a top-down, big-to-small approach to building forms.  The base structures are defined first: the window, columns, rows, control groups, etc.  After that, individual controls are placed into structures.  Finally, properties are assigned to individual controls.

As a window is defined, keep in mind that any function that defines a property will only apply to the most recent control that was defined, e.g. if you define two command buttons, you must assign the desired properties to the first command button before defining the second command button.  This prevents having to carry multiple arguments between various functions.  An example of how this works will be provided later.

>In many of the examples below, you will see various blocks created by using `{ }`.  These blocks do not define scope as much as they are used to designate various window build areas to make visual distinction between areas easier.

## Definitions
* **Form** - in the context of this document, any time the word *form* is used, it will refer to a custom NUI window.  This word is used to prevent confusion between custom NUI windows and the game window.

* **Control** - the various components that can be added to a form to define its structure, content and purpose.  These include components such as textboxes, labels, images, comboboxes, etc.  These may also be referred to as widgets.

* **Property** - the various settings that can be applied to a control or form that define or change the form or control's appearance or behavior.  Most properties can be applied to any control, but not every control will use every applied property.

* **Canvas** - a special type of property that allows a drawing to be applied on top of any control.  Canvases are transparent, but are applied as the top layer of the control, so any drawings on a canvas may hide details of the control.  Any one control may only have one canvas.

* **Drawing** - a set of lines, shapes, text, images and other components that can be drawn on a canvas.  You can put more than one drawing on a single canvas.

* **Vector** - a specific structure, normally of type `json` that defines a set of values used for a specific purpose.  The vector structures available in this system are defined below.

* **Bind** - the ability to attach a desired variable to a specific property of a control.  This allows the value of the bound variable to change and the changes will be reflected on the form.  Bound variables can also be used to return values that have been set on the form by a player.

* **Event** - an occurrence involving the form, such as a mouse click, form closing or bound variable change.

## Function Naming Conventions
* All public functions start with `NUI_` to ensure deconflication from other module systems.

* **Add** Functions that start with `add` are used to add controls to the current form.

* **Set** Functions that start with `set` are used to statically set a property on a form or control.

* **Bind** Functions that start with `bind` are used to dynamically link a specified variable with a values from a form's various controls.

* **Close** Functions that start with `close` are used to conclude the definition of complex controls.  These are only used for control groups, listboxes and canvases.

* **Save** Functions that start with `save` are used to conclude the definition of a major form element, such as template controls or the form itself.

## Vector Structures
Some of the controls on NUI forms take vector structures as arguments.

* `NUI_DefinePoint(float x, float y)` - takes two float (decimal) arguments and returns a json objecting containing the two coordinates.

* `NUI_DefineRectangle(float x, float y, float w, float h)` - takes four float (decimal) arguments to define a specific rectangular area.  For forms, this function can be used to define where the window will appear on the user's screen.  For drawings, this function can be used to define the location of the canvas on the control.

* `NUI_DefineCircle(float x, float y, float r)` - takes a circle center coordinate and radius argument and returns a json structure suitable for defining a rectangle that contains the circle centered at (x, y) with radius r.

* `NUI_DefineRGBColor(int r, int g, int b, int a = 255)` - takes three (optionally four) integer arguments to define a color vector.  These vectors can be used to define foreground colors for various controls as well as line and fill colors for drawing.

* `NUI_DefineHSVColor(float h, float s, float v)` - takes three float arguments to define a color vector based on hue, saturation and value.  These values will be converted to an RGB vector compatible with the NUI system.

* `NUI_DefineHexColor(int nColor)` - takes a single integer argument representing a hex color and converts it to an RGB vector compatible with the NUI system.

* `NUI_DefineRandomRGBColor()` - requires no arguments and returns a random RGB vector compatible with the NUI system.

## Controls
Controls are the primary method of interaction between the player and form.

* **Spacer** Spacers are transparent control used to optimize positions of controls on a form.  If a control is to be centered on a form, inserting a spacer on either said of the control will force the control into the center of the column or row, depending on orientation.  

    `NUI_AddSpacer()` - adds a spacer.

* **Label**  Labels are non-interactive controls used to convey information or deifine a control's use for the player.  Typically, a label will be associated with another control, but this is not required.

    `NUI_AddLabel()`

* **Textbox**  NUI has two types of textboxes: interactive and static.  An interactive textbox allows the user to input text.  This requires a bound value.  Interactive textboxes without bound values will not work correctly.  Static textboxes are much like labels, but with borders and a scrollbar that you can't turn off.  By default, this system builds interactive textboxes, but you can modify it with the `NUI_SetStatic()` function.

    `NUI_AddTextbox()` - adds an interactive textbox.

    `NUI_SetStatic()` - sets the textbox to static, which prevents the user from interacting with it.

* **Command Button** Command buttons are controls that perform specific functions when clicked by the player.  When clicked, the control background temporarily changes to show the button was clicked.

    `NUI_AddCommandButton()`

* **Image Button** An image button is the same as a command button, however, instead of a caption an image is displayed on the button.

    `NUI_AddImageButton()`

* **Toggle Button**  A toggle button is similar to a command button, but will latch when clicked, returning a value of `0` (not latched) or `1` (latched).  When latched, the control's background will be a dark blue textured pattern.  Toggle buttons without value binds will not latch.

    `NUI_AddToggleButton()`

* **Checkbox** A checkbox is a combination control that contains both a square (checkbox) and a label to the right of the square, which defines its purpose.

    `NUI_AddCheckbox()`

* **Image** An image control displays an image.

    `NUI_AddImage()`

* **Combobox**  A combobox is a dropdown list of options from which a player can select one.  The selected option will appear in the combobox after selection.

    `NUI_AddComboBox()`

* **Slider** Creates a line with a pointer (slider) on it.  The bounds and step of the slider can be defined as floats or ints.

    `NUI_AddIntSlider()`

    `NUI_AddFloatSlider()`

* **Progress Bar**  Creates a progress bar which displays a value between 0.0 and 1.0.

    `NUI_AddProgressBar()`

* **Listbox**  Listboxes display a list of repeated row templates, but populated with different data for each row.  The player can select a single item in a listbox to return the index of the item selected.  Once a listbox is added, the controls that make up the row template can be added.  Once all the controls are added, `NUI_CloseListbox()` must be called.

    `NUI_AddListbox()`

    `NUI_CloseListbox()`

* **Color Picker**  The color picker control displays a simple color picker that allows the player to designate a color.

    `NUI_AddColorPicker()`

* **Option Group**  An option group contains a set of radio buttons (circles with text next to them).  Only one radio button within an option group may be selected at a time.

    `NUI_AddOptionGroup()`

    `NUI_AddRadioButton()`

    `NUI_AddRadioButtonList()`

* **Chart**  A chart control can display either a bar or line graph.

    `NUI_AddChart()`

    `NUI_AddChartSeries()`

* **Control Group**  Control Groups are controls which contain other controls.  Control groups can be thought of as miniature forms within the main form.  Because of the nature of control groups and how the build process in the this system works, `NUI_CloseControlGroup()` must be called when the definition of the control group, including its controls, is complete.

    `NUI_AddControlGroup()`

    `NUI_CloseControlGroup()`

* **Template Controls**  Scripters may create template controls to prevent repeated effort during form definition.  For example, if a form requires multiple labels that are all the same size, a template control can be created before form definition and then added multiple times during form definition.  Properties specific to the control instance can be modified when inserted.  Template controls may only contain one base control, however that base control can be a control group that contains other controls.  All templated control definitions must be followed by `NUI_SaveTemplateControl()`.

    `NUI_CreateTemplateControl()`

    `NUI_SaveTemplateControl()`

    `NUI_AddTemplateControl()`

This is an example of template control usage:

```c
    NUI_CreateTemplateControl("cp_label");
    {
        NUI_AddLabel();
            NUI_SetHeight(25.0);
            NUI_SetWidth(150.0);
    } NUI_SaveTemplateControl();

    NUI_CreateForm("my_new_form");
    {
        // Add a template label, make it wider than the template, and add a bind
        NUI_AddTemplateControl("cp_label");
            NUI_SetWidth(250.0);        
            NUI_BindLabel("label1");

        // Add a template control, only adding a bind
        NUI_AddTemplateControl("cp_label");
            NUI_BindLabel("label2");
    } NUI_SaveForm();
```

## Properties
Forms and controls can have several properties assigned to modify their appearance.  Although any property can be assigned to any control, not every property will affect every control.  The following describes how various properties interact with the form and its controls.  Many properties and arguments can be bound to variables specific to individual players.  Binding functions will be discussed here, however, the concept of binding and advanced binding techniques will be discussed later.  Any property that can be bound to a variable can also be set statically, but the form will be less dynamic with static properties.

>Most properties, especially at the form level, have a default value.  All default values will be noted below.  No action is required, and no function need be called, if the defaul behavior is desired.

>All properties are optional unless otherwise noted with `(Required)`.  All required properties have a default value except for form geometry.

* **Version** `(Required)` Default: `1`.

    `NUI_SetVersion(int nVersion)`

* **Title**  Default: `""` (empty string).  The string provided to this property will appear in the title bar of the form, if the the title bar is displayed
    
    `NUI_SetTitle(string sTitle)`

    `NUI_BindTitle(string sVarName)`

* **Geometry** `(Required)`  Default: None.  The geometry provided to this property will determine where the window appears on the player's screen.  Setting the `x` and/or the `y` values to `-1` will cause the window to appear in the center of the user's screen.

    `NUI_SetGeometry(json jRectangle)` - accepts a rectangle vector created with `NUI_DefineRectangle()`.

    `NUI_SetCoordinateGeometry(float x, float y, float w, float h)` - allows a user to set the window geometry without first defining a rectangle vector.

    `NUI_BindGeometry(string sVarName)` - designates the variable that will contain a rectangle vector.

* **Transparent**  Default: `FALSE`.  If set to `TRUE`, the form's background will not be rendered, however the title bar and all controls will still have black backgrounds rendered if they are visible.

    `NUI_SetTransparent(int bTransparent = TRUE)`

    `NUI_BindTransparent(string sVarName)`

* **Modal**  Default: `FALSE`. If set to `TRUE`, the player will not have the ability to close the form.  The scripter must provide an alternate method to close the form.

    `NUI_SetModal(int bModal = TRUE);`

    `NUI_BindModal(string sVarName)`


* **Collapsible**  Default: `TRUE`. If set to `FALSE`, the player will not have the ability to collapse the form.  When a form is collapsed, only the title bar is visible.

    `NUI_SetCollapsible(int bCollapsible = TRUE)`

    `NUI_BindCollapsible(string sVarName)`

* **Resizable**  Default: `FALSE`.  If set to `TRUE`, a small resize handle will appear in the lower right corner of the form when the form is not collapsed.  This handle will allow the player to resize the window.  Resizing can have a detrimental effect to the look of the form as the game's NUI system attempts to resize and move control to best fit into the new form space.

    `NUI_SetResizable(int bResizable = TRUE)`

    `NUI_BindResizable(string sVarName)`

* **Border**  Default: `TRUE`.  If set to `FALSE`, the form or control's border will not be visible.

    `void NUI_SetBorderVisible(int bVisible = TRUE)`

    `void NUI_BindBorderVisible(string sVarName)`

* **Orientation**  Default: `NUI_ORIENTATION_COLUMNS`. Determines whether the general layout of the form is a set of one or more columns or a set of one or more rows.  This does not limit the number or placement of controls on the form, but does affect the placement of controls when not explicitly positioned.

    `NUI_SetOrientation(string sLayout = NUI_ORIENTATION_ROWS)`

* **Width** Sets the width of the control in pixels.

    `NUI_SetWidth(float fWidth)`

* **Height** Sets the height of the control in pixels.

    `NUI_SetHeight(float fHeight)`

* **Aspect** Default: `NUI_ASPECT_FIT`. Sets the aspect (ratio of x/y) applied to various images.

    Options:
    * NUI_ASPECT_FIT
    * NUI_ASPECT_FILL
    * NUI_ASPECT_FIT100
    * NUI_ASPECT_EXACT
    * NUI_ASPECT_EXACTSCALED
    * NUI_ASPECT_STRETCH

    `NUI_SetAspect(int nAspect)`

* **Margin** Sets the spacing outside of a control and determines how close other controls can be to the current control.

    `NUI_SetMargin(float fMargin)`

* **Padding** Sets the spacing inside the control.

    `NUI_SetPadding(float fPadding)`

* **ID** A control's id is returned with NUI event information.  If a control is not assigned an ID, NUI events will not fire for that control.  For convenience, IDs can be added with any `Add*` (e.g. `AddCommandButton("command_button_1")`) function instead of being set separately.

    `NUI_SetID(string sID)`

> Setting IDs is an important step in the form definition process.  For the game's implementation, controls must have IDs assigned in order to trigger events.  Controls without IDs assigned will not trigger user events, such as click, form open/close, etc.  For this system's implemention, controls must have IDs assigned in order to save custom properties/user data and to assign event scripts/actions.

* **Label**  Sets the visible label of the control.  For command and toggle buttons, this sets the text displayed on the button.  For labels, this sets the label's text.

    `NUI_SetLabel(string sLabel)`

* **Value**

* **Enabled** Default: `TRUE`.  Disabled controls cannot be interacted with and will not send NUI events.

    `NUI_SetEnabled(int bEnabled = TRUE)`

    `NUI_BindEnabled(string sVarName)`

* **Visible**  Determines whether a control is visible on the form.  Invisible controls take up layout space as if their were visible, but they are not rendered and cannot be interacted with.

    `NUI_SetVisible(int bVisible = TRUE)`

    `NUI_BindVisible(string sVarName)`

* **Tooltip** Sets the tooltip that appears when a player hovers a mouse pointer over a form's control.

    `NUI_SetTooltip(string sTooltip)`

    `NUI_BindTooltip(string sVarName)`

* **Foreground Color** Sets the control's foreground color.  This has different effects for different controls.  For text-based controls, it changes the color of the text.  It can also change the color of the progress bar.

    `NUI_SetRGBForegroundColor(int r, int g, int b, int a = 255)`

    `NUI_SetJSONForegroundColor(json jColor)` - accepts a color vector.

* **Alignment**  Text and images can be aligned, both vertically and horizontally, within their controls.  

    Options:
    * NUI_HALIGN_CENTER
    * NUI_HALIGH_LEFT
    * NUI_HALIGN_RIGHT

    `NUI_SetHorizontalAlignment(int nAlignment)`

    `NUI_BindHorizontalAlignment(string sVarName)`

    Options:
    * NUI_VALIGN_MIDDLE
    * NUI_VALIGN_TOP
    * NUI_VALIGN_BOTTOM

    `NUI_SetVerticalAlignment(int nAlignment)`

    `NUI_BindVerticalAlignment(string sVarName)`

* **Resref** Sets the resref for image-based controls.

    `NUI_SetResref()`

    `NUI_BindResref()`

* **Placeholder** Sets the placeholder text displayed in a textbox.  This text will disappear when the player starts typing a value into the textbox.

    `NUI_SetPlaceholder()`

    `NUI_BindPlaceholder()`

* **Max Length** Default: `50`.  Sets the maximum number of characters a player can type into a textbox.

    `NUI_SetMaxLength()`

* **Multiline** Determines whether a textbox is considered multiline.

    `NUI_SetMultiline()`

* **Row Count** Sets the row count of a listbox.

    `NUI_SetRowCount()`

    `NUI_BindRowCount()`

* **Row Height** Sets the row height of a listbox.

    `NUI_SetRowHeight()`

    `NUI_BindRowHeight()`

* **Checked** Sets whether a checkbox control is checked or blank.

    `NUI_SetChecked()`

    `NUI_BindChecked()`

* **Draw Color**

* **Scissor**  Default: `TRUE`.  Used only for canvases, this properties determines whether any portion of the drawing which overflows the size dimensions of the control it is based on will be trimmed to the control dimensions.

    `NUI_SetScissor()`

* **Scroll Bars**

* **Canvas**  A canvas allows drawings to be applied to a control.  A canvas is the top display layer of a control, so adding drawings such as images may cover up other parts of the control, such as labels.

    `NUI_AddCanvas`

    `NUI_DrawLine()`

    `NUI_DrawRectangle()`

    `NUI_DrawCircle()`

    `NUI_DrawText()`

    `NUI_DrawCurve()`

    `NUI_DrawArc()`

    `NUI_DrawImage()`
    
    `NUI_CloseCanvas()`

# Using Formfiles
Formfiles are a type of `.nss` include script that contain several functions which define, bind and react to events for a specific form or forms.  For those experienced with tag-based scripting, the idea is similar in that all code for a single form can be contained in a single script. The biggest difference is that formfiles are compiled on-demand, so formfiles can be modified while the server is running and forms redefined, if required.

Formfile integration works with the NUI configuration file `nui_i_config.nss`.  In this file you can set the following for formfile integration:

* `NUI_FORMFILE_PREFIX` - The prefix for all formfiles.  The system will search for all formfiles (all `.nss` resrefs that start with this value) and run the specified form definition script (see below).

* `NUI_FORMFILE_DEFINITION_FUNCTION` - (required) The function that contains the code for defining the form.  Should start with `NUI_CreateForm()` and end with `NUI_SaveForm()`.  Multiple forms can be defined in a single formfile.  Data returned for binding and event functions will contain the form id set during the definition process.

* `NUI_FORMFILE_BINDS_FUNCTION` - (optional) The function that contains code for setting all the initial bind values for the form.  This code must run *after* the form is open because all binds are set by form token and pc object.  The form token is different for each form instance (even if you open and close the same form multiple times), so binds must be set (if desired) each time the form is open.  If other scripts are set for handling form binding (i.e. via `NUI_SetBindScript()`), then those scripts take priority and the system will not attempt to run the formfile's bind handler.

* `NUI_FORMFILE_EVENTS_FUNCTION` - (optional) The function that contains the code for reacting to all events signaled by this form.  This is the defaul function for event handling for a specific form.  If other scripts are set for handling form events (i.e. via `NUI_SetEventScript()`), then those scripts take priority and the system will not attempt to run the formfile's event handler.

> Any time an override script is set during form definition (`NUI_SetBindScript()`, `NUI_SetEventScript()`, etc.), those scripts take priority over any functions contained in the form's formfile and the formfile's function will not be run.  Also, override scripts set at the form level (i.e. using `NUI_SetEventScript()` before any controls are added), are form-global and apply to all controls on the form unless a local override script is set.

Here is an example formfile:
```cpp
#include "nui_i_main"

// This function name matches NUI_FORMFILE_DEFINITION_FUNCTION in nui_i_config.nss
void NUI_HandleFormDefinition()
{
    NUI_CreateForm("textbox_form");
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

// This function name matches NUI_FORMFILE_BINDS_FUNCTION in nui_i_config.nss
void NUI_HandleFormBinds()
{
    object oPC = OBJECT_SELF;
    struct NUIBindData bd = NUI_GetBindData();
    int n;

    // NUIBindData provides the following elements:
    //  sFormID - the form ID as assigned during the form definition process
    //  nToken - the token of the focus form
    //  jBinds - a JsonArray of NUIBindArrayData[] (see below)
    //  nCount - the number of elements in jBinds to easily loop through the array

    for (n = 0; n < bd.nCount; n++)
    {
        struct NUIBindArrayData bad = NUI_GetBindArrayData(bd.jBinds, n);

        // NUIBindArrayData provides the following elements:
        //  sType - the type of control that has a bind (i.e. textedit, button, etc.)
        //  sProperty - the property on the form which has a bind (i.e. label, value, etc.)
        //  sBind - the bind variable as assigned in the form definition process
        //  jUserData - a JsonObject of user data (if any) as assigned in the form definition process

        if (sBind == "textbox_placeholder")
            // NUI_SetBindValue allows you to set the value of the current bind.
            // Maybe change this just to send the array back instead of each element?
            // --> NUI_SetBindValue(oPC, bad, JsonString("Example..."));
            NUI_SetBindValue(oPC, bd.nToken, bad.sBind, JsonString("Example..."));
    }
}

// This function name matches NUI_FORMFILE_EVENTS_FUNCTION in nui_i_config.nss
void NUI_HandleFormEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

    // NUIEventData provides the following elements:
    //  object oPC - the PC object interacting with the subject form
    //  int nFormToken - the token of the subject form
    //  string sFormID - the form ID as assigned during the form definition process
    //  string sEvent - the event type (click, mousedown, mouseup, mousescroll, open, close, watch)
    //  string sControlID - the ID of the control that triggered the event
    //  int nIndex - the index of the control in a list, if the control is in a list
    //  json jPayload - the event payload, which varies by event (usually includes mouse position)
    //  json jUserData - a JsonObject of user data (if any) as assigned in the form definition process

    if (ed.sEvent == "open")
        Notice("Look, ma! I opened the '" + ed.sFormID + "' form!");      
}
```

```cpp
// To illustrate how script overrides work, consider the following simple form definition code:
NUI_CreateForm("my_form");
    NUI_BindGeometry("form_geometry");
    NUI_SetBindScript("my_form_bind");
{
    NUI_AddCommandButton("command_save");
        NUI_SetLabel("Save");
        NUI_SetEventScript("nui_cmd_save");

    NUI_AddCommandButton("command_cancel");
        NUI_BindLabel("cancel_label");
} NUI_SaveForm();
```

The following scripts would run for the above form when it is opened/interacted with:
* For form events (open/close), `NUI_HandleFormEvents()` from the formfile is the handler because an override handler was not specified with `NUI_SetEventScript()` or `NUI_SetEventFunction()` at the form level.

* Events for `command_save` would call `nui_cmd_save.nss` because an override script was specified for that command button.  Events for `command_cancel` would be handled by the formfile's event handle because no event script was specified at the control level or at the form level.

* All binding would be handled by `my_form_bind.nss` for all controls on the form because this script override was specified at the form level (before any controls were added).  Since no child controls specified a bind handler, all binding defaults to the globally-specified handler.

* The same concept applies to the functions `NUI_SetEventFunction()` and `NUI_SetBindFunction()`.  The only difference is that a custom function built into the formfile can be called (instead of a dedicated script) to override the global/default handlers.  In this case, if you specified `NUI_SetEventFunction("command_save_events")`, you would need to add the function `void command_save_events()` to the formfile.

> The system will search for the first parent control to specify an override script, if one exists.  For example, if you specific an event script for a control group, but do not specify an event script for any controls within that group, all events for controls within that group (and the control group itself) will be handled by the script override set on the control group.

## Form Handler Priority
Only one handler will be run for any specific event, whether it's initial form binding, control building or event handling.  Although you can specific all three for any given control, only one will execute and will run in the following priority:

* User-specified scripts assigned via `NUI_Set[Event|Bind|Build]Script()`
* User-specified functions assigned via `NUI_Set[Event|Bind|Build]Function()`
* Default formfile functions as set in `nui_i_config.nss` and defined in the formfile

# Binding

> The term `bind` in this context refers to the variable set in a bind function such as `NUI_BindGeometry("my_geometry");`.  In this example, the `bind` is `"my_geometry"`.

There is no requirement to use this system's functions to set binds, however this system provides several functions to make binding easier for the novice scripter.  No matter the method used, binding requires some basic knowledge of the `json` datatype and converting various primitive types into `json`.  The conversion functions are base-game functions and not part of this system:

## JSON Conversion
To convert:
* `string` to `json` -> `JsonString("my_string");`
* `int` to `json` -> `JsonInt(2)` or `JsonInt(FALSE);`
* `float` to `json` -> `JsonFloat(3.0);`

## Setting a Handler

> *** WARNING *** The bind handler runs once immediately after the form is open and is designed to set the starting values for all binds on the form.  It is not an event handler and should not be used to update binds as the data returned from `NUI_GetBindData()` is not defined after the form is open and interactive.  Calls to `NUI_GetBindData()` or `NUI_GetBindArrayData()` after the form is open will result in the return of empty json objects. Changes to binds should be accomplished through form events.

If you don't want to use the default bind handler in the formfile, there are two other methods to assign scripts and functions for binds, builds and events.  The first is `SetBindScript("my_script_name");`.  A script set using this function will cause the standalone script to be executed during the bind process.

* You can set a form-global bind script by using `SetBindScript()` during form definition before any controls are added (i.e. in the same place as setting the `title` and other form-global values).  If a form-global script is set, this script will be called each time a control is found that has a bind, unless a local bind script is set for the control.

* You can set a local bind script for a specific control by using `SetBindScript("sScript")` while defining the control.  If a local bind script is set, that bind script will be called during the binding process instead of the form-global bind script.  The local bind script can be the same as the form-global bind script, if desired, however, in this case you would not have to specify a local script as the form-global script runs for each bound control on the form (unless a local script is specified).

The second method is `SetBindFunction("sFunction");`.  This method allows you to continue using the formfile methdology, but specify a different function to run for a specific control, usually one that requires special or advanced handling.  The `sFunction` parameter must match a function that is included in your formfile, much like the default functions for form definition, binding and event handling.

```c
// For SetBindFunction() calls, there must be a matching function in the form's formfile.  I missing function will not break the system, but will result in an error in your server log and a valid value will not be returned.

NUI_CreateForm("my_form_id");
    NUI_BindGeometry("my_form_geometry");
{
    NUI_AddCommandButton("my_command_button");
        NUI_SetWidth(150.0);
        NUI_BindLabel("my_button_label");
        NUI_SetBindFunction("my_button_label");
}

// In the basic form definition above, when the form is open, the system will find that the command button requires bound data and will attempt to run the function "my_button_label" which should be present in the formfile:

void my_button_label()
{
    // Determine bind data here
}
```

## Creating a Bind Script

Once you've set a bind script, you'll need to create the script to handle the binds.  The methodology used in any specific module can be very different, ranging from vast, module-wide event management systems to the more traditional "loose-script" system, which is how most modules are built.  If you have a system other than traditional (i.e. event management), you'll need to modify the function `NUI_RunScript()` to match your systems.  This function can be found at the top of `nui_i_main.nss`.

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

Once bind data has been calculated and is ready to be set, there are three options available for setting the data to the bound variable.

The first is using the general binding function `NUI_SetBindValue()`.  It requires four arguments:
* oPC - the PC object interacting with the subject form
* nFormToken - the token of the subject form
* sBind - the bind variable that is being set
* jValue - a json value that is being set on the bind
```c
NUI_SetBindValue(oPC, nFormToken, sBind, jValue)
```
> If this function is being called during the initial form bind process, `nFormToken` and `sBind` can be retrieved from the `NUIBindArrayData` struct.

The second is using a wrapper function designed for use only during the initial form bind process.  This function accepts the `NUIBindArrayData` structure as an argument.
```c
NUI_SetBindValueByStruct(oPC, bd, jValue)
```
The third option is to directly set the bind with the base-game function `NuiSetBind()`.

# Events

