MODULE TestCyclicImport01;
   IMPORT Out, TestCyclicImport00;

  TYPE R1* = RECORD x*: INTEGER END;
  VAR
     r0: TestCyclicImport00.R0;
BEGIN
  r0.k := 2
END TestCyclicImport01.
