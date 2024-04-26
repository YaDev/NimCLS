import nimcls
import ./mock

proc test_classes_signature_injection() =
    ### Setup ###
    let aa = AA()
    let ab = AB()
    let ac = AC()



    ### Test signature ###
    proc test_signature() =
        assert aa.type.signature is int
        assert ab.type.signature is int
        assert ac.type.signature is int

        assert aa.type.signature >= 99_999
        assert ab.type.signature >= 99_999
        assert ac.type.signature >= 99_999

        assert aa.type.signature == AA.signature
        assert ab.type.signature == AB.signature
        assert ac.type.signature == AC.signature

        assert aa.type.signature != AB.signature
        assert ab.type.signature != AC.signature
        assert ac.type.signature != AA.signature

    test_signature()



    ### Test check existing injections using isInjectable ###
    proc test_pre_injection() =
        assert not isInjectable(AA)
        assert not isInjectable(AB)
        assert not isInjectable(AC)
        assert not isInjectable(Service)
        assert not isInjectable(ChildServiceA)
        assert not isInjectable(ChildServiceB)

    test_pre_injection()



    ### Test Adding injections and injectors  ###
    proc test_addSingleton_addInjector() =
        addSingleton(aa)
        assert isInjectable(AA)
        assert isSingleton(AA)
        addInjector(
            proc() : AB =
                let inAB = AB()
                inAB.number = 4
                return inAB
        )
        assert isInjectable(AB)
        assert not isSingleton(AB)

        let childServiceB = ChildServiceB()
        addSingleton(Service, childServiceB)
        assert isInjectable(Service)
        assert isSingleton(Service)

        let procChildC = proc(): ChildServiceC = ChildServiceC()
        addInjector(ChildServiceB, procChildC)
        assert isInjectable(ChildServiceB)
        assert not isSingleton(ChildServiceB)


    test_addSingleton_addInjector()



    ### Duplicate Injection ###
    proc test_duplicate_injection() =
            var passed = false
            ### AA was added using addSingleton ###
            try:
                proc getAA(): AA = result = AA()
                addInjector(getAA)
            except InjectionError:
                passed = true
            assert passed

            passed = false

            ### AB was added using addInjector ###
            try:
                addSingleton(ab)
            except InjectionError:
                passed = true
            assert passed

            passed = false

            ### Service was added using addSingleton ###
            try:
                proc getService(): Service = result = Service()
                addInjector(Service, getService)
            except InjectionError:
                passed = true
            assert passed

            passed = false

            ### ChildServiceB was added using addInjector ###
            try:
                let childServiceB = ChildServiceB()
                addSingleton(ChildServiceB, childServiceB)
            except InjectionError:
                passed = true
            assert passed


    test_duplicate_injection()



    ### Test getting and updating the Injection  ###
    proc test_inject() =
        ## AA ##
        let aax: AA = AA()
        aax.number = -100
        var aaInjection: AA = inject(AA)
        assert aaInjection.number == 1
        assert aax.number != aaInjection.number
        addSingleton(aax)
        aaInjection = inject(AA)
        assert aaInjection.number != 1
        assert aax.number == aaInjection.number

        ## AB ##
        proc createAB(): AB =
            let abx = AB()
            abx.number = 123
            return abx

        let abSample: AB = createAB()
        var abInjection = inject(AB)
        assert abInjection.number == 4
        assert abSample.number != abInjection.number
        assert abSample.number == 123
        addInjector(createAB)
        abInjection = inject(AB)
        assert abInjection.number != 4
        assert abSample.number == abInjection.number

        ## Service ##
        let injService = inject(Service)
        let childServiceB = ChildServiceB()
        assert injService.getURL == childServiceB.getURL

        ## ChildServiceB ##
        let injChildB = inject(ChildServiceB)
        let childServiceC = ChildServiceC()
        assert injChildB.getURL == childServiceC.getURL

    test_inject()


    ### Test getting as a parameters  ###
    proc test_injection_param(objAA: AA = inject(AA), objAB: AB = inject(AB))  =
        let injectedAA = objAA
        let injectedAB = objAB
        assert injectedAA.type is ref ClassObj
        assert injectedAB.type is ref ClassObj
        assert injectedAA.type is AA
        assert injectedAB.type is AB
        assert injectedAA.getClassProperties.len == 1
        assert injectedAB.getClassProperties.len == 1
        assert injectedAA.number == -100
        assert injectedAB.number == 123
        assert not isInjectable(AC)

    test_injection_param()



    ### Test adding and getting non existing injections  ###
    proc test_injection_exceptions() = 
        var casuedError = false

        proc test_inject_exceptions() =
            ## Injection or injector does not exist ##
            try:
                let obj = inject(AC)
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false

        test_inject_exceptions()



        proc test_addInjector_exceptions() =

            ## addInjector 2 not a subclass ##
            try:
                addInjector(AB,
                    proc() : AA =
                        return AA()
                )
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false


            ## addInjector 2 not a subclass ##
            try:
                addInjector(ChildServiceA,
                    proc() : Service =
                        return Service()
                )
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false

        test_addInjector_exceptions()



        proc test_addSingleton_exceptions() =

            ## addSingleton 2 not a subclass ##
            try:
                let obj = AA()
                addSingleton(AB, obj)
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false


            ## addSingleton 2 not a subclass ##
            try:
                let obj = Service()
                addSingleton(ChildServiceA, obj)
            except InjectionError:
                casuedError = true
            
            assert casuedError
            casuedError = false


        test_addSingleton_exceptions()




    test_injection_exceptions()

    ### Test reseting injections tables  ###
    proc test_resetInjectTbl() =
        assert isInjectable(AA)
        assert isInjectable(AB)
        assert isInjectable(Service)
        assert isInjectable(ChildServiceB)
        resetInjectTbl()
        assert not isInjectable(AA)
        assert not isInjectable(AB)
        assert not isInjectable(Service)
        assert not isInjectable(ChildServiceB)
        

    test_resetInjectTbl()


test_classes_signature_injection()