%{
	#include <stdio.h>
	#include <stdlib.h>
	int yylex();
	void yyerror(char *s);

	typedef struct sLine {
		int pos;
		int len;
		int textType;
		int titleType;
		int style;
		int itemType;
	}line;

	#define TAB_SIZE 30
	extern line tab[TAB_SIZE];

	#define NORMAL_TEXT 0
	#define ITEM_TEXT 1
	#define TITLE_TEXT 2

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

	int lastIndexEndlist=0;
	int lastIndexDeblist=0;
	int lastIndexItemlist=0;
%}

%token TXT BALTIT FINTIT LIGVID DEBLIST ITEMLIST FINLIST ETOILE
%start fichier

%%
fichier: element | element fichier {};

element: TXT | LIGVID | titre | liste |texte_formatte {};

titre: BALTIT TXT FINTIT {};

liste: DEBLIST liste_textes suite_liste {
																				if($1==lastIndexEndlist)
																						tab[$1].itemType=FIRSTandLAST_ITEM;
																				else
																						tab[$1].itemType=FIRST_ITEM;
																				};

suite_liste: ITEMLIST liste_textes suite_liste {
																								if($1==lastIndexEndlist)
																										tab[$1].itemType=NEWandLAST_ITEM;
																								else
																						   			tab[$1].itemType=NEW_ITEM;
																							 }
						| FINLIST {
											tab[$1].itemType=LAST_ITEM;
											lastIndexEndlist=$1;
											};

texte_formatte: italique | gras | grasitalique{};

italique: ETOILE TXT ETOILE {tab[$2].style=ITALIC_STYLE;};

gras: ETOILE ETOILE TXT ETOILE ETOILE {tab[$3].style=BOLD_STYLE;};

grasitalique: ETOILE ETOILE ETOILE TXT ETOILE ETOILE ETOILE {tab[$4].style=BOLD_ITALIC_STYLE;};

liste_textes: TXT | texte_formatte | TXT liste_textes | texte_formatte liste_textes {};
%%

int main()
{
	yyparse();
	return 0;
}

void yyerror(char *s)
{
	fprintf(stderr,"erreur %s\n",s);
}
