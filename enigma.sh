#!/bin/bash

# (c) 2015 Charles Bailey

alphabet=ABCDEFGHIJKLMNOPQRSTUVWXYZ

swap_fd () {
	eval "exec {tmp}>&${!1} {$1}>&${!2}"
	eval "exec {$2}>&$tmp {tmp}>&-"
}

open_files () {
	for (( i=0; i != ${#alphabet}; i++ ))
	do
		letter=${alphabet:i:1}
		eval "exec {orig$letter}>lamp$letter"
	done
}

init_fds () {
	for (( i=0; i != ${#alphabet}; i++ ))
	do
		letter=${alphabet:i:1}
		eval "exec {fd$letter}>&\$orig$letter"
	done
}

close_fds () {
	for (( i=0; i != ${#alphabet}; i++ ))
	do
		letter=${alphabet:i:1}
		eval "exec {fd$letter}>&-"
	done
}

reflector () {
	# Umkehrwalze B: AY BR CU DH EQ FS GL IP JX KN MO TZ VW
	swap_fd fdA fdY
	swap_fd fdB fdR
	swap_fd fdC fdU
	swap_fd fdD fdH
	swap_fd fdE fdQ
	swap_fd fdF fdS
	swap_fd fdG fdL
	swap_fd fdI fdP
	swap_fd fdJ fdX
	swap_fd fdK fdN
	swap_fd fdM fdO
	swap_fd fdT fdZ
	swap_fd fdV fdW
}

move_to_tmp_fds () {
	for (( i=0; i != ${#alphabet}; i++ ))
	do
		letter=${alphabet:i:1}
		eval "exec {tmp$letter}>&\$fd$letter {fd$letter}>&-"
	done
}

rotor_fwd () {
	move_to_tmp_fds
	for (( i=0; i != ${#alphabet}; i++ ))
	do
		letter1=${alphabet:i:1}
		idx=$(expr index $alphabet ${1:(i+$2)%26:1})
		letter2=${alphabet:(idx+25-$2)%26:1}
		eval "exec {fd$letter2}>&\$tmp$letter1 {tmp$letter1}>&-"
	done
}

rotor_rev () {
	move_to_tmp_fds
	for (( i=0; i != ${#alphabet}; i++ ))
	do
		letter1=${alphabet:i:1}
		idx=$(expr index $alphabet ${1:(i+$2)%26:1})
		letter2=${alphabet:(idx+25-$2)%26:1}
		eval "exec {fd$letter1}>&\$tmp$letter2 {tmp$letter2}>&-"
	done
}

scramble_outputs () {
	init_fds
	rotor_fwd "$1" "$4"
	rotor_fwd "$2" "$5"
	rotor_fwd "$3" "$6"
	reflector
	rotor_rev "$3" "$6"
	rotor_rev "$2" "$5"
	rotor_rev "$1" "$4"
}

rotor1=EKMFLGDQVZNTOWYHXUSPAIBRCJ
rotor2=AJDKSIRUXBLHWTMCQGZNPYFVOE
rotor3=BDFHJLCPRTXVZNYEIWGAKMUSQO
rotor4=ESOVPZJAYQUIRHXLNFTGKDCMWB
rotor5=VZBRGITYUPSDNHLXAWMJQOFECK

r1pos=0
r2pos=0
r3pos=0

next_pos () { (( r1pos=(r1pos+1)%26 )); }

next () {
	next_pos
	scramble_outputs $rotor1 $rotor2 $rotor3\
	                 $r1pos  $r2pos  $r3pos
}

encode () {
	next
	eval "printf '*' >&\$fd$1"
	close_fds
}

open_files

while read -n 1 ch
do
	expr index $alphabet "$ch" >/dev/null && encode "$ch"
done
