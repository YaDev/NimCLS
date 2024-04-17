import ../src/nimcls
import times

Class static Loader:
    var file: string
    method load(self: Loader) {.base.} =
        echo "Loading: " & self.file

Class Logger:
    var timeStamp: int
    method log(self: Logger) {.base.} =
        echo "Logger time: " & $self.timeStamp

Class Handler:
    method run(self: Handler, loader: Loader = inject(Loader), logger: Logger = inject(Logger)) {.base.} =
        loader.load
        logger.log
        echo "=== Running Handler ==="
        echo "=== Finished ==="

proc setup() =
    let myLoader = Loader(file: "/tmp/test.txt")

    addSingleton(myLoader)
    addInjector(
        proc() : Logger =
            let logger = Logger()
            logger.timeStamp = getTime().nanosecond
            return logger
    )
    
setup()
let handler = Handler()
handler.run
