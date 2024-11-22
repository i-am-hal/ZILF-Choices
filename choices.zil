"Choices - Alastar Slater"

<PACKAGE "CHOICES">

<ENTRY V-LOOK CHOICES ENTRYFCN CHOICEEXIT GOTO>

;"The maximum value allowed in current choice (only modified by functions, don't touch.)"
<GLOBAL PROP-CHOICES-MAX 0>
;"The minimum value allowed in current choice (only modified by functions, don't touch.)"
<GLOBAL PROP-CHOICES-MIN 0>

;"Saves the length of choices property so that we can interate through each instance"
<CONSTANT PROP-CHOICE-LEN 6 ;3>

<PROPDEF CHOICES     <>
    ;(CHOICES "MANY" I:FIX S:STRING TURN TO R:ROOM = "MANY" <WORD .I> <STRING .S> <ROOM .R>)
    (CHOICES "MANY" I:FIX S:STRING GO TO R:ROOM = "MANY" <WORD .I> <STRING .S> <ROOM .R>)
    (CHOICES "MANY" I:FIX S:STRING TO R:ROOM = "MANY" <WORD .I> <STRING .S> <ROOM .R>)>

;"Function that will be executed when entering a room."
<PROPDEF ENTRYFCN <>>

;"The room to automatically route to after executing entry function"
<PROPDEF CHOICEEXIT <>>

;"Respecfying the macros neccesary to redefine GOTO"
<DEFMAC ORDERING? ()
    '<N=? ,WINNER ,PLAYER>>
<DEFMAC RESET-WINNER ()
    '<SETG WINNER ,PLAYER>>

<SET REDEFINE T>

<ROUTINE GOTO (RM "AUX" WAS-LIT F (CO <>) (OWINNER <>) (ENTRY-FCN <>) (CHOICES? <>) (CHOICE-EXIT <>) CHOICE-ROOM?)
    <COND (<ORDERING?>
           <SET OWINNER ,WINNER>
           <RESET-WINNER>)>
    <SET WAS-LIT ,HERE-LIT>
    <SETG HERE .RM>
    <MOVE ,WINNER ,HERE>
    <APPLY <GETP .RM ,P?ACTION> ,M-ENTER>
    ;"Call SEARCH-FOR-LIGHT down here in case M-ENTER adjusts the light."
    <SETG HERE-LIT <SEARCH-FOR-LIGHT>>

    <AND ;"Pull room's entry function, if exists"
        <SET ENTRY-FCN <GETP ,HERE ,P?ENTRYFCN>>
        ;"Execute the function before contents are read of room"
        <APPLY .ENTRY-FCN>>
    ;"Check if this is a choices room"
    <SET CHOICES? <GETPT ,HERE ,P?CHOICES>>
    ;"Pull a choice exit if one exists"
    <SET CHOICE-EXIT <GETP ,HERE ,P?CHOICEEXIT>>
    ;"Is a choice exit if there are choices, or a choice exit here"
    <SET CHOICE-ROOM? <OR .CHOICES? .CHOICE-EXIT>>

    ;"moved descriptors into GOTO so they'll be called when you call GOTO from a PER routine, etc"
    <COND (<NOT .WAS-LIT>
           <COND (,HERE-LIT
                  <SET F <DARKNESS-F ,M-DARK-TO-LIT>>)
                 (<OR <DARKNESS-F ,M-DARK-TO-DARK>
                      <DARKNESS-F ,M-LOOK>>
                  <SET F T>)>)
          (,HERE-LIT)
          (<OR <DARKNESS-F ,M-LIT-TO-DARK>
               <DARKNESS-F ,M-LOOK>>
           <SET F T>)>
    <COND
        ;"If normal lit room, operate as normal"
        (<AND <NOT .F> <NOT .CHOICE-ROOM?> <DESCRIBE-ROOM ,HERE>>
           <DESCRIBE-OBJECTS ,HERE>)
        
        ;"If this is a choice room then we will pull for the user's choice"
        (.CHOICE-ROOM?
            <SET CO T>
            <DESCRIBE-ROOM ,HERE T>
            <CHOICES-CAPTIVE-INPUT ,HERE>)
        
        ;"If there is a choice exit, then we will just divert to that new location"
        (.CHOICE-EXIT
            <SET CO T>
            <GOTO .CHOICE-EXIT>)>
    <COND (<AND ,HERE-LIT <NOT .CO>> <FSET ,HERE ,TOUCHBIT>)>
    <COND (.OWINNER <SETG WINNER .OWINNER>)>
    <RTRUE>>

