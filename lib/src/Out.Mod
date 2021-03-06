(* ESP32 UART0 Output Module *)

MODULE Out;
  IMPORT SYSTEM;

  CONST
    (* UART0 Registers *)
    UART_FIFO      = 3FF40000H; (* UART0 fifo address *)
    UART_CLKDIV    = 3FF40014H; (* UART0 clock divisor *)
    UART_STATUS    = 3FF4001CH; (* UART0 status register *)
    UART_MEM_CNT   = 3FF40064H; (* UART0 mem count register *)

    Baud115K*  = 80000000 DIV 115200;
    Baud76800* = 80000000 DIV 76800;
    Baud38400* = 80000000 DIV 38400;
    Baud19200* = 80000000 DIV 19200;
    Baud9600*  = 80000000 DIV 9600;
    
    CR         = 0DX;
    LF         = 0AX;

  VAR
    Opened: BOOLEAN;

  PROCEDURE FifoCount(): INTEGER;
  VAR 
    c, r1, r2 : INTEGER;
  BEGIN
    SYSTEM.GET(UART_STATUS, r1);
    SYSTEM.GET(UART_MEM_CNT, r2);
    c := AND(ASR(r1, 16), 0FFH) + LSL(AND(ASR(r2, 3), 07H), 8);
    RETURN c
  END FifoCount;

  PROCEDURE Flush*;
  BEGIN
    WHILE FifoCount() > 0 DO END
  END Flush;

  PROCEDURE Char*(ch: CHAR);
  BEGIN
    WHILE FifoCount() > 120 DO END ; (* Wait for some space in UART xmit FIFO *)
    SYSTEM.PUT(UART_FIFO, ORD(ch))
  END Char;

  PROCEDURE String*(s: ARRAY OF CHAR);
  VAR
    i: INTEGER;
  BEGIN
    i := 0;  
    WHILE  (i < LEN(s)) & (s[i] # 0X) DO
      Char(s[i]);
      INC(i)
    END
  END String;

  PROCEDURE Int*(x, n: INTEGER);
  VAR
    i, x0: INTEGER;
    a: ARRAY 10 OF CHAR;
  BEGIN
    i := 0;
    IF x < 0 THEN
      x0 := -x; DEC(n) 
    ELSE
      x0 := x 
    END ;
    REPEAT
      a[i] := CHR(x0 MOD 10 + 30H); 
      x0 := x0 DIV 10; 
      INC(i)
    UNTIL x0 = 0;
    WHILE n > i DO
      Char(" "); DEC(n) 
    END ;
    IF x < 0 THEN 
      Char("-") 
    END ;
    REPEAT DEC(i); Char(a[i]) UNTIL i = 0
  END Int;

  PROCEDURE Hex*(x, n: INTEGER);
  VAR 
    i, y: INTEGER;
    a: ARRAY 10 OF CHAR;
  BEGIN
    i := 0; 
    REPEAT 
      y := x MOD 10H;
      IF y < 10 THEN 
        a[i] := CHR(y + 30H) 
      ELSE 
        a[i] := CHR(y + 37H) 
      END ;
      x := x DIV 10H;
      INC(i)
    UNTIL (i = 8);
    WHILE n > 8 DO
      Char(" "); DEC(n) 
    END ;
    REPEAT DEC(i); Char(a[i]) UNTIL i = 0
  END Hex;

  PROCEDURE Ten(n: INTEGER): REAL;
  VAR t, p: REAL;
  BEGIN 
    t := 1.0; p := 10.0;   (* compute 10^n *)
    WHILE n > 0 DO
      IF ODD(n) THEN t := p * t END ;
      p := p * p; n := n DIV 2
    END ;
    RETURN t
  END Ten;

  PROCEDURE Real* (x: REAL; n: INTEGER);
    VAR e, i, k, m: INTEGER;
      d: ARRAY 16 OF CHAR;
  BEGIN
    e := ASR(ORD(x), 23) MOD 100H;  (* binary exponent *)
    IF e = 0 THEN
      String("  0 ");
      WHILE n >= 3 DO Char(" "); DEC(n) END
    ELSIF e = 255 THEN String(" NaN ")
    ELSE 
      Char(" ");
      WHILE n >= 15 DO DEC(n); Char(" ") END ;
      (* 2 < n < 9 digits to be written *)
      IF x < 0.0 THEN Char("-"); x := -x ELSE Char(" ") END ;
      e := (e - 127) * 77 DIV 256 - 6;  (* decimal exponent *)
      IF e >= 0 THEN x := x / Ten(e) ELSE x := Ten(-e) * x END ;
      m := FLOOR(x + 0.5);
      IF m >= 10000000 THEN INC(e); m := m DIV 10 END ;
      i := 0; k := 13-n;
      REPEAT
        IF i = k THEN INC(m, 5) END ;    (* rounding *)
        d[i] := CHR(m MOD 10 + 30H); m := m DIV 10; INC(i)
      UNTIL m = 0;
      DEC(i); Char(d[i]); Char(".");
      IF i < n-7 THEN n := 0 ELSE n := 14 - n END ;
      WHILE i > n DO DEC(i); Char(d[i]) END ;
      Char("E"); INC(e, 6);
      IF e < 0 THEN Char("-"); e := -e ELSE Char("+") END ;
      Char(CHR(e DIV 10 + 30H)); Char(CHR(e MOD 10 + 30H))
    END
  END Real;

  PROCEDURE RealFix*(x: REAL; n, k: INTEGER);
  VAR
    i, m: INTEGER; 
    neg: BOOLEAN;
    d: ARRAY 12 OF CHAR;
  BEGIN
    IF x = 0.0 THEN String("  0")
    ELSE
      IF x < 0.0 THEN 
        x := -x; 
        neg := TRUE 
      ELSE 
        neg := FALSE 
      END ;
      IF k > 7 THEN k := 7 END ;
      x := Ten(k) * x; 
      m := FLOOR(x + 0.5);
      i := 0;
      REPEAT 
        d[i] := CHR(m MOD 10 + 30H); 
        m := m DIV 10; INC(i) 
      UNTIL m = 0;
      Char(" ");
      WHILE n > i + 3 DO Char(" "); DEC(n) END ;
      IF neg THEN Char("-"); DEC(n) ELSE Char(" ") END ;
      WHILE i > k DO DEC(i); Char(d[i]) END ;
      Char(".");
      WHILE k > i DO DEC(k); Char("0") END ;
      WHILE i > 0 DO DEC(i); Char(d[i]) END
    END
  END RealFix;

  PROCEDURE Ln*;
  BEGIN 
    Char(CR); Char(LF)
  END Ln;

  PROCEDURE SetBaudRate*(baudRate: INTEGER);
  BEGIN
    SYSTEM.PUT(UART_CLKDIV, baudRate)
  END SetBaudRate;

  PROCEDURE Open*;
  BEGIN
    IF ~Opened THEN
      SetBaudRate(Baud115K);
      Opened := TRUE
    END
  END Open;

BEGIN
  Open;
END Out.
