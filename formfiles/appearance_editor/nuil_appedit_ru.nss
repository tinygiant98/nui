// ---------------------------------------------------------------------------------------
//                                LANGUAGE CONFIGURATION
// ---------------------------------------------------------------------------------------

// This is the Russian language file supporting the Appearance Editor.  This translation file
// was provided by Siala. 

// *** This file must be encoded in Cyrillic (Windows 1251) and the codepage option in the
// game's settings.tml must be set to "cp1251" for this to work correctly. ***

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
string TITLE    = "Редактор внешнего вида";

string HEAD     = "Голова";
string NECK     = "Шея";
string CHEST    = "Грудь";
string PELVIS   = "Таз";
string RIGHT    = "Правый";
string LEFT     = "Левый";
string BICEP    = "Бицепс";
string FOREARM  = "Предплечье";
string HAND     = "Кисть";
string THIGH    = "Бедро";
string SHIN     = "Голень";
string FOOT     = "Стопа";
string BELT     = "Пояс";
string SHOULDER = "Плечо";
string HELMET   = "Шлем";
string ROBE     = "Роба";

string SKIN     = "Кожа";
string HAIR     = "Волосы";
string TATTOO   = "Татуировка";
string LEATHER  = "Кожа";
string CLOTH    = "Ткань";
string METAL    = "Металл";
string COLOR    = "Цвет";

string APPEARANCE   = "Аппиренс";
string EQUIPMENT    = "Экипировка";
string NO_EQUIPMENT = "Не найдено нагрудника";
string NO_HELMET    = "Не найден шлем";
string CANNOT_EQUIP = "Вы не можете надеть выбранную модель";
string ARMOR        = "Броня";
string OUTFITS      = "Внешний вид";

string MODEL        = "Модель";
string PREVIOUS     = "Предыдущий";
string NEXT         = "Следующий";

// The previous and next labels can be too small for some translations. If you want to specify
// a value for these labels, set it here.  Setting these values to empty strings will result
// in a label comprised of PREVIOUS + MODEL and NEXT + MODEL.
string PREVIOUS_LABEL = "< " + PREVIOUS;
string NEXT_LABEL     = NEXT + " >";
