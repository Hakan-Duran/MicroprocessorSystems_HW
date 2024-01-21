; Hakan Duran 150200091

SysTick_CTRL        EQU    	0xE000E010    ;SYST_CSR -> SysTick Control and Status Register
SysTick_RELOAD      EQU    	0xE000E014    ;SYST_RVR -> SysTick Reload Value Register
SysTick_VAL         EQU    	0xE000E018    ;SYST_CVR -> SysTick Current Value Register
	
; CPU frequency: 128 MHz
; Timer interrupt period: 78 ms
; ( (78 * 10^(-3)) / (1 / ( 128 * 10^6 ) ) - 1 = 9983999
RELOAD				EQU		9983999
START				EQU		0x7 ; #0111
ArraySize 			EQU 	0x0190 ; 400

	AREA hw2arr, DATA, READWRITE
	ALIGN
		
y_array SPACE ArraySize
y_end

	AREA tarr, DATA, READWRITE
	ALIGN
z_array SPACE ArraySize
z_end

	AREA hw2, code, readonly
	ENTRY
	THUMB
	ALIGN
__main FUNCTION
	EXPORT __main

		LDR R3, =ArraySize ; Array's size has assigned to R3
		MOVS R0, #0 ; R0 assigned to 0
		LDR R1, =y_array ; R1 has pointer to declared block in memory 
		LDR R2, =x_array ; R2 has pointer to unsorted array
Copy	
		CMP R0, R3 ; R0 and R3 compared here
		BGE exit_store ; If equal, then exit the while condition
		LDR R5, [R2, R0] ; Contents of unsorted array has ben loaded to R5
		STR R5, [R1, R0] ; Contents of R5 writes into the memory.
		ADDS R0, R0, #4 ; R0 = R0 + 4 because one value in array is 4 byte.
		B Copy ; While condition
		
exit_store
; init_systick_timer
		LDR		R1, =SysTick_RELOAD ; SYST_RVR has been loaded to R1
		LDR		R2, =RELOAD ; Reload value has been loaded to R2.
		STR		R2, [R1]	; Reload value has been setted.
		
		LDR		R1, =SysTick_VAL ; SYST_CVR has been loaded to R1.
		MOVS 	R2, #0 ; R2 has assigned as 0.
		STR		R2, [R1] ; Current value zeroed in order to force register to start from reload value.
		
		LDR 	R0, =SysTick_CTRL ; SYST_CSR has been loaded to R0.
		LDR		R3, =START ; Value which let interrupt for SYST_CSR has been loaded to R3.
		STR		R3,	[R0]	; Control value has been setted.
		
		CPSIE    I ; Let interrupt for program. __enable_irq();
		
		MOVS R3, #2 ; R3 is value for "for loop" It will reach 100 in order to run BubbleSort for 98 times.
		
for_loop
		CMP R3, #0x64 ; Control R3 if it has reached to 100.
		BGT exit ; If reached, then go to exit.
		B time ; If not, continue.
time
		LDR R1, =SysTick_VAL ; Save_Start_Time()
		LDR R7, [R1] ; R7 is current value and it will be used in Save_Execution_Time() 

;BubbleSort
endcopy
		MOVS R0, #0 ; i=0 as index value
		MOVS R1, #4 ; R1 will be used in multiplication.
		MULS R3, R1, R3 ; R3 has multiplied by 4 to keep array size.
		SUBS R3, R3, #4 ; size = SIZE - 1
		LDR R2, =y_array ; Load start address of the allocated space for y 
L1
		CMP R0, R3 ; Check i < array_size
		BHS for_loop_enter ; If not, finish the loop.
		MOVS R1, #0 ; j=1 as second index
		MOVS R4, R3	; cond = size
		SUBS R4, R4, R0 ; cond = size - 1 
L2
		CMP R1, R4 ; Check j < cond
		BHS EndL2 ; If j >= cond, finish inner loop.
		LDR R5, [R2, R1] ; Firstval = y[j]
		ADDS R1, R1, #4 ; j = j + 4
		LDR R6, [R2, R1] ; Secondval = j[i]
		CMP R5, R6 ; Check firstval > secondval
		BLS L2 ; If firstval <= secondval then go to L2
		STR R5, [R2, R1] ; y[j] = firstval
		SUBS R1, R1, #4 ; j = j - 4
		STR R6, [R2, R1] ; y[j] = firstval
		ADDS R1, R1, #4 ; j = j + 4
		B L2 ; Go to L2
EndL2	
		ADDS R0, R0, #4 ; i = i + 4 for word. 
		B L1 ; Go to L1
		
;BubbleSort function ended
		
for_loop_enter
		; R3 was n, throughout the BubbleSort, it became 4n-4
		; R3 should be n+1 and start new BubbleSort.
		ADDS R3, #4 ; 4n-4 -> 4n
		LSRS R3, R3, #2 ; 4n -> n
		SUBS R4, R3, #2 ; R4 = n-2
		MOVS R0, #4 ; R0 will be used in multiplication
		MULS R4, R0, R4 ; R4 is used in storing operation, it is why it should be multiplied by 4.
		ADDS R3, #1 ; n -> n+1 , R3= n+1
	
		LDR R0, =z_array ; z_array has memory address of the execution times array.
		STR R7, [R0, R4] ; z_array[n-2] <= R7; R7 is current value which calculated before BubbleSort.
		B for_loop ; Start the new loop.

exit
		LDR R0, =y_array ; Memory address of sorted array
		LDR R1, =z_array ; Memory address of execution times array
finish	
		B finish

		ALIGN
		ENDFUNC


x_array DCDU 0xa603e9e1, 0xb38cf45a, 0xf5010841, 0x32477961, 0x10bc09c5, 0x5543db2b, 0xd09b0bf1, 0x2eef070e, 0xe8e0e237, 0xd6ad2467, 0xc65a478b, 0xbd7bbc07, 0xa853c4bb, 0xfe21ee08, 0xa48b2364, 0x40c09b9f, 0xa67aff4e, 0x86342d4a, 0xee64e1dc, 0x87cdcdcc, 0x2b911058, 0xb5214bbc, 0xff4ecdd7, 0x3da3f26, 0xc79b2267, 0x6a72a73a, 0xd0d8533d, 0x5a4af4a6, 0x5c661e05, 0xc80c1ae8, 0x2d7e4d5a, 0x84367925, 0x84712f8b, 0x2b823605, 0x17691e64, 0xea49cba, 0x1d4386fb, 0xb085bec8, 0x4cc0f704, 0x76a4eca9, 0x83625326, 0x95fa4598, 0xe82d995e, 0xc5fb78cb, 0xaf63720d, 0xeb827b5, 0xcc11686d, 0x18db54ac, 0x8fe9488c, 0xe35cf1, 0xd80ec07d, 0xbdfcce51, 0x9ef8ef5c, 0x3a1382b2, 0xe1480a2a, 0xfe3aae2b, 0x2ef7727c, 0xda0121e1, 0x4b610a78, 0xd30f49c5, 0x1a3c2c63, 0x984990bc, 0xdb17118a, 0x7dae238f, 0x77aa1c96, 0xb7247800, 0xb117475f, 0xe6b2e711, 0x1fffc297, 0x144b449f, 0x6f08b591, 0x4e614a80, 0x204dd082, 0x163a93e0, 0xeb8b565a, 0x5326831, 0xf0f94119, 0xeb6e5842, 0xd9c3b040, 0x9a14c068, 0x38ccce54, 0x33e24bae, 0xc424c12b, 0x5d9b21ad, 0x355fb674, 0xb224f668, 0x296b3f6b, 0x59805a5f, 0x8568723b, 0xb9f49f9d, 0xf6831262, 0x78728bab, 0x10f12673, 0x984e7bee, 0x214f59a2, 0xfb088de7, 0x8b641c20, 0x72a0a379, 0x225fe86a, 0xd98a49f3
x_end

END