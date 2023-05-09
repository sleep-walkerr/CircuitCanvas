//----------------------------------------------------
// Dr. Art Hanna
// Simple Digital Logic Simulator
//    04.18.2015 Added "additional information" specifics to SDLS runtime 
//          exception and changed LINELENGTH to 512, IDENTIFIERLENGTH to 64
// SDLS.h
//----------------------------------------------------
#ifndef SDLS_H
#define SDLS_H

#include <cstdio>
#include <cstdlib>
#include <cctype>
#include <cstring>

using namespace std;

#define LINELENGTH               512
#define IDENTIFIERLENGTH          64
#define EOL                        1
#define MAXIMUMCOMPONENTS        500
#define MAXIMUMALIASES          1000
#define MAXIMUMCONNECTIONS      2000
#define MAXIMUMINOUTS             64
#define INS      MAXIMUMCOMPONENTS+2
#define OUTS     MAXIMUMCOMPONENTS+3
#define POWERX   MAXIMUMCOMPONENTS+4
#define GROUNDX  MAXIMUMCOMPONENTS+5
#define MAXIMUMINPINS             50

enum STATE { ON,OFF,UNK };

#ifndef ONSTRING
   #define ONSTRING  " ON"
#endif

#ifndef OFFSTRING
   #define OFFSTRING "OFF"
#endif

#ifndef UNKSTRING
   #define UNKSTRING "UNK"
#endif
 
/*
<circuit>    ::= COMPONENTS
                    <component> { <component> }*
               [ ALIASES
                    <alias> { <alias> }* ]
                 CONNECTIONS
                    <connection> { <connection> }*
                 END
<component>  ::= <gate> | <latch> | <buffer>
<gate>       ::= (( AND | NAND | OR | NOR | XOR )) [ *<integer> ] <identifier>
               | NOT <identifier>
<latch>      ::= LATCH <identifier>
<buffer>     ::= BUFFER <identifier>
<alias>      ::= <identifier> = <node>
<connection> ::= <node> - <node>
<node>       ::= POWER | GROUND
               | <identifier>
               |  IN#<integer> 
               | OUT#<integer>
               | <identifer>#<integer>
<identifier> ::= <letter> { (( <letter> | <digit> )) }*
<integer>    ::= <digit> { <digit> }*
<letter>     ::= A | B | ... | Z | a | b | ... | z
<digit>      ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
<character>  ::= Any printable ASCII character
<comment>    ::= $ { <character> }*
*/

//----------------------------------------------------
enum TOKEN
//----------------------------------------------------
{
// Pseudoterminals
   IDENTIFIER,INTEGER,EOFX,UNKNOWN,
// Reserved words
   COMPONENTS,
   ALIASES,
   CONNECTIONS,
   END,
   AND,NAND,OR,NOR,XOR,NOT,LATCHX,BUFFERX,
   IN,
   OUT,
   POWER,
   GROUND,
// Delimiters
   STAR,  /*  * */
   POUND, /*  # */
   DASH,  /*  - */
   EQUAL  /*  = */
};

//----------------------------------------------------
enum ERROR
//----------------------------------------------------
{
// Syntax Errors
   EXPECTING_COMPONENTS         =  1,
   EXPECTING_CONNECTIONS        =  2,
   EXPECTING_END                =  3,
   EXPECTING_COMPONENTTYPE      =  4,
   EXPECTING_IDENTIFIER         =  5,
   MULTIPLY_DEFINED_IDENTIFIER  =  6,
   EXPECTING_POUND              =  7,
   EXPECTING_INTEGER            =  8,
   ILLEGAL_COMPONENT_PIN        =  9,
   EXPECTING_NODE               = 10,
   UNDEFINED_IDENTIFIER         = 11,
   EXPECTING_INOROUT            = 12,
   EXPECTING_EQUAL              = 13,
   ILLEGAL_CONNECTION           = 14,
   ILLEGAL_NUMBER_OF_INPUT_PINS = 15,
   EXPECTING_DASH               = 16,
// Runtime Errors
   ERROR_OPENING_SOURCE_FILE    = 20,
   ERROR_OPENING_LOG_FILE       = 21,
   ILLEGAL_INOUT_INTEGER        = 22,
   ILLEGAL_INOUT_ALIAS          = 23,
   ERROR_OPENING_TESTS_FILE     = 24,
   NOTUSED
};

//----------------------------------------------------
const char errorMessages[][60+1] =
//----------------------------------------------------
{
//  123456789012345678901234567890123456789012345678901234567890
   "**(Not used)",
// Syntax Errors (look in .log file for more specifics)
   " 1Expecting reserved word COMPONENTS",
   " 2Expecting reserved word CONNECTIONS",
   " 3Expecting reserved word END",
   " 4Expecting type AND,NAND,OR,NOR,XOR,NOT,LATCH or BUFFER",
   " 5Expecting identifier",
   " 6Multiply defined identifier",
   " 7Expecting #",
   " 8Expecting integer",
   " 9Illegal component pin",
   "10Expecting IN, OUT, POWER, GROUND or identifier",
   "11Undefined identifier",
   "12Expecting IN or OUT",
   "13Expecting =",
   "14Illegal connection",
   "15Number of IN pins must be in [2,50]",
   "16Expecting -",
   "17(Reserved for future use)",
   "18(Reserved for future use)",
   "19(Reserved for future use)",
// Runtime Errors (additionalInformation provides more specifics)
   "20Error opening source file",
   "21Error opening log file",
   "22Illegal IN# or OUT#",
   "23Illegal alias for IN# or OUT#",
   "24Error opening tests file",
   "**(Not used)"
};

//********************
class SDLSEXCEPTION
//********************
{
protected:
   ERROR error;
   char errorMessage[60+1];
public:
   SDLSEXCEPTION(ERROR error,const char additionalInformation[] = "")
   {
      this->error = error;
      strcpy(this->errorMessage,&errorMessages[error][2]);
      if ( strlen(additionalInformation) != 0 )
      {
         strcat(this->errorMessage,"[");
         strcat(this->errorMessage,additionalInformation);
         strcat(this->errorMessage,"]");
      }
   }

   char *GetErrorMessage()
   {
      return( errorMessage );
   }
};

