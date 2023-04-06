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

// MARK: - Provider

/// Provider configuration
public struct Provider: Codable, Equatable {
    /// Initialise a Provider configuration
    ///
    /// - Parameters:
    ///   - name: Cloud provider name
    ///   - stage: Default stage (default: dev)
    ///   - region: Default region (default: us-east-1)
    ///   - profile: The AWS profile to use to deploy (default: "default" profile)
    ///   - tags: Optional CloudFormation tags to apply to APIs and functions
    ///   - stackName: Use a custom name for the CloudFormation stack
    ///   - deploymentMethod: Method used for CloudFormation deployments: 'changesets' or 'direct' (default: changesets)
    ///   - notificationArns: List of existing Amazon SNS topics in the same region where notifications about stack events are sent.
    ///   - stackParameters: Stack parameters
    ///   - disableRollback: Disable automatic rollback by CloudFormation on failure. To be used for non-production environments.
    ///   - rollbackConfiguration: Rollback configuration
    ///   - runtime: Custom Runtme for Swift
    ///   - memorySize: Default memory size for functions (default: 1024MB)
    ///   - timeout: Default timeout for functions (default: 6 seconds)
    ///   - environment: Function environment variables
    ///   - logRetentionInDays: Duration for CloudWatch log retention (default: forever)
    ///   - logDataProtectionPolicy: Policy defining how to monitor and mask sensitive data in CloudWatch logs
    ///   - kmsKeyArn: KMS key ARN to use for encryption for all functions
    ///   - versionFunctions: Use function versioning (enabled by default)
    ///   - architecture: Processor architecture: `.x86_64` or `.arm64` via Graviton2 (default: x86_64)
    ///   - httpAPI: API Gateway v2 HTTP API
    ///   - iam: IAM permissions
    public init(
        name: Provider.CloudProvider,
        stage: Provider.Stage? = nil,
        region: Region,
        profile: String? = nil,
        tags: [String: String]? = nil,
        stackName: String? = nil,
        deploymentMethod: Provider.DeploymentMethod? = nil,
        notificationArns: [String]? = nil,
        stackParameters: [Provider.StackParameters]? = nil,
        disableRollback: Bool = false,
        rollbackConfiguration: Provider.RollbackConfiguration? = nil,
        runtime: Runtime,
        memorySize: Int? = nil,
        timeout: Int? = nil,
        environment: YAMLContent?,
        logRetentionInDays: Int? = nil,
        logDataProtectionPolicy: YAMLContent? = nil,
        kmsKeyArn: String? = nil,
        versionFunctions: Bool = true,
        architecture: Architecture,
        httpAPI: Provider.ProviderHTTPAPI?,
        iam: Iam?
    ) {
        self.name = name
        self.stage = stage
        self.region = region
        self.profile = profile
        self.tags = tags
        self.stackName = stackName
        self.deploymentMethod = deploymentMethod
        self.notificationArns = notificationArns
        self.stackParameters = stackParameters
        self.rollbackConfiguration = rollbackConfiguration
        self.runtime = runtime
        self.memorySize = memorySize
        self.timeout = timeout
        self.environment = environment
        self.logRetentionInDays = logRetentionInDays
        self.logDataProtectionPolicy = logDataProtectionPolicy
        self.kmsKeyArn = kmsKeyArn
        self.architecture = architecture
        self.httpAPI = httpAPI
        self.iam = iam
        self.versionFunctions = versionFunctions
        self.disableRollback = disableRollback
    }

    // MARK: - General Settings

    /// Cloud provider name
    public let name: CloudProvider

    /// Default stage (default: dev)
    public var stage: Stage?

    /// Default region (default: us-east-1)
    @CodableDefault.FirstCase public var region: Region

    /// The AWS profile to use to deploy (default: "default" profile)
    public let profile: String?

    /// Optional CloudFormation tags to apply to APIs and functions
    public let tags: [String: String]?

    /// Use a custom name for the CloudFormation stack
    public let stackName: String?

    /// Method used for CloudFormation deployments: 'changesets' or 'direct' (default: changesets)
    /// See https://www.serverless.com/framework/docs/providers/aws/guide/deploying#deployment-method
    public var deploymentMethod: DeploymentMethod?

    /// List of existing Amazon SNS topics in the same region where notifications about stack events are sent.
    ///
    /// example: ["arn:aws:sns:us-east-1:XXXXXX:mytopic"]
    public let notificationArns: [String]?

    /// Stack parameters
    public let stackParameters: [StackParameters]?

    /// Disable automatic rollback by CloudFormation on failure. To be used for non-production environments.
    @CodableDefault.False public var disableRollback

    /// Rollback configuration
    public let rollbackConfiguration: RollbackConfiguration?

    // MARK: - General function settings

    /// Custom Runtme for Swift
    ///
    /// Note: Other runtimes are unsupported
    public let runtime: Runtime

    /// Default memory size for functions (default: 1024MB)
    public let memorySize: Int?

