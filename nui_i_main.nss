
// Full documentation is contained in the GitHub repo README.md.  Comments and
// prototypes below are for IDE use only.  Direct comments and questions to
// tinygiant on the Neverwinter Vault or NWNX discord servers.

// Any functions marked as ** ADVANCED USAGE ** requires knowledge of json
// datatypes or other advanced nwscript features.  See the README.md document for
// additional details and example usage.

//#include "util_i_debug"
#include "util_i_color"
#include "util_i_csvlists"
#include "nui_i_const"
#include "nui_i_config"
#include "nui_i_database"

// -----------------------------------------------------------------------------
//                       Public Function Prototypes
//                  DO NOT CHANGE ANYTHING BELOW THIS LINE
// -----------------------------------------------------------------------------

struct NUIEventData {
    object oPC;           // PC object interacting with the form
    int    nFormToken;    // Subject form token
    string sFormID;       // Form ID as assigned during the form definition process
    string sEvent;        // Event - mouseup, click, etc.
    string sControlID;    // Control ID as assigned during the form definition process
    int    nIndex;        // Index of control in array, if the control is in an array (listbox)
    json   jPayload;      // Event payload, if it exists
    json   jUserData;     // Custom user data set on the control during form definition
    json   jBinds;        // NUIEventArrayData[] of bound data for this control (and children)
    int    nCount;        // Count of NUIEventArrayData[] in jBinds
};

struct NUIEventArrayData {
    string sControlID;    // Control ID as assigned during the form definition process
    string sProperty;     // Control property that has a bound variable assigned
    string sBind;         // Bound variable name
    json   jValue;        // Current value of the bound variable
};

struct NUIBindData {
    string sFormID;       // Form ID as assigned during the form definition process
    int nToken;           // Form token of the subject form
    json jBinds;          // NUIBindArrayData[] of bound data for this form, including all children
    int nCount;           // Count of NUIBindArrayData[] in jBinds
};

struct NUIBindArrayData {
    string sType;         // Control type - NUI_ELEMENT_*
    string sProperty;     // Control property - NUI_PROPERTY_*
    string sBind;         // Bound variable name
    json jUserData;       // Custom user data set on the control during form definition
};

// -----------------------------------------------------------------------------
//     Form Definition, Controls, Custom JSON Structures, Drawing Elements
// -----------------------------------------------------------------------------

// ---< NUI_Initialize >---
// Should be called from the module's OnModuleLoad event
// to initialize the system's database and load any
// available formfiles.
void NUI_Initialize();

// ---< NUI_CreateForm >---
// Creates a form template with id sID and starts
// form definition.  Form definition must be terminated
// with NUI_SaveForm().
void NUI_CreateForm(string sID, string sVersion = "");

// ---< NUI_SaveForm >---
// Terminates form defintion.
void NUI_SaveForm();

// ---< NUI_DisplayForm >---
// Displays form sFormID for player oPC.  Runs auto-bind functions for all
// bound controls.  sProfileName is the name of the profile to open the form
// with.
int NUI_DisplayForm(object oPC, string sFormID, string sProfileName = "default");

// ---< NUI_DestroyForm >---
// Destroys the form identified by nToken for oPC, if it's currently open.
// No events are run by this system or triggered by NUI.
void NUI_DestroyForm(object oPC, int nToken);

// ---< NUI_DefinePoint >---
// Creates a json object containing a single set of coordinates.
json NUI_DefinePoint(float x, float y);

// ---< NUI_DefineRGBColor >---
// Creates a json object containing elements defining an RGB color.
json NUI_DefineRGBColor(int r, int g, int b, int a = 255);

// ---< NUI_DefineHSVColor >---
// Creates a json object containing elements defining an HSV color.
json NUI_DefineHSVColor(float h, float s, float v);

// ---< NUI_DefineHSVColor >---
// Creates a json object containing elements defining a hex color.
json NUI_DefineHexColor(int nColor);

// ---< NUI_DefineRandomRGBColor >---
// Creates a json object containing elements definine a randome RGB color.
json NUI_DefineRandomRGBColor();

// ---< NUI_GetLinePoints >---
// Creates a json array of coordinates required to draw a line with
// NUI_DrawLine().  The line is defined by endpoints (x1, y1) and (x2, y2)
json NUI_GetLinePoints(float x1, float y1, float x2, float y2);

// ---< NUI_AddLinePoint >---
// Adds a single endpoint (x, y) to an existing set of line coordinates jPoints
json NUI_AddLinePoint(json jPoints, float x, float y);

// ---< NUI_DefineRectangle >---
// Creates a json object containing elements defining the origin (x, y),
// width and height of a rectangle.
json NUI_DefineRectangle(float x, float y, float w, float h);

// ---< NUI_GetRectanglePoints >---
// Creates a json array of coordinates required to draw rectangles
// with NUI_DrawRectangle() or NUI_DrawLine().  The rectangle is
// defined by origin (x, y), width w and height h.
json NUI_GetRectanglePoints(float x, float y, float w, float h);

// ---< NUI_GetDefinedRectanglePoints >---
// Creates a json array of coordinates required to draw rectangles
// with NUI_DrawRectangle() or NUI_DrawLine().  This function accepts
// a json structure previously defined by NUI_DefineRectangle().
json NUI_GetDefinedRectanglePoints(json jRectangle);

// ---< NUI_DefineCircle >---
// Creates a json object containing elements defining a rectangle
// surrounding a circle of center (x, y) and radius r.
json NUI_DefineCircle(float x, float y, float r);

// ---< NUI_GetTrianglePoints >---
// Creates a json array of coordinates required to draw triangles
// with NUI_DrawLine().  The triangle is defined by center 
// point x, y, height h and base b.
json NUI_GetTrianglePoints(float x, float y, float h, float b);

// ---< NUI_DefineStringByStringRef >---
// Creates a json object which will render the associated text as
// retrieved by strref from the module's tlk file.
json NUI_DefineStringByStringRef(int nStringRef);

// ---< NUI_CreateTemplateControl >---
// ** ADVANCED USAGE **
// Starts a template control definition. Only one base control
// can be added to a template, however that base control can be
// a control group which houses other controls.  Control template
// definitions must be terminated with NUI_SaveTemplateControl().
// sID is the template identifier, not a control's identifier.
void NUI_CreateTemplateControl(string sID);

// ---< NUI_SaveTemplateControl >---
// ** ADVANCED USAGE **
// Terminates a template control definition session.
void NUI_SaveTemplateControl();

// ---< NUI_AddTemplateControl >---
// ** ADVANCED USAGE **
// Adds a pre-defined tempalate control to the current layout,
// template or control group.  Instance properties may be changed
// after adding a template control.  sID must match the sID
// used in NUI_CreateTemplateControl().
void NUI_AddTemplateControl(string sID);

// ---< NUI_AddColumn >---
// Adds a column to the current form or control group layout.
// This function is error resistent.  If the layout requires a row 
// to be added before a column may be added, the row will be 
// automatically added before the column is added.
void NUI_AddColumn(float fWidth = -1.0);

// ---< NUI_AddRow >---
// Adds a row to the current form or control group layout.
// This function is error resistent.  If the layout requires a column 
// to be added before a row may be added, the column will be 
// automatically added before the row is added.
void NUI_AddRow(float fHeight = -1.0);

// ---< NUI_AddSpacer >---
// Adds a spacer control with id sID.
void NUI_AddSpacer(string sID = "");

// ---< NUI_AddLabel >---
// Adds a label conrol with id sID.
void NUI_AddLabel(string sID = "");

// ---< NUI_AddTextbox >---
// Adds a command button with id sID.
void NUI_AddTextbox(string sID = "");

// ---< NUI_AddCommandButton >---
// Adds a command button with id sID.
void NUI_AddCommandButton(string sID = "");

// ---< NUI_AddImageButton >---
// Adds an image button with id sID.
void NUI_AddImageButton(string sID = "");

// ---< NUI_AddToggleButton >---
// Adds an toggle button with id sID.
void NUI_AddToggleButton(string sID = "");

// ---< NUI_AddCheckbox >---
// Adds a combined checkbox/label control with id sID.
void NUI_AddCheckbox(string sID = "");

// ---< NUI_AddImage >---
// Adds a image control with id sID.
void NUI_AddImage(string sID = "");

// ---< NUI_AddCombobox >---
// Adds a combobox (dropdown) control with id sID.
void NUI_AddCombobox(string sID = "");

// ---< NUI_SetElements >---
// Statically sets the current control's elements property
// to jElements.
void NUI_SetElements(json jElements);

// ---< NUI_BindElements >---
// Dynamically binds the current control's elements property
// to sBind.
void NUI_BindElements(string sBind);

// ---< NUI_AddComboboxEntry >---
// Adds a combobox entry with displayed value sEntry and
// index nValue.  If nValue is not passed, sEntry will be
// added as the last entry.
void NUI_AddComboboxEntry(string sEntry, int nValue = -1);

// ---< NUI_AddComboboxEntryList >---
// Adds a CSV list of comobox entries to the current control.
// nStart is the index to insert the list.  If nStart is not
// passed, all values will be added to the end of the list.
void NUI_AddComboboxEntryList(string sEntries, int nStart = -1);

// ---< NUI_AddFloatSlider >---
// Adds a float-based slider control with id sID.
void NUI_AddFloatSlider(string sID = "");

// ---< NUI_AddIntSlider >---
// Adds an int-based slider control with id sID.
void NUI_AddIntSlider(string sID = "");

// ---< NUI_AddProgressBar >---
// Add a progress bar control with id sID.
void NUI_AddProgressBar(string sID = "");

// ---< NUI_AddListbox >---
// ** ADVANCED USAGE **
// Adds a listbox control with id sID and starts definition 
// of the listbox rows template.  Listbox rows template 
// definition must be terminated with NUI_CloseListbox().
void NUI_AddListbox();

// ---< NUI_CloseListbox >---
// ** ADVANCED USAGE **
// Terminates listbox rows template definition.
void NUI_CloseListbox();

// ---< NUI_AddColorPicker >---
// Adds a color picker control with id sID.
void NUI_AddColorPicker(string sID = "");

// ---< NUI_AddOptionGroup >---
// Adds an option group control with id sID.  Options may be
// added with NUI_AddRadioButton() or NUI_AddRadioButonList().
// Option group values are 0-based, starting with the first
// radio button added.
void NUI_AddOptionGroup(string sID = "");

// ---< NUI_AddRadioButton >---
// Adds an option to a previously defined option group. Radio
// button sButton will be added as the last item in the option
// group.
void NUI_AddRadioButton(string sButton);

// ---< NUI_AddRadioButtonList >---
// Accepts a comma-delimited list of options and adds them, in
// order, to a previously defined option group.  Individual
// values in the sButtons list may not contain commas.  Use
// NUI_AddRadioButton() to add values containing commas.
void NUI_AddRadioButtonList(string sButtons);

// ---< NUI_AddControlGroup >---
// ** ADVANCED USAGE **
// Adds a control group with id sID and starts definition of
// controls within the group.  Control groups may be oriented
// differently and separately from the main form.  Control group
// definitions must be terminated with NUI_CloseControlGroup().
void NUI_AddControlGroup();

// ---< NUI_CloseControlGroup >---
// ** ADVANCED USAGE **
// Terminates control group definition.
void NUI_CloseControlGroup();

// ---< NUI_AddChart >---
// ** ADVANCED USAGE **
// Adds a chart control with id sID.  Use NUI_AddChartSeries() to add
// values to the chart.
void NUI_AddChart(string sID = "");

// ---< NUI_AddChartSeries >---
// ** ADVANCED USAGE **
// Adds a chart series.  Chart must be previously defined with NUI_AddChart();
// nType - Type of Chart
//   > NUI_CHART_LINE
//   > NUI_CHART_BAR
// sLegend - The title of the chart series
// jColor - The color of the series bar/line, defined with NUI_Define*Color()
// jData - A json array of floats
void NUI_AddChartSeries(int nType, string sLegend, json jColor, json jData);

// ---< NUI_AddCanvas >---
// ** ADVANCED USAGE **
// Adds a canvas to the current control and starts definition of
// drawing elements.  Any number of drawing elements may be assigned
// to a single canvas.  Canvas definitions must be terminated with
// NUI_CloseCanvas().
void NUI_AddCanvas();

// ---< NUI_CloseCanvas >---
// ** ADVANCED USAGE **
// Terminates canvas/drawing element definition.
void NUI_CloseCanvas();

// ---< NUI_DrawLine >---
// ** ADVANCED USAGE **
// Draws line segments on a previously defined canvas between endpoints in
// coordinate array jPoints.
void NUI_DrawLine(json jPoints);

// ---< NUI_DrawRectangle >---
// ** ADVANCED USAGE **
// Draws a rectangle on a previously defined canvas between coordinates
// defined by origin (x, y) with width w and height h.
void NUI_DrawRectangle(float x, float y, float w, float h);

// ---< NUI_DrawDefinedRectangle >---
// ** ADVANCED USAGE **
// Draws a rectangle on a previously defined canvas.  This function accepts
// a json structure previously defined by NUI_DefineRectangle(). 
void NUI_DrawDefinedRectangle(json jRect);

// ---< NUI_DrawCircle >---
// ** ADVANCED USAGE **
// Draws a circle on a previously defined canvas around a center point (x, y)
// with radius r. 
void NUI_DrawCircle(float x, float y, float r);

// ---< NUI_DrawDefinedCircle >---
// ** ADVANCED USAGE **
// Draws a circle on a previously defined canvas.  This function accepts a 
// json structure previously defined by NUI_DefineCircle() or NUI_DefineRectangle().
void NUI_DrawDefinedCircle(json jCircle);

// ---< NUI_DrawTriangle >---
// ** ADVANCED USAGE **
// Draws a triangle on a previously defined canvas.  This function accepts
// center point x, y and height h, base b.
void NUI_DrawTriangle(float x, float y, float h, float b);