//********************
class COMPONENT
//********************
{
friend class CIRCUIT;

protected:
   char identifier[IDENTIFIERLENGTH+1];
   TOKEN type;                    // AND,NAND,OR,NOR,XOR,NOT,LATCHX,BUFFERX
   int numberOfINPins;
   STATE pins[MAXIMUMINPINS+1];   // pins[1..numberOfINPins] are input pins (pins[0] is ignored)
                                  // pins[numberOfINPins+1] virtual (i.e., computed) output pin

public:
   COMPONENT(const char identifier[],TOKEN type,int numberOfINPins)
   {
      strcpy(this->identifier,identifier);
      this->type = type;
      this->numberOfINPins = numberOfINPins;
   }

   TOKEN GetType()
   {
      return( type );
   }

   void SetINPinsToUNK()
   {
      for (int i = 1; i <= numberOfINPins; i++)
         pins[i] = UNK;
   }

   void SetINPin(int integer,STATE state)
   {
      if ( integer <= numberOfINPins )
         pins[integer] = state;
   }

   bool IsINPin(int integer)
   {
      return ( integer <= numberOfINPins );
   }

   bool IsOUTPin(int integer)
   {
      return ( integer == (numberOfINPins+1) );
   }

   bool AnyUNK()
   {
      bool r = false;

      for (int i = 1; i <= numberOfINPins; i++)
         r = r || (pins[i] == UNK);
      return( r );
   }

   virtual STATE GetPin(int integer) = 0;
};

//********************
class LATCH: public COMPONENT
//********************
{
protected:
   STATE state;

public:
   LATCH(const char identifier[]):
      COMPONENT(identifier,LATCHX,4)
   {
      state = OFF;
   }

   ~LATCH(){}
/*
Pin#1  Pin#2  Pin#3  Pin#4             Pin#5
    D     CK    Set  Clear  State Changes To
  Any    Any    ON     OFF       ON
  Any    Any    OFF    ON        OFF
  ON     ON     OFF    OFF       ON
  OFF    ON     OFF    OFF       OFF
  Any    OFF    OFF    OFF       Not changed
  Any    Any    ON     ON        Not changed
  
Any means either ON or OFF
*/
   STATE GetPin(int integer)
   {
      STATE r;

      if      ( integer <= numberOfINPins )
         r = pins[integer];
      else if ( integer == (numberOfINPins+1) )
      {
         if ( AnyUNK() )
            r = UNK;
         else
         {
            if      ( (pins[1] != UNK) &&  (pins[2] != UNK) &&  (pins[3] ==  ON) && (pins[4] == OFF) )
               state =  ON;
            else if ( (pins[1] != UNK) &&  (pins[2] != UNK) &&  (pins[3] == OFF) && (pins[4] ==  ON) )
               state = OFF;
            else if ( (pins[1] ==  ON) &&  (pins[2] ==  ON) &&  (pins[3] == OFF) && (pins[4] == OFF) )
               state =  ON;
            else if ( (pins[1] == OFF) &&  (pins[2] ==  ON) &&  (pins[3] == OFF) && (pins[4] == OFF) )
               state = OFF;
            else if ( (pins[1] != UNK) &&  (pins[2] == OFF) &&  (pins[3] == OFF) && (pins[4] == OFF) )
               /* State not changed*/;
            else/*if ( (pins[1] != UNK) &&  (pins[2] != UNK) &&  (pins[3] ==  ON) && (pins[4] ==  ON) )*/
               /* State not changed*/;
            r = state;
         }
      }
      else
         r = UNK;
      return( r );
   }
};

//********************
class BUFFER: public COMPONENT
//********************
{
friend class CIRCUIT;

protected:
   BUFFER(const char identifier[]):
      COMPONENT(identifier,BUFFERX,2) {}

   ~BUFFER(){}
/*
 Pin#1   Pin#2   Pin#3
DataIn Control DataOut
   ON      ON      ON
   OFF     ON      OFF
   Any     OFF     UNK
*/
   STATE GetPin(int integer)
   {
      STATE r;

      if      ( integer <= numberOfINPins )
         r = pins[integer];
      else if ( integer == (numberOfINPins+1) )
         if      ( (pins[1] ==  ON) &&  (pins[2] ==  ON) )
            r =  ON;
         else if ( (pins[1] == OFF) &&  (pins[2] ==  ON) )
            r = OFF;
         else if ( (pins[1] != UNK) &&  (pins[2] == OFF) )
            r = UNK;
         else
            r = UNK;
      else
         r = UNK;
      return( r );
   }
};

//********************
class GATE: public COMPONENT
//********************
{
friend class CIRCUIT;

protected:
public:
   GATE(const char identifier[],TOKEN type,int numberOfINPins = 1): 
      COMPONENT(identifier,type,numberOfINPins) {}

   ~GATE(){}
/*
  a    b  a AND b  a NAND b  a OR b  a NOR b  a XOR b  NOT a
OFF  OFF      OFF       ON      OFF      ON      OFF     ON
OFF  ON       OFF       ON      ON       OFF     ON      ON
ON   OFF      OFF       ON      ON       OFF     ON      OFF
ON   ON       ON        OFF     ON       OFF     OFF     OFF
ON   UNK      UNK       UNK     ON       OFF     UNK     OFF
OFF  UNK      OFF       ON      UNK      UNK     UNK     ON
UNK  ON       UNK       UNK     ON       OFF     UNK     UNK
UNK  OFF      OFF       ON      UNK      UNK     UNK     UNK

Inherited from parent class COMPONENT
   virtual STATE GetPin(int integer) = 0;
*/
   bool AllON()
   {
      bool r = true;

      for (int i = 1; i <= numberOfINPins; i++)
         r = r && (pins[i] == ON);
      return( r );
   }

   bool AllOFF()
   {
      bool r = true;

      for (int i = 1; i <= numberOfINPins; i++)
         r = r && (pins[i] == OFF);
      return( r );
   }

   bool AnyON()
   {
      bool r = false;

      for (int i = 1; i <= numberOfINPins; i++)
         r = r || (pins[i] == ON);
      return( r );
   }

   bool AnyOFF()
   {
      bool r = false;

      for (int i = 1; i <= numberOfINPins; i++)
         r = r || (pins[i] == OFF);
      return( r );
   }
};

