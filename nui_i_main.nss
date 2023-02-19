/// ----------------------------------------------------------------------------
/// @file   nui_i_main.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  NUI Form Creation and Management System
/// ----------------------------------------------------------------------------

#include "util_i_csvlists"
#include "util_i_color"
#include "nui_c_config"

// -----------------------------------------------------------------------------
//                                    Constants
// -----------------------------------------------------------------------------

const string NUI_VERSION = "0.2.0";
const string NUI_DATABASE = "nui_form_data";

const int NUI_ORIENTATION_ROW    = 0;
const int NUI_ORIENTATION_COLUMN = 1;

const int NUI_DRAW_ABOVE         = 1;
const int NUI_DRAW_BELOW         = -1;

const int NUI_DRAW_ALWAYS        = 0;
const int NUI_DRAW_MOUSEOFF      = 1;
const int NUI_DRAW_MOUSEHOVER    = 2;
const int NUI_DRAW_MOUSELEFT     = 3;
const int NUI_DRAW_MOUSERIGHT    = 4;
const int NUI_DRAW_MOUSEMIDDLE   = 5;

const int NUI_SCROLLBARS_NONE    = 0;
const int NUI_SCROLLBARS_X       = 1;
const int NUI_SCROLLBARS_Y       = 2;
const int NUI_SCROLLBARS_BOTH    = 3;
const int NUI_SCROLLBARS_AUTO    = 4;

const int NUI_CHART_LINE         = 0;
const int NUI_CHART_BAR          = 1;

const int NUI_ASPECT_FIT         = 0;
const int NUI_ASPECT_FILL        = 1;
const int NUI_ASPECT_FIT100      = 2;
const int NUI_ASPECT_EXACT       = 3;
const int NUI_ASPECT_EXACTSCALED = 4;
const int NUI_ASPECT_STRETCH     = 5;

const int NUI_HALIGN_CENTER      = 0;
const int NUI_HALIGN_LEFT        = 1;
const int NUI_HALIGN_RIGHT       = 2;

const int NUI_VALIGN_MIDDLE      = 0;
const int NUI_VALIGN_TOP         = 1;
const int NUI_VALIGN_BOTTOM      = 2;

const string NUI_DEFINE    = "DefineForm";
const string NUI_BIND      = "BindForm";
const string NUI_EVENT_NUI = "HandleNUIEvents";
const string NUI_EVENT_MOD = "HandleModuleEvents";

const string NUI_OBJECT    = "NUI_OBJECT";

json jTrue = JsonBool(TRUE);
json jFalse = JsonBool(FALSE);

// TODO remove upon debug completion
const int NUI_USE_CAMPAIGN_DATABASE = FALSE;
const string NUI_FORMFILE_PREFIX = "nui_f_";

struct NUIEventData {
    object oPC;           // PC object interacting with the form
    int    nToken;        // Subject form token
    string sFormID;       // Form ID as assigned during the form definition process
    string sEvent;        // Event - mouseup, click, etc.
    string sControlID;    // Control ID as assigned during the form definition process
    int    nIndex;        // Index of control in array, if the control is in an array (listbox)
    json   jPayload;      // Event payload, if it exists
};

// -----------------------------------------------------------------------------
//                              NUI/JSON Helpers
// -----------------------------------------------------------------------------

/// @brief Formats a json-parseable string.
/// @param s String value.
string nuiString(string s);

/// @brief Formats a json-parseable integer.
/// @param n Integer value.
string nuiInt(int n);

/// @brief Formats a json-parseable float.
/// @param f Float value.
string nuiFloat(float f);

/// @brief Formats a json-parseable boolean.
/// @param b Boolean value.
string nuiBool(int b);

/// @brief Creates a json-parseable object for a data bind.
/// @param sBind Bind variable.
string nuiBind(string sBind);

/// @brief Creates a json-parseable object for referencing strings by StringRef.
/// @param nStrRef StringRef value.
string nuiStrRef(int nStrRef);

/// @brief Creates a json-parseable object for a null value.
string nuiNull();

// -----------------------------------------------------------------------------
//     Form Definition, Controls, Custom JSON Structures, Drawing Elements
// -----------------------------------------------------------------------------

/// @brief Must be called during the module load process.  Initializes the
///     required nui database tables and loads all available formfiles.
void NUI_Initialize();

/// @brief Creates a form template with all required form properties set to
///     default values:
///         accepts_input:  true
///         border:         true
///         closable:       true
///         collapsible:    true
///         geometry:       bind:"geometry"
///         resizable:      true
///         title:          bind:"title"
///         transparent:    false
/// @param sID FormID.
/// @param sVersion A local version set into the form's json structure as
///     "local_version".  This is different than the nui system's required
///     version, which should never be changed.
void NUI_CreateForm(string sID, string sVersion = "");

/// @brief Define a subform.
/// @param sID Subform ID.
/// @warning Must be used only during the form definition process and after
///     definition of the main form.
void NUI_CreateSubform(string sID);

/// @brief Define a point based on a single coordinate set.
/// @param x X-coordinate.
/// @param y Y-coordinate.
/// @returns A json-parseable string representing a single coordinate set.
///     {"x":x.x, "y":y.y}
string NUI_DefinePoint(float x, float y);

/// @brief Get an array of line endpoint coordinates.
/// @param x1 Start point x-coordinate.
/// @param y1 Start point y-coordinate.
/// @param x2 End point x-coordinate.
/// @param y2 End point y-coordinate.
/// @returns A json-parseable string representing an array of coordinates
///     that can be used in NUI_DrawLine().
///     [x1, y1, x2, y2]
string NUI_GetLinePoints(float x1, float y1, float x2, float y2);

/// @brief Add a single coordinate set to an empty or existing coordinate array.
/// @param sPoints Coordinate array.  Can be a pre-existing arry as created by
///     NUI_GetLinePoints, an empty array string ("[]"), or an empty string ("").
/// @param x X-coordinate.
/// @param y Y-coordinate.
/// @returns A json-parseable string representing an array of coordinates
///     that can be used in NUI_DrawLine().
///     [..., x, y]
string NUI_AddLinePoint(string sPoints, float x, float y);

/// @brief Define an nui-usable color vector via rgba values.
/// @param r Red value.
/// @param g Green value.
/// @param b Blue value.
/// @param a Transparency value.
/// @returns A json-parseable string representing a color.
///     {"r":r, "g":g, "b":b, "a":a}
string NUI_DefineRGBColor(int r, int g, int b, int a = 255);

/// @brief Define an nui-usable color vector via hsv values.
/// @param h Hue.
/// @param s Saturation.
/// @param v Value.
/// @returns A json-parseable string representing a color.
///     {"r":r, "g":g, "b":b, "a":a}
string NUI_DefineHSVColor(float h, float s, float v);

/// @brief Define an nui-usable color vector via hex value.
/// @param nColor Hex color.
/// @returns A json-parseable string representing a color.
///     {"r":r, "g":g, "b":b, "a":a}
string NUI_DefineHexColor(int nColor);

/// @brief Define a random nui-usable color vector.
/// @returns A json-parseable string representing a color.
///     {"r":r, "g":g, "b":b, "a":a}
string NUI_DefineRandomColor();

/// @brief Define a rectangle based on coordinates and dimensions.
/// @param x X-coordinate, top left corner.
/// @param y Y-coordinate, top left corner.
/// @param w Width.
/// @param h Height.
/// @returns A json-parseable string representing a rectangular region.
///     {"x":x, "y":y, "w":w, "h":h}
string NUI_DefineRectangle(float x, float y, float w, float h);

/// @brief Get an array of rectangle corner coordinates.
/// @param x X-coordinate, top left corner.
/// @param y Y-coordinate, top left corner.
/// @param w Width.
/// @param h Height.
/// @returns A json-parseable string representing an array of coordinates
///     that can be used in NUI_DrawLine.
///     [x, y, x+w, y, x+w, y+h, x, y+h, x, y]
string NUI_GetRectanglePoints(float x, float y, float w, float h);

/// @brief Get an array of rectangle corner coordinates.
/// @param sRectangle A json-parseable string representing a rectangular
///     region as returned by NUI_DefineRectangle().
/// @returns A json-parseable string representing an array of coordinates
///     that can be used in NUI_DrawLine.
///     [x, y, x+w, y, x+w, y+h, x, y+h, x, y]
string NUI_GetDefinedRectanglePoints(string sRectangle);

/// @brief Define a circle based on coordinates and radius.
/// @param x X-coordinate, center point.
/// @param y Y-coordinate, center point.
/// @param r Radius.
/// @returns A json-parseable string representing a rectangular region
///     that can be used in NUI_DrawDefinedCircle().
string NUI_DefineCircle(float x, float y, float r);

/// @brief Add a column to the form or control group.
/// @param fWidth Column width.  If omitted, width will calculated automatically.
/// @note Definition must be closed with NUI_CloseColumn().
void NUI_AddColumn(float fWidth = -1.0);

/// @brief Close a column definition.
void NUI_CloseColumn();

/// @brief Add a row to the form or control group.
/// @param fWidth Row height.  If omitted, height will calculated automatically.
/// @note Definition must be closed with NUI_CloseRow().
void NUI_AddRow(float fHeight = -1.0);

/// @brief Close a row definition.
void NUI_CloseRow();

/// @brief Add a control group to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
/// @note Control group can contain other controls and can act as a layout element
///     for tab controls or as a form's subregion, containing its own columns and rows
///     of elements.  Definition must be closed with NUI_CloseGroup().
void NUI_AddGroup(string sID = "");

/// @brief Close a control group definition.
void NUI_CloseGroup();

/// @brief Add a chart to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddChart(string sID = "");

/// @brief Add a checkbox to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddCheckbox(string sID = "");

/// @brief Add a color picker to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddColorPicker(string sID = "");

/// @brief Add a combobox to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddCombobox(string sID = "");

/// @brief Add a command button to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddCommandButton(string sID = "");

/// @brief Add a float-based slider to the form or control group
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddFloatSlider(string sID = "");

/// @brief Add an image to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddImage(string sID = "");

/// @brief Add an image button to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddImageButton(string sID = "");

/// @brief Add an int-based slider to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddIntSlider(string sID = "");

/// @brief Add a label to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddLabel(string sID = "");

/// @brief Add a listbox to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
/// @note Each control added to the listbox row template can have individual
///     properties set.  Additionally, template element properties can be set
///     with NUI_SetTemplateVariable() and NUI_SetTemplateWidth().  Definition
///     must be closed with NUI_CloseListbox().
void NUI_AddListbox(string sID = "");

/// @brief Close a listbox definition.
void NUI_CloseListbox();

/// @brief Add an option group to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
/// @note Radio buttons may be added with NUI_SetElements().  Option group 
///     values are 0-based, starting with the first radio button added.
void NUI_AddOptionGroup(string sID = "");

/// @brief Add a progress bar to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddProgressBar(string sID = "");

/// @brief Add a spacer to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
void NUI_AddSpacer(string sID = "");

/// @brief Add an editable textbox to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
/// @note To force the textbox to be non-editable, use NUI_SetStatic();
void NUI_AddTextbox(string sID = "");

/// @brief Add a toggle button to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
/// @note Toggle buttons may be added with NUI_AddElement() or 
///     NUI_AddElement().  Option group values are 0-based, starting with
///     the first radio button added.
void NUI_AddToggleButton(string sID = "");

/// @brief Add an toggle (option) button group to the form or control group.
/// @param sID Control id.  Returned by NuiGetEventElement() (nwscript) or as
///     ed.sControlID in event data.
/// @note Toggle buttons may be added with NUI_SetElements().  Option group 
///     values are 0-based, starting with the first toggle button added.
void NUI_AddToggleGroup(string sID = "");

/// @brief Add a canvas to a control or control group.
/// @note Any number of drawlist elements may be added to a single canvas.
///     Drawlist elements can be added to any control or control group, but
///     cannot be added to the base form.  Definitions must be closed with
///     NUI_CloseCanvas().
void NUI_AddCanvas();

