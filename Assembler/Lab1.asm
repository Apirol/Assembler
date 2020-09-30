.386 ; ���������, �������������� ���������� ������������
; ����� �������� ��� ���������� 80386.
.MODEL FLAT, STDCALL ; ������� ������, ����� �������� �� ����������
; � Windows x32, ����� - ���������:
EXTRN  GetStdHandle@4:PROC ; ����������� ���������� �����-������
EXTRN  WriteConsoleA@20:PROC ; ����� ������
EXTRN  CharToOemA@8:PROC ; �������������
EXTRN  ReadConsoleA@20:PROC ; ����
EXTRN  ExitProcess@4:PROC ; �����
EXTRN  lstrlenA@4:PROC ; ����������� ������ ������

.DATA ; ������� ������
DOUT DD ? ; ���������� ������
DIN DD ? ; ���������� �����
STRN1 DB "������� ������ �����: ",13,10,0 ; ��������� ������
STRN2 DB "������� ������ �����: ",13,10,0 
BUF  DB 35 dup (?); ����������� ����� ��� ��������/��������� �����
LENS DD ? ; ���������� ���������� ��������
;��� �������� �����
NUMEROS_A DD ? ; ������
NUMEROS_B DD ? ; ������

SIXT DD ? ; ����������������� 
TEN DD ? ; ������������

flagA DD ?
flagB DD ?
flagAB DD ?

.CODE ; ������� ����
START: ; ����� ����� �����

PUSH OFFSET STRN1 ; ��������� ������� ���������� � ���� ��������
PUSH OFFSET STRN1
CALL CharToOemA@8 ; ����� �������

PUSH OFFSET STRN2 ; ��������� ������� ���������� � ���� ��������
PUSH OFFSET STRN2
CALL CharToOemA@8 ; ����� �������


PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX 	; ����������� ��������� �� �������� EAX 
; � ������ ������ � ������ DIN


PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX 

INPUT:
PUSH OFFSET STRN1 ; � ���� ���������� ��������� �� ������
CALL lstrlenA@4 ; ����� � EAX
; ����� ������� WriteConsoleA ��� ������ ������ STRN
PUSH 0 ; � ���� ���������� 5-� ��������
PUSH OFFSET LENS ; 4-� ��������
PUSH EAX ; 3-� ��������
PUSH OFFSET STRN1 ; 2-� ��������
PUSH DOUT ; 1-� ��������
CALL WriteConsoleA@20

; ���� ������
PUSH 0 ; � ���� ���������� 5-� ��������
PUSH OFFSET LENS ; 4-� ��������
PUSH 35 ; 3-� ��������
PUSH OFFSET BUF ; 2-� ��������
PUSH DIN ; 1-� ��������
CALL ReadConsoleA@20 


CMP LENS, 5; �������� �� ���-�� ��������
JL INPUT



;��������� 1-�� ����� (�� ������ ������ ����� ���� ������ � ������)
MOV SIXT, 16 ; ���������� ��������� ������� ���������
SUB LENS, 2 ; �������� ������� LF � CR (10 � 13)
MOV ECX, LENS ; ������� ����� - ���������� �������������� ��������
MOV ESI, OFFSET BUF ; ������ ������ �������� � ���������� BUF
XOR BX, BX ; �������� ������� BX �������� XOR, 
; ����������� ������� �������� ������������ ���
XOR AX, AX; �������� ������� AX

MOV BL, [ESI]
.if (BL == '-')
	MOV flagA, 1
	INC ESI
.endif

CONVERT_1: 	; ����� ������ ���� �����
	MOV BL, [ESI] ; ��������� ������ �� ��������� ������ � ������� 
	.if (BL > '9')
		sub BL, 37h
	.else
		sub BL, '0'
	.endif
	; ��������
	CMP BL, 'F'; ���� ������ ������ 7 (� ��� ������������ ��)
	JG INPUT; ��������� � ����� �����

	MUL SIXT ; �������� �������� AX �� 16, ��������� � � AX
	ADD AX, BX ; �������� � ����������� � AX ����� ����� �����	
	INC ESI ; ������� �� ��������� ������ ������
