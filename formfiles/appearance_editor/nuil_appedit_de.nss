// ---------------------------------------------------------------------------------------
//                                LANGUAGE CONFIGURATION
// ---------------------------------------------------------------------------------------

// This is the German language file supporting the Appearance Editor.  This translation file
// was provided by dunahan. 

// *** This file must be encoded in Western (ISO 8859-15) for this to work correctly. ***

// *** IF ANY CHANGES ARE MADE TO THIS FILE, ENSURE IT IS SAVED WITH THE CORRECT ENCODING OR 
// SOME TRANSLATION DATA MAY BE LOST ***  If you're using VSCode as your primary editor, you
// can select "Auto Guess Encoding" and this file *should* open and save with the correct
// encoding

// All of the text values which are displayed on the form's controls can be modified here to
// account for various languages this form may be deployed in.

// Setting this value to TRUE will reverse the order in which the directional adjective (i.e.
// right and left) are ordered in relation to the primary object (i.e. Forearm).  For example,
// for English, the option "Right Foot" would be appropriate.  In Spanish, however, it would
// be "Pie Derecho".  For languages which have subsequent adjectives, set this value to TRUE;
int ADJECTIVE_FOLLOWS = FALSE;

// Translate the string portion of any of the following variables into whatever language your
// module will primarily be using.
string TITLE    = "Editiere das Erscheinungsbild";

string HEAD     = "Kopf";
string NECK     = "Nacken";
string CHEST    = "Brust/Torso";
string PELVIS   = "Becken";
string RIGHT    = "Rechter";
string LEFT     = "Linker";
string BICEP    = "Bizeps/Oberarm";
string FOREARM  = "Unterarm";
string HAND     = "Hand";
string THIGH    = "Oberschenkel";
string SHIN     = "Unterschenkel";
string FOOT     = "Fuss";
string BELT     = "Gürtel";
string SHOULDER = "Schulter";
string HELMET   = "Helm";
string ROBE     = "Robe";

string SKIN     = "Haut";
string HAIR     = "Haar";
string TATTOO   = "Tattoo";
string LEATHER  = "Leder";
string CLOTH    = "Stoff";
string METAL    = "Metall";
string COLOR    = "Farbe";

string APPEARANCE     = "Aussehen";
string EQUIPMENT      = "Ausrüstung";
string NO_EQUIPMENT   = "Es wurde keine Rüstung im Torso Slot gefunden";
string NO_HELMET      = "Kein Helm gefunden";
string CANNOT_EQUIP   = "Du kannst das gewählte Modell nicht ausrüsten";
string ARMOR          = "Rüstung";
string OUTFITS        = "Kleidungsstück";

string MODEL          = "Modell";
string PREVIOUS       = "Zurück";
string NEXT           = "Weiter";

// The previous and next labels can be too small for some translations. If you want to specify
// a value for these labels, set it here.  Setting these values to empty strings will result
// in a label comprised of NEXT + MODEL.
string PREVIOUS_LABEL = "< " + PREVIOUS;
string NEXT_LABEL     = NEXT + " >";
