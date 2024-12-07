# AWS API Gateway Data Mapping Deep Drive

Deep dive on data mapping to/from integration methods. Path params, query params, headers and body mapping is explored.
Body mapping is done with Apache VTL (Velocity Template Language).

I have used HTTP integration type for this exercise. Also used 3rd party URLs in the HTTP integration endpoint URLs.

## Passing query params to HTTP integration request

GET request on ```/v1/api/agify?n=string``` is mapped to```https://api.agify.io?name="string"```.
This is achieved by URL query string parameters mapping in the integration part: ```method.request.querystring.n``` to ```name```.
```https://api.agify.io?name=string``` returns some fake age about name which is very useful for testing purposes. For example,
sending GET request on ```https://api.agify.io/?name=tiger``` returns ```{"count":4679,"name":"tiger","age":57}```
    

## References

* [API Gateway mapping template and access logging variable reference](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html)
* [Apache Velocity Template Language](https://velocity.apache.org/engine/devel/vtl-reference.html)
* [Fake Store API - Pseudo-real data for e-commerce or shopping website](https://fakestoreapi.com)

