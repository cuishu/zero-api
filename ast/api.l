%{
#include <stdio.h>
#include <string.h>

#include "ast.h"
#include "api.tab.h"

#define LINE_SIZE   (1024*64)

struct syntax_info {
    int line_no;
    int column;
    int column_offset;
    char line[LINE_SIZE];
};

extern char* filename;
static struct syntax_info syntax_info = {.line_no = 0, .column = 1, .line = {0}};

#define YY_INPUT(buf,result,max_size) \
    { \
        int c = '*'; \
        int n; \
        for ( n = 0; n < max_size && \
             (c = getc( yyin )) != EOF && c != '\n'; ++n ) { \
            buf[n] = (char) c; \
        } \
        if ( c == '\n' ) { \
            buf[n++] = (char) c; \
            syntax_info.line_no ++; \
            syntax_info.column = 1; \
            syntax_info.column_offset = 0; \
            strncpy(syntax_info.line, buf, LINE_SIZE);\
            syntax_info.line[n] = '\0'; \
        } \
        if ( c == EOF && ferror( yyin ) ) \
            YY_FATAL_ERROR( "input in flex scanner failed" ); \
            result = n; \
        }

#define HANDLE_COLUMN(str)                         \
    if (str!=NULL && *str == '\t') {               \
        syntax_info.column += 1;                   \
        syntax_info.column_offset+=8;              \
    } else if (str != NULL) {                      \
        int n = strlen(str);                       \
        syntax_info.column += n;                   \
        syntax_info.column_offset += n;            \
    }

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

name [a-zA-Z\[\]0-9]
email [-a-zA-Z0-9]+@[-a-zA-Z0-9]+\.[-a-zA-Z]+
version v[0-9].[0-9].[0-9]
tag `([0-9A-Za-z;:\",_-])+`
uri \/([0-9A-Za-z\/_-])+
string \"(\\.|[:"])*\"

%%
"info" { HANDLE_COLUMN(yytext); return INFO; }
"author" { HANDLE_COLUMN(yytext); return AUTHOR; }
"email" { HANDLE_COLUMN(yytext); return EMAIL; }

{email} {
    HANDLE_COLUMN(yytext);
    COPY(yylval.str, yytext);
    return EMAIL_ADDR;
}

{version} {
    HANDLE_COLUMN(yytext);
    COPY(yylval.str, yytext);
    return VERSION_VAL;
}

{uri} {
    HANDLE_COLUMN(yytext);
    COPY(yylval.str, yytext);
    return URI;
}

"version" { HANDLE_COLUMN(yytext); return VERSION; }
"type" { HANDLE_COLUMN(yytext); return TYPE; }
"service" { HANDLE_COLUMN(yytext); return SERVICE; }

(get|GET|post|POST|put|PUT|delete|DELETE) {
    HANDLE_COLUMN(yytext);
    COPY(yylval.str, yytext);
    return METHOD;
}
"@handler" { HANDLE_COLUMN(yytext); return HANDLER; }
"return" { HANDLE_COLUMN(yytext); return RETURN; }
"returns" { HANDLE_COLUMN(yytext); return RETURN; }

{name}+ {
    HANDLE_COLUMN(yytext);
    COPY(yylval.str, yytext);
    return NAME;
}

"{" { HANDLE_COLUMN(yytext); return OPEN_BRACE; }
"}" { HANDLE_COLUMN(yytext); return CLOSE_BRACE; }

"(" { HANDLE_COLUMN(yytext); return OPEN_PAREN; }
")" { HANDLE_COLUMN(yytext); return CLOSE_PAREN; }

":" { HANDLE_COLUMN(yytext); return COLON; }


{string} {
    HANDLE_COLUMN(yytext);
    COPY(yylval.str, yytext);
    return STRING;
}

{tag} {
    HANDLE_COLUMN(yytext);
    COPY(yylval.str, yytext);
    return TAG;
}

"/*"([^\*]|(\*)*[^\*/])*(\*)*"*/" {
    COPY(yylval.str, yytext);
    return COMMENT;
}

"//".*\n {
    COPY(yylval.str, yytext);
    return COMMENT;
}

[ \t\n] { HANDLE_COLUMN(yytext); }

. {
    printf("error: illeagal character '%s'\n", yytext);
    fprintf(stderr, "line %d column %d\n", syntax_info.line_no, syntax_info.column);
    fprintf(stderr, "%s", syntax_info.line);
    int wordlen = strlen(yytext);
    for (int i=0; i < syntax_info.column_offset - wordlen+1; ++i) {
        fprintf(stderr, "\033[32m_\033[0m");
    }
    for (int i = 0; i < wordlen; ++i) {
        fprintf(stderr, "\033[31m^\n\033[0m");
    }
}
%%

void yyerror(const char *msg) {
    int wordlen = strlen(yytext);
    fprintf(stderr, "\033[31m%s\033[0m: %s\n", msg, filename);
    fprintf(stderr, "line %d column %d\n",
        syntax_info.line_no, syntax_info.column - wordlen);
    fprintf(stderr, "%s", syntax_info.line);
    for (int i=0; i < syntax_info.column_offset - wordlen; ++i) {
        fprintf(stderr, "\033[32m_\033[0m");
    }
    fprintf(stderr, "\033[31m");
    for (int i = 0; i < wordlen; ++i) {
        fprintf(stderr, "^");
    }
    fprintf(stderr, "\033[0m");
}