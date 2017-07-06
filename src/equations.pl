
% attackerGroundLethalitySurvivingAtStartOfDay(T) :- true.
% attackerGroundProsecutionRatePerDay(T) :- true.
% attackerGroundToGroundLethalityAttritionRatePerDay(T) :- true.
% attackerTotalGroundLethalityAttritionRatePerDay(T) :- true.
%
% dGL(T) :- true. % Defender's ground lethality surviving at start of Tth day

constant(wMax, 20.0).
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
attackerGroundLethality(0, 330000).
attackerGroundLethality(1, 330000). % Base case
attackerGroundLethality(Day, Lethality) :-
    PreviousDay is Day - 1,
    attackerAttritionRate(PreviousDay, Attrition),
    dCAS(PreviousDay, AttackerGroundLethalityKilled),
    attackerGroundLethality(PreviousDay, PreviousLethality),
    Lethality is PreviousLethality * (1 - Attrition) - AttackerGroundLethalityKilled.

/**
 * (A-2)
 */
defenderGroundLethality(0, 200000).
defenderGroundLethality(1, 200000). % Base case
defenderGroundLethality(Day, Lethality) :-
    PreviousDay is Day - 1,
    constant(p, P),
    attackerAttritionRate(PreviousDay, Attrition),
    aCAS(PreviousDay, DefenderGroundLethalityKilled),
    defenderGroundLethality(PreviousDay, PreviousDefenderLethality),
    attackerGroundLethality(PreviousDay, PreviousAttackerLethality),
    Lethality is PreviousDefenderLethality - ((Attrition / P) * PreviousAttackerLethality) - DefenderGroundLethalityKilled.

/**
 * (A-3)
 */
attackerAttritionRate(Day, AttritionRate) :-
    attackerProsecutionRate(Day, ProsecutionRate),
    defenderWithdrawlRate(Day, WithdrawlRate),
    constant(wMax, WMax),
    AttritionRate is ProsecutionRate * (1 - (WithdrawlRate / WMax)).

/**
 * (A-4)
 */
defenderWithdrawlRate(1, 0).
defenderWithdrawlRate(Day, WithdrawlRate) :-
    PreviousDay is Day - 1,
    constant(adt, Adt),
    defenderTotalGroundLethalityAttritionRate(PreviousDay, DefenderTotalGroundLethalityAttritionRate),
    ( DefenderTotalGroundLethalityAttritionRate > Adt ->
        constant(wMax, WMax),
        defenderWithdrawlRate(PreviousDay, PreviousWithdrawlRate),
        WithdrawlRate is PreviousWithdrawlRate + (((WMax - PreviousWithdrawlRate) / (1 - Adt) * (DefenderTotalGroundLethalityAttritionRate - Adt)));
        WithdrawlRate is 0
    ).

/**
 * (A-5)
 */
defenderTotalGroundLethalityAttritionRate(Day, AttritionRate) :-
    NextDay is Day + 1,
    defenderGroundLethality(Day, CurrentLethality),
    defenderGroundLethality(NextDay, TomorrowLethality),
    AttritionRate is (CurrentLethality - TomorrowLethality) / CurrentLethality.

/**
* (A-6)
*/
attackerProsecutionRate(1, 0.02). % Base case
attackerProsecutionRate(Day, ProsecutionRate) :-
    PreviousDay is Day - 1,
    constant(aat, AaT),
    attackerProsecutionRate(PreviousDay, PreviousProsecutionRate),
    attackerTotalGroundLethalityAttritionRate(PreviousDay, AttackerTotalGroundLethalityAttritionRate),
    ProsecutionRate is PreviousProsecutionRate - (((AaT - PreviousProsecutionRate) / AaT) * (AttackerTotalGroundLethalityAttritionRate - AaT)).

/**
* (A-7)
*/
attackerTotalGroundLethalityAttritionRate(Day, AttritionRate) :-
    NextDay is Day + 1,
    attackerGroundLethality(Day, CurrentLethality),
    attackerGroundLethality(NextDay, TomorrowLethality),
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
dCAS(Day, CAS) :-
    % PreviousDay is Day - 1,
    constant(l, L),
    constant(v, V),
    constant(ada, Ada),
    constant(sd, Sd),
    constant(kd, Kd),
    defenderSurvivingCAS(Day, DSurvivingCAS),
    CAS is (L / V) * DSurvivingCAS * Kd * (((1 - ((1 - Ada) ** (Sd + 1))) / Ada) - 1).
    % defenderSurvivingCAS(1, DSurvivingCAS),
    % CAS is (L / V) * DSurvivingCAS * ((1 - Ada) ** (Sd * PreviousDay)) * Kd * (((1 - ((1 - Ada) ** (Sd + 1))) / Ada) - 1).

/**
 * (A-11)
 */
aCAS(Day, CAS) :-
    constant(l, L),
    constant(v, V),
    constant(aaa, Aaa),
    constant(sa, Sa),
    constant(ka, Ka),
    attackerSurvivingCAS(Day, DSurvivingCAS),
    CAS is (L / V) * DSurvivingCAS * Ka * (((1 - ((1 - Aaa) ** (Sa + 1))) / Aaa) - 1).

/**
 * (A-12)
 */
defenderSurvivingCAS(1, 300). % Base case
defenderSurvivingCAS(Day, DSurvivingCAS) :-
    PreviousDay is Day - 1,
    constant(ada, Ada),
    constant(sd, Sd),
    defenderSurvivingCAS(1, DSurvivingCASOnDayOne),
    DSurvivingCAS is DSurvivingCASOnDayOne * ((1 - Ada) ** (Sd * PreviousDay)).

/**
 * (A-13)
 */
 attackerSurvivingCAS(1, 250). % Base case
 attackerSurvivingCAS(Day, DSurvivingCAS) :-
     PreviousDay is Day - 1,
     constant(aaa, Aaa),
     constant(sa, Sa),
     attackerSurvivingCAS(1, DSurvivingCASOnDayOne),
     DSurvivingCAS is DSurvivingCASOnDayOne * ((1 - Aaa) ** (Sa * PreviousDay)).

/****************** TODO: Remove Test Code *******************/

groundForcesTest(T) :-
    attackerGroundLethality(3, Lethality),
    % myTestLen(3, Count),
    write('Yo - '),
    write(T), nl,
    writeln(Lethality).

/****************** Test Code *******************/
