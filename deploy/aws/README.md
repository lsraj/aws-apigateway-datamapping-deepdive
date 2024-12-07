
# API Gateway features

## API types

1) **HTTP API**: Use for lightweight, low-latency APIs when you don’t need the full feature set of REST APIs (for example, simple CRUD APIs for mobile apps or microservices).
2) **WebSocket API**: Use when your application needs real-time, full-duplex communication, like a messaging app or live data updates.
3) **REST API**: Use for feature-rich RESTful APIs that require advanced capabilities like custom authorizers, API keys, request/response transformation, caching, etc.
4) **REST API Private**: Use when you need to create private APIs that should only be accessed from within a VPC or by internal resources, like EC2 instances or Lambda functions inside the VPC.


Comparison Summary:
Feature	HTTP API	WebSocket API	REST API (Public)	REST API Private
Best For	Simple RESTful APIs with low latency	Real-time, bidirectional communication	Full-featured REST APIs with CRUD ops	Secure internal APIs within a VPC
Protocols	HTTP/HTTPS	WebSocket	HTTP/HTTPS	HTTP/HTTPS
Use Cases	Mobile/Web apps, microservices	Chat apps, real-time notifications, live updates	CRUD-based applications, integrations	Internal APIs within VPC, private services
Integration with Lambda	Yes	Yes	Yes	Yes
Latency	Low	Very low (real-time)	Medium (due to advanced features)	Medium (private endpoints)
Authorization	JWT, Cognito	JWT, Cognito	IAM, Lambda Authorizer, API Keys, Custom Authorizers	IAM, Lambda Authorizer, VPC-specific access
Cost	Lower (simpler)	Higher (due to persistent connections)	Higher (due to more advanced features)	Higher (due to VPC integration)



## Service integration:

It is most common to configure the API Gateway to invoke a Lambda function. However, we can often skip this Lambda
function and let the API Gateway communicate directly with the other services. Such service integration significantly
reduces cost and latency.  Our API can then directly connect with the DynamoDB or S3 or invoke a step function
asynchronously. If we use this smartly, it can result in very low latency and cost.


## HTTP integration:

We can configure API Gateway to proxy a request to a third-party HTTP request. Consider, for example, an application
that invokes a third-party API from RapidAPI with the related API keys.

It’s a security risk to embed API keys in the client browser application. It creates messy code if the client has to
invoke several different APIs. Therefore, collating everything into a single API within the API Gateway makes more sense.
Then, based on the path in the API, API Gateway can invoke the related third-party API, with the API key configured in AWS.

All this is possible with HTTP integration.


## Data mapping

Data mapping is handy when we work with service integrations. We can define a schema for transforming the
request and response as it passes through the API Gateway to any AWS service that’s integrated with the API.

Using this mapping as a parameter in the request passed on to the downstream service has much potential.
For example, if we have a service integration where API Gateway is used to trigger an SNS Event, it can be
helpful if we can add the IP address of the caller in the SNS Subject.


## Data model and validation

We can define and enforce a data model for the input request. API Gateway validates this model before actually
passing it into our service. This forms a protective layer, guarding our services against stray invocation attempts.
Any application that’s open to the internet has to worry about security. If it’s a niche application we develop,
we can expect many prying eyes. API Gateway provides several features that can help safeguard the API.

It supports authentication and authorization with API Keys, the Authenticator Lambda function, and Cognito Integration.
It also provides for security in the form of throttling on high loads. We can mask the internal service errors with
clean responses to ensure that the internals remain hidden.


## Usage quotas

We can assign quotas to the individual users by using API keys. For example, we can specify that each API key can
authenticate up to 100 requests per day.


## Deployment stages

API Gateway helps us with non-destructive deployments. We can easily deploy newer versions of the API without
messing with the existing ones. This simplifies the development cycle and enables faster and more frequent deployments.


## Logging and tracing

Because of the integration with CloudWatch and X-Ray services, API Gateway enables an elegant framework for
tracking and debugging individual API requests and responses.

