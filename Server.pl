% This file creates a web server based on SWI-Prolog

:-debug.
:-['DoctorLogic.pl'].
:-['HumanizedOutput.pl'].
:-use_module(library(http/thread_httpd)).
:-use_module(library(http/http_dispatch)).
:-use_module(library(http/html_write)).
:-use_module(library(http/http_files)).
:-use_module(library(http/http_client)).
:-use_module(library(http/http_error)).

% rule for ststic files handler
:- multifile http:location/3.
:- dynamic   http:location/3.
http:location(files, '/static', []).
:- http_handler(files(.), http_reply_from_files('static', []), [prefix]).

% handle the root of the tree by querying the goal web_doctor
:- http_handler(/, web_doctor, []).

% main loop for server
server(Port) :-
	http_server(http_dispatch, [port(Port)]).

% reply the clint next question page.
render_question_page:-
	gesture(Gesture),
	human_gesture(Gesture, HumanGesture),			% get Gesture
	opening(Opening),								% get Opening
	question_start(QuentionStart),					% get question start
	nextQuestion(Question),
	human_symptom(Question, HumanQuestion),			% get next question
	% define returned HTML page
	reply_html_page(
		[title('Sympathetic Doctor Talking Box--Diagnosing...')],
		[center(h1('Sympathetic Doctor Talking Box')),
		center(img(src='static/doctor.jpg')),
		center(p(['*', HumanGesture, '*'])),
		center(p([Opening, QuentionStart, HumanQuestion,'?'])),
		center(
			form([action='/', method='post'],
				[
				input([type='hidden', name='question', value=Question],[]),
				input([type='radio', id='yes', name='answer', value='yes', checked],[]),
				label([for='yes'], ['yes']),
				input([type='radio', id='no', name='answer', value='no'],[]),
				label([for='no'], ['no']),
				button([type='submit'],['Submit'])
				])
		)]
	).

% reply the clint diagnose result page
render_diagnose_page:-
	gesture(Gesture),
	human_gesture(Gesture, HumanGesture),		% get gesture
	opening(Opening),							% get opening
	diagnose(Result),
	human_diagnose(Result, Human_result),		% get diagnosis
	% define returned HTML page
	reply_html_page(
	   [title('Sympathetic Doctor Talking Box--Diagnosed!!!')],
	   [center(h1('Sympathetic Doctor Talking Box')),
		center(img(src='static/doctor.jpg')),
		center(p(['*',HumanGesture,'*'])),
		center(p([Opening,'you might have ', Human_result])),
		center(p('If you\'d like to try again, please restart the server.'))]
	).

% handling answers and following questions.
web_doctor(Request):-
	member(method(post), Request), !,
	http_read_data(Request, [question=Question, answer=Answer|_], []),
	answer(Question,Answer),
	(current_predicate(diagnose_ready/1) -> render_diagnose_page; render_question_page).

% handling the first request
web_doctor(_Request):-
	(current_predicate(diagnose_ready/1) -> render_diagnose_page; render_question_page).

% start the server
:- server(8000).
