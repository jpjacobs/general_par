NB. general parallel utilities
NB. Thread management
NB. ensurethr ensures at least y threads are available
NB.  - y: threads to ensure available
NB.  - returns number of threads ensured
NB. possible extension: - [x]: 1: all threads; 2 free threads (as for T.), but would need complicated validation and postproc. better make separate verb if needed
ensurethr =: 1&$: : (0&T.@''^:(-[>./@:T.''"_))

NB. matrushka semaphore
NB. each call sends a new pyx to put the response in. Make sure to balance calls and order, otherwise hangs are ensured.
NB. to start, create pyx, and send it, together with args to task.
NB. startsema, adverb, does this. It takes
NB. - u: task to run, a monad taking boxed y, first of which is a pyx for new call to u.
NB. the derived verb takes:
NB. - x: timeout value to be used
NB. - y: initial arguments
NB. TODO a pro could probably write this tacitly...

startsema=: {{lp,fp=. u t. '' (lp=. 5 T. x) ,&< y [ensurethr 1}}
NB. test=: {{
NB. 'p a'=. y
NB. echo datatype p
NB. echo 4 T. p
NB. 6 T. p,<'seen!'
NB. +: a
NB. }}
NB. 

