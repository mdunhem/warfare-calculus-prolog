/**
 * Mikael Dunhem
 * CS 355 - Summer 2017
 * Assignment 2 - THE CALCULUS OF CONVENTIONAL WAR: DYNAMIC ANALYSIS WITHOUT LANCHESTER THEORY
 *
 * All of the necessary equations listed in the paper are represented here. They are labled
 * with the same lables used in the paper. Each one stores it's results in a list in order
 * to prevent an excessively large call stack since each equation will be called recursively.
 * This way, the calculation will only be performed once per "Day" (day of warfare.)
 *
 * Equations A-8 and A-9 were omitted since they are not needed. They are only used if
 * omitting airpower from the calculation, which in this case, is not.
 */

/**
 * Store all values that do not change in a constant rule.
 */
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
attacker_attrition_rate_list([]).
attacker_attrition_rate(Day, AttritionRate) :-
    attacker_attrition_rate_list(CurrentList),
    ( nth1(Day, CurrentList, CurrentAttritionRate) ->
        AttritionRate is CurrentAttritionRate;
        attacker_prosecution_rate(Day, ProsecutionRate),
        defender_withdrawl_rate(Day, WithdrawlRate),
        constant(w_max, WMax),
        AttritionRate is ProsecutionRate * (1 - (WithdrawlRate / WMax)),
        append(CurrentList, [AttritionRate], NewList),
        asserta(attacker_attrition_rate_list(NewList))
    ).

/**
 * (A-4)
 */
defender_withdrawl_rate_list([0]).
defender_withdrawl_rate(Day, WithdrawlRate) :-
    defender_withdrawl_rate_list(CurrentList),
    ( nth1(Day, CurrentList, CurrentWithdrawlRate) ->
        WithdrawlRate is CurrentWithdrawlRate;
        PreviousDay is Day - 1,
        constant(adt, Adt),
        defender_total_ground_lethality_attrition_rate(PreviousDay, DefenderTotalGroundLethalityAttritionRate),
        ( DefenderTotalGroundLethalityAttritionRate > Adt ->
            constant(w_max, WMax),
            defender_withdrawl_rate(PreviousDay, PreviousWithdrawlRate),
            WithdrawlRate is PreviousWithdrawlRate + (((WMax - PreviousWithdrawlRate) / (1 - Adt) * (DefenderTotalGroundLethalityAttritionRate - Adt)));
            WithdrawlRate is 0
        ),
        append(CurrentList, [WithdrawlRate], NewList),
        asserta(defender_withdrawl_rate_list(NewList))
    ).

/**
 * (A-5)
 */
defender_total_ground_lethality_attrition_rate_list([]).
defender_total_ground_lethality_attrition_rate(Day, AttritionRate) :-
    defender_total_ground_lethality_attrition_rate_list(CurrentList),
    ( nth1(Day, CurrentList, CurrentAttritionRate) ->
        AttritionRate is CurrentAttritionRate;
        NextDay is Day + 1,
        defender_ground_lethality(Day, CurrentLethality),
        defender_ground_lethality(NextDay, TomorrowLethality),
        AttritionRate is (CurrentLethality - TomorrowLethality) / CurrentLethality,
        append(CurrentList, [AttritionRate], NewList),
        asserta(defender_total_ground_lethality_attrition_rate_list(NewList))
    ).

/**
* (A-6)
*/
attacker_prosecution_rate_list([0.02]).
attacker_prosecution_rate(Day, ProsecutionRate) :-
    attacker_prosecution_rate_list(CurrentList),
    ( nth1(Day, CurrentList, CurrentProsecutionRate) ->
        ProsecutionRate is CurrentProsecutionRate;
        PreviousDay is Day - 1,
        constant(aat, AaT),
        attacker_prosecution_rate(PreviousDay, PreviousProsecutionRate),
        attacker_total_ground_lethality_attrition_rate(PreviousDay, AttackerTotalGroundLethalityAttritionRate),
        ProsecutionRate is PreviousProsecutionRate - (((AaT - PreviousProsecutionRate) / AaT) * (AttackerTotalGroundLethalityAttritionRate - AaT)),
        append(CurrentList, [ProsecutionRate], NewList),
        asserta(attacker_prosecution_rate_list(NewList))
    ).

/**
* (A-7)
*/
attacker_total_ground_lethality_attrition_rate_list([]).
attacker_total_ground_lethality_attrition_rate(Day, AttritionRate) :-
    attacker_total_ground_lethality_attrition_rate_list(CurrentList),
    ( nth1(Day, CurrentList, CurrentAttritionRate) ->
        AttritionRate is CurrentAttritionRate;
        NextDay is Day + 1,
        attacker_ground_lethality(Day, CurrentLethality),
        attacker_ground_lethality(NextDay, TomorrowLethality),
        AttritionRate is (CurrentLethality - TomorrowLethality) / CurrentLethality,
        append(CurrentList, [AttritionRate], NewList),
        asserta(attacker_total_ground_lethality_attrition_rate_list(NewList))
    ).

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
defender_surviving_CAS_list([300]).
defender_surviving_CAS(Day, DSurvivingCAS) :-
    defender_surviving_CAS_list(CurrentList),
    ( nth1(Day, CurrentList, CurrentDSurvivingCAS) ->
        DSurvivingCAS is CurrentDSurvivingCAS;
        PreviousDay is Day - 1,
        constant(ada, Ada),
        constant(sd, Sd),
        defender_surviving_CAS(1, DSurvivingCASOnDayOne),
        DSurvivingCAS is DSurvivingCASOnDayOne * ((1 - Ada) ** (Sd * PreviousDay)),
        append(CurrentList, [DSurvivingCAS], NewList),
        asserta(defender_surviving_CAS_list(NewList))
    ).

/**
 * (A-13)
 */
attacker_surviving_CAS_list([250]).
attacker_surviving_CAS(Day, ASurvivingCAS) :-
    attacker_surviving_CAS_list(CurrentList),
    ( nth1(Day, CurrentList, CurrentASurvivingCAS) ->
        ASurvivingCAS is CurrentASurvivingCAS;
        PreviousDay is Day - 1,
        constant(aaa, Aaa),
        constant(sa, Sa),
        attacker_surviving_CAS(1, ASurvivingCASOnDayOne),
        ASurvivingCAS is ASurvivingCASOnDayOne * ((1 - Aaa) ** (Sa * PreviousDay)),
        append(CurrentList, [ASurvivingCAS], NewList),
        asserta(attacker_surviving_CAS_list(NewList))
    ).
