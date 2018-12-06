%% =================================
%%  CMPU-245, Fall 2018
%%  Asmt. 4
%%  Parker Zimmerman
%% =================================
%%  Electronic Submission Due:  Wed, Dec. 12 at 11:59 p.m.  
%%  Printouts can be left in the bin outside my door. 

%%  For this assignment, you should provide Prolog facts and
%%  rules for the following predicates.  To facilitate your
%%  work, some facts and rules have been provided for you.

%%  NOTE:  Your code should be nicely formatted, with adequate
%%         comments.  Long lines should NOT wrap around!!

%%  1.  Prerequisites for CMPU courses at Vassar
%% -----------------------------------------------

%%  prereqs(+C,Pre) 
%% ------------------------------------------
%%  holds if Pre is the list of pre-requisite courses for the course C

%%  Note:  The desired info is available from AskBanner.
%%         For this asmt, we only care about the pre-reqs that are CS courses.
%%         Don't worry about "recommended" courses, Math courses, etc.

%%  Sample facts/rules: 
%%    prereqs(cs101,[]).
%%    prereqs(cs145,[cs101]).

prereqs(cs101,[]).
prereqs(cs102, [cs101]).
prereqs(cs145, [cs101]).
prereqs(cs203, [cs102]).
prereqs(cs224, [cs102, cs145]).
prereqs(cs235, [cs102, cs145]).
prereqs(cs240, [cs102, cs145]).
prereqs(cs241, [cs102, cs145]).
prereqs(cs245, [cs102, cs145]).
prereqs(cs250, [cs102]).
prereqs(cs324, [cs224]).
prereqs(cs331, [cs224, cs240]).
prereqs(cs334, [cs203, cs224]).
prereqs(cs353, [cs203]).
prereqs(cs365, [cs145, cs203, cs245]).
prereqs(cs366, [cs240]).
prereqs(cs375, [cs203]).
prereqs(cs376, []).
prereqs(cs377, [cs203, cs224]).
prereqs(cs378, []).
prereqs(cs379, []).



%%  offered(+C,+Sem)   <=== facts and rules provided for you below
%% -----------------------------------------------------------------
%%  holds if the course C is offered in the semester Sem
%% -----------------------------------------------------------------
%%  Define in terms of the following helper predicates:
%%    offeredList(C,Sems) -- holds if C is offered during the listed semseters
%%      Example:  offeredList(cs245,[2,3,7]).

%% Courses that are offered every semester.

offered(cs101,_S).
offered(cs102,_S).
offered(cs145,_S).
offered(cs203,_S).
offered(cs224,_S).
offered(cs240,_S).
offered(cs241,_S).

%% Courses that are offered *sometimes*

%% Note:  Facts of the form, offeredList(C,Sems) are used to represent
%%        that the course C is offered during the semesters listed in
%%        Sems.  See examples below.

offered(C,Sem) :-
  offeredList(C,Sems),
  member(Sem,Sems).

%%  Note:  The following course-offering info is not intended to accurately
%%         reflect actual course offerings at Vassar, but it is close enough
%%         for our purposes.

%%  200 electives

offeredList(cs235,[1,4]).
offeredList(cs245,[2,3,7]).
offeredList(cs250,[5,6,8]).

%%  300 required

offeredList(cs331,[2,4,6,8]).
offeredList(cs334,[1,3,5,7]).

%%  300 electives

offeredList(cs324,[4,8]).
offeredList(cs353,[2,6]).
offeredList(cs366,[2,6]).
offeredList(cs365,[4,8]).
offeredList(cs375,[1,5]).
offeredList(cs376,[1,5]).
offeredList(cs377,[3,7]).
offeredList(cs378,[1,5]).
offeredList(cs379,[3,7]).


%%  2. canTake
%% -----------------------------------------------

%%  canTake(+C,+PrevCourses,+Sem)
%% -----------------------------------------------
%%  holds if the course C is offered during the semester Sem, and 
%%  PrevCourses contains all the prerequisites for C.

%%  Note:  If C is a 300-level course, it can only be taken if
%%         PrevCourses includes at least two 200-level courses.

%%  To help with this latter requirement, define facts/rules for the 
%%  following helper predicates:
%%    2a.  lowerLevel(C) -- holds if C is a 100-level or 200-level course
%%    2b.  midLevel(C) -- holds if C is a 200-level course
%%    2c.  atLeastNTwos(N,PrevCourses) -- holds if PrevCourses contains
%%                at least N 200-level courses.

