/// ----------------------------------------------------------------------------
/// @file   nuif_f_template.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Template formfile
/// ----------------------------------------------------------------------------

#include "nui_i_library"
#include "util_i_csvlists"
#include "util_i_debug"

const string FORM_ID = "demo";
const string VERSION = "0.1.0";
const string IGNORE_FORM_EVENTS = "";

void DefineForm()
{
    float w = 145.;
    float h = 25.;

    float wGroup = w + 15.0;

    string sTitle = NUI_DefineHexColor(COLOR_CYAN);

    //Form Definition
    NUI_CreateForm(FORM_ID);    
        NUI_SetTOCTitle("Demo");
    {  
        NUI_AddColumn();
            NUI_AddRow();
                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup, 100.0);
                    {
                        NUI_AddColumn();
                            NUI_AddLabel();
                                NUI_SetLabel("Labels");
                                NUI_SetTooltip("This is a regular old, center-aligned label");
                                NUI_SetHorizontalAlignment(NUI_HALIGN_CENTER);
                                NUI_SetWidth(w);
                                NUI_SetHeight(h);
                                NUI_SetForegroundColor(sTitle);

                            NUI_AddLabel();
                                NUI_SetEnabled(FALSE);
                                NUI_SetDisabledTooltip("This label is disabled and left-aligned");
                                NUI_SetLabel("Disabled Label");
                                NUI_SetHorizontalAlignment(NUI_HALIGN_LEFT);
                                NUI_SetWidth(w);
                                NUI_SetHeight(h);

                            NUI_AddLabel();
                                NUI_SetEncouraged(TRUE);
                                NUI_SetTooltip("This label is encouraged and right-aligned");
                                NUI_SetLabel("Encouraged Label");
                                NUI_SetHorizontalAlignment(NUI_HALIGN_RIGHT);
                                NUI_SetWidth(w);
                                NUI_SetHeight(h);
                        NUI_CloseColumn();
                    } NUI_CloseGroup();

                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup, 285.0);
                    {
                        NUI_AddColumn();
                            NUI_AddLabel();
                                NUI_SetLabel("Buttons");
                                NUI_SetDimensions(w, h);
                                NUI_SetForegroundColor(sTitle);

                            NUI_AddCommandButton();
                                NUI_SetLabel("Command Button");
                                NUI_SetDimensions(w, h);
                                NUI_SetTooltip("Normal command button");

                            NUI_AddCommandButton();
                                NUI_SetLabel("Disabled");
                                NUI_SetDisabledTooltip("Disabled command button");
                                NUI_SetDimensions(w, h);
                                NUI_SetEnabled(FALSE);

                            NUI_AddCommandButton();
                                NUI_SetLabel("Encouraged");
                                NUI_SetTooltip("Encouraged command button");
                                NUI_SetDimensions(w, h);
                                NUI_SetEncouraged();

                            NUI_AddToggleButton();
                                NUI_SetLabel("Toggle Button");
                                NUI_BindValue("tglButton");
                                NUI_SetTooltip("Toggle Button - Click me!");
                                NUI_SetDimensions(w, h);

                            NUI_AddImageButton();
                                NUI_SetResref("beamdoge");
                                NUI_SetDimensions(w, h + 100.0);
                                NUI_SetTooltip("Image button");
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                wGroup += 100.0;

                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup, 190.0);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Sliders and Progress Bar");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddIntSlider();
                                NUI_SetDisabledTooltip("Disabled Integer-based slider");
                                NUI_SetWidth(wGroup - 20.0);
                                NUI_SetValue(nuiInt(82));
                                NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_ORANGE));
                                NUI_SetIntSliderBounds(0, 100, 1);
                                NUI_SetEnabled(FALSE);

                            NUI_AddFloatSlider();
                                NUI_SetTooltip("Float-based slider");
                                NUI_SetWidth(wGroup - 20.0);
                                NUI_BindValue("floatSlider");
                                NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_RED));
                                NUI_SetFloatSliderBounds(0.0, 1.0, 0.1);

                            NUI_AddProgressBar();
                                NUI_SetValue(nuiFloat(0.76));
                                NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_YELLOW));
                                NUI_SetHeight(25.0);
                                NUI_SetTooltip("Progress bar at 76%, and encouraged");
                                NUI_SetEncouraged();

                            NUI_AddProgressBar();
                                NUI_SetValue(nuiFloat(0.25));
                                NUI_SetForegroundColor(NUI_DefineHexColor(COLOR_GREEN_LIGHT));
                                NUI_SetHeight(35.0);
                                NUI_SetTooltip("Progress bar at 25%");

                        NUI_CloseColumn();
                    } NUI_CloseGroup();

                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup, 195.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Color Picker");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddRow();
                                NUI_AddSpacer();
                                    NUI_SetWidth(10.0);

                                NUI_AddColorPicker();
                                    NUI_SetDimensions(wGroup - 20.0, 140.0);
                                    NUI_BindValue("cp");

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddSpacer();
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup, 300.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Textboxes");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddTextbox();
                                NUI_SetStatic();
                                NUI_SetTooltip("Static texbox, much like a label, but with a border");
                                NUI_SetValue(nuiString("This is a static textbox.  You can't type in it, but it supports " +
                                    "word-wrapping, scrollbars, etc."));
                                NUI_SetHeight(100.0);

                            NUI_AddTextbox();
                                NUI_BindValue("txt");
                                NUI_SetPlaceholder("Type here!");
                                NUI_SetTooltip("Dynaimic textbox with placeholder");
                                NUI_SetMultiline(TRUE);
                                NUI_SetWordWrap(TRUE);
                        NUI_CloseColumn();
                    } NUI_CloseGroup();

                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup, 85.0);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Combobox");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();
                            
                            NUI_AddCombobox();
                                NUI_BindValue("combo");
                                NUI_SetElements("Option 1,Option 2,Option 3,Option 4,Option 5");
                                NUI_SetWidth(wGroup - 10.0);

                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup, 200.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Listbox");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddListbox();
                                NUI_SetRowHeight(25.0);
                                NUI_BindRowCount("lstLabel");
                                NUI_SetHeight(150.0);
                            {
                                NUI_AddLabel();
                                    NUI_BindValue("lstLabel");
                            } NUI_CloseListbox();
                        NUI_CloseColumn();
                    } NUI_CloseGroup();

                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup, 185.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Checkboxes");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddCheckbox();
                                NUI_BindValue("chk1");
                                NUI_SetLabel("I'm a checkbox");

                            NUI_AddCheckbox();
                                NUI_BindValue("chk2");
                                NUI_SetLabel("Disabled checkbox");
                                NUI_SetEnabled(FALSE);

                            NUI_AddCheckbox();
                                NUI_BindValue("chk3");
                                NUI_SetLabel("Encouraged checkbox");
                                NUI_SetEncouraged(TRUE);
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();
            NUI_CloseRow();

            wGroup -= 75.0;

            NUI_AddRow();
                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup + 10., 210.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Image");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddImage();
                                NUI_SetDimensions(wGroup - 10.0, 150.0);
                                NUI_SetResref("beamdoge");
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup + 10., 210.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Vertical Option Group");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddOptionGroup();
                                NUI_SetElements("Option 1, Option 2, Option 3, Option 4");
                                NUI_SetDirection(NUI_ORIENTATION_COLUMN);
                                NUI_BindValue("tglVertOption");
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup, 210.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Vertical Toggle Group");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddToggleGroup();
                                NUI_SetElements("Option 1, Option 2, Option 3, Option 4");
                                NUI_SetDirection(NUI_ORIENTATION_COLUMN);
                                NUI_SetWidth(wGroup - 10.0);
                                NUI_BindValue("tglVertToggle");
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup + 130.0, 210.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Horizontal Option Group");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddOptionGroup();
                                NUI_SetElements("Option 1, Option 2");
                                NUI_BindValue("tglHorizOption");

                            NUI_AddSpacer();
                                NUI_SetHeight(20.0);

                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Horizontal Toggle Group");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddToggleGroup();
                                NUI_SetElements("Option 1, Option 2");
                                NUI_SetWidth(wGroup - 15.0);
                                NUI_BindValue("tglHorizToggle");
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();
            NUI_CloseRow();

            NUI_AddRow();
                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup + 130.0, 210.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Line Chart");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddChart();
                                NUI_SetDimensions(wGroup + 120.0, 150.0);
                                NUI_SetChartSeries(NUI_CHART_LINE, "Series 1", NUI_DefineHexColor(COLOR_BLUE_LIGHT), "[10,5,7,9,12,4]");
                                NUI_SetChartSeries(NUI_CHART_LINE, "Series 2", NUI_DefineHexColor(COLOR_YELLOW), "[5,9,12,14,0,6]");
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup + 130.0, 210.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Bar Chart");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddChart();
                                NUI_SetDimensions(wGroup + 120.0, 150.0);
                                NUI_SetChartSeries(NUI_CHART_BAR, "Series 1", NUI_DefineHexColor(COLOR_YELLOW), "[3,5,-7,9,12,-4]");
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();

                NUI_AddColumn();
                    NUI_AddGroup();
                        NUI_SetDimensions(wGroup + 130.0, 210.0);
                        NUI_SetScrollbars(NUI_SCROLLBARS_NONE);
                    {
                        NUI_AddColumn();
                            NUI_AddRow();
                                NUI_AddSpacer();

                                NUI_AddLabel();
                                    NUI_SetLabel("Movie Player");
                                    NUI_SetForegroundColor(sTitle);
                                    NUI_SetDimensions(w + 30.0, h);

                                NUI_AddSpacer();
                            NUI_CloseRow();

                            NUI_AddMoviePlayer();
                                NUI_SetResref("nwnintro");
                        NUI_CloseColumn();
                    } NUI_CloseGroup();
                NUI_CloseColumn();
            NUI_CloseRow();
        NUI_CloseColumn();
    }

    // Profile Definition
    NUI_CreateDefaultProfile();
    {
        NUI_SetProfileBind("geometry", NUI_DefineRectangle(100.0, 100.0, 990.0, 900.0));
    }
}

