MODULE TestFor;
  IMPORT Out;
  CONST minus1 = -1;
  TYPE R0 = RECORD x, y : INTEGER END;
       ARR = ARRAY 5 OF INTEGER;
  VAR  i, x: INTEGER;
       r0 : R0;
       v : ARR;
  
  PROCEDURE P3(VAR v3 : ARR);
  BEGIN
    v3[0] := 1; 
    r0.x := 4;
    FOR i := r0.x + 3 TO r0.x + 3 + v3[0] + v3[0] DO
      Out.Int(i, 10) 
    END;
  END P3;
  
  PROCEDURE P2(VAR k : INTEGER);
  BEGIN
    v[0] := 1; 
    r0.x := 4;
    FOR k := r0.x + 3 TO r0.x + 3 + v[0] + v[0] DO
      Out.Int(k, 10) 
    END;
  END P2;
  
  PROCEDURE P1(j : INTEGER);
  VAR  i1: INTEGER;
       r1 : R0;
       v1 : ARRAY 5 OF INTEGER;
  BEGIN
   FOR i1 := 0 TO 2 BY 1 DO
      Out.Int(i1, 10) 
    END;
    x := 3;
    FOR i1 := x TO 5 DO
      Out.Int(i1, 10)
    END;
    j := 8;
    FOR i1 := 6 TO j DO
      Out.Int(i1, 10)
    END;
    FOR i1 := j TO 0 BY minus1 DO
      Out.Int(i1, 10)
    END;
    Out.Ln;
    r1.x := 0;
    FOR i1 := r1.x TO 2 DO
      Out.Int(i1, 10) 
    END;
    r1.x := 2;
    FOR i1 := 3 TO r1.x + 3 DO
      Out.Int(i1, 10) 
    END;
    Out.Ln;
    v1[0] := 1; 
    r1.x := 4;
    FOR i1 := r1.x + 3 TO r1.x + 3 + v1[0] + v1[0] DO
      Out.Int(i1, 10) 
    END;
  END P1;
BEGIN
  FOR i := 0 TO 2 BY 1 DO
    Out.Int(i, 10) 
  END;
  x := 3;
  FOR i := x TO 5 DO
    Out.Int(i, 10)
  END;
  x := 8;
  FOR i := 6 TO x DO
    Out.Int(i, 10)
  END;
  FOR i := x TO 0 BY minus1 DO
    Out.Int(i, 10)
  END;
  Out.Ln;
  r0.x := 0;
  FOR i := r0.x TO 2 DO
    Out.Int(i, 10) 
  END;
  r0.x := 2;
  FOR i := 3 TO r0.x + 3 DO
    Out.Int(i, 10) 
  END;
  Out.Ln;
  v[0] := 1; 
  r0.x := 4;
  FOR i := r0.x + 3 TO r0.x + 3 + v[0] + v[0] DO
    Out.Int(i, 10) 
  END;
  Out.Ln;
  P1(0);
  i := 0;
  Out.Ln;
  P2(i);
  Out.Ln;
  P3(v);
  Out.Ln;
END TestFor.