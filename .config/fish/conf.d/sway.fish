if ! test -d "$XDG_RUNTIME_DIR"                                            
	mkdir $XDG_RUNTIME_DIR                                                  
	chmod 0700 $XDG_RUNTIME_DIR                                             
end 
set TTY1 (tty)
[ "$TTY1" = "/dev/tty1" ] && dbus-launch --exit-with-session sway
