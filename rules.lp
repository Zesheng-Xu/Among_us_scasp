
% defining killer logic:
% killer will kill someone if they are in the same room at the same turn with them, but might not kill them to gain their trust.
% and ofc, we do not encourage suicide
kill(player(Killer),player(Victim),turn(Y)):- to_kill, killer(Killer),choose(player(Victim),room(X),turn(Y)), choose(player(Killer),room(X),turn(Y)), k_chosen(player(Victim),turn(Y)),  Killer \= Victim.

% To kill, or not to kill, that is the question.....  <------------- doesnt work, always returned to_kill...
to_kill:- not not_to_kill.
not_to_kill:- not to_kill.

% a player is considered dead if they are killed or voted out
dead(player(Victim),turn(Y)):- voted_out(player(Victim,turn(Y))).
dead(player(Victim), turn(Y)):-  kill(player(Killer),player(Victim),turn(Y)).
dead_on(player(Victim), turn(Y)):- turn(X), turn(Y), player(Killer), kill(player(Killer),player(Victim),turn(X)), X =< Y.

% modeling the opinion of agents of each other
% a player will tends to trust the one who didnt murder him when they are in a room together
opinion(player(Self),player(Target),turn(Y), safe):- choose(player(Self),room(X),turn(Y)), choose(player(Target),room(X),turn(Y)),not dead_on(player(Self), turn(Y)), Target \= Self.
% a player will be hostile to another if can confirm he is either the killer or hostile to self
opinion(player(Self),player(Target),turn(Y), hostile):-  not killer(Self),kill(player(Target),player(Victim),turn(Y)) ,choose(player(Self),room(X),turn(Y)), choose(player(Target),room(X),turn(Y)), choose(player(Victim),room(X),turn(Y)),dead(player(Victim), turn(Y)),Victim \= Self,Target \= Self.



% modeling the voting mechanism
%vote(player(Self),player(Target), turn(Y)):- opinion(player(Self),player(Target),turn(X), hostile), X =< Y, not dead(player(Self),turn(Z)),v_chosen(player(Self),player(X),turn(Z)), Z < Y.
vote(player(Self),player(Target), turn(Y)):- opinion(player(Self),player(Target),turn(X), hostile), v_chosen(player(Self),player(Target),turn(Z)),X =< Y. % <--- to make the game terminate by voting out killer possible when the problem is not solved


% one is voted out if over half voted for him
voted_out(player(Victim), turn(Y)):- turn(Y), findall(Votes, vote(player(Votes),player(Victim), turn(Y)), List) ,size(Length, List), remaining(X,turn(Y)), X .=. Z *2, Length >= Z.

% game ending conditions
% game ends when no player left but killer
game_over(turn(Y),killer_won):- turn(Y), remaining(X,turn(Y)), X =< 2.
%game ends when killer is voted out
game_over(turn(Y), player_won):- turn(Y), voted_out(player(Victim), turn(Y)), killer(Victim).

% custom function
remaining(X,turn(Y)):- findall(Players,player(Players),P), findall(Dead,dead(player(Dead),turn(Y)),D), size(A,D),size(B,P), X .=. B - A.

size(0,[]).
size(X, [H|T]) :- X .=. Y + 1, size(Y,T).

% uniquely chosen per turn - for killer
k_notchosen(player(X),turn(Z)) :- chosen(player(Y),turn(Z)), not eq(player(X),player(Y)).
k_chosen(player(X),turn(Z)) :- possible(X), not notchosen(player(X),turn(Z)).


% uniquely chosen per turn - for Vote
v_notchosen(player(Self),player(X),turn(Z)) :- chosen(player(Self),player(Y),turn(Z)), not eq(player(X),player(Y)).
v_chosen(player(Self),player(X),turn(Z)) :- possible(X), not notchosen(player(Self),player(X),turn(Z)).


eq(X,X).