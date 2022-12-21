%{
#include <stdio.h>
#include <string.h>
#include <string.h>
#include "y.tab.h"

typedef struct sLine {
	int pos;
	int len;
	int textType;
	int titleType;
	int style;
	int itemType;
}line;

#define NORMAL_TEXT 0
#define ITEM_TEXT 1
#define TITLE_TEXT 2
#define EMPY_LINE 3

#define NONE_STYLE -1
#define ITALIC_STYLE 0
#define BOLD_STYLE 1
#define BOLD_ITALIC_STYLE 2

#define NONE_ITEM -1
#define FIRST_ITEM 0
#define NEW_ITEM 1
#define LAST_ITEM 2
#define NEWandLAST_ITEM 3
#define FIRSTandLAST_ITEM 4

#define TAB_SIZE 30

line tab[TAB_SIZE];
char ch[500];
int chIndex = 0;
int tabIndex = 0;
int titleLevel = 0;
int isInParagraph = 0;

void getTextBetween(const char* text, const int from, const int to, char* out)
{
    for(int i = from, j = 0; i < to; i++, j++) {
        out[j] = text[i];
    }
}

void formatText(line l, char* out) {
	if(l.style == ITALIC_STYLE)
		strcat(out, "<i>");
	else if(l.style == BOLD_STYLE)
		strcat(out, "<strong>");
	else if(l.style == BOLD_ITALIC_STYLE)
		strcat(out, "<i><strong>");
    
    char* temp = malloc(sizeof(char)*(l.len+1));
    memset(temp, '\0', sizeof(char)*(l.len+1));
	getTextBetween(ch, l.pos, l.pos+l.len, temp);
	strcat(out, temp);
	free(temp);

	if(l.style == ITALIC_STYLE)
		strcat(out, "</i>");
	else if(l.style == BOLD_STYLE)
		strcat(out, "</strong>");
	else if(l.style == BOLD_ITALIC_STYLE)
		strcat(out, "</strong></i>");
}

void endParagraph() {
	if(isInParagraph)
	{
		isInParagraph = 0;
		printf("</p>\n");
	}
}

void textProcess(line l) {
	char* temp = malloc(sizeof(char)*1024);
    memset(temp, '\0', sizeof(char)*1024);
	formatText(l, temp);
	if(isInParagraph)
		printf("%s", temp);
	else {
		isInParagraph = 1;
		printf("<p>%s", temp);
	}
    free(temp);
}

void listProcess(line l) {
	endParagraph();
	char* temp = malloc(sizeof(char)*1024);
    memset(temp, '\0', sizeof(char)*1024);

	formatText(l, temp);
    if(l.itemType == 0)
        printf("<ul>\n\t<li>%s", temp);
    else if(l.itemType == 1)
        printf("</li>\n\t<li>%s", temp);
    else if(l.itemType == 2)
        printf("%s</li>\n</ul>\n", temp);
    else if(l.itemType == 3)
        printf("</li>\n\t<li>%s</li>\n</ul>\n", temp);
    else
        printf("<ul>\n\t<li>%s</li>\n</ul>\n", temp);
    free(temp);
}

void titleProcess(line l) {
	endParagraph();
    char* temp = malloc(sizeof(char)*(l.len+1));
    memset(temp, '\0', sizeof(char)*(l.len+1));
    getTextBetween(ch, l.pos, l.pos+l.len, temp);
    printf("<h%d>%s</h%d>\n", l.titleType, temp,l.titleType);
    free(temp);
}

void emptyLineProcess(line l) 
{
	if(isInParagraph) {
		isInParagraph = 0;
		printf("</p>\n");
	}
}

void insertText(char* text)
{
	strcat(ch, text);
	line l = {chIndex, strlen(text), NORMAL_TEXT, -1, NONE_STYLE, NONE_ITEM};
	tab[tabIndex] = l;
	tabIndex++;
	chIndex += strlen(text);
}

void insertTitle(char* text)
{
	strcat(ch, text);
	line l = {chIndex, strlen(text), TITLE_TEXT, titleLevel, NONE_STYLE, NONE_ITEM};
	tab[tabIndex] = l;
	tabIndex++;
	chIndex += strlen(text);
}

void insertItem(char* text)
{
	strcat(ch, text);
	line l = {chIndex, strlen(text), ITEM_TEXT, -1, NONE_STYLE, NONE_ITEM};
	tab[tabIndex] = l;
	tabIndex++;
	chIndex += strlen(text);
}

void insertEmptyLine() 
{
	line l = {chIndex, 1, EMPY_LINE, -1, NONE_ITEM, NONE_ITEM};
	tab[tabIndex] = l;
	tabIndex++;
}

int getTitleLevel(char* title)
{
	int c = 0;
	for(int i = 0; i < strlen(title); i++)
		if(title[i] == '#')
			c++;
	return c;
}

char* clean(char* text) {
    char* new; // output
    if(!(new = calloc(strlen(text)+1, sizeof(char)))) { // init
        fprintf(stderr, "%s\n", strerror(errno)); // if can't init -> exit with error
        exit(errno);
    }

    size_t i = 0; // iterator on text
    size_t j = 0; // iterator on new
    for(; i < strlen(text); i++) { // For each char
        if(i < strlen(text)-1 && text[i] == '\\' && text[i+1] == '*') { // if not at whe end and text is backslash
                new[j] = '*'; // add *
                i++;// move to right (text)
            }
         else {
                new[j] = text[i];  // just add the char
            }
        j++;// move to right (new)
        }
    
    return new;
}

%}

