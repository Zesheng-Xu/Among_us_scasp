
% defining killer logic:
% killer will kill someone if they are in the same room at the same turn with them, but might not kill them to gain their trust.
% and ofc, we do not encourage suicide
% temproally disabled due to the infinite run time error due to choose(N)
kill(player(Killer),player(Victim),turn(Y)):- to_kill(turn(Y)), killer(Killer),choose(player(Victim),room(X),turn(Y)), choose(player(Killer),room(X),turn(Y)), k_chosen(player(Victim),turn(Y)),  Killer \= Victim.



% To kill, or not to kill, that is the question.
to_kill(turn(Y)):- not not_to_kill(turn(Y)).
not_to_kill(turn(Y)):- not to_kill(turn(Y)).

% a player is considered dead if they are killed or voted out
dead(player(Victim),turn(Y)):- voted_out(player(Victim,turn(Y))).
dead(player(Victim), turn(Y)):-  kill(player(Killer),player(Victim),turn(Y)).
dead_on(player(Victim), turn(Y)):- turn(X), turn(Y), dead(player(Victim), turn(X)), X =< Y.

% modeling the opinion of agents of each other - this opinion is ironically based on facts, not assumptions - hostile have a higher priority over safe
% a player will tends to trust the one who didnt murder him when they are in a room together, unless he has reason to be hostile to them
opinion(player(Self),player(Target),turn(Y), safe):-  turn(Y),  choose(player(Self),room(X),turn(Y)), choose(player(Target),room(X),turn(Y)),not kill(player(Target),player(Self),turn(Y)), Target \= Self.

% a player will be hostile to another if can confirm he is either the killer or hostile to self
opinion(player(Self),player(Target),turn(Y), hostile):-  not killer(Self),kill(player(Target),player(Victim),turn(Y)) ,choose(player(Self),room(X),turn(Y)), choose(player(Target),room(X),turn(Y)), choose(player(Victim),room(X),turn(Y)),dead(player(Victim), turn(Y)),Victim \= Self,Target \= Self.

opinion(player(Self),player(Target),turn(Y), hostile):- killer(Self), opinion(player(Target),player(Self),turn(Y), hostile).  %<------- a little programmer smart to address the killer accusing whoever accusing him

%agents expressing their opinion into action - this is based on assumptions of agent towards each other----------
% agent will try to spread distrust on other players who they believe is not safe
%accusing(player(Self),player(Target),turn(T)):- turn(T), player(Self), player(Target),Target \= Self,accusing(player(Target),player(Self),turn(Z)), Z < Y.

accusing(player(Self),player(Target),turn(T)):- turn(T), turn(X),player(Self), player(Target), opinion(player(Self),player(Target),turn(X), hostile), X =< T.
accusing_2(player(Self),player(Target),turn(T)):-turn(T), turn(X), turn(Y), Y < T, X < Y,player(Self), player(Target), player(Other), Target \= Self,Other \= Self,Target \= Other, accusing(player(Other),player(Target),turn(X)),  dead_on(player(Other), turn(Y)). % players that accused each other, and one of the party died, thus automatically assume the other party is the killer


% agent will try to assure others who he believe is safe
assuring(player(Self),player(Target),turn(T)):- turn(T),turn(Y), turn(Z), opinion(player(Self),player(Target),turn(Y), safe), not opinion(player(Self),player(Target),turn(Z), hostile), Y =< T, Y >= Z.

neutral(player(Self),player(Target),turn(T)):- turn(T), player(Self), player(Target), Self \= Target, not accusing(player(Self),player(Target),turn(T)), not assuring(player(Self),player(Target),turn(T)).




% modeling the voting mechanism
% player that have reason to be hostile to someone, they will try to vote one out, if he is not dead on that turn
vote(player(Self),player(Target), turn(Y)):-   accusing(player(Self),player(Target),turn(X)), v_chosen(player(Self),player(Target),turn(Y)), not dead_on(player(Self),turn(Y)), Self \= Target, X =< Y.
vote(player(Self),player(Target), turn(Y)):-   accusing_2(player(Self),player(Target),turn(X)), v_chosen(player(Self),player(Target),turn(Y)), not dead_on(player(Self),turn(Y)), Self \= Target, X =< Y.

% one is voted out if over half voted for him
voted_out(player(Victim), turn(Y)):- turn(Y), findall(Votes, vote(player(Votes),player(Victim), turn(Y)), List) ,set(List,L),size(Length, L), remaining(X,turn(Y)), X .=. Z *2, Length >= Z.

% game ending conditions
% game ends when no player left but killer
game_over(turn(Y),killer_won):- turn(Y), remaining(X,turn(Y)), X =< 2.
%game ends when killer is voted out
game_over(turn(Y), player_won):- turn(Y), voted_out(player(Victim), turn(Y)), killer(Victim).

% custom function
remaining(X,turn(Y)):- findall(Players,player(Players),P), findall(Dead,dead_on(player(Dead),turn(Y)),D), set(P,P_2),set(D,D_2),size(A,D_2),size(B,P_2), X .=. B - A.

size(0,[]).
size(X, [H|T]) :- X .=. Y + 1, size(Y,T).


%---------------------------------------- the following code is for uniquely selecting a target for either voting or killing of the progression

% uniquely chosen per turn - for killer
k_notchosen(player(X),turn(Z)) :- not  k_chosen(player(X),turn(Z)).
k_chosen(player(X),turn(Z)) :- player(X), turn(Z), not k_notchosen(player(X),turn(Z)).

:- k_chosen(player(X),turn(Z)), k_chosen(player(Y),turn(Z)), Y \= X.

% uniquely chosen per turn - for Vote
v_notchosen(player(Self),player(X),turn(Z)) :- not v_chosen(player(Self),player(X),turn(Z)).
v_chosen(player(Self),player(X),turn(Z)) :- player(X), player(Self),turn(Z),Self \= X, not v_notchosen(player(Self),player(X),turn(Z)).

:- v_chosen(player(Self),player(X),turn(Z)), v_chosen(player(Self),player(Y),turn(Z)),  X \= Y.


% remove duplicates from a list
mymember(X,[X|_]).
mymember(X,[_|T]) :- mymember(X,T).

set([],[]).
set([H|T],[H|Out]) :-
    not mymember(H,T),
    set(T,Out).
set([H|T],Out) :-
    mymember(H,T),
    set(T,Out).


