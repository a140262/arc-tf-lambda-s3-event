var fs = require('fs');
var AWS = require('aws-sdk');
var ecs = new AWS.ECS({apiVersion: '2014-11-13'});
var path = require('path');

// Check if the given key suffix matches a suffix in the whitelist. Return true if it matches, false otherwise.
exports.checkS3SuffixWhitelist = function(key, whitelist) {
    if(!whitelist){ return true; }
    if(typeof whitelist == 'string'){ return key.match(whitelist + '$') }
    if(Object.prototype.toString.call(whitelist) === '[object Array]') {
        for(var i = 0; i < whitelist.length; i++) {
            if(key.match(whitelist[i] + '$')) { return true; }
        }
        return false;
    }
    console.log(
        'Unsupported whitelist type (' + Object.prototype.toString.call(whitelist) +
        ') for: ' + JSON.stringify(whitelist)
    );
    return false;
};

exports.handler = function (event, context, callback) {

    console.log("====================");
    console.log("REQUEST: " + JSON.stringify(event));
    console.log("====================");

    var config = JSON.parse(fs.readFileSync('config.json', 'utf8'));
    console.log('Config: ' + JSON.stringify(config));

    
    var bucket = event.Records[0].s3.bucket.name;
    var key=decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));  
    var uri="s3a://".concat(bucket,"/",key)
    
    if(!exports.checkS3SuffixWhitelist(key, process.env.s3_key_suffix_whitelist)) {
        context.fail('Suffix for key: ' + key + ' is not in the whitelist')
    }
    
    launchEcsTask(uri,config);

};

function launchEcsTask (etl_config_uri,config) {

    console.log('Deploying an ARC Job as ECS task')
    
    var job_name = path.basename(etl_config_uri).replace(/.json/g,'')
    var is_stream = etl_config_uri.toLowerCase().includes('stream')
    var params = {
        cluster: process.env.CLUSTER_NAME,
        taskDefinition: process.env.TASK_ID,
        count: config.APP_COUJNT,
        launchType: "FARGATE",
        networkConfiguration: {
            awsvpcConfiguration: {
                subnets: [config.SUBNET_ID],
                assignPublicIp: "DISABLED",
                securityGroups: [config.ECS_TASK_SG]
            }
        },
          overrides: {
            containerOverrides: [
              {
                environment: [
                  {
                    name: "ETL_CONF_URI",
                    value: etl_config_uri
                  },
                  {
                    name: "ETL_CONF_STREAMING",
                    value: is_stream.toString()
                  },
                  {
                    name: "ETL_CONF_JOB_NAME",
                    value: job_name
                  }
                ],
                name: config.CONTAINER_NAME
              }
            ]
          }
        };

    ecs.runTask(params, function(err, data) {
        if (err) console.log(err, err.stack); // an error occurred
        else     console.log(data);           // successful response
    });

}