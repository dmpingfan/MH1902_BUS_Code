;/**************************************************************************//**
; * @file     startup_<Device>.s
; * @brief    CMSIS Cortex-M# Core Device Startup File for
; *           Device <Device>
; * @version  V3.10
; * @date     23. November 2012
; *
; * @note
; *
; ******************************************************************************/
;/* Copyright (c) 2012 ARM LIMITED
;
;   All rights reserved.
;   Redistribution and use in source and binary forms, with or without
;   modification, are permitted provided that the following conditions are met:
;   - Redistributions of source code must retain the above copyright
;     notice, this list of conditions and the following disclaimer.
;   - Redistributions in binary form must reproduce the above copyright
;     notice, this list of conditions and the following disclaimer in the
;     documentation and/or other materials provided with the distribution.
;   - Neither the name of ARM nor the names of its contributors may be used
;     to endorse or promote products derived from this software without
;     specific prior written permission.
;   *
;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;   ARE DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS AND CONTRIBUTORS BE
;   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;   POSSIBILITY OF SUCH DAMAGE.
;   ---------------------------------------------------------------------------*/
;/*
;//-------- <<< Use Configuration Wizard in Context Menu >>> ------------------
;*/


; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Stack_Size      EQU     0x00002000

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


; <h> Heap Configuration
;   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Heap_Size       EQU     0x00004000

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors
                EXPORT  __Vectors_End
                EXPORT  __Vectors_Size

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                DCD     NMI_Handler               ; NMI Handler
                DCD     HardFault_Handler         ; Hard Fault Handler
                DCD     MemManage_Handler         ; MPU Fault Handler
                DCD     BusFault_Handler          ; Bus Fault Handler
                DCD     UsageFault_Handler        ; Usage Fault Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     SVC_Handler               ; SVCall Handler
                DCD     DebugMon_Handler          ; Debug Monitor Handler
                DCD     0                         ; Reserved
                DCD     PendSV_Handler            ; PendSV Handler
                DCD     SysTick_Handler           ; SysTick Handler

                ; External Interrupts
                DCD     DMA0_IRQHandler
				DCD     USB_IRQHandler
                DCD     USBDMA_IRQHandler
                DCD     LCD_IRQHandler
                DCD     SCI0_IRQHandler
                DCD     UART0_IRQHandler
                DCD     UART1_IRQHandler
                DCD 	SPI0_IRQHandler
                DCD		CRYPT0_IRQHandler
                DCD		TIM0_0_IRQHandler
                DCD		TIM0_1_IRQHandler
                DCD		TIM0_2_IRQHandler
                DCD		TIM0_3_IRQHandler
                DCD		EXTI0_IRQHandler
                DCD		EXTI1_IRQHandler
                DCD		EXTI2_IRQHandler
                DCD		RTC_IRQHandler
                DCD		SENSOR_IRQHandler
                DCD		TRNG_IRQHandler
                DCD		ADC0_IRQHandler
				DCD		SSC_IRQHandler
				DCD		TIM0_4_IRQHandler
				DCD		TIM0_5_IRQHandler
				DCD		DCMI_IRQHandler
				DCD		MSR_IRQHandler
				DCD		EXTI3_IRQHandler
				DCD		SPI1_IRQHandler
				DCD		SPI2_IRQHandler
				DCD     IMG_COP_IRQHandler
__Vectors_End

__Vectors_Size  EQU     __Vectors_End - __Vectors

                AREA    |.text|, CODE, READONLY


; Reset Handler

Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]
                IMPORT  SystemInit
                IMPORT  __main
					
                LDR     R0, =__Vectors
                LDR     R1, =0xE000ED08
                STR     R0, [R1]
                LDR     R0, [R0]
                MOV     SP, R0
				
				
                LDR     R0, =SystemInit
                BLX     R0
                LDR     R0, =__main
                BX      R0
                ENDP

       
WAKEUP_PARAM_START	EQU 	0x574B5053	;"WKPS"
WAKEUP_PARAM_END	EQU		0x574B5045	;"WKPE"
				EXPORT  pm2_sleep
;pm2_sleep
pm2_sleep PROC
				push	{LR}
				push	{R0-R12}
				mrs		R0, PSR
				push	{R0}
				ldr 	R1, =0xE000ED08
				ldr		R0, [R1]
				push 	{R0}
				mrs		R0, MSP
				push 	{R0}
				
				;保存当前内存扰码值到retention寄存器
				LDR		R1, =0x4001F044	;内存扰码retention寄存器
				LDR 	R2, =0x40000184	;读取内存扰码
				ldr 	R2, [R2]
				str		R2, [R1]
				