    /// Default timeout for functions (default: 6 seconds)
    ///
    /// Note: API Gateway has a maximum timeout of 30 seconds
    public let timeout: Int?

    /// Function environment variables
    public let environment: YAMLContent?

    /// Duration for CloudWatch log retention (default: forever)
    ///
    /// Valid values: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-logs-loggroup.html
    public let logRetentionInDays: Int?

    /// Policy defining how to monitor and mask sensitive data in CloudWatch logs
    ///
    /// Policy format: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/mask-sensitive-log-data-start.html
    public let logDataProtectionPolicy: YAMLContent?

    /// KMS key ARN to use for encryption for all functions
    public let kmsKeyArn: String?

    /// Use function versioning (enabled by default)
    @CodableDefault.True public var versionFunctions

    /// Processor architecture: 'x86_64' or 'arm64' via Graviton2 (default: x86_64)
    @CodableDefault.FirstCase public var architecture: Architecture

    // MARK: - API Gateway v2 HTTP API

    /// API Gateway v2 HTTP API
    public let httpAPI: ProviderHTTPAPI?

    // MARK: - IAM permissions

    /// IAM permissions
    public let iam: Iam?
}

// MARK: - CodingKeys

extension Provider {
    enum CodingKeys: String, CodingKey {
        case name
        case stage
        case region
        case profile
        case tags
        case stackName
        case notificationArns
        case stackParameters
        case disableRollback
        case rollbackConfiguration
        case runtime
        case memorySize
        case timeout
        case httpAPI = "httpApi"
        case architecture
        case environment
        case logRetentionInDays
        case logDataProtectionPolicy
        case kmsKeyArn
        case versionFunctions
        case iam
    }
}

// MARK: - Extension

extension Provider {
    /// Cloud provider
    public enum CloudProvider: String, Codable, Equatable {
        case aws
    }

    /// Stage
    public enum Stage: String, Codable, CaseIterable, Equatable {
        case dev
        case prod
    }

    /// CloudFormation deployment method
    public enum DeploymentMethod: String, Codable, CaseIterable, Equatable {
        case changesets
        case direct
    }

    /// Stack Parameters
    public struct StackParameters: Codable, Equatable {
        /// StackParameters configuration
        ///
        /// - Parameters:
        ///   - parameterKey: parameter key
        ///   - parameterValue: parameter value
        public init(parameterKey: String, parameterValue: String) {
            self.parameterKey = parameterKey
            self.parameterValue = parameterValue
        }

        public let parameterKey: String
        public let parameterValue: String

        enum CodingKeys: String, CodingKey {
            case parameterKey = "ParameterKey"
            case parameterValue = "ParameterValue"
        }
    }

    /// Rollback Configuration
    public struct RollbackConfiguration: Codable, Equatable {
        /// RollbackConfiguration
        ///
        /// - Parameters:
        ///   - monitoringTimeInMinutes: Monitoring time in minutes
        ///   - rollbackTriggers: Rollback triggers
        public init(monitoringTimeInMinutes: Int, rollbackTriggers: [Provider.RollbackTrigger]) {
            self.monitoringTimeInMinutes = monitoringTimeInMinutes
            self.rollbackTriggers = rollbackTriggers
        }

        /// Monitoring time in minutes
        public let monitoringTimeInMinutes: Int

        /// Rollback triggers
        public let rollbackTriggers: [RollbackTrigger]

        enum CodingKeys: String, CodingKey {
            case monitoringTimeInMinutes = "MonitoringTimeInMinutes"
            case rollbackTriggers = "RollbackTriggers"
        }
    }

    /// Rollback Trigger
    public struct RollbackTrigger: Codable, Equatable {
        /// RollbackTrigger configuration
        ///
        /// - Parameters:
        ///   - arn: Trigger arn
        ///   - type: Trigger type
        public init(arn: String, type: String) {
            self.arn = arn
            self.type = type
        }

        /// Trigger arn
        public let arn: String

        /// Trigger type
        public let type: String

        enum CodingKeys: String, CodingKey {
            case arn = "Arn"
            case type = "Type"
        }
    }

    /// ProviderHTTPAPI
    public struct ProviderHTTPAPI: Codable, Equatable {
        /// Initialise ProviderHTTPAPI cofiguration
        ///
        /// - Parameters:
        ///   - id: Attach to an externally created HTTP API via its ID
        ///   - name: Set a custom name for the API Gateway API (default: ${sls:stage}-${self:service})
        ///   - payload: Payload format version (note: use quotes in YAML: '1.0' or '2.0') (default: '2.0')
        ///   - disableDefaultEndpoint: Disable the default 'execute-api' HTTP endpoint (default: false)
        ///   - metrics: Enable detailed CloudWatch metrics (default: false)
        ///   - cors: Enable CORS HTTP headers with default settings (allow all)
        ///   - authorizers: Authorizers
        public init(
            id: String? = nil,
            name: String? = nil,
            payload: String?,
            disableDefaultEndpoint: Bool? = nil,
            metrics: Bool? = nil,
            cors: Bool?,
            authorizers: YAMLContent? = nil
        ) {
            self.id = id
            self.name = name
            self.payload = payload
            self.disableDefaultEndpoint = disableDefaultEndpoint
            self.metrics = metrics
            self.cors = cors
            self.authorizers = authorizers
        }

