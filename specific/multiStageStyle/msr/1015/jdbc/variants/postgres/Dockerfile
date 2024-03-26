# trunk-ignore-all(checkov/CKV_DOCKER_2,checkov/CKV_DOCKER_3,checkov/CKV_DOCKER_7)
ARG __from_img=NOT_OPTIONAL
FROM ${__from_img}

# Follow tha same arguments as the ones in the original Dockerfile
ARG __sag_home=/opt/softwareag
ARG __user_group_id=1724

COPY --chown=${__user_group_id}:${__user_group_id} ./ ${__sag_home}/IntegrationServer/packages/WmJDBCAdapter/code/jars/