//********************
class ANDGATE: public GATE
//********************
{
public:
   ANDGATE(const char identifier[],int numberOfINPins): GATE(identifier,AND,numberOfINPins) {}

   STATE GetPin(int integer)
   {
      STATE r;

      if      ( integer <= numberOfINPins )
         r = pins[integer];
      else if ( integer == (numberOfINPins+1) )
         if ( AnyUNK() )
            r = UNK;
         else
            r = AllON() ? ON : OFF;
      else
         r = UNK;
      return( r );
   }
};

//********************
class NANDGATE: public GATE
//********************
{
public:
   NANDGATE(const char identifier[],int numberOfINPins): GATE(identifier,NAND,numberOfINPins) {}

   STATE GetPin(int integer)
   {
      STATE r;

      if      ( integer <= numberOfINPins )
         r = pins[integer];
      else if ( integer == (numberOfINPins+1) )
         if ( AnyUNK() )
            r = UNK;
         else
            r = AllON() ? OFF : ON;
      else
         r = UNK;
      return( r );
   }
};

//********************
class ORGATE: public GATE
//********************
{
public:
   ORGATE(const char identifier[],int numberOfINPins): GATE(identifier,OR,numberOfINPins) {}

   STATE GetPin(int integer)
   {
      STATE r;

      if      ( integer <= numberOfINPins )
         r = pins[integer];
      else if ( integer == (numberOfINPins+1) )
         if ( AnyUNK() )
            r = UNK;
         else
            r = AnyON() ? ON : OFF;
      else
         r = UNK;
      return( r );
   }
};

//********************
class NORGATE: public GATE
//********************
{
public:
   NORGATE(const char identifier[],int numberOfINPins): GATE(identifier,NOR,numberOfINPins) {}

   STATE GetPin(int integer)
   {
      STATE r;

      if      ( integer <= numberOfINPins )
         r = pins[integer];
      else if ( integer == (numberOfINPins+1) )
         if ( AnyUNK() )
            r = UNK;
         else
            r = AnyON() ? OFF : ON;
      else
         r = UNK;
      return( r );
   }
};

//********************
class XORGATE: public GATE
//********************
{
public:
   XORGATE(const char identifier[],int numberOfINPins): GATE(identifier,XOR,numberOfINPins) {}

   STATE GetPin(int integer)
   {
      STATE r;

      if      ( integer <= numberOfINPins )
         r = pins[integer];
      else if ( integer == (numberOfINPins+1) )
         if ( AnyUNK() )
            r = UNK;
         else
         {
         /*
            An XOR with 2 or more inputs outputs a ON when the number of ONs 
            at its inputs is odd, and a OFF when the number of incoming ONs 
            is even.
         */
            int c = 0;
            
            for (int i = 1; i <= numberOfINPins; i++)
               if ( pins[i] == ON ) c++;
            r = (c%2 == 0) ? OFF : ON;
         }
      else
         r = UNK;
      return( r );
   }
};

//********************
class NOTGATE: public GATE
//********************
{
public:
   NOTGATE(const char identifier[]): GATE(identifier,NOT) {}

   STATE GetPin(int integer)
   {
      STATE r;

      if      ( integer == 1 )
         r = pins[integer];
      else if ( integer == 2 )
         if ( pins[1] == UNK )
            r = UNK;
         else
            r = (pins[1] == ON) ? OFF : ON;
      else
         r = UNK;
      return( r );
   }
};

//********************
class NODE
//********************
{
public:
   int index;     // 1 <= index of array "components" <= numberOfComponents or INS,OUTS 
   TOKEN INOrOUT; // IN,OUT
   int integer;   // <integer> after #
};

//********************
class ALIAS
//********************
{
public:
   char identifier[IDENTIFIERLENGTH+1];
// = (can stand in place of, is a synonym for)
   NODE node;
};

//********************
class CONNECTION
//********************
{
public:
   NODE node1;
// - (is connected to)
   NODE node2;

   CONNECTION(){};
   CONNECTION(NODE node1,NODE node2);
   ~CONNECTION(){};
};

CONNECTION::CONNECTION(NODE node1,NODE node2)
{
   this->node1 = node1;
   this->node2 = node2;
}

//********************
class CIRCUIT
//********************
{
private:
   char fileName[IDENTIFIERLENGTH+1];
   STATE  INs[MAXIMUMINOUTS+1];
   STATE OUTs[MAXIMUMINOUTS+1];
   int numberOfComponents;
   COMPONENT *components[MAXIMUMCOMPONENTS+1];
   int numberOfAliases;
   ALIAS aliases[MAXIMUMALIASES+1];
   int numberOfConnections;
   CONNECTION connections[MAXIMUMCONNECTIONS+1];

   FILE  *SOURCE,*LOG;
   char  sourceLine[LINELENGTH+1],nextCharacter;
   int   sourceLineIndex,characterNumber,lineNumber,pageNumber;
   bool atEOF,atEOL;

   void ParseCircuit(TOKEN &token,char lexeme[]);
   void GetNextToken(TOKEN &token,char lexeme[]);
   void GetNextCharacter();
   void GetNextSourceLine();
   void ParseComponent(TOKEN &token,char lexeme[]);
   void ParseAlias(TOKEN &token,char lexeme[]);
   void ParseConnection(TOKEN &token,char lexeme[]);
   void ParseNode(TOKEN &token,char lexeme[],NODE &node);
   void FindComponentIdentifier(const char identifier[],bool &found,int &index);
   void FindAliasIdentifier(const char identifier[],bool &found,NODE &node);
   void AddGate(const char identifier[],TOKEN type,int numberOfINPins);
   void AddLatch(const char identifier[]);
   void AddBuffer(const char identifier[]);
   void AddAlias(const char identifier[],NODE node);
   void AddConnection(NODE node1,NODE node2,bool &legalConnection);
   bool IsComponentINPin(int index,int integer);
   bool IsComponentOUTPin(int index,int integer);
   void ProcessSyntaxError(ERROR error);
   void ProcessRuntimeError(ERROR error,char additionalInformation[]);
public:
   CIRCUIT();
   ~CIRCUIT(){};
   void Load(const char sourceFilename[]);
   void SetIN(int integer,STATE state);
   void SetIN(const char identifier[],STATE state);
   STATE GetIN(int integer);
   STATE GetIN(const char identifier[]);
   STATE GetOUT(int integer);
   STATE GetOUT(const char identifier[]);
   STATE GetComponentPin(const char identifier[],int integer);
   void SimulateLogic();
};