/// @brief Close a canvas definition.
void NUI_CloseCanvas();

/// @brief Draw a line or polyline on the canvas.
/// @param sPoints Json-parseable points array as defined by NUI_GetLinePoints(),
///     NUI_AddLinePoint(), or NUI_GetRectanglePoints().
/// @note Line point coordinates are relative to the top-left corner of the control
///     the drawlist element is being added to.
void NUI_DrawLine(string sPoints);

/// @brief Draw a rectangle on the canvas.
/// @param x X-coordinate, top left corner.
/// @param y Y-coordinate, top left corner.
/// @param w Width.
/// @param h Height.
/// @note X and Y coordinates are relative to the top-left corner of the control
///     the drawlist element is being added to.
void NUI_DrawRectangle(float x, float y, float w, float h);

/// @brief Draw a rectangle on the canvas.
/// @param sRect Json-parseable string representing a rectangular region as defined
///     by NUI_DefineRectangle().
/// @note X and Y coordinates are relative to the top-left corner of the control
///     the drawlist element is being added to.
void NUI_DrawDefinedRectangle(string sRect);

/// @brief Draw a circle on the canvas.
/// @param x X-coordinate, center point.
/// @param y Y-coordinate, center point.
/// @param r Radius.
/// @note X and Y coordinates are relative to the top-left corner of the control
///     the drawlist element is being added to.
void NUI_DrawCircle(float x, float y, float r);

/// @brief Draw a circle on the canvas.
/// @param sCircle Json-parseable string representing a rectangular region as defined
///     by NUI_DefineCircle().
/// @note X and Y coordinates are relative to the top-left corner of the control
///     the drawlist element is being added to.
void NUI_DrawDefinedCircle(string sCircle);

/// @brief Draw a textbox on the canvas.
/// @param sRect Json-parseable string representing a rectanglur region as defined
///     by NUI_DefineRectangle().
/// @param sText Text to be displayed in the drawn textbox.
/// @note X and Y coordinates are relative to the top-left corner of the control
///     the drawlist element is being added to.
void NUI_DrawText(string sRect, string sText);

/// @brief Draw an image on the canvas.
/// @param sResref Resref of the image to be displayed.
/// @param sRect Json-parseable string representing a rectanglur region as defined
///     by NUI_DefineRectangle().
/// @param nAspect Aspect ratio.
/// @param nHAlign Horizontal Alignment.
/// @param nValign Vertical Alignment.
void NUI_DrawImage(string sResref, string sRect, int nAspect, int nHAlign, int nVAlign);

/// @brief Draw an arc on the canvas.
/// @param sCenter Json-parseable string representing the center of the arc as defined by
///     NUI_DefinePoint().
/// @param r Radius.
/// @param fAMin Start angle.
/// @param fAMax End angle.
/// @note fAMin and fAMax are measured in fractions of PI radians from the start radian of
///     (0 * PI) which is visually represented as 090 degrees.  A complete circle is 2 * PI.
///     To draw a 90 degree arc from 180 degrees to 270 degrees, use 
///     NUI_DrawArc([sCenter], [r], 0.5 * PI, PI);.  The radius arms will also be drawn.
/// @note To achieve any given angle with 0 degrees as straight up, use
///     fAMin = (-0.5 * PI) + (<angle> / 180.0) * PI;
void NUI_DrawArc(string sCenter, float r, float fAMin, float fAMax);

/// @brief Draw a bezier curve on the canvas.
/// @param sStart Json-parseable string representing the curve's start point.
/// @param sEnd Json-parseable string representing the curve's end point.
/// @param sCtrl0 Json-parseable string representing the curve's first control point.
/// @param sCtrl1 Json-parseable string representing the curve's second control point.
/// @note All arguments for this function can be defined by NUI_DefinePoint().
/// @note More information about bezier curves:  https://en.wikipedia.org/wiki/B%C3%A9zier_curve
void NUI_DrawCurve(string sStart, string sEnd, string sCtrl0, string sCtrl1);

/// @brief Binds the drawlist element's points property.
/// @param sBind Variable to bind.
void NUI_BindLine(string sBind);

/// @brief Binds the drawlist element's rectangle property.
/// @param sBind Variable to bind.
void NUI_BindCircle(string sBind);

/// @brief Binds the drawlist element's text and rectangle properties.
/// @param sRectangle Variable to bind.
/// @param sText Variable to bind.
void NUI_BindTextbox(string sRectangle, string sText);

/// @brief Binds the drawlist element's rectangle, resref (image), aspect and alignment properties.
/// @param sResref Variable to bind.
/// @param sRectangle Variable to bind.
/// @param sAspect Variable to bind.
/// @param sHAlign Variable to bind.
/// @param sVAlign Variable to bind.
void NUI_BindImage(string sResref, string sRectangle, string sAspect, string sHAlign, string sVAlign);

/// @brief Binds the drawlist element's center, radius, start angle and end angle properties.
/// @param sCenter Variable to bind.
/// @param sRadius Variable to bind.
/// @param sStartAngle Variable to bind.
/// @param sEndAngle Variable to bind.
void NUI_BindArc(string sCenter, string sRadius, string sStartAngle, string sEndAngle);

/// @brief Binds the drawlist element's start, end, and control point properties.
/// @param sStart Variable to bind.
/// @param sEnd Variable to bind.
/// @param sCtrl0 Variable to bind.
/// @param sCtrl1 Variable to bind.
void NUI_BindCurve(string sStart, string sEnd, string sCtrl0, string sCtrl1);

/// @brief Binds the form's accepts input property.
/// @param sBind Variable to bind.
void NUI_BindAcceptsInput(string sBind);

/// @brief Binds the control's aspect property.
/// @param sBind Variable to bind.
void NUI_BindAspect(string sBind);

/// @brief Binds the form's or control's border property.
/// @param sBind Variable to bind.
void NUI_BindBorder(string sBind);

/// @brief Binds the form's closable property.
/// @param sBind Variable to bind.
void NUI_BindClosable(string sBind);

/// @brief Binds the form's collapsible property.
/// @param sBind Variable to bind.
void NUI_BindCollapsible(string sBind);

/// @brief Binds the control's color property.
/// @param sBind Variable to bind.
void NUI_BindColor(string sBind);

/// @brief Binds the disabled control's tooltip property.
/// @param sBind Variable to bind.
void NUI_BindDisabledTooltip(string sBind);

/// @brief Binds the control's elements property.
/// @param sBind Variable to bind.
void NUI_BindElements(string sBind);

/// @brief Binds the control's enabled property.
/// @param sBind Variable to bind.
void NUI_BindEnabled(string sBind);

/// @brief Binds the control's encouraged property.
/// @param sBind Variable to bind.
void NUI_BindEncouraged(string sBind);

/// @brief Binds the control's fill property.
/// @param sBind Variable to bind.
void NUI_BindFill(string sBind);

/// @brief Binds the control's foreground color property.
/// @param sBind Variable to bind.
void NUI_BindForegroundColor(string sBind);

/// @brief Binds the form's geometry property.
/// @param sBind Variable to bind.
void NUI_BindGeometry(string sBind);

/// @brief Binds the control's horizontal alignment property.
/// @param sBind Variable to bind.
void NUI_BindHorizontalAlignment(string sBind);

/// @brief Binds the control's resref (image) property.
/// @param sBind Variable to bind.
void NUI_BindResref(string sBind);

/// @brief Binds the control's label property.
/// @param sBind Variable to bind.
void NUI_BindLabel(string sBind);

/// @brief Binds the control's legend property.
/// @param sBind Variable to bind.
void NUI_BindLegend(string sBind);

/// @brief Binds the control's line thickness property.
/// @param sBind Variable to bind.
void NUI_BindLineThickness(string sBind);

/// @brief Binds the control's max property.
/// @param sBind Variable to bind.
void NUI_BindMax(string sBind);

/// @brief Binds the control's min property.
/// @param sBind Variable to bind.
void NUI_BindMin(string sBind);

/// @brief Binds the control's placeholder property.
/// @param sBind Variable to bind.
void NUI_BindPlaceholder(string sBind);

/// @brief Binds the control's points property.
/// @param sBind Variable to bind.
void NUI_BindPoints(string sBind);

/// @brief Binds the control's rectangle property.
/// @param sBind Variable to bind.
void NUI_BindRectangle(string sBind);

/// @brief Binds the control's region property.
/// @param sBind Variable to bind.
void NUI_BindRegion(string sBind);

/// @brief Binds the form's resizable property.
/// @param sBind Variable to bind.
void NUI_BindResizable(string sBind);

/// @brief Binds the control's rowcount property.
/// @param sBind Variable to bind.
void NUI_BindRowCount(string sBind);

/// @brief Binds the control's scissor property.
/// @param sBind Variable to bind.
void NUI_BindScissor(string sBind);

/// @brief Binds a slider control's bounds.
/// @param sUpper Variable to bind.
/// @param sLower Variable to bind.
/// @param sStep Variable to bind.
void NUI_BindSliderBounds(string sUpper, string sLower, string sStep);

/// @brief Binds the control's step property.
/// @param sBind Variable to bind.
void NUI_BindStep(string sBind);

/// @brief Binds the control's text property.
/// @param sBind Variable to bind.
void NUI_BindText(string sBind);

/// @brief Binds the form's title property.
/// @param sBind Variable to bind.
void NUI_BindTitle(string sBind);

/// @brief Binds the control's tooltip property.
/// @param sBind Variable to bind.
/// @param bDisabledTooltip If TRUE, the control's disabled tooltip property
///     will also be bound to sBind.
void NUI_BindTooltip(string sBind, int bDisabledTooltip = FALSE);

/// @brief Binds the form's elements property.
/// @param sBind Variable to bind.
void NUI_BindTransparent(string sBind);

/// @brief Binds the control's type property.
/// @param sBind Variable to bind.
void NUI_BindType(string sBind);

/// @brief Binds the control's value property.
/// @param sBind Variable to bind.
void NUI_BindValue(string sBind);

/// @brief Binds the control's vertical alignment property.
/// @param sBind Variable to bind.
void NUI_BindVerticalAlignment(string sBind);

/// @brief Binds the control's visible property.
/// @param sBind Variable to bind.
void NUI_BindVisible(string sBind);

/// @brief Set the form's accepts input property.
/// @param bAcceptsInput Whether the form will accept player input.
void NUI_SetAcceptsInput(int bAcceptsInput = TRUE);

/// @brief Sets the control's aspect property.
/// @param nAspect NUI_ASPECT_* constant.
void NUI_SetAspect(int nAspect);

/// @brief Sets the control's aspect ratio property.
/// @param fAspect Aspect ratio (x/y).
void NUI_SetAspectRatio(float fAspect);

/// @brief Sets the form's or control's border property.
/// @param bVisible Whether the border is visible.
void NUI_SetBorder(int bVisible = TRUE);

/// @brief Sets the control's center property.
/// @param x X-coordinate.
/// @param y Y-coordinate.
void NUI_SetCenter(float x, float y);

/// @brief Sets the form's closable property.
/// @param bClosable Whether the form is closable.
void NUI_SetClosable(int bClosable = TRUE);

/// @brief Sets the form's collapsible property.
/// @param bCollapsible Whether the form is collapsible.
void NUI_SetCollapsible(int bCollapsible = TRUE);

/// @brief Binds the control's color property.
/// @param sColor Json-parseable color vector as defined by NUI_DefineColor(),
///     NUI_DefineRGBColor(), NUI_DefineHSVColor(), NUI_DefineHexColor(), and
///     NUI_DefineRandomColor().
void NUI_SetColor(string sColor);

/// @brief For bound controls, sets the value that will be initially set
///     to the control's value property.
/// @param sDefault Default value to set.
void NUI_SetDefaultValue(string sDefault);

/// @brief Sets the control's center property.
/// @param sCenter Json-parseable point vector as defined by NUI_DefinePoint().
void NUI_SetDefinedCenter(string sCenter);

