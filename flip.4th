( 1  Forth List Interpreter Program )  
variable flip-task  

hex  
                01 constant fbit 
                01 constant obit 
                02 constant lbit 
0FFFFFFFC constant linkmask  
decimal  
            1000 constant maxcells  
              400 constant strbufsize  
                   4 constant ptrwidth  
                      variable oblist 
                      variable strpos 
                      variable cells      maxcells ptrwidth u* 2* allot  
                      variable strings  strbufsize allot  

hex
: 'do         sys 4C +origin d@ ;  attila 
: 'endo sys 54 +origin d@ ;  attila  
: 'push           sys 58 +origin d@ ;  attila  
( : 'next            sys 5C +origin d@ ;  attila  )
: >flip  ( codelistobj-cfa -> )
  sys 50 +origin d@ execute ;  attila  
  decimal
    
: cell   ( cell-idx -> cell-addr )
  ptrwidth u* 2* cells + ;   
  
: release-cells    ( -> )
  maxcells 0  
  do  i cell  ptrwidth +  
      dup c@ fbit or swap c!  
  loop ;  
  
: sweep-cells    ( -> )        sys [ smudge ] attila   
  dup   
  if  dup ptrwidth + c@ fbit xor over c!  dup c@   
    lbit and 0> over  d@ linkmask and  dup 0>  rot and  
    if  sweep-cells  else  drop  then  
  then   
  dup ptrwidth + dup c@ lbit and 0>  swap  
  d@ linkmask and  dup 0>  rot and   
  if  sweep-cells  else  drop  then  drop ;    smudge  
  
: use-cells   ( -> )
  oblist d@ sweep-cells ;  
  
: collect   ( -> )
  release-cells use-cells ;  
  
: get-cell   ( -> cell-addr )
  maxcells 0  
  do  i cell dup  ptrwidth + c@ dup  fbit and  
    if   fbit xor over ptrwidth + c!  leave  
    else  
      maxcells 1- i = if  ."  no free cells " abort  then  
      2drop    
    then  
  loop ;  
  
: init-flip  ( ->  )
  strings strpos d!
  cells maxcells ptrwidth u* 2* 0 fill   
  release-cells   get-cell oblist d! ;  
     
: hd   ( cell-address -> hd-val )
  d@ linkmask and ;  
  
: tl    ( cell-address -> tl-val )
  ptrwidth + d@ linkmask and ;  
  
: 'obexec   ;  
: 'obval     tl ;   
: 'obprint  tl tl ;  
: 'obsym   tl tl tl ;  
: obexec   hd ;  
: obval      'obval hd ;   
: obprint   'obprint hd ;  
: obsym    'obsym hd ;    
    
hex  
 
 : newest-obj   ( -> obj-addr )
  oblist d@  hd ;
  
: symprint   ( obj-addr -> )  
  'obsym d@ dup 1+ swap c@ 1F and type space ;    
  
: strprint  ( obj-addr -> )  
  'obval d@  count type space ;  
  
: intval ( obj-addr -> val )  
  'obval d@  ;  
  
: printval  ( obval ->  ) 
   . ; 
  
: execval  ( obj-addr -> )
  'obval d@ sys execute ; attila
  
: print-obj  ( obj-addr -> )  
  dup 'obval swap obprint sys execute ;  attila  
  
: exec-obj  ( obj-addr -> ) 
  dup ( obval swap ) obexec sys execute ;  attila  
  
  : exec-list  ( list-addr -> )  sys [ smudge ] 
  begin  dup  linkmask and d@   0>  while  
    dup linkmask and dup >r   dup d@ lbit and  
    if   linkmask and  d@ exec-list  
    else   d@  exec-obj 
    then  r>  ptrwidth + d@
  repeat  drop   ;  smudge attila  
  
: print-symbols  ( list-addr -> )   sys [ smudge ]  
  ." { "  
  begin  dup  d@ dup linkmask and 0>  while  
    dup lbit and  
    if  linkmask and print-symbols  
    else  symprint 
    then  tl  
  repeat  2drop  ." } " ;  smudge attila  
    
: exec-listobj  ( ob-addrj -> )  
  obval exec-list ;  
      
: (exec-obj)   ( obj-addr -> {exec-results...} )
  'obval d@ exec-list  ; 
  
: (print-obj)   ( obval ->  )
   linkmask and print-symbols  ;
 
: print-litlist  ( list-addr -> )  sys [ smudge ]  
  ." { "  
  begin  dup   tl 0>   while  
    dup d?   tl  
  repeat  drop  ." } " ;  smudge attila  
  
: exec-litlist  ( obj-addr -> )  sys [ smudge ]  
  obval
  begin  dup   tl 0>   while  
    dup d@   swap tl  
  repeat  drop  ;  smudge attila    
  
  : point-to (   )
   ;
   
: add-new-obj  ( -> )  
  oblist d@ lbit or 
  get-cell dup  oblist d! ptrwidth + d!  
  get-cell dup lbit or  oblist d@ d!  sys  
  0 over d!  ptrwidth +   
  get-cell  dup lbit or rot d!  
  0 over d!  ptrwidth +  
  get-cell  dup lbit or rot d!  
  ' symprint cfa over d! ptrwidth +  
  get-cell  0 over d! 
  lbit or swap d! ; attila  
   
: as-list   ( obj-addr -> list-addr )
  obval ;  
  
: ft    ( cell-addr -> emptycell-addr )
  begin  linkmask and ptrwidth +  dup c@ lbit and  while  
    d@  
  repeat ;  
  
: str$  ( {varname} {string} -> )  
  add-new-obj  create newest-obj d,  
  sys  latest newest-obj 'obsym d!  
  ' strprint cfa newest-obj 'obexec d!  attila  
  bl word count  
  dup 1+ strpos d@ + strings - strbufsize >  
  if  ."  string buffer full " abort  then  
  strpos d@  over over c!  
  1+ swap cmove  
  strpos d@  dup newest-obj 'obval d!  
  c@ 1+ strpos d+! 
  does> d@ ;  
  
: int  ( int {varname} -> )  
  add-new-obj  create newest-obj d,  
  sys latest newest-obj 'obsym d!  
  ' intval cfa newest-obj 'obexec d!  
  ' printval cfa newest-obj 'obprint d!  attila 
  newest-obj 'obval d!  
  does> d@ ;  
  
: exec  ( int {varname} -> )  
  add-new-obj  create newest-obj obit or d,  
  sys latest newest-obj 'obsym d!  
  ' execval cfa newest-obj 'obexec d!  attila  
  newest-obj 'obval d!  
  does> d@ ;  
  
: newlist  ( {listname} -> )  
  add-new-obj  create newest-obj d,  
  sys latest newest-obj 'obsym d!  
  ' (exec-obj) cfa newest-obj 'obexec d! 
  ' (print-obj) cfa newest-obj 'obprint d!  attila
  newest-obj 'obval get-cell lbit or swap d! 
  does> d@ ;  
  
: l+  ( obj-addr -> )  
  newest-obj 'obval d@ ft linkmask and  
  swap over ptrwidth - d!
  get-cell lbit or swap d! ;   
  
: .oblist  ( -> )  j
  ." { "  
  oblist  d@  
  begin  dup 0>  while  
    dup hd dup 0>  
    if  symprint  tl  else  swap drop  then  
  repeat drop  ." } " ;  
    
( : .s-list  ( list-addr -> )  ( sys [ smudge ]  )
(  dup hd 0>  )
(  if    dup d@ lbit and  )
(    if    ." { "   dup hd .s-list  )
(    else  dup hd symprint )
(    then  tl .s-list  )
(  else  drop  ." } "  )
(  then ;  smudge attila  )
  
( : symlist  ( list-addr -> )  
(  ." { " .s-list ;  )
  
: .tree  ( list-addr -> )  sys [ smudge ]  
    dup hd 0>  
    if    dup d@ lbit and  
      if    dup hd .tree  
      else  dup hd .val  
      then  tl .tree  
    else  drop  
    then ;  smudge attila  
  
: .revtree  ( list-addr -> )  sys [ smudge ]  
    dup tl 0>  
    if  
      dup tl .revtree  
      dup d@ lbit and  
      if    hd .revtree  
      else  hd .val   
      then  
    else  drop  
    then ;  smudge attila  
  
: flatten  ( list-addr -> )  sys [ smudge ]  
  begin  dup  d@ dup linkmask and 0>  while   
    dup lbit and  
    if  linkmask and flatten  else 
    else  l+  
    then  tl  
  repeat  2drop  ;  smudge attila  
  
( : it  ( cell-addr -> ) 
(  ft  get-cell dup lbit or rot d!  )
(  sys [compile] ' cfa  swap d! ;  immediate attila  )
  
( : obval2list  (  -> ) 
(  newest-obj 'obval get-cell dup lbit or rot d!  )
(  sys 'define swap d! ;  attila  )
  
init-flip  
  
str$ s1 apple 
str$ s2 banana  
str$ s3 cherry  
str$ s4 date  
str$ s5 berry  
  
newlist fruits 
s1 l+  
s2 l+  
s3 l+  
s4 l+  
  
newlist b-fruits  
s2 l+  
s5 l+  
  
b-fruits as-list lbit or fruits as-list tl d!  
  
1234567890 int i1  
        42 int i2  
     66667 int i3  
         4 int i4  
         0 int i5 
  
newlist set-A  
i1 l+  
i2 l+  
i3 l+ 
  
newlist set-B  
i4 l+  
i2 l+  
i5 l+  
 
set-B as-list lbit or set-A as-list tl d!  
  
  ' + sys cfa attila exec (+) 
  
newlist 4+ 
i4 l+ 
(+) l+

newlist lits
1 l+
2 l+
3 l+


endload


 to aaaa  ( mmm nnn )
   [
    pen up
    repeat 4 [  pen down  forward mmm   right nnn ]
    if  ( ccc is-less-than ddd )  [  bbb  ]
    end
   ]
   
[ aaaa with( mmm nnn ) := 
  ...
]
   
to aaaa with( mmm nnn ) := 
[
  ...
]   

to makelist :=
get a pointer lptr to a free cell
while next item is not ']'
  if item is '[' then makelist
  set head of cell as ptr to item
  set tail of cell as ptr to new free cell
 endwhile
 