%%  Then the additional requirement for taking a 300-level course 
%%  can be expressed as:
%%    "if C is a 300-level course, then PrevCourses must contain at
%%        least two 200-level courses"
%%  which is equivalent to:
%%    "either C is a lower-level course (100-level or 200-level)
%%     *OR* PrevCourses must contain at least 2 200-level courses"

%%  (Hint:  How is "disjunction" (i.e., OR) represented in Prolog syntax?)
lowerLevel(C) :- subset([C], [cs101,cs102,cs145,cs203,cs224,cs234,cs240,cs241,cs245,cs250]).
midLevel(C) :- subset([C], [cs203,cs224,cs234,cs240,cs241,cs245,cs250]).

atLeastNTwos(0,PrevCourses).
atLeastNTwos(N,PrevCourses) :-
    subset([C], PrevCourses),
    midLevel(C),
    delete(PrevCourses, C, RestC),
    atLeastNTwos(N-1, RestC).

canTake(C, PrevCourses, Sem) :-
    offered(C, Sem),
    lowerLevel(C),
    prereqs(C, PrevCourses).
canTake(C, PrevCourses, Sem) :-
    offered(C, Sem),
    \+lowerLevel(C),
    atLeastNTwos(2, PrevCourses),
    prereqs(C, PrevCourses).

%%  3.  selectCourse
%% ---------------------------------------------------------------

%%  selectCourse(-C, +PrevCourses, +CoursesLeft, -RemCourses, +Sem)
%% --------------------------------------------------------------
%%  holds if C is a course that can be taken during semester Sem,
%%  given that the courses listed in PrevCourses have already been
%%  taken.  C must be drawn from CoursesLeft.  RemCourses is what
%%  remains after removing C from CoursesLeft.  (See "select" from the
%%  map-coloring code.)

selectCourse(C,PrevCourses,CoursesLeft,RemCourses,Sem) :-
    canTake(C, PrevCourses,Sem),
    select(CoursesLeft, C, RemCourses).


%%  4.  incrementally fleshing out a full schedule
%% ---------------------------------------------------------------

%%  fillSched(+PrevSched, +PrevCourses, +CurrCourses, +MaxPer, +CoursesLeft,
%%                        +Sem, -FullSched)
%% --------------------------------------------------------------------
%%  holds if the current partial schedule can be fleshed out into a
%%  full schedule that satisfies the C.S. major. 
%% --------------------------------------------------------------------
%%  PrevSched is a list containing info about the courses taken in 
%%    each of the prior semesters.  Each element of PrevSched has the
%%    form N/Cs, where N is the number of the semester (1 <= N <= 8), 
%%    and Cs is the list of courses taken in that semester 
%%    (e.g., [cs102,cs145]));
%%  PrevCourses is a *flat* list of *all* the C.S. courses from *all*
%%    of the semesters included in PrevSched (e.g., [cs101,cs102,cs145]);
%%  CurrCourses are the C.S. courses that are being scheduled (so far)
%%    for the current semester (Sem);
%%  MaxPer is an upper bound on the number of C.S. courses that can be
%%    taken during any one semester (e.g., MaxPer might be 3);
%%  CoursesLeft are the C.S. courses that the student has not yet
%%    scheduled that are needed to complete the major;
%%  Sem is the semester number (1-8); and
%%  FullSched is the resulting full schedule (typically not known until
%%    until the very end).

%%  Note:  A partial schedule can be incrementally fleshed out
%%         in the following ways:
%%   (1) If possible, select a course to add to CurrCourses for this 
%%         semester.  (Recursive goal will stay in this semester.)
%%   (2) Move to the next semester.  (Recursive goal will involve 
%%         appending Sem/CurrCourses to the PrevSched.)
%%   (3) The current semester is 9, indicating that semesters 1-8 are
%%         included in PrevSched, which means that you're done.
%% ---------------------------------------------------------------------
%% (1) is not possible if you've already scheduled MaxPer courses for
%%     the current semester, or there's no course that you're able
%%     to add to the current semester because of pre-reqs.
%% (2) is not possible if the number of courses left is too big to
%%     fit into the remaining semesters.  (For example, if there
%%     are 8 courses left, but only 2 semesters left, and MaxPer = 3,
%%     then there's not enough room left to schedule the remaining
%%     courses.  Including this constraint will make the search for 
%%     a solution faster.)
%% (3) is not allowed if CoursesLeft is not empty, among other things.

