% map items in libraries to human-friendly words.
human_symptom(unbearable_pain	,'unbearable pain').
human_symptom(lot_of_pain		,'lot of pain').
human_symptom(manageable_pain	,'manageable pain').
human_symptom(mild_pain			,'mild pain').
human_symptom(no_pain			,'no pain').

human_symptom(calm				,'calm').
human_symptom(angry				,'angry').
human_symptom(weepy				,'weepy').
human_symptom(anxious			,'anxious').
human_symptom(malaise			,'malaise').

human_symptom(temperature		,'running a temperature').
human_symptom(sweat				,'sweat').
human_symptom(ache				,'ache').
human_symptom(sneeze			,'sneeze').
human_symptom(cough				,'cough').
human_symptom(blood				,'bleed').
human_symptom(breathe_rapidly	,'having to breathe rapidly sometimes').
human_symptom(headache			,'a headache').
human_symptom(bruise			,'having a bruise').

human_illness(fever				,'a fever. Next, I will give you some medicine to treat the fever.').
human_illness(cold				,'caught a cold. Next, I will give you some medicine to treat the cold.').
human_illness(injury			,'an injury. Now we are going to do some further examinations.').
human_illness(cancer			,'cancer. Please stay calm and we will do some further examinations.').
human_illness(anxiety_disorder	,'an anxiety disorder. Please stay calm and we will do some further examinations.').
human_illness(no_illness		,'no illness. Congratulations!').

human_gesture(look_concerned	,'looks concerned').
human_gesture(mellow_voice		,'mellow voice').
human_gesture(light_touch		,'light touch').
human_gesture(faint_smile		,'faint smile').
human_gesture(greet				,'greet').
human_gesture(look_composed		,'looks composed').
human_gesture(look_attentive	,'looks attentive').
human_gesture(broad_smile		,'broad smile').
human_gesture(joke				,'joking').
human_gesture(beaming_voice		,'beaming voice').

% greetings before asking a question
openings('All right, ').
openings('My friend, ').
openings('Hmm, ').
openings('Take your time, but ').
openings('My dear patient, ').
% Randomly select an opening from library above
opening(Opening):-
	findall(A, openings(A), OpeningsList),
	random_member(Opening, OpeningsList).

% prepare for asking a question
question_starts('do you feel ').
question_starts('are you feeling ').
question_start(QuestionStart):-
	findall(A, question_starts(A), Question_startsList),
	random_member(QuestionStart, Question_startsList).

% map diagnose results to human-friendly words
human_diagnose(L, H):-
	length(L, Len),
	(
		Len==0 -> human_illness(no_illness, H);
		(
			convlist([X,Y] >> human_illness(X,Y), L, HL),
			atomic_list_concat(HL, ', or ', H)
		)
	).

