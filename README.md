# swift-sls-adapter

[![Swift 5.7](https://img.shields.io/badge/Swift-5.7-orange.svg)](https://swift.org/download/) 
[![Dist](https://github.com/swift-sprinter/swift-sls-adapter/actions/workflows/swift-test.yml/badge.svg)](https://github.com/swift-sprinter/swift-sls-adapter/actions/workflows/swift-test.yml)

Swift serverless.yml adapter. Read and Write a Serverless Framework configuration in Swift.


The [Serverless framework](https://www.serverless.com) is an All-in-one development solution for auto-scaling apps on AWS Lambda.
The serverless.yml file represents the deployment configuration.
This swift package allows Encoding and Decoding a serverless.yml using [Yams](https://github.com/jpsim/Yams).


## Installation

### Swift Package Manager

Add the following packages to your swift package
```swift
dependencies: [
    // ...
    .package(url: "https://github.com/swift-sprinter/swift-sls-adapter.git", from: "0.1.0")
]
```

## Usage

Decode:
```swift
import Foundation
import SwiftSlsAdapter
import Yams

let fileUrl =  URL(fileURLWithPath: "servreless.yml")
let serverlessYml: Data = Data(contentsOf: fileUrl)
let decoder = YAMLDecoder()
let serverlessConfig = try decoder.decode(ServerlessConfig.self, from: serverlessYml)
```

Encode:
```swift
import Foundation
import SwiftSlsAdapter
import Yams

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

let encoder = YAMLEncoder()
let content = try encoder.encode(serverlessConfig)
```

## Supported Serverless Features

The package is under development.

Status of the features implemented in this package:

| Feature                         | Support |
|---------------------------------|---------|
| Root Properties                 | ✅ |
| Parameters                      | ✅ |
| Provider                        | aws |
| General Settings                | ✅ |
| General Function Settings       | ✅ |
| Deployment Bucket               | ❌ |
| API Gateway v2 HTTP API         | ✅ |
| API Gateway v1 REST API         | ❌ |
| ALB                             | ❌ |
| Docker image deployments in ECR | ❌ |
| IAM permissions                 | ✅ |
| VPC                             | ❌ |
| S3 buckets                      | ❌ |
| Package                         | ✅ |
| Functions                       | ✅ |
| Lambda events                   | ✅ |
| API Gateway v2 HTTP API         | ✅ |
| API Gateway v1 REST API         | ❌ |
| API Gateway v1 REST API         | ❌ |
| Websocket API                   | ❌ |
| S3 events                       | ❌ |
| S3 Schedule                     | ❌ |
| SNS                             | ❌ |
| SQS                             | ❌ |
| Streams                         | ❌ |
| MSK                             | ❌ |
| ActiveMQ                        | ❌ |
| Kafka                           | ❌ |
| Kafka                           | ❌ |
| RabbitMQ                        | ❌ |
| Alexa                           | ❌ |
| IOT                             | ❌ |
| CloudWatch                      | ❌ |
| Cognito                         | ❌ |
| ALB                             | ❌ |
| EventBridge                     | ❌ |
| CloudFront                      | ❌ |
| Function layers                 | ✅ |
| AWS Resources                   | ✅ |

## Contributions

Contributions are more than welcome! Follow this [guide](https://github.com/swift-sprinter/swift-sls-adapter/blob/main/CONTRIBUTING.md) to contribute.

## References

https://www.serverless.com/framework/docs/providers/aws/guide/serverless.yml
