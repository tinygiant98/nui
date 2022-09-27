// -----------------------------------------------------------------------------
//    File: nui_i_const.nss
//  System: Test Plugin
// -----------------------------------------------------------------------------
// Description:
//  Constants
// -----------------------------------------------------------------------------
// Builder Use:
//  None!  Leave me alone.
// -----------------------------------------------------------------------------

string NUI_VERSION = "0.1.1";

// NUI Event list
string NUI_EVENTS = "click,mousedown,mouseup,mousescroll,open,close,watch,range";

string NUI_PATH_ROOT = "root,children,-1";
string NUI_PATH_GROUP = "children,0,children,-1";
string NUI_PATH_LISTBOX = "row_template,-1";
string NUI_PATH_DRAWLIST = "draw_list,-1";

// JSON Booleans
json jTRUE = JsonBool(TRUE);
json jFALSE = JsonBool(FALSE);

const int NUI_DEBUG_SEVERITY_NONE     = 0;
const int NUI_DEBUG_SEVERITY_CRITICAL = 1;
const int NUI_DEBUG_SEVERITY_ERROR    = 2;
const int NUI_DEBUG_SEVERITY_WARNING  = 3;
const int NUI_DEBUG_SEVERITY_NOTICE   = 4;
const int NUI_DEBUG_SEVERITY_DEBUG    = 5;

// Variable names
const string NUI_BUILD_ROOT = "NUI_BUILD_ROOT";
const string NUI_BUILD_CONTROL = "NUI_BUILD_CONTROL";
const string NUI_BUILD_LAYER = "NUI_BUILD_LAYER";
const string NUI_BUILD_CONTROL_PROPERTIES = "NUI_BUILD_CONTROL_PROPERTIES";
const string NUI_BUILD_MODE = "NUI_BUILD_MODE";
const string NUI_BUILD_WRAP = "NUI_BUILD_WRAP";
const string NUI_BUILD_WINDOW = "NUI_BUILD_WINDOW";
const string NUI_CONTROL_PATH = "NUI_CONTROL_PATH";
const string NUI_EVENT_PATH = "NUI_EVENT_PATH";
const string NUI_DATA_PATH = "NUI_DATA_PATH";

// Elements (Form-based)
const string NUI_ELEMENT_SPACER = "spacer";
const string NUI_ELEMENT_LABEL = "label";
const string NUI_ELEMENT_TEXTBOX_STATIC = "text";
const string NUI_ELEMENT_COMMANDBUTTON = "button";
const string NUI_ELEMENT_IMAGEBUTTON = "button_image";
const string NUI_ELEMENT_TOGGLEBUTTON = "button_select";
const string NUI_ELEMENT_CHECKBOX = "check";
const string NUI_ELEMENT_IMAGE = "image";
const string NUI_ELEMENT_COMBOBOX = "combo";
const string NUI_ELEMENT_FLOATSLIDER = "sliderf";
const string NUI_ELEMENT_INTSLIDER = "slider";
const string NUI_ELEMENT_PROGRESSBAR = "progress";
const string NUI_ELEMENT_TEXTBOX = "textedit";
const string NUI_ELEMENT_LISTBOX = "list";
const string NUI_ELEMENT_COLORPICKER = "color_picker";
const string NUI_ELEMENT_OPTIONGROUP = "options";
const string NUI_ELEMENT_CHART = "chart";
const string NUI_ELEMENT_DRAWLIST = "draw_list";
const string NUI_ELEMENT_GROUP = "group";
const string NUI_ELEMENT_ROW = "row";
const string NUI_ELEMENT_COLUMN = "col";
const string NUI_ELEMENT_CONTROL = "control";
const string NUI_ELEMENT_CANVAS = "canvas";
const string NUI_ELEMENT_TEMPLATE = "template";

