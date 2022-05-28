use_module(library(lists)).
/* pongo come ipotesi che non stanno su stessa colonna, array di 4 valori,
per aumentare vanno modificate mutation e crossover*/
%FunzioneGenerale
queens(Popolazione, Risultato):-
    write('Popolazione: '),
    writeln(Popolazione),
    valida(Popolazione,Punteggio), %PrimaEvaluetion
    min_list(Punteggio,PunteggioMinimo),
    ( PunteggioMinimo =\= 0 -> %significaDiverso
    sum_list(Punteggio,TotalePunteggio), %SommaDiTutteLeFitness
    selezione(Popolazione,TotalePunteggio,Prescelti,Punteggio),
    length(Prescelti,Len),
    /* controllo da fare perchè in selezione ho una probabilità*/
    (Len = 0 ->  
       Migliori = Popolazione; %selezioneFattaMale 
       Migliori = Prescelti %selezioneFattaBene
    ),
    mischia(Migliori, Figli),
    mutazione(Figli, NuovaPopolazione),
    queens(NuovaPopolazione,Risultato);

    nth1(Indice,Punteggio,0), 
    /* nth1(indice,lista,elemento) -> restituisce che elemento è in lista in posizione 'indice'
       prima troviamo Indice, poi troviamo Risultato */
    nth1(Indice,Popolazione,Risultato)
    ).



%ValidaFitness
valida([],[]).
valida([Pop|Popolazione], [P|Punteggio]):-
    valida(Popolazione, Punteggio),
    fitness(Pop, Fit), 
    /*Pop è una lista con dentro la combinazione di regine sul tavolo, Fit è un valore
    poi sotto chiamo valida così da dare i valori a tutte le combinazioni*/
    P = Fit. %ArithmeticEvaluation

fitness([], 0).
fitness([P|Pop], Fit) :- 
    /*analizzo tutti e quattro i valori della combinazione*/
    uccisioni(P, Pop, Morti,1),
    fitness(Pop, F), 
    /*applica fitness a tutte e 4 le regine*/
    Fit is F + Morti.
    /*scrivo is e non = poichè voglio che prenda quel valore, altrimenti fa unificazione
    * is -> fit=f+morti sommati
    * = -> fit=f+morti come espressione
    */

uccisioni(_,[], 0, _). %passoBase
uccisioni(P1,[P2|Pop],Risultato,Diagonale) :-
  (P1 =\= P2 -> %not on the same row  
  Diag is abs(P2-P1),
  /*stessa diagonale è 1*/
  (Diag =\= Diagonale -> %NoDiagonale

  SommaDiagonale is Diagonale + 1, 
  /* provo tutte le distanze delle diagonali*/
  uccisioni(P1,Pop,Ris,SommaDiagonale),
  Risultato is Ris; %rimane0

  SommaDiagonale is Diagonale + 1,
  uccisioni(P1,Pop,Ris,SommaDiagonale),
  Risultato is Ris + 1 %aumenta1LaFitness
  );
  Risultato is 100
  ).


%Selezione
selezione([],_,[],[]).
selezione([P|Popolazione],TotalePunteggio, Prescelti,[Punt|Punteggio]):-
    /*[punt|punteggio mi serve per non richiamare la fitness]*/
    Prob is 1 - Punt/TotalePunteggio, 
    /* 1/(1+Punt) non va, era individuale
    *più P è Vicino Ad Uno Meglio è, ha più probablità di essere usato per fare i figli
    */
    (maybe(Prob) ->
      Prescelti = [P|ListaPrescelti],
      selezione(Popolazione, TotalePunteggio, ListaPrescelti, Punteggio);   
      selezione(Popolazione, TotalePunteggio, Prescelti, Punteggio)
    ).
    

%Crossover_Mischia
mischia([],[]).
mischia([M|Migliori], Figli) :-
    /*Migliori sono più combinazioni, con succ ne prendi uno alla volta*/
    mischia(Migliori, F),
    crossover(M,Migliori,Incroci),
    union([M|F],Incroci,Figli).
crossover(_,[],[]).
crossover(S1,[S2|Migl],Incroci):-
    /*S1 e S2 sono una combinazione a testa, scrivendo così vale solo per 4Regine,
    * se vuoi fare più di 4 regine devi aggiungere altri campi in S1,S2,R1,R2
    */
    [A1,A2,A3,A4,A5] = S1, 
    [C1,C2,C3,C4,C5] = S2,
    R1 = [A1,A2,C3,C4,C5],
    R2 = [C1,C2,A3,A4,A5], 
    crossover(S1,Migl,AltriIncroci),
    union([R1,R2],AltriIncroci,Incroci).


%mutazione
/*tengo sia l'individuo non mutato (F) sia quello mutato (N)*/
mutazione([],[]).
mutazione([F|Figli], [F,N|NuovaPopolazione]):-
    L is 5, 
    /* modificare se vuoi aumentare le regine */
    random_between(1,L,Rand1),
    /* random_between(L,U,R), Binds R to a random integer in [L,U] (i.e., including both L and U). Fails silently if U<L. */
    random_between(1,L,Rand2),
    nth1(Rand1,F, Elem),
    scambia(F,N,Rand2,Elem),
    mutazione(Figli,NuovaPopolazione).
scambia([],[],_,_).
scambia([F1|Figli1],[N|NuovaPop],Indice,Elemento):-
    (Indice = 1 ->
    N = Elemento,
    I is Indice-1,
    scambia(Figli1,NuovaPop,I,Elemento);
    N = F1,
    I is Indice-1,
    scambia(Figli1,NuovaPop,I,Elemento)
    ).



