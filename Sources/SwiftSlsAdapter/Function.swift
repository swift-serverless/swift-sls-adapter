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

// MARK: - Function

/// Function configuration
public struct Function: Codable, Equatable {
    /// Initialize a Lambda Function configuration
    ///
    /// - Parameters:
    ///   - handler: The file and module for this specific function. Cannot be used with 'image'.
    ///   - image: Container image to use. Cannot be used with 'handler'.
    ///   - runtime: Custom Runtme for Swift: `.provided` or `.providedAl2`
    ///   - memorySize: Default memory size for functions (default: 1024MB)
    ///   - timeout: Default timeout for functions (default: 6 seconds)
    ///   - environment: Function environment variables
    ///   - ephemeralStorageSize: Configure the size of ephemeral storage available to your Lambda function (in MBs, default: 512)
    ///   - name: Override the Lambda function name ${sls:stage}-lambdaName
    ///   - description: Description
    ///   - architecture: Processor architecture: `.x86_64` or `.arm64` via Graviton2 (default: x86_64)
    ///   - reservedConcurrency: Reserve a maximum number of concurrent instances (default: account limit)
    ///   - provisionedConcurrency: Provision a minimum number of concurrent instances (default: 0)
    ///   - role: Override the IAM role to use for this function
    ///   - onError: SNS topic or SQS ARN to use for the DeadLetterConfig (failed executions)
    ///   - kmsKeyArn: KMS key ARN to use for encryption for this function
    ///   - snapStart: Defines if you want to make use of SnapStart, this feature can only be used in combination with a Java runtime. Configuring this property will result in either None or PublishedVersions for the Lambda function
    ///   - disableLogs: Disable the creation of the CloudWatch log group
    ///   - logRetentionInDays: Duration for CloudWatch log retention (default: forever).
    ///   - tags: Function specific tags
    ///   - vpc: VPC settings for this function
    ///   - url: Lambda URL definition for this function, optional
    ///   - package: Packaging rules specific to this function
    ///   - layers: ARN of Lambda layers to use
    ///   - tracing: Overrides the provider setting. Can be 'Active' or 'PassThrough'
    ///   - condition: Conditionally deploy the function
    ///   - dependsOn: CloudFormation 'DependsOn' option
    ///   - destinations: Lambda destination settings
    ///   - fileSystemConfig: Mount an EFS filesystem
    ///   - maximumRetryAttempts: Maximum retry attempts when an asynchronous invocation fails (between 0 and 2; default: 2)
    ///   - maximumEventAge: Maximum event age in seconds when invoking asynchronously (between 60 and 21600)
    ///   - events: Function Events
    public init(
        handler: String?,
        image: String? = nil,
        runtime: Runtime?,
        memorySize: Int?,
        timeout: Int?,
        environment: YAMLContent?,
        ephemeralStorageSize: Int?,
        name: String?,
        description: String,
        architecture: Architecture?,
        reservedConcurrency: Int?,
        provisionedConcurrency: Int?,
        role: String?,
        onError: String?,
        kmsKeyArn: String?,
        snapStart: Bool?,
        disableLogs: Bool?,
        logRetentionInDays: Int?,
        tags: [String: String]?,
        vpc: YAMLContent?,
        url: YAMLContent?,
        package: Package?,
        layers: YAMLContent?,
        tracing: Tracing?,
        condition: YAMLContent?,
        dependsOn: [String]?,
        destinations: YAMLContent?,
        fileSystemConfig: YAMLContent?,
        maximumRetryAttempts: Int?,
        maximumEventAge: Int?,
        events: [FunctionEvent]
    ) {
        self.handler = handler
        self.image = image
        self.runtime = runtime
        self.memorySize = memorySize
        self.timeout = timeout
        self.environment = environment
        self.ephemeralStorageSize = ephemeralStorageSize
        self.name = name
        self.description = description
        self.architecture = architecture
        self.reservedConcurrency = reservedConcurrency
        self.provisionedConcurrency = provisionedConcurrency
        self.role = role
        self.onError = onError
        self.kmsKeyArn = kmsKeyArn
        self.snapStart = snapStart
        self.disableLogs = disableLogs
        self.logRetentionInDays = logRetentionInDays
        self.tags = tags
        self.vpc = vpc
        self.url = url
        self.package = package
        self.layers = layers
        self.tracing = tracing
        self.condition = condition
        self.dependsOn = dependsOn
        self.destinations = destinations
        self.fileSystemConfig = fileSystemConfig
        self.maximumRetryAttempts = maximumRetryAttempts
        self.maximumEventAge = maximumEventAge
        self.events = events
    }

    /// The file and module for this specific function. Cannot be used with 'image'.
    public let handler: String?

    /// Container image to use. Cannot be used with 'handler'.
    /// Can be the URI of an image in ECR, or the name of an image defined in 'provider.ecr.images'
    public let image: String?

    /// Custom Runtme for Swift
    ///
    /// Note: Other runtimes are unsupported
    public let runtime: Runtime?

    /// Default memory size for functions (default: 1024MB)
    public let memorySize: Int?

    /// Default timeout for functions (default: 6 seconds)
    ///
    /// Note: API Gateway has a maximum timeout of 30 seconds
    public let timeout: Int?

    /// Function environment variables
    public let environment: YAMLContent?

