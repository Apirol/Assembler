.386 ; директива, предписывающая Ассемблеру использовать
; набор операций для процессора 80386.
.MODEL FLAT, STDCALL ; плоская модель, вызов процедур по соглашению
; в Windows x32, далее - процедуры:
EXTRN  GetStdHandle@4:PROC ; стандартный дескриптор ввода-вывода
EXTRN  WriteConsoleA@20:PROC ; вывод текста
EXTRN  CharToOemA@8:PROC ; перекодировка
EXTRN  ReadConsoleA@20:PROC ; ввод
EXTRN  ExitProcess@4:PROC ; выход
EXTRN  lstrlenA@4:PROC ; определение длинны строки

.DATA ; сегмент данных
DOUT DD ? ; дескриптор вывода
DIN DD ? ; дескриптор ввода
STRN1 DB "Введите первое число: ",13,10,0 ; выводимая строка
STRN2 DB "Введите второе число: ",13,10,0 
BUF  DB 35 dup (?); достаточный буфер для вводимых/выводимых строк
LENS DD ? ; количество выведенных символов
;два вводимых числа
NUMEROS_A DD ? ; первое
NUMEROS_B DD ? ; второе

SIXT DD ? ; шестнадцатеричная 
TEN DD ? ; десятеричная

flagA DD ?
flagB DD ?
flagNegSum DD ?

.CODE ; сегмент кода
START: ; метка точки входа

PUSH OFFSET STRN1 ; параметры функции помещаются в стек командой
PUSH OFFSET STRN1
CALL CharToOemA@8 ; вызов функции

PUSH OFFSET STRN2 ; параметры функции помещаются в стек командой
PUSH OFFSET STRN2
CALL CharToOemA@8 ; вызов функции


PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX 	; переместить результат из регистра EAX 
; в ячейку памяти с именем DIN


PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX 

INPUT:
PUSH OFFSET STRN1 ; в стек помещается указатель на строку
CALL lstrlenA@4 ; длина в EAX

PUSH 0 ; в стек помещается 5-й параметр
PUSH OFFSET LENS ; 4-й параметр
PUSH EAX ; 3-й параметр
PUSH OFFSET STRN1 ; 2-й параметр
PUSH DOUT ; 1-й параметр
CALL WriteConsoleA@20

; ввод строки
PUSH 0 ; в стек помещается 5-й параметр
PUSH OFFSET LENS ; 4-й параметр
PUSH 35 ; 3-й параметр
PUSH OFFSET BUF ; 2-й параметр
PUSH DIN ; 1-й параметр
CALL ReadConsoleA@20 


CMP LENS, 5; Проверка на количество символов
JL INPUT


MOV SIXT, 16 ; присвоение основание системы счисления
SUB LENS, 2 ; вычитаем символы LF и CR (10 и 13)
MOV ECX, LENS ; счетчик цикла - количество необработанных символов
MOV ESI, OFFSET BUF ; начало строки хранится в переменной BUF
XOR BX, BX ; обнулить регистр BX командой XOR, 
XOR AX, AX; обнулить регистр AX

MOV BL, [ESI]
CMP BL, '-'
JNE CONVERT_1
MOV flagA, 1
INC ESI
DEC ECX


CONVERT_1: 	; метка начала тела цикла
	MOV BL, [ESI] ; поместить символ из введенной строки в регистр 
	.if (BL > '9')
		sub BL, 37h
	.else
		sub BL, '0'
	.endif
	; проверка
	CMP BL, 'F'; если символ больше 7 (у нас восьмиричная СС)
	JG INPUT; вернуться к вводу числа

	MUL SIXT ; умножить значение AX на 16, результат – в AX
	ADD AX, BX ; добавить к полученному в AX числу новую цифру	
	INC ESI ; перейти на следующий символ строки
LOOP CONVERT_1 ; перейти на следующую итерацию цикла

; проверка на отрицательное
CMP flagA, 0
JE notNegativeA
neg EAX

notNegativeA:
MOV NUMEROS_A, EAX ; отправим полученное число в память