;"Redefines the V-LOOK function so that it checks (and uses) any choices inplemented for the user."
<ROUTINE V-LOOK ("AUX" (FCN <>) EXIT)
    <COND 
        ;"If a room has any twine-like choices, describe the room, then go through the choices"
        (<AND <GETPT ,HERE ,P?CHOICES> <DESCRIBE-ROOM ,HERE T>>
            <CHOICES-CAPTIVE-INPUT ,HERE>
            <RTRUE>)
        
        ;"If this room has choice exit, reroute there (and execute entry function if exists)"
        (<SET EXIT <GETPT ,HERE ,P?CHOICEEXIT>>
            <GOTO .EXIT>)

        ;"Normal V-LOOK behavior with a room that doesn't have any twine-like choices"
        (<DESCRIBE-ROOM ,HERE T>
           <DESCRIBE-OBJECTS ,HERE>)>>

;"Display all of the defined choices from the choices table, let user see their options"
<ROUTINE DISPLAY-CHOICES (TBL NUM-CHOICES "AUX" SIZE)
    <SET SIZE </ <PTSIZE .TBL> ,PROP-CHOICE-LEN>> ;"Store size of the pt table"

    <REPEAT ((I 0) CHOICE-NUM TEXT OFST)
        ;<TELL CR "I = " N .I " S = " N .SIZE >

        ;"If we have exited the bounds of the defined choices, exit"
        <COND (<=? .I .SIZE> <RETURN>)>

        ;"Defines the offset, we can now add offset with digits to access each property"
        <SET OFST <* 3 ;,PROP-CHOICE-LEN .I>>

        ;"Retrieve the number"
        <SET CHOICE-NUM <GET ;/B .TBL .OFST>>
        <SET TEXT       <GET ;/B .TBL <+ 1 .OFST>>>

        ;"Start of loop, set min and max to first number"
        <COND (<=? .I 0>
            <SETG PROP-CHOICES-MAX .CHOICE-NUM>
            <SETG PROP-CHOICES-MIN .CHOICE-NUM>)>
        
        ;"If this choice number is larger than max, update max"
        <COND (<G? .CHOICE-NUM ,PROP-CHOICES-MAX>
            <SETG PROP-CHOICES-MAX .CHOICE-NUM>)>

        ;"If this choice number is smaller than min, update min"
        <COND (<L? .CHOICE-NUM ,PROP-CHOICES-MIN>
            <SETG PROP-CHOICES-MIN .CHOICE-NUM>)>

        ;"Print out the choice for the user to see"
        <TELL CR N .CHOICE-NUM ". " .TEXT>

        <SET I <+ .I 1>>>>

;"Recieves a key input from the user, constrainted from 1-9"
<ROUTINE GET-DIGIT-INPUT ("AUX" KEY MIN MAX)
    ;"Calculate the min and max values so we can check"
    <SET MIN <+ 48 ,PROP-CHOICES-MIN>>
    <SET MAX <+ 48 ,PROP-CHOICES-MAX>>

    <TELL CR "> ">

    <REPEAT ()
        ;"Recieve a keypress from the user"
        <SET KEY <INPUT 1>>

        ;"If Key is not in range 0-9, retrieve input again. (Also make sure in acceptable ranges)"
        <COND (<AND <G=? .KEY 48> <L=? .KEY 57> <G=? .KEY .MIN> <L=? .KEY .MAX>>
                    <RETURN>)>>
    
    <SET KEY <- .KEY 48>>
    ;<TELL N .KEY>
    
    ;"Subtract 48 to deduce the number itself, not ascii value"
    <RETURN .KEY>>

