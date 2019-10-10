#!/bin/bash

systemctl stop amazon-ssm-agent 
amazon-ssm-agent -register -code "<ssm_activiation_code>" -id "<ssm_id>" -region "<region>"
systemctl start amazon-ssm-agent
