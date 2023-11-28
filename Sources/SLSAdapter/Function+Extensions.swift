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

public extension YAMLContent {
    static func buildLayers(layerName: String) throws -> YAMLContent {
        let layerInternalName =  layerName.prefix(1).capitalized + layerName.dropFirst(1).replacingOccurrences(of: "-", with: "Dash").appending("LambdaLayer")
        return try YAMLContent(with: [["Ref": layerInternalName]])
    }
    
    static func buildJWTAuthorizer(identitySource: String = "$request.header.Authorization",
                                   issuerUrl: String,
                                   audience: [String]) -> YAMLContent {
        return .dictionary(
            ["type": .string("jwt"),
             "identitySource": .string(identitySource),
             "issuerUrl": .string(issuerUrl),
             "audience": .array(audience.compactMap { .string($0)} )])
    }
    
    static func buildCustomAuthorizer(name: String,
                                      type: String = "request",
                                      functionName: String,
                                      payloadVersion: String = "2.0",
                                      identitySource: [String],
                                      resultTtlInSeconds: Int = 0,
                                      enableSimpleResponses: Bool = true) -> YAMLContent {
        return .dictionary(
            ["name": .string(name),
             "type": .string(type),
             "functionName": .string(functionName),
             "payloadVersion": .string(payloadVersion),
             "identitySource": .array(identitySource.compactMap { .string($0) }),
             "resultTtlInSeconds": .string("\(resultTtlInSeconds)"),
             "enableSimpleResponses": .string("\(enableSimpleResponses)")
            ])
    }
}

public extension Function {
    static func httpApiLambda(
        handler: String,
        description: String?,
        memorySize: Int?,
        runtime: Runtime?,
        package: Package,
        layerName: String,
        event: EventHTTPAPI
    ) throws -> Function {
        let layersRef = try YAMLContent.buildLayers(layerName: layerName)
        return Function(
            handler: handler,
            runtime: runtime,
            memorySize: memorySize,
            description: description ?? "[${sls:stage}] \(event.method) \(event.path)",
            package: package,
            layers: layersRef,
            events: [.init(httpAPI: event)]
        )
    }
    
    static func httpApiLambda(
        handler: String,
        description: String?,
        memorySize: Int?,
        runtime: Runtime?,
        package: Package?,
        event: EventHTTPAPI
    ) throws -> Function {
        Function(
            handler: handler,
            runtime: runtime,
            memorySize: memorySize,
            description: description ?? "[${sls:stage}] \(event.method) \(event.path)",
            package: package,
            layers: nil,
            events: [.init(httpAPI: event)]
        )
    }
    
    static func httpApiLambda(
        handler: String,
        description: String?,
        memorySize: Int?,
        environment: YAMLContent?,
        runtime: Runtime?,
        package: Package?,
        event: EventHTTPAPI
    ) throws -> Function {
        Function(
            handler: handler,
            runtime: runtime,
            memorySize: memorySize,
            environment: environment,
            description: description ?? "[${sls:stage}] \(event.method) \(event.path)",
            package: package,
            layers: nil,
            events: [.init(httpAPI: event)]
        )
    }
}
