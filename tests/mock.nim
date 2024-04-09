import nimcls

const url1*: string = "http://wiki.com"
const url2*: string = "https://google.com"
const url3*: string = "https://x.com"
const url4*: string = "https://z.com"

Class *Service:
    var url: string
    method init*(self: Service, link: string = url1) {.base.} =
        self.url = link
    method getURL*(self: Service): string  {.base.} =
        return self.url
        
Class ChildServiceA*(Service):
    var port: int
    method init*(self: ChildServiceA, port: int) =
        procCall super(self).init(url2)
        self.port = port
    method getPort*(self: ChildServiceA): int {.base.} =
        return self.port
    method connect*(self: ChildServiceA) {.base.} =
        echo "Connected"

Class ChildServiceB*(Service):
    var port: int
    var key*: string
    method init*(self: ChildServiceB, port: int, key: string) =
        procCall self.super.init(url3)
        self.port = port
        self.key = key
    method getPort*(self: ChildServiceB): int =
        return self.port
    method getURL*(self: ChildServiceB): string =
        return url4
    method callParentURL*(self: ChildServiceB): string  {.base.} =
        return procCall self.super.getURL
    method callParentInit*(self: ChildServiceB) {.base.} =
        procCall self.super.init(url2)

Class ChildServiceC*(ChildServiceB):
    method getKey(self: ChildServiceC) : string {.base.} =
        return self.key
    method getURL*(self: ChildServiceC): string =
        return url1

Class *AA:
    var number*: int = 1
Class *AB:
    var number*: int = 2
Class *AC:
    var number*: int = 3