// ---< NUI_DrawText >---
// ** ADVANCED USAGE **
// Draws a textbox containing sText on a previously defined canvas.  jRect is a
// json structure defined by NUI_DefineRactangle.
void NUI_DrawText(json jRect, string sText);

// ---< NUI_DrawImage >---
// ** ADVANCED USAGE **
// Draws an image of sResref, aligned within jRect by nHAlign and nVAlign,
// with aspect nAspect.
// 
// HorizontalAlignment (nHAlign)        Vertical Alignment (nVAlign)
//      NUI_HALIGN_CENTER                   NUI_VALIGN_MIDDLE
//      NUI_HALIGN_LEFT                     NUI_VALIGN_TOP
//      NUI_HALIGN_RIGHT                    NUI_VALIGN_BOTTOM
//
// Aspect (nAspect)
//      NUI_ASPECT_FIT
//      NUI_ASPECT_FILL
//      NUI_ASPECT_FIT100
//      NUI_ASPECT_EXACT
//      NUI_ASPECT_EXACTSCALED
//      NUI_ASPECT_STRETCH
void NUI_DrawImage(string sResref, json jRect, int nAspect, int nHAlign, int nVAlign);

// ---< NUI_DrawCurve >---
// ** ADVANCED USAGE **
// TODO
// Stupid computers!  Still can't nail down exactly how jA and jB affect the arc/curvature
// of the drawnline
void NUI_DrawCurve(json jA, json jB, json jCtrl0, json jCtrl1);

// ---< NUI_DrawArc >---
// ** ADVANCED USAGE **
// Drawn an arc centered at jC with radius fRadius from fAMin to fAMax.  fAMin and fAMax are
// measure in fractions of PI radians from the start radian of (0 * PI) which is visually
// represented as 090 degrees.  A complete circle is 2 * PI.  To draw a 90 degree arc from 
// 180 degrees to 270 degrees, use NUI_DrawArc([jC], [fRadius], 0.5 * PI, PI);  The radius
// arms will also be drawn.  To achieve any given angle with 0 degrees as straight up,
// use fAMin = (-0.5 * PI) + (fAngle / 180.0) * PI;
void NUI_DrawArc(json jC, float fRadius, float fAMin, float fAMax);

// -----------------------------------------------------------------------------
//                      Form and  Control Properties
// -----------------------------------------------------------------------------

// ---< NUI_SetTitle >---
// Statically sets the form's title to sTitle.
void NUI_SetTitle(string sTitle);

// ---< NUI_BindTitle >---
// Dynamically bind the form's title to sBind.
void NUI_BindTitle(string sBind);

// ---< NUI_SetGeometry >---
// Statically sets the form's geometry to a location defined by origin (x, y) with
// width w and height h.
void NUI_SetGeometry(float x, float y, float w, float h);

// ---< NUI_SetCoordinateGeometry >---
// Statically sets the form's geometry to a location defined by jGeometry.  jGeometry
// can be defined by NUI_DefineRectangle().
void NUI_SetDefinedGeometry(json jGeometry);

// ---< NUI_BindGeometry >---
// Dynamically binds the form's geometry to sBind.
void NUI_BindGeometry(string sBind);

// ---< NUI_SetResizable >---
// Statically sets the form's resizable property to bResizable.
void NUI_SetResizable(int bResizable = TRUE);

// ---< NUI_BindResizable >---
// Dynamically binds the form's resizable property to sBind.
void NUI_BindResizable(string sBind);

// ---< NUI_SetCollapsible >---
// Statically sets the form's resizable property to bResizable.
void NUI_SetCollapsible(int bCollapsible = TRUE);

// ---< NUI_BindCollapsible >---
// Dynamically binds the form's resizable property to bCollapsible.
void NUI_BindCollapsible(string sBind);

// ---< NUI_SetModal >---
// Dynamically binds the form's resizable property to sBind.

// ---< NUI_BindModal >---
// Dynamically binds the form's resizable property to sBind.

// ---< NUI_SetTransparent >---
// Statically sets the form's transparent property to bTransparent.
void NUI_SetTransparent(int bTransparent = TRUE);

// ---< NUI_BindTransparent >---
// Dynamically binds the form's transparent property to sBind.
void NUI_BindTransparent(string sBind);

// ---< NUI_SetBorderVisible >---
// Statically sets a form or control's border visibility to bVisible.
void NUI_SetBorderVisible(int bVisible = TRUE);

// ---< NUI_BindBorderVisible >---
// Dynamically sets a form or control's border visibility to sBind.
void NUI_BindBorderVisible(string sBind);

// ---< NUI_SetVersion >---
// Statically sets the form's version to nVersion.  This is a required
// property and defaults to `1` if no version is explicitly set.
void NUI_SetVersion(int nVersion = 1);

// ---< NUI_SetOrientation >---
// Statically sets a form or control group's layout orientation.
// Orientation determines how various rows and columns are added
// and displayed.  The default orientation for all forms and
// control groups is NUI_ORIENTATION_COLUMNS.

// nOrientation
//      NUI_ORIENTATION_COLUMNS (default)
//      NUI_ORIENTATION_ROWS
void NUI_SetOrientation(string sOrientation = NUI_ORIENTATION_ROWS);

// ---< NUI_SetWidth >---
// Statically sets a control's width to fWidth (pixels).
void NUI_SetWidth(float fWidth);

// ---< NUI_SetHeight >---
// Statically sets a control's height to fHeight (pixels).
void NUI_SetHeight(float fHeight);

// ---< NUI_SetSquare >---
// Convenience function to set both the control height and
// width to fHeight.
void NUI_SetSquare(float fSide);

// ---< NUI_SetDimensions >---
// Convenience function to set the control's width to fWidth
// and height to fHeight.
void NUI_SetDimensions(float fWidth, float fHeight);

// ---< NUI_SetAspectRatio >---
// Statically sets the controls aspect ratio to fRatio, defined
// as x/y.  Do not use this to set the aspect ratio for images.
void NUI_SetAspectRatio(float fRatio);

// ---< NUI_SetImageAspect >---
// Statically sets the aspect ratio for an image to one of the
// following options:
//
// NUI_ASPECT_FIT
// NUI_ASPECT_FILL
// NUI_ASPECT_FIT100
// NUI_ASPECT_EXACT
// NUI_ASPECT_EXACTSCALED
// NUI_ASPECT_STRETCH
void NUI_SetImageAspect(int nAspect);

// ---< NUI_SetImageHorizontalAlignment >---
// Statically sets an image's horizontal alignment to one of the
// following options:
//
// NUI_HALIGN_CENTER
// NUI_HALIGN_LEFT
// NUI_HALIGN_RIGHT
void NUI_SetImageHorizontalAlignment(int nHAlign);

// ---< NUI_SetImageVerticalAlignment >---
// Statically sets an image's vertical alignment to one of the
// following options:
//
// NUI_VALIGN_MIDDLE
// NUI_VALIGN_TOP
// NUI_VALIGN_BOTTOM
void NUI_SetImageVerticalAlignment(int nVAlign);

// ---< NUI_SetMargin >---
// Statically sets the current control's margin to fMargin.
// Margin determines the distance between controls.
void NUI_SetMargin(float fMargin);

// ---< NUI_SetPadding >---
// Statically sets the current control's padding to fPadding.
// Padding determines the distances between internal elements
// of a control and its border.
void NUI_SetPadding(float fPadding);

// ---< NUI_SetID >---
// Statically sets the current control's ID to sID.  If set
// while the control was added, this function does not need
// to be called.  Controls without an ID will not generate 
// NUI events.
void NUI_SetID(string sID);

// ---< NUI_SetLabel >---
// Statically sets the current control's label property to
// sLabel.  Can be used to set the label for label controls,
// the static value displayed in a static textbox, or to
// set the "label" property on any other control that uses it.
void NUI_SetLabel(string sLabel);

// ---< NUI_BindLabel >---
// Dynamically binds the current control's label property to
// sBind.  Can be used to bind the label for label controls,
// the static value displayed in a static textbox, or to
// bind the "label" property on any other control that uses it.
void NUI_BindLabel(string sBind);

// ---< NUI_SetEnabled >---
// Statically sets the current control's enabled property to
// bEnabled.  All controls are enabled by default.
void NUI_SetEnabled(int bEnabled = TRUE);

// ---< NUI_BindEnabled >---
// Dynamically binds the current control's enabled property
// to sBind.  All controls are enabled by default.  Binding 
// a control's enabled property will change the control's 
// default value to disabled/FALSE.
void NUI_BindEnabled(string sBind);

// ---< NUI_SetVisible >---
// Statically sets the current control's visible property to 
// bVisible.  All controls are visible by default.  Setting 
// a control to invisible does not collapse the control.
// Invisible controls will be displayed as blank space.
void NUI_SetVisible(int bVisible = TRUE);

// ---< NUI_BindVisible >---
// Dynamically binds the current control's visible property to 
// sBind.  All controls are visible by default.
void NUI_BindVisible(string sBind);

// ---< NUI_SetTooltip >---
// Statically set the current control's tooltip property to
// sTooltip.  Tooltips are not displayed on disabled or
// invisible controls.
void NUI_SetTooltip(string sTooltip, int bDisabledTooltip = FALSE);

// ---< NUI_BindTooltip >---
// Dynamically binds the current control's tooltip property to
// sBind.  Tooltips are not displayed on disabled or
// invisible controls.
void NUI_BindTooltip(string sBind, int bDisabledTooltip = FALSE);

// ---< NUI_SetRGBForegroundColor >---
// Statically sets the current control's foreground/text color
// to an RGB color defined by r, g, b, a.
void NUI_SetRGBForegroundColor(int r, int g, int b, int a = 255);

// ---< NUI_SetDefinedForegroundColor >---
// Statically sets the current control's foreground/text color
// to jColor, which can be defined by NUI_DefineRGBColor(),
// NUI_DefineHSVColor(), NUI_DefineHexColor() or
// NUI_DefineRandomRGBColor().
void NUI_SetDefinedForegroundColor(json jColor);

// ---< NUI_BindForegroundColor >---
// Dynamically binds the current control's foreground/text color
// to sBind.
void NUI_BindForegroundColor(string sBind);

// ---< NUI_SetColor >---
// Statically sets the current control's color property to
// jColor, which can be defined by NUI_DefineRGBColor(),
// NUI_DefineHSVColor(), NUI_DefineHexColor() or
// NUI_DefineRandomRGBColor().
void NUI_SetDefinedColor(json jColor);

// ---< NUI_SetRGBColor >---
// Statically sets the current control's color property to
// an rgb color defined by r, g, b, a.
void NUI_SetRGBColor(int r, int g, int b, int a = 255);

// ---< NUI_BindColor >---
// Dynamically binds the current control's color property
// to sBind.
void NUI_BindColor(string sBind);

// ---< NUI_SetHorizontalAlignment >---
// Statically set the current control's horizontal alignment
// property to one of the following values:
//
// NUI_HALIGN_CENTER
// NUI_HALIGN_LEFT
// NUI_HALIGN_RIGHT
void NUI_SetHorizontalAlignment(int nAlignment);

// ---< NUI_BindHorizontalAlignment >---
// Dynamically bind the current control's horizontal
// alignment property to sBind.
void NUI_BindHorizontalAlignment(string sBind);

// ---< NUI_SetVerticalAlignment >---
// Statically set the current control's vertical alignment
// property to one of the following values:
//
// NUI_VALIGN_MIDDLE
// NUI_VALIGN_TOP
// NUI_VALIGN_BOTTOM
void NUI_SetVerticalAlignment(int nAlignment);

// ---< NUI_BindVerticalAlignment >---
// Dynamically bind the current control's vertical
// alignment property to sBind.
void NUI_BindVerticalAlignment(string sBind);

// ---< NUI_SetResref >---
// Statically sets the current control's resref property
// to sResref.
void NUI_SetResref(string sResref);

// ---< NUI_BindResref >---
// Dynamically binds the current control's resref property
// to sBind.
void NUI_BindResref(string sBind);

// ---< NUI_SetStatic >---
// Statically sets the current control's static property
// to bStatic.  If the current control is a textbox, the
// textbo will not be editable.
void NUI_SetStatic(int bStatic = TRUE);

// ---< NUI_SetPlaceholder >---
// Statically sets the current control's placeholder property
// to sPlaceholder.
void NUI_SetPlaceholder(string sPlaceholder = "");

// ---< NUI_BindPlaceholder >---
// Dynamically binds the current control's xxxxxx property
// to sBind.
void NUI_BindPlaceholder(string sBind);

// ---< NUI_SetMaxLength >---
// Statically sets the current control's maxlength property
// to nLength.
void NUI_SetMaxLength(int nLength = 50);

// ---< NUI_SetMultiline >---
// Statically sets the current control's multiline property
// to bMultiline.
void NUI_SetMultiline(int bMultiline = TRUE);

// ---< NUI_SetRowCount >---
// Statically sets the current control's rowcount property
// to nRowCount.
void NUI_SetRowCount(int nRowCount);

// ---< NUI_BindRowCount >---
// Dynamically binds the current control's rowcount property
// to sBind.
void NUI_BindRowCount(string sBind);

// ---< NUI_SetRowHeight >---
// Statically sets the current control's rowheight property
// to fRowHeight.
void NUI_SetRowHeight(float fRowHeight);

// ---< NUI_BindRowHeight >---
// Dynamically binds the current control's rowheight property
// to sBind.
void NUI_BindRowHeight(string sBind);

// ---< NUI_SetChecked >---
// Statically sets the current control's checked property
// to bChecked.
void NUI_SetChecked(int bChecked = TRUE);

// ---< NUI_BindChecked >---
// Dynamically binds the current control's checked property
// to sBind.
void NUI_BindChecked(string sBind);

// ---< NUI_SetDrawColor >---
// Statically sets the current control's drawcolor property
// to jColor.
void NUI_SetDrawColor(json jColor);

// ---< NUI_BindDrawColor >---
// Dynamically binds the current control's drawcolor property
// to sBind.
void NUI_BindDrawColor(string sBind);

