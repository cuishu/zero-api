#ifndef AST_H
#define AST_H

#include <stdlib.h>
#include <stdbool.h>

#include "list.h"

#define STR_MAX_LEN 2048

extern int yyparse();
extern int yylex();
extern void yyerror(const char*);
struct ast* yyparser(char* filename);

struct info {
    char* author;
    char* email;
    char* version;
};

struct type {
    char* comment;
    char* name;
    struct list_head fields;
    struct list_head node;
};

struct field {
    char* comment;
    char* name;
    char* type;
    char* tag;
    struct list_head node;
};

struct api {
    char* comment;
    char* handler;
    char* method;
    char* uri;
    char* input;
    char* output;
    struct list_head node;
};

struct service {
    char* comment;
    char* name;
    struct list_head apis;
};

struct ast {
    char* comment;
    struct info info;
    struct list_head types;
    struct service service;
};

struct type* next_type(struct list_head* node);
struct field* next_field(struct list_head* node, struct list_head* head);
struct api* next_api(struct list_head* node);

struct _yystype {
    char* str;
};

#define YYSTYPE struct _yystype

#endif