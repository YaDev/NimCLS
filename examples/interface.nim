import ../src/nimcls


Interface IRunner:
    method run(self: IRunner)
    method getFilePath(self: IRunner): string
    method isRunning(self: IRunner): bool
    method notImplemented(self: IRunner)

Class RunnerImpl(IRunner):
    var running: bool = false
    method run(self: RunnerImpl) = 
        echo "Running"
        self.running = true

    method getFilePath(self: RunnerImpl): string =
        return "/home/user/file"

    method isRunning(self: RunnerImpl): bool =
        return self.running

let runner: IRunner = RunnerImpl()
runner.run
echo "Is it Running: " & $runner.isRunning
echo "File path: " & runner.getFilePath
try:
    runner.notImplemented
except Exception:
    echo "Exception: The method `notImplemented` has not been implemented"