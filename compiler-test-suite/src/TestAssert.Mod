MODULE TestAssert;
  IMPORT Out;
  VAR x : INTEGER;
   
BEGIN
  x := 2;
  ASSERT(TRUE);
  ASSERT(x > 0);
  ASSERT((x > 0) & (x > 5) OR (x < 8) & (x # 3));
  Out.Int(1, 10)
END TestAssert.