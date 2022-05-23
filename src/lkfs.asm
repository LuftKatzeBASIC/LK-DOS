db 'S'
db "LKDOS",0,"              ",0	;dir sys ro hidden
db "IO.COM",0,"             ",0,0,1,1,1,0,18,4			
db "COMMAND.COM",0,"        ",0,0,1,1,1,0,13,5			; head (0), start(13), len (5)
db 28
times (0x1800-($-$$)) db 28
