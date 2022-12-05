import * as cdk from 'aws-cdk-lib';
import { aws_stepfunctions as sfn } from 'aws-cdk-lib';
import { aws_apigateway as apigateway } from 'aws-cdk-lib';
import { aws_dynamodb as dynamodb } from 'aws-cdk-lib';
import { custom_resources as cr } from 'aws-cdk-lib';
import { RemovalPolicy as RemovalPolicy } from 'aws-cdk-lib';
import { aws_stepfunctions_tasks as tasks } from 'aws-cdk-lib';
import { aws_iam as iam } from 'aws-cdk-lib';


export class StepFunctionsStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);


    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // DDB tables creation 
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    const ddbtablerestaurant = new dynamodb.Table(this, 'yelbddbrestaurants', {
        partitionKey: { name: 'name', type: dynamodb.AttributeType.STRING },
        removalPolicy: RemovalPolicy.DESTROY,
    });

    const ddbtablecache = new dynamodb.Table(this, 'yelbddbcache', {
        partitionKey: { name: 'counter', type: dynamodb.AttributeType.STRING },
        removalPolicy: RemovalPolicy.DESTROY,
    });


    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // DDB tables initiliazation  
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    new cr.AwsCustomResource(this, 'initTablePageviews', {
      onCreate: {
        service: 'DynamoDB',
        action: 'putItem',
        parameters: {
            TableName: ddbtablecache.tableName,
            Item: {"counter": {"S": "pageviews"}, "pageviewscount": {"N": "0"}}
        },
        physicalResourceId: cr.PhysicalResourceId.of(ddbtablerestaurant.tableName + '_initialization')
      },
      policy: cr.AwsCustomResourcePolicy.fromSdkCalls({ resources: cr.AwsCustomResourcePolicy.ANY_RESOURCE }),
    });
    
    new cr.AwsCustomResource(this, 'initTableIhop', {
      onCreate: {
        service: 'DynamoDB',
        action: 'putItem',
        parameters: {
            TableName: ddbtablerestaurant.tableName,
            Item: {"name": {"S": "ihop"}, "restaurantcount": {"N": "0"}}
        },
        physicalResourceId: cr.PhysicalResourceId.of(ddbtablerestaurant.tableName + '_initialization')
      },
      policy: cr.AwsCustomResourcePolicy.fromSdkCalls({ resources: cr.AwsCustomResourcePolicy.ANY_RESOURCE }),
    });

    new cr.AwsCustomResource(this, 'initTableChipotle', {
      onCreate: {
        service: 'DynamoDB',
        action: 'putItem',
        parameters: {
            TableName: ddbtablerestaurant.tableName,
            Item: {"name": {"S": "chipotle"}, "restaurantcount": {"N": "0"}}
        },
        physicalResourceId: cr.PhysicalResourceId.of(ddbtablerestaurant.tableName + '_initialization')
      },
      policy: cr.AwsCustomResourcePolicy.fromSdkCalls({ resources: cr.AwsCustomResourcePolicy.ANY_RESOURCE }),
    });

    new cr.AwsCustomResource(this, 'initTableOutback', {
      onCreate: {
        service: 'DynamoDB',
        action: 'putItem',
        parameters: {
            TableName: ddbtablerestaurant.tableName,
            Item: {"name": {"S": "outback"}, "restaurantcount": {"N": "0"}}
        },
        physicalResourceId: cr.PhysicalResourceId.of(ddbtablerestaurant.tableName + '_initialization')
      },
      policy: cr.AwsCustomResourcePolicy.fromSdkCalls({ resources: cr.AwsCustomResourcePolicy.ANY_RESOURCE }),
    });

    new cr.AwsCustomResource(this, 'initTableBucadibeppo', {
      onCreate: {
        service: 'DynamoDB',
        action: 'putItem',
        parameters: {
            TableName: ddbtablerestaurant.tableName,
            Item: {"name": {"S": "bucadibeppo"}, "restaurantcount": {"N": "0"}}
        },
        physicalResourceId: cr.PhysicalResourceId.of(ddbtablerestaurant.tableName + '_initialization')
      },
      policy: cr.AwsCustomResourcePolicy.fromSdkCalls({ resources: cr.AwsCustomResourcePolicy.ANY_RESOURCE }),
    });


    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Step Function state machines creations  
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    ///////////////////////////////////////////
    // pageviews state machine
    ///////////////////////////////////////////
    // 
    // These two state machine objects have been created using the "aws_stepfunctions_tasks" module and 
    // are only provided as an example; they are alternative to using the custom state with a JSON blob. 
    // Since I already had the blob I am going to build my state machines off of those without using 
    // "aws_stepfunctions_tasks" (which is probably the preferred way if starting from scratch). 
    //
    //    const pageviews_update_DDB = new tasks.DynamoUpdateItem(this, 'pageviews_update_DDB', {
    //      key: {
    //        "counter": tasks.DynamoAttributeValue.fromString("pageviews")
    //      },
    //      table: ddbtablecache,
    //      expressionAttributeValues: { ":incr": tasks.DynamoAttributeValue.fromNumber(1)},
    //      updateExpression: 'SET pageviewscount = pageviewscount + :incr',
    //    });
    //
    //    const pageviews_read_DDB = new tasks.DynamoGetItem(this, 'pageviews_read_DDB', {
    //      key: {
    //        "counter": tasks.DynamoAttributeValue.fromString("pageviews")
    //      },
    //      table: ddbtablecache,
    //      outputPath: "$.Item.pageviewscount.N"
    //    });
    


    const pageviews_update_DDB = new sfn.CustomState(this, 'pageviews_update_DDB', {
      stateJson: {
        "Type": "Task",
        "Resource": "arn:aws:states:::dynamodb:updateItem",
        "Parameters": {
          "TableName": ddbtablecache.tableName,
          "Key": {
            "counter": {
              "S": "pageviews"
            }
          },
          "UpdateExpression": "SET pageviewscount = pageviewscount + :incr",
          "ExpressionAttributeValues": {
            ":incr": {
              "N": "1"
            }
          }
        }
      }
    });

    const pageviews_read_DDB = new sfn.CustomState(this, 'pageviews_read_DDB', {
      stateJson: {
        "Type": "Task",
        "Resource": "arn:aws:states:::dynamodb:getItem",
        "Parameters": {
          "TableName": ddbtablecache.tableName,
          "Key": {
            "counter": {
              "S": "pageviews"
            }
          }
        },
        "OutputPath": "$.Item.pageviewscount.N",
        "End": true
      }
    });
    
    const chain_sm_pageviews = sfn.Chain.start(pageviews_update_DDB)
      .next(pageviews_read_DDB);
    
    const sm_pageviews = new sfn.StateMachine(this, 'sm_pageviews', {
      definition: chain_sm_pageviews,
      stateMachineType: sfn.StateMachineType.EXPRESS,
    });
    ddbtablecache.grantWriteData(sm_pageviews);
    ddbtablecache.grantReadData(sm_pageviews);

    
    ///////////////////////////////////////////
    // getstats state machine 
    ///////////////////////////////////////////

    const getstats_call_pageviews = new sfn.CustomState(this, 'getstats_call_pageviews', {
      stateJson: {
        "Type": "Task",
        "Parameters": {
          "StateMachineArn": sm_pageviews.stateMachineArn
        },
        "Resource": "arn:aws:states:::aws-sdk:sfn:startSyncExecution",
        "ResultSelector": {
          "hostname": "serverless", 
          "pageviews.$": "$.Output"
        },
        "End": true
      },
    });

    const sm_getstats = new sfn.StateMachine(this, 'sm_getstats', {
      definition: getstats_call_pageviews,
      stateMachineType: sfn.StateMachineType.EXPRESS,
    });
    sm_pageviews.grantStartSyncExecution(sm_getstats);


    ///////////////////////////////////////////
    // restaurantdbread state machine 
    ///////////////////////////////////////////

    const restaurantdbread = new sfn.CustomState(this, 'restaurantdbread', {
      stateJson: {
        "Type": "Task",
        "Resource": "arn:aws:states:::dynamodb:getItem",
        "Parameters": {
          "TableName": ddbtablerestaurant.tableName,
          "Key": {
            "name": {
              "S.$": "$.restaurant_name"
            }
          }
        },
        "OutputPath": "$.Item.restaurantcount.N",
        "End": true
      }
    });

    const sm_restaurantdbread = new sfn.StateMachine(this, 'sm_restaurantdbread', {
      definition: restaurantdbread,
      stateMachineType: sfn.StateMachineType.EXPRESS,
    });
    ddbtablerestaurant.grantReadData(sm_restaurantdbread);




    ///////////////////////////////////////////
    // restaurantdbupdate state machine 
    ///////////////////////////////////////////

    const restaurantdbupdate = new sfn.CustomState(this, 'restaurantdbupdate', {
      stateJson: {
        "Type": "Task",
        "Resource": "arn:aws:states:::dynamodb:updateItem",
        "Parameters": {
          "TableName": ddbtablerestaurant.tableName,
          "Key": {
            "name": {
              "S.$": "$.restaurant_name"
            }
          },
          "UpdateExpression": "SET restaurantcount = restaurantcount + :incr",
          "ExpressionAttributeValues": {
            ":incr": {
              "N": "1"
            }
          }
        },
        "End": true
      }
    });

    const sm_restaurantdbupdate = new sfn.StateMachine(this, 'sm_restaurantdbupdate', {
      definition: restaurantdbupdate,
      stateMachineType: sfn.StateMachineType.EXPRESS,
    });
    ddbtablerestaurant.grantReadData(sm_restaurantdbupdate);
    ddbtablerestaurant.grantWriteData(sm_restaurantdbupdate);



    ///////////////////////////////////////////
    // getvotes state machine
    ///////////////////////////////////////////



    const getvotes_map_constructing = new sfn.CustomState(this, 'getvotes_map_constructing', {
      stateJson: {
        "Type": "Map",
        "Iterator": {
          "StartAt": "StartSyncExecution",
          "States": {
            "StartSyncExecution": {
              "Type": "Task",
              "Parameters": {
                "StateMachineArn": sm_restaurantdbread.stateMachineArn,
                "Input.$": "$"
              },
              "ResultSelector": {
                "name.$": "States.StringToJson($.Input)",
                "value.$": "States.StringToJson($.Output)"
              },
              "Resource": "arn:aws:states:::aws-sdk:sfn:startSyncExecution",
              "End": true
            }
          }
        }
      }
    });

    const getvotes_map_formatting = new sfn.CustomState(this, 'getvotes_map_formatting', {
      stateJson: {
        "Type": "Map",
        "End": true,
        "Iterator": {
          "StartAt": "Pass",
          "States": {
            "Pass": {
              "Type": "Pass",
              "End": true,
              "Parameters": {
                "name.$": "$.name.restaurant_name",
                "value.$": "States.StringToJson($.value)"
              }
            }
          }
        }
      }
    });
    
    const chain_sm_getvotes = sfn.Chain.start(getvotes_map_constructing)
      .next(getvotes_map_formatting);
    
    const sm_getvotes = new sfn.StateMachine(this, 'sm_getvotes', {
      definition: chain_sm_getvotes,
      stateMachineType: sfn.StateMachineType.EXPRESS,
    });
    sm_restaurantdbread.grantStartSyncExecution(sm_getvotes);



    ///////////////////////////////////////////
    // rrestaurant state machine
    ///////////////////////////////////////////


    const restaurant_put = new sfn.CustomState(this, 'restaurant_put', {
      stateJson: {
        "Type": "Task",
        "Parameters": {
          "StateMachineArn": sm_restaurantdbupdate.stateMachineArn,
          "Input.$": "$"
        },
        "Resource": "arn:aws:states:::aws-sdk:sfn:startSyncExecution",
      }
    });

    const restaurant_get = new sfn.CustomState(this, 'restaurant_get', {
      stateJson: {
        "Type": "Task",
        "Parameters": {
          "StateMachineArn": sm_restaurantdbread.stateMachineArn,
          "Input.$": "$.Input"
        },
        "Resource": "arn:aws:states:::aws-sdk:sfn:startSyncExecution",
        "OutputPath": "$.Output",
        "End": true
      }
    });
    
    const chain_sm_restaurant = sfn.Chain.start(restaurant_put)
      .next(restaurant_get);
    
    const sm_restaurant = new sfn.StateMachine(this, 'sm_restaurant', {
      definition: chain_sm_restaurant,
      stateMachineType: sfn.StateMachineType.EXPRESS,
    });
    sm_restaurantdbread.grantStartSyncExecution(sm_restaurant);
    sm_restaurantdbupdate.grantStartSyncExecution(sm_restaurant);


    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // API Gateway configuration 
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Inspired by: https://dev.to/aws-builders/api-gateway-rest-api-step-functions-direct-integration-aws-cdk-guide-13c4 
    



    ///////////////////////////////////////////
    // creating the IAM role to be assigned to the methods
    ///////////////////////////////////////////
    
    const invoke_sm_IRole = new iam.Role(this, "invoke_sm_IRole", {
      assumedBy: new iam.ServicePrincipal("apigateway.amazonaws.com"),
      inlinePolicies: {
        allowSFNInvoke: new iam.PolicyDocument({
          statements: [
            new iam.PolicyStatement({
              effect: iam.Effect.ALLOW,
              actions: ["states:StartSyncExecution"],
              resources: [sm_getvotes.stateMachineArn, sm_getstats.stateMachineArn, sm_restaurant.stateMachineArn]
            })
          ]
        })
      }
    });



    ///////////////////////////////////////////
    // API Gateway
    ///////////////////////////////////////////

    const YelbAPIGatewayStepFunctions:apigateway.RestApi = new apigateway.RestApi(this, 'Yelb-API-Gateway-StepFunctions', {
      deploy: true,
      deployOptions:{
        stageName: "api"
      },
      endpointConfiguration: {
        types: [ apigateway.EndpointType.REGIONAL ]
      }
    });


    ///////////////////////////////////////////
    // creategetvotes resource and method
    ///////////////////////////////////////////

    const creategetvotes = YelbAPIGatewayStepFunctions.root.addResource("getvotes") 
    
    creategetvotes.addMethod(
      "GET",
      new apigateway.Integration({
        type: apigateway.IntegrationType.AWS,
        integrationHttpMethod: "POST",
        uri: `arn:aws:apigateway:${cdk.Aws.REGION}:states:action/StartSyncExecution`,
        options: {
          passthroughBehavior: apigateway.PassthroughBehavior.NEVER,
          credentialsRole: invoke_sm_IRole,
          requestTemplates: {
            "application/json": 
            `{
            "input": "[{\\"restaurant_name\\": \\"ihop\\"}, {\\"restaurant_name\\": \\"bucadibeppo\\"}, {\\"restaurant_name\\": \\"chipotle\\"}, {\\"restaurant_name\\": \\"outback\\"}]",
            "stateMachineArn": "${sm_getvotes.stateMachineArn}"
            }`
          },
          integrationResponses: [
            {
              selectionPattern: "200",
              statusCode: "200",
              responseTemplates: {
                "application/json":
                `#set($inputRoot = $input.path('$')) 
                $inputRoot.output`
              }
            }
          ]
        }
      }),
      {
        methodResponses: [
          {
            statusCode: "200"
          }
        ]
      }
    )
  
  
    ///////////////////////////////////////////
    // creategetstats resource and method
    ///////////////////////////////////////////  
    
    const creategetstats = YelbAPIGatewayStepFunctions.root.addResource("getstats") 
    
    creategetstats.addMethod(
      "GET",
      new apigateway.Integration({
        type: apigateway.IntegrationType.AWS,
        integrationHttpMethod: "POST",
        uri: `arn:aws:apigateway:${cdk.Aws.REGION}:states:action/StartSyncExecution`,
        options: {
          passthroughBehavior: apigateway.PassthroughBehavior.NEVER,
          credentialsRole: invoke_sm_IRole,
          requestTemplates: {
            "application/json": 
            `{
            "stateMachineArn": "${sm_getstats.stateMachineArn}"
            }`
          },
          integrationResponses: [
            {
              selectionPattern: "200",
              statusCode: "200",
              responseTemplates: {
                "application/json":
                `#set($inputRoot = $input.path('$')) 
                $inputRoot.output`
              }
            }
          ]
        }
      }),
      {
        methodResponses: [
          {
            statusCode: "200"
          }
        ]
      }
    )    
    
    ///////////////////////////////////////////
    // createvoteoutback resource and method
    ///////////////////////////////////////////  

    
    const createvoteoutback = YelbAPIGatewayStepFunctions.root.addResource("outback") 
    
    createvoteoutback.addMethod(
      "GET",
      new apigateway.Integration({
        type: apigateway.IntegrationType.AWS,
        integrationHttpMethod: "POST",
        uri: `arn:aws:apigateway:${cdk.Aws.REGION}:states:action/StartSyncExecution`,
        options: {
          passthroughBehavior: apigateway.PassthroughBehavior.NEVER,
          credentialsRole: invoke_sm_IRole,
          requestTemplates: {
            "application/json": 
            `{
            "input": "{\\"restaurant_name\\": \\"outback\\"}",
            "stateMachineArn": "${sm_restaurant.stateMachineArn}"
            }`
          },
          integrationResponses: [
            {
              selectionPattern: "200",
              statusCode: "200",
              responseTemplates: {
                "application/json":
                `#set($inputRoot = $input.path('$')) 
                $inputRoot.output`
              }
            }
          ]
        }
      }),
      {
        methodResponses: [
          {
            statusCode: "200"
          }
        ]
      }
    )    
    
    ///////////////////////////////////////////
    // createvoteihop resource and method
    ///////////////////////////////////////////  
    
    const createvoteoihop = YelbAPIGatewayStepFunctions.root.addResource("ihop") 
    
    createvoteoihop.addMethod(
      "GET",
      new apigateway.Integration({
        type: apigateway.IntegrationType.AWS,
        integrationHttpMethod: "POST",
        uri: `arn:aws:apigateway:${cdk.Aws.REGION}:states:action/StartSyncExecution`,
        options: {
          passthroughBehavior: apigateway.PassthroughBehavior.NEVER,
          credentialsRole: invoke_sm_IRole,
          requestTemplates: {
            "application/json": 
            `{
            "input": "{\\"restaurant_name\\": \\"ihop\\"}",
            "stateMachineArn": "${sm_restaurant.stateMachineArn}"
            }`
          },
          integrationResponses: [
            {
              selectionPattern: "200",
              statusCode: "200",
              responseTemplates: {
                "application/json":
                `#set($inputRoot = $input.path('$')) 
                $inputRoot.output`
              }
            }
          ]
        }
      }),
      {
        methodResponses: [
          {
            statusCode: "200"
          }
        ]
      }
    )    

    ///////////////////////////////////////////
    // createvotechipotle resource and method
    ///////////////////////////////////////////  

    const createvotechipotle = YelbAPIGatewayStepFunctions.root.addResource("chipotle") 
    
    createvotechipotle.addMethod(
      "GET",
      new apigateway.Integration({
        type: apigateway.IntegrationType.AWS,
        integrationHttpMethod: "POST",
        uri: `arn:aws:apigateway:${cdk.Aws.REGION}:states:action/StartSyncExecution`,
        options: {
          passthroughBehavior: apigateway.PassthroughBehavior.NEVER,
          credentialsRole: invoke_sm_IRole,
          requestTemplates: {
            "application/json": 
            `{
            "input": "{\\"restaurant_name\\": \\"chipotle\\"}",
            "stateMachineArn": "${sm_restaurant.stateMachineArn}"
            }`
          },
          integrationResponses: [
            {
              selectionPattern: "200",
              statusCode: "200",
              responseTemplates: {
                "application/json":
                `#set($inputRoot = $input.path('$')) 
                $inputRoot.output`
              }
            }
          ]
        }
      }),
      {
        methodResponses: [
          {
            statusCode: "200"
          }
        ]
      }
    )
    
    
    ///////////////////////////////////////////
    // createvotebucadibeppo resource and method
    ///////////////////////////////////////////  
  
    const createvotebucadibeppo = YelbAPIGatewayStepFunctions.root.addResource("bucadibeppo") 
    
    createvotebucadibeppo.addMethod(
      "GET",
      new apigateway.Integration({
        type: apigateway.IntegrationType.AWS,
        integrationHttpMethod: "POST",
        uri: `arn:aws:apigateway:${cdk.Aws.REGION}:states:action/StartSyncExecution`,
        options: {
          passthroughBehavior: apigateway.PassthroughBehavior.NEVER,
          credentialsRole: invoke_sm_IRole,
          requestTemplates: {
            "application/json": 
            `{
            "input": "{\\"restaurant_name\\": \\"bucadibeppo\\"}",
            "stateMachineArn": "${sm_restaurant.stateMachineArn}"
            }`
          },
          integrationResponses: [
            {
              selectionPattern: "200",
              statusCode: "200",
              responseTemplates: {
                "application/json":
                `#set($inputRoot = $input.path('$')) 
                $inputRoot.output`
              }
            }
          ]
        }
      }),
      {
        methodResponses: [
          {
            statusCode: "200"
          }
        ]
      }
    )
        
  }
}
