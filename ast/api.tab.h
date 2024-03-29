/* A Bison parser, made by GNU Bison 3.7.5.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_API_TAB_H_INCLUDED
# define YY_YY_API_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    INFO = 258,                    /* INFO  */
    AUTHOR = 259,                  /* AUTHOR  */
    EMAIL = 260,                   /* EMAIL  */
    VERSION = 261,                 /* VERSION  */
    EMAIL_ADDR = 262,              /* EMAIL_ADDR  */
    VERSION_VAL = 263,             /* VERSION_VAL  */
    TYPE = 264,                    /* TYPE  */
    SERVICE = 265,                 /* SERVICE  */
    COMMENT = 266,                 /* COMMENT  */
    NAME = 267,                    /* NAME  */
    TAG = 268,                     /* TAG  */
    STRING = 269,                  /* STRING  */
    DECORATOR_HANDLER = 270,       /* DECORATOR_HANDLER  */
    DECORATOR_TOKEN = 271,         /* DECORATOR_TOKEN  */
    METHOD = 272,                  /* METHOD  */
    URI = 273,                     /* URI  */
    RETURN = 274,                  /* RETURN  */
    OPEN_BRACE = 275,              /* OPEN_BRACE  */
    CLOSE_BRACE = 276,             /* CLOSE_BRACE  */
    OPEN_PAREN = 277,              /* OPEN_PAREN  */
    CLOSE_PAREN = 278,             /* CLOSE_PAREN  */
    COLON = 279                    /* COLON  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_API_TAB_H_INCLUDED  */
