[OUTPUT]
    Name cloudwatch_logs
    Match   *
    region ${region}
    log_group_name /aws/eks/fargate/${project}
    log_stream_prefix ${project}-
    log_retention_days 60
    auto_create_group true
