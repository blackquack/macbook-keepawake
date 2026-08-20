import Foundation
import Shared

let runner = PMSetRunner()
_ = try? runner.setSleepOverride(enabled: false)

let service = HelperService(runner: runner)
let listener = NSXPCListener(machServiceName: AppConstants.helperMachServiceName)
listener.delegate = service
listener.resume()

RunLoop.current.run()
