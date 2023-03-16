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

## Requires

NWN >= 8193.34.1

## Change Log

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

The function `NUI_Initialize()` must be run somewhere during your module's `OnModuleLoad` event.  It can be as simple as this:

```c
#include "nui_i_main"

void main()
{
    NUI_Initialize();
}
```

Additionally, you must integrate the NUI system into your module's NUI event handler, if you have one.  You must `#include "nui_i_main"` and add this line to it somewhere:

```c
#include "nui_i_main"

void main()
{
    NUI_HandleEvents();
}
```

That's it!  The basic system should now run.

## Description
This system is designed to allow builders/scripters to fully define NUI forms, controls, layouts, events and data binds.  Much like `nw_inc_nui.nss`, it is simply a set of functions/wrappers that create the required json structures which define a form.  This version uses a different method in that all definition data is string-based versus json-based.  In addition, this system also handles all NUI events and, optionally, any other game event that might affect a form.

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

* **Event** - an occurrence involving the form, such as a mouse click, form closing or bound variable change.  This may also refer general gave events, such as `OnUnaquireItem`, if the builder chooses to subsscrie to game events.

## Function Naming Conventions
* All public functions start with `NUI_` to ensure deconflication from other module systems, and are all prototyped for ease of use in the toolset's script editor or via the nwscript language server.  All private functions start with `nui_`.  If you find yourself referring to a private function, you likely need to re-evaluate your design.  Additionally, private functions have no error checking because they're, well, private.  Using them without fully undertanding their purpose could introduce bugs into your form build/function.

* **Add** Functions that start with `add` are used to add controls or structures to the current form.

* **Set** Functions that start with `set` are used to statically set a property on a form or control.

* **Bind** Functions that atart with `bind` are used to dynamically bind a variable name to a form or control property.

* **Close** Functions that start with `close` are used to conclude the definition of complex controls and structures.  These are only used for control groups, listboxes, canvases, rows and columns.

* **Save** Functions that start with `save` are used to conclude the definition of a major form element, such as template controls.

## Vector Structures
Some of the controls on NUI forms take vector structures as arguments.

* `NUI_DefinePoint(float x, float y)` - takes two float (decimal) arguments and returns a json-parseable string containing the two coordinates.

* `NUI_DefineRectangle(float x, float y, float w, float h)` - takes four float (decimal) arguments to define a specific rectangular area.  For forms, this function can be used to define where the form will appear on the user's screen.  For drawings, this function can be used to define the location of the canvas on the control.

* `NUI_DefineCircle(float x, float y, float r)` - takes a circle center coordinate and radius argument and returns a json-parseable string suitable for defining a rectangle that contains the circle centered at (x, y) with radius r.

* `NUI_DefineRGBColor(int r, int g, int b, int a = 255)` - takes three (optionally four) integer arguments to define a color vector.  These vectors can be used to define foreground colors for various controls as well as line and fill colors for drawings.

* `NUI_DefineHSVColor(float h, float s, float v)` - takes three float arguments to define a color vector based on hue, saturation and value.  These values will be converted to an RGB vector compatible with the NUI system.

* `NUI_DefineHexColor(int nColor)` - takes a single integer argument representing a hex color and converts it to an RGB vector compatible with the NUI system.

* `NUI_DefineRandomRGBColor()` - requires no arguments and returns a random RGB vector compatible with the NUI system.