%start TITLE
%start ITEM
STRING ([^#*_\n]|"\\*")+
ENDLINE (\n|\r\n)

%%

(" "|\t)+	{}

<INITIAL>{STRING}	{
	printf("Piece of text : %s\n", clean(yytext));
	yylval=tabIndex;
	insertText(clean(yytext));
	return TXT;
}

<TITLE>{STRING}	{
	printf("Piece of text : %s\n",yytext);
	yylval=tabIndex;
	insertTitle(yytext);
	return TXT;
}

<ITEM>{STRING}	{
	printf("Piece of text : %s\n", yytext);
	yylval=tabIndex;
	insertItem(yytext);
	return TXT;
}

<INITIAL>^" "{0,3}"#"{1,6}" "+	{
	printf("Title tag\n");
	BEGIN TITLE;
	titleLevel = getTitleLevel(yytext);
	return BALTIT;
}

<TITLE>{ENDLINE}(" "*{ENDLINE})+|\n	{
	printf("End of title\n");
	BEGIN INITIAL;
	return FINTIT;
}

<INITIAL>{ENDLINE}(" "*{ENDLINE})+	{
	printf("Blank line\n");
	insertEmptyLine();
	return LIGVID;
}

<INITIAL>^"*"" "+	{
	printf("Start of list\n");
	BEGIN ITEM;
	yylval=tabIndex;
	return DEBLIST;
}

<ITEM>^"*"" "+	{
	printf("List item\n");
	yylval=tabIndex;
	return ITEMLIST;
}

<ITEM>{ENDLINE}(" "*{ENDLINE})+	{
	printf("End de list\n");
	BEGIN INITIAL;
	yylval=tabIndex-1;
	return FINLIST;
}

"*" {
	printf("Asterisk\n");
	return ETOILE;
}

. {
	printf("Lexical error : Character %s not allowed\n",yytext);
}

%%


int yywrap() {
	// Affichage chaine
	printf("String :\n %s\n", ch);

	// Affichage tableau
	printf("\n------------------------\n");
	for(int i = 0; i < TAB_SIZE; i++)
		printf("| %d\t| %d\t| %d\t| %d\t| %d\t| %d\t|\n", tab[i].pos, tab[i].len, tab[i].textType, tab[i].titleType, tab[i].style, tab[i].itemType); // display line
	printf("------------------------\n");


    printf("<!DOCTYPE html>\n");
    printf("<html>\n");
    printf("<head>\n");
    printf("\t <title>Title html</title>\n");
    printf("\t <meta charset=\"utf-8\"/>\n");
    printf("</head>\n");
    printf("<body>\n");

    for(int i = 0; i < TAB_SIZE; i++) {
        if(tab[i].len != 0) {

            if(tab[i].textType == NORMAL_TEXT)
                textProcess(tab[i]);
            else if(tab[i].textType == ITEM_TEXT)
                listProcess(tab[i]);
            else if(tab[i].textType == EMPY_LINE)
				emptyLineProcess(tab[i]);
			else
                titleProcess(tab[i]);
        }
    }
	endParagraph();

    printf("</body>\n");
    printf("</html>");

	return 1;
}