%%  Here's case (3), done for you!

fillSched(PrevSched, _PrevCourses, [], _MaxPer, [], 9, FullSched) :-
  %% Since accumulating schedule in a list, it comes out backwards;
  %% so, need to reverse it
  reverse(PrevSched,FullSched),
  %% Hey, let's print it out nicely!  (printSemester defined below)
  maplist(printSemester,FullSched).


%% ---------------------------------------------------------------
%%  Some additional facts/rules to help you out.
%% ---------------------------------------------------------------

%%  printSemester(+Sched)
%% ---------------------------------------------------------------
%%  always succeeds.  causes the Sched for *one* semester to be 
%%  printed out nicely.  assumes Sched has the form:  N/Courses.
%%  For example, Sched might be:  1/[cs101].  Another example:
%%  2/[cs102,cs145].

printSemester(N/Courses) :-
  format('Semester ~w: ~w \n', [N,Courses]).

%%  "Wrapper predicate" to facilitate testing:

%%  makeSched(+MaxPer,+TwoElec,+ThrElecA,+ThrElecB,-FullSched)
%% ---------------------------------------------------------------
%%  holds if there is a FullSched of courses (over 8 semesters)
%%  that satisfies the C.S. major requirements, as follows:
%%   MaxPer = max number of CS courses in any single semester
%%   TwoElec = one of cs235, cs245, cs250
%%   ThrElecA = one of the 300-level electives
%%   ThrElecB = another of the 300-level electives

makeSched(MaxPer,TwoElec,ThrElecA,ThrElecB,FullSched) :-
  member(TwoElec,[cs235,cs245,cs250]),
  subset([ThrElecA,ThrElecB],[cs324,cs325,cs353,cs365,cs366,cs375,cs376,
           cs377,cs378,cs379]),
  %%  We assemble the list of courses as follows to make the search
  %%  go faster.  Note that the courses need not be scheduled in this
  %%  order, but the actual order will probably not deviate too much
  %%  from this
  ListyOne = [cs101,cs102,cs145,cs203,cs224,cs240,cs241],
  ListyTwo = [TwoElec,cs331,cs334,ThrElecA,ThrElecB],
  append(ListyOne,ListyTwo,Listy),
  %%  Here's the call to "fillSched" with suitably initialized arguments
  %%  Notice that PrevSched = PrevCourses = CurrCourses = []
  %%  Listy = the full list of courses needed to satisfy the major
  %%  FullSched won't be instantiated until the entire goal succeeds.
  fillSched([],[],[],MaxPer,Listy,1,FullSched).

%%  Here's an example:

%% ?- makeSched(3,cs245,cs365,cs377,FullSched).
%% Semester 1: [cs101]          <--- These 8 lines are side-effect printing
%% Semester 2: [cs145,cs102]
%% Semester 3: [cs240,cs224,cs203]
%% Semester 4: [cs331,cs241]
%% Semester 5: [cs334]
%% Semester 6: []
%% Semester 7: [cs377,cs245]
%% Semester 8: [cs365]                        
%% FullSched = [1/[cs101], 2/[cs145, cs102], 3/[cs240, cs224, cs203], 
%%              4/[cs331, cs241], 5/[cs334], 6/[], 7/[cs377|...], 8/[...]] .

%% The last line "FullSched = ..." is "the answer".  See why we used "maplist"
%% and "printSemester"!


%% =======================================================
%%  TESTING WILL BE A SIGNIFICANT PART OF YOUR GRADE!
%% =======================================================
%%  You should include MANY separate tests for EACH of the following predicates
%%  to demonstrate that they work properly when tested in isolation:
%%     prereqs, canTake, selectCourse, fillSched.
%%  For "fillSched", create some tests that start with a full (or nearly
%%  full) schedule.  For example, you might try defining a TESTER predicate
%%  like this:

tester(0,F) :-
  PrevSched = [1/[cs101],2/[cs145,cs102],3/[cs224,cs203],4/[cs235,cs240],
               5/[cs376,cs241],6/[cs366,cs331],7/[cs334],8/[]],
  PrevCourses = [cs101,cs102,cs145,cs203,cs224,cs240,cs241,cs235,cs331,cs334,cs366,cs376],
  fillSched(PrevSched, PrevCourses, [], 2, [], 9, F).