void BindForm()
{
    json jBinds = NUI_GetOrphanBinds(FORM_ID);
    int nToken = NuiFindWindow(OBJECT_SELF, FORM_ID);

    int n; for (n; n < JsonGetLength(jBinds); n++)
    {
        string sValue, sBind = JsonGetString(JsonArrayGet(jBinds, n));
        json jValue = JsonNull();

        if (sBind == "intSlider")
            sValue = nuiInt(76);
        else if (sBind == "floatSlider")
            sValue = nuiFloat(0.25);
        else if (sBind == "cp")
            sValue = NUI_DefineRandomColor();
        else if (sBind == "lstLabel")
            jValue = ListToJson("List Entry 1,List Entry 2,List Entry 3,List Entry 4," +
                "List Entry 5,List Entry 6,List Entry 7,List Entry 8,List Entry 9");
        else if (sBind == "chk1")
            sValue = nuiBool(TRUE);
        else if (sBind == "title")
            sValue = nuiString("NUI Demo Form -- All Controls");

        if (sValue != "")
            NUI_SetBind(OBJECT_SELF, FORM_ID, sBind, sValue);
        else if (jValue != JsonNull())
            NUI_SetBindJ(OBJECT_SELF, FORM_ID, sBind, jValue);
    }
}

void HandleNUIEvents()
{
    struct NUIEventData ed = NUI_GetEventData();

}

void HandleModuleEvents()
{

}
