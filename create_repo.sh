#!/bin/bash

export AWS_DEFAULT_REGION=us-west-2

aws ecr create-repository --repository-name reinvent/app1 || true
aws ecr create-repository --repository-name reinvent/app2  || true
aws ecr create-repository --repository-name reinvent/app3  || true