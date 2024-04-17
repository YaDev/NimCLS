import nimcls
import ./mock

proc test_classes_signature_injection() =
    ### Setup ###
    var aa = SAA()
    var ab = SAB()
    var ac = SAC()



    ### Test signature ###
    proc test_signature() =
        assert aa.type.signature is int
        assert ab.type.signature is int
        assert ac.type.signature is int

        assert aa.type.signature >= 99_999
        assert ab.type.signature >= 99_999
        assert ac.type.signature >= 99_999

        assert aa.type.signature == SAA.signature
        assert ab.type.signature == SAB.signature
        assert ac.type.signature == SAC.signature

        assert aa.type.signature != SAB.signature
        assert ab.type.signature != SAC.signature
        assert ac.type.signature != SAA.signature

    test_signature()



    ### Test check existing injections using isInjectable ###
    proc test_pre_injection() =
        assert not isInjectable(SAA)
        assert not isInjectable(SAB)
        assert not isInjectable(SAC)
        assert not isInjectable(Loader)
        assert not isInjectable(ChildLoaderA)
        assert not isInjectable(ChildLoaderB)

    test_pre_injection()



    ### Test Adding injections and injectors  ###
    proc test_addSingleton_addInjector() =
        addSingleton(aa)
        assert isInjectable(SAA)
        assert isSingleton(SAA)
        addInjector(
            proc() : SAB =
                return SAB()
        )
        assert isInjectable(SAB)
        assert not isSingleton(SAB)

        let procLoaderA = proc(): ChildLoaderA = ChildLoaderA()
        addInjector(procLoaderA)
        assert isInjectable(ChildLoaderA)
        assert not isSingleton(ChildLoaderA)


    test_addSingleton_addInjector()



    ### Duplicate Injection ###
    proc test_duplicate_injection() =
            var passed = false
            ### SAA was added using addSingleton ###
            try:
                proc getSAA(): SAA = result = SAA()
                addInjector(getSAA)
            except InjectionError:
                passed = true
            assert passed

            passed = false

            ### SAB was added using addInjector ###
            try:
                addSingleton(ab)
            except InjectionError:
                passed = true
            assert passed

            passed = false

            ### ChildLoaderA was added using addInjector ###
            try:
                let loaderB = ChildLoaderA()
                addSingleton(loaderB)
            except InjectionError:
                passed = true
            assert passed


    test_duplicate_injection()



    ### Test getting and updating the Injection  ###
    proc test_inject() =
        ## SAA ##
        let saa: SAA = SAA(number: -100)
        var saaInjection: SAA = inject(SAA)
        assert saaInjection.number == 1
        assert saa.number != saaInjection.number
        addSingleton(saa)
        saaInjection = inject(SAA)
        assert saaInjection.number != 1
        assert saa.number == saaInjection.number

        # SAB ##
        proc createSAB(): SAB =
            let abx = SAB(number: 123)
            return abx
        
        let sabSample = createSAB()

        var sabInjection = inject(SAB)
        assert sabInjection.number == 2
        assert sabSample.number != sabInjection.number

        addInjector(createSAB)
        sabInjection = inject(SAB)
        assert sabInjection.number != 2
        assert sabSample.number == sabInjection.number

        ## ChildLoaderA ##
        let injChildA = inject(ChildLoaderA)
        let loaderC = ChildLoaderA()
        assert injChildA.code == loaderC.code

    test_inject()


    ### Test getting as a parameters  ###
    proc test_injection_param(objSAA: SAA = inject(SAA), objSAB: SAB = inject(SAB))  =
        var injectedSAA = objSAA
        var injectedSAB = objSAB
        assert injectedSAA.type is ClassStaticObj
        assert injectedSAB.type is ClassStaticObj
        assert injectedSAA.type is SAA
        assert injectedSAB.type is SAB
        assert injectedSAA.getClassProperties.len == 1
        assert injectedSAB.getClassProperties.len == 1
        assert injectedSAA.getClassCalls.len == 5
        assert injectedSAB.getClassCalls.len == 5
        assert injectedSAA.number == -100
        assert injectedSAB.number == 123
        assert not isInjectable(SAC)

    test_injection_param()



    ### Test adding and getting non existing injections  ###
    proc test_injection_exceptions() = 
        var casuedError = false

        proc test_inject_exceptions() =
            ## Injection or injector does not exist ##
            try:
                let obj = inject(SAC)
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false

            ## Inject ClassStaticObj ##
            try:
                let obj = inject(ClassStaticObj)
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false
        
        test_inject_exceptions()



        proc test_addInjector_exceptions() =
            ## addInjector 1 ClassStaticObj ##
            try:
                addInjector(
                    proc() : ClassStaticObj =
                        return SAA()
                )
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false


        test_addInjector_exceptions()



        proc test_addSingleton_exceptions() =
            ## addSingleton 1 ClassStaticObj ##
            try:
                let obj = ClassStaticObj()
                addSingleton(obj)
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false

        test_addSingleton_exceptions()




        ## Checking isInjectable using ClassStaticObj ##
        proc test_isInjectable_isSingleton_exceptions() =
            try:
                let val = isInjectable(ClassStaticObj)
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false

            ## Checking isSingleton using ClassObj ##
            try:
                let val = isSingleton(ClassStaticObj)
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false
        
        test_isInjectable_isSingleton_exceptions()




    test_injection_exceptions()

    ### Test reseting injections tables  ###
    proc test_resetInjectTbl() =
        assert isInjectable(SAA)
        assert isInjectable(SAB)
        assert isInjectable(ChildLoaderA)
        resetInjectTbl()
        assert not isInjectable(SAA)
        assert not isInjectable(SAB)
        assert not isInjectable(ChildLoaderA)
        

    test_resetInjectTbl()


test_classes_signature_injection()