## Controls and Properties
Controls are the primary method of interaction between the player and form.  The properties listed with these controls are control-specific.  For generic properties that apply to all controls, such as dimensional properties, colors, enabling and visibility, see [properties](#properties).  If control-specific properties are not listed for a specific control, only generic properties are available.

* <ctl>**Spacer**</ctl> Spacers are transparent control used to optimize positions of controls on a form.  If a control is to be centered on a form, inserting a spacer on either said of the control will force the control into the center of the column or row, depending on orientation.  Additionally, spacers may be used resolve spacing problems as they can act greedily at times and take up layout space that otherwise would have been left in by the layout system.

    <fg>**Controls:**</fg>
    - `NUI_AddSpacer()` - adds a spacer.
    
* <ctl>**Label**</ctl>  Labels are non-interactive controls used to convey information or define a control's use for the player.  Typically, a label will be associated with another control, but this is not required.

    <fg>**Controls:**</fg>
    - `NUI_AddLabel()`

    <fg>**Properties:**</fg> [[dimensions]](#common-dimensional-properties) [[interaction]](#common-interaction-properties)
    - `NUI_[Set|Bind]Label()` - text that will be displayed in the label [**...**](#label)
    - `NUI_[Set|Bind]HorizontalAlignment()` [**...**](#alignment)
    - `NUI_[Set|Bind]VerticalAlignment()` [**...**](#alignment)

* <ctl>**Textbox**</ctl>  NUI has two types of textboxes: interactive and static.  An interactive textbox allows the user to input text.  This requires a bound value.  Interactive textboxes without bound values will not work correctly.  Static textboxes are much like labels, but with borders and a scrollbar that you can't turn off.  By default, this system builds interactive textboxes, but you can modify it with the `NUI_SetStatic()` function.

    <fg>**Controls:**</fg>
    - `NUI_AddTextbox()` - adds an interactive textbox.
    - `NUI_SetStatic()` - set textbox to non-interactive.

    <fg>**Properties:**</fg> (interactive textboxes)
    - `NUI_[Set|Bind]Placeholder()` - placeholder text displayed when the textbox is empty. [**...**](#placeholder)
    - `NUI_[Set|Bind]Value()` - the textbox's value; a bound value is required for interactive textboxes. [**...**](#value)
    - `NUI_SetLength()` - maximum number of characters the user can enter. [**...**](#length)
    - `NUI_SetMultiline()` - allow the user to enter newlines. [**...**](#multiline)
    - `NUI_SetWordWrap()` - allow the textbox to wrap text values. [**...**](#wordwrap)

    <fg>**Properties:**</fg> (static textboxes)
    - `NUI_[Set|Bind]Value()` [**...**](#value)
    - `NUI_SetBorder()` [**...**](#border)
    - `NUI_SetScrollbars()` [**...**](#scrollbars)

* <ctl>**Command Button**</ctl> Command buttons are controls that perform specific functions when clicked by the player.  When clicked, the control background temporarily changes to show the button was clicked.

    <fg>**Controls:**</fg>
    - `NUI_AddCommandButton()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Label()` - text that will be displayed on the button. [**...**](#label)

* <ctl>**Image Button**</ctl> An image button is the same as a command button, however, instead of a caption an image is displayed on the button.

    <fg>**Controls:**</fg>
    - `NUI_AddImageButton()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Resref()` - resref of image to display, less the file extension. [**...**](#resref)

* <ctl>**Toggle Button**</ctl>  A toggle button is similar to a command button, but will latch when clicked, returning a value of `0` (not latched) or `1` (latched).  When latched, the control's background will be a dark blue textured pattern.  Toggle buttons without value binds will not latch.

    <fg>**Controls:**</fg>
    - `NUI_AddToggleButton()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Label()` - text that will be displayed on the button. [**...**](#label)
    - `NUI_[Set|Bind]Value()` - whether the toggle button is toggled. [**...**](#value)


* <ctl>**Checkbox**</ctl> A checkbox is a combination control that contains both a square (checkbox) and a label to the right of the square, which defines its purpose.

    <fg>**Controls:**</fg>
    - `NUI_AddCheckbox()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Label()` - text that will be displayed to the left of the checkbox. [**...**](#label)
    - `NUI_[Set|Bind]Value()` - whether the checkbox is checked. [**...**](#value)

* <ctl>**Image**</ctl> An image control displays an image.

    <fg>**Controls:**</fg>
    - `NUI_AddImage()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Resref()` - resref of image to display, less the file extension. [**...**](#resref)
    - `NUI_[Set|Bind]Aspect()` - NUI_ASPECT_* [**...**](#aspect)
    - `NUI_[Set|Bind]HorizontalAlignment()` - NUI_HALIGN_* [**...**](#alignment)
    - `NUI_[Set|Bind]VerticalAlignment()` - NUI_VALIGN_* [**...**](#alignment)

* <ctl>**Combobox**</ctl>  A combobox is a dropdown list of options from which a player can select one.  The selected option will appear in the combobox after selection.

    <fg>**Controls:**</fg>
    - `NUI_AddComboBox()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Elements()` - elements to be displayed in the combobox. [**...**](#elements)
    - `NUI_[Set|Bind]Value()` - the element currently selected. [**...**](#value)

* <ctl>**Slider**</ctl> Creates a line with a pointer (slider) on it.  The bounds and step of the slider can be defined as floats or ints.

    <fg>**Controls:**</fg>
    - `NUI_AddIntSlider()`
    - `NUI_AddFloatSlider()`

    <fg>**Properties:**</fg>
    - `NUI_SetIntSliderBounds()` [**...**](#bounds)
    - `NUI_SetFloatSliderBounds()` [**...**](#bounds)
    - `NUI_BindSliderBounds()` [**...**](#bounds)
    - `NUI_[Set|Bind]Value()` - current value of the slider. [**...**](#value)

* <ctl>**Progress Bar**</ctl>  Creates a progress bar which displays a value between 0.0 and 1.0.

    <fg>**Controls:**</fg>
    - `NUI_AddProgressBar()`

    <fg>**Properties:**</fg>
    - `NUI_[Set|Bind]Value()` [**...**](#value)

* <ctl>**Listbox**</ctl>  Listboxes display a list of repeated row templates, but populated with different data for each row.  The player can select a single item in a listbox to return the index of the item selected.  Once a listbox is added, the controls that make up the row template can be added.  Once all the controls are added, `NUI_CloseListbox()` must be called.

    <fg>**Controls:**</fg>
    - `NUI_AddListbox()`
    - `NUI_CloseListbox()`

    <fg>**Properties:**</fg>
    - `NUI_SetRowHeight()` [**...**](#rowheight)
    - `NUI_SetBorder()` [**...**](#border)
    - `NUI_SetScrollbars()` [**...**](#scrollbars)
    - `NUI_[Set|Bind]RowCount()` [**...**](#rowcount)

* <ctl>**Color Picker**</ctl>  The color picker control displays a simple color picker that allows the player to designate a color.

    <fg>**Controls:**</fg>
    - `NUI_AddColorPicker()`

    <fg>**Properties:**</fg>
    - `NUI_SetValue()` [**...**](#value)

* <ctl>**Option Group**</ctl>  An option group contains a set of radio buttons (circles with text next to them).  Only one radio button within an option group may be selected at a time.

    <fg>**Controls:**</fg>
    - `NUI_AddOptionGroup()`

    <fg>**Properties:**</fg>
    - `NUI_SetDirection()` [**...**](#direction)
    - `NUI_[Set|Bind]Elements()` [**...**](#elements)

* <ctl>**Chart**</ctl>  A chart control can display either a bar or line graph.

    <fg>**Controls:**</fg>
    - `NUI_AddChart()`

    <fg>**Properties:**</fg>
    - `NUI_SetChartSeries()` [**...**](#chart-series)

* <ctl>**Control Group**</ctl>  Control Groups are controls which contain other controls.  Control groups can be thought of as miniature forms within the main form.  Because of the nature of control groups and how the build process in the this system works, `NUI_CloseControlGroup()` must be called when the definition of the control group, including its controls, is complete.

    <fg>**Controls:**</fg>
    - `NUI_AddControlGroup()`
    - `NUI_CloseControlGroup()`

    <fg>**Properties:**</fg>
    - `NUI_SetBorder()` [**...**](#border)
    - `NUI_SetScrollbars()` [**...**](#scrollbars)

* <ctl>**Template Controls**</ctl>  Scripters may create template controls to prevent repeated effort during form definition.  For example, if a form requires multiple labels that are all the same size, a template control can be created before form definition and then added multiple times during form definition.  Properties specific to the control instance can be modified when inserted.  Template controls may only contain one base control, however that base control can be a control group that contains other controls.  All templated control definitions must be followed by `NUI_SaveTemplateControl()`.

    <fg>**Controls:**</fg>
    - `NUI_CreateTemplateControl()`
    - `NUI_SaveTemplateControl()`
    - `NUI_AddTemplateControl()`

    <fg>**Properties:**</fg>

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

>Most properties, especially at the form level, have a default value.  All default values will be noted below.  No action is required, and no function need be called, if the default behavior is desired.  Additionally, any default labeled `automatic` means that the system will calculate an appropriate value if none is assigned.

>All properties are optional unless otherwise noted with <r>**(Required)**</r>.  All required properties have a default value except for form geometry.

### Form-level Properties
The following properties apply only to the form object.

<a id="title"></a>
* <ctl>**Title**</ctl> <b>Default: `""` (empty string)</b>.  The string provided to this property will appear in the title bar of the form, if the the title bar is displayed.  This property can be bound.
    
    - `NUI_SetTitle(string sTitle)`
    - `NUI_BindTitle(string sVarName)`

<a id="geometry"></a>
* <ctl>**Geometry**</ctl> <r>**(Required)**</r> <b>Default: Bind -> `"geometry"`</b>.  The geometry provided to this property will determine where the form appears on the player's screen.  Setting the `x` and/or the `y` values to `-1` will cause the window to appear in the center of the user's screen.

    - `NUI_SetGeometry(string sRectangle)` - accepts a rectangle vector created with `NUI_DefineRectangle()`.
    - `NUI_SetCoordinateGeometry(float x, float y, float w, float h)` - allows a user to set the window geometry without first defining a rectangle vector.
    - `NUI_BindGeometry(string sVarName)` - designates the variable that will contain a rectangle vector.

<a id="transparent"></a>
* <ctl>**Transparent**</ctl>  <b>Default: `false`</b>.  If set to `TRUE`, the form's background will not be rendered, however the title bar and all controls will still have black backgrounds rendered if they are visible.

    - `NUI_SetTransparent(int bTransparent = TRUE)`
    - `NUI_BindTransparent(string sVarName)`

<a id="modal"></a>
* <ctl>**Modal**</ctl>  <b>Default: `false`</b>. If set to `TRUE`, the player will not have the ability to close the form.  The scripter must provide an alternate method to close the form.

    - `NUI_SetModal(int bModal = TRUE);`
    - `NUI_BindModal(string sVarName)`

<a id="collapsible"></a>
* <ctl>**Collapsible**</ctl>  <b>Default: `true`</b>. If set to `FALSE`, the player will not have the ability to collapse the form.  When a form is collapsed, only the title bar is visible.

    - `NUI_SetCollapsible(int bCollapsible = TRUE)`
    - `NUI_BindCollapsible(string sVarName)`

<a id="resizable"></a>
* <ctl>**Resizable**</ctl> <b>Default: `FALSE`</b>.  If set to `TRUE`, a small resize handle will appear in the lower right corner of the form when the form is not collapsed.  This handle will allow the player to resize the window.  Resizing can have a detrimental effect to the look of the form as the game's NUI system attempts to resize and move control to best fit into the new form space.

    - `NUI_SetResizable(int bResizable = TRUE)`
    - `NUI_BindResizable(string sVarName)`

### Common Dimensional Properties
The following properties control the sizing of form controls and must be assigned constant values (binding is not allowed for these properties).  These properties can be applied to any control.

<a id="width"></a>
* <ctl>**Width**</ctl> <b>Default: automatic</b>.  Sets the width of the control in pixels.  This property cannot be bound.  See notes at `Aspect` below.

    - `NUI_SetWidth(float fWidth)`

<a id="height"></a>
* <ctl>**Height**</ctl> <b>Default: automatic</b>.  Sets the height of the control in pixels.  This property cannot be bound.  See notes at `Aspect` below.

    - `NUI_SetHeight(float fHeight)`

<a id="aspect"></a>
* <ctl>**Aspect**</ctl> <b>Default: `NUI_ASPECT_FIT`</b>. Sets the aspect (ratio of x/y or width/height) applied to various images and controls.  For controls, this property cannot be bound, for images it can.
    > <warn>A maximum of two of the properties `width`, `height` and `aspect` can be set on any individual control.  Since they relate to each other, the system cannot resolve a conflict if all three are set and **the form will not render**.</warn>

    For images:
    * NUI_ASPECT_FIT
    * NUI_ASPECT_FILL
    * NUI_ASPECT_FIT100
    * NUI_ASPECT_EXACT
    * NUI_ASPECT_EXACTSCALED
    * NUI_ASPECT_STRETCH

    For controls:  A float (decimal) value designating the x/y or width/height ratio, such as `16.0/9.0`.

    - `NUI_SetAspect(int nAspect)`

<a id="margin"></a>
* <ctl>**Margin**</ctl> <b>Default: automatic.</b>  Sets the spacing outside of a control and determines how close other controls can be to the current control.

    - `NUI_SetMargin(float fMargin)`

<a id="padding"></a>
* <ctl>**Padding**</ctl> <b>Default: automatic.</b>  Sets the spacing inside the control.

    - `NUI_SetPadding(float fPadding)`

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

    - `void NUI_SetBorderVisible(int bVisible = TRUE)`
    - `void NUI_BindBorderVisible(string sVarName)`

<a id="label"></a>
* <ctl>**Label**</ctl> <b>Default: none</b>. Sets the visible label of the control.  For command and toggle buttons, this sets the text displayed on the button.  For labels, this sets the label's text.

    - `NUI_SetLabel(string sLabel)`

<a id="value"></a>
* <ctl>**Value**</ctl>

<a id="tooltip"></a>
* <ctl>**Tooltip**</ctl> <b>Default: none</b>.  Sets the tooltip that appears when a player hovers a mouse pointer over an enabled control.  If `bDisabledTooltip` is passed as `TRUE`, this function will also set the control's `DisabledTooltip` property to the `sTooltip`.

    - `NUI_SetTooltip(string sTooltip, int bDisabledTooltip = FALSE)`
    - `NUI_BindTooltip(string sVarName)`

<a id="disabled-tooltip"></a>
* <ctl>**Disabled Tooltip**</ctl> <b>Default: none</b>.  Sets the tooltip that appears when a player hovers a mouse pointer over a disabled control.

    - `NUI_SetDiabledTooltip(string sTooltip)`
    - `NUI_BindDisabledTooltip(string sVarName)`

<a id="foreground-color"></a>
* <ctl>**Foreground Color**</ctl> <b>Default: (255, 255, 255)</b>. Sets the control's foreground color.  This has different effects for different controls.  For text-based controls, it changes the color of the text.  For progress bars, it changes the color of the progress bar.

    - `NUI_SetRGBForegroundColor(int r, int g, int b, int a = 255)`

<a id="alignment"></a>
* <ctl>**Alignment**</ctl> Text and images can be aligned, both vertically and horizontally, within their controls.  

    - `NUI_SetHorizontalAlignment(int nAlignment)`
    - `NUI_BindHorizontalAlignment(string sVarName)`

        - NUI_HALIGN_CENTER
        - NUI_HALIGH_LEFT
        - NUI_HALIGN_RIGHT

    - `NUI_SetVerticalAlignment(int nAlignment)`
    - `NUI_BindVerticalAlignment(string sVarName)`

        - NUI_VALIGN_MIDDLE
        - NUI_VALIGN_TOP
        - NUI_VALIGN_BOTTOM

<a id="resref"></a>
* <ctl>**Resref**</ctl> Sets the resref for image-based controls.

    - `NUI_SetResref()`
    - `NUI_BindResref()`

<a id="placeholder"></a>
* <ctl>**Placeholder**</ctl> <b>Default: none</b>.  Sets the placeholder text displayed in a non-static textbox.  This text will disappear when the player starts typing a value into the textbox and will re-appear if the player deletes all text from the textbox.

    - `NUI_SetPlaceholder()`
    - `NUI_BindPlaceholder()`

<a id="length"></a>
* <ctl>**Length**</ctl> <b>Default: `50`</b>.  Sets the maximum number of characters a player can type into a textbox.

    - `NUI_SetLength()`
    - `NUI_BindLength()`

<a id="multiline"></a>
* <ctl>**Multiline**</ctl> <b>Default: `FALSE`</b>.  Determines whether a textbox is considered multiline. For static textboxes, this implies an automatic word-wrap feature.  Non-static textboxes do not have automatic word-wrap and users must manually insert line-breaks and paragraphs by pressing enter.

    - `NUI_SetMultiline()`

<a id="rowcount"></a>
* <ctl>**Row Count**</ctl> <b>Default: `0`</b>.  Sets the row count of a listbox.

    - `NUI_SetRowCount()`
    - `NUI_BindRowCount()`

<a id="rowheight"></a>
* <ctl>**Row Height**</ctl> <b>Default `25.0`</b>.  Sets the row height of a listbox.

    - `NUI_SetRowHeight()`
    - `NUI_BindRowHeight()`

<a id="checked"></a>
* <ctl>**Checked**</ctl> <b>Default `FALSE`</b>.  Sets whether a checkbox control is checked or blank.

    - `NUI_SetChecked()` - must be set to `true` or `false`.
    - `NUI_BindChecked()` - must be bound to a boolean value.

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
Formfiles are a type of `.nss` that contain several functions which define, bind and react to events for a specific form or forms.  For those experienced with tag-based scripting, the idea is similar in that all code for a single form can be contained in a single script. Formfiles can be created as pre-compiled scripts (for performance) or as compile-on-demand scripts.  Pre-compiled scripts must `#include "nui_i_library"` in order to be setup correctly.  This script contains the formfile's `void main()` function, so a `main` function should not be included in your formfile.  If `nui_i_library` is not included, the formfile is assumed to be compiled-on-demand and will be compiled as required using script chunks.

Formfile integration works with the NUI configuration file `nui_c_config.nss`.  In this file you can set the following for formfile integration:

// TODO 

Following is a basic formfile.  Other examples of varying complexity, including a template formfile, can be found in this repo's `formfile` folder.
```cpp
#include "nui_i_main"

void DefineForm()
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

void NUI_BindForm()
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

void HandleNUIEvents()
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

    if (ed.sEvent == "open")
        Notice("Look, ma! I opened the '" + ed.sFormID + "' form!");      
}

void HandleModuleEvents()
{

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

