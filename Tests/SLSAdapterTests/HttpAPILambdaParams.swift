/*
 Copyright 2023 (c) Andrea Scuderi - https://github.com/swift-sprinter
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import SLSAdapter
import Yams

public struct HttpAPILambdaParams {
    public let name: String
    public let handler: String
    public let event: EventHTTPAPI
    public let environment: YAMLContent?
    public let artifact: String
    
    public init(name: String, handler: String, event: EventHTTPAPI, environment: YAMLContent?, artifact: String) {
        self.name = name
        self.handler = handler
        self.event = event
        self.environment = environment
        self.artifact = artifact
    }
}

public extension Function {
    static func httpAPILambda(params: HttpAPILambdaParams, memorySize: Int?) throws -> Function {
        try .httpApiLambda(
            handler: params.handler,
            description: nil,
            memorySize: memorySize,
            environment: params.environment,
            runtime: nil,
            package: .init(patterns: nil,
                           individually: nil,
                           artifact: params.artifact),
            event: params.event
        )
    }
}

extension Array where Element == HttpAPILambdaParams {
    func buildFunctions(memorySize: Int) throws -> [String: Function] {
        var functions: [String: Function] = [:]
        for lambdasParam in self {
            functions[lambdasParam.name] = try Function.httpAPILambda(params: lambdasParam, memorySize: memorySize)
        }
        return functions
    }
}
