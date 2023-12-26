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
import XCTest
import Yams

final class ServerlessHttpAPILambdaTests: XCTestCase {
    
    enum TestError: Error {
        case missingFixture
    }
    
    func fixture(name: String, type: String) throws -> Data {
        guard let fixtureUrl = Bundle.module.url(forResource: name, withExtension: type, subdirectory: "Fixtures") else {
            throw TestError.missingFixture
        }
        return try Data(contentsOf: fixtureUrl)
    }

    func test_ReadServerlessWebhook() throws {
        let serverlessYml = try fixture(name: "serverless_webhook", type: "yml")
        
        let decoder = YAMLDecoder()
        let serverlessConfig = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
        XCTAssertEqual(serverlessConfig.service, "swift-webhook")
        XCTAssertEqual(serverlessConfig.frameworkVersion, "3")
        XCTAssertEqual(serverlessConfig.configValidationMode, .warn)
        XCTAssertEqual(serverlessConfig.useDotenv, false)
        
        XCTAssertEqual(serverlessConfig.package?.individually, true)
        
        XCTAssertNil(serverlessConfig.custom)
        
        let provider = serverlessConfig.provider
        XCTAssertEqual(provider.name, .aws)
        XCTAssertEqual(provider.region, .us_east_1)
        
        let httpAPI = try XCTUnwrap(provider.httpAPI)
        XCTAssertEqual(httpAPI.payload, "2.0")
        XCTAssertEqual(httpAPI.cors, false)
        
        XCTAssertEqual(provider.runtime, .providedAl2)
        XCTAssertEqual(provider.architecture, .arm64)
        
        let iam = try XCTUnwrap(provider.iam)
        
        var role: Role?
        if case .role(let value) = iam {
            role = value
        }
        
        XCTAssertEqual(role?.statements.count, 1)
        
        let statement1 = try XCTUnwrap(role?.statements.first)
        let actionExpectation1 = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        XCTAssertEqual(statement1.effect, "Allow")
        XCTAssertEqual(statement1.action, actionExpectation1)
        XCTAssertEqual(statement1.resource.value, "*")
        
        let postWebHook = try XCTUnwrap(serverlessConfig.functions?["postWebHook"])
        XCTAssertEqual(postWebHook.handler, "post-webhook")
        XCTAssertEqual(postWebHook.memorySize, 256)
        XCTAssertEqual(postWebHook.description, "[${sls:stage}] post /webhook")
        let artifact = postWebHook.package?.artifact
        XCTAssertEqual(artifact, "build/WebHook/WebHook.zip")
        XCTAssertEqual(postWebHook.events.first?.httpAPI?.path, "/webhook")
        XCTAssertEqual(postWebHook.events.first?.httpAPI?.method, .post)
        
        let getWebHook = try XCTUnwrap(serverlessConfig.functions?["getWebHook"])
        XCTAssertEqual(getWebHook.handler, "get-webhook")
        XCTAssertEqual(getWebHook.memorySize, 256)
        XCTAssertEqual(getWebHook.description, "[${sls:stage}] get /webhook")
        let artifact2 = getWebHook.package?.artifact
        XCTAssertEqual(artifact2, "build/WebHook/WebHook.zip")
        XCTAssertEqual(getWebHook.events.first?.httpAPI?.path, "/webhook")
        XCTAssertEqual(getWebHook.events.first?.httpAPI?.method, .get)
        
        let githubWebHook = try XCTUnwrap(serverlessConfig.functions?["githubWebHook"])
        XCTAssertEqual(githubWebHook.handler, "github-webhook")
        XCTAssertEqual(githubWebHook.memorySize, 256)
        XCTAssertEqual(githubWebHook.description, "[${sls:stage}] post /github-webhook")
        let artifact3 = githubWebHook.package?.artifact
        XCTAssertEqual(artifact3, "build/GitHubWebHook/GitHubWebHook.zip")
        let environment = githubWebHook.environment?.dictionary
        let webBookSecret = try XCTUnwrap(environment?["WEBHOOK_SECRET"]?.string)
        XCTAssertEqual(webBookSecret, "${ssm:/dev/swift-webhook/webhook_secret}")
        XCTAssertEqual(githubWebHook.events.first?.httpAPI?.path, "/github-webhook")
        XCTAssertEqual(githubWebHook.events.first?.httpAPI?.method, .post)
    }
    
    func test_WriteServerlessWebook() throws {
        let serverlessYml = try fixture(name: "serverless_webhook", type: "yml")
        let decoder = YAMLDecoder()
        let serverlessConfig = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
        let encoder = YAMLEncoder()
        let content = try encoder.encode(serverlessConfig)
        let data = try XCTUnwrap(content.data(using: .utf8))
        let serverlessConfig2 = try decoder.decode(ServerlessConfig.self, from: data)
        XCTAssertEqual(serverlessConfig, serverlessConfig2)
    }
    
    func test_InitServerlessYml() throws {
        let decoder = YAMLDecoder()
        let serverlessYml = try fixture(name: "serverless_webhook", type: "yml")
        let serverlessConfig2 = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
        
        let service: String = "swift-webhook"
        let region: Region = .us_east_1
        let runtime: Runtime = .providedAl2
        let architecture: Architecture = .arm64
        let memorySize: Int = 256
        
        let lambdasParams: [HttpAPILambdaParams] = [
            HttpAPILambdaParams(
                name: "postWebHook",
                handler: "post-webhook",
                event: .init(path: "/webhook", method: .post),
                environment: nil,
                artifact: "build/WebHook/WebHook.zip"
            ),
            HttpAPILambdaParams(
                name: "getWebHook",
                handler: "get-webhook",
                event: .init(path: "/webhook", method: .get),
                environment: nil,
                artifact: "build/WebHook/WebHook.zip"
            ),
            HttpAPILambdaParams(
                name: "githubWebHook",
                handler: "github-webhook",
                event: .init(path: "/github-webhook", method: .post),
                environment: YAMLContent.dictionary(
                    ["WEBHOOK_SECRET": .string("${ssm:/dev/swift-webhook/webhook_secret}")]
                ),
                artifact: "build/GitHubWebHook/GitHubWebHook.zip"
            )
        ]
        let serverlessConfig = try ServerlessConfig.webhookLambdaAPI(
            service: service,
            region: region,
            runtime: runtime,
            architecture: architecture,
            memorySize: memorySize,
            lambdasParams: lambdasParams
        )
        XCTAssertEqual(serverlessConfig, serverlessConfig2)
    }
}