// ---< xxxxxx >---
// Statically sets the current control's scissor property
// to bScissor.
void NUI_SetScissor(int bScissor);

// ---< NUI_SetLineThickness >---
// Statically sets the current control's linethickness property
// to fThickness.
void NUI_SetLineThickness(float fThickness);

// ---< NUI_BindLineThickness >---
// Dynamically binds the current control's linethickness property
// to sBind.
void NUI_BindLineThickness(string sBind);

// ---< NUI_SetFill >---
// Statically sets the current control's fill property
// to bFill.
void NUI_SetFill(int bFill = TRUE);

// ---< NUI_BindFill >---
// Dynamically binds the current control's fill property
// to sBind.
void NUI_BindFill(string sBind);

// ---< NUI_SetCenter >---
// Statically sets the current control's center property
// to a point defined by x, y.
void NUI_SetCenter(float x, float y);

// ---< NUI_SetDefinedCenter >---
// Statically sets the current control's center property
// to jCenter, which can be defined by NUI_DefinePoint().
void NUI_SetDefinedCenter(json jCenter);

// ---< NUI_BindCenter >---
// Dynamically binds the current control's center property
// to sBind.
void NUI_BindCenter(string sBind);

// ---< NUI_SetRadius >---
// Statically sets the current control's radius property
// to r.
void NUI_SetRadius(float r);

// ---< NUI_BindRadius >---
// Dynamically binds the current control's radius property
// to sBind.
void NUI_BindRadius(string sBind);

// ---< NUI_SetAMin >---
// Statically sets the current control's AMin property
// to fMultiplier.
void NUI_SetAMin(float fMultiplier);

// ---< NUI_BindAMin >---
// Dynamically binds the current control's AMin property
// to sBind.
void NUI_BindAMin(string sBind);

// ---< NUI_SetAMax >---
// Statically sets the current control's AMax property
// to fMultiplier.
void NUI_SetAMax(float fMultiplier);

// ---< NUI_BindAMax >---
// Dynamically binds the current control's AMax property
// to sBind.
void NUI_BindAMax(string sBind);

// ---< NUI_SetText >---
// Statically sets the current control's text property
// to sText.
void NUI_SetText(string sText);

// ---< NUI_BindText >---
// Dynamically binds the current control's text property
// to sBind.
void NUI_BindText(string sBind);

// ---< NUI_SetPoints >---
// Statically sets the current control's points property
// to jPoints.
void NUI_SetPoints(json jPoints);

// ---< NUI_BindPoints >---
// Dynamically binds the current control's points property
// to sBind.
void NUI_BindPoints(string sBind);

// ---< NUI_SetIntSliderBounds >---
// Statically sets the current control's lower bound to
// nLower, upper bound to nUpper and step value to nStep.
void NUI_SetIntSliderBounds(int nLower, int nUpper, int nStep);

// ---< NUI_SetFloatSliderBounds >---
// Statically sets the current control's lower bound to
// fLower, upper bound to fUpper and step value to fStep.
void NUI_SetFloatSliderBounds(float fLower, float fUpper, float fStep);

// ---< NUI_SetProgress >---
// Statically sets the current control's progress property
// to fValue.
void NUI_SetProgress(float fValue);

// ---< NUI_BindProgress >---
// Dynamically binds the current control's progress property
// to sBind.
void NUI_BindProgress(string sBind);

// ---< NUI_SetValue >---
// Statically sets the current control's value property to jValue.
void NUI_SetValue(json jValue);

// ---< NUI_BindValue >---
// Dynamically binds the current control's value property to sBind.
void NUI_BindValue(string sBind);

// ---< NUI_SetImage >---
// Statically sets the current control's image property
// to sResref.
void NUI_SetImage(string sResref);

// ---< NUI_BindImage >---
// Dynamically binds the current control's xxxxxx property
// to sBind.
void NUI_BindImage(string sBind);

// ---< NUI_SetEncouraged >---
// Statically sets the current control's encouraged property
// to bEncouraged.
void NUI_SetEncouraged(int bEncouraged = TRUE);

// ---< NUI_BindEncouraged >---
// Dynamically binds the current control's encouraged property
// to sBind.
void NUI_BindEncouraged(string sBind);

// ---< NUI_SetDisabledTooltip >---
// Statically sets the current control's disabled_tooltip property
// to string sTooltip.
void NUI_SetDisabledTooltip(string sTooltip);

// ---< NUI_BindDisabledTooltip >---
// Dynamically binds the current control's disabled_tooltip property
// to sBind.
void NUI_BindDisabledTooltip(string sBind);

// ---< NUI_SetRectangle >---
// Statically sets the current control's rect property
// to jRect.
void NUI_SetRectangle(json jRect);

// ---< NUI_SetScrollbars >---
// Statically sets the current control's scrollbars property
// to nScrollbars.
void NUI_SetScrollbars(int nScrollbars = NUI_SCROLLBARS_AUTO);

// ---< xxxxxx >---
// Statically sets the current control's xxxxxx property
// to xxxxxx.

// ---< xxxxxx >---
// Dynamically binds the current control's xxxxxx property
// to sBind.

// -----------------------------------------------------------------------------
//                        Event and Data Management
// -----------------------------------------------------------------------------

// ---< NUI_SetCustomProperty >---
// Sets custom data onto the current control.  This data will
// be returned during any event that is triggered by the
// associated control and can be accessed from the event data
// struct.
void NUI_SetCustomProperty(string sProperty, json jValue);

// ---< NUI_GetCustomProperty >---
// Retrieves custom property sProperty from user data jUserData.
json NUI_GetCustomProperty(json jUserData, string sProperty);

// ---< NUI_CountCustomProperties >---
// Counts the number of properties contined in jUserData.
// Combined with NUI_GetCustomPropertyByIndex(), can loop jUserData.
int NUI_CountCustomProperties(json jUserData);

// ---< NUI_GetCustomPropertyByIndex >---
// Returns the custom proeprty from jUserData at index nIndex.
json NUI_GetCustomPropertyByIndex(json jUserData, int nIndex);

// ---< NUI_SetBindScript >---
// Sets the script that this control will use when the initial
// bind function is called.  All children of the current control
// (such as controls within control groups) will also use this
// bind script unless specifically excluded.
void NUI_SetBindScript(string sScript);

// ---< NUI_SetEventScript >---
// Sets the script that this control will use when an event
// is triggered by the current control.  All children of the
// current control (such as controls within control groups) 
// will also use this event script unless specifically excluded.
void NUI_SetEventScript(string sScript);

// ---< NUI_SetBindFunction >---
// Sets the function that this control will use when the initial
// bind function is called.  All children of the current control
// (such as controls within control groups) will also use this
// bind function unless specifically excluded.
void NUI_SetBindFunction(string sFunction);

// ---< NUI_SetEventFunction >---
// Sets the function that this control will use when an event
// is triggered by the current control.  All children of the
// current control (such as controls within control groups) 
// will also use this event function unless specifically excluded.
void NUI_SetEventFunction(string sFunction);

// ---< NUI_SetFormScript >---
// Convenience function to set both the bind and event script
// to sScript.
void NUI_SetFormScript(string sScript);

// ---< NUI_SetFormFunction >---
// Convenience function to set both the bind and event function
// to sFunction.
void NUI_SetFormFunction(string sFunction);

// ---< NUI_SetBindValue >---
// Sets the bind value for sBind to jValue only for window
// nToken if displayed for oPC.
void NUI_SetBindValue(object oPC, int nToken, string sBind, json jValue);

// ---< NUI_DelayBindValue >---
// Sets the bind value for sBind to jValue only for window
// nToken if displayed for oPC.  Adds a short delay to the bind
// for situations where the bind value is destroyed by NUI.
void NUI_DelayBindValue(object oPC, int nToken, string sBind, json jValue);

// ---< NUI_SetBindWatch >---
// Starts or stops a bind value watch for sBind on window
// nToken for player oPC.
void NUI_SetBindWatch(object oPC, int nToken, string sBind, int bWatch = TRUE);

// ---< NUI_GetBindValue >---
// Returns the json value bound to sBind for oPC's window nToken.
json NUI_GetBindValue(object oPC, int nToken, string sBind);

// ---< NUI_GetBindData >---
// ** ADVANCED USAGE **
// Returns a bind table of all controls that have bind values associated
// with them.  This is primarily used during the form opening
// sequence to set intial bind values.
struct NUIBindData NUI_GetBindData();

// ---< NUI_GetBindArrayData >---
// ** ADVANCED USAGE **
// Returns a struct of specified bind data from jBinds at index n.
// Should only be used with data returned from NUI_GetBindData().
struct NUIBindArrayData NUI_GetBindArrayData(json jBinds, int n);

// ---< NUI_GetEventData >---
// Returns events data for the current NUI event.  Event data includes
// custom user data set on the control that triggered the event.
struct NUIEventData NUI_GetEventData(int bIncludeChildren = TRUE);

// ---< NUI_GetEventArrayData >---
// Returns a struct of specific bind data for jBinds at index n.
// Should only be used with data returned from NUI_GetEventData.
struct NUIEventArrayData NUI_GetEventArrayData(json jBinds, int n);

// -----------------------------------------------------------------------------
//                             Private Functions
// -----------------------------------------------------------------------------

void NUI_ClearBuildVariables();
json NUI_CreateListboxRowTemplate(json jControl);
void NUI_SetBindData(object oPC, int nToken, string sFormID, json jBinds);
void NUI_SetBindValue(object oPC, int nFormToken, string sBind, json jValue);
object NUI_GetBindObject(object oPC, string sObject);
void NUI_CreateControl(string sType, string sID = "");
void NUI_DeleteBindData(object oPC);
string NUI_GetStandardBind(object oPC, string sValue);
void NUI_CreateListbox();
void NUI_CreateGroup();
json NUI_CreateCellTemplate(string sElement, float fDimension = -1.0);

string NUI_GetKey(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1) return sPair;
    else              return GetSubString(sPair, 0, nIndex);
}

string NUI_GetValue(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1) return "";
    else              return GetSubString(sPair, ++nIndex, GetStringLength(sPair));
}

void NUI_SetCurrentOperation(int nOperation)
{
    SetLocalInt(GetModule(), NUI_CURRENT_OPERATION, nOperation);
}

int NUI_GetCurrentOperation()
{
    return GetLocalInt(GetModule(), NUI_CURRENT_OPERATION);
}

void NUI_ClearCurrentOperation()
{
    DeleteLocalInt(GetModule(), NUI_CURRENT_OPERATION);
}

int NUI_ExecuteFileFunction(string sFile, string sFunction, object oTarget = OBJECT_SELF, string sArguments = "")
{
    if (sFile == "" || sFunction == "")
        return FALSE;

    if (sArguments != "")
        sArguments = "\"" + sArguments + "\"";

    string sChunk = "#" + "include \"" + sFile + "\" " +
        "void main() {" + sFunction + "(" + sArguments + ");}";

    if (GetLocalInt(GetModule(), "DEBUG_FILE_FUNCTION") || TRUE)
    {
        string sError = ExecuteScriptChunk(sChunk, oTarget, FALSE);
        if (sError != "" && FindSubString(sError, "Chunk(1)") == -1)
            NUI_Debug(sError, NUI_DEBUG_SEVERITY_ERROR);

        return sError == "";
    }
    else
        return ExecuteScriptChunk(sChunk, oTarget, FALSE) == "";
}

int NUI_GetBuildLayer()
{
    return GetLocalInt(GetModule(), NUI_BUILD_LAYER);
}

void NUI_ResetBuildLayer()
{
    DeleteLocalInt(GetModule(), NUI_BUILD_LAYER);
}

void NUI_IncrementBuildLayer()
{
    int nLayer = NUI_GetBuildLayer();
    SetLocalInt(GetModule(), NUI_BUILD_LAYER, ++nLayer);

    NUI_ClearBuildVariables();
}

void NUI_DecrementBuildLayer()
{
    NUI_ClearBuildVariables();

    int nLayer = NUI_GetBuildLayer();
    SetLocalInt(GetModule(), NUI_BUILD_LAYER, max(0, --nLayer));
}

void NUI_SetBuildVariable(string sVariable, json jValue)
{
    sVariable += IntToString(NUI_GetBuildLayer());
    SetLocalJson(GetModule(), sVariable, jValue);
}

json NUI_GetBuildVariable(string sVariable, int nLayer = -1)
{
    if (nLayer == -1)
        nLayer = NUI_GetBuildLayer();

    sVariable += IntToString(nLayer);
    return GetLocalJson(GetModule(), sVariable);
}

void NUI_DeleteBuildVariable(string sVariable)
{
    sVariable += IntToString(NUI_GetBuildLayer());
    DeleteLocalJson(GetModule(), sVariable);
}

string NUI_GetLayoutOrientation()
{
    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    json jOrientation = JsonObjectGet(jRoot, NUI_PROPERTY_ORIENTATION);

    if (jOrientation == JsonNull())
        return "";
    else
        return JsonGetString(jOrientation);
}

string NUI_GetBuildMode()
{
    string sLayer = IntToString(NUI_GetBuildLayer());
    return GetLocalString(GetModule(), NUI_BUILD_MODE + sLayer);
}

void NUI_ResetBuildMode()
{   
    string sLayer = IntToString(NUI_GetBuildLayer());
    DeleteLocalString(GetModule(), NUI_BUILD_MODE + sLayer);
}

void NUI_SetBuildMode(string sMode)
{
    string sLayer = IntToString(NUI_GetBuildLayer());
    SetLocalString(GetModule(), NUI_BUILD_MODE + sLayer, sMode);
}

int NUI_GetRunningPathIndex()
{
    string sLayer = IntToString(NUI_GetBuildLayer());
    string sSource = GetLocalString(GetModule(), NUI_CONTROL_PATH + sLayer);
    return StringToInt(GetListItem(sSource, CountList(sSource) - 1));
}

string NUI_GetRunningPathSource()
{
    string sLayer = IntToString(NUI_GetBuildLayer());
    return GetLocalString(GetModule(), NUI_CONTROL_PATH + sLayer);
}

