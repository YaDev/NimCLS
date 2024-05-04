import nimcls/clsmacro
import macros

static:

    ## 
    ## 
    ## Check Classes Names
    ## 
    ## 
    
    block: # Check regular class's name
        let className: string = "MyClass"
        let ast: NimNode = parseExpr("Class " & className)
        let output: NimNode = createClass(ast[1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check regular class's name
        let className: string = "MyClass"
        let ast: NimNode = parseExpr("Class *" & className)
        let output: NimNode = createClass(ast[1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][1] == className

    block: # Check static class's name
        let className: string = "MyClass"
        let ast: NimNode = parseStmt("Class static " & className)
        let output: NimNode = createClass(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check static class's name
        let className: string = "MyClass"
        let ast: NimNode = parseStmt("Class static *" & className)
        let output: NimNode = createClass(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][1] == className

    block: # Check generic class's name
        let className: string = "MyClass"
        let genericName: string = "MyClass[T,R]"
        let ast: NimNode = parseStmt("Class " & genericName)
        let output: NimNode = createClass(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check generic class's name
        let className: string = "MyClass"
        let genericName: string = "MyClass[T: int,R](Test[T])"
        let ast: NimNode = parseStmt("Class " & genericName)
        let output: NimNode = createClass(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check static generic class's name
        let className: string = "MyClass"
        let genericName: string = "*MyClass[T,R]"
        let ast: NimNode = parseStmt("Class static " & genericName)
        let output: NimNode = createClass(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][1] == className


    block: # Check static generic class's name
        let className: string = "MyClass"
        let genericName: string = "MyClass[T,R]"
        let ast: NimNode = parseStmt("Class static " & genericName)
        let output: NimNode = createClass(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check static generic class's name
        let className: string = "MyClass"
        let genericName: string = "MyClass[T,R](Test[T])"
        let ast: NimNode = parseStmt("Class static " & genericName)
        let output: NimNode = createClass(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className
    
    ## 
    ## 
    ## Check Classes export
    ## 
    ## 
    
    block: # Check regular class is exported
        let ast: NimNode = parseExpr("Class *MyClass")
        let output: NimNode = createClass(ast[1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check regular class is exported
        let ast: NimNode = parseExpr("Class MyClass*(Test)")
        let output: NimNode = createClass(ast[1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check static class is exported
        let ast: NimNode = parseStmt("Class static MyClass*(Test)")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"
    
    block: # Check static class is exported
        let ast: NimNode = parseStmt("Class static *MyClass")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check generic class is exported
        let ast: NimNode = parseStmt("Class *MyClass[T,R]")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check generic class is exported
        let ast: NimNode = parseStmt("Class MyClass*[T,R](RootObj)")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check static generic class is exported
        let ast: NimNode = parseStmt("Class static *MyClass[T,R]")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check static generic class is exported
        let ast: NimNode = parseStmt("Class static MyClass*[T,R](Test[T,R])")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    ## 
    ## 
    ## Check Classes' parent
    ## 
    ## 
    
    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class MyClass(" & parentClassName & ")")
        let output: NimNode = createClass(ast[0][1])
        assert $output[0][0][2][0][1][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class MyClass*(" & parentClassName & ")")
        let output: NimNode = createClass(ast[0][1])
        assert $output[0][0][2][0][1][0] == parentClassName
        

    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class static MyClass(" & parentClassName & ")")
        let output: NimNode = createClass(ast[0][1])
        assert $output[0][0][2][1][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class static MyClass*(" & parentClassName & ")")
        let output: NimNode = createClass(ast[0][1])
        assert $output[0][0][2][1][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class MyClass*[T](" & parentClassName & ")")
        let output: NimNode = createClass(ast[0][1])
        assert $output[0][0][2][0][1][0] == parentClassName
        

    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class static MyClass[K,V](" & parentClassName & ")")
        let output: NimNode = createClass(ast[0][1])
        assert $output[0][0][2][1][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let parentClassGeneric = parentClassName & "[K,V]"
        let ast: NimNode = parseStmt("Class static MyClass[K,V](" & parentClassGeneric & ")")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][2][1][0].kind == nnkBracketExpr
        assert $output[0][0][2][1][0][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let parentClassGeneric = parentClassName & "[K,V]"
        let ast: NimNode = parseStmt("Class MyClass*[K: int | string, V: float | string](" & parentClassGeneric & ")")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][2][0][1][0].kind == nnkBracketExpr
        assert $output[0][0][2][0][1][0][0] == parentClassName

    ## 
    ## 
    ## Check Classes' types
    ## 
    ## 

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class MyClass")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][2].kind == nnkRefTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class static MyClass")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][2].kind == nnkObjectTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class MyClass*(Test)")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][2].kind == nnkRefTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class static MyClass(Test)")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][2].kind == nnkObjectTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class *MyClass[T]")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][2].kind == nnkRefTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class static MyClass[R, V](Test[R,V])")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][2].kind == nnkObjectTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class MyClass[R, V](Test[R,V])")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][2].kind == nnkRefTy


    ## 
    ## 
    ## Check Classes' generic parameters
    ## 
    ## 

    block: # Check generic parameters 
        let ast: NimNode = parseStmt("Class *MyClass[K: int | string, V: float | string]")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][1].kind == nnkGenericParams
        assert output[0][0][1].len == 2
        assert output[0][0][1][1][1].kind == nnkInfix
        assert output[0][0][1][1][1].len == 3
        assert $output[0][0][1][1][1][2] == "string"


    block: # Check generic parameters 
        let ast: NimNode = parseStmt("Class static MyClass*[K, V, Y, Z](Test[T])")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][1].kind == nnkGenericParams
        assert output[0][0][1][0].kind == nnkIdentDefs
        assert output[0][0][1][0].len == 6
        assert $output[0][0][1][0][3] == "Z"


    block: # Check generic parameters 
        let ast: NimNode = parseStmt("Class MyClass[K, V : int | float, Y, Z: string]")
        let output: NimNode = createClass(ast[0][1])
        assert output[0][0][1].kind == nnkGenericParams
        assert output[0][0][1].len == 4
        assert output[0][0][1][0].kind == nnkIdentDefs
        assert $output[0][0][1][0][0] == "K"
        assert $output[0][0][1][1][0] == "V"
        assert output[0][0][1][1][1].kind == nnkInfix
        assert $output[0][0][1][3][1] == "string"


    ## 
    ## 
    ## Check Classes' methods and procedures
    ## 
    ## 


    block: # Check methods and procedures
        let ast: NimNode = parseExpr("Class *MyClass")
        let output: NimNode = createClass(ast[1])
        var count_methods: int = 0
        for elem in output[2][0][1]:
            if elem.kind == nnkMethodDef:
                count_methods += 1
        assert count_methods == 5
        assert output[1].kind == nnkProcDef


    block: # Check methods and procedures
        let ast: NimNode = parseExpr("Class static MyClass(Test)")
        let output: NimNode = createClass(ast[1])
        var count_methods: int = 0
        for elem in output[2][0][1]:
            if elem.kind == nnkMethodDef:
                count_methods += 1
        assert count_methods == 5
        assert output[1].kind == nnkProcDef

    block: # Check methods and procedures
        let ast: NimNode = parseExpr("Class MyClass[T,R](Test)")
        let output: NimNode = createClass(ast[1])
        var count_methods: int = 0
        var count_procedures: int = 0
        for elem in output[2][0][1]:
            if elem.kind == nnkMethodDef:
                count_methods += 1
            if elem.kind == nnkProcDef:
                count_procedures += 1
        assert count_procedures == 5
        assert count_methods == 0
        assert output[1].kind == nnkProcDef


    block: # Check methods and procedures
        let ast: NimNode = parseExpr("Class static MyClass*[T,R](Test[T])")
        let output: NimNode = createClass(ast[1])
        var count_methods: int = 0
        var count_procedures: int = 0
        for elem in output[2][0][1]:
            if elem.kind == nnkMethodDef:
                count_methods += 1
            if elem.kind == nnkProcDef:
                count_procedures += 1
        assert count_procedures == 5
        assert count_methods == 0
        assert output[1].kind == nnkProcDef


    ## 
    ## 
    ## Check Classes' variables
    ## 
    ## 

    block: # Check variables
        let ast: NimNode = parseExpr("""
        Class MyClass:
            var s: string
            var i: int = 0
        """)
        let output: NimNode = createClass(ast[1], ast[2])
        assert output[0][0][2].kind == nnkRefTy
        assert output[0][0][2][0].kind == nnkObjectTy
        assert output[0][0][2][0][2].kind == nnkRecList
        assert output[0][0][2][0][2].len == 2
        assert $output[0][0][2][0][2][1][1] == "int"


    ## 
    ## 
    ## Check Classes' methods
    ## 
    ## 

    block: # Check methods
        let ast: NimNode = parseExpr("""
        Class static MyClass:
            method test(s: MyClass) = echo "My Class"
        """)
        let output: NimNode = createClass(ast[1], ast[2])
        assert output[0][0][2].kind == nnkObjectTy
        assert output[3].kind == nnkMethodDef
        assert output[3][0].kind == nnkIdent
        assert $output[3][0] == "test"


    block: # Check methods
        let ast: NimNode = parseExpr("""
        Class MyClass:
            method test(s: MyClass) = echo "My Class"
        """)
        let output: NimNode = createClass(ast[1], ast[2])
        assert output[0][0][2].kind == nnkRefTy
        assert output[3].kind == nnkMethodDef
        assert output[3][0].kind == nnkIdent
        assert $output[3][0] == "test"


    block: # Check methods
        let ast: NimNode = parseExpr("""
        Class MyClass[T]:
            method test[T](s: MyClass[T]) = echo "My Class"
        """)
        let output: NimNode = createClass(ast[1], ast[2])
        assert output[0][0][2].kind == nnkRefTy 
        assert output[3].kind == nnkMethodDef
        assert output[3][0].kind == nnkIdent
        assert $output[3][0] == "test"

    block: # Check methods
        let ast: NimNode = parseExpr("""
        Class static MyClass[T]:
            method test[T](s: MyClass[T]) = echo "My Class"
        """)
        let output: NimNode = createClass(ast[1], ast[2])
        assert output[0][0][2].kind == nnkObjectTy
        assert output[3].kind == nnkMethodDef
        assert output[3][0].kind == nnkIdent
        assert $output[3][0] == "test"

        
    block: # Check proc
        let ast: NimNode = parseExpr("""
        Class MyClass:
            proc test(s: typedesc[MyClass]) = echo "My Class"
        """)
        let output: NimNode = createClass(ast[1], ast[2])
        assert output[0][0][2].kind == nnkRefTy
        assert output[3].kind == nnkProcDef
        assert output[3][0].kind == nnkIdent
        assert $output[3][0] == "test"


    ## 
    ## 
    ## Check Interfaces' methods
    ## 
    ## 


    block: # Check Interfaces
        let ast: NimNode = parseExpr("""
        Interface IClass:
            method test1(i: IClass)
            method test2(i: IClass, value: int): int
            method test3(i: IClass, next: float): string
        """)
        let output: NimNode = createInterface(ast[1], ast[2])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == "IClass"
        assert output[len(output) - 1].kind == nnkMethodDef
        assert output[len(output) - 2].kind == nnkMethodDef
        assert output[len(output) - 3].kind == nnkMethodDef
        assert output[len(output) - 3][0].kind == nnkIdent
        assert $output[len(output) - 1][0] == "test3"
        assert $output[len(output) - 2][0] == "test2"
        assert $output[len(output) - 3][0] == "test1"
        assert output[len(output) - 1][4].kind == nnkPragma
        assert $output[len(output) - 1][4][0] == "base"
        assert output[len(output) - 1][6].kind == nnkStmtList
        assert output[len(output) - 1][6][0].kind == nnkRaiseStmt

    block: # Check Interfaces
        let ast: NimNode = parseExpr("""
        Interface *IClass:
            method test1(i: IClass)
            method test2(i: IClass, value: int): int
            method test3(i: IClass, next: float): string
        """)
        let output: NimNode = createInterface(ast[1], ast[2])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][1] == "IClass"
        assert $output[0][0][2][0][1][0] == "ClassObj"
        assert output[len(output) - 1].kind == nnkMethodDef
        assert output[len(output) - 2].kind == nnkMethodDef
        assert output[len(output) - 3].kind == nnkMethodDef
        assert output[len(output) - 3][0].kind == nnkIdent
        assert $output[len(output) - 1][0] == "test3"
        assert $output[len(output) - 2][0] == "test2"
        assert $output[len(output) - 3][0] == "test1"
        assert output[len(output) - 1][4].kind == nnkPragma
        assert $output[len(output) - 1][4][0] == "base"
        assert output[len(output) - 1][6].kind == nnkStmtList
        assert output[len(output) - 1][6][0].kind == nnkRaiseStmt


    ## 
    ## 
    ## Check When statements
    ## 
    ## 


    block: # Check When for variables
        let ast: NimNode = parseExpr("""
        Class MyClass:
            var i: int = 0
            when true:
                var s: string
            else:
                var f: float
        """)
        let output: NimNode = createClass(ast[1], ast[2])
        assert output[0][0][2].kind == nnkRefTy
        assert output[0][0][2][0].kind == nnkObjectTy
        assert output[0][0][2][0][2].kind == nnkRecList
        assert output[0][0][2][0][2].len == 2
        assert output[0][0][2][0][2][1].kind == nnkRecWhen
        assert output[0][0][2][0][2][1].len == 2
        assert output[0][0][2][0][2][1][0].kind == nnkElifBranch
        assert output[0][0][2][0][2][1][1].kind == nnkElse
        assert output[0][0][2][0][2][1][1][0].kind == nnkRecList
        assert $output[0][0][2][0][2][1][1][0][0][0] == "f"



    block: # Check When for methods, proc, functions
        let ast: NimNode = parseExpr("""
        Class MyClass:
            when defined(linux):
                proc x(self: MyClass) = echo "linux"
            elif defined(windows):
                func x(self: MyClass) = echo "windows"
            else:
                method x(self: MyClass) = echo "others"
        """)
        let output: NimNode = createClass(ast[1], ast[2])
        assert output[len(output) - 1].kind == nnkWhenStmt
        assert output[len(output) - 1].len == 3
        assert output[len(output) - 1][0].kind == nnkElifBranch
        assert output[len(output) - 1][1].kind == nnkElifBranch
        assert output[len(output) - 1][2].kind == nnkElse
        assert output[len(output) - 1][2][0][0].kind == nnkMethodDef
        assert $output[len(output) - 1][2][0][0][0] == "x"
