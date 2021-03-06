MODULE Pattern1;
VAR
  ch: CHAR;
  k:  INTEGER;
  x:  REAL;
  s:  SET;
BEGIN 
  ch := "0";
  k  :=  10;
  x  := 1.0;
  s  := {0, 4, 8}
END Pattern1.

(* 
    .title "Module Pattern1, Key A5E2D4B5"
    .sbttl "Oberon ESP32 Compiler Version 0.1.0"

    .align 4
    .section .bss_Pattern1_A5E2D4B5
    .global _Pattern1_A5E2D4B5_s_bss
_Pattern1_A5E2D4B5_s_bss:
_Pattern1_s_bss:
    .space 16


    .align 4
    .section .init_Pattern1_A5E2D4B5

_Pattern1_init:
    entry a1, 16
    movi a2, _Pattern1_s_bss
    movi a3, 48          # a3 := "0"
    s8i a3, a2, 0        # ch := "0"
    movi a3, 10          # a3 := 10
    s32i a3, a2, 4       # k := 10
    movi a3, 1065353216  # a3 := 1.0
    s32i a3, a2, 8       # x := 1.0
    movi a3, 273         # a3 := {0, 4, 8}
    s32i a3, a2, 12      # s := {0, 4, 8}
    retw
    .size _Pattern1_init, .-_Pattern1_init

    .align 4
    .section .init_table_Pattern1_A5E2D4B5
    .int _Pattern1_init
*)