void NUI_SetRunningPathSource(string sPath)
{
    string sLayer = IntToString(NUI_GetBuildLayer());
    SetLocalString(GetModule(), NUI_CONTROL_PATH + sLayer, sPath);
}

void NUI_AddRunningPath(string sElement = NUI_PROPERTY_CHILDREN, int bAddIndex = TRUE)
{
    string sPath = NUI_GetRunningPathSource();

    if (NUI_GetBuildMode() == NUI_ELEMENT_LISTBOX)
        sPath = AddListItem(sPath, sElement);
    else
    {
        sPath = AddListItem(sPath, sElement);
        
        if (bAddIndex == TRUE)
            sPath = AddListItem(sPath, "-1");
    }

    NUI_SetRunningPathSource(sPath);
}

void NUI_NormalizeRunningPath(string sElement)
{
    string sOrientation = NUI_GetLayoutOrientation();
    string sMode = NUI_GetBuildMode();
    int bMatch, nCount, bLayer = NUI_GetBuildLayer() > 0;

    if (sOrientation != "")
    {
        if (sElement == NUI_ELEMENT_CONTROL)
            nCount = 7 + bLayer;
        else
        {
            int bMatch = (sOrientation == NUI_ORIENTATION_COLUMNS && sElement == NUI_ELEMENT_COLUMN) ||
                    (sOrientation == NUI_ORIENTATION_ROWS && sElement == NUI_ELEMENT_ROW);
    
            nCount = (bMatch ? 3 : 5) + bLayer;
        }

        string sPath, sSource = NUI_GetRunningPathSource();
        sPath = CopyListItem(sSource, sPath, 0, nCount);

        NUI_SetRunningPathSource(sPath);
    }
    else if (sMode == NUI_ELEMENT_LISTBOX)
        nCount = CountList(NUI_PATH_LISTBOX);
    else if (sMode == NUI_ELEMENT_TEMPLATE)
        NUI_SetRunningPathSource("");
    else
        NUI_Debug("NUI Build error in NUI_NormalizeRunningPath; could not " +
            "handle normalization for sElement = " + sElement, NUI_DEBUG_SEVERITY_ERROR);
}

string NUI_GetRunningPath(int bDropIndex = FALSE)
{
    string sPath, sSource = NUI_GetRunningPathSource();
    int n, nCount = CountList(sSource);

    for (n = 0; n < nCount - bDropIndex; n++)
        sPath += "/" + GetListItem(sSource, n);

    return sPath;
}

void NUI_IncrementRunningPath()
{
    string sPath, sSource = NUI_GetRunningPathSource();
    int nIndex = CountList(sSource) - 1;
    int nStep = StringToInt(GetListItem(sSource, nIndex)) + 1;

    sPath = DeleteListItem(sSource, nIndex);
    sPath = AddListItem(sPath, IntToString(nStep));

    NUI_SetRunningPathSource(sPath);
}

void NUI_DropRunningPath(int nCount = 2)
{
    string sPath, sSource = NUI_GetRunningPathSource();
    sPath = CopyListItem(sSource, sPath, 0, CountList(sSource) - nCount);

    NUI_SetRunningPathSource(sPath);    
}

void NUI_ResetRunningPath(int bDelete = FALSE)
{
    string sPath;
    int nLayer = NUI_GetBuildLayer();
    
    if (bDelete == TRUE)
        DeleteLocalString(GetModule(), NUI_CONTROL_PATH + IntToString(nLayer));
    else
    {
        if (nLayer == 0)
            sPath = NUI_PATH_ROOT;
        else
        {
            string sMode = NUI_GetBuildMode();
            if (sMode == NUI_ELEMENT_GROUP)
                sPath = NUI_PATH_GROUP;
            else if (sMode == NUI_ELEMENT_LISTBOX)
                sPath = NUI_PATH_LISTBOX;
            else if (sMode == NUI_ELEMENT_CANVAS)
                sPath = NUI_PATH_DRAWLIST;
            else if (sMode == NUI_ELEMENT_TEMPLATE)
                sPath = "";
        }
        
        NUI_SetRunningPathSource(sPath);
    }
}

int NUI_GetLengthAtRunningPath(string sPath = "")
{
    if (sPath == "")
        sPath = NUI_GetRunningPath(TRUE);

    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);

    return JsonGetLength(JsonPointer(jRoot, sPath));
}

json NUI_GetCurrentControl(string sPath = "")
{
    if (sPath == "")
        sPath = NUI_GetRunningPath();
    
    return JsonPointer(NUI_GetBuildVariable(NUI_BUILD_ROOT), sPath == "" ? "/" : sPath);
}

string NUI_GetCurrentControlType(string sPath = "")
{
    json jControl = NUI_GetCurrentControl(sPath);
    return JsonGetString(JsonObjectGet(jControl, NUI_PROPERTY_TYPE));
}

void NUI_SetControlWrap()
{
    string sLayer = IntToString(NUI_GetBuildLayer());
    SetLocalInt(GetModule(), NUI_BUILD_WRAP + sLayer, TRUE);
}

int NUI_GetControlWrap()
{
    string sLayer = IntToString(NUI_GetBuildLayer());
    return GetLocalInt(GetModule(), NUI_BUILD_WRAP + sLayer);
}

void NUI_ResetControlWrap()
{
    string sLayer = IntToString(NUI_GetBuildLayer());
    DeleteLocalInt(GetModule(), NUI_BUILD_WRAP + sLayer);
}

int NUI_GetCellStructureIsEmpty()
{
    string sSource = NUI_GetRunningPathSource();

    if (NUI_GetBuildLayer() == 0 && sSource == "")
        return TRUE;
    else if (NUI_GetBuildMode() == NUI_ELEMENT_GROUP && sSource == NUI_PATH_GROUP)
        return TRUE;
    else
        return FALSE;
}

void NUI_ClearBuildVariables()
{
    NUI_ResetBuildMode();
    NUI_ResetRunningPath(TRUE);
    NUI_ResetControlWrap();
    NUI_DeleteBuildVariable(NUI_BUILD_ROOT);
}


json NUI_HandleUniquePatchRequirements(json j, string sOperation = "add")
{
    string sMode = NUI_GetBuildMode();
    if (sMode == NUI_ELEMENT_LISTBOX)
    {
        if (sOperation == "add")
            j = NUI_CreateListboxRowTemplate(j);
    }

    return j;
}

void NUI_ApplyPatchToRoot(json j, string sOperation = "add", string sPath = "")
{
    if (sPath == "")
        sPath = NUI_GetRunningPath();

    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);

    json jEdit = JsonObject();
         jEdit = JsonObjectSet(jEdit, "op", JsonString(sOperation));
         jEdit = JsonObjectSet(jEdit, "path", JsonString(sPath));
         jEdit = JsonObjectSet(jEdit, "value", j);

    json jPatch = JsonArray();
         jPatch = JsonArrayInsert(jPatch, jEdit);

    jRoot = JsonPatch(jRoot, jPatch);
    NUI_SetBuildVariable(NUI_BUILD_ROOT, jRoot);
}

void NUI_HandleUniquePropertyRequirements(string sProperty, json jValue)
{
    string sMode = NUI_GetBuildMode();
    string sPath = NUI_GetRunningPath();
    json jControl = NUI_GetCurrentControl();
    int bControlFlag = sPath != "";

    if (sMode == NUI_ELEMENT_LISTBOX)
    {
        if (sProperty == NUI_PROPERTY_RESIZABLE)
            sPath += "/2";
        else if (sProperty == NUI_PROPERTY_STATIC)
            sPath += "/2";
        else if (bControlFlag == TRUE)
            sPath += "/0/" + sProperty;
        else if (bControlFlag == FALSE)
            sPath = "/" + sProperty;

        NUI_ApplyPatchToRoot(jValue, "add", sPath);
    }
    else if (sMode == NUI_ELEMENT_GROUP)
        NUI_ApplyPatchToRoot(jControl, "replace");
    else if (sMode == NUI_ELEMENT_CANVAS)
        NUI_ApplyPatchToRoot(jControl, "replace");
}

json NUI_GetTemplateControl(string sID)
{
    return GetLocalJson(GetModule(), NUI_ELEMENT_TEMPLATE + sID);
}

json NUI_SetObjectProperty(json jObject, string sProperty, json jValue)
{
    return JsonObjectSet(jObject, sProperty, jValue);
}

void NUI_SetCurrentControlObjectProperty(string sProperty, json jValue)
{
    string sPath = NUI_GetRunningPath();
    string sMode = NUI_GetBuildMode();

    if (sMode == NUI_ELEMENT_LISTBOX)
    {
        NUI_HandleUniquePropertyRequirements(sProperty, jValue);
        return;
    }

    if (sMode == NUI_ELEMENT_GROUP && NUI_GetRunningPathSource() == NUI_PATH_GROUP)
        sPath = "";

    NUI_ApplyPatchToRoot(jValue, "add",  sPath + "/" + sProperty);
}

json NUI_BindVariable(string sVariableName)
{
    json j = JsonString(sVariableName);
    return JsonObjectSet(JsonObject(), NUI_PROPERTY_BIND, j);
}

void NUI_SetCustomControlProperty(string sNode, string sProperty, json jValue)
{
    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    string sPath = NUI_GetRunningPath() + "/" + sNode;

    json jData = JsonPointer(jRoot, sPath);

    if (jData == JsonNull())
        jData = JsonObject();

    jData = JsonObjectSet(jData, sProperty, jValue);
    NUI_ApplyPatchToRoot(jData, "add", sPath);
}

void NUI_SetHandler(string sNode, string sProperty, string sScript)
{
    NUI_SetCustomControlProperty(sNode, sProperty, JsonString(sScript));
}

void NUI_RunHandler(string sType, string sFormID, string sControlID, object oTarget)
{
    if (NUI_RunScript(NUI_GetHandler(sFormID, sControlID, sType, "script"), oTarget) == FALSE)
    {
        string sFormfile = NUI_GetFormfile(sFormID);
        string sFunction = NUI_GetHandler(sFormID, sControlID, sType, "function");

        if (NUI_ExecuteFileFunction(sFormfile, sFunction, oTarget) == FALSE)
        {
            if (sType == NUI_PROPERTY_EVENTDATA)
                sFunction = NUI_FORMFILE_EVENTS_FUNCTION;
            else if (sType == NUI_PROPERTY_BINDDATA)
                sFunction = NUI_FORMFILE_BINDS_FUNCTION;
            else if (sType == NUI_PROPERTY_BUILDDATA)
                sFunction = NUI_FORMFILE_BUILDS_FUNCTION;

            if (NUI_ExecuteFileFunction(sFormfile, sFunction, oTarget) == FALSE)
            {
                NUI_Debug("Handler not found for " + sType + ":" +
                    "\n  sFormID -> " + sFormID +
                    "\n  sControlID -> " + sControlID +
                    "\n  sFormfile -> " + sFormfile +
                    "\n  sFunction -> " + sFunction +
                    "\n  oTarget -> " + GetName(oTarget), NUI_DEBUG_SEVERITY_ERROR);
            }
        }
    }
}

void NUI_RunEventHandler()
{
    object oPC = NuiGetEventPlayer();
    string sFormID = NuiGetWindowId(oPC, NuiGetEventWindow());
    string sControlID = NuiGetEventElement();
    string sEventType = NuiGetEventType();
    string sFunction = (sControlID == "_window_" ? "form" : sControlID) + "_" + sEventType;

    if (HasListItem(NUI_IGNORE_EVENTS, sEventType))
        return;

    NUI_SetCurrentOperation(NUI_OPERATION_EVENT);

    string sFormfile = NUI_GetFormfile(sFormID);
    if (NUI_ExecuteFileFunction(sFormfile, sFunction, oPC) == FALSE)
    {
        if (NUI_ExecuteFileFunction(sFormfile, sControlID, oPC) == FALSE)
            NUI_RunHandler(NUI_PROPERTY_EVENTDATA, sFormID, sControlID, oPC);
    }

    NUI_ClearCurrentOperation();
}

void NUI_RunNUIEventHandler()
{
    NUI_RunEventHandler();
}

void NUI_RunModuleEventFunction(object oPC, string sFunction)
{
    int n, nToken;

    do 
    {
        if ((nToken = NuiGetNthWindow(oPC, n++)) > 0)
        {
            string sFormID = NuiGetWindowId(oPC, nToken);
            NUI_ExecuteFileFunction(NUI_GetFormfile(sFormID), sFunction, oPC);
        }
    } while (nToken != 0);
}

void NUI_RunModuleEventHandler(object oPC = OBJECT_SELF)
{
    NUI_RunModuleEventFunction(oPC, "HandleModuleEvents");
}

void NUI_RunTargetingEventHandler()
{
    NUI_RunModuleEventFunction(GetLastPlayerToSelectTarget(), "HandlePlayerTargeting");
}

void NUI_RunGUIEventHandler()
{
    NUI_RunModuleEventFunction(GetLastGuiEventPlayer(), "HandleGUIEvents");
}

void NUI_DropBuildLayer()
{
    json j = NUI_GetBuildVariable(NUI_BUILD_ROOT);

    NUI_DecrementBuildLayer();
    NUI_ApplyPatchToRoot(j, "replace");
}

void NUI_AddBuildLayer(string sControl)
{
    if (sControl != NUI_ELEMENT_CANVAS)
        NUI_CreateControl(sControl);
    else
    {
        json j = NUI_GetBuildVariable(NUI_BUILD_ROOT);
             j = JsonPointer(j, NUI_GetRunningPath());

        NUI_IncrementBuildLayer();
        NUI_SetBuildVariable(NUI_BUILD_ROOT, j);
        NUI_SetBuildMode(sControl);
        NUI_ResetRunningPath();
        NUI_IncrementRunningPath();
    }
}

