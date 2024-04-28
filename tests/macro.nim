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
        let output: NimNode = processMacro(ast[1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check regular class's name
        let className: string = "MyClass"
        let ast: NimNode = parseExpr("Class *" & className)
        let output: NimNode = processMacro(ast[1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][1] == className

    block: # Check static class's name
        let className: string = "MyClass"
        let ast: NimNode = parseStmt("Class static " & className)
        let output: NimNode = processMacro(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check static class's name
        let className: string = "MyClass"
        let ast: NimNode = parseStmt("Class static *" & className)
        let output: NimNode = processMacro(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][1] == className

    block: # Check generic class's name
        let className: string = "MyClass"
        let genericName: string = "MyClass[T,R]"
        let ast: NimNode = parseStmt("Class " & genericName)
        let output: NimNode = processMacro(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check generic class's name
        let className: string = "MyClass"
        let genericName: string = "MyClass[T: int,R](Test[T])"
        let ast: NimNode = parseStmt("Class " & genericName)
        let output: NimNode = processMacro(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check static generic class's name
        let className: string = "MyClass"
        let genericName: string = "*MyClass[T,R]"
        let ast: NimNode = parseStmt("Class static " & genericName)
        let output: NimNode = processMacro(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][1] == className


    block: # Check static generic class's name
        let className: string = "MyClass"
        let genericName: string = "MyClass[T,R]"
        let ast: NimNode = parseStmt("Class static " & genericName)
        let output: NimNode = processMacro(ast[0][1])
        assert output.kind == nnkStmtList
        assert output[0].kind == nnkTypeSection
        assert output[0][0].kind == nnkTypeDef
        assert output[0][0][0].kind == nnkIdent
        assert $output[0][0][0] == className

    block: # Check static generic class's name
        let className: string = "MyClass"
        let genericName: string = "MyClass[T,R](Test[T])"
        let ast: NimNode = parseStmt("Class static " & genericName)
        let output: NimNode = processMacro(ast[0][1])
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
        let output: NimNode = processMacro(ast[1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check regular class is exported
        let ast: NimNode = parseExpr("Class MyClass*(Test)")
        let output: NimNode = processMacro(ast[1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check static class is exported
        let ast: NimNode = parseStmt("Class static MyClass*(Test)")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"
    
    block: # Check static class is exported
        let ast: NimNode = parseStmt("Class static *MyClass")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check generic class is exported
        let ast: NimNode = parseStmt("Class *MyClass[T,R]")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check generic class is exported
        let ast: NimNode = parseStmt("Class MyClass*[T,R](RootObj)")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check static generic class is exported
        let ast: NimNode = parseStmt("Class static *MyClass[T,R]")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][0].kind == nnkPostfix
        assert $output[0][0][0][0] == "*"

    block: # Check static generic class is exported
        let ast: NimNode = parseStmt("Class static MyClass*[T,R](Test[T,R])")
        let output: NimNode = processMacro(ast[0][1])
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
        let output: NimNode = processMacro(ast[0][1])
        assert $output[0][0][2][0][1][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class MyClass*(" & parentClassName & ")")
        let output: NimNode = processMacro(ast[0][1])
        assert $output[0][0][2][0][1][0] == parentClassName
        

    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class static MyClass(" & parentClassName & ")")
        let output: NimNode = processMacro(ast[0][1])
        assert $output[0][0][2][1][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class static MyClass*(" & parentClassName & ")")
        let output: NimNode = processMacro(ast[0][1])
        assert $output[0][0][2][1][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class MyClass*[T](" & parentClassName & ")")
        let output: NimNode = processMacro(ast[0][1])
        assert $output[0][0][2][0][1][0] == parentClassName
        

    block: # Check parent class 
        let parentClassName = "Test"
        let ast: NimNode = parseStmt("Class static MyClass[K,V](" & parentClassName & ")")
        let output: NimNode = processMacro(ast[0][1])
        assert $output[0][0][2][1][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let parentClassGeneric = parentClassName & "[K,V]"
        let ast: NimNode = parseStmt("Class static MyClass[K,V](" & parentClassGeneric & ")")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][2][1][0].kind == nnkBracketExpr
        assert $output[0][0][2][1][0][0] == parentClassName


    block: # Check parent class 
        let parentClassName = "Test"
        let parentClassGeneric = parentClassName & "[K,V]"
        let ast: NimNode = parseStmt("Class MyClass*[K: int | string, V: float | string](" & parentClassGeneric & ")")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][2][0][1][0].kind == nnkBracketExpr
        assert $output[0][0][2][0][1][0][0] == parentClassName

    ## 
    ## 
    ## Check Classes' types
    ## 
    ## 

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class MyClass")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][2].kind == nnkRefTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class static MyClass")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][2].kind == nnkObjectTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class MyClass*(Test)")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][2].kind == nnkRefTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class static MyClass(Test)")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][2].kind == nnkObjectTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class *MyClass[T]")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][2].kind == nnkRefTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class static MyClass[R, V](Test[R,V])")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][2].kind == nnkObjectTy

    block: # Check class's object type 
        let ast: NimNode = parseStmt("Class MyClass[R, V](Test[R,V])")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][2].kind == nnkRefTy


    ## 
    ## 
    ## Check Classes' generic parameters
    ## 
    ## 

    block: # Check generic parameters 
        let ast: NimNode = parseStmt("Class *MyClass[K: int | string, V: float | string]")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][1].kind == nnkGenericParams
        assert output[0][0][1].len == 2
        assert output[0][0][1][1][1].kind == nnkInfix
        assert output[0][0][1][1][1].len == 3
        assert $output[0][0][1][1][1][2] == "string"


    block: # Check generic parameters 
        let ast: NimNode = parseStmt("Class static MyClass*[K, V, Y, Z](Test[T])")
        let output: NimNode = processMacro(ast[0][1])
        assert output[0][0][1].kind == nnkGenericParams
        assert output[0][0][1][0].kind == nnkIdentDefs
        assert output[0][0][1][0].len == 6
        assert $output[0][0][1][0][3] == "Z"


    block: # Check generic parameters 
        let ast: NimNode = parseStmt("Class MyClass[K, V : int | float, Y, Z: string]")
        let output: NimNode = processMacro(ast[0][1])
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
        let output: NimNode = processMacro(ast[1])
        var count_methods: int = 0
        var count_procedures: int = 0
        for elem in output[1][0][1]:
            if elem.kind == nnkMethodDef:
                count_methods += 1
            if elem.kind == nnkProcDef:
                count_procedures += 1
        assert count_methods == 5
        assert count_procedures == 1


    block: # Check methods and procedures
        let ast: NimNode = parseExpr("Class static MyClass(Test)")
        let output: NimNode = processMacro(ast[1])
        var count_methods: int = 0
        var count_procedures: int = 0
        for elem in output[1][0][1]:
            if elem.kind == nnkMethodDef:
                count_methods += 1
            if elem.kind == nnkProcDef:
                count_procedures += 1
        assert count_methods == 5
        assert count_procedures == 1

    block: # Check methods and procedures
        let ast: NimNode = parseExpr("Class MyClass[T,R](Test)")
        let output: NimNode = processMacro(ast[1])
        var count_methods: int = 0
        var count_procedures: int = 0
        for elem in output[1][0][1]:
            if elem.kind == nnkMethodDef:
                count_methods += 1
            if elem.kind == nnkProcDef:
                count_procedures += 1
        assert count_methods == 0
        assert count_procedures == 6


    block: # Check methods and procedures
        let ast: NimNode = parseExpr("Class static MyClass*[T,R](Test[T])")
        let output: NimNode = processMacro(ast[1])
        var count_methods: int = 0
        var count_procedures: int = 0
        for elem in output[1][0][1]:
            if elem.kind == nnkMethodDef:
                count_methods += 1
            if elem.kind == nnkProcDef:
                count_procedures += 1
        assert count_methods == 0
        assert count_procedures == 6


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
        let output: NimNode = processMacro(ast[1], ast[2])
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

    block: # Check variables
        let ast: NimNode = parseExpr("""
        Class static MyClass:
            method test(s: MyClass) = echo "My Class"
        """)
        let output: NimNode = processMacro(ast[1], ast[2])
        assert output[0][0][2].kind == nnkObjectTy
        assert output[2].kind == nnkMethodDef
        assert output[2][0].kind == nnkIdent
        assert $output[2][0] == "test"