//----------------------------------------------------
CIRCUIT::CIRCUIT()
//----------------------------------------------------
{
   numberOfComponents = 0;
   numberOfAliases = 0;
   numberOfConnections = 0;
}

//----------------------------------------------------
void CIRCUIT::Load(const char sourceFilename[])
//----------------------------------------------------
{
   char fullFilename[LINELENGTH];
   TOKEN token;
   char lexeme[LINELENGTH+1];

   strcpy(this->fileName,fileName);
   strcpy(fullFilename,sourceFilename);
   strcat(fullFilename,".sdl");
   if ( (SOURCE = fopen(fullFilename,"r")) == NULL)
      ProcessRuntimeError(ERROR_OPENING_SOURCE_FILE,fullFilename);
   strcpy(fullFilename,sourceFilename);
   strcat(fullFilename,".log");
   if ( (LOG = fopen(fullFilename,"w")) == NULL)
      ProcessRuntimeError(ERROR_OPENING_LOG_FILE,fullFilename);
   ParseCircuit(token,lexeme);
   fprintf(LOG,"%4d characters, %3d lines\n",characterNumber,lineNumber);
   fprintf(LOG," %3d components (%s...%s)\n",numberOfComponents,
      components[1]->identifier,components[numberOfComponents]->identifier);
   fprintf(LOG," %3d connections\n",numberOfConnections);
//   printf("%4d characters, %3d lines\n",characterNumber,lineNumber);
//   printf(" %3d components (%s...%s)\n",numberOfComponents,
//      components[1]->identifier,components[numberOfComponents]->identifier);
//   printf(" %3d connections\n",numberOfConnections);
   fclose(SOURCE);
   fclose(LOG);
}

//----------------------------------------------------
void CIRCUIT::FindComponentIdentifier(const char identifier[],bool &found,int &index)
//----------------------------------------------------
{
   char uIdentifier1[IDENTIFIERLENGTH+1];
   int i;

   found = false;
   index = 1;
   for (i = 0; i <= (int) strlen(identifier); i++)
      uIdentifier1[i] = toupper(identifier[i]);
   while ( (index <= numberOfComponents) && !found )
   {
      char uIdentifier2[IDENTIFIERLENGTH+1];

      for (i = 0; i <= (int) strlen(components[index]->identifier); i++)
         uIdentifier2[i] = toupper(components[index]->identifier[i]);
      if ( strcmp(uIdentifier1,uIdentifier2) == 0 )
         found = true;
      else
         index++;
   }
}

//----------------------------------------------------
void CIRCUIT::FindAliasIdentifier(const char identifier[],bool &found,NODE &node)
//----------------------------------------------------
{
   char uIdentifier1[IDENTIFIERLENGTH+1];
   int i,index;

   found = false;
   index = 1;
   for (i = 0; i <= (int) strlen(identifier); i++)
      uIdentifier1[i] = toupper(identifier[i]);
   while ( (index <= numberOfAliases) && !found )
   {
      char uIdentifier2[IDENTIFIERLENGTH+1];

      for (i = 0; i <= (int) strlen(aliases[index].identifier); i++)
         uIdentifier2[i] = toupper(aliases[index].identifier[i]);
      if ( strcmp(uIdentifier1,uIdentifier2) == 0 )
      {
         node = aliases[index].node;
         found = true;
      }
      else
         index++;
   }
}

//----------------------------------------------------
void CIRCUIT::AddGate(const char identifier[],TOKEN type,int numberOfINPins)
//----------------------------------------------------
{
   numberOfComponents++;
   switch ( type )
   {
      case  AND: components[numberOfComponents] = new  ANDGATE(identifier,numberOfINPins);
                 break;
      case NAND: components[numberOfComponents] = new NANDGATE(identifier,numberOfINPins);
                 break;
      case   OR: components[numberOfComponents] = new   ORGATE(identifier,numberOfINPins);
                 break;
      case  NOR: components[numberOfComponents] = new  NORGATE(identifier,numberOfINPins);
                 break;
      case  XOR: components[numberOfComponents] = new  XORGATE(identifier,numberOfINPins);
                 break;
      case  NOT: components[numberOfComponents] = new  NOTGATE(identifier);
                 break;
   }
}

//----------------------------------------------------
void CIRCUIT::AddLatch(const char identifier[])
//----------------------------------------------------
{
   numberOfComponents++;
   components[numberOfComponents] = new LATCH(identifier);
}

//----------------------------------------------------
void CIRCUIT::AddBuffer(const char identifier[])
//----------------------------------------------------
{
   numberOfComponents++;
   components[numberOfComponents] = new BUFFER(identifier);
}

//----------------------------------------------------
void CIRCUIT::AddAlias(const char identifier[],NODE node)
//----------------------------------------------------
{
   numberOfAliases++;
   strcpy(aliases[numberOfAliases].identifier,identifier);
   aliases[numberOfAliases].node = node;
}