string NUI_GetCellDepthPath(int nDepth)
{
    string sPath, sSource = NUI_GetRunningPathSource();
    int n, nBase = CountList(NUI_PATH_ROOT);
    int bLayer = NUI_GetBuildLayer() > 0;

    if (bLayer == TRUE)
    {
        string sMode = NUI_GetBuildMode();
        if (sMode == NUI_ELEMENT_GROUP)
        {
            nBase = CountList(NUI_PATH_GROUP);
        }
    }

    for (n = 0; n < nBase + (nDepth * 2); n++)
        sPath += "/" + GetListItem(sSource, n);

    return sPath;
}

json NUI_GetCellDepthPointer(int nDepth)
{
    return JsonPointer(NUI_GetBuildVariable(NUI_BUILD_ROOT), NUI_GetCellDepthPath(nDepth));
}

int NUI_CountCellsAtDepth(int nDepth)
{
    return JsonGetLength(NUI_GetCellDepthPointer(nDepth));
}

int NUI_GetCellsExistAtDepth(int nDepth)
{
    return NUI_GetCellDepthPointer(nDepth) != JsonNull();
}

void NUI_IncrementCellsAtDepth(int nDepth, float fDimension = -1.0)
{
    if (NUI_GetBuildLayer() == 0 && NUI_GetRunningPathSource() == "")
        NUI_ResetRunningPath();

    string sElement, sOrientation = NUI_GetLayoutOrientation();

    if (sOrientation == NUI_ORIENTATION_COLUMNS && nDepth == 0)
        sElement = NUI_ELEMENT_COLUMN;
    else if (sOrientation == NUI_ORIENTATION_COLUMNS && nDepth == 1)
        sElement = NUI_ELEMENT_ROW;
    else if (sOrientation == NUI_ORIENTATION_ROWS && nDepth == 0)
        sElement = NUI_ELEMENT_ROW;
    else if (sOrientation == NUI_ORIENTATION_ROWS && nDepth == 1)
        sElement = NUI_ELEMENT_COLUMN;

    if (nDepth == 1)
    {
        if (NUI_CountCellsAtDepth(0) == 0)
            NUI_IncrementCellsAtDepth(0);
    }

    if (NUI_GetRunningPath() == "")
        NUI_ResetRunningPath();
    NUI_AddRunningPath();
    NUI_NormalizeRunningPath(sElement);
    NUI_IncrementRunningPath();

    json jTemplate = NUI_CreateCellTemplate(sElement, fDimension);
    NUI_ApplyPatchToRoot(jTemplate);
}

void NUI_CreateGroup()
{
    NUI_AddBuildLayer(NUI_ELEMENT_GROUP);
}

void NUI_CreateListbox()
{
    NUI_AddBuildLayer(NUI_ELEMENT_LISTBOX);
}

void NUI_BindForm(object oPC, int nToken, string sProfileName)
{
    string sFormID = NuiGetWindowId(oPC, nToken);

    if (NUI_GetSkipAutoBind(sFormID) == FALSE)
    {
        // If you're skipping autobind, you better know what you're doing as there won't be any
        // bind data available to you during the form bind process.

        sqlquery sqlBinds = NUI_GetBindTable(sFormID);   

        //json jBinds = NUI_GetJSONBindTable(sFormID);
        //jBinds = JsonArrayTransform(jBinds, JSON_ARRAY_UNIQUE);

        json jBinds = JsonArray();

        while (SqlStep(sqlBinds))
        {
            json jBind = JsonObject();
                 jBind = JsonObjectSet(jBind, NUI_BIND_TYPE, JsonString(SqlGetString(sqlBinds, 0)));
                 jBind = JsonObjectSet(jBind, NUI_BIND_PROPERTY, JsonString(SqlGetString(sqlBinds, 2)));
                 jBind = JsonObjectSet(jBind, NUI_BIND_VARIABLE, JsonString(SqlGetString(sqlBinds, 3)));
                 jBind = JsonObjectSet(jBind, NUI_BIND_USERDATA, SqlGetJson(sqlBinds, 4));

            jBinds = JsonArrayInsert(jBinds, jBind);
        }

        NUI_SetBindData(oPC, nToken, sFormID, jBinds);
    }

    NUI_SetCurrentOperation(NUI_OPERATION_BIND);
    NUI_ExecuteFileFunction(NUI_GetFormfile(sFormID), NUI_FORMFILE_BINDS_FUNCTION, oPC, sProfileName);
    NUI_ClearCurrentOperation();
}

json NUI_CreateCanvasTemplate()
{
    json j = JsonObject();
         j = JsonObjectSet(j, NUI_PROPERTY_TYPE, JsonNull());
         j = JsonObjectSet(j, NUI_PROPERTY_ENABLED, jTRUE);
         j = JsonObjectSet(j, NUI_PROPERTY_COLOR, NUI_DefineRGBColor(255, 255, 255));
         j = JsonObjectSet(j, NUI_PROPERTY_FILL, jFALSE);
         j = JsonObjectSet(j, NUI_PROPERTY_LINETHICKNESS, JsonFloat(0.5));
         j = JsonObjectSet(j, NUI_PROPERTY_POSITION, JsonInt(NUI_POSITION_ABOVE));
         j = JsonObjectSet(j, NUI_PROPERTY_CONDITION, JsonInt(NUI_CONDITION_ALWAYS));

    return j;
}

void NUI_BuildCanvas(json jCanvas)
{
    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    json jPointer = JsonPointer(jRoot, "/" + NUI_ELEMENT_DRAWLIST);
    
    if (JsonGetLength(jPointer) == 0)
        NUI_ResetRunningPath();

    NUI_IncrementRunningPath();
    NUI_ApplyPatchToRoot(jCanvas);
}

json NUI_CreateCellTemplate(string sElement, float fDimension = -1.0)
{
    json jTemplate = JsonObject();
         jTemplate = JsonObjectSet(jTemplate, NUI_PROPERTY_CHILDREN, JsonArray());
         jTemplate = JsonObjectSet(jTemplate, NUI_PROPERTY_TYPE, JsonString(sElement));
         jTemplate = JsonObjectSet(jTemplate, NUI_PROPERTY_VISIBLE, jTRUE);
         jTemplate = JsonObjectSet(jTemplate, NUI_PROPERTY_ENABLED, jTRUE);

    if (fDimension > -1.0)
    {
        string sProperty = (sElement == NUI_ELEMENT_COLUMN ? NUI_PROPERTY_WIDTH : NUI_PROPERTY_HEIGHT);
        jTemplate = JsonObjectSet(jTemplate, sProperty, JsonFloat(fDimension));
    }

    return jTemplate;
}

json NUI_CreateListboxRowTemplate(json jControl)
{
    json j = JsonArray();
         j = JsonArrayInsert(j, jControl);
         j = JsonArrayInsert(j, JsonFloat(0.0));
         j = JsonArrayInsert(j, jFALSE);

    return j;
}

void NUI_CreateControl(string sType, string sID = "")
{
    string sMode = NUI_GetBuildMode();

    if (sMode != NUI_ELEMENT_LISTBOX)
    {   
        if (NUI_GetCellsExistAtDepth(1) == FALSE)
            NUI_SetControlWrap();

        if (NUI_GetControlWrap() == TRUE)
            NUI_IncrementCellsAtDepth(1);

        NUI_AddRunningPath();
        NUI_NormalizeRunningPath(NUI_ELEMENT_CONTROL);

        if (sType == NUI_ELEMENT_TEMPLATE)
            NUI_IncrementRunningPath();
        else if (sMode != NUI_ELEMENT_TEMPLATE)
            NUI_IncrementRunningPath();
    }
    else
    {
        if (NUI_GetRunningPathSource() == "")
            NUI_ResetRunningPath();

        NUI_IncrementRunningPath();
    }

    json j = JsonObject();

    j = NUI_SetObjectProperty(j, NUI_PROPERTY_TYPE, JsonString(sType));
    j = NUI_SetObjectProperty(j, NUI_PROPERTY_LABEL, JsonNull());
    j = NUI_SetObjectProperty(j, NUI_PROPERTY_VALUE, JsonNull());
    j = NUI_SetObjectProperty(j, NUI_PROPERTY_ENABLED, jTRUE);
    j = NUI_SetObjectProperty(j, NUI_PROPERTY_VISIBLE, jTRUE);
    j = NUI_SetObjectProperty(j, NUI_PROPERTY_UUID, JsonString(GetRandomUUID()));
    j = NUI_SetObjectProperty(j, NUI_PROPERTY_USERDATA, JsonObject());
    j = NUI_SetObjectProperty(j, NUI_PROPERTY_BINDDATA, JsonObject());
    j = NUI_SetObjectProperty(j, NUI_PROPERTY_BUILDDATA, JsonObject());
    j = NUI_SetObjectProperty(j, NUI_PROPERTY_EVENTDATA, JsonObject());
    
    if (sID != "")
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_ID, JsonString(sID));

    if (sType == NUI_ELEMENT_GROUP)
    {
        json jTemplate = NUI_CreateCellTemplate(NUI_ELEMENT_ROW);
        json jChildren = JsonArray();
             jChildren = JsonArrayInsert(jChildren, jTemplate);

        if (sID != "")
            j = NUI_SetObjectProperty(j, NUI_PROPERTY_ID, JsonString(sID));

        j = NUI_SetObjectProperty(j, NUI_PROPERTY_BORDER, jTRUE);
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_ORIENTATION, JsonString(NUI_ORIENTATION_COLUMNS));
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_HEIGHT, JsonNull());
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_SCROLLBARS, JsonInt(NUI_SCROLLBARS_AUTO));
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_WIDTH, JsonNull());
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_CHILDREN, jChildren);
    }

    if (sType == NUI_ELEMENT_LISTBOX)
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_ROWTEMPLATE, JsonArray());

    if (sType == NUI_ELEMENT_OPTIONGROUP)
    {
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_DIRECTION, JsonInt(1));
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_ELEMENTS, JsonArray());
    }

    if (sType == NUI_ELEMENT_COMBOBOX)
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_ELEMENTS, JsonArray());

    if (sType == NUI_ELEMENT_FLOATSLIDER)
    {
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_VALUE, JsonFloat(0.0));
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_MIN, JsonFloat(0.0));
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_MAX, JsonFloat(1.0));
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_STEP, JsonFloat(0.01));
    }

    if (sType == NUI_ELEMENT_INTSLIDER)
    {
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_VALUE, JsonInt(0));
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_MIN, JsonInt(0));
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_MAX, JsonInt(100));
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_STEP, JsonInt(1));  
    }

    if (sType == NUI_ELEMENT_CHART)
        j = NUI_SetObjectProperty(j, NUI_PROPERTY_VALUE, JsonArray());
    
    if (sMode == NUI_ELEMENT_LISTBOX)
        j = NUI_HandleUniquePatchRequirements(j);

    if (sType == NUI_ELEMENT_TEMPLATE)
        j = NUI_GetTemplateControl(sID);

    NUI_ApplyPatchToRoot(j);

    if (sType == NUI_ELEMENT_GROUP || sType == NUI_ELEMENT_LISTBOX)
    {
        NUI_IncrementBuildLayer();
        NUI_SetBuildVariable(NUI_BUILD_ROOT, j);

        NUI_SetBuildMode(sType);
        NUI_ResetRunningPath(sType == NUI_ELEMENT_LISTBOX);
    }
}

object NUI_GetBindObject(object oPC, string sObject)
{
    if (sObject == NUI_BIND_PC)
        return oPC;
    else if (sObject == NUI_BIND_MODULE || sObject == "")
        return GetModule();
    else
        return GetObjectByTag(sObject);

    return OBJECT_INVALID;
}

json NUI_GetResrefArray(string sPrefix, int nResType = RESTYPE_NSS, int bSearchBase = FALSE, string sFolders = "")
{
    json jResrefs = JsonArray();

    string sResref;
    int n = 1;

    while ((sResref = ResManFindPrefix(sPrefix, nResType, n++, bSearchBase, sFolders)) != "")
        jResrefs = JsonArrayInsert(jResrefs, JsonString(sResref));

    return JsonGetLength(jResrefs) == 0 ? JsonNull() : jResrefs;
}

void NUI_DefineFormsByFormfile()
{
    int f, fCount = CountList(NUI_FORMFILE_PREFIX);
    for (f = 0; f < fCount; f++)
    {
        string sPrefix = GetListItem(NUI_FORMFILE_PREFIX, f);
        json jFormfiles = NUI_GetResrefArray(sPrefix);
        if (jFormfiles == JsonNull())
            return;

        NUI_SetCurrentOperation(NUI_OPERATION_DEFINE);

        int n, nCount = JsonGetLength(jFormfiles);
        for (n = 0; n < nCount; n++)
        {
            string sFormfile = JsonGetString(JsonArrayGet(jFormfiles, n));
            SetLocalString(GetModule(), NUI_CURRENT_FORMFILE, sFormfile);
            NUI_ExecuteFileFunction(sFormfile, NUI_FORMFILE_DEFINITION_FUNCTION);
        }

        NUI_ClearCurrentOperation();
    }
}

void NUI_CreateFormProfile(string sFormID, string sProfileName = "")
{
    if (sProfileName == "")
        sProfileName = "default";

    SetLocalString(GetModule(), "NUI_PROFILE", sFormID + ":" + sProfileName);
    SetLocalJson(GetModule(), "NUI_PROFILE", JsonObject());
}

void NUI_SetProfileProperty(string sProperty, json jValue)
{
    json jProfile = GetLocalJson(GetModule(), "NUI_PROFILE");
    if (jProfile == JsonNull())
        jProfile = JsonObject();

    if (sProperty == "" || jValue == JsonNull())
        return;

    jProfile = JsonObjectSet(jProfile, sProperty, jValue);
    SetLocalJson(GetModule(), "NUI_PROFILE", jProfile);
}