These are just a few major features we get with API Gateway. As we go through each of these in depth, we’ll better
appreciate its power. Let’s get started.


# REST API in AWS API Gateway

Any REST API definition has three components:
1) URL
2) HTTP method
3) Definition for request/response payloads.


## Resources and methods

Any API in the API Gateway can have several resources, and each resource can have several methods.
Finally, each resource with a method has a unique integration on the API Gateway.

Now, what does that mean? The API has one base URL for invoking an API, but there are several
endpoints in there. AN example Hello World API endpoint looks like https://{baseurl}/hello.

Here, hello is the resource. We can have several endpoints in the same API. For example,
with https://{baseurl}, https://{baseurl}/res1, https://{baseurl}/res1/res2, and so on.
Each endpoint can provide different HTTP methods (GET, POST, PUT, DELETE, PATCH, and OPTIONS).
Thus, we can have six ways to invoke the https://{baseurl}/hello endpoint.


## Integration:

API Gateway provides five ways of integrating the request. These are:
 - Lambda function,
 - an HTTP integration,
 - Mock integration
 - AWS Service
 - VPC link

In simple words, this part of the API defines what an incoming API request means for us.
We can also tweak the incoming data and alter its values or headers.

REST API can be configured on the method request. Here, we can add special functionality
like payload validation, authorization, header validation, and so on.

Just like an integration request maps the incoming request to something in the cloud, the integration
response maps and translates the API’s response.

Finally, a method response validates and fixes the API’s response.


## Stage and deployment

AWS doesn’t directly deploy the API as we fill in these details. After we make all the required changes
to the API, we have to explicitly deploy the API to the required stage. This is useful for managing the
test and production environments, or for managing API versions.

Deployment remains unchanged while we can make more changes and deploy it to stage v2. This makes it
very easy to make blue-green deployments with API Gateway.



# API Gateway: Basic Configurations


## Data Mapping


### Data flow

When REST API is invoked, the data flows through a series of steps:

1) The method request identifies the incoming request and extracts components like the path parameters, headers, and query parameters. It can validate the request based on these components.

2) The integration request maps the available inputs to the inputs required by the target API. It has the required IAM role needed to invoke the target API.

3) The target API could be a Lambda function, any AWS service, or an external URL our API invokes as part of the integration.

4) The integration response maps the response from the target service to the response expected by the API client.

5) The method response patches up the response so that it’s ready to return. This step can alter headers or the response status code based on the configuration.

Data mapping in the API Gateway is a powerful tool. A few lines of code here can significantly reduce the cost and
latency of our APIs. In addition, data mapping is essential for AWS service integration.

**Apache Velocity**

We can have a complex data transformation at the API Gateway, not just mapping fields. We can modify the fields
and parse or convert them per the business requirement.

Apache Velocity defines a standard language for such data mapping and transformation. API Gateway adopts this
as a standard for mapping the request and response of the API.
require a detailed tutorial.



## API Authentication and Authorization

Authentication involves ensuring that the API client is indeed what it claims to be.

authorization ensures that the client should be allowed to do what they’re trying to do.

Both are equally important when we work with API gateway. First, we must ensure that the client
is genuine. The task doesn’t end there. We should also ensure that the client is authorized to do
what they’re trying to do.

Authentication is implemented using login credentials, JWT tokens, or keys that define an understanding
between the client and server.

Authorization is implemented within AWS based on the IAM role assigned to the request.

Method requests take care of the security of the API Gateway. This step has features to validate
the HTTP headers and the body. It can connect with services like AWS Cognito and AWS Lambda for
elaborate validation.

Additionally, we can use the AWS Web Application Firewall (WAF) to filter out unwanted requests.
A firewall is very useful for blocking unwanted requests. Typical legacy firewalls enable IP and
port blocking. WAF is a smart firewall capable of handling a lot more than that. It can identify
shady requests that can compromise security and can block them before they can damage our application.

