MODULE TestINCLAndEXCL;
  IMPORT Out;

  CONST K = {1, 2, 3};
  VAR y : SET;
      j,f : INTEGER;
      b : ARRAY 2 OF SET;
      r: RECORD a: ARRAY 2 OF RECORD b: INTEGER END END;
   
  PROCEDURE PrintSet(x : SET);
  VAR i : INTEGER;
  BEGIN
    FOR i:= 0 TO 31 DO
      IF i IN x THEN Out.Int(i, 10) END
    END;
    Out.Ln
  END PrintSet;

  PROCEDURE P0(a0 : SET; VAR a1 : ARRAY OF SET);
    VAR i : ARRAY 2 OF SET;
        z : RECORD x : SET END;
        x : BYTE;
  BEGIN 
    x := 0;
    i[0] := K; 
    i[1] := K + {8}; 
    INCL(i[0], 8);
    PrintSet(i[0]); (* {1 2 3 8} *)
    EXCL(i[x+1], 1);
    PrintSet(i[x+1]); (* {2 3 8} *)
    
    z.x := K;
    EXCL(z.x, 2);
    PrintSet(z.x); (* {1 3} *)
        
    EXCL(a0, 2);
    PrintSet(a0); (* {1 3} *)
    
    EXCL(a1[x+1], 3);
    PrintSet(a1[x+1]); (* {1 2} *)
    
    j := 0;
    INCL(a1[j+1], 3);
    PrintSet(a1[j+1]); (* {1 2 3} *)
    INCL(a0, 8+x);
    PrintSet(a0); (* {1 3 8} *)
  END P0; 
  
  PROCEDURE Effect(VAR x : BYTE) : INTEGER;
  BEGIN 
    Out.Int(x, 10); (* 7 *)
    INC(f); 
    RETURN 0
  END Effect;
  
  PROCEDURE P1;
    VAR i : ARRAY 2 OF RECORD b : SET END;
        j : ARRAY 20 OF BYTE;
        z : ARRAY 20 OF BYTE;
        x : BYTE;
  BEGIN 
    i[0].b := K;
    x := 10;
    f := 0;
    j[x+5] := 7;
    EXCL(i[Effect(j[x+5])].b, 2);
    Out.Int(f, 10); (* 1 *)
    PrintSet(i[0].b); (* {1 3} *)
    z[x+1] := 8;
    INCL(i[Effect(j[x+5])].b, z[x+1]);
    Out.Int(f, 10); (* 2 *)
    PrintSet(i[0].b); (* {1 3 8} *)
    z[2+x] := 10;
    INCL(i[Effect(j[x+5])].b, z[x+1] + z[2+x]);
    Out.Int(f, 10); (* 3 *)
    PrintSet(i[0].b); (* {1 3 8 18} *)
  END P1; 

BEGIN
  y := K;
  EXCL(y, 2); (* {1 3} *)
  PrintSet(y);
  y := K;
  j := 1;
  r.a[-1+j].b := 2;
  EXCL(y, r.a[-1+j].b); (* {1 3} *)
  PrintSet(y);
  j := 2;
  y := K;
  EXCL(y, j);
  PrintSet(y); (* {1 3} *)
  b[j - 1] := K;
  EXCL(b[j - 1], j); (* {1 3} *)
  PrintSet(b[j - 1]);
  y := K;
  b[1] := K;
  P0(y, b);
  P1
END TestINCLAndEXCL.