// Properties
const string NUI_PROPERTY_ELEMENTS = "elements";
const string NUI_PROPERTY_TOOLTIP = "tooltip";
const string NUI_PROPERTY_DISABLED_TOOLTIP = "disabled_tooltip";
const string NUI_PROPERTY_STRREF = "strref";
const string NUI_PROPERTY_ENCOURAGED = "encouraged";
const string NUI_PROPERTY_VISIBLE = "visible";
const string NUI_PROPERTY_ENABLED = "enabled";
const string NUI_PROPERTY_PADDING = "padding";
const string NUI_PROPERTY_MARGIN = "margin";
const string NUI_PROPERTY_ASPECT = "aspect";
const string NUI_PROPERTY_HEIGHT = "height";
const string NUI_PROPERTY_WIDTH = "width";
const string NUI_PROPERTY_FORECOLOR = "foreground_color";
const string NUI_PROPERTY_ID = "id";
const string NUI_PROPERTY_HALIGN = "text_halign";
const string NUI_PROPERTY_VALIGN = "text_valign";
const string NUI_PROPERTY_CHILDREN = "children";
const string NUI_PROPERTY_BIND = "bind";
const string NUI_PROPERTY_EVENTS = "events";
const string NUI_PROPERTY_SCROLLBARS = "scrollbars";
const string NUI_PROPERTY_VERSION = "version";
const string NUI_PROPERTY_TITLE = "title";
const string NUI_PROPERTY_ROOT = "root";
const string NUI_PROPERTY_GEOMETRY = "geometry";
const string NUI_PROPERTY_RESIZABLE = "resizable";
const string NUI_PROPERTY_COLLAPSIBLE = "collapsed";
const string NUI_PROPERTY_MODAL = "closable";
const string NUI_PROPERTY_TRANSPARENT = "transparent";
const string NUI_PROPERTY_BORDER = "border";
const string NUI_PROPERTY_TYPE = "type";
const string NUI_PROPERTY_LABEL = "label";
const string NUI_PROPERTY_VALUE = "value";
const string NUI_PROPERTY_ORIENTATION = "orientation";
const string NUI_PROPERTY_UUID = "uuid";
const string NUI_PROPERTY_MIN = "min";
const string NUI_PROPERTY_MAX = "max";
const string NUI_PROPERTY_STEP = "step";
const string NUI_PROPERTY_MULTILINE = "multiline";
const string NUI_PROPERTY_ROWTEMPLATE = "row_template";
const string NUI_PROPERTY_ROWCOUNT = "row_count";
const string NUI_PROPERTY_ROWHEIGHT = "row_height";
const string NUI_PROPERTY_DIRECTION = "direction";
const string NUI_PROPERTY_LEGEND = "legend";
const string NUI_PROPERTY_COLOR = "color";
const string NUI_PROPERTY_DATA = "data";
const string NUI_PROPERTY_FILL = "fill";
const string NUI_PROPERTY_LINETHICKNESS = "line_thickness";
const string NUI_PROPERTY_POINTS = "points";
const string NUI_PROPERTY_CTRL0 = "ctrl0";
const string NUI_PROPERTY_CTRL1 = "ctrl1";
const string NUI_PROPERTY_RECT = "rect";
const string NUI_PROPERTY_RADIUS = "radius";
const string NUI_PROPERTY_AMIN = "amin";
const string NUI_PROPERTY_AMAX = "amax";
const string NUI_PROPERTY_TEXT = "text";
const string NUI_PROPERTY_STATIC = "static";
const string NUI_PROPERTY_DRAWLIST = "draw_list";
const string NUI_PROPERTY_DRAWLISTSCISSOR = "draw_list_scissor";
const string NUI_PROPERTY_IMAGE = "image";
const string NUI_PROPERTY_IMAGEASPECT = "image_aspect";
const string NUI_PROPERTY_IMAGEHALIGN = "image_halign";
const string NUI_PROPERTY_IMAGEVALIGN = "image_valign";
const string NUI_PROPERTY_IMAGEREGION = "image_region";
const string NUI_PROPERTY_BUILDABLE = "buildable";
const string NUI_PROPERTY_POSITION = "order";
const string NUI_PROPERTY_CONDITION = "render";
const string NUI_PROPERTY_ACCEPTSINPUT = "accepts_input";

const string NUI_PROPERTY_USERDATA = "user_data";
const string NUI_PROPERTY_BINDDATA = "bind_data";
const string NUI_PROPERTY_BUILDDATA = "build_data";
const string NUI_PROPERTY_EVENTDATA = "event_data";

const string NUI_PROPERTY_BINDSCRIPT = "bind_script";
const string NUI_PROPERTY_BINDVARIABLE = "bind_variable";
const string NUI_PROPERTY_BINDSCRIPTCHUNK = "bind_script_chunk";

