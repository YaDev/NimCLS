import ../src/nimcls

Class IService:
    method run(self: IService) {.base.} = raise newException(Exception, "Not implemented")

Class ServiceImpl(IService):
    method run(self: ServiceImpl)  = 
        echo "=== Service ==="

Class Controller:
    var service: IService
    method init(self: Controller, service: IService = inject(IService)) {.base.} =
        self.service = service
    method startService(self: Controller) {.base} =
        self.service.run

proc setup() =
    let service: ServiceImpl = ServiceImpl()
    addSingleton(IService, service)

    
    
setup()
let controller = Controller()
controller.init
controller.startService