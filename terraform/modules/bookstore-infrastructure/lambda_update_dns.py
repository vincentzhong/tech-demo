import json
import boto3
import os

ecs_client = boto3.client('ecs')
ec2_client = boto3.client('ec2')
route53_client = boto3.client('route53')

HOSTED_ZONE_ID = os.environ['HOSTED_ZONE_ID']
DOMAIN_NAME = os.environ['DOMAIN_NAME']
CLUSTER_NAME = os.environ['CLUSTER_NAME']
SERVICE_NAME = os.environ['SERVICE_NAME']

def lambda_handler(event, context):
    """
    Triggered by ECS task state change events.
    Updates Route53 A record with the new task's public IP.
    """
    print(f"Received event: {json.dumps(event)}")
    
    # Check if this is a task state change to RUNNING
    detail = event.get('detail', {})
    last_status = detail.get('lastStatus')
    desired_status = detail.get('desiredStatus')
    group = detail.get('group', '')

    print(f"Task status - Last: {last_status}, Desired: {desired_status}, Group: {group}")

    # Only process tasks that belong to the ECS service (not one-off migration tasks)
    expected_group = f"service:{SERVICE_NAME}"
    if group != expected_group:
        print(f"Task is not part of service {SERVICE_NAME} (group: {group}), skipping...")
        return {'statusCode': 200, 'body': 'Not a service task'}

    # Only process when task reaches RUNNING state AND is not stopping
    if last_status != 'RUNNING' or desired_status != 'RUNNING':
        print(f"Task not in stable RUNNING state (last: {last_status}, desired: {desired_status}), skipping...")
        return {'statusCode': 200, 'body': 'Task not running or stopping'}
    
    # Get the task ARN from the event
    task_arn = detail.get('taskArn')
    if not task_arn:
        print("No task ARN found in event")
        return {'statusCode': 400, 'body': 'No task ARN'}
    
    print(f"Processing task: {task_arn}")
    
    try:
        # Get task details
        tasks_response = ecs_client.describe_tasks(
            cluster=CLUSTER_NAME,
            tasks=[task_arn]
        )
        
        if not tasks_response['tasks']:
            print("Task not found")
            return {'statusCode': 404, 'body': 'Task not found'}
        
        task = tasks_response['tasks'][0]
        
        # Find the network interface ID
        eni_id = None
        for attachment in task.get('attachments', []):
            if attachment['type'] == 'ElasticNetworkInterface':
                for detail in attachment['details']:
                    if detail['name'] == 'networkInterfaceId':
                        eni_id = detail['value']
                        break
        
        if not eni_id:
            print("No network interface found")
            return {'statusCode': 404, 'body': 'No ENI found'}
        
        print(f"Found ENI: {eni_id}")
        
        # Get the public IP from the network interface
        eni_response = ec2_client.describe_network_interfaces(
            NetworkInterfaceIds=[eni_id]
        )
        
        if not eni_response['NetworkInterfaces']:
            print("Network interface not found")
            return {'statusCode': 404, 'body': 'ENI not found'}
        
        public_ip = eni_response['NetworkInterfaces'][0].get('Association', {}).get('PublicIp')
        
        if not public_ip:
            print("No public IP found for task")
            return {'statusCode': 404, 'body': 'No public IP'}
        
        print(f"Found public IP: {public_ip}")
        
        # Update Route53 A record
        response = route53_client.change_resource_record_sets(
            HostedZoneId=HOSTED_ZONE_ID,
            ChangeBatch={
                'Comment': f'Auto-updated by Lambda for ECS task {task_arn}',
                'Changes': [
                    {
                        'Action': 'UPSERT',
                        'ResourceRecordSet': {
                            'Name': DOMAIN_NAME,
                            'Type': 'A',
                            'TTL': 60,
                            'ResourceRecords': [{'Value': public_ip}]
                        }
                    }
                ]
            }
        )
        
        print(f"Successfully updated DNS record for {DOMAIN_NAME} to {public_ip}")
        print(f"Route53 change ID: {response['ChangeInfo']['Id']}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'DNS updated successfully',
                'domain': DOMAIN_NAME,
                'ip': public_ip,
                'task_arn': task_arn
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

