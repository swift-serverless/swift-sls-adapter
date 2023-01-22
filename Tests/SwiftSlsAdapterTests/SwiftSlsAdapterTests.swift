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
import SwiftSlsAdapter
import XCTest
import Yams

final class SwiftSlsAdapterTests: XCTestCase {
    enum TestError: Error {
        case missingFixture
    }

    func fixture(name: String, type: String) throws -> Data {
        guard let fixtureUrl = Bundle.module.url(forResource: name, withExtension: type, subdirectory: "Fixtures") else {
            throw TestError.missingFixture
        }
        return try Data(contentsOf: fixtureUrl)
    }

    func testReadServerlessYml() throws {
        let serverlessYml = try fixture(name: "serverless", type: "yml")

        let decoder = YAMLDecoder()
        let serverlessConfig = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
        XCTAssertEqual(serverlessConfig.service, "swift-sprinter-rest-api")
        XCTAssertEqual(serverlessConfig.frameworkVersion, "3")
        XCTAssertEqual(serverlessConfig.configValidationMode, .warn)
        XCTAssertEqual(serverlessConfig.useDotenv, false)

        XCTAssertEqual(serverlessConfig.package?.individually, true)

        XCTAssertEqual(serverlessConfig.custom?.value, ["tableName": "products-table-${sls:stage}"])

        let provider = serverlessConfig.provider
        XCTAssertEqual(provider.name, .aws)
        XCTAssertEqual(provider.region, .eu_west_1)

        let httpAPI = try XCTUnwrap(provider.httpAPI)
        XCTAssertEqual(httpAPI.payload, "2.0")
        XCTAssertEqual(httpAPI.cors, true)

        XCTAssertEqual(provider.runtime, .providedAl2)
        XCTAssertEqual(provider.lambdaHashingVersion, "20201221")
        XCTAssertEqual(provider.architecture, .arm64)

        XCTAssertEqual(provider.environment?.value, ["PRODUCTS_TABLE_NAME": "${self:custom.tableName}"])

        let iam = try XCTUnwrap(provider.iam)

        var role: Role?
        if case .role(let value) = iam {
            role = value
        }

        XCTAssertEqual(role?.statements.count, 2)

        let statement1 = try XCTUnwrap(role?.statements.first)
        let actionExpectation1 = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        XCTAssertEqual(statement1.effect, "Allow")
        XCTAssertEqual(statement1.action, actionExpectation1)
        XCTAssertEqual(statement1.resource.value, "*")

        let statement2 = try XCTUnwrap(role?.statements.last)
        let actionExpectation2 = [
            "dynamodb:UpdateItem",
            "dynamodb:PutItem",
            "dynamodb:GetItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:DescribeTable"
        ]
        XCTAssertEqual(statement2.effect, "Allow")
        XCTAssertEqual(statement2.action, actionExpectation2)
        XCTAssertEqual(statement2.resource.value, [["Fn::GetAtt": ["ProductsTable", "Arn"]]])

        let layer = try XCTUnwrap(serverlessConfig.layers?["swift-lambda-runtime"])

        XCTAssertEqual(layer.path, "./build/swift-lambda-runtime")
        XCTAssertEqual(layer.name, "aws-swift-sprinter-lambda-runtime")
        XCTAssertEqual(layer.description, "AWS Lambda Custom Runtime for Swift-Sprinter")

        let patternsExpectation = ["!**/*", "build/Products"]

        let createProduct = try XCTUnwrap(serverlessConfig.functions?["createProduct"])
        XCTAssertEqual(createProduct.handler, "build/Products.create")
        XCTAssertEqual(createProduct.package?.individually, true)
        XCTAssertEqual(createProduct.package?.patterns, patternsExpectation)
        XCTAssertEqual(createProduct.memorySize, 256)
        XCTAssertEqual(createProduct.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(createProduct.description, "[${sls:stage}] Create Product")
        XCTAssertEqual(createProduct.events.first?.httpAPI?.path, "/products")
        XCTAssertEqual(createProduct.events.first?.httpAPI?.method, .post)

        let readProduct = try XCTUnwrap(serverlessConfig.functions?["readProduct"])
        XCTAssertEqual(readProduct.handler, "build/Products.read")
        XCTAssertEqual(readProduct.package?.individually, true)
        XCTAssertEqual(readProduct.package?.patterns, patternsExpectation)
        XCTAssertEqual(readProduct.memorySize, 256)
        XCTAssertEqual(readProduct.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(readProduct.description, "[${sls:stage}] Get Product")
        XCTAssertEqual(readProduct.events.first?.httpAPI?.path, "/products/{sku}")
        XCTAssertEqual(readProduct.events.first?.httpAPI?.method, .get)

        let updateProduct = try XCTUnwrap(serverlessConfig.functions?["updateProduct"])
        XCTAssertEqual(updateProduct.handler, "build/Products.update")
        XCTAssertEqual(updateProduct.package?.individually, true)
        XCTAssertEqual(updateProduct.package?.patterns, patternsExpectation)
        XCTAssertEqual(updateProduct.memorySize, 256)
        XCTAssertEqual(updateProduct.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(updateProduct.description, "[${sls:stage}] Update Product")
        XCTAssertEqual(updateProduct.events.first?.httpAPI?.path, "/products")
        XCTAssertEqual(updateProduct.events.first?.httpAPI?.method, .put)

        let deleteProduct = try XCTUnwrap(serverlessConfig.functions?["deleteProduct"])
        XCTAssertEqual(deleteProduct.handler, "build/Products.delete")
        XCTAssertEqual(deleteProduct.package?.individually, true)
        XCTAssertEqual(deleteProduct.package?.patterns, patternsExpectation)
        XCTAssertEqual(deleteProduct.memorySize, 256)
        XCTAssertEqual(deleteProduct.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(deleteProduct.description, "[${sls:stage}] Delete Product")
        XCTAssertEqual(deleteProduct.events.first?.httpAPI?.path, "/products/{sku}")
        XCTAssertEqual(deleteProduct.events.first?.httpAPI?.method, .delete)

        let listProducts = try XCTUnwrap(serverlessConfig.functions?["listProducts"])
        XCTAssertEqual(listProducts.handler, "build/Products.list")
        XCTAssertEqual(listProducts.package?.individually, true)
        XCTAssertEqual(listProducts.package?.patterns, patternsExpectation)
        XCTAssertEqual(listProducts.memorySize, 256)
        XCTAssertEqual(listProducts.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(listProducts.description, "[${sls:stage}] List Products")
        XCTAssertEqual(listProducts.events.first?.httpAPI?.path, "/products")
        XCTAssertEqual(listProducts.events.first?.httpAPI?.method, .get)

        let resources = try XCTUnwrap(serverlessConfig.resources?.dictionary?["Resources"])
        let productTable = try XCTUnwrap(resources.dictionary?["ProductsTable"])
        let productTableType = try XCTUnwrap(productTable.dictionary?["Type"])
        XCTAssertEqual(productTableType.string, "AWS::DynamoDB::Table")
        let productTableProperties = try XCTUnwrap(productTable.dictionary?["Properties"])
        XCTAssertEqual(productTableProperties.dictionary?["TableName"]?.string, "${self:custom.tableName}")
        XCTAssertEqual(productTableProperties.dictionary?["AttributeDefinitions"]?.value, [["AttributeName": "sku", "AttributeType": "S"]])
        XCTAssertEqual(productTableProperties.dictionary?["KeySchema"]?.value, [["AttributeName": "sku", "KeyType": "HASH"]])
        XCTAssertEqual(productTableProperties.dictionary?["BillingMode"]?.string, "PAY_PER_REQUEST")
    }

    func testReadWriteServerlessYml() throws {
        let serverlessYml = try fixture(name: "serverless", type: "yml")
        let decoder = YAMLDecoder()
        let serverlessConfig = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
        let encoder = YAMLEncoder()
        let content = try encoder.encode(serverlessConfig)
        let data = try XCTUnwrap(Data(content.utf8))
        let serverlessConfig2 = try decoder.decode(ServerlessConfig.self, from: data)
        XCTAssertEqual(serverlessConfig, serverlessConfig2)
    }

    func testInitServerlessYml() throws {
        let decoder = YAMLDecoder()
        let serverlessYml = try fixture(name: "serverless", type: "yml")
        let serverlessConfig2 = try decoder.decode(ServerlessConfig.self, from: serverlessYml)

        // Initialise ServerlessConfig
        let iam = Iam(
            role: Role(
                statements: [
                    Statement(
                        effect: "Allow",
                        action: [
                            "logs:CreateLogGroup",
                            "logs:CreateLogStream",
                            "logs:PutLogEvents"
                        ],
                        resource: try YAMLContent(with: "*")
                    ),
                    Statement(
                        effect: "Allow",
                        action: [
                            "dynamodb:UpdateItem",
                            "dynamodb:PutItem",
                            "dynamodb:GetItem",
                            "dynamodb:DeleteItem",
                            "dynamodb:Query",
                            "dynamodb:Scan",
                            "dynamodb:DescribeTable"
                        ],
                        resource: try YAMLContent(with: [["Fn::GetAtt": ["ProductsTable", "Arn"]]])
                    )
                ]))
        let environment = try YAMLContent(with: ["PRODUCTS_TABLE_NAME": "${self:custom.tableName}"])
        let provider = Provider(
            name: .aws,
            region: .eu_west_1,
            runtime: .providedAl2,
            environment: environment,
            lambdaHashingVersion: "20201221",
            architecture: .arm64,
            httpAPI: .init(payload: "2.0", cors: true),
            iam: iam
        )
        let custom = try YAMLContent(with: ["tableName": "products-table-${sls:stage}"])
        let layer = Layer(
            path: "./build/swift-lambda-runtime",
            name: "aws-swift-sprinter-lambda-runtime",
            description: "AWS Lambda Custom Runtime for Swift-Sprinter"
        )

        let package = Package(
            patterns: [
                "!**/*",
                "build/Products"
            ],
            individually: true
        )

        let layersRef = try YAMLContent(with: [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])

        let path = "/products"
        let keyedPath = "/products/{sku}"

        let createProduct = Function(
            handler: "build/Products.create",
            runtime: nil,
            memorySize: 256,
            description: "[${sls:stage}] Create Product",
            package: package,
            layers: layersRef,
            events: [.init(httpAPI: .init(path: path, method: .post))]
        )

        let readProduct = Function(
            handler: "build/Products.read",
            runtime: nil,
            memorySize: 256,
            description: "[${sls:stage}] Get Product",
            package: package,
            layers: layersRef,
            events: [.init(httpAPI: .init(path: keyedPath, method: .get))]
        )

        let updateProduct = Function(
            handler: "build/Products.update",
            runtime: nil,
            memorySize: 256,
            description: "[${sls:stage}] Update Product",
            package: package,
            layers: layersRef,
            events: [.init(httpAPI: .init(path: path, method: .put))]
        )

        let deleteProduct = Function(
            handler: "build/Products.delete",
            runtime: nil,
            memorySize: 256,
            description: "[${sls:stage}] Delete Product",
            package: package,
            layers: layersRef,
            events: [.init(httpAPI: .init(path: keyedPath, method: .delete))]
        )

        let listProducts = Function(
            handler: "build/Products.list",
            runtime: nil,
            memorySize: 256,
            description: "[${sls:stage}] List Products",
            package: package,
            layers: layersRef,
            events: [.init(httpAPI: .init(path: path, method: .get))]
        )

        let resource = Resource.dynamoDBResource(tableName: "${self:custom.tableName}", key: "sku")
        let resources = Resources.resources(with: ["ProductsTable": resource])

        let serverlessConfig = ServerlessConfig(
            service: "swift-sprinter-rest-api",
            provider: provider,
            package: .init(patterns: nil, individually: true, artifact: nil),
            custom: custom,
            layers: ["swift-lambda-runtime": layer],
            functions: [
                "createProduct": createProduct,
                "readProduct": readProduct,
                "updateProduct": updateProduct,
                "deleteProduct": deleteProduct,
                "listProducts": listProducts
            ],
            resources: try YAMLContent(with: resources)
        )

        XCTAssertEqual(serverlessConfig.service, serverlessConfig2.service)
        XCTAssertEqual(serverlessConfig.provider, serverlessConfig2.provider)
        XCTAssertEqual(serverlessConfig.provider.iam, serverlessConfig2.provider.iam)
        XCTAssertEqual(serverlessConfig.package, serverlessConfig2.package)
        XCTAssertEqual(serverlessConfig.custom, serverlessConfig2.custom)
        XCTAssertEqual(serverlessConfig.functions?["createProduct"], serverlessConfig2.functions?["createProduct"])
        XCTAssertEqual(serverlessConfig.functions?["readProduct"], serverlessConfig2.functions?["readProduct"])
        XCTAssertEqual(serverlessConfig.functions?["updateProduct"], serverlessConfig2.functions?["updateProduct"])
        XCTAssertEqual(serverlessConfig.functions?["deleteProduct"], serverlessConfig2.functions?["deleteProduct"])
        XCTAssertEqual(serverlessConfig.functions?["listProducts"], serverlessConfig2.functions?["listProducts"])
        XCTAssertEqual(serverlessConfig.custom, serverlessConfig2.custom)
        XCTAssertEqual(serverlessConfig.package, serverlessConfig2.package)
        XCTAssertEqual(serverlessConfig.resources, serverlessConfig2.resources)
    }
}