//----------------------------------------------------
void CIRCUIT::AddConnection(NODE node1,NODE node2,bool &legalConnection)
//----------------------------------------------------
{
/*
Connection is legal? (Y)es, (R)everse-is-legal, (N)o
          | node2
     node1| IN#  OUT#  gate#(IN)  gate#(OUT) POWER GROUND
----------|----------------------------------------------
       IN#|   N     Y          Y           N     N      N
      OUT#|   R     N          N           R     N      N
 gate#(IN)|   R     N          N           R     R      R
gate#(OUT)|   N     Y          Y           N     N      N
     POWER|   N     N          Y           N     N      N
    GROUND|   N     N          Y           N     N      N
*/
   char connectionIsLegal[6][6] =
   {
       { 'N', 'Y', 'Y', 'N', 'N', 'N' },
       { 'R', 'N', 'N', 'R', 'N', 'N' },
       { 'R', 'N', 'N', 'R', 'R', 'R' },
       { 'N', 'Y', 'Y', 'N', 'N', 'N' },
       { 'N', 'N', 'Y', 'N', 'N', 'N' },
       { 'N', 'N', 'Y', 'N', 'N', 'N' }
   };

   int row,col;

   if      ( node1.index == INS )
      row = 0;
   else if ( node1.index == OUTS )
      row = 1;
   else if ( (node1.index <= numberOfComponents) && (node1.INOrOUT ==  IN) )
      row = 2;
   else if ( (node1.index <= numberOfComponents) && (node1.INOrOUT == OUT) )
      row = 3;
   else if ( node1.index == POWERX )
      row = 4;
   else if ( node1.index == GROUNDX )
      row = 5;
   if      ( node2.index == INS )
      col = 0;
   else if ( node2.index == OUTS )
      col = 1;
   else if ( (node2.index <= numberOfComponents) && (node2.INOrOUT ==  IN) )
      col = 2;
   else if ( (node2.index <= numberOfComponents) && (node2.INOrOUT == OUT) )
      col = 3;
   else if ( node2.index == POWERX )
      col = 4;
   else if ( node2.index == GROUNDX )
      col = 5;
   switch ( connectionIsLegal[row][col] )
   {
      case 'N': legalConnection = false;
                break;
      case 'R': connections[++numberOfConnections] = CONNECTION(node2,node1);
                legalConnection = true;
                break;
      case 'Y': connections[++numberOfConnections] = CONNECTION(node1,node2);
                legalConnection = true;
                break;
   }
}

//----------------------------------------------------
void CIRCUIT::SetIN(int integer,STATE state)
//----------------------------------------------------
{
   if ( (integer < 1) || (integer > MAXIMUMINOUTS) )
   {
      char additionalInformation[LINELENGTH+1];

      sprintf(additionalInformation,"%d",integer);
      ProcessRuntimeError(ILLEGAL_INOUT_INTEGER,additionalInformation);
   }
   INs[integer] = state;
}

//----------------------------------------------------
void CIRCUIT::SetIN(const char identifier[],STATE state)
//----------------------------------------------------
{
   bool found;
   NODE node;

   FindAliasIdentifier(identifier,found,node);
   if ( !found || (node.index != INS) )
      ProcessRuntimeError(ILLEGAL_INOUT_ALIAS,const_cast<char *>(identifier));
   INs[node.integer] = state;
}

//----------------------------------------------------
STATE CIRCUIT::GetIN(int integer)
//----------------------------------------------------
{
   if ( (integer < 1) || (integer > MAXIMUMINOUTS) )
   {
      char additionalInformation[LINELENGTH+1];

      sprintf(additionalInformation,"%d",integer);
      ProcessRuntimeError(ILLEGAL_INOUT_INTEGER,additionalInformation);
   }
   return(  INs[integer] );
}

//----------------------------------------------------
STATE CIRCUIT::GetIN(const char identifier[])
//----------------------------------------------------
{
   bool found;
   NODE node;

   FindAliasIdentifier(identifier,found,node);
   if ( !found || (node.index != INS) )
      ProcessRuntimeError(ILLEGAL_INOUT_ALIAS,const_cast<char *>(identifier));
   return(  INs[node.integer] );
}

//----------------------------------------------------
STATE CIRCUIT::GetOUT(int integer)
//----------------------------------------------------
{
   if ( (integer < 1) || (integer > MAXIMUMINOUTS) )
   {
      char additionalInformation[LINELENGTH+1];

      sprintf(additionalInformation,"%d",integer);
      ProcessRuntimeError(ILLEGAL_INOUT_INTEGER,additionalInformation);
   }
   return( OUTs[integer] );
}

//----------------------------------------------------
STATE CIRCUIT::GetOUT(const char identifier[])
//----------------------------------------------------
{
   bool found;
   NODE node;

   FindAliasIdentifier(identifier,found,node);
   if ( !found || (node.index != OUTS) )
      ProcessRuntimeError(ILLEGAL_INOUT_ALIAS,const_cast<char *>(identifier));
   return( OUTs[node.integer] );
}

//----------------------------------------------------
STATE CIRCUIT::GetComponentPin(const char identifier[],int integer)
//----------------------------------------------------
{
   bool found;
   int index;

   FindComponentIdentifier(identifier,found,index);
   if ( !found )   
      ProcessRuntimeError(UNDEFINED_IDENTIFIER,const_cast<char *>(identifier));
   return( components[index]->GetPin(integer) );
}