;"Takes the room with the choices property, then displays all the choices for the user, and makes the
player pick which choice they want. Moves the player to that room for their choice after."
<ROUTINE CHOICES-CAPTIVE-INPUT (RM "AUX" TBL ;CH-TXT SIZE USER-CHOICE NEW-ROOM)
    <SET TBL    <GETPT .RM ,P?CHOICES>>
    ;<SET CH-TXT <GETP .RM ,P?CHOICE-TEXT>>

    ;"If doesn't have choices property, then don't progress, checking inputs from user and making the choices"
    <COND (.TBL
        ;"If defined, print out the choice text"
        ;<AND .CH-TXT <TELL CR .CH-TXT>>
        ;"Divide size of property table by prop choice len to derive number of choices"
        <SET SIZE </ <PTSIZE .TBL> ,PROP-CHOICE-LEN>>

        ;"Display all of the choices for the player to choose between"
        <DISPLAY-CHOICES .TBL .SIZE>

        ;"Gets a single digit input from the user for making acceptable choice"
        <SET USER-CHOICE <GET-DIGIT-INPUT>>

        <REPEAT ((I 0) CHOICE-NUM TEXT CHOICE-ROOM OFST)
            ;"If we have found which choice the user wants to make, save the new room, exit loop"
            <COND (<=? .USER-CHOICE .CHOICE-NUM>
                    <SET NEW-ROOM .CHOICE-ROOM>
                    <RETURN>)>

            ;"Defines the offset, we can now add offset with digits to access each property"
            <SET OFST <* 3 ;,PROP-CHOICE-LEN .I>>

            ;"Retrieve the number"
            <SET CHOICE-NUM  <GET ;/B .TBL .OFST>>
            <SET TEXT        <GET ;/B .TBL <+ 1 .OFST>>>
            ;"Retrieve the room that we should go to if the player choice this"
            <SET CHOICE-ROOM <GET ;/B .TBL <+ 2 .OFST>>>
            
            <SET I <+ .I 1>>>)>
    
    ;"Print out the digit of the user's choice, then move into new room"
    <TELL N .USER-CHOICE CR CR>
    ;<SETG ,HERE .NEW-ROOM>
    ;<MOVE ,PLAYER ,HERE>
    ;<V-LOOK>
    <GOTO .NEW-ROOM>>

;<ROOM OUTSIDE (DESC "OUTSIDE")
    (IN ROOMS)
    (LDESC "This is outside of your house.")
    (FLAGS RLANDBIT LIGHTBIT)
    (CHOICES
        1 "Go back inside." TO LIVING-ROOM)>

;<ROOM LIVING-ROOM (DESC "LIVING ROOM")
    (IN ROOMS)
    (LDESC "This is the living room.")
    (FLAGS RLANDBIT LIGHTBIT)
    (CHOICES
        1 "Go outside." GO TO OUTSIDE
        2 "Go back into your room." GO TO BEDROOM)>

;<ROOM BEDROOM (DESC "BEDROOM")
    (IN ROOMS)
    (LDESC "This is your bedroom.")
    (FLAGS RLANDBIT LIGHTBIT)
    (CHOICES
        1 "Go to living room." TURN TO LIVING-ROOM)>

;<ROUTINE GO ()
    <SETG HERE ,BEDROOM>
    <MOVE ,PLAYER ,HERE>
    <CRLF> <V-VERSION>
    <CRLF> <V-LOOK>
    <UPDATE-STATUS-LINE>
    <MAIN-LOOP>>

<ENDPACKAGE>
