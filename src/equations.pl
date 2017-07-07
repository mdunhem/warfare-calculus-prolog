
constant(w_max, 20.0).
constant(p, 1.5).
constant(l, 47490).
constant(v, 1200).
constant(ada, 0.05).
constant(adt, 0.05).
constant(sd, 1.5).
constant(kd, 0.5).
constant(aat, 0.075).
constant(aaa, 0.05).
constant(sa, 1.0).
constant(ka, 0.25).

/**
 * (A-1)
 */
attacker_ground_lethality_list([330000]).
attacker_ground_lethality(Day, Lethality) :-
    attacker_ground_lethality_list(CurrentList),
    ( nth1(Day, CurrentList, CurrentLethality) ->
        Lethality is CurrentLethality;

        PreviousDay is Day - 1,
        attacker_attrition_rate(PreviousDay, Attrition),
        d_CAS(PreviousDay, AttackerGroundLethalityKilled),
        attacker_ground_lethality(PreviousDay, PreviousLethality),
        Lethality is PreviousLethality * (1 - Attrition) - AttackerGroundLethalityKilled,
        append(CurrentList, [Lethality], NewList),
        asserta(attacker_ground_lethality_list(NewList))
    ).

/**
 * (A-2)
 */
defender_ground_lethality_list([200000]).
defender_ground_lethality(Day, Lethality) :-
    defender_ground_lethality_list(CurrentList),
    ( nth1(Day, CurrentList, CurrentLethality) ->
        Lethality is CurrentLethality;

        PreviousDay is Day - 1,
        constant(p, P),
        attacker_attrition_rate(PreviousDay, Attrition),
        a_CAS(PreviousDay, DefenderGroundLethalityKilled),
        defender_ground_lethality(PreviousDay, PreviousDefenderLethality),
        attacker_ground_lethality(PreviousDay, PreviousAttackerLethality),
        Lethality is PreviousDefenderLethality - ((Attrition / P) * PreviousAttackerLethality) - DefenderGroundLethalityKilled,
        append(CurrentList, [Lethality], NewList),
        asserta(defender_ground_lethality_list(NewList))
    ).

/**
 * (A-3)
 */
attacker_attrition_rate(Day, AttritionRate) :-
    attacker_prosecution_rate(Day, ProsecutionRate),
    defender_withdrawl_rate(Day, WithdrawlRate),
    constant(w_max, WMax),
    AttritionRate is ProsecutionRate * (1 - (WithdrawlRate / WMax)).

/**
 * (A-4)
 */
defender_withdrawl_rate(1, 0).
defender_withdrawl_rate(Day, WithdrawlRate) :-
    PreviousDay is Day - 1,
    constant(adt, Adt),
    defender_total_ground_lethality_attrition_rate(PreviousDay, DefenderTotalGroundLethalityAttritionRate),
    ( DefenderTotalGroundLethalityAttritionRate > Adt ->
        constant(w_max, WMax),
        defender_withdrawl_rate(PreviousDay, PreviousWithdrawlRate),
        WithdrawlRate is PreviousWithdrawlRate + (((WMax - PreviousWithdrawlRate) / (1 - Adt) * (DefenderTotalGroundLethalityAttritionRate - Adt)));
        WithdrawlRate is 0
    ).

/**
 * (A-5)
 */
defender_total_ground_lethality_attrition_rate(Day, AttritionRate) :-
    NextDay is Day + 1,
    defender_ground_lethality(Day, CurrentLethality),
    defender_ground_lethality(NextDay, TomorrowLethality),
    AttritionRate is (CurrentLethality - TomorrowLethality) / CurrentLethality.

/**
* (A-6)
*/
attacker_prosecution_rate(1, 0.02). % Base case
attacker_prosecution_rate(Day, ProsecutionRate) :-
    PreviousDay is Day - 1,
    constant(aat, AaT),
    attacker_prosecution_rate(PreviousDay, PreviousProsecutionRate),
    attacker_total_ground_lethality_attrition_rate(PreviousDay, AttackerTotalGroundLethalityAttritionRate),
    ProsecutionRate is PreviousProsecutionRate - (((AaT - PreviousProsecutionRate) / AaT) * (AttackerTotalGroundLethalityAttritionRate - AaT)).

/**
* (A-7)
*/
attacker_total_ground_lethality_attrition_rate(Day, AttritionRate) :-
    NextDay is Day + 1,
    attacker_ground_lethality(Day, CurrentLethality),
    attacker_ground_lethality(NextDay, TomorrowLethality),
    AttritionRate is (CurrentLethality - TomorrowLethality) / CurrentLethality.

/**
 * (A-8)
 */


/**
 * (A-9)
 */


/**
 * (A-10)
 */
d_CAS(Day, CAS) :-
    constant(l, L),
    constant(v, V),
    constant(ada, Ada),
    constant(sd, Sd),
    constant(kd, Kd),
    defender_surviving_CAS(Day, DSurvivingCAS),
    CAS is (L / V) * DSurvivingCAS * Kd * (((1 - ((1 - Ada) ** (Sd + 1))) / Ada) - 1).

/**
 * (A-11)
 */
a_CAS(Day, CAS) :-
    constant(l, L),
    constant(v, V),
    constant(aaa, Aaa),
    constant(sa, Sa),
    constant(ka, Ka),
    attacker_surviving_CAS(Day, DSurvivingCAS),
    CAS is (L / V) * DSurvivingCAS * Ka * (((1 - ((1 - Aaa) ** (Sa + 1))) / Aaa) - 1).

/**
 * (A-12)
 */
defender_surviving_CAS(1, 300). % Base case
defender_surviving_CAS(Day, DSurvivingCAS) :-
    PreviousDay is Day - 1,
    constant(ada, Ada),
    constant(sd, Sd),
    defender_surviving_CAS(1, DSurvivingCASOnDayOne),
    DSurvivingCAS is DSurvivingCASOnDayOne * ((1 - Ada) ** (Sd * PreviousDay)).

/**
 * (A-13)
 */
 attacker_surviving_CAS(1, 250). % Base case
 attacker_surviving_CAS(Day, DSurvivingCAS) :-
     PreviousDay is Day - 1,
     constant(aaa, Aaa),
     constant(sa, Sa),
     attacker_surviving_CAS(1, DSurvivingCASOnDayOne),
     DSurvivingCAS is DSurvivingCASOnDayOne * ((1 - Aaa) ** (Sa * PreviousDay)).

/****************** TODO: Remove Test Code *******************/

count(Num) :-
    ( Num < 58 ->
        NextNum is Num + 1,
        attacker_ground_lethality(Num, Lethality),
        writeln(Lethality),
        count(NextNum);
        true
    ).

groundForcesTest(T) :-
    % constant(initList, InitList),
    % resultList([[23, 33]], InitList, NewList),
    % nth0(1, NewList, Element),
    % writeln(Element),
    % attacker_ground_lethality(4, Lethality),
    % myTestLen(3, Count),
    count(1),
    write('Yo - '),
    write(T), nl.
    % writeln(Lethality).

/****************** Test Code *******************/
