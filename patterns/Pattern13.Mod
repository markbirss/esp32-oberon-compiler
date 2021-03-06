MODULE Pattern13;
TYPE
  P0 = POINTER TO R0;
  P1 = POINTER TO R1;
  P2 = POINTER TO R2;
  
  R0 = RECORD
        x: INTEGER
      END ;
  R1 = RECORD (R0)
        y: INTEGER
      END ;
  R2 = RECORD (R1)
        z: INTEGER
      END ;
      
VAR
  p0: P0;
  p1: P1;
  p2: P2;

BEGIN 
  p0.x := 0;
  p1.y := 1;
  p0(P1).y := 3;
  p0(P2).z := 5;
  IF p1 IS P2 THEN
    p0 := p2
  END
END Pattern13.

(* 
    .title "Module Pattern13, Key A5E3D3E8"
    .sbttl "Oberon ESP32 Compiler Version 0.1.0"

    .align 4
    .section .data_types_Pattern13_A5E3D3E8
    .global _Pattern13_A5E3D3E8_s_data_types
_Pattern13_A5E3D3E8_s_data_types:
_Pattern13_s_types:
    .int 32,-1,-1,-1,-1,32,81926,-1
    .int -1,-1,32,81925,163841,-1,-1

    .align 4
    .section .bss_Pattern13_A5E3D3E8
    .global _Pattern13_A5E3D3E8_s_bss
_Pattern13_A5E3D3E8_s_bss:
_Pattern13_s_bss:
    .space 12



    .align 4
    .section .init_Pattern13_A5E3D3E8

_Pattern13_init:
    entry a1, 16
    movi a2, _Pattern13_s_bss
    l32i a3, a2, 0
    movi a4, 0
    s32i a4, a3, 0
    l32i a3, a2, 4
    movi a4, 1
    s32i a4, a3, 4
    l32i a3, a2, 0
    movi a4, 0
    mov a5, 4
    beqz a3, L1
    addi a4, a3, -8
    l32i a4, a4, 0
    l32i a4, a4, 4
    movi a5, _Pattern13_s_types
    addi a5, a5, 20
L1:
    movi a4, 3
    s32i a4, a3, 4
    l32i a3, a2, 0
    movi a4, 0
    mov a5, 4
    beqz a3, L2
    addi a4, a3, -8
    l32i a4, a4, 0
    l32i a4, a4, 8
    movi a5, _Pattern13_s_types
    addi a5, a5, 40
L2:
    movi a4, 5
    s32i a4, a3, 8
    
    l32i a3, a2, 4
    movi a4, 0
    mov a5, 4
    beqz a3, L3
    addi a4, a3, -8
    l32i a4, a4, 0
    l32i a4, a4, 8
    movi a5, _Pattern13_s_types
    addi a5, a5, 40
L3:
    bne a3, a4, L4
    l32i a3, a2, 8
    s32i a3, a2, 0
L4:
    retw
    .size _Pattern13_init, .-_Pattern13_init


    .align 4
    .section .init_table_Pattern13_A5E3D3E8
    .int _Pattern13_init

*)
