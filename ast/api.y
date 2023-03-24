%{
    #include <stdio.h>
    #include <string.h>

    #include "ast.h"

    extern FILE *yyin;
    static struct ast ast;
    static char* comment;
    static inline struct type* current_type() {
        if (ast.types.prev == &ast.types) {
            return NULL;
        }
        return getobj(ast.types.prev, struct type, node);
    }
    static inline struct field* current_field() {
        struct type* type = current_type();
        if (type == NULL) {
            return NULL;
        }
        if (type->fields.prev == &type->fields) {
            return NULL;
        }
        return getobj(type->fields.prev, struct field, node);
    }
    struct type* next_type(struct list_head* node)
    {
        if (node->next == &ast.types) {
            return NULL;
        }
        return getobj(node->next, struct type, node);
    }
    struct field* next_field(struct list_head* node, struct list_head* head)
    {
        if (node->next == head) {
            return NULL;
        }
        return getobj(node->next, struct field, node);
    }
    static inline struct api* current_api() {
        if (ast.service.apis.prev == &ast.service.apis) {
            return NULL;
        }
        return getobj(ast.service.apis.prev, struct api, node);
    }
    struct api* next_api(struct list_head* node)
    {
        if (node->next == &ast.service.apis) {
            return NULL;
        }
        return getobj(node->next, struct api, node);
    }
%}
%language "c"
%token INFO AUTHOR EMAIL VERSION EMAIL_ADDR VERSION_VAL
%token TYPE
%token SERVICE
%token COMMENT
%token NAME STRING TAG
%token METHOD HANDLER URI RETURN
%token OPEN_BRACE CLOSE_BRACE OPEN_PAREN CLOSE_PAREN TAG_SEP COLON SPACE EOL
%right NAME
%%
stmt :
    | stmt INFO OPEN_PAREN info CLOSE_PAREN
    | stmt TYPE type_name OPEN_BRACE type CLOSE_BRACE
    | stmt SERVICE service_name OPEN_BRACE api CLOSE_BRACE
    | stmt COMMENT {
        if (comment) { free(comment); }
        comment = yylval.str;
        yylval.str = NULL;
        if (ast.comment == NULL) {
            ast.comment = comment;
            comment = NULL;
        }
    }
    ;

info : 
    AUTHOR COLON NAME {
        ast.info.author = yylval.str;
        yylval.str = NULL;
    }
    EMAIL COLON EMAIL_ADDR {
        ast.info.email = yylval.str;
        yylval.str = NULL;
    }
    VERSION COLON VERSION_VAL {
        ast.info.version = yylval.str;
        yylval.str = NULL;
    }
    ;

type : 
    | type field
    | type comment
    ;
field: field_name field_type field_tag
    ;
comment: COMMENT {
        if (comment) { free(comment); }
        comment = yylval.str;
        yylval.str = NULL;
    }
    ;
field_tag: TAG {
        struct field* field = current_field();
        field->tag = yylval.str;
        yylval.str = NULL;
    }
    ;

field_name: NAME {
        struct type* type = current_type();
        if (type) {
            struct field* field = malloc(sizeof(*field));
            field->name = yylval.str;
            yylval.str = NULL;
            field->comment = comment;
            comment = NULL;
            list_append(&field->node, &type->fields);
        }
    }
    ;
field_type: NAME {
        struct field* field = current_field();
        field->type = yyval.str;
        yylval.str = NULL;
    }
    ;

type_name: NAME {
        struct type* type = malloc(sizeof(*type));
        INIT_LIST_HEAD(&type->fields);
        list_append(&type->node, &ast.types);
        type->comment = comment;
        comment = NULL;
        type->name = yylval.str;
        yylval.str = NULL;
    }
    ;

service_name: NAME {
        ast.service.comment = comment;
        ast.service.name = yylval.str;
        comment = NULL;
        yylval.str = NULL;
    }
    ;
api:
    | api HANDLER handler
    | api method uri OPEN_PAREN params CLOSE_PAREN RETURN OPEN_PAREN ret CLOSE_PAREN
    | api comment
    ;
method: METHOD {
        struct api* api = current_api();
        api->method = yylval.str;
        yylval.str = NULL;
    }
    ;
uri: URI {
        struct api* api = current_api();
        api->uri = yylval.str;
        yylval.str = NULL;
    }
    ;
params: NAME {
        struct api* api = current_api();
        api->input = yylval.str;
        yylval.str = NULL;
    }
    ;
ret : NAME {
        struct api* api = current_api();
        api->output = yylval.str;
        yylval.str = NULL;
    };
handler: NAME {
        struct api* api = malloc(sizeof(*api));
        api->comment = comment;
        comment = NULL;
        api->handler = yylval.str;
        yylval.str = NULL;
        list_append(&api->node, &ast.service.apis);
    }
    ;
%%

struct ast* yyparser(char* filename)
{
    if (!(yyin = fopen(filename, "r"))) {
        fprintf(stderr, filename);
        return NULL;
    }
    comment = NULL;
    INIT_LIST_HEAD(&ast.types);
    INIT_LIST_HEAD(&ast.service.apis);

    yyparse();
    fclose(yyin);
    return &ast;
}
