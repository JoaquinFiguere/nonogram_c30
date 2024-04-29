:- module(proylcc,
	[  
		put/8
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
	nth0(RowN, NewGrid, Row), % Row in the index RowN 
	nth0(RowN, RowsClues, RowClues), % RowClues in the index RowN
	nth0(ColN, ColsClues, ColClues), % ColClues in the index ColN	
	length(NewGrid , CantRows),
	CantRows1 is CantRows - 1,
	searchColumn(CantRows1 , ColN , NewGrid , Column),
	checkCluesAndLine(RowClues , Row , RowSat),
	checkCluesAndLine(ColClues , Column , ColSat).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	searchColumn(-1 , _ , _ , _Column).
	searchColumn(Indice , ColN, Grid, Column):-
		nth0(Indice, Grid, Row),
		nth0(ColN, Row, Element),
		NewIndice is Indice - 1,
		searchColumn(NewIndice, ColN, Grid, [Element | Column]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Caso base: no hay más clues y no hay más celdas en la fila.
checkCluesAndLine([], [], true).

% Caso recursivo: el primer clue es igual a la cantidad de # consecutivos en la fila.
checkCluesAndLine([Clue|RestOfClues], Line, Sat):-
    iterateUntilHash(Line, LineAfterHash),
    countConsecutiveHashes(LineAfterHash, 0, Clue, RestOfLine),
    checkNoMoreHashes(RestOfLine),
    checkCluesAndLine(RestOfClues, RestOfLine, Sat).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Caso base
iterateUntilHash([], []).
iterateUntilHash(['#'|RestOfLine], ['#'|RestOfLine]).

% Caso recursivo: la celda actual no es un #, por lo que seguimos buscando.
iterateUntilHash(['_'|RestOfLine], RestOfLineAfterHash):-
    iterateUntilHash(RestOfLine, RestOfLineAfterHash).

iterateUntilHash(['X'|RestOfLine], RestOfLineAfterHash):-
	iterateUntilHash(RestOfLine, RestOfLineAfterHash).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Caso base: hemos contado la cantidad correcta de # consecutivos.
countConsecutiveHashes(Line, Count, Count, Line).

% Caso recursivo: seguimos contando # consecutivos.
countConsecutiveHashes(['#'|RestOfLine], Count, Clue, RestOfLineAfterHashes):-
    NewCount is Count + 1,
    countConsecutiveHashes(RestOfLine, NewCount, Clue, RestOfLineAfterHashes).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Caso base: la siguiente celda no es un # o no hay mas celdas.
checkNoMoreHashes(['_'|_]).
checkNoMoreHashes(['X'|_]).
checkNoMoreHashes([]).

% Caso recursivo: la siguiente celda es un #, lo cual es un error.
checkNoMoreHashes(['#'|_]):-
    fail.