    /// Configure the size of ephemeral storage available to your Lambda function (in MBs, default: 512)
    public let ephemeralStorageSize: Int?

    /// Override the Lambda function name ${sls:stage}-lambdaName
    public let name: String?

    public let description: String

    /// Processor architecture: 'x86_64' or 'arm64' via Graviton2 (default: x86_64)
    public let architecture: Architecture?

    /// Reserve a maximum number of concurrent instances (default: account limit)
    public let reservedConcurrency: Int?

    /// Provision a minimum number of concurrent instances (default: 0)
    public let provisionedConcurrency: Int?

    /// Override the IAM role to use for this function
    ///
    /// arn:aws:iam::XXXXXX:role/role
    public let role: String?

    /// SNS topic or SQS ARN to use for the DeadLetterConfig (failed executions)
    ///
    /// example: arn:aws:sns:us-east-1:XXXXXX:sns-topic
    public let onError: String?

    /// KMS key ARN to use for encryption for this function
    ///
    /// example: arn:aws:kms:us-east-1:XXXXXX:key/some-hash
    public let kmsKeyArn: String?

    /// Defines if you want to make use of SnapStart, this feature can only be used in combination with a Java runtime. Configuring this property will result in either None or PublishedVersions for the Lambda function
    public let snapStart: Bool?

    /// Disable the creation of the CloudWatch log group
    public let disableLogs: Bool?

    /// Duration for CloudWatch log retention (default: forever).
    public let logRetentionInDays: Int?

    /// Function specific tags
    public let tags: [String: String]?

    /// VPC settings for this function
    /// If you use VPC then both subproperties (securityGroupIds and subnetIds) are required
    /// Can be set to '~' to disable the use of a VPC
    public let vpc: YAMLContent?

    /// Lambda URL definition for this function, optional
    /// Can be defined as `true` which will create URL without authorizer and cors settings
    public let url: YAMLContent?

    /// Packaging rules specific to this function
    public let package: Package?

    /// ARN of Lambda layers to use
    public let layers: YAMLContent?

    /// Overrides the provider setting. Can be 'Active' or 'PassThrough'
    public let tracing: Tracing?

    /// Conditionally deploy the function
    public let condition: YAMLContent?

    /// CloudFormation 'DependsOn' option
    public let dependsOn: [String]?

    /// Lambda destination settings
    public let destinations: YAMLContent?

    /// Mount an EFS filesystem
    ///
    /// ARN of EFS Access Point
    /// example:    arn: arn:aws:elasticfilesystem:us-east-1:11111111:access-point/fsap-a1a1a1
    /// Path under which EFS will be mounted and accessible in Lambda
    /// example:    localMountPath: /mnt/example
    public let fileSystemConfig: YAMLContent?

    /// Maximum retry attempts when an asynchronous invocation fails (between 0 and 2; default: 2)
    public let maximumRetryAttempts: Int?

    /// Maximum event age in seconds when invoking asynchronously (between 60 and 21600)
    public let maximumEventAge: Int?

    /// Function Events
    public let events: [FunctionEvent]
}

// MARK: - FunctionEvent

/// FunctionEvent configuration
public struct FunctionEvent: Codable, Equatable {
    /// Initialize a FunctionEvent configuration
    ///
    /// - Parameter httpAPI: API Gateway v2 HTTP API event
    public init(httpAPI: EventHTTPAPI?) {
        self.httpAPI = httpAPI
    }

    /// API Gateway v2 HTTP API Event
    public let httpAPI: EventHTTPAPI?

    enum CodingKeys: String, CodingKey {
        case httpAPI = "httpApi"
    }
}

// MARK: - EventHTTPAPI

/// EventHTTPAPI configuration
public struct EventHTTPAPI: Codable, Equatable {
    /// Initialise an EventHTTP API configuration
    ///
    /// - Parameters:
    ///   - path: URL path
    ///   - method: HTTP metohd
    ///   - authorizer: Authorizer
    public init(
        path: String,
        method: HTTPMethod,
        authorizer: YAMLContent?
    ) {
        self.path = path
        self.method = method
        self.authorizer = authorizer
    }

    /// URL path
    public let path: String
    
    /// HTTP Method
    public let method: HTTPMethod

    /// Name of an authorizer defined in 'provider.httpApi.authorizers'
    /// example:
    /// ```
    /// ["name": "someJwtAuthorizer",
    ///  "scopes": ["user.id", "user.email"]]
    ///  ```
    public let authorizer: YAMLContent?
}

// MARK: - Layer

/// Layer configuration
public struct Layer: Codable, Equatable {
    /// Initialise a Layer configuration
    ///
    /// - Parameters:
    ///   - path: Path to layer contents on disk
    ///   - name: Name
    ///   - description: Description
    public init(
        path: String,
        name: String,
        description: String
    ) {
        self.path = path
        self.name = name
        self.description = description
    }

    /// Path to layer contents on disk
    public let path: String
    
    /// Name
    public let name: String
    
    /// Description
    public let description: String
}

// MARK: - Tracing

/// Tracing
public enum Tracing: String, Codable, Equatable {
    case active = "Active"
    case passThrough = "PassThrough"
}

// MARK: - HTTPMethod

/// HTTPMethod
public enum HTTPMethod: String, Codable, Equatable {
    case `get`
    case post
    case put
    case delete
    case patch
}