//----------------------------------------------------
void CIRCUIT::SimulateLogic()
//----------------------------------------------------
{
   int i;

// Assumes that all SetIN()s have made by circuit owner.
// Set all OUT#s to UNK
   for (i = 1; i <= MAXIMUMINOUTS; i++)
      OUTs[i] = UNK;
// Set all gate pins to UNK
   for (i = 1; i <= numberOfComponents; i++)
      components[i]->SetINPinsToUNK();
// Process connections
//    * POWER/GROUND - component#(IN)
   for (i = 1; i <= numberOfConnections; i++)
   {
      NODE n1 = connections[i].node1;
      NODE n2 = connections[i].node2;

      if ( (n1.index == POWERX) &&
           (n2.index <= numberOfComponents) &&
           (n2.INOrOUT == IN) )
         components[n2.index]->SetINPin(n2.integer,ON);
      if ( (n1.index == GROUNDX) &&
           (n2.index <= numberOfComponents) &&
           (n2.INOrOUT == IN) )
         components[n2.index]->SetINPin(n2.integer,OFF);
   }
//    * IN# - OUT#
   for (i = 1; i <= numberOfConnections; i++)
   {
      NODE n1 = connections[i].node1;
      NODE n2 = connections[i].node2;

      if ( (n1.index == INS) &&
           (n2.index == OUTS) )
         OUTs[n2.integer] = GetIN(n1.integer);
   }
//    * IN# - component#(IN)
   for (i = 1; i <= numberOfConnections; i++)
   {
      NODE n1 = connections[i].node1;
      NODE n2 = connections[i].node2;

      if ( (n1.index == INS) &&
           (n2.index <= numberOfComponents) &&
           (n2.INOrOUT == IN) )
         components[n2.index]->SetINPin(n2.integer,GetIN(n1.integer));
   }
//    * component#(OUT) - component#(IN)
   for (int g = 1; g <= numberOfComponents; g++)
      for (i = 1; i <= numberOfConnections; i++)
      {
         NODE n1 = connections[i].node1;
         NODE n2 = connections[i].node2;

         if ( (n1.index <= numberOfComponents) &&
              (n1.INOrOUT == OUT) &&
              (n2.index <= numberOfComponents) &&
              (n2.INOrOUT == IN) )
            components[n2.index]->SetINPin(n2.integer,components[n1.index]->GetPin(n1.integer));
      }
//    * component#(OUT) - OUT#
   for (i = 1; i <= numberOfConnections; i++)
   {
      NODE n1 = connections[i].node1;
      NODE n2 = connections[i].node2;

      if ( (n1.index <= numberOfComponents) &&
           (n1.INOrOUT == OUT) &&
           (n2.index == OUTS) )
         OUTs[n2.integer] = components[n1.index]->GetPin(n1.integer);
   }
}

//----------------------------------------------------
bool CIRCUIT::IsComponentINPin(int index,int integer)
//----------------------------------------------------
{
   return( components[index]->IsINPin(integer) );
}

//----------------------------------------------------
bool CIRCUIT::IsComponentOUTPin(int index,int integer)
//----------------------------------------------------
{
   return( components[index]->IsOUTPin(integer) );
}

//----------------------------------------------------
void CIRCUIT::ParseCircuit(TOKEN &token,char lexeme[])
//----------------------------------------------------
{
/*
<circuit>    ::= COMPONENTS
                    <component> { <component> }*
               [ ALIASES
                    <alias> { <alias> }* ]
                 CONNECTIONS
                    <connection> { <connection> }*
                 END
*/

   atEOF = false;
   characterNumber = 0;
   lineNumber = 0;
   pageNumber = 0;
   GetNextSourceLine();
   GetNextCharacter();
   GetNextToken(token,lexeme);
   if ( token != COMPONENTS )
      ProcessSyntaxError(EXPECTING_COMPONENTS);
   GetNextToken(token,lexeme);
   do 
      ParseComponent(token,lexeme);
   while ( (token != ALIASES) && (token != CONNECTIONS) && (token != EOFX) );
   if ( token == ALIASES )
   {
      GetNextToken(token,lexeme);
      do
         ParseAlias(token,lexeme);
      while ( (token != CONNECTIONS) && (token != EOFX) );
   }
   if ( token != CONNECTIONS )
      ProcessSyntaxError(EXPECTING_CONNECTIONS);
   GetNextToken(token,lexeme);
   do
      ParseConnection(token,lexeme);
   while ( (token != END) && (token != EOFX) );
   if ( token != END )
      ProcessSyntaxError(EXPECTING_END);
}

//----------------------------------------------------
void CIRCUIT::ParseComponent(TOKEN &token,char lexeme[])
//----------------------------------------------------
{
/*
<component>  ::= <gate> | <latch> | <buffer>
<gate>       ::= (( AND | NAND | OR | NOR | XOR )) [ *<integer> ] <identifier>
               | NOT <identifier>
<latch>      ::= LATCH <identifier>
<buffer>     ::= BUFFER <identifier>
*/
   TOKEN type;
   bool found;
   int index,numberOfINPins;

   if ( (token ==  AND) ||
        (token == NAND) ||
        (token ==   OR) ||
        (token ==  NOR) ||
        (token ==  XOR) )
   {
      type = token;
      GetNextToken(token,lexeme);
      if ( token == STAR )
      {
         GetNextToken(token,lexeme);
         if ( token != INTEGER )
            ProcessSyntaxError(EXPECTING_INTEGER);
         numberOfINPins = atoi(lexeme);
         if ( (numberOfINPins < 2) || (numberOfINPins > MAXIMUMINPINS) )
            ProcessSyntaxError(ILLEGAL_NUMBER_OF_INPUT_PINS);
         GetNextToken(token,lexeme);
      }
      else
         numberOfINPins = 2;
   }
   else if ( token == NOT )
   {
      type = token;
      numberOfINPins = 1;
      GetNextToken(token,lexeme);
   }
   else if ( token == LATCHX )
   {
      type = token;
      GetNextToken(token,lexeme);
   }
   else if ( token == BUFFERX )
   {
      type = token;
      GetNextToken(token,lexeme);
   }
   else
      ProcessSyntaxError(EXPECTING_COMPONENTTYPE);
   if ( token != IDENTIFIER )
      ProcessSyntaxError(EXPECTING_IDENTIFIER);
   FindComponentIdentifier(lexeme,found,index);
   if ( found )
      ProcessSyntaxError(MULTIPLY_DEFINED_IDENTIFIER);
   switch ( type )
   {
      case  AND:
      case   OR:
      case NAND:
      case  NOR:
      case  XOR:
      case  NOT: 
         AddGate(lexeme,type,numberOfINPins);
         break;
      case LATCHX:
         AddLatch(lexeme);
         break;
      case BUFFERX:
         AddBuffer(lexeme);
         break;
   }
   GetNextToken(token,lexeme);
}