%%  Other test cases can be constructed similarly (using a first argument that
%%  is a different number).  That way, at the command line, you can just type:
%%  tester(0,F) instead of the whole big mess above.

tester(_N,F) :-
  write('This test not yet defined!\n').

%%  You should define MANY such test expressions for fillSched.

%%  When everything appears to be working, *then* you should define SEVERAL
%%  MORE test expressions for makeSched.

%%  As described in asmt8-template.txt, you should define an "output"
%%  predicate that generates all of your test results in a nicely formatted
%%  manner.  And you should generate an output file that you will include
%%  in your electronic submission, and that you will print out.  See
%%  "asmt8-template.txt" for more details.

%%  HINTS:  If testPrereqs takes two arguments (e.g., cs101 and Cs)
%%          you can use:  maplist(testPrereqs,[cs101,cs353,cs366],_Listy)
%%    Listy represents the list of answers (each element being a list of
%%    prereqs for one of the given courses).

%%    Run "output." at the prolog query to test your "output" predicate.
%%    You don't have to create an output file every time you test; only
%%    at the end, when you're done.


%% ==============================
%%  TEST PREDICATES  --  provided by your helpful professor!
%% ==============================

%%  testPrereqs(+C,Cs)
%% --------------------------

testPrereqs(C,Cs) :-
  prereqs(C,Cs),
  format('  prereqs(~w,~w)\n',[C,Cs]).

%%  testCanTake(+C,+Cs,+Sem)
%% ----------------------------

testCanTake(C,Cs,Sem) :-
  canTake(C,Cs,Sem),
  format('  canTake(~w,~w,~w)\n',[C,Cs,Sem]).

testCanTake(C,Cs,Sem) :-
  \+ canTake(C,Cs,Sem),
  format('  NOT canTake(~w,~w,~w)\n',[C,Cs,Sem]).

%%  testSelectCourse(+C, +PrevCourses, +CoursesLeft, -RemCourses, +Sem)
%% ----------------------------------------------------------------------

testSelectCourse(C,PrevCourses,CoursesLeft,RemCourses,Sem) :-
  selectCourse(C,PrevCourses,CoursesLeft,RemCourses,Sem),
  format('  selectCourse(~w,~w,~w,~w,~w)\n',[C,PrevCourses,CoursesLeft,RemCourses,Sem]).

testSelectCourse(C,PrevCourses,CoursesLeft,RemCourses,Sem) :-
  \+ selectCourse(C,PrevCourses,CoursesLeft,RemCourses,Sem),
  format('  NOT selectCourse(~w,~w,~w,~w,~w)\n',[C,PrevCourses,CoursesLeft,RemCourses,Sem]).

%%  testFillSched
%% ------------------------------

testFillSched(N) :-
  format('Test ~w: \n', N),
  tester(N,F),
  write('\n').

%%  output
%% -----------------------------------------------------
%%  a proposition that always succeeds.  used to perform tests
%%  and print out results.

output :-
  write('\n-----------------------\n'),
  write(' CMPU-245, Fall 2016\n'),
  write(' Asmt. 9 YOUR_NAME_GOES_HERE!\n'),
  write('-----------------------\n\n'),

  write('PROBLEM ONE:  Testing prereqs:\n'),   %% This example uses maplist
  maplist(testPrereqs,[cs101,cs145],_Listy),   %% <--- Add MORE TESTS!

  write('\nPROBLEM TWO:  Testing canTake:\n'),
  maplist(testCanTake,[cs101,cs245],
                      [[],[cs101,cs102]],
                      [3,4]),                  %% <--- Add MORE TESTS!

  write('\nPROBLEM THREE:  Testing selectCourse:\n'), %% This example doesn't use maplist
    testSelectCourse(C,[],[cs101,cs102,cs145],RemCourses,4),  %% <--- Add MORE TESTS!

  write('\nPROBLEM FOUR:  Testing fillSched:\n'),  %% This example uses maplist
    maplist(testFillSched,[0,1,2]),   %% <--- Add MORE TESTS!!

  %% ==> Include tests for makeSched too!!

  %% The following ensures no attempts will be made to find more
  %% than one way of satisfying any of the above predications:
  !.