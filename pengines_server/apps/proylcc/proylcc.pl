:- module(proylcc,
	[  
		put/8,
		checkRowClues/4,
		checkColClues/4,
		checkCluesInitial/6
	]).

:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY is the result of replacing the occurrence of X in position XIndex of Xs by Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%

put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, RowSat, ColSat):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),
	checkRowClues(RowN , RowsClues , RowSat , NewGrid),
	checkColClues(ColN , ColsClues , ColSat , NewGrid).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


checkCluesInitial([RowN, ColN], RowsClues, ColsClues, Grid, RowSat, ColSat):-
	checkRowClues(RowN , RowsClues , RowSat , Grid),
	checkColClues(ColN , ColsClues , ColSat , Grid).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


checkRowClues(RowN , RowsClues , true , Grid):-
	nth0(RowN , Grid , Row), % Row in the index RowN	
	nth0(RowN , RowsClues , RowClues), % RowClues in the index RowN
	checkLineClues(RowClues , Row).
checkRowClues(_ , _ , false , _).

checkColClues(ColN , ColsClues , true , Grid):-
	searchColumn(ColN, Grid , Column), % Column in the index ColN
	nth0(ColN , ColsClues , ColClues), % ColClues in the index ColN
	checkLineClues(ColClues , Column).
checkColClues(_ , _ , false , _).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		
searchColumn(ColN , Grid , Column):-
	maplist( nth0(ColN) , Grid , Column).
	
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


checkLineClues([0] , Line):-
	not(member("#" , Line)).
		
checkLineClues([ ] , Line):-
	not(member("#" , Line)).
		
checkLineClues([Clue | RestClues] , [FirstElem | RestLine]):-
	FirstElem == "#",
	checkConsecutiveHash(Clue , [FirstElem | RestLine] , RestingLine),
	checkLineClues(RestClues , RestingLine).

checkLineClues(Clues , [FirstElem | RestLine]):-
	FirstElem \== "#",
	checkLineClues(Clues , RestLine).
		
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
		
checkConsecutiveHash(0 , [ ] , [ ]).
		
checkConsecutiveHash(0 , [FirstElem | RestLine] , RestLine):-
	FirstElem \== "#".
		
checkConsecutiveHash(CluesResting , [FirstElem | RestLine] , FinalLine):-
	FirstElem == "#",
	CluesRestingAux is CluesResting - 1,
	checkConsecutiveHash(CluesRestingAux , RestLine , FinalLine).

		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%