const string NUI_EVENT_MOUSEDOWN = "mousedown";
const string NUI_EVENT_MOUSEUP = "mouseup";
const string NUI_EVENT_MOUSESCROLL = "mousescroll";
const string NUI_EVENT_OPEN = "open";
const string NUI_EVENT_CLOSE = "close";
const string NUI_EVENT_WATCH = "watch";

const int NUI_CANVAS_POLYLINE = 0;
const int NUI_CANVAS_CURVE = 1;
const int NUI_CANVAS_CIRCLE = 2;
const int NUI_CANVAS_ARC = 3;
const int NUI_CANVAS_TEXT = 4;
const int NUI_CANVAS_IMAGE = 5;
const int NUI_CANVAS_LINE = 6;

const int NUI_POSITION_BELOW = -1;
const int NUI_POSITION_ABOVE = 1;

const int NUI_CONDITION_ALWAYS = 0;
const int NUI_CONDITION_MOUSE_OFF = 1;
const int NUI_CONDITION_MOUSE_HOVER = 2;
const int NUI_CONDITION_MOUSE_LEFT = 3;
const int NUI_CONDITION_MOUSE_RIGHT = 4;
const int NUI_CONDITION_MOUSE_MIDDLE = 5;

const int NUI_CHART_LINE = 0;
const int NUI_CHART_BAR = 1;

const string NUI_CURRENT_FORMFILE = "NUI_CURRENT_FORMFILE";
const string NUI_CURRENT_CONTROLFILE = "NUI_CURRENT_CONTROLFILE";
const string NUI_CURRENT_OPERATION = "NUI_CURRENT_OPERATION";
const int NUI_OPERATION_NONE = 0;
const int NUI_OPERATION_BUILD = 1;
const int NUI_OPERATION_BIND = 2;
const int NUI_OPERATION_EVENT = 3;
const int NUI_OPERATION_DEFINE = 4;

const string NUI_PROPERTY_C = "c";
const string NUI_PROPERTY_X = "x";
const string NUI_PROPERTY_Y = "y";
const string NUI_PROPERTY_W = "w";
const string NUI_PROPERTY_H = "h";
const string NUI_PROPERTY_R = "r";
const string NUI_PROPERTY_G = "g";
const string NUI_PROPERTY_B = "b";
const string NUI_PROPERTY_A = "a";

const string NUI_ORIENTATION_COLUMNS = "columns";
const string NUI_ORIENTATION_ROWS = "rows";
const string NUI_ORIENTATION_HORIZONTAL = "0";
const string NUI_ORIENTATION_VERTICAL = "1";

const string NUI_TREE_VALUE = "value";

const string NUI_BIND_PC = "_pc_";
const string NUI_BIND_MODULE = "_module_";
const string NUI_FORM = "_form_";
const string NUI_NOBIND = "_nobind_";
const string NUI_WINDOW = "_window_";

const string NUI_BIND_DATA = "NUI_BIND_DATA";

const string NUI_BIND_FORM = "form_id";
const string NUI_BIND_TOKEN = "token";
const string NUI_BIND_BINDS = "binds";
const string NUI_BIND_COUNT = "count";

const string NUI_BIND_TYPE = "control_type";
const string NUI_BIND_VARIABLE = "bind_variable";
const string NUI_BIND_PROPERTY = "control_property";
const string NUI_BIND_USERDATA = "user_data";
const string NUI_BIND_VALUE = "value";
const string NUI_BIND_CONTROLID = "control_id";

// Niv's constants
const int NUI_ASPECT_FIT                   = 0;
const int NUI_ASPECT_FILL                  = 1;
const int NUI_ASPECT_FIT100                = 2;
const int NUI_ASPECT_EXACT                 = 3;
const int NUI_ASPECT_EXACTSCALED           = 4;
const int NUI_ASPECT_STRETCH               = 5;

const int NUI_SCROLLBARS_NONE              = 0;
const int NUI_SCROLLBARS_X                 = 1;
const int NUI_SCROLLBARS_Y                 = 2;
const int NUI_SCROLLBARS_BOTH              = 3;
const int NUI_SCROLLBARS_AUTO              = 4;

const int NUI_HALIGN_CENTER                = 0;
const int NUI_HALIGN_LEFT                  = 1;
const int NUI_HALIGN_RIGHT                 = 2;

const int NUI_VALIGN_MIDDLE                = 0;
const int NUI_VALIGN_TOP                   = 1;
const int NUI_VALIGN_BOTTOM                = 2;