void NUI_SaveFormProfile()
{
    string sProfile = GetLocalString(GetModule(), "NUI_PROFILE");
    string sFormID = NUI_GetKey(sProfile);
    string sProfileName = NUI_GetValue(sProfile);
    json jProfile = GetLocalJson(GetModule(), "NUI_PROFILE");

    sQuery = "INSERT INTO " + NUI_PROFILES + " (form, name, profile) " +
             "VALUES (@form, @name, @profile) " +
             "ON CONFLICT (form, name) DO UPDATE " +
                "SET profile = @profile;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    SqlBindString(sql, "@name", sProfileName);
    SqlBindJson(sql, "@profile", jProfile);

    SqlStep(sql);

    DeleteLocalJson(GetModule(), "NUI_PROFILE");
    DeleteLocalJson(GetModule(), "NUI_PROFILE");
}

json NUI_GetFormProfile(string sFormID, string sProfileName)
{
    if (sFormID == "" || sProfileName == "")
        return JsonNull();

    sQuery = "SELECT profile " + 
            "FROM " + NUI_PROFILES + " " +
            "WHERE form = @form " +
                "AND name = @name;";
    sql = NUI_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    SqlBindString(sql, "@name", sProfileName);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

void NUI_InheritFormProfile(string sFormID, string sProfileName)
{
    json jProfile = NUI_GetFormProfile(sFormID, sProfileName);
    if (jProfile == JsonNull())
        return;

    SetLocalJson(GetModule(), "NUI_PROFILE", jProfile);
}

void NUI_SetFormProfile(string sFormID, string sProfileName, json jProfile)
{
    SetLocalString(GetModule(), "NUI_PROFILE", sFormID + ":" + sProfileName);
    SetLocalJson(GetModule(), "NUI_PROFILE", jProfile);
    NUI_SaveFormProfile();
}

// -----------------------------------------------------------------------------
//                              Public Functions
// -----------------------------------------------------------------------------

void NUI_Initialize()
{
    SetDebugLevel(DEBUG_LEVEL_NOTICE);
    SetDebugLogging(DEBUG_LOG_ALL);

    NUI_SetEventHandler();
    NUI_InitializeDatabase();
    //NUI_DefineCustomControlsByFile();
    NUI_DefineFormsByFormfile();
}

void NUI_CreateForm(string sID, string sVersion = "")
{
    json jRoot = JsonObject();
         jRoot = JsonObjectSet(jRoot, NUI_PROPERTY_CHILDREN, JsonArray());
         jRoot = JsonObjectSet(jRoot, NUI_PROPERTY_TYPE, JsonString(NUI_ELEMENT_ROW));
         jRoot = JsonObjectSet(jRoot, NUI_PROPERTY_ENABLED, jTRUE);
         jRoot = JsonObjectSet(jRoot, NUI_PROPERTY_VISIBLE, jTRUE);

    json j = JsonObject();
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_ID, JsonString(sID));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_VERSION, JsonInt(1));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_TITLE, JsonNull());
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_ROOT, jRoot);
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_GEOMETRY, JsonNull());
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_RESIZABLE, JsonBool(FALSE));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_COLLAPSIBLE, JsonBool(FALSE));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_MODAL, JsonBool(TRUE));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_TRANSPARENT, JsonBool(FALSE));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_BORDER, JsonBool(TRUE));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_ORIENTATION, JsonString(NUI_ORIENTATION_COLUMNS));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_UUID, JsonString(GetRandomUUID()));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_USERDATA, JsonObject());
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_BINDDATA, JsonObject());
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_BUILDDATA, JsonObject());
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_EVENTDATA, JsonObject());

    NUI_ResetBuildLayer();
    NUI_ClearBuildVariables();
    NUI_SetBuildVariable(NUI_BUILD_ROOT, j);

    if (sID != "")
    {
        if (GetStringLeft(sID, 1) == "_")
            NUI_Debug(" > Defining tab " + sID + (sVersion == "" ? "" : " (Version " + sVersion + ")"), NUI_DEBUG_SEVERITY_NOTICE);
        else
            NUI_Debug("Defining form " + sID + (sVersion == "" ? "" : " (Version " + sVersion + ")"), NUI_DEBUG_SEVERITY_NOTICE);
    }
}

void NUI_SaveForm()
{
    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    string sID = JsonGetString(JsonObjectGet(jRoot, NUI_PROPERTY_ID));

    NUI_SaveFormJSON(sID, jRoot);
    NUI_SetFormfile(sID, GetLocalString(GetModule(), NUI_CURRENT_FORMFILE));
}

int NUI_DisplayForm(object oPC, string sFormID, string sProfileName = "default")
{
    json j = NUI_GetFormJSON(sFormID);
    if (j != JsonNull())
    {
        // if there are any custom controls, populate the required data ...
        //NUI_PopulateBuildJSON(oPC, sFormID);

        int nToken = NuiCreate(oPC, j, sFormID);
        NUI_BindForm(oPC, nToken, sProfileName);
        return nToken;
    }
    else
        NUI_Debug("JSON data for form '" + sFormID + "' not found", NUI_DEBUG_SEVERITY_CRITICAL);

    return -1;
}

void NUI_DestroyForm(object oPC, int nToken)
{
    NuiDestroy(oPC, nToken);
}

json NUI_DefinePoint(float x, float y)
{
    json j = JsonObject();
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_X, JsonFloat(x));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_Y, JsonFloat(y));
    return j;
}

json NUI_DefineRGBColor(int r, int g, int b, int a = 255)
{
    json j = JsonObject();
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_R, JsonInt(r));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_G, JsonInt(g));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_B, JsonInt(b));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_A, JsonInt(a));
    return j;
}

json NUI_GetLinePoints(float x1, float y1, float x2, float y2)
{
    json j = JsonArray();
         j = JsonArrayInsert(j, JsonFloat(x1));
         j = JsonArrayInsert(j, JsonFloat(y1));
         j = JsonArrayInsert(j, JsonFloat(x2));
         j = JsonArrayInsert(j, JsonFloat(y2));

    return j;
}

json NUI_AddLinePoint(json jPoints, float x, float y)
{
    jPoints = JsonArrayInsert(jPoints, JsonFloat(x));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(y));

    return jPoints;
}

json NUI_DefineHSVColor(float h, float s, float v)
{
    struct HSV hsv;
    hsv.h = h;
    hsv.s = s;
    hsv.v = v;

    struct RGB rgb = HSVToRGB(hsv);
    return NUI_DefineRGBColor(rgb.r, rgb.g, rgb.b);
}

json NUI_DefineHexColor(int nColor)
{
    struct RGB rgb = HexToRGB(nColor);
    return NUI_DefineRGBColor(rgb.r, rgb.g, rgb.b);
}

json NUI_DefineRandomRGBColor()
{
    return NUI_DefineRGBColor(Random(256), Random(256), Random(256));
}

json NUI_DefineRectangle(float x, float y, float w, float h)
{
    json j = JsonObject();
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_X, JsonFloat(x));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_Y, JsonFloat(y));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_W, JsonFloat(w));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_H, JsonFloat(h));
    return j;
}

json NUI_GetRectanglePoints(float x, float y, float w, float h)
{
    json j = JsonArray();
         j = JsonArrayInsert(j, JsonFloat(x));
         j = JsonArrayInsert(j, JsonFloat(y));
         j = JsonArrayInsert(j, JsonFloat(x + w));
         j = JsonArrayInsert(j, JsonFloat(y));
         j = JsonArrayInsert(j, JsonFloat(x + w));
         j = JsonArrayInsert(j, JsonFloat(y + h));
         j = JsonArrayInsert(j, JsonFloat(x));
         j = JsonArrayInsert(j, JsonFloat(y + h));
         j = JsonArrayInsert(j, JsonFloat(x));
         j = JsonArrayInsert(j, JsonFloat(y));

    return j;
}

json NUI_GetDefinedRectanglePoints(json jRectangle)
{
    float x = JsonGetFloat(JsonObjectGet(jRectangle, NUI_PROPERTY_X));
    float y = JsonGetFloat(JsonObjectGet(jRectangle, NUI_PROPERTY_Y));
    float w = JsonGetFloat(JsonObjectGet(jRectangle, NUI_PROPERTY_W));
    float h = JsonGetFloat(JsonObjectGet(jRectangle, NUI_PROPERTY_H));

    return NUI_GetRectanglePoints(x, y, w, h);
}

json NUI_DefineCircle(float x, float y, float r)
{
    r = fclamp(r, 0.0, fmin(x, y));
    float s = 2 * r;

    json j = JsonObject();
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_X, JsonFloat(x - r));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_Y, JsonFloat(y - r));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_W, JsonFloat(s));
         j = NUI_SetObjectProperty(j, NUI_PROPERTY_H, JsonFloat(s));
    return j;
}

json NUI_GetTrianglePoints(float x, float y, float h, float b)
{
    json j= JsonArray();
    j = JsonArrayInsert(j, JsonFloat(x));
    j = JsonArrayInsert(j, JsonFloat(y));
    j = JsonArrayInsert(j, JsonFloat(x - (b / 2.0)));
    j = JsonArrayInsert(j, JsonFloat(y + h));
    j = JsonArrayInsert(j, JsonFloat(x + (b / 2.0)));
    j = JsonArrayInsert(j, JsonFloat(y + h));
    j = JsonArrayInsert(j, JsonFloat(x));
    j = JsonArrayInsert(j, JsonFloat(y));

    return j;
}

json NUI_DefineStringByStringRef(int nStringRef)
{
    return  JsonObjectSet(JsonObject(), NUI_PROPERTY_STRREF, JsonInt(nStringRef));
}

void NUI_CreateTemplateControl(string sID)
{
    if (NUI_GetBuildLayer() > 0)
        return;

    NUI_IncrementBuildLayer();
    NUI_SetBuildMode(NUI_ELEMENT_TEMPLATE);
    NUI_ResetRunningPath();

    SetLocalString(GetModule(), NUI_ELEMENT_TEMPLATE, sID);
}

void NUI_SaveTemplateControl()
{
    json j = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    string sID = GetLocalString(GetModule(), NUI_ELEMENT_TEMPLATE);

    DeleteLocalString(GetModule(), NUI_ELEMENT_TEMPLATE);
    SetLocalJson(GetModule(), NUI_ELEMENT_TEMPLATE + sID, j);

    NUI_DecrementBuildLayer();
}

void NUI_AddTemplateControl(string sID)
{
    NUI_CreateControl(NUI_ELEMENT_TEMPLATE, sID);
}

void NUI_AddColumn(float fWidth = -1.0)
{
    NUI_IncrementCellsAtDepth(NUI_GetLayoutOrientation() != NUI_ORIENTATION_COLUMNS, fWidth);
    NUI_ResetControlWrap();
}

void NUI_AddRow(float fHeight = -1.0)
{
    NUI_IncrementCellsAtDepth(NUI_GetLayoutOrientation() != NUI_ORIENTATION_ROWS, fHeight);
    NUI_ResetControlWrap();
}

void NUI_AddSpacer(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_SPACER, sID);
}

void NUI_AddLabel(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_LABEL, sID);
}

void NUI_AddTextbox(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_TEXTBOX, sID);
}

void NUI_AddCommandButton(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_COMMANDBUTTON, sID);
}

void NUI_AddImageButton(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_IMAGEBUTTON, sID);
}

void NUI_AddToggleButton(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_TOGGLEBUTTON, sID);
}

void NUI_AddCheckbox(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_CHECKBOX, sID);
}

void NUI_AddImage(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_IMAGE, sID);
}

void NUI_AddCombobox(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_COMBOBOX, sID);
}

void NUI_SetElements(json jElements)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ELEMENTS, jElements);
}

void NUI_BindElements(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ELEMENTS, NUI_BindVariable(sBind));
}

void NUI_AddComboboxEntryList(string sEntries, int nStart = -1)
{
    NUI_AddRunningPath(NUI_PROPERTY_ELEMENTS, FALSE);
    string sPath = NUI_GetRunningPath();
    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    json jElements = JsonPointer(jRoot, sPath);
    int nElements = NUI_GetLengthAtRunningPath(sPath);
    int n, nCount = CountList(sEntries);

    for (n = 0; n < nCount; n++)
    {
        string sEntry = GetListItem(sEntries, n);
        int nValue = nStart == -1 ? nElements + n : nStart;

        json jEntry = JsonArray();
             jEntry = JsonArrayInsert(jEntry, JsonString(sEntry));
             jEntry = JsonArrayInsert(jEntry, JsonInt(nValue));

        jElements = JsonArrayInsert(jElements, jEntry);
    }

    NUI_ApplyPatchToRoot(jElements, "replace");
    NUI_DropRunningPath(1);
}

void NUI_AddComboboxEntry(string sEntry, int nValue = -1)
{
    NUI_AddRunningPath(NUI_PROPERTY_ELEMENTS, FALSE);
    string sPath = NUI_GetRunningPath();

    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    json jElements = JsonPointer(jRoot, sPath);

    if (nValue < 0)
        nValue = NUI_GetLengthAtRunningPath(sPath);

    json jEntry = JsonArray();
         jEntry = JsonArrayInsert(jEntry, JsonString(sEntry));
         jEntry = JsonArrayInsert(jEntry, JsonInt(nValue));

    jElements = JsonArrayInsert(jElements, jEntry);

    NUI_ApplyPatchToRoot(jElements, "replace");
    NUI_DropRunningPath(1);
}

void NUI_AddFloatSlider(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_FLOATSLIDER, sID);
}

void NUI_AddIntSlider(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_INTSLIDER, sID);
}

void NUI_AddProgressBar(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_PROGRESSBAR, sID);
}

void NUI_AddListbox()
{
    NUI_CreateListbox();
}

void NUI_CloseListbox()
{
    NUI_DropBuildLayer();
}

void NUI_AddColorPicker(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_COLORPICKER, sID);
}

void NUI_AddOptionGroup(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_OPTIONGROUP, sID);
}

void NUI_AddRadioButton(string sButton)
{
    NUI_AddRunningPath(NUI_PROPERTY_ELEMENTS, FALSE);
    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    json jElements = JsonPointer(jRoot, NUI_GetRunningPath());

    jElements = JsonArrayInsert(jElements, JsonString(" " + sButton));

    NUI_ApplyPatchToRoot(jElements, "replace");
    NUI_DropRunningPath(1);
}

