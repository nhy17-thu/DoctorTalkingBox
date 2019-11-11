pain.							% store pain level selected by patient
mood.							% store mood level selected by patient
diagnose_ready.					% true with all questions asked and answered
symptom_positive(nothing).		% symptoms with positive answer, including symptoms, pain, and mood
answered(nothing).				% answered items, including pain, mood, and symptoms

% Library of pains, moods, and symptoms
pain_library([unbearable_pain, lot_of_pain, manageable_pain, mild_pain, no_pain]).
mood_library([calm, angry, weepy, anxious, malaise]).
symptom_library([temperature, sweat, ache, sneeze, cough, blood, breathe_rapidly, headache, bruise]).

% List of illness and its library of symptoms
illness(fever,  [temperature, sweat, ache, weepy, headache]).
illness(cold,   [sneeze, cough, temperature, mild_pain, malaise]).
illness(injury, [blood, unbearable_pain, ache, angry, bruise]).
illness(cancer, [blood, manageable_pain, temperature, sweat, ache, malaise]).
illness(anxiety_disorder, [anxious, sweat, lot_of_pain, breathe_rapidly, headache]).

% Library of gestures
gesture(polite_gesture, [look_concerned, mellow_voice, light_touch, faint_smile]).
gesture(calming_gesture, [greet, look_composed, look_attentive]).
gesture(normal_gesture, [broad_smile, joke, beaming_voice]).

% determine whether a list is empty
list_empty([], true).
list_empty([_|_], false).

% recursively determine whether a list L1 is a subset of L2
% is_subset(L1, L2).
is_subset([], _).
is_subset([H|T], L):-
	member(H,L), is_subset(T,L).

% Randomly select a certain gesture from libraries
gesture(G):-
	(
		% if patient havn't choose pain/mood, or have chosen no_pain or calm, set GestureList to normal_gesture
		(
			(not(current_predicate(pain/1)); not(current_predicate(mood/1)); pain(no_pain); mood(calm)),
			gesture(normal_gesture, GestureList)
		);
		% if patient selected unbearable_pain, lot_of_pain, anxious, or angry, set GestureList to polite_gesture
		(
			(pain(unbearable_pain); pain(lot_of_pain); mood(anxious); mood(angry)), 
			gesture(polite_gesture, GestureList)
		);
		% if patient select manageable_pain, mild_pain, weepy or malaise is selected, set GestureList to calming_gesture
		(
			(pain(manageable_pain); pain(mild_pain); mood(weepy); mood(malaise)),
			gesture(calming_gesture, GestureList)
		)
	),
	random_member(G, GestureList).   % get a random gesture from GestureList chosen above

% determine whether all items from a library L have been answered.
library_finished(L, AvailableChoices, If_finished):-
	findall(X, answered(X), History),
	list_to_set(L, P),
	list_to_set(History, S),
	subtract(P, S, AvailableChoices),	% get unanswered choices, if any
	list_empty(AvailableChoices, If_finished).


% return the next question to be asked, using cut operator ! to avoid previous questions
% ask symptoms after finishing pains and moods
nextQuestion(Next):-
	pain_library(Pain_library),
	mood_library(Mood_library),
	symptom_library(Symptom_library),
	library_finished(Pain_library, _, If_pain_finished),   % check if all items in Pain_library has been answered 
	library_finished(Mood_library, _, If_mood_finished),   % check if all items in Mood_library has been answered 
	library_finished(Symptom_library, AvailableChoices, _),    
	(
		/*
		 * here we assume that patients can have only one kind of pain level and mood at a time
		 * but can have many different sympotms
		 */
		(current_predicate(pain/1); If_pain_finished),   % or at least one in the Pain_library is answered positively
		(current_predicate(mood/1); If_mood_finished)    % or at least one in the Mood_library is answered positively
	),!,
	random_member(Next, AvailableChoices).
% ask moods after finishing pains
nextQuestion(Next):-
	pain_library(Pain_library),
	mood_library(Mood_library),
	library_finished(Pain_library, _, If_pain_finished),	% check if all items in Pain_library has been answered 
	(current_predicate(pain/1); If_pain_finished),     		% or at least one in the library is answered positively
	library_finished(Mood_library, AvailableChoices, _),!,
	random_member(Next, AvailableChoices).
% ask pains
nextQuestion(Next):-
	% pain have not been selected
	pain_library(Pain_library),
	library_finished(Pain_library, AvailableChoices, _),!,     
	random_member(Next, AvailableChoices).


% deal with positive answers on pains, moods, and symptoms
answer_positive(Question):-
	pain_library(Pain_library),
	mood_library(Mood_library),
	symptom_library(Symptom_library),
	(
		member(Question, Pain_library) -> assert(pain(Question));		% if Question is about a pain
		member(Question, Mood_library) -> assert(mood(Question));		% if Question is about a mood
		member(Question, Symptom_library) -> true						% Then Question is about a symptom
	),
	assert(symptom_positive(Question)).									% add Question to symptom_positive

% Interface between inputs and system
answer(Question, Answer):-
	assert(answered(Question)),
	(   
		Answer == yes -> answer_positive(Question); true
	),
	% if every symptom is answered, then ready to diagnose
	symptom_library(Symptom_library),
	(
		library_finished(Symptom_library, _, If_library_finished),
		(If_library_finished -> assert(diagnose_ready(true)); true)
	).

% having a certain illness means having all its symptoms
diagnose_iterator(Illness):-
	findall(Sympotms, symptom_positive(Sympotms), PositiveSymptoms),
	illness(Illness, SymptomList), 
	is_subset(SymptomList, PositiveSymptoms).

% find all possible illnesses based on positive answers
diagnose(List):-
	findall(Illness, diagnose_iterator(Illness), List).