//----------------------------------------------------
void CIRCUIT::ParseAlias(TOKEN &token,char lexeme[])
//----------------------------------------------------
{
/*
<alias>      ::= <identifier> = <node>
*/
   char identifier[IDENTIFIERLENGTH+1];
   NODE node;
   bool found;
   int index;

   if ( token != IDENTIFIER )
      ProcessSyntaxError(EXPECTING_IDENTIFIER);
   strcpy(identifier,lexeme);
   FindAliasIdentifier(identifier,found,node);
   if ( found )
      ProcessSyntaxError(MULTIPLY_DEFINED_IDENTIFIER);
   FindComponentIdentifier(identifier,found,index);
   if ( found )
      ProcessSyntaxError(MULTIPLY_DEFINED_IDENTIFIER);
   GetNextToken(token,lexeme);
   if ( token != EQUAL )
      ProcessSyntaxError(EXPECTING_EQUAL);
   GetNextToken(token,lexeme);
   ParseNode(token,lexeme,node);
   AddAlias(identifier,node);
}

//----------------------------------------------------
void CIRCUIT::ParseConnection(TOKEN &token,char lexeme[])
//----------------------------------------------------
{
/*
<connection> ::= <node> - <node>
*/
   NODE node1,node2;
   bool legalConnection;

   ParseNode(token,lexeme,node1);
   if ( token != DASH )
      ProcessSyntaxError(EXPECTING_DASH);
   GetNextToken(token,lexeme);
   ParseNode(token,lexeme,node2);
   AddConnection(node1,node2,legalConnection);
   if ( !legalConnection )
      ProcessSyntaxError(ILLEGAL_CONNECTION);
}

//----------------------------------------------------
void CIRCUIT::ParseNode(TOKEN &token,char lexeme[],NODE &node)
//----------------------------------------------------
{
/*
<node>       ::= POWER | GROUND 
               |<identifer>
               |  IN#<integer> 
               | OUT#<integer>
               | <identifer>#<integer>
*/
   bool found;

   switch ( token )
   {
      case IN:
         node.index = INS;
         node.INOrOUT = IN;
         GetNextToken(token,lexeme);
         if ( token != POUND )
            ProcessSyntaxError(EXPECTING_POUND);
         GetNextToken(token,lexeme);
         if ( token != INTEGER )
            ProcessSyntaxError(EXPECTING_INTEGER);
         node.integer = atoi(lexeme);
         if ( (node.integer < 1) || (node.integer > MAXIMUMINOUTS) )
            ProcessSyntaxError(ILLEGAL_INOUT_INTEGER);
         GetNextToken(token,lexeme);
         break;
      case OUT:
         node.index = OUTS;
         node.INOrOUT = OUT;
         GetNextToken(token,lexeme);
         if ( token != POUND )
            ProcessSyntaxError(EXPECTING_POUND);
         GetNextToken(token,lexeme);
         if ( token != INTEGER )
            ProcessSyntaxError(EXPECTING_INTEGER);
         node.integer = atoi(lexeme);
         if ( (node.integer < 1) || (node.integer > MAXIMUMINOUTS) )
            ProcessSyntaxError(ILLEGAL_INOUT_INTEGER);
         GetNextToken(token,lexeme);
         break;
      case POWER:
         node.index = POWERX;
         node.INOrOUT = OUT;
         node.integer = 0;           // Node field not used.
         GetNextToken(token,lexeme);
         break;
      case GROUND:
         node.index = GROUNDX;
         node.INOrOUT = OUT;
         node.integer = 0;           // Node field not used.
         GetNextToken(token,lexeme);
         break;
      case IDENTIFIER:
         FindAliasIdentifier(lexeme,found,node);
         if ( found )
            GetNextToken(token,lexeme);
         else
         {
            FindComponentIdentifier(lexeme,found,node.index);
            if ( !found )
               ProcessSyntaxError(UNDEFINED_IDENTIFIER);
            GetNextToken(token,lexeme);
            if ( token != POUND )
               ProcessSyntaxError(EXPECTING_POUND);
            GetNextToken(token,lexeme);
            if ( token != INTEGER )
               ProcessSyntaxError(EXPECTING_INTEGER);
            node.integer = atoi(lexeme);
            GetNextToken(token,lexeme);
            if      ( IsComponentINPin(node.index,node.integer) ) 
               node.INOrOUT = IN;
            else if ( IsComponentOUTPin(node.index,node.integer) ) 
               node.INOrOUT = OUT;
            else
               ProcessSyntaxError(EXPECTING_NODE);
         }
         break;
      default:
         ProcessSyntaxError(EXPECTING_NODE);
   }
}