void NUI_AddRadioButtonList(string sButtons)
{
    NUI_AddRunningPath(NUI_PROPERTY_ELEMENTS, FALSE);
    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    json jElements = JsonPointer(jRoot, NUI_GetRunningPath());

    int n, nCount = CountList(sButtons);
    for (n = 0; n < nCount; n++)
    {
        string sButton = GetListItem(sButtons, n);
        json jButton = JsonString(" " + sButton);
        
        jElements = JsonArrayInsert(jElements, jButton);
    }

    NUI_ApplyPatchToRoot(jElements, "replace");
    NUI_DropRunningPath(1);
}

void NUI_AddControlGroup()
{
    NUI_CreateGroup();
}

void NUI_CloseControlGroup()
{
    NUI_DropBuildLayer();
}

void NUI_AddChart(string sID = "")
{
    NUI_CreateControl(NUI_ELEMENT_CHART, sID);
}

void NUI_AddChartSeries(int nType, string sLegend, json jColor, json jData)
{
    json j = JsonObject();
         j = JsonObjectSet(j, NUI_PROPERTY_TYPE, JsonInt(nType));
         j = JsonObjectSet(j, NUI_PROPERTY_LEGEND, JsonString(sLegend));
         j = JsonObjectSet(j, NUI_PROPERTY_COLOR, jColor);
         j = JsonObjectSet(j, NUI_PROPERTY_DATA, jData);

    NUI_AddRunningPath(NUI_PROPERTY_VALUE, FALSE);
    json jRoot = NUI_GetBuildVariable(NUI_BUILD_ROOT);
    json jSeries = JsonPointer(jRoot, NUI_GetRunningPath());
         jSeries = JsonArrayInsert(jSeries, j);

    NUI_ApplyPatchToRoot(jSeries, "replace");
    NUI_DropRunningPath(1);
}

void NUI_AddCanvas()
{
    if (NUI_GetBuildMode() == NUI_ELEMENT_GROUP && NUI_GetRunningPathIndex() == -1)
        NUI_ResetRunningPath(TRUE);

    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_DRAWLIST, JsonArray());
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_DRAWLISTSCISSOR, jFALSE);
    NUI_AddBuildLayer(NUI_ELEMENT_CANVAS);
}

void NUI_CloseCanvas()
{
    NUI_DropBuildLayer();
}

void NUI_DrawLine(json jPoints)
{
    json jCanvas = NUI_CreateCanvasTemplate();
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_POINTS, jPoints);
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_TYPE, JsonInt(NUI_CANVAS_POLYLINE));

    NUI_BuildCanvas(jCanvas);
}

void NUI_DrawRectangle(float x, float y, float w, float h)
{
    NUI_DrawLine(NUI_GetRectanglePoints(x, y, w, h));
}

void NUI_DrawDefinedRectangle(json jRect)
{
    NUI_DrawLine(NUI_GetDefinedRectanglePoints(jRect));
}

void NUI_DrawCircle(float x, float y, float r)
{
    json jRect = NUI_DefineCircle(x, y, r);

    json jCanvas = NUI_CreateCanvasTemplate();
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_RECT, jRect);
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_TYPE, JsonInt(NUI_CANVAS_CIRCLE));

    NUI_BuildCanvas(jCanvas);
}

void NUI_DrawDefinedCircle(json jCircle)
{
    json jCanvas = NUI_CreateCanvasTemplate();
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_RECT, jCircle);
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_TYPE, JsonInt(NUI_CANVAS_CIRCLE));

    NUI_BuildCanvas(jCanvas);
}

void NUI_DrawTriangle(float x, float y, float h, float b)
{
    NUI_DrawLine(NUI_GetTrianglePoints(x, y, h, b));
}

void NUI_DrawText(json jRect, string sText)
{
    json jCanvas = NUI_CreateCanvasTemplate();
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_RECT, jRect);
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_TEXT, JsonString(sText));
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_FILL, JsonNull());
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_TYPE, JsonInt(NUI_CANVAS_TEXT));

    NUI_BuildCanvas(jCanvas);
}

void NUI_DrawImage(string sResref, json jRect, int nAspect, int nHAlign, int nVAlign)
{
    json j = NUI_CreateCanvasTemplate();
         j = JsonObjectSet(j, NUI_PROPERTY_COLOR, JsonNull());
         j = JsonObjectSet(j, NUI_PROPERTY_FILL, JsonNull());
         j = JsonObjectSet(j, NUI_PROPERTY_LINETHICKNESS, JsonNull());
         j = JsonObjectSet(j, NUI_PROPERTY_IMAGE, JsonString(sResref));
         j = JsonObjectSet(j, NUI_PROPERTY_RECT, jRect);
         j = JsonObjectSet(j, NUI_PROPERTY_IMAGEASPECT, JsonInt(nAspect));
         j = JsonObjectSet(j, NUI_PROPERTY_IMAGEHALIGN, JsonInt(nHAlign));
         j = JsonObjectSet(j, NUI_PROPERTY_IMAGEVALIGN, JsonInt(nVAlign));
         j = JsonObjectSet(j, NUI_PROPERTY_TYPE, JsonInt(NUI_CANVAS_IMAGE));

    NUI_BuildCanvas(j);
}

void NUI_DrawCurve(json jA, json jB, json jCtrl0, json jCtrl1)
{
    json jCanvas = NUI_CreateCanvasTemplate();
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_A, jA);
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_B, jB);
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_CTRL0, jCtrl0);
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_CTRL1, jCtrl1);
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_FILL, jFALSE);
         jCanvas = JsonObjectSet(jCanvas, NUI_PROPERTY_TYPE, JsonInt(NUI_CANVAS_CURVE));

    NUI_BuildCanvas(jCanvas);
}

void NUI_DrawArc(json jC, float fRadius, float fAMin, float fAMax)
{
    json j = NUI_CreateCanvasTemplate();
         j = JsonObjectSet(j, NUI_PROPERTY_C, jC);
         j = JsonObjectSet(j, NUI_PROPERTY_RADIUS, JsonFloat(fRadius));
         j = JsonObjectSet(j, NUI_PROPERTY_AMIN, JsonFloat(fAMin));
         j = JsonObjectSet(j, NUI_PROPERTY_AMAX, JsonFloat(fAMax));
         j = JsonObjectSet(j, NUI_PROPERTY_TYPE, JsonInt(NUI_CANVAS_ARC));

    NUI_BuildCanvas(j);
}

void NUI_SetTitle(string sTitle)
{
    json j = JsonString(sTitle);
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TITLE, j);
}

void NUI_BindTitle(string sBind)
{
    json j = NUI_BindVariable(sBind);
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TITLE, j);
}

void NUI_SetGeometry(float x, float y, float w, float h)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_GEOMETRY, NUI_DefineRectangle(x, y, w, h));
}

void NUI_SetDefinedGeometry(json jGeometry)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_GEOMETRY, jGeometry);
}

void NUI_BindGeometry(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_GEOMETRY, NUI_BindVariable(sBind));
}

void NUI_SetResizable(int bResizable = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_RESIZABLE, JsonBool(bResizable));
}

void NUI_BindResizable(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_RESIZABLE, NUI_BindVariable(sBind));
}

void NUI_SetCollapsible(int bCollapsible = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_COLLAPSIBLE, JsonBool(bCollapsible));
}

void NUI_BindCollapsible(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_COLLAPSIBLE, NUI_BindVariable(sBind));
}

void NUI_SetModal(int bModal = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_MODAL, JsonBool(!bModal));
}

void NUI_BindModal(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_MODAL, NUI_BindVariable(sBind));
}

void NUI_SetTransparent(int bTransparent = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TRANSPARENT, JsonBool(bTransparent));
}

void NUI_BindTransparent(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TRANSPARENT, NUI_BindVariable(sBind));
}

void NUI_SetBorderVisible(int bVisible = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_BORDER, JsonBool(bVisible));
}

void NUI_BindBorderVisible(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_BORDER, NUI_BindVariable(sBind));
}

void NUI_SetVersion(int nVersion = 1)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VERSION, JsonInt(nVersion));
}

void NUI_SetOrientation(string sOrientation = NUI_ORIENTATION_ROWS)
{
    if (NUI_GetCurrentControlType() == NUI_ELEMENT_OPTIONGROUP)
    {
        int nOrientation = StringToInt(sOrientation);
        NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_DIRECTION, JsonInt(nOrientation));
        return;
    }

    if (NUI_GetCellStructureIsEmpty() == TRUE)
    {
        if (NUI_GetLayoutOrientation() == sOrientation)
            return;
        else
        {
            NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ORIENTATION, JsonString(sOrientation));

            string sPath, sLayout;
            if (NUI_GetBuildLayer() == 0)
                sPath = "/root/type";
            else if (NUI_GetBuildMode() == NUI_ELEMENT_GROUP)
                sPath = "/children/0/type";
            
            if (sOrientation == NUI_ORIENTATION_ROWS)
                sLayout = NUI_ELEMENT_COLUMN;
            else
                sLayout = NUI_ELEMENT_ROW;

            NUI_ApplyPatchToRoot(JsonString(sLayout), "add", sPath);
        }
    }
    else
        NUI_Debug("Attempted to set orientation after controls have been added; new orientation not set", NUI_DEBUG_SEVERITY_ERROR);
}

void NUI_SetWidth(float fWidth)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_WIDTH, JsonFloat(fWidth));
}

void NUI_SetHeight(float fHeight)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_HEIGHT, JsonFloat(fHeight));
}

void NUI_SetSquare(float fSide)
{
    NUI_SetHeight(fSide);
    NUI_SetWidth(fSide);
}

void NUI_SetDimensions(float fWidth, float fHeight)
{
    NUI_SetWidth(fWidth);
    NUI_SetHeight(fHeight);
}

void NUI_SetAspectRatio(float fRatio)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ASPECT, JsonFloat(fRatio));
}

void NUI_SetImageAspect(int nAspect)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_IMAGEASPECT, JsonInt(nAspect));
}

void NUI_SetImageHorizontalAlignment(int nHAlign)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_IMAGEHALIGN, JsonInt(nHAlign));
}

void NUI_SetImageVerticalAlignment(int nVAlign)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_IMAGEVALIGN, JsonInt(nVAlign));
}

void NUI_SetMargin(float fMargin)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_MARGIN, JsonFloat(fMargin));
}

void NUI_SetPadding(float fPadding)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_PADDING, JsonFloat(fPadding));
}

void NUI_SetID(string sID)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ID, JsonString(sID));
}

void NUI_SetLabel(string sLabel)
{
    string sType = NUI_GetCurrentControlType();

    if (sType == NUI_ELEMENT_LABEL || sType == NUI_ELEMENT_TEXTBOX_STATIC)
        NUI_SetValue(JsonString(sLabel));
    else
        NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_LABEL, JsonString(sLabel));
}

void NUI_BindLabel(string sBind)
{
    string sType = NUI_GetCurrentControlType();

    if (sType == NUI_ELEMENT_LABEL || sType == NUI_ELEMENT_TEXTBOX_STATIC)
        NUI_BindValue(sBind);
    else
        NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_LABEL, NUI_BindVariable(sBind));
}

void NUI_SetEnabled(int bEnabled = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ENABLED, JsonBool(bEnabled));
}

void NUI_BindEnabled(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ENABLED, NUI_BindVariable(sBind));
}

void NUI_SetVisible(int bVisible = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VISIBLE, JsonBool(bVisible));
}

void NUI_BindVisible(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VISIBLE, NUI_BindVariable(sBind));
}

void NUI_SetTooltip(string sTooltip, int bDisabledTooltip = FALSE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TOOLTIP, JsonString(sTooltip));
    if (bDisabledTooltip == TRUE)
        NUI_SetDisabledTooltip(sTooltip);
}

void NUI_BindTooltip(string sBind, int bDisabledTooltip = FALSE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TOOLTIP, NUI_BindVariable(sBind));
    if (bDisabledTooltip == TRUE)
        NUI_BindDisabledTooltip(sBind);
}

void NUI_SetRGBForegroundColor(int r, int g, int b, int a = 255)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_FORECOLOR, NUI_DefineRGBColor(r, g, b, a));
}

void NUI_SetDefinedForegroundColor(json jColor)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_FORECOLOR, jColor);
}

void NUI_BindForegroundColor(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_FORECOLOR, NUI_BindVariable(sBind));
}

void NUI_SetDisabledTooltip(string sTooltip)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_DISABLED_TOOLTIP, JsonString(sTooltip));
}

void NUI_BindDisabledTooltip(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TOOLTIP, NUI_BindVariable(sBind));
}

void NUI_SetEncouraged(int bEncouraged = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ENCOURAGED, JsonBool(bEncouraged));
}

void NUI_BindEncouraged(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ENCOURAGED, NUI_BindVariable(sBind));
}

/*
// TODO Are these two necessary?  Maybe delete and use NUI_SetDrawColor instead?
void NUI_SetDefinedColor(json jColor)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_COLOR, jColor);
}
*/

// TODO why do these set the value property instead of the color proeprty?  I'm sure I did this
// for a reason, but don't see it in the NUI definitions.  Check and remove?
void NUI_SetDefinedColor(json jColor)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALUE, jColor);
}

void NUI_SetRGBColor(int r, int g, int b, int a = 255)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALUE, NUI_DefineRGBColor(r, g, b, a));
}

void NUI_BindColor(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALUE, NUI_BindVariable(sBind));
}

void NUI_SetHorizontalAlignment(int nAlignment)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_HALIGN, JsonInt(nAlignment));
}

void NUI_BindHorizontalAlignment(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_HALIGN, NUI_BindVariable(sBind));
}

void NUI_SetVerticalAlignment(int nAlignment)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALIGN, JsonInt(nAlignment));
}

void NUI_BindVerticalAlignment(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALIGN, NUI_BindVariable(sBind));
}

void NUI_SetResref(string sResref)
{
    // TODO Need special handling
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALUE, JsonString(sResref));
}