/// @brief Sets the form's geometry property.
/// @param sGeometry Json-parseable string representing a rectangular region as
///     defined by NUI_DefineRectangle().
void NUI_SetDefinedGeometry(string sGeometry);

/// @brief Sets the control's width and height properties.
/// @param fWidth Width.
/// @param fHeight Height.
void NUI_SetDimensions(float fWidth, float fHeight);

/// @brief Sets the disabled control's tooltip property.
/// @param sTooltip Tooltip text.
void NUI_SetDisabledTooltip(string sText);

/// @brief Sets the control's direction property.
/// @param nDirection NUI_ORIENTATION_* constant.
void NUI_SetDirection(int nDirection = NUI_ORIENTATION_ROW);

/// @brief Sets the control's draw condition property.
/// @param nCondition NUI_CONDITION_* constant.
void NUI_SetDrawCondition(int nCondition = NUI_DRAW_ALWAYS);

/// @brief Sets the control's draw position property.
/// @param nPosition NUI_POSITION_* constant.
void NUI_SetDrawPosition(int nPosition = NUI_DRAW_ABOVE);

/// @brief Sets the control's elements property.
/// @param sElements 
void NUI_SetElements(string sElements);

/// @brief Sets the control's enabled property.
/// @param bEnabled Whether the control is enabled.
void NUI_SetEnabled(int bEnabled = TRUE);

/// @brief Sets the control's encouraged property.
/// @param bEncourage Whether the control is encouraged.
void NUI_SetEncouraged(int bEncouraged = TRUE);

/// @brief Sets the control's fill property.
/// @param bFill Whether the control is filled.
void NUI_SetFill(int bFill = TRUE);

/// @brief Sets the bounds for a float-based slider.
/// @param fLower Lower bound.
/// @param fUpper Upper bound.
/// @param fStep Step Value.
void NUI_SetFloatSliderBounds(float fLower, float fUpper, float fStep);

/// @brief Sets the control's foreground color property.
/// @param sColor A json-parseable color vector as
///     defined by NUI_DefineRGBColor(), NUI_DefineHSVColor(), 
///     NUI_DefineHexColor(), or NUI_DefineRandomColor(). 
void NUI_SetForegroundColor(string sColor);

/// @brief Sets the form's geometry property.
/// @param x X-coordinate, top left corner.
/// @param y Y-coordinate, top left corner.
/// @param w Width.
/// @param h Height.
void NUI_SetGeometry(float x, float y, float w, float h);

/// @brief Sets the control's height property.
/// @param fHeight Height.
void NUI_SetHeight(float fHeight);

/// @brief Sets the control's horizontal alignment property.
/// @param nAlign NUI_HALIGN_* constant.
void NUI_SetHorizontalAlignment(int nAlign);

/// @brief Sets the control's id property.
/// @param sID ID.
void NUI_SetID(string sID);

/// @brief Sets the bounds for a integer-based slider.
/// @param nLower Lower bound.
/// @param nUpper Upper bound.
/// @param nStep Step Value.
void NUI_SetIntSliderBounds(int nLower, int nUpper, int nStep);

/// @brief Sets the control's label property.
/// @param sLabel Label.
void NUI_SetLabel(string sLabel);

/// @brief Sets the control's max length property.
/// @param nLength Max number of characters.
void NUI_SetLength(int nLength);

/// @brief Sets the control's line thickness property.
/// @param fThickness Line thickness.
void NUI_SetLineThickness(float fThickness);

/// @brief Sets the control's margin property.
/// @param fMargin Margin.
void NUI_SetMargin(float fMargin);

/// @brief Sets the control's multiline property.
/// @param bMultiline Whether the textbox has multiple lines.
void NUI_SetMultiline(int bMultiline = TRUE);

/// @brief Sets the control's padding property.
/// @param fPadding Padding.
void NUI_SetPadding(float fPadding);

/// @brief Sets the control's placeholder property.
/// @param sText Placeholder text.
void NUI_SetPlaceholder(string sText);

/// @brief Sets the control's points property.
/// @param sPoint Json-parseable string representing a coordinate array as defined
///     by NUI_GetLinePoints(), NUI_AddLinePoint(), or NUI_GetRectanglePoints().
void NUI_SetPoints(string sPoints);

/// @brief Sets the control's radius property.
/// @param r Radius.
void NUI_SetRadius(float r);

/// @brief Sets the control's rectangle property.
/// @param sRectangle Json-parsaable string representing a rectangular region as defined
///     by NUI_DefineRectangle().
void NUI_SetRectangle(string sRectangle);

/// @brief Sets the control's region property.
/// @param sRegion Json-parsaable string representing a rectangular region as defined
///     by NUI_DefineRectangle().
void NUI_SetRegion(string sRegion);

/// @brief Sets the form's resizable property.
/// @param bResizable Whether the form is resizable.
void NUI_SetResizable(int bResizable = TRUE);

/// @brief Sets the control's resref/image property.
/// @param sResref Resource resref.
void NUI_SetResref(string sResref);

/// @brief Sets the control's row count property.
/// @param nRowCount Number of rows.
void NUI_SetRowCount(int nRowCount);

/// @brief Sets the control's row height property.
/// @param fRowHeight Row height.
void NUI_SetRowHeight(float fRowHeight);

/// @brief Sets the control's scissor property.
/// @param bScissor Whether to scissor to the control's dimensions.
void NUI_SetScissor(int bScissor);

/// @brief Sets the control's scrollbars property.
/// @param nScrollBars NUI_SCROLLBARS_* constant.
void NUI_SetScrollbars(int nScrollbars = NUI_SCROLLBARS_AUTO);

/// @brief Sets the control's width and height properties.
/// @param fSide Length of one side.
void NUI_SetSquare(float fSide);

/// @brief Sets the control's type property.
/// @note Sets an editable textbox to non-editable.
void NUI_SetStatic();

/// @brief Sets the template's variable property.
/// @param bVariable Whether the template control width is variable.
void NUI_SetTemplateVariable(int bVariable = TRUE);

/// @brief Sets the template's width property.
/// @param fWidth Width.
void NUI_SetTemplateWidth(float fWidth);

/// @brief Sets the control's text property.
/// @param sText Text.
void NUI_SetText(string sText);

/// @brief Sets the form's title property.
/// @param sTitle Title.
void NUI_SetTitle(string sTitle);

/// @brief Sets the control's tooltip property.
/// @param sText Tooltip text.
/// @param bDisabledTooltip If TRUE, the control's disabled tooltip property
///     will also be set to sText.
void NUI_SetTooltip(string sText, int bDisabledTooltip = FALSE);

/// @brief Sets the form's transparent property.
/// @param bTransparent Whether the form's background is transparent.
void NUI_SetTransparent(int bTransparent = TRUE);

/// @brief Sets the control's value property.
/// @param sValue Json-Parseable string.
/// @note sValue must be a string representing a value json structure.
void NUI_SetValue(string sValue);

/// @brief Sets the control's vertical alignment property.
/// @param nAlign NUI_VALIGN_* constant.
void NUI_SetVerticalAlignment(int nAlign);

/// @brief Sets the control's visible property.
/// @param bVisible Whether the control is visible.
void NUI_SetVisible(int bVisible = TRUE);

/// @brief Sets the control's width property.
/// @param fWidth Width.
void NUI_SetWidth(float fWidth);

/// @brief Set's the control's wordwrap property.
/// @param bWrap Whether the text wrap's withing the control's width.
void NUI_SetWordWrap(int bWrap = TRUE);

/// @brief Defines all forms via formfiles that match prefixes set into
///     the configuration file.
/// @param sFormfile Optional formfile specification.
/// @note If sFormfile is passed, only the specified formfile will be loaded.
void NUI_DefineForms(string sFormfile = "");

/// @brief Display an NUI form.
/// @param oPC Client to display the form on.
/// @param sFormID ID of the for to display.
/// @param sProfile Optional form profile.
/// @returns Form's token as assigned by the game engine.
int NUI_DisplayForm(object oPC, string sFormID, string sProfile = "default");

/// @brief Close an open NUI form.
/// @param oPC Client on which to close the form.
/// @param sFormID ID of the form to close.
void NUI_CloseForm(object oPC, string sFormID);

/// @brief Display a subform onto control group element or form root.
/// @param oPC Client to display the subform on.
/// @param sFormID Form ID.
/// @param sElementID Element ID to replace.
/// @param sSubformID Subform ID to insert into sElement.
void NUI_DisplaySubform(object oPC, string sFormID, string sElementID, string sSubformID);

/// @brief Creates the default profile.
void NUI_CreateDefaultProfile();

/// @brief Create a custom form profile based on the default profile.
/// @param sProfile Profile name.
/// @param sBase Optional; must be a previously created profile.  If set,
///     sProfile will be based on profile sBase.
void NUI_CreateProfile(string sProfile, string sBase = "");

/// @brief Set a profile default bind value.
/// @param sBind Bind name.
/// @param sJson Json-parseable string representing the bind's profile value.
void NUI_SetProfileBind(string sBind, string sJson);

/// @brief Set multiple profile binds to a single value.
/// @param sBinds Comma-delimited list of bind names.
/// @param sJson Json-parseable string representing the binds' profile value.
void NUI_SetProfileBinds(string sBinds, string sJson);

/// @brief Set a form's profile.
/// @param oPC Client to set the profile on.
/// @param sFormID Form ID to set the profile on.
/// @param sProfile Profile to set.
void NUI_SetProfile(object oPC, string sFormID, string sProfile);

/// @brief Set a bind value.
/// @param oPC Player to set the bind for.
/// @param sFormID Form ID.
/// @param sBind Bind/property name.
/// @param sValue Json-parseable bind Value.
void NUI_SetBind(object oPC, string sFormID, string sBind, string sValue);

/// @brief Set a delayed bind value.
/// @param oPC Player to set the bind for.
/// @param sFormID Form ID.
/// @param sBind Bind/property name.
/// @param sValue Json-parseable bind Value.
void NUI_DelayBind(object oPC, string sFormID, string sBind, string sValue);

/// @brief Set a bind watch.
/// @param oPC Player to set the bind for.
/// @param sFormID Form ID.
/// @param sBind Bind/property name.
/// @param bWatch TRUE to set the watch, FALSE to remove it.
void NUI_SetBindWatch(object oPC, string sFormID, string sBind, int bWatch = TRUE);

/// @brief Retireve a bind value.
/// @param oPC Player to set the bind for.
/// @param sFormID Form ID.
/// @param sBind Bind/property name.
/// @returns Current bind value.
json NUI_GetBind(object oPC, string sFormID, string sBind);

/// @brief Create a temporary layout to be immediately returned by NUI_GetLayout().
/// @note Allow the creation of temporary layouts that can be immediately inserted
///     into a form's layout.  This function should not be used for creating
///     tabs to be referenced at a later time.  The layout created with this function
///     is temporary.
void NUI_CreateLayout();

/// @brief Get the temporary layout created with NUI_CreateLayout().
/// @note The json-parseable string can be inserted directly into the current layout
///     or used in a layout replacement (tabs).  This data will not, however, be
///     saved to the database, so this function and NUI_CreateLayout(). are
///     meant for dynamic form building.
string NUI_GetLayout();

/// @brief Save all of sFormID's bind values to a local variable.
/// @param oPC Player associated with sFormID.
/// @param sFormID Form ID to save bind values for.
void NUI_SaveState(object oPC, string sFormID);

/// @brief Restore all of sFormID's bind values from a local variable.
/// @param oPC Player associated with sFormID.
/// @param sFormID Form ID to restore bind values for.
void NUI_RestoreState(object oPC, string sFormID);

// -----------------------------------------------------------------------------
//                             Public Functions
//                          Administrative Helpers
// -----------------------------------------------------------------------------

// TODO Need prototypes
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

object nui_GetDataObject() {return GetModule();}