;вывод строки
PUSH OFFSET STRN2 ; в стек помещается указатель на строку
CALL lstrlenA@4
PUSH 0 ; в стек помещается 5-й параметр
PUSH OFFSET LENS ; 4-й параметр
PUSH EAX ; 3-й параметр
PUSH OFFSET STRN2 ; 2-й параметр
PUSH DOUT ; 1-й параметр
CALL WriteConsoleA@20

; ввод строки
PUSH 0 ; в стек помещается 5-й параметр
PUSH OFFSET LENS ; 4-й параметр
PUSH 35 ; 3-й параметр
PUSH OFFSET BUF ; 2-й параметр
PUSH DIN ; 1-й параметр
CALL ReadConsoleA@20 

CMP LENS, 5;ПРОВЕРКА НА КОЛ-ВО СИМВОЛОВ
JL INPUT

;обработка 2 строки 
SUB LENS, 2 ; вычитание символов
MOV ECX, LENS ; счетчик цикла
MOV ESI, OFFSET BUF ; начало строки хранится в переменной BUF
XOR BX, BX ; обнулить регистр BX командой XOR, 
; выполняющей побитно операцию «исключающее или»
XOR AX, AX ; обнулить регистр AX

MOV BL, [ESI]
CMP BL, '-'
JNE CONVERT_2
MOV flagB, 1
INC ESI
DEC ECX


CONVERT_2: 	; метка начала тела цикла
	MOV BL, [ESI]; поместить символ из введенной строки в регистр 
	; BL, используя косвенную адресацию
	.if (BL > '9')
		sub BL, 37h
	.else
		sub BL, '0'
	.endif
	; проверка
	
	CMP BL, 'F'; если символ больше 7 (у нас восьмиричная СС)
	JG INPUT; вернуться к вводу числа

	MUL SIXT ; умножить значение AX на 16, результат – в AX
	ADD AX, BX ; добавить к полученному в AX числу новую цифру	
	INC ESI ; перейти на следующий символ строки
LOOP CONVERT_2 ; перейти на следующую итерацию цикла

; проверка на отрицательное
CMP flagB, 0
JE notNegativeB
neg EAX

notNegativeB:
MOV NUMEROS_B, EAX ; отправим полученное число в память

MOV EAX, NUMEROS_A ; отправим первое число в регистр
MOV EBX, NUMEROS_B ; отправим второе число в регистр


; сложение чисел
ADD EAX, EBX	   ; сложим, результат в EAX


JNS TRANSFORM

MOV flagNegSum, 1
neg EAX

TRANSFORM:
CDQ ; приведём тип к 64-х битному (EAX распространяется на EDX)
XOR EDI, EDI ; обнуление
MOV TEN, 10 ; загрузка константы
MOV ESI,OFFSET BUF ; начало строки хранится в переменной BUF

;преобразование в десятичную систему
.WHILE EAX>=TEN ; пока число > 10
		IDIV TEN ; результат в EAX, остаток в EDX
		;поместить в строку
		ADD EDX, '0' ; добавить код нуля
		PUSH EDX; складываем перекодированный остаток в стек
		ADD EDI, 1 ; прибавим единицу
		XOR EDX, EDX ; обнуление
.ENDW ; конец цикла
ADD EAX, '0' ; прибавление кода нуля
PUSH EAX ; в стек
ADD EDI, 1 ; прибавить единицу

MOV ECX, EDI ; число повторений
CMP flagNegSum, 1
JNE PRINT	
MOV EBX, '-'
PUSH EBX
INC ECX

PRINT:
CONVERT_3: ; начало цикла
	POP [ESI] ; из стека
	INC ESI ; уменьшить ESI на 1
LOOP CONVERT_3 ; конец цикла

PUSH OFFSET BUF ; в стек помещается указатель на строку
CALL lstrlenA@4
PUSH 0 ; в стек помещается 5-й параметр
PUSH OFFSET LENS ; 4-й параметр
PUSH EAX ; 3-й параметр
PUSH OFFSET BUF ; 2-й параметр
PUSH DOUT ; 1-й параметр
CALL WriteConsoleA@20

; выход из программы 
PUSH 0 ; параметр: код выхода
CALL ExitProcess@4
END START