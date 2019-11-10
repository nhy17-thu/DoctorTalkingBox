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
	human_gesture(Gesture, Human_gesture),      % get Gesture
	opening(OP),                                % get Opening
	question_start(QS),                         % get question start
	nextQuestion(Question),
	human_symptom(Question, Human_question),    % get next question
	% define returned HTML page
	reply_html_page(
	   [title('Professional Talking Box Doctor')],
	   [center([style='font-size: 36pt', title='tooltip text'],'Professional Talking Box Doctor'),
	   center([
			img([src='/static/doctor.jpg', width=128], []),br([]),
			'<    ',Human_gesture,'    >',br([]),
			OP,QS, Human_question,'?',
			br([]),
			form([action='/', method='post'],
				[
				input([type='hidden', name='question', value=Question],[]),
				input([type='radio', id='yes', name='answer', value='yes'],[]),
				label([for='yes'], ['yes']),
				input([type='radio', id='no', name='answer', value='no', checked],[]),
				label([for='no'], ['no']),
				button([type='submit'],['Submit'])
				])
		])]
		).

% reply the clint diagnose result page
render_diagnose_page:-
	gesture(Gesture),
	human_gesture(Gesture, Human_gesture),		% get gesture
	opening(OP),                            	% get opening
	diagnose(Result),
	human_diagnose(Result, Human_result),		% get diagnose result
	% define returned HTML page
	reply_html_page(
	   [title('Professional Talking Box Doctor')],
	   [center([style='font-size: 36pt', title='tooltip text'],'Professional Talking Box Doctor'),
		center([
			img([src='img/doctor.jpg', width=128], []),br([]),
			'<    ',Human_gesture,'    >',br([]),
			OP,'You might have ', Human_result
		]),
		center('To start over, please restart the server.')]
		).

% handling answers and following questions.
web_doctor(Request):-
	member(method(post), Request), !,
	http_read_data(Request, [question=Q, answer=A|_], []),
	answer(Q,A),
	(current_predicate(diagnose_ready/1) -> render_diagnose_page; render_question_page).

% handling the first request
web_doctor(_Request) :-
	(current_predicate(diagnose_ready/1) -> render_diagnose_page; render_question_page).

% start the server
:- server(8000).
