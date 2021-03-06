MODULE ORB;   (*NW 25.6.2014  / 1.3.2019  in Oberon-07*)
  IMPORT Files, Out, ORS, Config;
  (*Definition of data types Object and Type, which together form the data structure
    called "symbol table". Contains procedures for creation of Objects, and for search:
    NewObj, this, thisimport, thisfield (and OpenScope, CloseScope).
    Handling of import and export, i.e. reading and writing of "symbol files" is done by procedures
    Import and Export. This module contains the list of standard identifiers, with which
    the symbol table (universe), and that of the pseudo-module SYSTEM are initialized. *)

  CONST 
      maxTypTab = 64;
    (* class values *) 
      Head*  = 0;
      Const* = 1; Var*   = 2; Par*   = 3; 
      Fld*   = 4; Typ*   = 5; SProc* = 6; 
      SFunc* = 7; Mod*   = 8;

    (* form values *)
      Byte*     =  1; Bool*     =  2; Char*     =  3; 
      ShortInt* =  4; Int*      =  5; LongInt*  =  6;
      Real*     =  7; Set*      =  8; Pointer*  =  9;
      CPointer* = 10; NilTyp*   = 11; NoTyp*    = 12; 
      Proc*     = 13; String*   = 14; CProc*    = 15; 
      Array*    = 16; CArray*   = 17; Record*   = 18; 
      CRecord*  = 19;
      
  TYPE 
    Object* = POINTER TO ObjDesc;
    Module* = POINTER TO ModDesc;
    Type*   = POINTER TO TypeDesc;

    ObjDesc* = RECORD
      class*, 
      exno*:  BYTE;
      expo*,             (* exported *)
      rdo*:   BOOLEAN;   (* read-only *)
      lev*:   INTEGER;
      next*, 
      dsc*:   Object;
      type*:  Type;
      name*:  ORS.Ident;
      val*, val1*: INTEGER (* for LONGINT, val1 is the highest 32 bits *)
    END ;

    ModDesc* = RECORD (ObjDesc) orgname*: ORS.Ident; cdecl: BOOLEAN END ;

    TypeDesc* = RECORD
      form*, 
      ref*,              (*ref is only used for import/export*)
      mno*:    INTEGER;  
      nofpar*: INTEGER;  (*for procedures, extension level for records*)
      len*:    INTEGER;  (*for arrays, len < 0 => open array; for records: adr of descriptor*)
      dsc*, 
      typobj*: Object;
      base*:   Type;     (*for arrays, records, pointers*)
      size*:   INTEGER   (*in bytes; always multiple of 4, except for Byte, Bool and Char*)
    END ;

  (* Object classes and the meaning of "val":
    class    val
    --------------------------------------
    Var      address
    Par      address
    Const    value
    Fld      offset
    Typ      type descriptor (TD) address
    SProc    inline code number
    SFunc    inline code number
    Mod      key

  Type forms and the meaning of "dsc" and "base":
    form               dsc      base
    -----------------------------------------------------
    Pointer, CPointer   -       type of dereferenced object
    Proc, CProc        params   result type
    Array               -       type of elements
    Record, CRecord    fields   extension *)

  VAR 
    topScope*, 
    universe, 
    system*: Object;
    byteType*, 
    boolType*, 
    charType*,
    shortType*,
    intType*, 
    longType*, 
    realType*, 
    setType*, 
    nilType*, 
    noType*, 
    strType*: Type;
    nofmod, 
    Ref: INTEGER;
    typtab: ARRAY maxTypTab OF Type;
    importPaths: ARRAY 20, 256 OF CHAR;

  PROCEDURE DecodePath(impPath: ARRAY OF CHAR);
    VAR i, j, k: INTEGER;
  BEGIN
    importPaths[0] := ".";
    i := 1; j := 0; k := 0;
    WHILE (i < LEN(importPaths)) & (j < LEN(impPath)) & (impPath[j] # 0X) DO
      IF impPath[j] = ":" THEN
        importPaths[i][k] := 0X; k := 0; INC(i)
      ELSE
        importPaths[i][k] := impPath[j]; INC(k)
      END ;
      INC(j)
    END ;
    IF i < LEN(importPaths) THEN
      importPaths[i][k] := 0X; INC(i);
      WHILE i < 10 DO importPaths[i][0] := 0X; INC(i) END
    END
  END DecodePath;

  PROCEDURE NewObj*(VAR obj: Object; id: ORS.Ident; class: INTEGER);  (*insert new Object with name id*)
    VAR new, x: Object;
  BEGIN x := topScope;
    WHILE (x.next # NIL) & (x.next.name # id) DO x := x.next END ;
    IF x.next = NIL THEN
      NEW(new); new.name := id; new.class := class; new.next := NIL; new.rdo := FALSE; new.dsc := NIL;
      x.next := new; obj := new
    ELSE obj := x.next; ORS.Mark("mult def")
    END 
  END NewObj;

  PROCEDURE thisObj*(): Object;
    VAR s, x: Object;
  BEGIN s := topScope;
    REPEAT x := s.next;
      WHILE (x # NIL) & (x.name # ORS.id) DO x := x.next END ;
      s := s.dsc
    UNTIL (x # NIL) OR (s = NIL);
    RETURN x
  END thisObj;

  PROCEDURE thisimport*(mod: Object): Object;
    VAR obj: Object;
  BEGIN
    IF mod.rdo THEN
      IF mod.name[0] # 0X THEN
        obj := mod.dsc;
        WHILE (obj # NIL) & (obj.name # ORS.id) DO obj := obj.next END
      ELSE obj := NIL
      END
    ELSE obj := NIL
    END ;
    RETURN obj
  END thisimport;

  PROCEDURE thisfield*(rec: Type): Object;
    VAR fld: Object;
  BEGIN fld := rec.dsc;
    WHILE (fld # NIL) & (fld.name # ORS.id) DO fld := fld.next END ;
    RETURN fld
  END thisfield;

  PROCEDURE OpenScope*;
    VAR s: Object;
  BEGIN NEW(s); s.class := Head; s.dsc := topScope; s.next := NIL; topScope := s
  END OpenScope;

  PROCEDURE CloseScope*;
  BEGIN topScope := topScope.dsc
  END CloseScope;

  (*------------------------------- Import ---------------------------------*)

  PROCEDURE MakeFileName*(VAR FName: ARRAY OF CHAR; folder, name, ext: ARRAY OF CHAR);
    VAR i, j: INTEGER;
  BEGIN i := 0; j := 0;  (*assume name suffix less than 4 characters*)
    WHILE (j < LEN(FName) - 5) & (folder[j] # 0X) DO FName[j] := folder[j]; INC(j) END ;
    IF (j > 0) & (FName[j - 1] # "/") THEN FName[j] := "/"; INC(j) END ;
    WHILE (j < LEN(FName) - 5) & (name[i] # 0X) DO FName[j] := name[i]; INC(i); INC(j) END ;
    i := 0;
    WHILE ext[i] # 0X DO FName[j] := ext[i]; INC(i); INC(j) END ;
    FName[j] := 0X
  END MakeFileName;
  
  PROCEDURE FindFileName*(VAR FName: ARRAY OF CHAR; name, ext: ARRAY OF CHAR);
    VAR 
      i: INTEGER;
      found: BOOLEAN;
  BEGIN
    i := 0;
    found := FALSE;
    WHILE (i < LEN(importPaths)) & (importPaths[i][0] # 0X) & ~found DO
      MakeFileName(FName, importPaths[i], name, ext);
      found := Files.Old(FName) # NIL;
      INC(i);
    END
  END FindFileName;

  PROCEDURE ThisModule(name, orgname: ORS.Ident; non: BOOLEAN; key: INTEGER; cdecl: BOOLEAN): Object;
    VAR mod: Module; obj, obj1: Object;
  BEGIN obj1 := topScope; obj := obj1.next;  (*search for module*)
    WHILE (obj # NIL) & (obj.name # name) DO obj1 := obj; obj := obj1.next END ;
    IF obj = NIL THEN  (*insert new module*)
      NEW(mod); mod.class := Mod; mod.rdo := FALSE; mod.cdecl := cdecl;
      mod.name := name; mod.orgname := orgname; mod.val := key;
      mod.lev := nofmod; INC(nofmod); mod.type := noType; mod.dsc := NIL; mod.next := NIL;
      obj1.next := mod; obj := mod
    ELSE (*module already present*)
      IF non THEN ORS.Mark("invalid import order") END
    END ;
    RETURN obj
  END ThisModule;
  
  PROCEDURE Read(VAR R: Files.Rider; VAR x: INTEGER);
    VAR b: BYTE;
  BEGIN Files.Read(R, b);
    IF b < 80H THEN x := b ELSE x := b - 100H END
  END Read;
  
  PROCEDURE InType(VAR R: Files.Rider; thismod: Object; VAR T: Type);
    VAR key: INTEGER;
      ref, class, form, np, readonly: INTEGER;
      fld, par, obj, mod, last: Object;
      t: Type;
      name, modname: ORS.Ident;
      cdecl: BOOLEAN;
  BEGIN Read(R, ref);
    IF ref < 0 THEN T := typtab[-ref]  (* already read *)
    ELSE NEW(t); T := t; typtab[ref] := t; t.mno := thismod.lev;
      Read(R, form); t.form := form;
      IF (form = Pointer) OR (form = CPointer) THEN InType(R, thismod, t.base); t.size := 4
      ELSIF (form = Array) OR (form = CArray) THEN
        InType(R, thismod, t.base); Files.ReadNum(R, t.len); Files.ReadNum(R, t.size)
      ELSIF (form = Record) OR (form = CRecord) THEN
        InType(R, thismod, t.base);
        IF t.base.form = NoTyp THEN t.base := NIL; obj := NIL ELSE obj := t.base.dsc END ;
        Files.ReadNum(R, t.len);     (* TD adr/exno *)
        Files.ReadNum(R, t.nofpar);  (* ext level   *)
        Files.ReadNum(R, t.size);
        Read(R, class); last := NIL;
        WHILE class # 0 DO  (* fields *)
          NEW(fld); fld.class := class; Files.ReadString(R, fld.name);
          IF last = NIL THEN t.dsc := fld ELSE last.next := fld END ;
          last := fld;
          IF fld.name[0] # 0X THEN fld.expo := TRUE; InType(R, thismod, fld.type) ELSE fld.expo := FALSE; fld.type := nilType END ;
          Files.ReadNum(R, fld.val); Read(R, class)
        END ;
        IF last = NIL THEN t.dsc := obj ELSE last.next := obj END
      ELSIF (form = Proc) OR (form = CProc) THEN
        InType(R, thismod, t.base);
        obj := NIL; np := 0; Read(R, class);
        WHILE class # 0 DO  (* parameters *)
          NEW(par); par.class := class; Read(R, readonly); par.rdo := readonly = 1; 
          InType(R, thismod, par.type); par.next := obj; obj := par; INC(np); Read(R, class)
        END ;
        t.dsc := obj; t.nofpar := np; t.size := 4
      END ;
      Files.ReadString(R, modname);
      IF modname[0] # 0X THEN  (* re-import *)
        Files.ReadInt(R, key); Files.ReadString(R, name);
        Read(R, class); (* cdecl *)
        cdecl := class = 1;
        mod := ThisModule(modname, modname, FALSE, key, cdecl);
        obj := mod.dsc;  (* search type *)
        WHILE (obj # NIL) & (obj.name # name) DO obj := obj.next END ;
        IF obj # NIL THEN T := obj.type   (* type object found in object list of mod *)
        ELSE (* insert new type object in object list of mod *)
          NEW(obj); obj.name := name; obj.class := Typ; obj.next := mod.dsc; mod.dsc := obj; obj.type := t;
          t.mno := mod.lev; t.typobj := obj; T := t
        END ;
        typtab[ref] := T
      END
    END
  END InType;
  
  (* Skip imported module name *)
  PROCEDURE SkipImported(VAR R: Files.Rider);
    VAR cnt: INTEGER; name: ORS.Ident;
  BEGIN
    Read(R, cnt);
    WHILE cnt > 0 DO Files.ReadString(R, name); DEC(cnt) END ;
  END SkipImported;

  PROCEDURE Import*(VAR modid, modid1: ORS.Ident);
    VAR key: INTEGER; class, k: INTEGER;
      obj: Object;  t: Type;
      thismod: Object;
      modname: ORS.Ident;
      F: Files.File; R: Files.Rider;
      fname: ARRAY 256 OF CHAR;
      cdecl: BOOLEAN;
  BEGIN
    IF modid1 = "SYSTEM" THEN
      thismod := ThisModule(modid, modid1, TRUE, key, FALSE); DEC(nofmod);
      thismod.lev := 0; thismod.dsc := system; thismod.rdo := TRUE
    ELSE 
      FindFileName(fname, modid1, ".smb"); 
      F := Files.Old(fname);
      IF F # NIL THEN
        Files.Set(R, F, 0); Files.ReadInt(R, key); Files.ReadInt(R, key); Files.ReadString(R, modname);
        Read(R, class); (* version key *)
        IF class # Config.SmbVersionKey THEN ORS.Mark("wrong version") END ;
        Read(R, class); (* cdecl *)
        cdecl := class = 1;
        thismod := ThisModule(modid, modid1, TRUE, key, cdecl); thismod.rdo := TRUE;
        SkipImported(R);
        Read(R, class);
        WHILE class # 0 DO
          NEW(obj); obj.class := class; Files.ReadString(R, obj.name);
          InType(R, thismod, obj.type); obj.lev := -thismod.lev;
          IF class = Typ THEN
            t := obj.type; t.typobj := obj; Read(R, k);  (* fixup bases of previously declared pointer types *)
            WHILE k # 0 DO typtab[k].base := t; Read(R, k) END
          ELSE
            IF class = Const THEN
              IF obj.type.form = Real THEN Files.ReadInt(R, obj.val)
              ELSE Files.ReadNum(R, obj.val); 
                IF obj.type = longType THEN Files.ReadNum(R, obj.val1) END 
              END
            ELSIF class = Var THEN Files.ReadNum(R, obj.val); obj.rdo := TRUE
            END
          END ;
          obj.next := thismod.dsc; thismod.dsc := obj; Read(R, class)
        END ;
      ELSE ORS.Mark("import not available")
      END
    END
  END Import;
  
  (*-------------------------------- Export ---------------------------------*)

  PROCEDURE Write(VAR R: Files.Rider; x: INTEGER);
  BEGIN Files.Write(R, x)
  END Write;

  PROCEDURE OutType(VAR R: Files.Rider; t: Type);
    VAR obj, mod, fld, bot: Object;

    PROCEDURE OutPar(VAR R: Files.Rider; par: Object; n: INTEGER);
      VAR cl: INTEGER;
    BEGIN
      IF n > 0 THEN
        OutPar(R, par.next, n-1); cl := par.class;
        Write(R, cl);
        IF par.rdo THEN Write(R, 1) ELSE Write(R, 0) END ;
        OutType(R, par.type)
      END
    END OutPar;

    PROCEDURE FindHiddenPointers(VAR R: Files.Rider; typ: Type; offset: INTEGER);
      VAR fld: Object; i, n: INTEGER;
    BEGIN
      IF (typ.form = Pointer) OR (typ.form = NilTyp) THEN Write(R, Fld); Write(R, 0); Files.WriteNum(R, offset)
      ELSIF typ.form = Record THEN fld := typ.dsc;
        WHILE fld # NIL DO FindHiddenPointers(R, fld.type, fld.val + offset); fld := fld.next END
      ELSIF typ.form = Array THEN i := 0; n := typ.len;
        WHILE i < n DO FindHiddenPointers(R, typ.base, typ.base.size * i + offset); INC(i) END
      END
    END FindHiddenPointers;

  BEGIN
    IF t.ref > 0 THEN (*type was already output*) Write(R, -t.ref)
    ELSE obj := t.typobj;
      IF obj # NIL THEN Write(R, Ref); t.ref := Ref; INC(Ref) ELSE (*anonymous*) Write(R, 0) END ;
      Write(R, t.form);
      IF (t.form = Pointer) OR (t.form = CPointer) THEN OutType(R, t.base)
      ELSIF (t.form = Array) OR (t.form = CArray) THEN OutType(R, t.base); Files.WriteNum(R, t.len); Files.WriteNum(R, t.size)
      ELSIF (t.form = Record) OR (t.form = CRecord) THEN
        IF t.base # NIL THEN OutType(R, t.base); bot := t.base.dsc ELSE OutType(R, noType); bot := NIL END ;
        IF obj # NIL THEN Files.WriteNum(R, obj.exno) ELSE Write(R, 0) END ;
        Files.WriteNum(R, t.nofpar); Files.WriteNum(R, t.size);
        fld := t.dsc;
        WHILE fld # bot DO  (*fields*)
          IF fld.expo THEN
            Write(R, Fld); Files.WriteString(R, fld.name); OutType(R, fld.type); Files.WriteNum(R, fld.val)  (*offset*)
          ELSE FindHiddenPointers(R, fld.type, fld.val)
          END ;
          fld := fld.next
        END ;
        Write(R, 0)
      ELSIF (t.form = Proc) OR (t.form = CProc) THEN OutType(R, t.base); OutPar(R, t.dsc, t.nofpar); Write(R, 0)
      END ;
      IF (t.mno > 0) & (obj # NIL) THEN  (*re-export, output name*)
        mod := topScope.next;
        WHILE (mod # NIL) & (mod.lev # t.mno) DO mod := mod.next END ;
        IF mod # NIL THEN 
          Files.WriteString(R, mod(Module).orgname); 
          Files.WriteInt(R, mod.val); 
          Files.WriteString(R, obj.name);
          Write(R, ORD(mod(Module).cdecl))
        ELSE ORS.Mark("re-export not found"); Write(R, 0)
        END
      ELSE Write(R, 0)
      END
    END
  END OutType;

  (* Write imported module names *)
  PROCEDURE OutImported(VAR R: Files.Rider);
  VAR cnt: INTEGER; obj: Object;
  BEGIN
    obj := topScope.next;
    cnt := 0;
    WHILE obj # NIL DO
      IF (obj.class = Mod) & (obj.dsc # system) THEN INC(cnt) END ;
      obj := obj.next
    END ;
    Write(R, cnt);
    obj := topScope.next;
    WHILE obj # NIL DO
      IF (obj.class = Mod) & (obj.dsc # system) THEN 
        Files.WriteString(R, obj(Module).orgname) 
      END ;
      obj := obj.next
    END ;
  END OutImported;

  PROCEDURE Export*(VAR modid: ORS.Ident; VAR newSF: BOOLEAN; VAR key: INTEGER; cdecl: BOOLEAN; folder: ARRAY OF CHAR);
    VAR x, sum, oldkey: INTEGER;
      obj, obj0: Object;
      filename: ARRAY 256 OF CHAR;
      F, F1: Files.File; R, R1: Files.Rider;
  BEGIN 
    Ref := Record + 1; 
    MakeFileName(filename, folder, modid, ".smb");
    F := Files.New(filename); Files.Set(R, F, 0);
    Files.WriteInt(R, 0); (* placeholder *)
    Files.WriteInt(R, 0); (* placeholder for key to be inserted at the end *)
    Files.WriteString(R, modid); Write(R, Config.SmbVersionKey); Write(R, ORD(cdecl));
    OutImported(R);
    obj := topScope.next;
    WHILE obj # NIL DO
      IF obj.expo THEN
        Write(R, obj.class); Files.WriteString(R, obj.name);
        OutType(R, obj.type);
        IF obj.class = Typ THEN
          IF (obj.type.form = Record) OR (obj.type.form = CRecord) THEN
            obj0 := topScope.next;  (* check whether this is base of previously declared pointer types *)
            WHILE obj0 # obj DO
              IF ((obj0.type.form = Pointer) OR (obj0.type.form = CPointer)) & (obj0.type.base = obj.type) & (obj0.type.ref > 0) THEN Write(R, obj0.type.ref) END ;
              obj0 := obj0.next
            END
          END ;
          Write(R, 0)
        ELSIF obj.class = Const THEN
          IF (obj.type.form = Proc) OR (obj.type.form = CProc) THEN Files.WriteNum(R, obj.exno)
          ELSIF obj.type.form = Real THEN Files.WriteInt(R, obj.val)
          ELSE Files.WriteNum(R, obj.val);
            IF obj.type = longType THEN Files.WriteNum(R, obj.val1) END
          END
        ELSIF obj.class = Var THEN Files.WriteNum(R, obj.val)
        END
      END ;
      obj := obj.next
    END ;
    REPEAT Write(R, 0) UNTIL Files.Length(F) MOD 4 = 0;
    FOR Ref := Record+1 TO maxTypTab-1 DO typtab[Ref] := NIL END ;
    Files.Set(R, F, 0); sum := 0; Files.ReadInt(R, x);  (* compute key (checksum) *)
    WHILE ~R.eof DO sum := sum + x; Files.ReadInt(R, x) END ;
    F1 := Files.Old(filename); (* sum is new key *)
    IF F1 # NIL THEN Files.Set(R1, F1, 4); Files.ReadInt(R1, oldkey) ELSE oldkey := sum+1 END ;
    IF sum # oldkey THEN
      IF newSF OR (F1 = NIL) THEN
        key := sum; newSF := TRUE; Files.Set(R, F, 4); Files.WriteInt(R, sum);   (* insert checksum *)
        Files.Register(F);
        Files.Close(F);
      ELSE ORS.Mark("new symbol file inhibited")
      END
    ELSE newSF := FALSE; key := sum
    END
  END Export;

  PROCEDURE Init*(impPath: ARRAY OF CHAR);
  BEGIN
    DecodePath(impPath); 
    topScope := universe; nofmod := 1
  END Init;
  
  PROCEDURE type(ref, form: INTEGER; size: INTEGER): Type;
    VAR tp: Type;
  BEGIN NEW(tp); tp.form := form; tp.size := size; tp.ref := ref; tp.base := NIL;
    typtab[ref] := tp; RETURN tp
  END type;

  PROCEDURE enter(name: ARRAY OF CHAR; cl: INTEGER; type: Type; n: INTEGER);
    VAR obj: Object;
  BEGIN NEW(obj); obj.name := name; obj.class := cl; obj.type := type; obj.val := n; obj.dsc := NIL;
    IF cl = Typ THEN type.typobj := obj END ;
    obj.next := system; system := obj
  END enter;
  
BEGIN
  byteType  := type(Byte,     Int,    1);
  boolType  := type(Bool,     Bool,   1);
  charType  := type(Char,     Char,   1);
  shortType := type(ShortInt, Int,    2);
  intType   := type(Int,      Int,    4);
  longType  := type(LongInt,  Int,    8);
  realType  := type(Real,     Real,   4);
  setType   := type(Set,      Set,    4);
  nilType   := type(NilTyp,   NilTyp, 4);
  noType    := type(NoTyp,    NoTyp,  4);
  strType   := type(String,   String, 8);
    
  (*initialize universe with data types and in-line procedures;
    LONGINT is *NOT* synonym to INTEGER, LONGREAL to REAL.
    LED, ADC, SBC; LDPSR, LDREG, REG, COND are not in language definition From RISC Compiler
    neither are NOT AND BOR XOR MIN MAX from the ESP32 Compiler *)

  system := NIL;   (* n = procno*10 + nofpar *)

  enter("SQRT",     SFunc, realType, 271);
  enter("MAX",      SFunc, noType,   262);
  enter("MIN",      SFunc, noType,   252);
  enter("XOR",      SFunc, intType,  242);
  enter("BOR",      SFunc, intType,  232);
  enter("AND",      SFunc, intType,  222);
  enter("NOT",      SFunc, intType,  211);
  enter("UML",      SFunc, intType,  132);
  enter("SBC",      SFunc, intType,  122);
  enter("ADC",      SFunc, intType,  112);
  enter("ROR",      SFunc, intType,   92);
  enter("ASR",      SFunc, intType,   82);
  enter("LSL",      SFunc, intType,   72);
  enter("LEN",      SFunc, intType,   61);
  enter("CHR",      SFunc, charType,  51);
  enter("ORD",      SFunc, intType,   41);
  enter("FLT",      SFunc, realType,  31);
  enter("FLOOR",    SFunc, intType,   21);
  enter("ODD",      SFunc, boolType,  11);
  enter("ABS",      SFunc, intType,    1);
  enter("LED",      SProc, noType,    81);  (* procedures *)
  enter("UNPK",     SProc, noType,    72);
  enter("PACK",     SProc, noType,    62);
  enter("NEW",      SProc, noType,    51);
  enter("ASSERT",   SProc, noType,    41);
  enter("EXCL",     SProc, noType,    32);
  enter("INCL",     SProc, noType,    22);
  enter("DEC",      SProc, noType,    11);
  enter("INC",      SProc, noType,     1);
  enter("SET",      Typ,   setType,    0);  (* types *)
  enter("BOOLEAN",  Typ,   boolType,   0);
  enter("BYTE",     Typ,   byteType,   0);
  enter("CHAR",     Typ,   charType,   0);
  enter("LONGREAL", Typ,   realType,   0);
  enter("REAL",     Typ,   realType,   0);
  enter("SHORTINT", Typ,   shortType,  0);
  enter("INTEGER",  Typ,   intType,    0);
  enter("LONGINT",  Typ,   longType,   0);

  topScope := NIL; OpenScope; topScope.next := system; universe := topScope;
  
  system := NIL;  (* initialize "unsafe" pseudo-module SYSTEM*)

  enter("RSR",      SFunc, intType,  281);  (* functions *)
  enter("H",        SFunc, intType,  201);
  enter("COND",     SFunc, boolType, 191);
  enter("SIZE",     SFunc, intType,  181);
  enter("ADR",      SFunc, intType,  171);
  enter("VAL",      SFunc, intType,  162);
  enter("REG",      SFunc, intType,  151);
  enter("BIT",      SFunc, boolType, 142);
  enter("WSR",      SProc, intType,  152);  (* procedures *)
  enter("LDREG",    SProc, noType,   142);
  enter("LDPSR",    SProc, noType,   131);
  enter("COPY",     SProc, noType,   123);
  enter("PUT",      SProc, noType,   112);
  enter("GET",      SProc, noType,   102);
END ORB.