Within the API Gateway, security is managed by the Lambda authorizers in the method request step.
AWS Cognito can provide us with this functionality out of the box.


## API Throttling

**Why throttle?**

Anything in excess is wrong. When the traffic bursts beyond limits, it could overburden the system.
The traffic surge could also be caused by a hacker, not actual good traffic. When hackers try to attack
the application by simultaneously making too many API calls, it shows up as a DDoS attack on the
API Gateway. AWS has several services dedicated to security against such attacks. The AWS Shield is the
most popular for guarding against DDoS attacks.`

The simplest way to hold back such attacks is through throttling. We can restrict the burst of
API invocations with this configuration. Throttling limits the number of concurrent API invocations to
ensure that our system isn’t surprised by more requests than it can handle.

**Request rate and burst**


API Gateway allows us to define throttling in two components:
 - the number of requests per second. The rate determines the maximum aggregate rate over the second.
 - the burst count. burst defines the maximum number of concurrent requests.

These limits are applied at deployment stage.


## API Keys


Authentication and authorization some times is too excessive. At times, a complex password is enough to take
us through in cases where risk doesn’t justify the overheads of other forms of security.

An API key is a complex string we can use to identify a client making the API call. API Gateway expects this
key in a request header, x-api-key. Based on this key, the API Gateway can handle authentication and
authorization for the request.

API Gateway has a pool of such keys along with the access and quota allocated to each key. It tracks all the
invocations using a particular API key and uses this detail to authorize any new invocation.

Note that the API keys are specific to the account and region, not restricted by any particular API. So, several
APIs in an account and region can share the same API key.


## API Logging

CloudWatch


## API Tracing

Amazon X-Ray helps us see through the complete stack and look for what we need to know. In microservice and
serverless architecture, tracking how different services process a particular request is challenging.
AWS X-Ray makes this possible. It helps us trace a single request as it passes through different services
and components of the system.

It can trace through the path taken by every API request and comes up with a wonderful visualization of how
that request was processed at each service.


## API Logging Deep Dive



# API Caching


## CORS


# Data Mapping Deep Dive

**What's integration?**

Modern distributed systems span multiple components, which may communicate with each other.
Integration is the term used for a collection of tools and techniques for connecting such systems.
The data format expected by the API may differ from the format the caller expects. To address this,
API Gateway provides a strong framework for data mapping to bridge such mismatch..

API Gateway provides a strong framework for bridging such a mismatch. API Gateway provides several different types of integration with services in and outside of AWS. This chapter covers the data mapping required for such integration.

**Types of integration**

When we define request integration with API Gateway, we have only three logical options.

 * We can integrate with an API inside AWS.
 * We can integrate with an API outside of AWS.
 * We can process the request within the API Gateway.

Most of AWS is a collection of REST APIs. All the services export a REST API that allows the client to
connect with it and submit a payload for processing. The API Gateway can expose such an API to the
external world, along with the appropriate protection.

The API Gateway also works as a proxy for external APIs, using an HTTP integration, and it can
process the API within itself by using a mock integration.


## Request Integration

The API Gateway has several different ways of constructing the payload when it invokes the remote API.
It can build the target API call's body, headers, path, and query parameters based on the input request's
body, headers, path parameters, and query parameters. This process is called request integration.
AWS gives us a set of powerful tools that can implement this integration with very low latency and cost.

### Integration within AWS

AWS uses IAM roles for this purpose. When integrating an AWS service with the API Gateway, we must
specify an IAM role that the API Gateway can assume while invoking the service. AWS internally manages
the exchange of tokens and headers for all the authentication and authorization required under the hood.


## Query Parameters

Consider the URL, https://example.com?arg1=val1&arg2=val2. Here, arg1 and arg2 are called query parameters.
We need query parameter integration in two scenarios.
 * The URL invoking our API contains query parameters that should pass into the target API.
 * The URL of the target API requires some query parameters.

API Gateway enables either of them. When we integrate the requests, we can change the query parameters to
get the required mapping.


