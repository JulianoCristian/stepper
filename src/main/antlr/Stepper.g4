
grammar Stepper;

program
    : annotation* 'state' programName=ID '{' statement+ '}'
    ;

// control statements

annotation
    : '@' ID '(' scalar ')'
    ;

forStatement
    : 'for' '(' var=ID '=' expr ';' limiting=expr ';' (incVar=ID complexAssign)? delta=expr ')' statementBlock #forClassic
    | 'for' '(' ID 'in' iterable=expr ')' statementBlock     #forIteration
    ;

ifStatement
    : IF '(' ifCondition=expr ')' ifBlock=statementBlock
        (ELSE elseBlock=statementBlock)?
    ;

whileStatement
    : 'while' '(' expr ')' statementBlock
    ;

whenStatement
    : 'when' '{'
        ('case' caseExpr=expr ':' statementBlock)+
        ('else' statementBlock)?
    '}'
    ;

statementBlock
    : '{' statement+ '}'
    | statement
    ;

statement
    : assignment                        #statementAssignment
    | task                              #statementTask
    | forStatement                      #statementFor
    | ifStatement                       #statementIf
    | whileStatement                    #statementWhile
    | whenStatement                     #statementWhen
    ;

assignment
    : dereference ASSIGN task SEMICOLON?                           #assignmentTask
    | dereference complexAssign expr ';'                           #assignmentExpr
    | dereference ASSIGN jsonObject SEMICOLON?                     #assignmentJson
    | dereference ASSIGN '[' value (',' value)* ']' SEMICOLON?     #assignmentJsonArray
    ;

expr
    : scalar
    | NULL
    | expressionStatement
    | expr INCR
    | expr DECR
    | INCR expr
    | DECR expr
    | expr MUL expr
    | expr DIV expr
    | expr ADD expr
    | expr SUB expr
    | '(' expr ')'
    | expr AND expr
    | expr OR expr
    | NOT expr
    | expr EQUALITY expr
    | expr LE expr
    | expr LT expr
    | expr GE expr
    | expr GT expr
    ;

expressionStatement
    : dereference indexingDereference? ('.' expressionStatement)?
    | methodCall indexingDereference? ('.' expressionStatement)?
    ;

methodCall
    : ID '(' ')'
    | ID '(' expr (',' expr)* ')'
    ;

indexingDereference
    : '[' expr ']'
    ;

dereference
    : ID ('.' ID )*
    ;

task
    : 'task' ('(' taskName=STRING ')')? jsonObject
    ;

jsonObject
    : '{' pair (',' pair)* '}'
    ;

pair
    : STRING ':' value
;

value
   : STRING                             #valueString
   | NUMBER                             #valueNum
   | TRUE                               #valueTrue
   | FALSE                              #valueFalse
   | '{' pair (',' pair)* '}'           #valueObj
   | '{' '}'                            #valueObjEmpty
   | '[' value (',' value)* ']'         #valueArr
   | '[' ']'                            #valueArrEmpty
;

scalar
    : STRING
    | NUMBER
    | TRUE
    | FALSE
    ;

complexAssign
    : (ASSIGN | PLUSASSIGN | MINUSASSIGN | MULTASSIGN | DIVASSIGN)
    ;

// lexer rules

NUMBER
   : '-'? INT ('.' [0-9] +)? EXP?
   ;

STRING
   : '"' (ESC | SAFECODEPOINT)* '"'
   ;

// operators
INCR: '++';
DECR: '--';
MUL: '*';
DIV: '/';
ADD: '+';
SUB: '-';
AND: '&&';
OR: '||';
NOT: '!';
EQUALITY: '==';
LE: '<=';
LT: '<';
GE: '>=';
GT: '>';
ASSIGN: '=';
PLUSASSIGN: '+=';
MINUSASSIGN: '-=';
MULTASSIGN: '*=';
DIVASSIGN: '/=';

// keywords
TRUE: 'true';
FALSE: 'false';
NULL: 'null';
IF: 'if';
ELSE: 'else';

// symbols
SEMICOLON: ';';

ID
    : ALPHA (ALPHA | DIGIT)*
    ;

fragment ESC
   : '\\' (["\\/bfnrt])
   ;

fragment SAFECODEPOINT
   : ~ ["\\\u0000-\u001F]
   ;

fragment INT
   : '0' | [1-9] DIGIT*
   ;

// no leading zeros

fragment EXP
   : [Ee] [+\-]? INT
   ;

fragment DIGIT
    : [0-9]
    ;

fragment ALPHA
    : [a-zA-Z_]
    ;

COMMENT
    : '/*' .*? '*/' -> skip
    ;

LINE_COMMENT
    : '//' ~[\r\n]* -> skip
    ;

WS
   : [ \t\n\r]+ -> skip
   ;