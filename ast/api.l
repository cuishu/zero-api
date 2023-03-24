%{
#include <stdio.h>
#include <string.h>

#include "ast.h"
#include "api.tab.h"

#define COPY(dist, src) do {        \
    if (dist) { free(dist); }       \
    dist = malloc(strlen(src)+1);   \
    strcpy(dist, src);              \
} while(0)

%}

%option noyywrap
%option pointer
%option yylineno
%x C_COMMENT

name [-a-zA-Z\[\]]
email [-a-zA-Z0-9]+@[-a-zA-Z0-9]+\.[-a-zA-Z]+
version v[0-9].[0-9].[0-9]
tag `([0-9A-Za-z;:\",_-])+`
uri \/([0-9A-Za-z\/_-])+
string \"(\\.|[:"])*\"

%%
"info" { return INFO; }
"author" { return AUTHOR; }
"email" { return EMAIL; }

{email} {
    COPY(yylval.str, yytext);
    return EMAIL_ADDR;
}

{version} {
    COPY(yylval.str, yytext);
    return VERSION_VAL;
}

{uri} {
    COPY(yylval.str, yytext);
    return URI;
}

"version" { return VERSION; }
"type" { return TYPE; }
"service" { return SERVICE; }

(get|GET|post|POST|put|PUT|delete|DELETE) {
    COPY(yylval.str, yytext);
    return METHOD;
}
"@handler" { return HANDLER; }
"return" { return RETURN; }
"returns" { return RETURN; }

{name}+ {
    COPY(yylval.str, yytext);
    return NAME;
}

"{" { return OPEN_BRACE; }
"}" { return CLOSE_BRACE; }

"(" { return OPEN_PAREN; }
")" { return CLOSE_PAREN; }

":" { return COLON; }


{string} {
    COPY(yylval.str, yytext);
    return STRING;
}

{tag} {
    COPY(yylval.str, yytext);
    return TAG;
}

"/*"                { BEGIN(C_COMMENT); }
<C_COMMENT>"*/"     { BEGIN(INITIAL); }
<C_COMMENT>([^*]|\n)+|. {
    if (yylval.str) { free(yylval.str); }
    int len = strlen(yytext);
    yylval.str = malloc(len+6);
    strncpy(yylval.str, "/*", 2);
    strncpy(yylval.str+2, yytext, len);
    strcpy(yylval.str+2+len, "*/");
    return COMMENT;
}
<C_COMMENT><<EOF>>  { fprintf(stderr, "%d: Unterminated comment\n",
                yylineno); return 0; }

"//".*\n {
    COPY(yylval.str, yytext);
    return COMMENT;
}

[ \t\n] {}

. {
    printf("error: illeagal character '%s'\n", yytext);
}
%%

void yyerror(const char *msg) {
    fprintf(stderr, "error: %s %s\n", yytext, msg);
}