// RUN: %empty-directory(%t)

// Baseline check: if the prebuilt cache path does not exist, everything should
// still work.
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk %S/Inputs -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s

// Baseline check: if the module is not in the prebuilt cache, build it
// normally.
// RUN: %empty-directory(%t/prebuilt-cache)
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk %S/Inputs -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s

// Do a manual prebuild, and see if it gets picked up.
// RUN: %empty-directory(%t/MCP)
// RUN: sed -e 's/FromInterface/FromPrebuilt/g' %S/Inputs/prebuilt-module-cache/Lib.swiftinterface | %target-swift-frontend -parse-stdlib -module-cache-path %t/MCP -emit-module-path %t/prebuilt-cache/Lib.swiftmodule - -module-name Lib
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk %S/Inputs -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-PREBUILT %s
// RUN: ls %t/MCP | not grep swiftmodule

// Try some variations on the detection that the search path is in the SDK:
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk %S/Inputs -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-PREBUILT %s
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk %S//Inputs -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-PREBUILT %s
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk %S/Inputs/prebuilt-module-cache -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-PREBUILT %s
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk / -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-PREBUILT %s

// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk %S/Inputs/p -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk %S/garbage-path -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk "" -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s

// What if the module is invalid?
// RUN: rm %t/prebuilt-cache/Lib.swiftmodule && touch %t/prebuilt-cache/Lib.swiftmodule
// RUN: not %target-swift-frontend -typecheck -enable-parseable-module-interface -parse-stdlib -module-cache-path %t/MCP -sdk %S/Inputs/ -I %S/Inputs/prebuilt-module-cache/ -prebuilt-module-cache-path %t/prebuilt-cache %s 2>&1 | %FileCheck -check-prefix=FROM-INTERFACE %s

import Lib

struct X {}
let _: X = Lib.testValue
// FROM-INTERFACE: [[@LINE-1]]:16: error: cannot convert value of type 'FromInterface' to specified type 'X'
// FROM-PREBUILT: [[@LINE-2]]:16: error: cannot convert value of type 'FromPrebuilt' to specified type 'X'