void NUI_BindResref(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALUE, NUI_BindVariable(sBind));
}

void NUI_SetStatic(int bStatic = TRUE)
{
    if (NUI_GetBuildMode() == NUI_ELEMENT_LISTBOX)
        NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_STATIC, JsonBool(bStatic));
    else
        NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TYPE, JsonString(NUI_ELEMENT_TEXTBOX_STATIC));
}

void NUI_SetPlaceholder(string sPlaceholder = "")
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_LABEL, JsonString(sPlaceholder));
}

void NUI_BindPlaceholder(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_LABEL, NUI_BindVariable(sBind));
}

void NUI_SetMaxLength(int nLength = 50)
{
    nLength = clamp(nLength, 1, 65535); // from niv's notes
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_MAX, JsonInt(nLength));
}

void NUI_SetMultiline(int bMultiline = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_MULTILINE, JsonBool(bMultiline));
}

void NUI_SetRowCount(int nRowCount)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ROWCOUNT, JsonInt(nRowCount));
}

void NUI_BindRowCount(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ROWCOUNT, NUI_BindVariable(sBind));
}

void NUI_SetRowHeight(float fRowHeight)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ROWHEIGHT, JsonFloat(fRowHeight));
}

void NUI_BindRowHeight(string sBind)
{ 
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_ROWHEIGHT, NUI_BindVariable(sBind));
}

void NUI_SetChecked(int bChecked = TRUE)
{
    NUI_SetValue(JsonBool(bChecked));
}

void NUI_BindChecked(string sBind)
{
    NUI_SetValue(NUI_BindVariable(sBind));
}

void NUI_SetDrawColor(json jColor)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_COLOR, jColor);
}

void NUI_BindDrawColor(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_COLOR, NUI_BindVariable(sBind));
}

void NUI_SetScissor(int bScissor)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_DRAWLISTSCISSOR, JsonBool(bScissor));
}

void NUI_SetLineThickness(float fThickness)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_LINETHICKNESS, JsonFloat(fThickness));
}

void NUI_BindLineThickness(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_LINETHICKNESS, NUI_BindVariable(sBind));
}

void NUI_SetPosition(int nPosition = NUI_POSITION_ABOVE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_POSITION, JsonInt(nPosition));
}

void NUI_SetCondition(int nCondition = NUI_CONDITION_ALWAYS)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_CONDITION, JsonInt(nCondition));
}

void NUI_SetFill(int bFill = TRUE)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_FILL, JsonBool(bFill));
}

void NUI_BindFill(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_FILL, NUI_BindVariable(sBind));
}

void NUI_SetCenter(float x, float y)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_C, NUI_DefinePoint(x, y));
}

void NUI_SetDefinedCenter(json jCenter)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_C, jCenter);
}

void NUI_BindCenter(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_C, NUI_BindVariable(sBind));
}

void NUI_SetRadius(float r)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_RADIUS, JsonFloat(r));
}

void NUI_BindRadius(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_RADIUS, NUI_BindVariable(sBind));
}

void NUI_SetAMin(float fMultiplier)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_AMIN, JsonFloat(PI * fMultiplier));
}

void NUI_BindAMin(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_AMIN, NUI_BindVariable(sBind));
}

void NUI_SetAMax(float fMultiplier)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_AMAX, JsonFloat(PI * fMultiplier));
}

void NUI_BindAMax(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_AMAX, NUI_BindVariable(sBind));
}

void NUI_SetText(string sText)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TEXT, JsonString(sText));
}

void NUI_BindText(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_TEXT, NUI_BindVariable(sBind));
}

void NUI_SetPoints(json jPoints)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_POINTS, jPoints);
}

void NUI_BindPoints(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_POINTS, NUI_BindVariable(sBind));
}

void NUI_SetIntSliderBounds(int nLower, int nUpper, int nStep)
{
    json jLower = JsonInt(nLower);
    json jUpper = JsonInt(nUpper);
    json jStep = JsonInt(nStep);

    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_MIN, jLower);
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_MAX, jUpper);
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_STEP, jStep);
}

void NUI_SetFloatSliderBounds(float fLower, float fUpper, float fStep)
{
    json jLower = JsonFloat(fLower);
    json jUpper = JsonFloat(fUpper);
    json jStep = JsonFloat(fStep);

    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_MIN, jLower);
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_MAX, jUpper);
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_STEP, jStep);
}

void NUI_SetProgress(float fValue)
{   
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALUE, JsonFloat(fValue));
}

void NUI_BindProgress(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALUE, NUI_BindVariable(sBind));
}

void NUI_SetValue(json jValue)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALUE, jValue);
}

void NUI_BindValue(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_VALUE, NUI_BindVariable(sBind));
}

void NUI_SetImage(string sResref)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_IMAGE, JsonString(sResref));
}

void NUI_BindImage(string sBind)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_IMAGE, NUI_BindVariable(sBind));
}

void NUI_SetRectangle(json jRect)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_RECT, jRect);
}

void NUI_SetScrollbars(int nScrollbars = NUI_SCROLLBARS_AUTO)
{
    NUI_SetCurrentControlObjectProperty(NUI_PROPERTY_SCROLLBARS, JsonInt(nScrollbars));
}

void NUI_SetCustomProperty(string sProperty, json jValue)
{
    NUI_SetCustomControlProperty(NUI_PROPERTY_USERDATA, sProperty, jValue);
}

json NUI_GetCustomProperty(json jUserData, string sProperty)
{
    return JsonObjectGet(jUserData, sProperty);
}

int NUI_CountCustomProperties(json jUserData)
{
    return JsonGetLength(jUserData);
}

json NUI_GetCustomPropertyByIndex(json jUserData, int nIndex)
{
    json jKeys = JsonObjectKeys(jUserData);
    string sProperty = JsonGetString(JsonArrayGet(jKeys, nIndex));

    return NUI_GetCustomProperty(jUserData, sProperty);
}

void NUI_SetBindScript(string sScript)
{
    NUI_SetHandler(NUI_PROPERTY_BINDDATA, "script", sScript);
}

void NUI_SetBuildScript(string sScript)
{
    NUI_SetHandler(NUI_PROPERTY_BUILDDATA, "script", sScript);
}

void NUI_SetEventScript(string sScript)
{
    NUI_SetHandler(NUI_PROPERTY_EVENTDATA, "script", sScript);
}

void NUI_SetBindFunction(string sFunction)
{
    NUI_SetHandler(NUI_PROPERTY_BINDDATA, "function", sFunction);
}

void NUI_SetEventFunction(string sFunction)
{
    NUI_SetHandler(NUI_PROPERTY_EVENTDATA, "function", sFunction);
}

void NUI_SetBuildFunction(string sFunction)
{
    NUI_SetHandler(NUI_PROPERTY_BUILDDATA, "function", sFunction);
}

void NUI_SetFormScript(string sScript)
{
    NUI_SetBuildScript(sScript);
    NUI_SetBindScript(sScript);
    NUI_SetEventScript(sScript);
}

void NUI_SetFormFunction(string sFunction)
{
    NUI_SetBuildFunction(sFunction);
    NUI_SetBindFunction(sFunction);
    NUI_SetEventFunction(sFunction);
}

void NUI_SetBindValue(object oPC, int nToken, string sBind, json jValue)
{
    NuiSetBind(oPC, nToken, sBind, jValue);
}

void NUI_DelayBindValue(object oPC, int nToken, string sBind, json jValue)
{
    DelayCommand(0.001, NUI_SetBindValue(oPC, nToken, sBind, jValue));
}

void NUI_SetBindWatch(object oPC, int nToken, string sBind, int bWatch = TRUE)
{
    NuiSetBindWatch(oPC, nToken, sBind, bWatch);
}

json NUI_GetBindValue(object oPC, int nToken, string sBind)
{
    return NuiGetBind(oPC, nToken, sBind);
}


void NUI_SetBindData(object oPC, int nToken, string sFormID, json jBinds)
{
    json j = JsonObject();
    j = JsonObjectSet(j, NUI_BIND_FORM, JsonString(sFormID));
    j = JsonObjectSet(j, NUI_BIND_TOKEN, JsonInt(nToken));
    j = JsonObjectSet(j, NUI_BIND_BINDS, jBinds);
    j = JsonObjectSet(j, NUI_BIND_COUNT, JsonInt(JsonGetLength(jBinds)));
    
    SetLocalJson(oPC, NUI_BIND_DATA, j);
}

struct NUIBindData NUI_GetBindData()
{
    object oPC = OBJECT_SELF;
    struct NUIBindData bd;

    if (NUI_GetCurrentOperation() != NUI_OPERATION_BIND)
        return bd;

    json j = GetLocalJson(oPC, NUI_BIND_DATA);

    bd.sFormID = JsonGetString(JsonObjectGet(j, NUI_BIND_FORM));
    bd.nToken = JsonGetInt(JsonObjectGet(j, NUI_BIND_TOKEN));
    bd.jBinds = JsonObjectGet(j, NUI_BIND_BINDS);
    bd.nCount = JsonGetInt(JsonObjectGet(j, NUI_BIND_COUNT));
    
    return bd;    
}

struct NUIBindArrayData NUI_GetBindArrayData(json jBinds, int n)
{
    struct NUIBindArrayData bad;
    json j = JsonArrayGet(jBinds, n);

    bad.sType = JsonGetString(JsonObjectGet(j, NUI_BIND_TYPE));
    bad.sProperty = JsonGetString(JsonObjectGet(j, NUI_BIND_PROPERTY));
    bad.sBind = JsonGetString(JsonObjectGet(j, NUI_BIND_VARIABLE));
    bad.jUserData = JsonObjectGet(j, NUI_BIND_USERDATA);

    return bad;
}

json NUI_CreateEventArrayData(string sFormID, string sControlID, int bIncludeChildren)
{
    return JsonNull();
}

struct NUIEventData NUI_GetEventData(int bIncludeChildren = TRUE)
{
    struct NUIEventData ed;

    ed.oPC = NuiGetEventPlayer();
    ed.nFormToken = NuiGetEventWindow();
    ed.sFormID = NuiGetWindowId(ed.oPC, ed.nFormToken);
    ed.sEvent = NuiGetEventType();
    ed.sControlID = NuiGetEventElement();
    ed.nIndex = NuiGetEventArrayIndex();
    ed.jBinds = NUI_CreateEventArrayData(ed.sFormID, ed.sControlID, bIncludeChildren);
    ed.jPayload = NuiGetEventPayload();
    ed.jUserData = NUI_GetUserData(ed.sFormID, ed.sControlID);

    return ed;
}

struct NUIEventArrayData NUI_GetEventArrayData(json jBinds, int n)
{
    struct NUIEventArrayData ead;
    json j = JsonArrayGet(jBinds, n);

    ead.sControlID = JsonGetString(JsonObjectGet(j, NUI_BIND_CONTROLID));
    ead.sProperty = JsonGetString(JsonObjectGet(j, NUI_BIND_PROPERTY));
    ead.sBind = JsonGetString(JsonObjectGet(j, NUI_BIND_VARIABLE));
    ead.jValue = JsonObjectGet(j, NUI_BIND_VALUE);

    return ead;
}

// All below is experimental for custom control implementation.  DO NOT USE
// ANY FUNCTION BELOW THIS WARNING XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

void NUI_AbortFileFunction(string sMessage)
{
    SetLocalInt(GetModule(), "FILE_FUNCTION_ABORTED", TRUE);
    NUI_Debug(sMessage, NUI_DEBUG_SEVERITY_NOTICE);
}

void NUI_ClearFileFunctionAborted()
{
    DeleteLocalInt(GetModule(), "FILE_FUdNCTION_ABORTED");
}

int NUI_GetFileFunctionAborted()
{
    int nAbort = GetLocalInt(GetModule(), "FILE_FUNCTION_ABORTED");
    NUI_ClearFileFunctionAborted();
    return nAbort;
}

void NUI_AddSeries(object oPC, string sFormID, string sControlID, json jData)
{
    SetLocalJson(oPC, "SERIESDATA#" + sFormID + "#" + sControlID, jData);

    json jUserData = NUI_GetUserData(sFormID, sControlID);
    if (JsonObjectGet(jUserData, "custom_control") == JsonBool(TRUE))
    {
        string sArguments = "\"" + sFormID + "\", \"" + sControlID + "\"";

        json jBuildData = NUI_GetBuildData(sFormID, sControlID);
        string sType = JsonGetString(JsonObjectGet(jBuildData, "type"));
        NUI_ExecuteFileFunction(NUI_GetControlfile(sType), NUI_CONTROLFILE_ADDSERIES_FUNCTION, oPC, sArguments);

        if (NUI_GetFileFunctionAborted())
            return;
    }

    NUI_ExecuteFileFunction(NUI_GetFormfile(sFormID), NUI_FORMFILE_BUILDS_FUNCTION, oPC);
}

void NUI_DropSeries(object oPC, string sFormID, string sControlID, string sTag)
{

}

void NUI_DefineCustomControlsByFile()
{
    json jControlFiles = NUI_GetResrefArray(NUI_CONTROLFILE_PREFIX);
    if (jControlFiles == JsonNull())
        return;

    NUI_SetCurrentOperation(NUI_OPERATION_DEFINE);

    int n, nCount = JsonGetLength(jControlFiles);
    for (n = 0; n < nCount; n++)
    {
        string sControlfile = JsonGetString(JsonArrayGet(jControlFiles, n));
        SetLocalString(GetModule(), NUI_CURRENT_CONTROLFILE, sControlfile);
        NUI_ExecuteFileFunction(sControlfile, NUI_CONTROLFILE_REGISTRATION_FUNCTION);
    }

    NUI_ClearCurrentOperation();
}

void NUI_AddCustomControl(string sControl, string sID)
{
    string sArguments = "\"" + sID + "\"";
    NUI_ExecuteFileFunction(NUI_GetControlfile(sControl), NUI_CONTROLFILE_INSERTION_FUNCTION, OBJECT_SELF, sArguments);
}