//----------------------------------------------------
void CIRCUIT::GetNextToken(TOKEN &token,char lexeme[])
//----------------------------------------------------
{
/*
   <letter>    ::= A | B | ... | Z | a | b | ... | z
   <digit>     ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
   <character> ::= Any printable ASCII character
*/
   int j,k;
   char uLexeme[LINELENGTH];

   do
   {
      /*
         "Eat" any whitespace (blanks and EOLs and TABs).
      */
      while ( (nextCharacter == ' ')
           || (nextCharacter == EOL)
           || (nextCharacter == '\t') )
         GetNextCharacter();

      /*
         "Eat" any comments. Comments are always assumed to extend to EOL.
         <comment> ::= $ {<character>}*
      */
      if ( nextCharacter == '$' )
         do
            GetNextCharacter();
         while ( nextCharacter != EOL );
   } while ( (nextCharacter == ' ')
          || (nextCharacter == EOL)
          || (nextCharacter == '\t') );
/*
   Reserved words and
   <identifier> ::= <letter> { (( <letter> | <digit> )) }*
*/
   if ( isalpha(nextCharacter) )
   {
      j = 0;
      lexeme[j++] = nextCharacter;
      GetNextCharacter();
      while ( isalpha(nextCharacter) || isdigit(nextCharacter) )
      {
         lexeme[j++] = nextCharacter;
         GetNextCharacter();
      }
      lexeme[j] = '\0';
      for (k = 0; k <= (int) strlen(lexeme); k++)
         uLexeme[k] = toupper(lexeme[k]);
      if      ( strcmp(uLexeme,"COMPONENTS") == 0 )
         token = COMPONENTS;
      else if ( strcmp(uLexeme,"ALIASES") == 0 )
         token = ALIASES;
      else if ( strcmp(uLexeme,"CONNECTIONS") == 0 )
         token = CONNECTIONS;
      else if ( strcmp(uLexeme,"END") == 0 )
         token = END;
      else if ( strcmp(uLexeme,"AND") == 0 )
         token = AND;
      else if ( strcmp(uLexeme,"NAND") == 0 )
         token = NAND;
      else if ( strcmp(uLexeme,"OR") == 0 )
         token = OR;
      else if ( strcmp(uLexeme,"NOR") == 0 )
         token = NOR;
      else if ( strcmp(uLexeme,"XOR") == 0 )
         token = XOR;
      else if ( strcmp(uLexeme,"NOT") == 0 )
         token = NOT;
      else if ( strcmp(uLexeme,"LATCH") == 0 )
         token = LATCHX;
      else if ( strcmp(uLexeme,"BUFFER") == 0 )
         token = BUFFERX;
      else if ( strcmp(uLexeme,"IN") == 0 )
         token = IN;
      else if ( strcmp(uLexeme,"OUT") == 0 )
         token = OUT;
      else if ( strcmp(uLexeme,"POWER") == 0 )
         token = POWER;
      else if ( strcmp(uLexeme,"GROUND") == 0 )
         token = GROUND;
      else
         token = IDENTIFIER;
   }
/*
   <integer> ::= <digit> { <digit> }*
*/
   else if ( isdigit(nextCharacter) )
   {
      token = INTEGER;
      j = 0;
      lexeme[j++] = nextCharacter;
      GetNextCharacter();
      while ( isdigit(nextCharacter) )
      {
         lexeme[j++] = nextCharacter;
         GetNextCharacter();
      }
      lexeme[j] = '\0';
   }
   else
   {
      switch ( nextCharacter )
      {
         case EOF: token = EOFX;
                   lexeme[0] = '\0';
                   break;
         case '*': token = STAR;
                   lexeme[0] = nextCharacter; lexeme[1] = '\0';
                   GetNextCharacter();
                   break;
         case '#': token = POUND;
                   lexeme[0] = nextCharacter; lexeme[1] = '\0';
                   GetNextCharacter();
                   break;
         case '-': token = DASH;
                   lexeme[0] = nextCharacter; lexeme[1] = '\0';
                   GetNextCharacter();
                   break;
         case '=': token = EQUAL;
                   lexeme[0] = nextCharacter; lexeme[1] = '\0';
                   GetNextCharacter();
                   break;
         default:  token = UNKNOWN;
                   lexeme[0] = nextCharacter; lexeme[1] = '\0';
                   GetNextCharacter();
                   break;
      }
   }
}

//----------------------------------------------------
void CIRCUIT::GetNextCharacter()
//----------------------------------------------------
{
   if ( atEOF )
      nextCharacter = EOF;
   else
   { 
      if ( atEOL )
         GetNextSourceLine();
      if ( sourceLineIndex <= ((int) strlen(sourceLine)-1) )
      {
         nextCharacter = sourceLine[sourceLineIndex];
         sourceLineIndex += 1;
      }
      else
      {
         nextCharacter = EOL;
         atEOL = true;
      }
   }
   characterNumber++;
}

//----------------------------------------------------
void CIRCUIT::GetNextSourceLine()
//----------------------------------------------------
{
   const char FF = 0X0C;

   if ( fgets(sourceLine,LINELENGTH,SOURCE) == NULL )
      atEOF = true;
   else
   {
      atEOF = false;
      atEOL = false;
/*
   Erase control characters at end of source line (if any)
*/
      while ( (0 <= (int) strlen(sourceLine)-1) && 
              iscntrl(sourceLine[strlen(sourceLine)-1]) )
         sourceLine[strlen(sourceLine)-1] = '\0';
      sourceLineIndex = 0;
/*
   Echo source line to LOG file using the format
      for source line number and text, respectively.

         111111
123456789012345
Page XXXX

Line Source Line
---- ----------------------------------------------------------------------
XXXX XXX---source line text---XXX
   .   .
   .   .
XXXX XXX---source line text---XXX
*/
      lineNumber++;
      if ( lineNumber % 50 == 1 )
      {
         pageNumber++;
         fprintf(LOG,"%cPage %4d\n",FF,pageNumber);
         fprintf(LOG,"\n");
         fprintf(LOG,"Line Source Line\n");
         fprintf(LOG,"---- ----------------------------------------------------------------------\n");
      }
      fprintf(LOG,"%4d %s\n",lineNumber,sourceLine);
   }
}

//----------------------------------------------------
void CIRCUIT::ProcessSyntaxError(ERROR error)
//----------------------------------------------------
{
/*
   Use panic mode error recovery technique; viz., log error message,
   close source and LOG files and throw exception.
*/
   fprintf(LOG,"     ");
   for (int i = 1; i <= (sourceLineIndex-1); i++)
      fprintf(LOG," ");
   fprintf(LOG,"^ %s\n",&errorMessages[error][2]);
   fclose(SOURCE);
   fclose(LOG);
   throw SDLSEXCEPTION(error);
}

//----------------------------------------------------
void CIRCUIT::ProcessRuntimeError(ERROR error,char additionalInformation[])
//----------------------------------------------------
{
   throw SDLSEXCEPTION(error,static_cast<const char *>(additionalInformation));
}

//----------------------------------------------------
const char *StateString(STATE state)
//----------------------------------------------------
{
   switch ( state )
   {
      case  ON: return(  ONSTRING );
      case OFF: return( OFFSTRING );
      case UNK: return( UNKSTRING );
      default:  return( "???" );
   }
}

//----------------------------------------------------
template<class ENUM>
ENUM Predecessor(ENUM x)
//----------------------------------------------------
{
   return( (ENUM) (((int) x)-1) );
}

//----------------------------------------------------
template<class ENUM>
ENUM Successor(ENUM x)
//----------------------------------------------------
{
   return( (ENUM) (((int) x)+1) );
}

#endif
