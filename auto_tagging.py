import json
import boto3
import logging
from botocore.exceptions import ClientError


logger = logging.getLogger()
logger.setLevel(logging.INFO)

def aws_create_tag(_aws_region, _instance_id: str, _key_name: str, _tag_value: str):
    try:
        client = boto3.client('ec2', region_name=_aws_region)
        client.create_tags(Resources=[_instance_id, ], Tags=[{'Key': _key_name, 'Value': _tag_value}, ])
        logging.info(f'successfuly created tag {_key_name} for instance {_instance_id}')
    except ClientError:
        logging.info(str(ClientError))
        return False
    return True


def lambda_handler(event, context):
    if 'detail' in event:
        try:
            if 'userIdentity' in event['detail']:
                if event['detail']['userIdentity']['type'] == 'AssumedRole':
                    #user_name = str(event['detail']['userIdentity']['principalId'].split(':')[1] + ', Role: ' + event['detail']['userIdentity']['sessionContext']['sessionIssuer']['userName'] + ' (role)')
                    user_name = str(event['detail']['userIdentity']['principalId'].split(':')[1])
                    #user_name = boto3.client('sts').get_caller_identity()['UserId'].split(':')[1]
                elif event['detail']['userIdentity']['type'] == 'IAMUser':
                    user_name = event['detail']['userIdentity']['userName']
                elif event['detail']['userIdentity']['type'] == 'Root':
                    user_name = 'root'
                else:
                    logging.info('Could not determine username (unknown iam userIdentity) ')
                    user_name = ''
            else:
                logging.info('Could not determine username (no userIdentity data in cloudtrail')
                user_name = ''
            if event['detail']['userAgent'].find("Terraform") >= 0 or event['detail']['userAgent'].find("terraform") >= 0:
                project_name = 'Terraform'
            else:
                project_name = event['detail']['userAgent']
        except Exception as e:
            logging.info('could not find username, exception: ' + str(e))
            user_name = ''
        try:
            instance_id = [x['instanceId'] for x in event['detail']['responseElements']['instancesSet']['items']]
        except Exception as e:
            instance_id = []
        aws_region = event['detail']['awsRegion']
        client = boto3.client('ec2', region_name=aws_region)
        if instance_id:
            for instance in instance_id:
                # tag instance
                instance_api = client.describe_instances(InstanceIds=[instance])
                # get all ec2 instance tags
                if 'Tags' in instance_api['Reservations'][0]['Instances'][0]:
                    instance_tags = instance_api['Reservations'][0]['Instances'][0]['Tags']
                else:
                    instance_tags = []
                # check 'Name' tag is exist 
                if instance_tags:
                    instance_name = [x['Value'] for x in instance_tags if x['Key'] and x['Key'] == 'Name']
                    if instance_name:
                        instance_name = instance_name[0]
                else:
                    instance_name = ''
                # check 'Owner' tag exist 
                if instance_tags:
                    if not any(keys.get('Key') == 'Owner' for keys in instance_tags):
                        logging.info(f'Tag "Owner" doesn\'t exist for instance {instance}, creating...')
                        aws_create_tag(aws_region, instance, 'Owner', user_name)
                    else:
                        logging.info(f'Owner tag already exist for instance {instance}')
                    if not any(keys.get('Key') == 'Schedule' for keys in instance_tags):
                        logging.info(f'Tag "Schedule" doesn\'t exist for instance {instance}, creating...')
                        aws_create_tag(aws_region, instance, 'Schedule', 'vn-office-hours')   
                    else:
                        logging.info(f'Schedule tag already exist for instance {instance}')
                    if not any(keys.get('Key') == 'project' for keys in instance_tags):
                        logging.info(f'Tag "project" doesn\'t exist for instance {instance}, creating...')
                        aws_create_tag(aws_region, instance, 'project', project_name)   
                    else:
                        logging.info(f'Schedule tag already exist for instance {instance}')
                else:
                    logging.info(f'Instance {instance} has no tags, let\'s tag it with Owner tag')
                    aws_create_tag(aws_region, instance, 'Owner', user_name)
                    aws_create_tag(aws_region, instance, 'Schedule', 'vn-office-hours')
                    aws_create_tag(aws_region, instance, 'project', project_name)  
        
                # tag ebs volumes
                instance_volumes = [x['Ebs']['VolumeId'] for x in instance_api['Reservations'][0]['Instances'][0]['BlockDeviceMappings']]
                # check volume has tags
                for volume in instance_volumes:
                    response = client.describe_volumes(VolumeIds=[volume])
                    volume_tags = [x['Tags'] for x in response['Volumes'] if 'Tags' in x]
                    if volume_tags:
                        # if any(keys.get('Key') == 'Owner' and keys.get('Key') == 'AttachedInstance' and keys.get('Key') == 'Schedule' for keys in
                        if any(keys.get('Key') == 'Owner' and keys.get('Key') == 'AttachedInstance' and keys.get('Key') == 'project' for keys in volume_tags[0]):
                            logging.info(f'Nothing to tag for volume {volume} of instance: {instance}, is already tagged')
                            continue
                        if not any(keys.get('Key') == 'Owner' for keys in volume_tags[0]):
                            logging.info(f'Tag "Owner" doesn\'t exist, creating...')
                            aws_create_tag(aws_region, volume, 'Owner', user_name)
                        if not any(keys.get('Key') == 'AttachedInstance' for keys in volume_tags[0]):
                            logging.info(f'Tag "AttachedInstance" doesn\'t exist, creating...')
                            aws_create_tag(aws_region, volume, 'AttachedInstance', instance + ' - ' + str(instance_name))
                        if not any(keys.get('Key') == 'project' for keys in volume_tags[0]):
                           logging.info(f'Tag "project" doesn\'t exist, creating...')
                           aws_create_tag(aws_region, instance, 'project', project_name)
                    else:
                        logging.info(f'volume {volume} is not tagged, adding Owner and AttachedInstance and Schedule tags')
                        aws_create_tag(aws_region, volume, 'AttachedInstance', instance + ' - ' + str(instance_name))
                        aws_create_tag(aws_region, volume, 'Owner', user_name)
                        aws_create_tag(aws_region, instance, 'project', project_name)
                        #aws_create_tag(aws_region, volume, 'Schedule', 'vn-office-hours')
            return {
                'statusCode': 200,
                'body': json.dumps('All Done!')
            }
        else:
            return {
                'statusCode': 200,
                'body': json.dumps('No Data!')
            }
