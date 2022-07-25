// ---------------------------------------------------------------------------------------
//                                LANGUAGE CONFIGURATION
// ---------------------------------------------------------------------------------------

// This is the English language file supporting the Appearance Editor.

// All of the text values which are displayed on the form's controls can be modified here to
// account for various languages this form may be deployed in.

// Setting this value to TRUE will reverse the order in which the directional adjective (i.e.
// right and left) are ordered in relation to the primary object (i.e. Forearm).  For example,
// for English, the option "Right Foot" would be appropriate.  In Spanish, however, it would
// be "Pie Derecho".  For languages which have subsequent adjectives, set this value to TRUE;
int ADJECTIVE_FOLLOWS = FALSE;

// Translate the string portion of any of the following variables into whatever language your
// module will primarily be using.
string TITLE    = "Personal Appearance Editor";

string HEAD     = "Head";		// GetStringByStrRef( 123 );
string NECK     = "Neck";		// GetStringByStrRef( 7143 );
string CHEST    = "Chest/Torso";	// GetStringByStrRef( 7144 );
string PELVIS   = "Pelvis";		// GetStringByStrRef( 7145 );

string RIGHT    = "Right";
string LEFT     = "Left";

string BICEP    = "Bicep";
string FOREARM  = "Forearm";
string HAND     = "Hand";
string THIGH    = "Thigh";
string SHIN     = "Shin";
string FOOT     = "Foot";
string BELT     = "Belt";		// GetStringByStrRef( 1518 );
string SHOULDER = "Shoulder";
string HELMET   = "Helmet";		// GetStringByStrRef( 182 );
string ROBE     = "Robe";		// GetStringByStrRef( 83691 );

string RIGHT_SHOULDER = "Right Shoulder";	//  GetStringByStrRef( 7146 );
string LEFT_SHOULDER = "Left Shoulder";		//  GetStringByStrRef( 7150 );

string RIGHT_BICEP = "Right Bicep";		//  GetStringByStrRef( 7147 );
string LEFT_BICEP = "Left Bicep";		//  GetStringByStrRef( 7151 );

string RIGHT_FOREARM = "Right Forearm";		//  GetStringByStrRef( 7148 );
string LEFT_FOREARM = "Left Forearm";		//  GetStringByStrRef( 7152 );

string RIGHT_HAND = "Right Hand";		//  GetStringByStrRef( 7149 );
string LEFT_HAND = "Left Hand";			//  GetStringByStrRef( 7153 );

string RIGHT_THIGH = "Right Thigh";		//  GetStringByStrRef( 7474 );
string LEFT_THIGH = "Left Thigh";		//  GetStringByStrRef( 7477 );

string RIGHT_SHIN = "Right Shin";		//  GetStringByStrRef( 7475 );
string LEFT_SHIN = "Left Shin";			//  GetStringByStrRef( 7478 );

string RIGHT_FOOT = "Right Foot";		//  GetStringByStrRef( 7476 );
string LEFT_FOOT = "Left Foot";			//  GetStringByStrRef( 7479 );


string SKIN     = "Skin";			//  GetStringByStrRef( 13379 );
string HAIR     = "Hair";			//  GetStringByStrRef( 67432 );
string TATTOO   = "Tattoo";			//  GetStringByStrRef( 1591 );
string LEATHER  = "Leather";			//  GetStringByStrRef( 185 );

string CLOTH    = "Cloth";			//  GetStringByStrRef( 111808 );
string METAL    = "Metal";			//  GetStringByStrRef( 6736 );
string COLOR    = "Color";			//  GetStringByStrRef( 4821 );

string APPEARANCE     = "Appearance";		//  GetStringByStrRef( 2297 );
string EQUIPMENT      = "Equipment";
string NO_EQUIPMENT   = "No armor found in chest slot";
string NO_HELMET      = "No helmet found";
string CANNOT_EQUIP   = "You cannot equip the selected model";
string ARMOR          = "Armor";		//  GetStringByStrRef( 335 );
string OUTFITS        = "Outfits";

string MODEL          = "Model";		//  GetStringByStrRef( 7139 );
string PREVIOUS       = "Previous";
string NEXT           = "Next";

string TOP = "Top";				//  GetStringByStrRef( 7140 );
string MIDDLE = "Middle";                       //  GetStringByStrRef( 7141 );
string BOTTOM = "Bottom";                       //  GetStringByStrRef( 7142 );

// The previous and next labels can be too small for some translations. If you want to specify
// a value for these labels, set it here.  Setting these values to empty strings will result
// in a label comprised of NEXT + MODEL.
string NEXT_LABEL     = "";
string PREVIOUS_LABEL = "";
