NB. Class for coroutines
NB. uses Henry's suggested semaphore mechanism, wrapped in an OOP object to limit loose pieces hanging around.

coclass 'coro'
NB. creator function, does not do much but verify at least 1 thread is running.
create =: {{
	0&T.@''^:(-1&T.@'') 1 NB. ensure 1 thread
	NB. starting of coro needs to be handled by adverb (new), as it requires the verb to be taken as arg.
}}
NB. entrypoint: adverb taking coroutine verb and returns a verb that takes a timeout as x and as y any initial arguments. This derived verb in turn returns a reference to the coro object to refer to when using yield__x and resume__ref.
new =: {{
  co =. conew 'coro'
  WAIT__co =: x
  pyxback__co =: 5 T. x
  pyxfin__co=: co u t. ''y
  co
}} (30&$: :) NB. default timeout: 30 s
NB. naming convention:
NB. - forw suffix is for passing stuff from main to coro
NB. - back suffix is for passing stuff from coro to main
NB. Mutex needed?
sendsema =:{{ pl [ 6 T. x,<(pl =. 5 T. WAIT);<y}}
NB. yield: Only called by the coro. takes values to pass back to the "main" thread, returns values passed to the resume function in the "main" thread.
yield  =: {{r [ pyxback=:p [ 'p r'=. > pyxforw =: pyxback sendsema y}}
NB. resume: Only called by the "main" thread. Passes aruments to the coro and returns yielded values from the coro.
resume =: {{r [ pyxforw=:p [ pyxback =: pyxforw sendsema y [ 'p r'=.>pyxback}}

NB. status returns 1 when coro is active, and 0 when it has ended, based on whether pyx fin is pending, i.e. > 0
NB. takes as optional y a tiny delay needed for allowing coroutine to return if done, default 0.001
status  =: {{0 < 4 T. pyxfin [ 6!:3]{.y,0.001 }}
destroy =: {{
  echo 'destroy called:',":coname''
	NB. if anything is hanging/waiting, send them an error.
	for_p. pyxforw,pyxback,pyxfin do.
		if. 0 < 4 T. p do. 7 T. p,<18 end.
	end.
	codestroy '' NB. remove locale
}}
NB. shortcut for getting return value from the final pyx and disposing of object.
end =: {{r [ destroy '' [ r=.>pyxfin}}

NB. back to base for a test
cocurrent'base'
NB. test coroutine; only limitation: x is be coro object reference passed by new_coro_ function
test =: {{
	echo 'C: coro init done'
	echo 'C: test init args ', y NB. presume literal args
	args =. yield__x |. y
	echo 'C: got new args: ', args
	args =. yield__x |. args
	echo 'C: sigh ... I''ve had enough of this: ',args
	'ret: so long and thanks for all the fish'
}}

NB. first test, simple
main =: {{
  echo 'main starting!'
	c =: 10 test new_coro_ 'init args for C'
	echo 'M: got from coro: ', resume__c 'what the ...'
	echo 'M: got from coro(2): ', resume__c 'last warning'
	echo pyxfin__c
	end__c
  echo'end'
}}

NB. second test, using loop and status.
main2 =: {{
	c =: 10 test new_coro_ 'init 2'
	while. status__c'' do.
		echo resume__c 'abcde' {~ 3 ?@$ 5
	end.
	end__c ''
}}

