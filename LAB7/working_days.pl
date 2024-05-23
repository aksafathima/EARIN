% Allow clauses of predicates to be defined non-contiguously
:- discontiguous day_of_week/2.
:- discontiguous month_days/2.

% Definitions and dynamic declarations
:- dynamic month_days/2, next_weekday/2, is_weekend/1.

% Define the length of each month in 2024 (leap year)
month_days(1, 31).
month_days(2, 29).
month_days(3, 31).
month_days(4, 30).
month_days(5, 31).
month_days(6, 30).
month_days(7, 31).
month_days(8, 31).
month_days(9, 30).
month_days(10, 31).
month_days(11, 30).
month_days(12, 31).

% Define days of the week following each other
next_weekday(monday, tuesday).
next_weekday(tuesday, wednesday).
next_weekday(wednesday, thursday).
next_weekday(thursday, friday).
next_weekday(friday, saturday).
next_weekday(saturday, sunday).
next_weekday(sunday, monday).

% Check for weekends
is_weekend(saturday).
is_weekend(sunday).

% Base day of the week for the starting known date
day_of_week(date(2024, 1, 1), monday).

% Get the next day, considering month-end and year-end
next_day(date(Y, M, D), NewDate) :-
    month_days(M, MaxD),
    (   D < MaxD
    ->  NewD is D + 1,
        NewDate = date(Y, M, NewD)
    ;   (   M == 12
        ->  NewY is Y + 1, NewM = 1
        ;   NewY = Y, NewM is M + 1
        ),
        NewDate = date(NewY, NewM, 1)
    ).

% Recursive function to add working days, skipping weekends
add_working_days(CurrentDate, 0, CurrentDate, CurrentWeekDay) :-
    day_of_week(CurrentDate, CurrentWeekDay).
add_working_days(CurrentDate, N, ResultDate, ResultWeekDay) :-
    N > 0,
    next_day(CurrentDate, NextDate),
    day_of_week(NextDate, NextWeekDay),
    (   is_weekend(NextWeekDay)
    ->  add_working_days(NextDate, N, ResultDate, ResultWeekDay)
    ;   N1 is N - 1,
        add_working_days(NextDate, N1, ResultDate, ResultWeekDay)
    ).

% Calculate the weekday by advancing from a known date
day_of_week(Date, WeekDay) :-
    day_of_week(date(2024, 1, 1), KnownWeekDay),
    date_difference(date(2024, 1, 1), Date, Difference),
    weekday_after(KnownWeekDay, Difference, WeekDay).

% Calculate the difference in days between two dates
date_difference(Date1, Date2, Difference) :-
    date_difference(Date1, Date2, 0, Difference).

date_difference(date(Y, M, D1), date(Y, M, D2), Acc, Difference) :-
    !, Difference is Acc + D2 - D1.
date_difference(date(Y1, M1, D1), date(Y2, M2, D2), Acc, Difference) :-
    month_days(M1, MaxD1),
    NewAcc is Acc + MaxD1 - D1 + 1,
    (   M1 == 12
    ->  NewY is Y1 + 1, NewM = 1
    ;   NewY = Y1, NewM is M1 + 1
    ),
    date_difference(date(NewY, NewM, 1), date(Y2, M2, D2), NewAcc, Difference).

% Calculate the weekday after a certain number of days
weekday_after(WeekDay, 0, WeekDay).
weekday_after(WeekDay, Days, ResultWeekDay) :-
    Days > 0,
    next_weekday(WeekDay, NextWeekDay),
    Days1 is Days - 1,
    weekday_after(NextWeekDay, Days1, ResultWeekDay).