;typedef struct wakeup_param_s
;{
;	uint32_t start_flag;0x574B5053
;	uint32_t FSCR;	//Flash scramble
;	uint32_t PC;	//R15
;	uint32_t end_flag;0x574B5045
;	uint32_t MSP;	//R13
;}wakeup_param;				
				;Save param end flag
				LDR 	R1, =WAKEUP_PARAM_END
				push	{R1}
				;Save PC
				mov		R1, PC
				add 	R2, R1, #20 * 2
                orr     R2, #1 
				push 	{R2}
				
				;Save Flash Scramble
				LDR 	R1, =0x40001438;Flash scramble
				ldr		R1, [R1]
				push 	{R1}
				
				LDR		R1, =WAKEUP_PARAM_START
				push	{R1}
				
				;保存当前栈指针地址,到retention寄存器
				mrs		R0, MSP
				;add		R0, #4	;处理满栈
				LDR 	R1, =0x4001F040
				str		R0, [R1]
				WFI
				; ldr 	R0, =0x4001F014;LOCK
				; mov 	R1, #0
				; str 	R1, [R0]
				; ldr 	R0, =0x4001F010	;Reset register
				; ldr 	R1, =0x40000000	;reset m3
				; str 	R1, [R0]
				
				;b		.		;FPGA测试时没有时钟门控, 因此需要在这里死循环
				
				;前面的add 	R2, R1, #16 * 2偏移后的PC地址必须落在某一个nop上, 否则会错
				nop		
				nop
				nop
				nop
				nop
				nop
				nop
				nop
				nop
				nop		
				nop
				nop
				nop
				nop
				nop
				nop
				nop
				nop
				
				
				pop		{R0}
				ldr 	R1, =0xE000ED08
				str		R0, [R1]
				pop 	{R0}
				msr		PSR, R0
				pop		{R0-R12}
				pop		{PC}
				ENDP

				ALIGN
				
; Dummy Exception Handlers (infinite loops which can be modified)

NMI_Handler     PROC
                EXPORT  NMI_Handler               [WEAK]
                B       .
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler         [WEAK]
                B       .
                ENDP
MemManage_Handler\
                PROC
                EXPORT  MemManage_Handler         [WEAK]
                B       .
                ENDP
BusFault_Handler\
                PROC
                EXPORT  BusFault_Handler          [WEAK]
                B       .
                ENDP
UsageFault_Handler\
                PROC
                EXPORT  UsageFault_Handler        [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler               [WEAK]
                B       .
                ENDP
DebugMon_Handler\
                PROC
                EXPORT  DebugMon_Handler          [WEAK]
                B       .
                ENDP
PendSV_Handler\
                PROC
                EXPORT  PendSV_Handler            [WEAK]
                B       .
                ENDP
SysTick_Handler\
                PROC
                EXPORT  SysTick_Handler           [WEAK]
                B       .
                ENDP

Default_Handler PROC
; ToDo:  Add here the export definition for the device specific external interrupts handler
                EXPORT		DMA0_IRQHandler			[WEAK]
				EXPORT		USB_IRQHandler			[WEAK]
				EXPORT		USBDMA_IRQHandler		[WEAK]
				EXPORT		LCD_IRQHandler			[WEAK]
				EXPORT		SCI0_IRQHandler			[WEAK]
				EXPORT		UART0_IRQHandler		[WEAK]
				EXPORT		UART1_IRQHandler		[WEAK]
				EXPORT 		SPI0_IRQHandler			[WEAK]
				
				EXPORT		CRYPT0_IRQHandler		[WEAK]
				EXPORT		TIM0_0_IRQHandler		[WEAK]
				EXPORT		TIM0_1_IRQHandler		[WEAK]
				EXPORT		TIM0_2_IRQHandler		[WEAK]
				EXPORT		TIM0_3_IRQHandler		[WEAK]
				EXPORT		EXTI0_IRQHandler		[WEAK]
				EXPORT		EXTI1_IRQHandler		[WEAK]
				EXPORT		EXTI2_IRQHandler		[WEAK]
				EXPORT		RTC_IRQHandler			[WEAK]
				EXPORT		SENSOR_IRQHandler		[WEAK]
				EXPORT		TRNG_IRQHandler			[WEAK]
				EXPORT		ADC0_IRQHandler			[WEAK]
				EXPORT		SSC_IRQHandler			[WEAK]
				EXPORT		TIM0_4_IRQHandler		[WEAK]
				EXPORT		TIM0_5_IRQHandler		[WEAK]	
				EXPORT		DCMI_IRQHandler			[WEAK]	
				EXPORT		MSR_IRQHandler			[WEAK]	
				EXPORT		EXTI3_IRQHandler		[WEAK]	
				EXPORT 		SPI1_IRQHandler			[WEAK]
				EXPORT 		SPI2_IRQHandler			[WEAK]
				EXPORT 		IMG_COP_IRQHandler		[WEAK]
; ToDo:  Add here the names for the device specific external interrupts handler
DMA0_IRQHandler
USB_IRQHandler
USBDMA_IRQHandler
LCD_IRQHandler
SCI0_IRQHandler
UART0_IRQHandler
UART1_IRQHandler
SPI0_IRQHandler
CRYPT0_IRQHandler
TIM0_0_IRQHandler
TIM0_1_IRQHandler
TIM0_2_IRQHandler
TIM0_3_IRQHandler
EXTI0_IRQHandler
EXTI1_IRQHandler
EXTI2_IRQHandler
RTC_IRQHandler
SENSOR_IRQHandler
TRNG_IRQHandler
ADC0_IRQHandler
SSC_IRQHandler
TIM0_4_IRQHandler
TIM0_5_IRQHandler
DCMI_IRQHandler
MSR_IRQHandler
EXTI3_IRQHandler
SPI1_IRQHandler
SPI2_IRQHandler
IMG_COP_IRQHandler
                B       .
                ENDP


                ALIGN


; User Initial Stack & Heap

                IF      :DEF:__MICROLIB

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit

                ELSE

                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap

__user_initial_stackheap PROC
                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + Stack_Size)
                LDR     R2, = (Heap_Mem +  Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR
                ENDP

                ALIGN

                ENDIF


                END

