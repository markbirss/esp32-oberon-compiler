MODULE Pattern1;
  IMPORT Out, SYSTEM;
  VAR ch: CHAR;
      k,j: INTEGER;
      x: REAL;
      s: SET;
BEGIN
  ch := "0";
  Out.Int(ORD(ch), 10);
  k := 10;
  Out.Int(k, 10);
  k := -65536;
  Out.Int(k, 10);
  k := -65537;
  Out.Int(k, 10);
  k := 65535;
  Out.Int(k, 10);
  k := 65536;
  Out.Int(k, 10);
  k := 65537;
  Out.Int(k, 10);
  x := 1.0;
  Out.Real(x, 10);
  s := {0, 4, 8};
  Out.Int(SYSTEM.VAL(INTEGER, s), 10);
  s := {3..5};
  Out.Int(SYSTEM.VAL(INTEGER, s), 10);
  k := 5;
  s := {3..k};
  Out.Int(SYSTEM.VAL(INTEGER, s), 10);
  k := 18;
  s := {16..k};
  Out.Int(SYSTEM.VAL(INTEGER, s), 10);
  k := 3;
  s := {k..5};
  Out.Int(SYSTEM.VAL(INTEGER, s), 10);
  k := 3;
  s := {k..15};
  Out.Int(SYSTEM.VAL(INTEGER, s), 10);
  j := 5;
  s := {k..j};
  Out.Int(SYSTEM.VAL(INTEGER, s), 10);
END Pattern1.