// -----------------------------------------------------------------------------
//                             Private Functions
//                        Build Flags and JSON Pathing
// -----------------------------------------------------------------------------

// TODO
/// CUT LINE FOR .35 - Remove below once .35 is stable

string nui_ReplaceSubString(string sString, string sSub, int nStart, int nEnd)
{
    int nLength = GetStringLength(sString);
    if (nStart < 0 || nStart >= nLength || nStart > nEnd)
        return sString;

    return GetSubString(sString, 0, nStart) + sSub +
           GetSubString(sString, nEnd + 1, nLength - nEnd);
}

string nui_SubstituteSubString(string sString, string sToken, string sSub)
{
    int nPos;
    if ((nPos = FindSubString(sString, sToken)) == -1)
        return sString;

    return nui_ReplaceSubString(sString, sSub, nPos, nPos + GetStringLength(sToken) - 1);
} 

string nui_SubstituteSubStrings(string sString, string sToken, string sSub)
{
    int n;
    while ((n = FindSubString(sString, sToken)) >= 0)
        sString = nui_SubstituteSubString(sString, sToken, sSub);

    return sString;
}

int nui_GetMatchesPattern(string sString, string sPattern)
{
    sqlquery q = SqlPrepareQueryObject(GetModule(),
        "SELECT @string GLOB @pattern;");
    SqlBindString(q, "@string", sString);
    SqlBindString(q, "@pattern", sPattern);
    return SqlStep(q) ? SqlGetInt(q, 0) : FALSE;
}

string nui_RegExpReplace(string sToken, string sString, string sSub)
{
    return nui_SubstituteSubStrings(sString, sToken, sSub);
}

int nui_RegExpMatch(string sString)
{
    return nui_GetMatchesPattern(sString, "*row_template???") || nui_GetMatchesPattern(sString, "*row_template?????");
}

string nui_RegExpReplaceLast(string sToken, string sString, string sSub)
{
    int nCount = GetSubStringCount(sString, sToken);
    
    if (nCount)
    {
        int nPos = FindSubStringN(sString, sToken, nCount - 1);

        // Need to delete the rest of the path too!
        return nui_ReplaceSubString(sString, sSub, nPos, nPos + GetStringLength(sString));
        //return nui_ReplaceSubString(sString, sSub, nPos, nPos + GetStringLength(sToken) - 1);
    }
    else
        return sString;
}

/// CUT LINE FOR .35 - Remove above once .35 is stable

void nui_ClearVariables()
{
    object oData = nui_GetDataObject();
    DeleteLocalInt   (oData, "FLAG_DEFINITION");
    DeleteLocalInt   (oData, "FLAG_INCREMENT");
    DeleteLocalInt   (oData, "FLAG_DRAWLIST");
    DeleteLocalInt   (oData, "FLAG_LISTBOX");
    DeleteLocalInt   (oData, "FLAG_FORCE");
    DeleteLocalInt   (oData, "NUI_ENTRY_COUNT");
    DeleteLocalString(oData, "NUI_CONTROL_TYPE");
    DeleteLocalString(oData, "NUI_PATH");
    DeleteLocalString(oData, "NUI_FORMID");
}

int nui_ToggleFlag(int nFlag, string sFlag)
{
    if (nFlag == -1)
        nFlag = !GetLocalInt(nui_GetDataObject(), sFlag);

    SetLocalInt(nui_GetDataObject(), sFlag, nFlag);
    return nFlag;
}

int  nui_GetEntryCount()                     {return GetLocalInt(nui_GetDataObject(), "NUI_ENTRY_COUNT");}
void nui_ResetEntryCount()                   {DeleteLocalInt(nui_GetDataObject(), "NUI_ENTRY_COUNT");}

int  nui_IncrementEntryCount(int nIncrement = 1)
{
    int nCount = nui_GetEntryCount();
    SetLocalInt(nui_GetDataObject(), "NUI_ENTRY_COUNT", ++nCount);
    return nCount;
}

int nui_ToggleIncrementFlag(int nFlag = -1)  {return nui_ToggleFlag(nFlag, "FLAG_INCREMENT");}
int nui_GetIncrementFlag()                   {return GetLocalInt(nui_GetDataObject(), "FLAG_INCREMENT");}

int nui_ToggleDrawlistFlag(int nFlag = -1)   {return nui_ToggleFlag(nFlag, "FLAG_DRAWLIST");}
int nui_GetDrawlistFlag()                    {return GetLocalInt(nui_GetDataObject(), "FLAG_DRAWLIST");}

int nui_ToggleListboxFlag(int nFlag = -1)    {return nui_ToggleFlag(nFlag, "FLAG_LISTBOX");}
int nui_GetListboxFlag()                     {return GetLocalInt(nui_GetDataObject(), "FLAG_LISTBOX");}

int nui_ToggleDefinitionFlag(int nFlag = -1) {return nui_ToggleFlag(nFlag, "FLAG_DEFINITION");}
int nui_GetDefinitionFlag()                  {return GetLocalInt(nui_GetDataObject(), "FLAG_DEFINITION");}

void   nui_SetControlType(string sType)      {SetLocalString(nui_GetDataObject(), "NUI_CONTROL_TYPE", sType);}
string nui_GetControlType()                  {return GetLocalString(nui_GetDataObject(), "NUI_CONTROL_TYPE");}

string nui_SetPath(string sPath)
{
    SetLocalString(nui_GetDataObject(), "NUI_PATH", sPath);
    return sPath;
}

void   nui_ResetPath()                       {nui_SetPath("$");}
string nui_GetPath()                         {return GetLocalString(nui_GetDataObject(), "NUI_PATH");}

void   nui_SetFormID(string sFormID)         {SetLocalString(nui_GetDataObject(), "NUI_FORMID", sFormID);}
string nui_GetFormID()                       {return GetLocalString(nui_GetDataObject(), "NUI_FORMID");}

void   nui_SetFormfile(string sFormfile)     {SetLocalString(nui_GetDataObject(), "NUI_FORMFILE", sFormfile);}
string nui_GetFormfile()                     {return GetLocalString(nui_GetDataObject(), "NUI_FORMFILE");}

// TODO When .35 is stable, remove the `nui_` in front of both `nui_RegExpReplace` functions
// to restore .35 functionality.
string nui_SubstitutePath(string sSub)       {return nui_SetPath(nui_RegExpReplace("@", nui_GetPath(), sSub));}
string nui_GetSubstitutedPath(string sSub)   {return nui_RegExpReplace("@", nui_GetPath(), sSub);}

// TODO Restore `RegExpMatch` when .35 is stable.
string nui_GetGroupKey()
{
    //return JsonGetString(JsonArrayGet(RegExpMatch("\\.(\\w*)\\[(?!.*\\.\\w*\\[)", nui_GetPath()), 1));
    return nui_RegExpMatch(nui_GetPath()) ? "row_template" : "";
}

string nui_IncrementPath(string sElement = "", int bForce = FALSE)
{
    if (!nui_GetIncrementFlag() && !bForce)
        return nui_GetPath();
    else
        nui_ToggleIncrementFlag();

    string sPath = nui_GetPath();

    if (sPath == "$")
        sPath += ".root";
    else
    {
        sPath = nui_SubstitutePath("#-1");

        if (nui_GetGroupKey() == "row_template" && (nui_GetControlType() == "group" || sElement == "draw_list"))
            sPath += "[0]";

        if (sElement != "draw_list")
        {
            if (nui_GetControlType() == "listbox")
                sPath += ".row_template[@]";
            else
                sPath += ".children[@]";
        }
        else
            sPath += ".draw_list[@]";
    }

    return nui_SetPath(sPath);
}

// TODO Restore .35 functionality

string nui_DecrementPath(int n = 1)
{
    string sPath;
    while (n-- > 0)
        sPath = nui_SetPath(nui_RegExpReplaceLast("[#-1]", nui_GetPath(), "[@]"));
        //sPath = nui_SetPath(RegExpReplace("\\[#-1\\](?!.*\\[#-1\\]).*", nui_GetPath(), "[@]"));

    return sPath;
}

// -----------------------------------------------------------------------------
//                             Private Functions
//                                 Database
// -----------------------------------------------------------------------------

string sQuery;
sqlquery sql;

void nui_BeginTransaction()  {SqlStep(SqlPrepareQueryObject(GetModule(), "BEGIN TRANSACTION;"));}
void nui_CommitTransaction() {SqlStep(SqlPrepareQueryObject(GetModule(), "COMMIT TRANSACTION;"));}

sqlquery nui_PrepareQuery(string sQuery, int bForceModule = FALSE)
{
    if (nui_GetDefinitionFlag() || bForceModule)
        return SqlPrepareQueryObject(GetModule(), sQuery);

    if (NUI_USE_CAMPAIGN_DATABASE)
        return SqlPrepareQueryCampaign(NUI_DATABASE, sQuery);
    else
        return SqlPrepareQueryObject(GetModule(), sQuery);
}

void nui_InitializeDatabase()
{
    sQuery = "DROP TABLE IF EXISTS nui_forms;";
    SqlStep(nui_PrepareQuery(sQuery));
    SqlStep(nui_PrepareQuery(sQuery, TRUE));

    sQuery = "CREATE TABLE IF NOT EXISTS nui_forms (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "form TEXT NOT NULL UNIQUE, " +
        "definition TEXT);";
    SqlStep(nui_PrepareQuery(sQuery));
    SqlStep(nui_PrepareQuery(sQuery, TRUE));
}

void nui_SaveForm(string sID, string sJson)
{
    sQuery = "INSERT INTO nui_forms (form, definition) " +
        "VALUES (@form, json(@json)) " +
        "ON CONFLICT (form) DO UPDATE SET " +
            "definition = json(@json);";
    sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sID);
    SqlBindString(sql, "@json", sJson);
    SqlStep(sql);
}

void nui_DeleteForm(string sID)
{
    sql = nui_PrepareQuery("DELETE FROM nui_forms WHERE form = @form;");
    SqlBindString(sql, "@form", sID);
    SqlStep(sql);
}

void nui_CopyDefinitions(string sTable = "nui_forms")
{
    if (!NUI_USE_CAMPAIGN_DATABASE)
        return;

    sQuery = "WITH forms AS (SELECT json_object('form', form, 'definition', definition) AS f " +
             "FROM " + sTable + ") SELECT json_group_array(json(f)) FROM forms;";
    sql = nui_PrepareQuery(sQuery, TRUE);
    json jForms = SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();

    if (jForms == JsonNull())
        return;

    // ->> only works in .35!  D'oh!
    /*
    sQuery = "INSERT OR REPLACE INTO " + sTable + " (form, definition) " +
        "SELECT value ->> '$.form', value ->> '$.definition' " +
        "FROM (SELECT value FROM json_each(@forms));";
    */
    // TODO remove when .35 is live
    sQuery = "INSERT OR REPLACE INTO " + sTable + " (form, definition) " +
        "SELECT json_extract(value, '$.form'), json_extract(value, '$.definition') " +
        "FROM (SELECT value FROM json_each(@forms));";
    sql = nui_PrepareQuery(sQuery);
    SqlBindJson(sql, "@forms", jForms);
    SqlStep(sql);

    sQuery = "DELETE FROM " + sTable + ";";
    SqlStep(nui_PrepareQuery(sQuery, TRUE));
}

