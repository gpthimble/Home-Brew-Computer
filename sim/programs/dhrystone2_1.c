#define options   "Non-optimised"
#define opt "0"
#define Null 0 
#define NULL 0
                /* Value of a Null pointer */
#define true  1
#define false 0
#define structassign(d, s)      d = s
#define REG

typedef       enum    {Ident_1, Ident_2, Ident_3, Ident_4, Ident_5}
                Enumeration;
typedef int     One_Thirty;
typedef int     One_Fifty;
typedef char    Capital_Letter;
typedef int     Boolean;
typedef char    Str_30 [31];
typedef int     Arr_1_Dim [50];
typedef int     Arr_2_Dim [50] [50];

typedef struct record 
    {
    struct record *Ptr_Comp;
    Enumeration    Discr;
    union {
          struct {
                  Enumeration Enum_Comp;
                  int         Int_Comp;
                  char        Str_Comp [31];
                  } var_1;
          struct {
                  Enumeration E_Comp_2;
                  char        Str_2_Comp [31];
                  } var_2;
          struct {
                  char        Ch_1_Comp;
                  char        Ch_2_Comp;
                  } var_3;
          } variant;
      } Rec_Type, *Rec_Pointer;

/* Global Variables: */
 
Rec_Pointer     Ptr_Glob,
                 Next_Ptr_Glob;
int             Int_Glob;
Boolean         Bool_Glob;
char            Ch_1_Glob,
                Ch_2_Glob;
int             Arr_1_Glob [50];
int             Arr_2_Glob [50] [50];

char Reg_Define[40] = "Register option      Selected.";

Enumeration Func_1 (Capital_Letter Ch_1_Par_Val,
                                          Capital_Letter Ch_2_Par_Val);
void Proc_1 (REG Rec_Pointer Ptr_Val_Par);
void Proc_2 (One_Fifty *Int_Par_Ref);
void Proc_3 (Rec_Pointer *Ptr_Ref_Par);
void Proc_4 (); 
void Proc_5 ();
void Proc_6 (Enumeration Enum_Val_Par, Enumeration *Enum_Ref_Par);
void Proc_7 (One_Fifty Int_1_Par_Val, One_Fifty Int_2_Par_Val,
                                             One_Fifty *Int_Par_Ref);
void Proc_8 (Arr_1_Dim Arr_1_Par_Ref, Arr_2_Dim Arr_2_Par_Ref,
                               int Int_1_Par_Val, int Int_2_Par_Val);
                               
Boolean Func_2 (Str_30 Str_1_Par_Ref, Str_30 Str_2_Par_Ref);
Boolean Func_3 (Enumeration Enum_Par_Val); 
void putchar( char a);
void printstr (char * a);
void swap(char *x, char *y);
char* reverse(char *buffer, int i, int j);
char* itoa(int value, char* buffer, int base);
void printnum(int number, int base);
int abs (int number);
int gettime(int timer);
int strcmp(const char *X, const char *Y);
char* strcpy(char* destination, const char* source);