        /// Attach to an externally created HTTP API via its ID:
        public let id: String?

        /// Set a custom name for the API Gateway API (default: ${sls:stage}-${self:service})
        public let name: String?

        /// Payload format version (note: use quotes in YAML: '1.0' or '2.0') (default: '2.0')
        public let payload: String?

        /// Disable the default 'execute-api' HTTP endpoint (default: false)
        /// Useful when using a custom domain.
        public let disableDefaultEndpoint: Bool?

        /// Enable detailed CloudWatch metrics (default: false)
        public let metrics: Bool?

        /// Enable CORS HTTP headers with default settings (allow all)
        /// Can be fine-tuned with specific options
        public let cors: Bool?

        /// Authorizers
        public let authorizers: YAMLContent?
    }
}

// MARK: - Iam

/// Iam configuration
public enum Iam: Codable, Equatable {
    /// Instruct Serverless to use an existing IAM role for all Lambda functions
    case existingRole(String)

    /// Configure the role that will be created by Serverless (simplest):
    case role(Role)

    /// Initialise Iam config
    ///
    /// - Parameter role: Configure the role that will be created by Serverless
    public init(role: String) {
        self = .existingRole(role)
    }

    /// Initialise Iam config
    ///
    /// - Parameter role: Instruct Serverless to use an existing IAM role for all Lambda functions
    public init(role: Role) {
        self = .role(role)
    }

    enum CodingKeys: String, CodingKey {
        case role
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(Role.self, forKey: .role) {
            self = .role(value)
        } else {
            let container = try decoder.singleValueContainer()
            self = .existingRole(try container.decode(String.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .existingRole(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .role(let role):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(role, forKey: .role)
        }
    }
}

// MARK: - Role

/// Role configuration
public struct Role: Codable, Equatable {
    /// Initialise Role configuration
    ///
    /// - Parameters:
    ///   - statements: Statement list
    ///   - name: Optional custom name for default IAM role
    ///   - path: Optional custom path for default IAM role
    ///   - managedPolicies: Optional IAM Managed Policies to include into the IAM Role
    ///   - permissionsBoundary: ARN of a Permissions Boundary for the role
    ///   - tags: CloudFormation tags
    ///   - deploymentRole: ARN of an IAM role for CloudFormation service. If specified, CloudFormation uses the role's credentials
    public init(
        statements: [Statement],
        name: String? = nil,
        path: String? = nil,
        managedPolicies: [String]? = nil,
        permissionsBoundary: String? = nil,
        tags: [String: String]? = nil,
        deploymentRole: String? = nil
    ) {
        self.statements = statements
        self.name = name
        self.path = path
        self.managedPolicies = managedPolicies
        self.permissionsBoundary = permissionsBoundary
        self.tags = tags
        self.deploymentRole = deploymentRole
    }

    /// Statement list
    public let statements: [Statement]

    /// Optional custom name for default IAM role
    public let name: String?

    /// Optional custom path for default IAM role
    public let path: String?

    /// Optional IAM Managed Policies to include into the IAM Role
    public let managedPolicies: [String]?

    /// ARN of a Permissions Boundary for the role
    public let permissionsBoundary: String?

    /// CloudFormation tags
    public let tags: [String: String]?

    /// ARN of an IAM role for CloudFormation service. If specified, CloudFormation uses the role's credentials
    public let deploymentRole: String?
}

// MARK: - Statement

/// Statement configuration
public struct Statement: Codable, Equatable {
    /// Initialise Statement
    ///
    /// - Parameters:
    ///   - effect: effect
    ///   - action: action
    ///   - resource: resource YAML
    public init(
        effect: String,
        action: [String],
        resource: YAMLContent
    ) {
        self.effect = effect
        self.action = action
        self.resource = resource
    }

    /// effect
    public let effect: String
    /// action
    public let action: [String]
    /// resource YAML
    public let resource: YAMLContent

    enum CodingKeys: String, CodingKey {
        case effect = "Effect"
        case action = "Action"
        case resource = "Resource"
    }
}

/// Runtime
public enum Runtime: String, Codable, Equatable {
    case provided
    case providedAl2 = "provided.al2"
}

/// Architecture
public enum Architecture: String, Codable, CaseIterable, Equatable {
    /// CPU architecture x86_64 - Intel
    case x86_64
    /// CPU architecture arm64 - Graviton 2
    case arm64
}

public extension Statement {
    static func allowLogAccess(resource: YAMLContent) -> Statement {
        Statement(
            effect: "Allow",
            action: [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            resource: resource
        )
    }
    
    static func allowDynamoDBReadWrite(resource: YAMLContent) -> Statement {
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
            resource: resource
        )
    }
}