string nui_GetDefinitionValue(string sFormID, string sPath = "")
{
    sQuery = "SELECT json_extract(definition, '$" + (sPath == "" ? "" : "." + sPath) + "') " +
        "FROM nui_forms WHERE form = @form;";
    
    sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

// -----------------------------------------------------------------------------
//                             Private Functions
//                              Form Definition
// -----------------------------------------------------------------------------

string nui_CreateRowTemplate(string sControl)
{
    return "[" + sControl + "," + nuiFloat(25.0) + "," + nuiBool(TRUE) + "]";
}

void nui_SetObject(string sProperty, string sValue, string sType = "")
{
    string sPath, sFormID = nui_GetFormID();

    if (sProperty != "")
    {
        sPath = nui_GetSubstitutedPath("#-1");

        if (nui_GetGroupKey() == "row_template")
        {
            if      (sProperty == "NUI_TEMPLATE_WIDTH")    sPath += "[1]";
            else if (sProperty == "NUI_TEMPLATE_VARIABLE") sPath += "[2]";
            else                                           sPath += "[0]." + sProperty;
        }
        else if (sProperty == "NUI_ELEMENT")               sPath += ".elements[#]";
        else if (sProperty == "NUI_SERIES")                sPath += ".value[#]";
        else                                               sPath += "." + sProperty;
    }
    else
    {
        nui_IncrementPath(sType);

        if (nui_GetGroupKey() == "row_template")
            sValue = nui_CreateRowTemplate(sValue);

        if (sType != "")
        {
            if (sType == "combo" || sType == "options")
                nui_ResetEntryCount();

            nui_SetControlType(sType);
        }

        sPath = nui_GetSubstitutedPath("#");
    }

    sQuery = "UPDATE nui_forms SET definition = (SELECT json_set(definition, '" + sPath + 
        "', json(@value)) FROM nui_forms WHERE form = @form) WHERE form = @form;";

    sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    SqlBindString(sql, "@value", sValue);
    SqlStep(sql);
}

void nui_SetControl (string sValue, string sType = "") {nui_SetObject("", sValue, sType);}
void nui_SetProperty(string sProperty, string sValue)  {nui_SetObject(sProperty, sValue);}

void nui_CreateControl(string sType, string sID = "")
{
    string sControl = "{" + 
        nuiString("label")      + ":null," +
        nuiString("value")      + ":null," + 
        nuiString("enabled")    + ":true," +
        nuiString("visible")    + ":true," +
        nuiString("user_data")  + ":{},"   +
        nuiString("event_data") + ":{},"   +
        nuiString("type")       + ":" + nuiString(sType) +
        (sID == "" ? "" : ","   + 
            nuiString("id")     + ":" + nuiString(sID))  +
    "}";
    
    nui_SetControl(sControl, sType);
}

string nui_CreateCanvasTemplate(string sProperties)
{
    return "{" +
        nuiString("enabled")        + ":true,"  +
        nuiString("fill")           + ":false," +
        nuiString("line_thickness") + ":0.5,"   +
        nuiString("order")          + ":" + nuiInt(NUI_DRAW_ABOVE)            + "," +
        nuiString("render")         + ":" + nuiInt(NUI_DRAW_ALWAYS)           + "," +
        nuiString("color")          + ":" + NUI_DefineRGBColor(255, 255, 255) + "," +
        sProperties +
    "}";
}

// -----------------------------------------------------------------------------
//                              Public Functions
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                          Json-Parseable Creators
// -----------------------------------------------------------------------------

string nuiString(string s)    {return "\"" + s + "\"";}
string nuiInt(int n)          {return IntToString(n);}
string nuiFloat(float f)      {return FloatToString(f);}
string nuiBool(int b)         {return b ? "true" : "false";}
string nuiBind(string sBind)  {return "{" + nuiString("bind")   + ":" + nuiString(sBind) + "}";}
string nuiStrRef(int nStrRef) {return "{" + nuiString("strref") + ":" + nuiInt(nStrRef)  + "}";}
string nuiNull()              {return "null";}

// -----------------------------------------------------------------------------
//                       Form/Subform/Layout Definition
// -----------------------------------------------------------------------------

void NUI_Initialize()
{
    if (GetLocalInt(GetModule(), "NUI_INITIALIZED"))
        return;

    SetLocalInt(GetModule(), "NUI_INITIALIZED", TRUE);

    nui_InitializeDatabase();
    NUI_DefineForms();
}

void NUI_CreateForm(string sID, string sVersion = "")
{
    nui_SetFormID(sID);

    string sForm = "{" +
        nuiString("accepts_input") + ":true,"  +
        nuiString("border")        + ":true,"  +
        nuiString("closable")      + ":true,"  +
        nuiString("resizable")     + ":true,"  +
        nuiString("collapsed")     + ":false," +
        nuiString("transparent")   + ":false," +
        nuiString("version")       + ":1,"     +
        nuiString("user_data")     + ":{},"    +
        nuiString("event_data")    + ":[],"    +
        nuiString("subforms")      + ":{},"    +
        nuiString("profiles")      + ":{" + nuiString("default") + ":{}}," +
        nuiString("formfile")      + ":"  + nuiString(nui_GetFormfile()) + "," +
        nuiString("geometry")      + ":"  + nuiBind("geometry")          + "," + 
        nuiString("title")         + ":"  + nuiBind("title")             + "," +
        nuiString("local_version") + ":"  + nuiString(sVersion)          + "," +
        nuiString("id")            + ":"  + nuiString(sID) +
    "}";

    nui_SaveForm(sID, sForm);  
    nui_ResetPath();
}

void NUI_CreateSubform(string sID) {nui_SetPath("$.subforms." + sID);}

void NUI_CreateLayout()
{
    nui_ToggleDefinitionFlag(TRUE);
    NUI_CreateForm("__layout__");   
}

string NUI_GetLayout()
{
    string sLayout = nui_GetDefinitionValue("__layout__", "root");
    nui_DeleteForm("__layout__");
    nui_ToggleDefinitionFlag(FALSE);
    return sLayout;
}

void NUI_SaveState(object oPC, string sFormID)
{
    int n, nToken = NuiFindWindow(oPC, sFormID);
    json jState = JsonObject();
    string sBind;

    while ((sBind = NuiGetNthBind(oPC, nToken, FALSE, n++)) != "")
        jState = JsonObjectSet(jState, sBind, NuiGetBind(oPC, nToken, sBind));

    if (jState != JsonObject())
        SetLocalJson(oPC, "NUI_STATE:" + sFormID, jState);
}

void NUI_RestoreState(object oPC, string sFormID)
{
    json jState = GetLocalJson(oPC, "NUI_STATE:" + sFormID);
    if (jState == JsonNull())
        return;

    json jKeys = JsonObjectKeys(jState);
    int n, nToken = NuiFindWindow(oPC, sFormID);
    string sBind;

    while ((sBind = JsonGetString(JsonArrayGet(jKeys, n++))) != "")
        NuiSetBind(oPC, nToken, sBind, JsonObjectGet(jState, sBind));
}

// -----------------------------------------------------------------------------
//                                  Vectors
// -----------------------------------------------------------------------------

string NUI_DefinePoint(float x, float y)
{
    return "{" +
        nuiString("x") + ":" + nuiFloat(x) + "," +
        nuiString("y") + ":" + nuiFloat(y) +
    "}";
}

string NUI_GetLinePoints(float x1, float y1, float x2, float y2)
{
    return "[" + 
        nuiFloat(x1) + "," +
        nuiFloat(y1) + "," +
        nuiFloat(x2) + "," +
        nuiFloat(y2) +
    "]";
}

string NUI_AddLinePoint(string sPoints, float x, float y)
{
    string sOpen;
    if (sPoints == "" || sPoints == "[]")
        sOpen = "[";
    else
        sOpen = GetStringLeft(sPoints, GetStringLength(sPoints) - 1) + ",";

    return sOpen +
           nuiFloat(x) + "," +
           nuiFloat(y) + "]";
}

string NUI_DefineRGBColor(int r, int g, int b, int a = 255)
{
    return "{" + 
        nuiString("r") + ":" + nuiInt(r) + "," +
        nuiString("g") + ":" + nuiInt(g) + "," +
        nuiString("b") + ":" + nuiInt(b) + "," +
        nuiString("a") + ":" + nuiInt(a) +
    "}";
}

string NUI_DefineHSVColor(float h, float s, float v)
{
    struct HSV hsv;
    hsv.h = h;
    hsv.s = s;
    hsv.v = v;

    struct RGB rgb = HSVToRGB(hsv);
    return NUI_DefineRGBColor(rgb.r, rgb.g, rgb.b);
}

string NUI_DefineHexColor(int nColor)
{
    struct RGB rgb = HexToRGB(nColor);
    return NUI_DefineRGBColor(rgb.r, rgb.g, rgb.b);
}

string NUI_DefineRandomColor()
{
    return NUI_DefineRGBColor(Random(256), Random(256), Random(256));
}

string NUI_DefineRectangle(float x, float y, float w, float h)
{
    return "{" + 
        nuiString("x") + ":" + nuiFloat(x) + "," +
        nuiString("y") + ":" + nuiFloat(y) + "," +
        nuiString("w") + ":" + nuiFloat(w) + "," +
        nuiString("h") + ":" + nuiFloat(h) +
    "}";
}

string NUI_GetRectanglePoints(float x, float y, float w, float h)
{
    string sx  = nuiFloat(x);
    string sy  = nuiFloat(y);
    string sxw = nuiFloat(x + w);
    string syh = nuiFloat(y + h);

    return "[" +
        sx  + "," + sy  + "," +
        sxw + "," + sy  + "," +
        sxw + "," + syh + "," +
        sx  + "," + syh + "," +
        sx  + "," + sy  +
    "]";
}

// TODO Needs Testing
string NUI_GetDefinedRectanglePoints(string sRectangle)
{
    float x = StringToFloat(nui_GetValue(GetListItem(sRectangle, 0)));
    float y = StringToFloat(nui_GetValue(GetListItem(sRectangle, 1)));
    float w = StringToFloat(nui_GetValue(GetListItem(sRectangle, 2)));
    float h = StringToFloat(nui_GetValue(GetListItem(sRectangle, 3)));
    
    return NUI_GetRectanglePoints(x, y, w, h);
}

string NUI_DefineCircle(float x, float y, float r)
{
    r = fclamp(r, 0.0, fmin(x, y));
    string d = nuiFloat(2 * r);

    return "{" + 
        nuiString("x") + ":" + nuiFloat(x - r) + "," +
        nuiString("y") + ":" + nuiFloat(y - r) + "," +
        nuiString("w") + ":" + d + "," +
        nuiString("h") + ":" + d +
    "}";
}

// -----------------------------------------------------------------------------
//                                  Controls
// -----------------------------------------------------------------------------

// Columns and Rows ------------------------------------------------------------

void nui_AddLayout(string sType, float f = -1.0)
{
    string sDimension;
    if (f > 0.0)
        sDimension = "," + nuiString(sType == "col" ? "width" : "height") + ":" + nuiFloat(f);

    string sRoot = "{" + 
        nuiString("enabled")  + ":true," + 
        nuiString("visible")  + ":true," +
        nuiString("children") + ":[],"   +
        nuiString("type")     + ":"      + nuiString(sType) +
        sDimension +
    "}";

    if (nui_GetPath() == "$")
    {
        nui_SetProperty("root", sRoot);
        nui_IncrementPath("", TRUE);
    }
    else
    {
        nui_SetControl(sRoot, sType);
        nui_ToggleIncrementFlag(TRUE);
    } 
}

void NUI_AddColumn(float fWidth = -1.0)    {nui_AddLayout("col", fWidth);}
void NUI_CloseColumn()                     {nui_DecrementPath();}

void NUI_AddRow(float fHeight = -1.0)      {nui_AddLayout("row", fHeight);}
void NUI_CloseRow()                        {nui_DecrementPath();}

// Controls --------------------------------------------------------------------

void NUI_AddCheckbox(string sID = "")      {nui_CreateControl("check",         sID);}
void NUI_AddColorPicker(string sID = "")   {nui_CreateControl("color_picker",  sID);}
void NUI_AddCommandButton(string sID = "") {nui_CreateControl("button",        sID);}
void NUI_AddFloatSlider(string sID = "")   {nui_CreateControl("sliderf",       sID);}
void NUI_AddImage(string sID = "")         {nui_CreateControl("image",         sID);}
void NUI_AddImageButton(string sID = "")   {nui_CreateControl("button_image",  sID);}
void NUI_AddIntSlider(string sID = "")     {nui_CreateControl("slider",        sID);}
void NUI_AddLabel(string sID = "")         {nui_CreateControl("label",         sID);}
void NUI_AddMoviePlayer(string sID = "")   {nui_CreateControl("movieplayer",   sID);}
void NUI_AddProgressBar(string sID = "")   {nui_CreateControl("progress",      sID);}
void NUI_AddSpacer(string sID = "")        {nui_CreateControl("spacer",        sID);}
void NUI_AddToggleButton(string sID = "")  {nui_CreateControl("button_select", sID);}

void NUI_AddCanvas()
{
    nui_SetProperty("draw_list", "[]");
    nui_SetProperty("draw_list_scissor", nuiBool(FALSE));
    nui_IncrementPath("draw_list", TRUE);
    nui_ToggleDrawlistFlag(TRUE);
}

void NUI_AddChart(string sID = "")
{
    nui_CreateControl("chart", sID);
    nui_SetProperty("value", "[]");
}

void NUI_CloseCanvas()
{
    nui_ToggleDrawlistFlag(FALSE);
    nui_DecrementPath();
}

void NUI_AddCombobox(string sID = "")
{
    nui_CreateControl("combo", sID);
    nui_SetProperty("elements", "[]");
}

void NUI_AddGroup(string sID = "")
{
    sID = (sID == "" ? "" : nuiString("id") + ":" + nuiString(sID) + ",");
    string sGroup = "{" + sID +
        nuiString("children")   + ":[]," +
        nuiString("border")     + ":true," +
        nuiString("type")       + ":" + nuiString("group") + "," +
        nuiString("scrollbars") + ":" + nuiInt(NUI_SCROLLBARS_AUTO) +
    "}";

    nui_SetControl(sGroup, "group");
    nui_ToggleIncrementFlag(TRUE);
}

void NUI_CloseGroup() {nui_DecrementPath();}

void NUI_AddListbox(string sID = "")
{
    sID = (sID == "" ? "" : nuiString("id") + ":" + nuiString(sID) + ",");
    string sList = "{" + sID +
        nuiString("row_template") + ":[]," +
        nuiString("row_count")    + ":null," +
        nuiString("border")       + ":true," +
        nuiString("row_height")   + ":25.0," +
        nuiString("type")         + ":" + nuiString("list") + "," +
        nuiString("scrollbars")   + ":" + nuiInt(NUI_SCROLLBARS_Y) +
    "}";

    nui_SetControl(sList, "listbox");
    nui_ToggleIncrementFlag(TRUE);
}

void NUI_CloseListbox() {nui_DecrementPath();}

void NUI_AddOptionGroup(string sID = "")
{
    nui_CreateControl("options", sID);
    nui_SetProperty("elements", "[]");
}

// TODO prototype
void NUI_AddToggleGroup(string sID = "")
{
    nui_CreateControl("tabbar", sID);
    nui_SetProperty("elements", "[]");
}

void NUI_AddTextbox(string sID = "")
{
    nui_CreateControl("textedit", sID);
    nui_SetProperty("wordwrap", nuiBool(TRUE));    
}

// Drawlist --------------------------------------------------------------------

void NUI_DrawLine(string sPoints)
{
    string sDraw = 
        nuiString("points") + ":" + sPoints + "," +
        nuiString("type") +   ":" + nuiInt(0);

    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_DrawRectangle(float x, float y, float w, float h)
{
    NUI_DrawLine(NUI_GetRectanglePoints(x, y, w, h));
}

void NUI_DrawDefinedRectangle(string sRect)
{
    NUI_DrawLine(NUI_GetDefinedRectanglePoints(sRect));
}

void NUI_DrawCircle(float x, float y, float r)
{
    string sDraw =
        nuiString("rect") + ":" + NUI_DefineCircle(x, y, r) + "," +
        nuiString("type") + ":" + nuiInt(2);

    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_DrawDefinedCircle(string sCircle)
{
    string sDraw =
        nuiString("rect") + ":" + sCircle + "," +
        nuiString("type") + ":" + nuiInt(2);

    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_DrawTextbox(string sRect, string sText)
{
    string sDraw =
        nuiString("rect") + ":" + sRect + "," +
        nuiString("text")   + ":" + nuiString(sText) + "," +
        nuiString("type")   + ":" + nuiInt(4);

    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_DrawImage(string sResref, string sRect, int nAspect, int nHAlign, int nVAlign)
{
    string sDraw =
        nuiString("rect")         + ":" + sRect             + "," +
        nuiString("image")        + ":" + nuiString(sResref) + "," +
        nuiString("image_aspect") + ":" + nuiInt(nAspect)   + "," +
        nuiString("image_halign") + ":" + nuiInt(nHAlign)   + "," +
        nuiString("image_valign") + ":" + nuiInt(nVAlign)   + "," +
        nuiString("type")         + ":" + nuiInt(5);
    
    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_DrawArc(string sCenter, float fRadius, float fAMin, float fAMax)
{
    string sDraw =
        nuiString("c")      + ":" + sCenter           + "," +
        nuiString("radius") + ":" + nuiFloat(fRadius) + "," +
        nuiString("amin")   + ":" + nuiFloat(fAMin)   + "," +
        nuiString("amax")   + ":" + nuiFloat(fAMax)   + "," +
        nuiString("type")   + ":" + nuiInt(3);
    
    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_DrawCurve(string sA, string sB, string sCtrl0, string sCtrl1)
{
    string sDraw = 
        nuiString("a")     + ":" + sA + "," +
        nuiString("b")     + ":" + sB + "," +
        nuiString("ctrl0") + ":" + sCtrl0 + "," +
        nuiString("ctrl1") + ":" + sCtrl1 + "," +
        nuiString("type")  + ":" + nuiInt(1);
    
    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_BindLine(string sBind)   {NUI_DrawLine(nuiBind(sBind));}
void NUI_BindCircle(string sBind) {NUI_DrawDefinedCircle(nuiBind(sBind));}

void NUI_BindTextbox(string sRectangle, string sText)
{
    string sDraw =
        nuiString("text")   + ":" + nuiBind(sText) + "," +
        nuiString("points") + ":" + nuiBind(sRectangle) + "," +
        nuiString("type")   + ":" + nuiInt(4);

    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_BindImage(string sResref, string sRectangle, string sAspect, string sHAlign, string sVAlign)
{
    string sDraw =
        nuiString("rect")         + ":" + nuiBind(sRectangle) + "," +
        nuiString("image")        + ":" + nuiBind(sResref) + "," +
        nuiString("image_aspect") + ":" + nuiBind(sAspect) + "," +
        nuiString("image_halign") + ":" + nuiBind(sHAlign) + "," +
        nuiString("image_valign") + ":" + nuiBind(sVAlign) + "," +
        nuiString("type")         + ":" + nuiInt(5);
    
    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_BindArc(string sCenter, string sRadius, string sStartAngle, string sEndAngle)
{
    string sDraw =
        nuiString("c")      + ":" + nuiBind(sCenter) + "," +
        nuiString("radius") + ":" + nuiBind(sRadius) + "," +
        nuiString("amin")   + ":" + nuiBind(sStartAngle) + "," +
        nuiString("amax")   + ":" + nuiBind(sEndAngle) + "," +
        nuiString("type")   + ":" + nuiInt(3);
    
    nui_ToggleIncrementFlag(FALSE);
    nui_SetControl(nui_CreateCanvasTemplate(sDraw));
}

void NUI_BindCurve(string sStart, string sEnd, string sCtrl0, string sCtrl1)
{
    NUI_DrawCurve(nuiBind(sStart), nuiBind(sEnd), nuiBind(sCtrl0), nuiBind(sCtrl1));
}

// -----------------------------------------------------------------------------
//                         Form and Control Properties
// -----------------------------------------------------------------------------

// Binds -----------------------------------------------------------------------
//   Forms ---------------------------------------------------------------------
void NUI_BindAcceptsInput(string sBind)         {nui_SetProperty("accepts_input",     nuiBind(sBind));}
void NUI_BindClosable(string sBind)             {nui_SetProperty("closable",          nuiBind(sBind));}
void NUI_BindCollapsible(string sBind)          {nui_SetProperty("collapsed",         nuiBind(sBind));}
void NUI_BindGeometry(string sBind)             {nui_SetProperty("geometry",          nuiBind(sBind));}
void NUI_BindResizable(string sBind)            {nui_SetProperty("resizable",         nuiBind(sBind));}
void NUI_BindTitle(string sBind)                {nui_SetProperty("title",             nuiBind(sBind));}
void NUI_BindTransparent(string sBind)          {nui_SetProperty("transparent",       nuiBind(sBind));}

// Binds -----------------------------------------------------------------------
//   Shared --------------------------------------------------------------------
void NUI_BindBorder(string sBind)               {nui_SetProperty("border",            nuiBind(sBind));}

// Binds -----------------------------------------------------------------------
//   Controls ------------------------------------------------------------------
void NUI_BindData(string sBind)                 {nui_SetProperty("data",              nuiBind(sBind));}
void NUI_BindDisabledTooltip(string sBind)      {nui_SetProperty("disabled_tooltip",  nuiBind(sBind));}
void NUI_BindElements(string sBind)             {nui_SetProperty("elements",          nuiBind(sBind));}
void NUI_BindEnabled(string sBind)              {nui_SetProperty("enabled",           nuiBind(sBind));}
void NUI_BindEncouraged(string sBind)           {nui_SetProperty("encouraged",        nuiBind(sBind));}
void NUI_BindEndPoint(string sBind)             {nui_SetProperty("b",                 nuiBind(sBind));}
void NUI_BindFill(string sBind)                 {nui_SetProperty("fill",              nuiBind(sBind));}
void NUI_BindForegroundColor(string sBind)      {nui_SetProperty("foreground_color",  nuiBind(sBind));}
void NUI_BindHorizontalAlignment(string sBind)  {nui_SetProperty("text_halign",       nuiBind(sBind));}
void NUI_BindLegend(string sBind)               {nui_SetProperty("legend",            nuiBind(sBind));}
void NUI_BindLength(string sBind)               {nui_SetProperty("max",               nuiBind(sBind));}
void NUI_BindLineThickness(string sBind)        {nui_SetProperty("line_thickness",    nuiBind(sBind));}
void NUI_BindPlaceholder(string sBind)          {nui_SetProperty("label",             nuiBind(sBind));}
void NUI_BindPoints(string sBind)               {nui_SetProperty("points",            nuiBind(sBind));}
void NUI_BindRadius(string sBind)               {nui_SetProperty("radius",            nuiBind(sBind));}
void NUI_BindRectangle(string sBind)            {nui_SetProperty("rect",              nuiBind(sBind));}
void NUI_BindRegion(string sBind)               {nui_SetProperty("image_region",      nuiBind(sBind));}
void NUI_BindRowCount(string sBind)             {nui_SetProperty("row_count",         nuiBind(sBind));}
void NUI_BindScissor(string sBind)              {nui_SetProperty("draw_list_scissor", nuiBind(sBind));}
void NUI_BindStartPoint(string sBind)           {nui_SetProperty("a",                 nuiBind(sBind));}
void NUI_BindStep(string sBind)                 {nui_SetProperty("step",              nuiBind(sBind));}
void NUI_BindText(string sBind)                 {nui_SetProperty("text",              nuiBind(sBind));}
void NUI_BindType(string sBind)                 {nui_SetProperty("type",              nuiBind(sBind));}
void NUI_BindValue(string sBind)                {nui_SetProperty("value",             nuiBind(sBind));}
void NUI_BindVerticalAlignment(string sBind)    {nui_SetProperty("text_valign",       nuiBind(sBind));}
void NUI_BindVisible(string sBind)              {nui_SetProperty("visible",           nuiBind(sBind));}

void NUI_BindAspect(string sBind)
{
    string sProperty;
    if (nui_GetDrawlistFlag() || nui_GetControlType() == "image")
        sProperty = "image_aspect";
    else
        sProperty = "aspect";

    nui_SetProperty(sProperty, nuiBind(sBind));
}

void NUI_BindColor(string sBind)
{
    string sProperty = (nui_GetControlType() == "color_picker" ? "value" : "color");
    nui_SetProperty(sProperty, nuiBind(sBind));
}

void NUI_BindSliderBounds(string sUpper, string sLower, string sStep)
{
    nui_SetProperty("max", nuiBind(sUpper));
    nui_SetProperty("min", nuiBind(sLower));
    nui_SetProperty("step", nuiBind(sStep));
}

void NUI_BindLabel(string sBind)
{
    string sProperty = (nui_GetControlType() == "label" ? "value" : "label");
    nui_SetProperty(sProperty, nuiBind(sBind));
}

void NUI_BindMax(string sBind)
{
    string sProperty = (nui_GetDrawlistFlag() ? "amax" : "max");
    nui_SetProperty(sProperty, nuiBind(sBind));
}

void NUI_BindMin(string sBind)
{
    string sProperty = (nui_GetDrawlistFlag() ? "amin" : "min");
    nui_SetProperty(sProperty, nuiBind(sBind));
}

void NUI_BindResref(string sBind)
{
    string sProperty, sType = nui_GetControlType();
    if      (sType == "button_image") sProperty = "label";
    else if (sType == "image")        sProperty = "value";
    else if (sType == "movieplayer")  sProperty = "value";
    else                              sProperty = "image";

    nui_SetProperty(sProperty, nuiBind(sBind));
}

void NUI_BindTooltip(string sBind, int bDisabledTooltip = FALSE)
{
    nui_SetProperty("tooltip", nuiBind(sBind));
    if (bDisabledTooltip) NUI_BindDisabledTooltip(sBind);
}

// Sets ------------------------------------------------------------------------
//   Forms ---------------------------------------------------------------------
void NUI_SetAcceptsInput(int bAcceptsInput = TRUE)       {nui_SetProperty("accepts_input",          nuiBool(bAcceptsInput));}
void NUI_SetClosable(int bClosable = TRUE)               {nui_SetProperty("closable",               nuiBool(bClosable));}
void NUI_SetCollapsible(int bCollapsible = TRUE)         {nui_SetProperty("collapsed",              nuiBool(bCollapsible));}
void NUI_SetTitle(string sTitle)                         {nui_SetProperty("title",                  nuiString(sTitle));}
void NUI_SetTOCTitle(string sTitle)                      {nui_SetProperty("toc_title",              nuiString(sTitle));}
void NUI_SetDefinedGeometry(string sGeometry)            {nui_SetProperty("geometry",               sGeometry);}
void NUI_SetGeometry(float x, float y, float w, float h) {nui_SetProperty("geometry",               NUI_DefineRectangle(x, y, w, h));}
void NUI_SetResizable(int bResizable = TRUE)             {nui_SetProperty("resizable",              nuiBool(bResizable));}
void NUI_SetTransparent(int bTransparent = TRUE)         {nui_SetProperty("transparent",            nuiBool(bTransparent));}

// Sets ------------------------------------------------------------------------        
//   Shared --------------------------------------------------------------------        
void NUI_SetBorder(int bVisible = TRUE)                  {nui_SetProperty("border",                 nuiBool(bVisible));}

// Sets ------------------------------------------------------------------------
//   Controls ------------------------------------------------------------------
void NUI_SetAspect(int nAspect)                               {nui_SetProperty("image_aspect",           nuiInt(nAspect));}
void NUI_SetAspectRatio(float fAspect)                        {nui_SetProperty("aspect",                 nuiFloat(fAspect));}
void NUI_SetCenter(float x, float y)                          {nui_SetProperty("c",                      NUI_DefinePoint(x, y));}
void NUI_SetDefaultValue(string sDefault)                     {nui_SetProperty("default_value",          sDefault);}
void NUI_SetDisabledTooltip(string sTooltip)                  {nui_SetProperty("disabled_tooltip",       nuiString(sTooltip));}
void NUI_SetDirection(int nDirection = NUI_ORIENTATION_ROW)   {nui_SetProperty("direction",              nuiInt(nDirection));}
void NUI_SetDrawCondition(int nCondition = NUI_DRAW_ALWAYS)   {nui_SetProperty("render",                 nuiInt(nCondition));}
void NUI_SetDrawPosition(int nPosition = NUI_DRAW_ABOVE)      {nui_SetProperty("order",                  nuiInt(nPosition));}
void NUI_SetEnabled(int bEnabled = TRUE)                      {nui_SetProperty("enabled",                nuiBool(bEnabled));}
void NUI_SetEncouraged(int bEncouraged = TRUE)                {nui_SetProperty("encouraged",             nuiBool(bEncouraged));}
void NUI_SetFill(int bFill = TRUE)                            {nui_SetProperty("fill",                   nuiBool(bFill));}
void NUI_SetForegroundColor(string sColor)                    {nui_SetProperty("foreground_color",       sColor);}
void NUI_SetHeight(float fHeight)                             {nui_SetProperty("height",                 nuiFloat(fHeight));}
void NUI_SetID(string sID)                                    {nui_SetProperty("id",                     nuiString(sID));}
void NUI_SetLength(int nLength)                               {nui_SetProperty("max",                    nuiInt(nLength));}
void NUI_SetLineThickness(float fThickness)                   {nui_SetProperty("line_thickness",         nuiFloat(fThickness));}
void NUI_SetMargin(float fMargin)                             {nui_SetProperty("margin",                 nuiFloat(fMargin));}
void NUI_SetMultiline(int bMultiline = TRUE)                  {nui_SetProperty("multiline",              nuiBool(bMultiline));}
void NUI_SetPadding(float fPadding)                           {nui_SetProperty("padding",                nuiFloat(fPadding));}
void NUI_SetPlaceholder(string sText)                         {nui_SetProperty("label",                  nuiString(sText));}
void NUI_SetPoints(string sPoints)                            {nui_SetProperty("points",                 sPoints);}
void NUI_SetRadius(float r)                                   {nui_SetProperty("radius",                 nuiFloat(r));}
void NUI_SetRectangle(string sRectangle)                      {nui_SetProperty("rect",                   sRectangle);}
void NUI_SetRegion(string sRegion)                            {nui_SetProperty("image_region",           sRegion);}
void NUI_SetRowCount(int nRowCount)                           {nui_SetProperty("row_count",              nuiInt(nRowCount));}
void NUI_SetRowHeight(float fRowHeight)                       {nui_SetProperty("row_height",             nuiFloat(fRowHeight));}
void NUI_SetScissor(int bScissor)                             {nui_SetProperty("draw_list_scissor",      nuiBool(bScissor));}
void NUI_SetScrollbars(int nScrollbars = NUI_SCROLLBARS_AUTO) {nui_SetProperty("scrollbars",             nuiInt(nScrollbars));}
void NUI_SetStatic()                                          {nui_SetProperty("type",                   nuiString("text"));}
void NUI_SetTemplateVariable(int bVariable)                   {nui_SetProperty("NUI_TEMPLATE_VARIABLE",  nuiBool(bVariable));}
void NUI_SetTemplateWidth(float fWidth)                       {nui_SetProperty("NUI_TEMPLATE_WIDTH",     nuiFloat(fWidth));}
void NUI_SetText(string sText)                                {nui_SetProperty("text",                   nuiString(sText));}
void NUI_SetValue(string sValue)                              {nui_SetProperty("value",                  sValue);}
void NUI_SetVisible(int bVisible = TRUE)                      {nui_SetProperty("visible",                nuiBool(bVisible));}
void NUI_SetWidth(float fWidth)                               {nui_SetProperty("width",                  nuiFloat(fWidth));}
void NUI_SetWordWrap(int bWrap = TRUE)                        {nui_SetProperty("wordwrap",               nuiBool(bWrap));}

void NUI_SetColor(string sColor)
{
    string sProperty = (nui_GetControlType() == "color_picker" ? "value" : "color");
    nui_SetProperty(sProperty, sColor);
}

void NUI_SetDimensions(float fWidth, float fHeight)
{
    NUI_SetWidth(fWidth);
    NUI_SetHeight(fHeight);
}

void NUI_SetElements(string sElements)
{
    int nEntry = nui_GetEntryCount();
    string sType = nui_GetControlType();
    int n; for(n; n < CountList(sElements); n++)
    {
        string sElement, sEntry = GetListItem(sElements, n);
        if (sType == "combo")       
            sElement = "[" +
                nuiString(sEntry) + "," +
                nuiInt(nEntry++) +
            "]";
        else if (sType == "options" || sType == "tabbar")
            sElement = nuiString(sEntry);

        nui_IncrementEntryCount();
        nui_SetProperty("NUI_ELEMENT", sElement);
    }
}

void NUI_SetFloatSliderBounds(float fLower, float fUpper, float fStep)
{
    nui_SetProperty("min", nuiFloat(fLower));
    nui_SetProperty("max", nuiFloat(fUpper));
    nui_SetProperty("step", nuiFloat(fStep));
}

void NUI_SetHorizontalAlignment(int nAlign)
{
    string sProperty = (nui_GetControlType() == "label" ? "text_halign" : "image_halign");
    nui_SetProperty(sProperty, nuiInt(nAlign));
}

void NUI_SetIntSliderBounds(int nLower, int nUpper, int nStep)
{
    nui_SetProperty("min", nuiInt(nLower));
    nui_SetProperty("max", nuiInt(nUpper));
    nui_SetProperty("step", nuiInt(nStep));
}

void NUI_SetLabel(string sLabel)
{
    string sProperty = (nui_GetControlType() == "label" ? "value" : "label");
    nui_SetProperty(sProperty, nuiString(sLabel));
}

void NUI_SetResref(string sResref)
{
    string sProperty, sType = nui_GetControlType();
    if      (sType == "button_image") sProperty = "label";
    else if (sType == "image")        sProperty = "value";
    else if (sType == "movieplayer")  sProperty = "value";
    else                              sProperty = "image";

    nui_SetProperty(sProperty, nuiString(sResref));
}

void NUI_SetSquare(float fSide)
{
    NUI_SetHeight(fSide);
    NUI_SetWidth(fSide);
}

void NUI_SetTooltip(string sTooltip, int bDisabledTooltip = FALSE)
{
    nui_SetProperty("tooltip", nuiString(sTooltip));
    if (bDisabledTooltip) NUI_SetDisabledTooltip(sTooltip);
}

// TODO alignments for future movie player growth?
void NUI_SetVerticalAlignment(int nAlign)
{
    string sProperty = (nui_GetControlType() == "label" ? "text_valign" : "image_valign");
    nui_SetProperty(sProperty, nuiInt(nAlign));
}

// TODO not tested
void NUI_SetChartSeries(int nType, string sLegend, string sColor, string sData)
{
    string sChart = "{" +
        nuiString("type")   + ":" + nuiInt(nType) + "," +
        nuiString("legend") + ":" + nuiString(sLegend)  + "," +
        nuiString("color")  + ":" + sColor              + "," +
        nuiString("data")   + ":" + sData +
    "}";

    nui_SetProperty("NUI_SERIES", sChart);
}

// -----------------------------------------------------------------------------
//                         Form Definition/Management
//                                  Private
// -----------------------------------------------------------------------------

json nui_GetForm(string sFormID, int bForceModule = FALSE)
{
    sql = nui_PrepareQuery("SELECT definition FROM nui_forms WHERE form = @form;", bForceModule);    
    SqlBindString(sql, "@form", sFormID);

    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonNull();
}

string nui_GetFormsByPrefix(string sForms, string sPrefix, int nResType)
{
    string sForm;
    int n; while ((sForm = ResManFindPrefix(sPrefix, nResType, ++n)) != "")
        sForms = AddListItem(sForms, sForm, TRUE);

    return sForms;
}

string nui_GetForms(string sPrefix)
{
    string sForms = nui_GetFormsByPrefix("", sPrefix, RESTYPE_NCS);
    return sForms = nui_GetFormsByPrefix(sForms, sPrefix, RESTYPE_NSS);
}

int nui_ExecuteFunction(string sFile, string sFunction, object oTarget = OBJECT_SELF, string sArguments = "")
{
    if (sFile == "" || sFunction == "")
        return FALSE;

    if (ResManFindPrefix(sFile, RESTYPE_NCS) == sFile)
    {   
        SetScriptParam("NUI_FUNCTION", sFunction);
        SetScriptParam("NUI_ARGS", sArguments);
        ExecuteScript(sFile, oTarget);
        return TRUE;
    }

    if (sArguments != "") sArguments = nuiString(sArguments);

    string sChunk = "#" + "include " + nuiString(sFile) + " " +
                    "void main() {" + sFunction + "(" + sArguments + ");}";
    return ExecuteScriptChunk(sChunk, oTarget, FALSE) == "";
}

json NUI_GetOrphanBinds(string sFormID)
{
    sQuery = "SELECT json_group_array(value) FROM (SELECT DISTINCT value FROM nui_forms, " +
        "json_tree(nui_forms.definition, '$') WHERE key = 'bind' and form = @form EXCEPT " +
        "SELECT key FROM (SELECT DISTINCT key FROM nui_forms, json_each(nui_forms.definition, " +
        "'$.profiles.default') AS value WHERE form = @form));";
    sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonArray();
}

// -----------------------------------------------------------------------------
//                               Form Profiles
//                                  Private
// -----------------------------------------------------------------------------

void   nui_SetProfile(string sProfile) {SetLocalString(nui_GetDataObject(), "NUI_PROFILE", sProfile);}
string nui_GetProfile()                {return GetLocalString(nui_GetDataObject(), "NUI_PROFILE");}

/// @private Sets the profile bind value into the form definition.
void nui_SetProfileBind(string sProperty, string sJson = "")
{
    string sPath = "$.profiles." + nui_GetProfile() + "." + sProperty;
    sQuery = "UPDATE nui_forms SET definition = (SELECT json_set(definition, '" + sPath + 
        "', json(@json)) FROM nui_forms WHERE form = @form) WHERE form = @form;";

    sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", nui_GetFormID());
    SqlBindString(sql, "@json", sJson);
    SqlStep(sql);
}

/// @private Used when basing a new profile off an old profile.  To prevent massive amounts
///     of potential recursion, just copy the base profile and go from there.
void nui_CopyProfile(string sBase)
{
    sQuery = "WITH base AS (SELECT value FROM nui_forms, json_tree(nui_forms.definition, " +
        "'$.profiles') WHERE key = @base AND form = @form) UPDATE nui_forms SET definition = " +
        "(SELECT json_set(definition, '$.profiles." + nui_GetProfile() + "', json_extract(base.value, '$')) " +
        "FROM nui_forms, base WHERE form = @form) WHERE form = @form;";

    sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@base", sBase);
    SqlBindString(sql, "@form", nui_GetFormID());
    SqlStep(sql);
}

/// @private Returns a json object of bind:value pairs from the default profile as modified
///     by sProfile.
json nui_GetProfileBinds(string sFormID, string sProfile = "")
{
    sQuery = "WITH def AS (SELECT value FROM nui_forms, json_tree(nui_forms.definition, " +
        "'$.profiles') WHERE key = 'default' AND form = @form), sel AS (SELECT " +
        "COALESCE((SELECT value from nui_forms, json_tree(nui_forms.definition, '$.profiles') " +
        "WHERE key = @profile AND form = @form), json_object()) value FROM nui_forms WHERE form = @form) " +
        "SELECT json_patch(json_extract(def.value, '$'), json_extract(sel.value, '$')) FROM def, sel;";

    sql = nui_PrepareQuery(sQuery);
    SqlBindString(sql, "@form", sFormID);
    SqlBindString(sql, "@profile", sProfile);
    return SqlStep(sql) ? SqlGetJson(sql, 0) : JsonObject();    
}

/// @private Called during form opening, sets the initial values for all default binds.
void nui_SetProfileBinds(object oPC, int nToken, string sFormID, string sProfile)
{
    json jProfile = nui_GetProfileBinds(sFormID, sProfile);
    json jKeys    = JsonObjectKeys(jProfile);
    int n; for (n; n < JsonGetLength(jKeys); n++)
    {
        string sKey = JsonGetString(JsonArrayGet(jKeys, n));
        NuiSetBind(oPC, NuiFindWindow(oPC, sFormID), sKey, JsonObjectGet(jProfile, sKey));
    }

    NUI_DelayBind(oPC, sFormID, "NUI_FORM_PROFILE", nuiString(sProfile));
    NUI_DelayBind(oPC, sFormID, "NUI_FORM_FILE", nuiString(nui_GetDefinitionValue(sFormID, "formfile")));
}

// -----------------------------------------------------------------------------
//                         Form Definition/Management
//                                  Public
// -----------------------------------------------------------------------------

void NUI_DefineForms(string sFormfile = "")
{
    nui_ClearVariables();
    nui_BeginTransaction();
    nui_ToggleDefinitionFlag(TRUE);

    if (sFormfile != "")
    {
        nui_SetFormfile(sFormfile);
        nui_ExecuteFunction(sFormfile, NUI_DEFINE);
    }
    else
    {
        int n; for (n; n < CountList(NUI_FORMFILE_PREFIX); n++)
        {
            string sFormfiles = nui_GetForms(GetListItem(NUI_FORMFILE_PREFIX, n));
            if (sFormfiles == "") return;

            int f; for (f; f < CountList(sFormfiles); f++)
            {
                sFormfile = GetListItem(sFormfiles, f);
                nui_SetFormfile(sFormfile);
                nui_ExecuteFunction(sFormfile, NUI_DEFINE);
            }
        }
    }

    nui_ToggleDefinitionFlag(FALSE);
    nui_CopyDefinitions();
    nui_CommitTransaction();
}

int NUI_DisplayForm(object oPC, string sFormID, string sProfile = "default")
{
    json jForm = nui_GetForm(sFormID);
    if (jForm != JsonNull())
    {
        int nToken = NuiCreate(oPC, jForm, sFormID);
        nui_SetProfileBinds(oPC, nToken, sFormID, sProfile);
        nui_ExecuteFunction(nui_GetDefinitionValue(sFormID, "formfile"), NUI_BIND, oPC);
        return nToken;
    }

    return -1;
}

void NUI_CloseForm(object oPC, string sFormID) {NuiDestroy(oPC, NuiFindWindow(oPC, sFormID));}

void NUI_DisplaySubform(object oPC, string sFormID, string sElementID, string sSubformID)
{
    int nToken = NuiFindWindow(oPC, sFormID);
    string sLayout = nui_GetDefinitionValue(NuiGetWindowId(oPC, nToken), "subforms." + sSubformID);
    NuiSetGroupLayout(oPC, nToken, sElementID, JsonParse(sLayout));
}

int NUI_GetFormToken(object oPC, string sFormID)
{
    return NuiFindWindow(oPC, sFormID);
}

// -----------------------------------------------------------------------------
//                               Form Profiles
//                                   Public
// -----------------------------------------------------------------------------

void NUI_CreateDefaultProfile() {NUI_CreateProfile("default");}

void NUI_CreateProfile(string sProfile, string sBase = "")
{
    nui_SetProfile(sProfile);

    if (sBase != "")
        nui_CopyProfile(sBase);
}

void NUI_SetProfileBind(string sBind, string sJson)
{
    if (sBind == "" || sJson == "" || JsonParse(sJson) == JsonNull())
        return;

    nui_SetProfileBind(sBind, sJson);
}

void NUI_SetProfileBinds(string sBinds, string sJson)
{
    if (sBinds == "" || sJson == "" || JsonParse(sJson) == JsonNull())
        return;

    int n; for (n; n < CountList(sBinds); n++)
        nui_SetProfileBind(GetListItem(sBinds, n), sJson);
}

void NUI_SetProfile(object oPC, string sFormID, string sProfile)
{
    nui_SetProfileBinds(oPC, NuiFindWindow(oPC, sFormID), sFormID, sProfile);
}

string NUI_GetProfile(object oPC, string sFormID)
{
    return JsonGetString(NUI_GetBind(oPC, sFormID, "NUI_FORM_PROFILE"));
}

// -----------------------------------------------------------------------------
//                              Event Management
//                                   Private
// -----------------------------------------------------------------------------

void nui_HandleNUIEvents()
{
    object oPC = NuiGetEventPlayer();
    string sFormID = NuiGetWindowId(oPC, NuiGetEventWindow());
    string sFormfile = nui_GetDefinitionValue(sFormID, "formfile");
    nui_ExecuteFunction(sFormfile, NUI_EVENT_NUI, oPC);
}

// -----------------------------------------------------------------------------
//                              Event Management
//                                   Public
// -----------------------------------------------------------------------------

void NUI_SetBind(object oPC, string sFormID, string sBind, string sValue)
{
    NuiSetBind(oPC, NuiFindWindow(oPC, sFormID), sBind, JsonParse(sValue));
}

void NUI_DelayBind(object oPC, string sFormID, string sBind, string sValue)
{
    DelayCommand(0.001, NuiSetBind(oPC, NuiFindWindow(oPC, sFormID), sBind, JsonParse(sValue)));
}

void NUI_SetBindWatch(object oPC, string sFormID, string sBind, int bWatch = TRUE)
{
    NuiSetBindWatch(oPC, NuiFindWindow(oPC, sFormID), sBind, bWatch);
}

json NUI_GetBind(object oPC, string sFormID, string sBind)
{
    return NuiGetBind(oPC, NuiFindWindow(oPC, sFormID), sBind);
}

int NUI_GetIsFormOpen(object oPC, string sFormID)
{
    return NuiFindWindow(oPC, sFormID) > 0;
}

struct NUIEventData NUI_GetEventData()
{
    struct NUIEventData ed;

    ed.oPC        = NuiGetEventPlayer();
    ed.nToken     = NuiGetEventWindow();
    ed.sFormID    = NuiGetWindowId(ed.oPC, ed.nToken);
    ed.sEvent     = NuiGetEventType();
    ed.sControlID = NuiGetEventElement();
    ed.nIndex     = NuiGetEventArrayIndex();
    ed.jPayload   = NuiGetEventPayload();

    return ed;
}

void NUI_SubscribeEvent(int nEvent)
{
    sQuery = "UPDATE nui_forms SET definition = (SELECT json_set(definition, " +
        "'$.event_data[#]', json(@value)) FROM nui_forms WHERE form = @form) " +
        "WHERE form = @form;";
    
    sql = nui_PrepareQuery(sQuery, TRUE);
    SqlBindString(sql, "@form", nui_GetFormID());
    SqlBindInt   (sql, "@value", nEvent);
    SqlStep(sql);
}

void NUI_HandleEvents(object oPC = OBJECT_SELF)
{
    int nEvent = GetCurrentlyRunningEvent();

    if (nEvent == EVENT_SCRIPT_MODULE_ON_NUI_EVENT)
        nui_HandleNUIEvents();
    else
    {
        sQuery = "SELECT json_group_array(json_extract(nui_forms.definition, '$.formfile')) " +
            "FROM nui_forms WHERE EXISTS (SELECT 1 FROM json_each(nui_forms.definition, " +
            "'$.event_data') WHERE value = @event);";
        sql = nui_PrepareQuery(sQuery);
        SqlBindInt(sql, "@event", nEvent);

        SetLocalObject(oPC, NUI_OBJECT, OBJECT_SELF);

        if (SqlStep(sql))
        {
            json jFormfiles = SqlGetJson(sql, 0);
            int n; for (n; n < JsonGetLength(jFormfiles); n++)
                nui_ExecuteFunction(JsonGetString(JsonArrayGet(jFormfiles, n)), NUI_EVENT_MOD, oPC);
        }

        DeleteLocalObject(oPC, NUI_OBJECT);
    }
}