/* variables for time measurement: */
#define Too_Small_Time 2
int             User_Time, start_time;
int             Microseconds,
                 Dhrystones_Per_Second,
                 Vax_Mips;
 /* end of variables for time measurement */

  void main ( )
   /*****/
 
   /* main program, corresponds to procedures        */
   /* Main and Proc_0 in the Ada version             */
    {
 
         One_Fifty   Int_1_Loc;
   REG   One_Fifty   Int_2_Loc;
         One_Fifty   Int_3_Loc;
   REG   char        Ch_Index;
         Enumeration Enum_Loc;
         Str_30      Str_1_Loc;
         Str_30      Str_2_Loc;
   REG   int         Run_Index;
   REG   int         Number_Of_Runs; 
         int         endit, count = 10;
         int         errors = 0;
         int         i;
         int         nopause = 1;
/***********************************************************************
 *         Change for compiler and optimisation used                   *
 ***********************************************************************/
 
   Rec_Type rec_0;
   Rec_Type rec_1;
   printstr("Dhrystone Benchmark, Version 2.1 (Language: C or C++)\n");

   Next_Ptr_Glob = &rec_0;
   Ptr_Glob      = &rec_1;
   //Next_Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));
   //Ptr_Glob = (Rec_Pointer) malloc (sizeof (Rec_Type));
 
   Ptr_Glob->Ptr_Comp                    = Next_Ptr_Glob;
   Ptr_Glob->Discr                       = Ident_1;
   Ptr_Glob->variant.var_1.Enum_Comp     = Ident_3;
   Ptr_Glob->variant.var_1.Int_Comp      = 40;
   strcpy (Ptr_Glob->variant.var_1.Str_Comp, 
           "DHRYSTONE PROGRAM, SOME STRING");       
   strcpy (Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");
 
   Arr_2_Glob [8][7] = 10;
         /* Was missing in published program. Without this statement,   */
         /* Arr_2_Glob [8][7] would have an undefined value.            */
         /* Warning: With 16-Bit processors and Number_Of_Runs > 32000, */
         /* overflow may occur for this array element.                  */
   printstr("\n");  

   printstr ("Optimisation    ");
   printstr (options);
   printstr("\n");
   //printstr(Ptr_Glob->variant.var_1.Str_Comp);

   printstr ("Register option not selected\n\n");
   strcpy(Reg_Define, "Register option  Not selected.");


   Number_Of_Runs = 50000;
   do
   {

       //Number_Of_Runs = Number_Of_Runs * 2;
       count = count - 1;
       Arr_2_Glob [8][7] = 10;
        
       /***************/
       /* Start timer */
       /***************/
  
       start_time=gettime(0);
   
       for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
       {
 
         Proc_5();
         //printstr("proc_5\n");
         Proc_4();
           /* Ch_1_Glob == 'A', Ch_2_Glob == 'B', Bool_Glob == true */
         //printstr("proc_4\n");
         Int_1_Loc = 2;
         Int_2_Loc = 3;
         strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
         Enum_Loc = Ident_2;
         Bool_Glob = ! Func_2 (Str_1_Loc, Str_2_Loc);
          //printstr("func_2\n");
           /* Bool_Glob == 1 */
         while (Int_1_Loc < Int_2_Loc)  /* loop body executed once */
         {
           Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
             /* Int_3_Loc == 7 */
           Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
             /* Int_3_Loc == 7 */
           Int_1_Loc += 1;
         }   /* while */
          //printstr("proc_7\n");
            /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
         Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
         //printstr("proc_8\n");
           /* Int_Glob == 5 */
         Proc_1 (Ptr_Glob);
         //printstr("proc_1\n");
         for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index)
                              /* loop body executed twice */
         {
           if (Enum_Loc == Func_1 (Ch_Index, 'C'))
               /* then, not executed */
             {
               Proc_6 (Ident_1, &Enum_Loc);
               strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
               Int_2_Loc = Run_Index;
               Int_Glob = Run_Index;
             }
         }
         //printstr("proc_6\n");
           /* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
         Int_2_Loc = Int_2_Loc * Int_1_Loc;
         Int_1_Loc = Int_2_Loc / Int_3_Loc;
         Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
           /* Int_1_Loc == 1, Int_2_Loc == 13, Int_3_Loc == 7 */
         Proc_2 (&Int_1_Loc);
           /* Int_1_Loc == 5 */
        //printstr("proc_2\n");
       }   /* loop "for Run_Index" */
 
       /**************/
       /* Stop timer */
       /**************/
 
       Microseconds=gettime(0)-start_time;
       //User_Time = Microseconds/1000;

       printnum(Number_Of_Runs,10);
       printstr(" runs ");
       printnum(Microseconds,10);
       printstr(" micro seconds \n");
              if (Microseconds > 200000)
       {
             count = 0;
       }
       else
       {
             if (Microseconds < 100)
             {
                  Number_Of_Runs = Number_Of_Runs * 5;
             }
       }
      //count = 0;
   }   /* calibrate/run do while */
   while (count >0);
    User_Time = Microseconds/1000000;
   printstr ("\n");
   printstr ("Final values (* implementation-dependent):\n");
   printstr ("\n");
   printstr ("Int_Glob:      ");
   if (Int_Glob == 5)  printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Int_Glob,10);
   printstr("  ");
      
   printstr ("Bool_Glob:     ");
   if (Bool_Glob == 1) printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Bool_Glob,10);
   printstr("\n");
      
   printstr ("Ch_1_Glob:     ");
   if (Ch_1_Glob == 'A')  printstr ("O.K.  ");               
   else                   printstr ("WRONG ");
   putchar(Ch_1_Glob);
   printstr("  ");
  
         
   printstr ("Ch_2_Glob:     ");
   if (Ch_2_Glob == 'B')  printstr ("O.K.  ");
   else                   printstr ("WRONG ");
   putchar(Ch_2_Glob);
   printstr("\n");

   
   printstr ("Arr_1_Glob[8]: ");
   if (Arr_1_Glob[8] == 7)  printstr ("O.K.  ");
   else                     printstr ("WRONG ");
   printnum(Arr_1_Glob[8],10);
   printstr("  ");

            
   printstr ("Arr_2_Glob8/7: ");
   if (Arr_2_Glob[8][7] == Number_Of_Runs + 10)
                          printstr ("O.K.  ");
   else                   printstr ("WRONG ");
   printnum(Arr_2_Glob[8][7],10);
   printstr("\n");

   
   printstr ("Ptr_Glob->            ");
   printstr ("  Ptr_Comp:       *    ");
   printnum((int) Ptr_Glob->Ptr_Comp,10);
   printstr("\n");
   
   printstr ("  Discr:       ");
   if (Ptr_Glob->Discr == 0)  printstr ("O.K.  ");
   else                       printstr ("WRONG ");
   printnum(Ptr_Glob->Discr,10);
   printstr("  ");

            
   printstr ("Enum_Comp:     ");
   if (Ptr_Glob->variant.var_1.Enum_Comp == 2)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Ptr_Glob->variant.var_1.Enum_Comp,10);
   printstr("\n");
      
   printstr ("  Int_Comp:    ");
   if (Ptr_Glob->variant.var_1.Int_Comp == 17)  printstr ("O.K.  ");
   else                                         printstr ("WRONG ");
   printnum(Ptr_Glob->variant.var_1.Int_Comp,10);
   printstr("  ");   

      
   printstr ("Str_Comp:      ");
   if (strcmp(Ptr_Glob->variant.var_1.Str_Comp,
                        "DHRYSTONE PROGRAM, SOME STRING") == 0)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");   
   printstr(Ptr_Glob->variant.var_1.Str_Comp);
   printstr("\n");   

   
   printstr ("Next_Ptr_Glob->       "); 
   printstr("  Ptr_Comp:       *    ");
   printnum((int) Next_Ptr_Glob->Ptr_Comp,10);
   printstr (" same as above\n");
   
   printstr ("  Discr:       ");
   if (Next_Ptr_Glob->Discr == 0)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Next_Ptr_Glob->Discr,10);
   printstr("  "); 

   
   printstr ("Enum_Comp:     ");
   if (Next_Ptr_Glob->variant.var_1.Enum_Comp == 1)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Next_Ptr_Glob->variant.var_1.Enum_Comp,10);
   printstr("\n");  

   
   printstr ("  Int_Comp:    ");
   if (Next_Ptr_Glob->variant.var_1.Int_Comp == 18)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Next_Ptr_Glob->variant.var_1.Int_Comp,10);
   printstr("  "); 
   
   printstr ("Str_Comp:      ");
   if (strcmp(Next_Ptr_Glob->variant.var_1.Str_Comp,
                        "DHRYSTONE PROGRAM, SOME STRING") == 0)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printstr(Next_Ptr_Glob->variant.var_1.Str_Comp);
   printstr("\n");     
   
   printstr ("Int_1_Loc:     ");
   if (Int_1_Loc == 5)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Int_1_Loc,10);
   printstr("  "); 

      
   printstr ("Int_2_Loc:     ");
   if (Int_2_Loc == 13)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Int_2_Loc,10);
   printstr("\n");  

   
   printstr ("Int_3_Loc:     ");
   if (Int_3_Loc == 7)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Int_3_Loc,10);
   printstr("  "); 

   
   printstr ("Enum_Loc:      ");
   if (Enum_Loc == 1)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");
   printnum(Enum_Loc,10);
   printstr("  \n");  

   
   
   printstr ("Str_1_Loc:                             ");
   if (strcmp(Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING") == 0)
                        printstr ("O.K.  ");

   else                printstr ("WRONG ");  
   printstr(Str_1_Loc) ;
   printstr("\n");


   printstr ("Str_2_Loc:                             ");
   if (strcmp(Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING") == 0)
                        printstr ("O.K.  ");
   else                printstr ("WRONG ");  
   printstr(Str_2_Loc) ;
   printstr("\n");
         

   printstr ("\n");
    
 
   if (User_Time < Too_Small_Time)
   {
     printstr ("Measured time too small to obtain meaningful results\n");
     printstr ("Please increase number of runs\n");
     printstr ("\n");
   }
   else
   {
     Microseconds = User_Time * 1000000
                         /  Number_Of_Runs;
     Dhrystones_Per_Second =  Number_Of_Runs / User_Time;
     Vax_Mips = Dhrystones_Per_Second / 1757;
 
     printstr ("Microseconds for one run through Dhrystone: ");
     printnum ( Microseconds,10);
     printstr(" \n");
     printstr ("Dhrystones per Second:                      ");
     printnum (Dhrystones_Per_Second,10);
     printstr(" \n");     
     printstr ("VAX  MIPS rating =                          ");
     printnum (Vax_Mips,10);
     printstr(" \n");
     printstr ("\n");
    }
    //stop here
    while (true)
    {
        /* code */
    }
    
}

 void Proc_1 (REG Rec_Pointer Ptr_Val_Par)
 /******************/
 
     /* executed once */
 {
   REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;  
                                         /* == Ptr_Glob_Next */
   /* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
   /* corresponds to "rename" in Ada, "with" in Pascal           */
   
   structassign (*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob);
   Ptr_Val_Par->variant.var_1.Int_Comp = 5;
   Next_Record->variant.var_1.Int_Comp 
         = Ptr_Val_Par->variant.var_1.Int_Comp;
   Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
   Proc_3 (&Next_Record->Ptr_Comp);
     /* Ptr_Val_Par->Ptr_Comp->Ptr_Comp 
                         == Ptr_Glob->Ptr_Comp */
   if (Next_Record->Discr == Ident_1)
     /* then, executed */
   {
     Next_Record->variant.var_1.Int_Comp = 6;
     Proc_6 (Ptr_Val_Par->variant.var_1.Enum_Comp, 
            &Next_Record->variant.var_1.Enum_Comp);
     Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
     Proc_7 (Next_Record->variant.var_1.Int_Comp, 10, 
            &Next_Record->variant.var_1.Int_Comp);
   }
   else /* not executed */
     structassign (*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
 } /* Proc_1 */
 
 
 void Proc_2 (One_Fifty *Int_Par_Ref)
 /******************/
     /* executed once */
     /* *Int_Par_Ref == 1, becomes 4 */
 
 {
   One_Fifty  Int_Loc;
   Enumeration   Enum_Loc;
 
   Int_Loc = *Int_Par_Ref + 10;
   do /* executed once */
     if (Ch_1_Glob == 'A')
       /* then, executed */
     {
       Int_Loc -= 1;
       *Int_Par_Ref = Int_Loc - Int_Glob;
       Enum_Loc = Ident_1;
     } /* if */
   while (Enum_Loc != Ident_1); /* true */
 } /* Proc_2 */
 
 
 void Proc_3 (Rec_Pointer *Ptr_Ref_Par)
 /******************/
     /* executed once */
     /* Ptr_Ref_Par becomes Ptr_Glob */
 
 {
   if (Ptr_Glob != Null)
     /* then, executed */
     *Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;
   Proc_7 (10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
 } /* Proc_3 */
 
 
void Proc_4 () /* without parameters */
 /*******/
     /* executed once */
 {
   Boolean Bool_Loc;
 
   Bool_Loc = Ch_1_Glob == 'A';
   Bool_Glob = Bool_Loc | Bool_Glob;
   Ch_2_Glob = 'B';
 } /* Proc_4 */
 
 
 void Proc_5 () /* without parameters */
 /*******/
     /* executed once */
 {
   Ch_1_Glob = 'A';
   Bool_Glob = false;
 } /* Proc_5 */
 
 void Proc_6 (Enumeration Enum_Val_Par, Enumeration *Enum_Ref_Par)
 /*********************************/
     /* executed once */
     /* Enum_Val_Par == Ident_3, Enum_Ref_Par becomes Ident_2 */
 
 {
   *Enum_Ref_Par = Enum_Val_Par;
   if (! Func_3 (Enum_Val_Par))
     /* then, not executed */
     *Enum_Ref_Par = Ident_4;
   switch (Enum_Val_Par)
   {
     case Ident_1: 
       *Enum_Ref_Par = Ident_1;
       break;
     case Ident_2: 
       if (Int_Glob > 100)
         /* then */
       *Enum_Ref_Par = Ident_1;
       else *Enum_Ref_Par = Ident_4;
       break;
     case Ident_3: /* executed */
       *Enum_Ref_Par = Ident_2;
       break;
     case Ident_4: break;
     case Ident_5: 
       *Enum_Ref_Par = Ident_3;
       break;
   } /* switch */
 } /* Proc_6 */
 
 
 void Proc_7 (One_Fifty Int_1_Par_Val, One_Fifty Int_2_Par_Val,
                                              One_Fifty *Int_Par_Ref)
 /**********************************************/
     /* executed three times                                      */
     /* first call:      Int_1_Par_Val == 2, Int_2_Par_Val == 3,  */
     /*                  Int_Par_Ref becomes 7                    */
     /* second call:     Int_1_Par_Val == 10, Int_2_Par_Val == 5, */
     /*                  Int_Par_Ref becomes 17                   */
     /* third call:      Int_1_Par_Val == 6, Int_2_Par_Val == 10, */
     /*                  Int_Par_Ref becomes 18                   */

 {
   One_Fifty Int_Loc;
 
   Int_Loc = Int_1_Par_Val + 2;
   *Int_Par_Ref = Int_2_Par_Val + Int_Loc;
 } /* Proc_7 */
 
 
 void Proc_8 (Arr_1_Dim Arr_1_Par_Ref, Arr_2_Dim Arr_2_Par_Ref,
                                  int Int_1_Par_Val, int Int_2_Par_Val)
 /*********************************************************************/
     /* executed once      */
     /* Int_Par_Val_1 == 3 */
     /* Int_Par_Val_2 == 7 */

 {
   REG One_Fifty Int_Index;
   REG One_Fifty Int_Loc;
 
   Int_Loc = Int_1_Par_Val + 5;
   Arr_1_Par_Ref [Int_Loc] = Int_2_Par_Val;
   Arr_1_Par_Ref [Int_Loc+1] = Arr_1_Par_Ref [Int_Loc];
   Arr_1_Par_Ref [Int_Loc+30] = Int_Loc;
   for (Int_Index = Int_Loc; Int_Index <= Int_Loc+1; ++Int_Index)
     Arr_2_Par_Ref [Int_Loc] [Int_Index] = Int_Loc;
   Arr_2_Par_Ref [Int_Loc] [Int_Loc-1] += 1;
   Arr_2_Par_Ref [Int_Loc+20] [Int_Loc] = Arr_1_Par_Ref [Int_Loc];
   Int_Glob = 5;
 } /* Proc_8 */
 
 
 Enumeration Func_1 (Capital_Letter Ch_1_Par_Val,
                                           Capital_Letter Ch_2_Par_Val)
 /*************************************************/
     /* executed three times                                         */
     /* first call:      Ch_1_Par_Val == 'H', Ch_2_Par_Val == 'R'    */
     /* second call:     Ch_1_Par_Val == 'A', Ch_2_Par_Val == 'C'    */
     /* third call:      Ch_1_Par_Val == 'B', Ch_2_Par_Val == 'C'    */
 
 {
   Capital_Letter        Ch_1_Loc;
   Capital_Letter        Ch_2_Loc;
 
   Ch_1_Loc = Ch_1_Par_Val;
   Ch_2_Loc = Ch_1_Loc;
   if (Ch_2_Loc != Ch_2_Par_Val)
     /* then, executed */
     return (Ident_1);
   else  /* not executed */
   {
     Ch_1_Glob = Ch_1_Loc;
     return (Ident_2);
    }
 } /* Func_1 */
 
 
 Boolean Func_2 (Str_30 Str_1_Par_Ref, Str_30 Str_2_Par_Ref)
 /*************************************************/
     /* executed once */
     /* Str_1_Par_Ref == "DHRYSTONE PROGRAM, 1'ST STRING" */
     /* Str_2_Par_Ref == "DHRYSTONE PROGRAM, 2'ND STRING" */
 
 {
   REG One_Thirty        Int_Loc;
       Capital_Letter    Ch_Loc;
 
   Int_Loc = 2;
   while (Int_Loc <= 2) /* loop body executed once */
     if (Func_1 (Str_1_Par_Ref[Int_Loc],
                 Str_2_Par_Ref[Int_Loc+1]) == Ident_1)
       /* then, executed */
     {
       Ch_Loc = 'A';
       Int_Loc += 1;
     } /* if, while */
   if (Ch_Loc >= 'W' && Ch_Loc < 'Z')
     /* then, not executed */
     Int_Loc = 7;
   if (Ch_Loc == 'R')
     /* then, not executed */
     return (true);
   else /* executed */
   {
     if (strcmp (Str_1_Par_Ref, Str_2_Par_Ref) > 0)
       /* then, not executed */
     {
       Int_Loc += 7;
       Int_Glob = Int_Loc;
       return (true);
     }
     else /* executed */
       return (false);
   } /* if Ch_Loc */
 } /* Func_2 */
 
 
 Boolean Func_3 (Enumeration Enum_Par_Val)
 /***************************/
     /* executed once        */
     /* Enum_Par_Val == Ident_3 */
     
 {
   Enumeration Enum_Loc;
 
   Enum_Loc = Enum_Par_Val;
   if (Enum_Loc == Ident_3)
     /* then, executed */
     return (true);
   else /* not executed */
     return (false);
 } /* Func_3 */

void printstr( char * a)
{   
    char temp = *a;
    while (temp != 0)
    {
        if (temp == '\n')
        {
            putchar('\n');
            putchar('\r');
        }
        else
        {
            putchar(temp);
        }
        a = a+1;
        temp = *a;
    }
}
void printnum(int number, int base)
{
    char buffer[33];
    itoa(number, buffer, base);
    printstr(buffer);
}

void swap(char *x, char *y) {
    char t = *x; *x = *y; *y = t;
}
 
// function to reverse buffer[i..j]
char* reverse(char *buffer, int i, int j)
{
    while (i < j)
        swap(&buffer[i++], &buffer[j--]);
 
    return buffer;
}
 
// Iterative function to implement itoa() function in C
char* itoa(int value, char* buffer, int base)
{
    int n = abs(value);
    int i = 0;
    int r = 0;
    // invalid input
    if (base < 2 || base > 32)
        return buffer;
 
    // consider absolute value of number
    while (n)
    {
        r = n % base;
 
        if (r >= 10) 
            buffer[i++] = 65 + (r - 10);
        else
            buffer[i++] = 48 + r;
 
        n = n / base;
    }
 
    // if number is 0
    if (i == 0)
        buffer[i++] = '0';
 
    // If base is 10 and value is negative, the resulting string 
    // is preceded with a minus sign (-)
    // With any other base, value is always considered unsigned
    if (value < 0 && base == 10)
        buffer[i++] = '-';
 
    buffer[i] = '\0'; // null terminate string
 
    // reverse the string and return it
    return reverse(buffer, 0, i - 1);
}

int abs (int i)
{
  return i < 0 ? -i : i;
}
// Function to implement strcmp function
int strcmp(const char *X, const char *Y)
{
    while(*X)
    {
        // if characters differ or end of second string is reached
        if (*X != *Y)
            break;
 
        // move to next pair of characters
        X++;
        Y++;
    }
 
    // return the ASCII difference after converting char* to unsigned char*
    return *(const unsigned char*)X - *(const unsigned char*)Y;
}

// Function to implement strcpy() function
char* strcpy(char* destination, const char* source)
{
    // take a pointer pointing to the beginning of destination string
    char *ptr = destination;
    // return if no memory is allocated to the destination
    if (destination == NULL)
        return NULL;
 
 
    // copy the C-string pointed by source into the array
    // pointed by destination
    while (*source != '\0')
    {
        *destination = *source;
        destination++;
        source++;
    }
 
    // include the terminating null character
    *destination = '\0';
 
    // destination is returned by standard strcpy()
    return ptr;
}
