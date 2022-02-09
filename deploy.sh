#!/usr/bin/env bash

# Login to Kubernetes Cluster.
if [ -n "$CLUSTER_ROLE_ARN" ]; then
	aws eks \
	  --region ${AWS_REGION} \
	  update-kubeconfig --name ${CLUSTER_NAME} \
          --role-arn=${CLUSTER_ROLE_ARN}
else
	aws eks \
	  --region ${AWS_REGION} \
          update-kubeconfig --name ${CLUSTER_NAME} 
fi

# Helm Deployment
if [ -n "$DEPLOY_NAMESPACE" ]; then
    case ${GITHUB_REF##*/} in
      test)
        DEPLOY_NAMESPACE=test
      ;;
      staging)
        DEPLOY_NAMESPACE=staging
      ;;
      main)
        DEPLOY_NAMESPACE=production
      ;; 
    esac
    echo ${NAMESPACE}
fi

if [ -n "$DEPLOY_CHART_PATH" ]; then
   DEPLOY_CHART_PATH="helm/${APP_NAME}"
fi

if [ -n "$DEPLOY_CONFIG_FILES" ]; then
   DEPLOY_CONFIG_FILES="${DEPLOY_NAMESPACE}.yaml"
fi

if [ -n "$DEPLOY_NAME" ]; then
   DEPLOY_NAME="${DEPLOY_NAMESPACE}-${APP_NAME}"
fi

if [ -n "$DEPLOY_IMAGE_TAG" ]; then
   IMAGE_TAG="${GITHUB_SHA_SHORT}"
fi


helm upgrade --install \
     --set-string image.tag=${DEPLOY_IMAGE_TAG} \
     --namespace ${DEPLOY_NAMESPACE} \
     -f ${DEPLOY_CHART_PATH}/${DEPLOY_CONFIG_FILES} ${DEPLOY_NAME} ${DEPLOY_CHART_PATH}
