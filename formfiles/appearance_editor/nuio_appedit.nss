// ---------------------------------------------------------------------------------------
//                         APPEARANCE EDITOR CONFIGURATION FILE
// ---------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
//                                LANGUAGE CONFIGURATION
// ---------------------------------------------------------------------------------------

// Place the include directive here for the language file you'll be using.  The language
// file should be named nuil_appedit_xx.nss, where xx represents the ISO 639-1 standard
// langauge code.  See the notes in each language file for system requirements, encoding
// and game settings to ensure that language displays correctly.
#include "nuil_appedit_en"

// ---------------------------------------------------------------------------------------
//                                DATABASE CONFIGURATION
// ---------------------------------------------------------------------------------------

// This form uses a lot of model-specific data that does not change much.  To keep this data
// available without constantly reloading it, you can save it to a campaign db and reload
// it only when data changes.  To use a campaign database, set this value to TRUE.  If this
// value is FALSE, model appearances will be loaded into the module's sqlite database on each
// module load and the LOAD_MODEL_DATA variable below will have no effect.
int USE_CAMPAIGN_DATABASE = TRUE;

// If using the campaign database, the model data can be saved to a different database than
// set in nui_i_database.nss.  Set this value to the name of the campaign database to save
// all model data.  If this value is left blank, the nui system's campaign database setting
// will be used.
string CAMPAIGN_DATABASE = "";

// Whether the model data is saved into a campaign database or module sqlite database, set
// these values to the tables names to be used for simple/layered models, composite models,
// and armor/personal appearance models.
string DATABASE_TABLE_SIMPLE = "nuif_appedit_simple";
string DATABASE_TABLE_COMPOSITE = "nuif_appedit_composite";
string DATABASE_TABLE_ARMOR = "nuif_appedit_armor";

// ---------------------------------------------------------------------------------------
//                                MODEL DATA CONFIGURATION
// ---------------------------------------------------------------------------------------

// *** WARNING *** There is a very high chance (somewhere around 100.000%) that the routines
// for loading appearances will hit the instruction limit.  So, if you're running NWNX,
// raise the instruction limit.  If you're running the base game, set it to the highest
// possible setting in the game options.  You can limit the number of loops the system
// must make by modifying the following variables.  This is VERY ADVANCED USAGE, so if you
// don't know what to do here, just leave them all at "".  Running the appearance generation
// code during the module startup process may take more than a minute, so please be patient.
// If model data is being saved to the campaign database (see database settings above), this
// value can be set to FALSE *AFTER* the first time the form is defined in your module and
// all model data is saved.
int LOAD_MODEL_DATA = FALSE;

// This system sources the gender identifiers from the GENDER column in gender.2da.  If you're
// not using all the genders contains in gender.2da, set this value to a comma-delimited list
// of genders you are using.  The default value is "m,f" which represents male and female.
string MODEL_GENDER = "m,f";

// This system sources the race identifiers from the RACE column in appearance.2da.  If you're
// not using all the possible playable races (see the PLAYERRACE column in racialtypes.2da),
// set this value toa  comma-delimited list of races you are using.  These should be the race
// identifier letters as found in appearance.2da.  For example, in the base game, d = dwarf.
// Do not repeat letters, all entries should be unique.  This will normally be left as a blank
// string.
string MODEL_RACE = "";

// This system sources the phenotype identifiers from the index column of phenotype.2da.  If you're
// not using all the possible phenotypes, set this value to a comma-delimited list of phenotypes
// you are using.  These should be integers from the first column of phenotype.2da.  The default
// for this is "0,2" which represent 'Normal' and 'Large' phenotypes.
string MODEL_PHENOTYPE = "0,2";

// This system sources the potential creature parts from the MDLNAME columns of capart.2da.  If you're
// not using all the possible parts, set this value to a comma-delimited list of parts you
// are using.  These values need to match the naming scheme for model parts (handl, shinr, etc.).
// Typically, this will be left as a blank string.
string MODEL_PARTS = "";
