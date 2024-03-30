/*
 Copyright 2023 (c) Andrea Scuderi - https://github.com/swift-serverless
 
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
    
    func test_ReadServerlessYml() throws {
        let serverlessYml = try fixture(name: "serverless", type: "yml")
        
        let decoder = YAMLDecoder()
        let serverlessConfig = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
        XCTAssertEqual(serverlessConfig.service, "swift-serverless-rest-api")
        XCTAssertEqual(serverlessConfig.frameworkVersion, "3")
        XCTAssertEqual(serverlessConfig.configValidationMode, .warn)
        XCTAssertEqual(serverlessConfig.useDotenv, false)
        
        XCTAssertEqual(serverlessConfig.package?.individually, true)
        
        XCTAssertEqual(serverlessConfig.custom?.value, ["tableName": "products-table-${sls:stage}",
                                                        "keyName": "sku"])
        
        let provider = serverlessConfig.provider
        XCTAssertEqual(provider.name, .aws)
        XCTAssertEqual(provider.region, .eu_west_1)
        
        let httpAPI = try XCTUnwrap(provider.httpAPI)
        XCTAssertEqual(httpAPI.payload, "2.0")
        XCTAssertEqual(httpAPI.cors, true)
        
        XCTAssertEqual(provider.runtime, .providedAl2)
        XCTAssertEqual(provider.architecture, .arm64)
        
        XCTAssertEqual(provider.environment?.value, ["DYNAMO_DB_TABLE_NAME": "${self:custom.tableName}",
                                                     "DYNAMO_DB_KEY": "${self:custom.keyName}"])
        
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
        XCTAssertEqual(layer.name, "aws-swift-serverless-lambda-runtime")
        XCTAssertEqual(layer.description, "AWS Lambda Custom Runtime for swift-serverless")
        
        let patternsExpectation = ["!**/*", "build/Products"]
        
        let createProduct = try XCTUnwrap(serverlessConfig.functions?["createProducts"])
        XCTAssertEqual(createProduct.handler, "build/Products.create")
        XCTAssertEqual(createProduct.package?.individually, true)
        XCTAssertEqual(createProduct.package?.patterns, patternsExpectation)
        XCTAssertEqual(createProduct.memorySize, 256)
        XCTAssertEqual(createProduct.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(createProduct.description, "[${sls:stage}] post /products")
        XCTAssertEqual(createProduct.events.first?.httpAPI?.path, "/products")
        XCTAssertEqual(createProduct.events.first?.httpAPI?.method, .post)
        
        let readProduct = try XCTUnwrap(serverlessConfig.functions?["readProducts"])
        XCTAssertEqual(readProduct.handler, "build/Products.read")
        XCTAssertEqual(readProduct.package?.individually, true)
        XCTAssertEqual(readProduct.package?.patterns, patternsExpectation)
        XCTAssertEqual(readProduct.memorySize, 256)
        XCTAssertEqual(readProduct.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(readProduct.description, "[${sls:stage}] get /products/{sku}")
        XCTAssertEqual(readProduct.events.first?.httpAPI?.path, "/products/{sku}")
        XCTAssertEqual(readProduct.events.first?.httpAPI?.method, .get)
        
        let updateProduct = try XCTUnwrap(serverlessConfig.functions?["updateProducts"])
        XCTAssertEqual(updateProduct.handler, "build/Products.update")
        XCTAssertEqual(updateProduct.package?.individually, true)
        XCTAssertEqual(updateProduct.package?.patterns, patternsExpectation)
        XCTAssertEqual(updateProduct.memorySize, 256)
        XCTAssertEqual(updateProduct.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(updateProduct.description, "[${sls:stage}] put /products")
        XCTAssertEqual(updateProduct.events.first?.httpAPI?.path, "/products")
        XCTAssertEqual(updateProduct.events.first?.httpAPI?.method, .put)
        
        let deleteProduct = try XCTUnwrap(serverlessConfig.functions?["deleteProducts"])
        XCTAssertEqual(deleteProduct.handler, "build/Products.delete")
        XCTAssertEqual(deleteProduct.package?.individually, true)
        XCTAssertEqual(deleteProduct.package?.patterns, patternsExpectation)
        XCTAssertEqual(deleteProduct.memorySize, 256)
        XCTAssertEqual(deleteProduct.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(deleteProduct.description, "[${sls:stage}] delete /products/{sku}")
        XCTAssertEqual(deleteProduct.events.first?.httpAPI?.path, "/products/{sku}")
        XCTAssertEqual(deleteProduct.events.first?.httpAPI?.method, .delete)
        
        let listProducts = try XCTUnwrap(serverlessConfig.functions?["listProducts"])
        XCTAssertEqual(listProducts.handler, "build/Products.list")
        XCTAssertEqual(listProducts.package?.individually, true)
        XCTAssertEqual(listProducts.package?.patterns, patternsExpectation)
        XCTAssertEqual(listProducts.memorySize, 256)
        XCTAssertEqual(listProducts.layers?.value, [["Ref": "SwiftDashlambdaDashruntimeLambdaLayer"]])
        XCTAssertEqual(listProducts.description, "[${sls:stage}] get /products")
        XCTAssertEqual(listProducts.events.first?.httpAPI?.path, "/products")
        XCTAssertEqual(listProducts.events.first?.httpAPI?.method, .get)
        
        let resources = try XCTUnwrap(serverlessConfig.resources?.dictionary?["Resources"])
        let productTable = try XCTUnwrap(resources.dictionary?["ProductsTable"])
        let productTableType = try XCTUnwrap(productTable.dictionary?["Type"])
        XCTAssertEqual(productTableType.string, "AWS::DynamoDB::Table")
        let productTableProperties = try XCTUnwrap(productTable.dictionary?["Properties"])
        XCTAssertEqual(productTableProperties.dictionary?["TableName"]?.string, "${self:custom.tableName}")
        XCTAssertEqual(productTableProperties.dictionary?["AttributeDefinitions"]?.value, [["AttributeName": "${self:custom.keyName}", "AttributeType": "S"]])
        XCTAssertEqual(productTableProperties.dictionary?["KeySchema"]?.value, [["AttributeName": "${self:custom.keyName}", "KeyType": "HASH"]])
        XCTAssertEqual(productTableProperties.dictionary?["BillingMode"]?.string, "PAY_PER_REQUEST")
    }
    
    func test_ReadWriteServerlessYml() throws {
        let serverlessYml = try fixture(name: "serverless", type: "yml")
        let decoder = YAMLDecoder()
        let serverlessConfig = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
        let encoder = YAMLEncoder()
        let content = try encoder.encode(serverlessConfig)
        let data = try XCTUnwrap(content.data(using: .utf8))
        let serverlessConfig2 = try decoder.decode(ServerlessConfig.self, from: data)
        XCTAssertEqual(serverlessConfig, serverlessConfig2)
    }
    
    struct Endpoint {
        let handler: String
        let method: HTTPMethod
        let path: String
    }
    
    func test_InitServerlessYml() throws {
        let decoder = YAMLDecoder()
        let serverlessYml = try fixture(name: "serverless", type: "yml")
        let serverlessConfig2 = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
       
        let serverlessConfig = try ServerlessConfig.dynamoDBLambdaAPIWithLayer(
            service: "swift-serverless-rest-api",
            dynamoDBKey: "sku",
            dynamoDBTableNamePrefix: "products",
            httpAPIPath: "/products",
            region: .eu_west_1,
            runtime: .providedAl2,
            architecture: .arm64,
            memorySize: 256,
            executable: "Products",
            layerName: "aws-swift-serverless-lambda-runtime",
            layerDescription: "AWS Lambda Custom Runtime for swift-serverless",
            layerPath: "./build/swift-lambda-runtime",
            buildPath: "build"
        )
        
        XCTAssertEqual(serverlessConfig.service, serverlessConfig2.service)
        XCTAssertEqual(serverlessConfig.provider, serverlessConfig2.provider)
        XCTAssertEqual(serverlessConfig.provider.iam, serverlessConfig2.provider.iam)
        XCTAssertEqual(serverlessConfig.package, serverlessConfig2.package)
        XCTAssertEqual(serverlessConfig.custom, serverlessConfig2.custom)
        XCTAssertEqual(serverlessConfig.functions?["createProducts"], serverlessConfig2.functions?["createProducts"])
        XCTAssertEqual(serverlessConfig.functions?["readProducts"], serverlessConfig2.functions?["readProducts"])
        XCTAssertEqual(serverlessConfig.functions?["updateProducts"], serverlessConfig2.functions?["updateProducts"])
        XCTAssertEqual(serverlessConfig.functions?["deleteProducts"], serverlessConfig2.functions?["deleteProducts"])
        XCTAssertEqual(serverlessConfig.functions?["listProducts"], serverlessConfig2.functions?["listProducts"])
        XCTAssertEqual(serverlessConfig.custom, serverlessConfig2.custom)
        XCTAssertEqual(serverlessConfig.package, serverlessConfig2.package)
        XCTAssertEqual(serverlessConfig.resources, serverlessConfig2.resources)
    }
    
    func test_InitServerlessNolLayerYml() throws {
        let decoder = YAMLDecoder()
        let serverlessYml = try fixture(name: "serverless_no_layer", type: "yml")
        let serverlessConfig2 = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
        
        let serverlessConfig = try ServerlessConfig.dynamoDBLambdaAPI(
            service: "swift-serverless-rest-api",
            dynamoDBKey: "sku",
            dynamoDBTableNamePrefix: "products",
            httpAPIPath: "/products",
            region: .eu_west_1,
            runtime: .providedAl2,
            architecture: .arm64,
            memorySize: 256,
            executable: "Products",
            artifact: "build/Products/Products.zip"
        )
        
        XCTAssertEqual(serverlessConfig.service, serverlessConfig2.service)
        XCTAssertEqual(serverlessConfig.provider, serverlessConfig2.provider)
        XCTAssertEqual(serverlessConfig.provider.iam, serverlessConfig2.provider.iam)
        XCTAssertEqual(serverlessConfig.custom, serverlessConfig2.custom)
        XCTAssertEqual(serverlessConfig.package, serverlessConfig2.package)
        XCTAssertEqual(serverlessConfig.functions?["createProducts"], serverlessConfig2.functions?["createProducts"])
        XCTAssertEqual(serverlessConfig.functions?["readProducts"], serverlessConfig2.functions?["readProducts"])
        XCTAssertEqual(serverlessConfig.functions?["updateProducts"], serverlessConfig2.functions?["updateProducts"])
        XCTAssertEqual(serverlessConfig.functions?["deleteProducts"], serverlessConfig2.functions?["deleteProducts"])
        XCTAssertEqual(serverlessConfig.functions?["listProducts"], serverlessConfig2.functions?["listProducts"])
        XCTAssertEqual(serverlessConfig.custom, serverlessConfig2.custom)
        XCTAssertEqual(serverlessConfig.resources, serverlessConfig2.resources)
    }
}
