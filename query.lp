%?- v_chosen(player(Self),player(Target),turn(Y)).
%?- findall(Votes, vote(player(Votes),player(Victim), turn(Y)), List).
%?- voted_out(player(Victim), turn(Y)), game_over(turn(Y), V).
?- game_over(turn(Y), V), remaining(X,turn(Y)).
%?- opinion(player(Self),player(Target),turn(Y), hostile).
%?- remaining(X,turn(Y)).
%?-kill(player(Killer),player(Victim),turn(Y)).