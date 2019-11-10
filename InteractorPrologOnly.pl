/*
 * Lab Project for CZ3005 Artificial Intelligence @ Nanyang Technological University
 * Assignment 4: Patient with a sympathetic doctor
 * Niu Haoyu, N1902565A, Group TSP4
 */

% Including core logic & translation codes
:-['DoctorLogic.pl'].
:-['HumanizedOutput.pl'].

ask_question:-
    gesture(Gesture),
    human_gesture(Gesture, HumanGesture),			% get gesture
    opening(Opening),								% get opening
    question_start(QuestionStart),					% get question start
    nextQuestion(Question),
    human_symptom(Question, HumanQuestion),    		% get available question
    write('*'), write(HumanGesture), write('*'), nl,
    write(Opening), write(QuestionStart), write(HumanQuestion),write('?'), nl, nl,
	write('Please reply as follows:'), nl,
	write('reply('), write(Question), write(',yes). or '), write('reply('), write(Question), write(',no).'),!.

make_diagnose:-
    gesture(Gesture),
    human_gesture(Gesture, HumanGesture),			% get gesture
    opening(Opening),								% get opening
    diagnose(Result),
    human_diagnose(Result, Human_result),			% get diagnosis
    write('*'), write(HumanGesture),write('*'),nl,
    write(Opening), write('you might have '), write(Human_result),!.

% we may get directly into diagnosis if the symptoms from last time were kept in prolog
start:-
    (current_predicate(diagnos_ready/1) -> make_diagnose; ask_question).

reply(Question, Answer):-
    answer(Question, Answer),
	(current_predicate(diagnos_ready/1) -> make_diagnose; ask_question).
