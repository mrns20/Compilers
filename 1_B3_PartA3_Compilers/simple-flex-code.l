/* Onoma arxeiou:       simple-flex-code.l
   Perigrafh:           Ypodeigma gia anaptyksh lektikou analyth me xrhsh tou ergaleiou Flex
   Syggrafeas:          Ergasthrio Metaglwttistwn, Tmhma Mhxanikwn Plhroforikhs kai Ypologistwn,
                        Panepisthmio Dytikhs Attikhs
   Sxolia:              To paron programma ylopoiei (me th xrhsh flex) enan aplo lektiko analyth
			pou anagnwrizei kena (space kai tab) kai akeraious (dekadikou systhmatos
			mono!) gia th glwssa Uni-Python	enw diaxeirizetai tous eidikous xarakthres
			neas grammhs '\n' (new line) kai 'EOF' (end of file). Yparxoun anafores
			gia thn anagnwrish metablhtwn, me ton pragmatiko kwdika na exei antikatastathei
			apo to lektiko FILL ME wste na symplhrwthei apo esas. Proairetika o lektikos
			analyths dexetai orismata arxeiwn gia eisodo kai eksodo.
   Odhgies ekteleshs:   Dinete "make" xwris ta eisagwgika ston trexonta katalogo. Enallaktika:
			flex -o simple-flex-code.c simple-flex-code.l
                        gcc -o simple-flex-code simple-flex-code.c
                        ./simple-flex-code
*/

/* H anagnwsh periorizetai se ena mono arxeio kai termatizei sto prwto EOF */
%option  noyywrap

%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Header file pou periexei lista me ola ta tokens */
#include "token.h"

/* Orismos metrhth trexousas grammhs */
int line = 1;

/* Στο παρακάτω τμήμα του κώδικα, οριζούμε τα tokens που θα χρησιμοποιηθούν και αναφέρονται στο token.h αρχείο, με την αντίστοιχη Κανονική Εκφραση. */ 
/*Είναι σημαντικό να αναφέρουμε ότι το σύμβολο @ βρίσκεται σε 2 tokens(OPERATORS & S_WORDS) σύμφωνα με την unipython, και απο την στιγμή που δεν υπάρχει κάποια περεταίρω αναφορά,
  το σύμβολο θα εμφανίζεται ως το token που έχει οριστεί 1ο. 
  Τέλος,τροποποιήσαμε και μερικές απο τις κανονικές εκφράσεις που είχαμε βάλει στο Α-2 μέρος της εργασίας, καθώς παρουσιάστηκαν σφάλματα κατα την διάρκεια της εκτέλεσης του λεκτικού αναλυτή. 
*/

%}

DELIMITER       [ \t]+
DECIMAL        	[+-]?([0]|([1-9][0-9]*)) 
BINARY			[0][b|B][01]+
FLOAT			[+-]?(([1-9][0-9]*)|0)(\.[0-9]+)?([eE][-+]?[0-9]+)?
IMAGINARY		[+-]?(0(\.[0-9]+)+|[1-9][0-9]*(\.[0-9]+)?)([eE][+-]?[0-9]+)?[j]
IDENTIFIER		[a-zA-Z_][a-zA-Z0-9_]*
STRING 			(\"(\\[\\\"'nr]|[^\n\"'\\])*\")|(\'(\\[\\\"'nr]|[^\n\"'\\])*\')
COMMENT			[#].* 		
KEYWORD 		False|class|finally|is|return|None|continue|for|lambda|try|True|def|from|nonlocal|while|and|del|global|not|with|as|elif|if|or|yield|assert|else|import|pass|break|except|in|raise	
OPERATOR		\+|\-|\*|\*\*|\/|\/\/|%|@|<<|>>|&|\||\^|~|<|>|<=|>=|==|!=
S_WORD			\(|\)|\[|\]|\{|\}|,|:|\.|;|@|=|->|\+=|\-=|\*=|\/=|\/\/=|%=|@=|&=|\|=|\^=|>>=|<<=|\*\*=
UNKNOWN_TOKEN   [^ \t\n]+


 /* Στην συνέχεια, ακολουθεί η περιοχή ορισμού των κανόνων που θα υπάρχουν κατα την μεταγλώττιση , δήλαδή τι ενέργειες θα πραγματοποιηθούν με την ανίχνευση περιεχομένου του αρχείου. */

%%
{DELIMITER}     {  }
{KEYWORD}		{ return KEYWORD; }
{OPERATOR}		{ return OPERATOR; }
{S_WORD}		{ return S_WORD; }
{DECIMAL}      	{ return DECIMAL; }
{BINARY}		{ return BINARY; }
{FLOAT}			{ return FLOAT; }
{IMAGINARY}		{ return IMAGINARY; }
{IDENTIFIER}	{ return IDENTIFIER; }
{STRING}		{ return STRING; }
{COMMENT}		{ line++; }
{UNKNOWN_TOKEN}	{ return UNKNOWN_TOKEN; }

\n              { line++; printf("\n"); }
<<EOF>>		{ printf("#END-OF-FILE#\n"); exit(0); }

%%

/* Pinakas me ola ta tokens se antistoixia me tous orismous sto token.h */
char *tname[12] = {"DELIMITER", "DECIMAL", "BINARY", "FLOAT", "IMAGINARY", "IDENTIFIER", "STRING", "COMMENT", "UNKNOWN_TOKEN", "KEYWORD", "OPERATOR", "S_WORD"};

int main(int argc, char **argv){
        int token;

        if(argc == 3){
                if(!(yyin = fopen(argv[1], "r"))) {
                        fprintf(stderr, "Cannot read file: %s\n", argv[1]);
                        return 1;
                }
                if(!(yyout = fopen(argv[2], "w"))) {
                        fprintf(stderr, "Cannot create file: %s\n", argv[2]);
                        return 1;
                }
        }
        else if(argc == 2){
                if(!(yyin = fopen(argv[1], "r"))) {
                        fprintf(stderr, "Cannot read file: %s\n", argv[1]);
                        return 1;
                }
        }


        /*   Προσθέσαμε μια δομή επιλογής if , έτσι ώστε η εκτύπωση να συνάδει με τους κάνόνες της uni-python.    */


        while( (token=yylex()) >= 0){
			if(tname[token-1]=="KEYWORD"){
				fprintf(yyout, "\tLine=%d, token=keyword(%s), value=\"%s\"\n", line, yytext, yytext);
			}
			else if(tname[token-1]=="OPERATOR"){
				fprintf(yyout, "\tLine=%d, token=operator(%s), value=\"%s\"\n", line, yytext, yytext);
			}
			else if(tname[token-1]=="S_WORD"){
				fprintf(yyout, "\tLine=%d, token=s_word(%s), value=\"%s\"\n", line, yytext, yytext);
			}
			else if(tname[token-1]=="UNKNOWN_TOKEN"){
				fprintf(yyout, "\tLine=%d, %s, value=\"%s\"\n", line, tname[token-1], yytext);
			}
			else{
				fprintf(yyout, "\tLine=%d, token=%s, value=\"%s\"\n", line, tname[token-1], yytext);
				}
					
			}
        return 0;
}