LOOP CONVERT_1 ; ������� �� ��������� �������� �����
MOV NUMEROS_A, EAX ; �������� ���������� ����� � ������

;����� ������
PUSH OFFSET STRN2 ; � ���� ���������� ��������� �� ������
CALL lstrlenA@4
PUSH 0 ; � ���� ���������� 5-� ��������
PUSH OFFSET LENS ; 4-� ��������
PUSH EAX ; 3-� ��������
PUSH OFFSET STRN2 ; 2-� ��������
PUSH DOUT ; 1-� ��������
CALL WriteConsoleA@20

; ���� ������
PUSH 0 ; � ���� ���������� 5-� ��������
PUSH OFFSET LENS ; 4-� ��������
PUSH 35 ; 3-� ��������
PUSH OFFSET BUF ; 2-� ��������
PUSH DIN ; 1-� ��������
CALL ReadConsoleA@20 

CMP LENS, 5;�������� �� ���-�� ��������
JL INPUT

;��������� 2 ������ 
SUB LENS, 2 ; ��������� ��������
MOV ECX, LENS ; ������� �����
MOV ESI, OFFSET BUF ; ������ ������ �������� � ���������� BUF
XOR BX, BX ; �������� ������� BX �������� XOR, 
; ����������� ������� �������� ������������ ���
XOR AX, AX ; �������� ������� AX

MOV BL, [ESI]
.if (BL == '-')
	MOV flagB, 1
	INC ESI
.endif


CONVERT_2: 	; ����� ������ ���� �����
	MOV BL, [ESI]; ��������� ������ �� ��������� ������ � ������� 
	; BL, ��������� ��������� ���������
	.if (BL > '9')
		sub BL, 37h
	.else
		sub BL, '0'
	.endif
	; ��������
	
	CMP BL, 'F'; ���� ������ ������ 7 (� ��� ������������ ��)
	JG INPUT; ��������� � ����� �����

	MUL SIXT ; �������� �������� AX �� 16, ��������� � � AX
	ADD AX, BX ; �������� � ����������� � AX ����� ����� �����	
	INC ESI ; ������� �� ��������� ������ ������
LOOP CONVERT_2 ; ������� �� ��������� �������� �����
MOV NUMEROS_B, EAX ; �������� ������ �����



; �������� �����
MOV EAX, NUMEROS_A ; �������� ������ ����� � �������
MOV EBX, NUMEROS_B ; �������� ������ ����� � �������
ADD EAX, EBX	   ; ������, ��������� � EAX
; ���������� ������� � ������ �� �����, ��������� � EAX �����������

; ����� ����������
CDQ ; ������� ��� � 64-� ������� (EAX ���������������� �� EDX)

XOR EDI, EDI ; ���������
MOV TEN, 10 ; �������� ���������
MOV ESI,OFFSET BUF ; ������ ������ �������� � ���������� BUF

.WHILE EAX>=TEN ; ���� ����� > 10
		IDIV TEN ; ��������� � EAX, ������� � EDX
		;��������� � ������
		ADD EDX, '0' ; �������� ��� ����
		PUSH EDX; ���������� ���������������� ������� � ����
		ADD EDI, 1 ; �������� �������
		XOR EDX, EDX ; ���������
.ENDW ; ����� �����
ADD EAX, '0' ; ����������� ���� ����
PUSH EAX ; � ����
ADD EDI, 1 ; ��������� �������

MOV ECX, EDI ; ����� ����������
CONVERT_3: ; ������ �����
	POP [ESI] ; �� �����
	INC ESI ; ��������� ESI �� 1
LOOP CONVERT_3 ; ����� �����

PUSH OFFSET BUF ; � ���� ���������� ��������� �� ������
CALL lstrlenA@4
PUSH 0 ; � ���� ���������� 5-� ��������
PUSH OFFSET LENS ; 4-� ��������
PUSH EAX ; 3-� ��������
PUSH OFFSET BUF ; 2-� ��������
PUSH DOUT ; 1-� ��������
CALL WriteConsoleA@20

; ����� �� ��������� 
PUSH 0 ; ��������: ��� ������
CALL ExitProcess@4
END START
