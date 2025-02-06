package terraform.validation

import input.resource_changes as resources

# -------------------------------------------------------------
# Rule 1: Deny resources without a 'Name' tag
# -------------------------------------------------------------

deny_missing_name_tag[msg] if {
    resource := resources[_]
    resource.change.after.tags_all != null
    not resource.change.after.tags_all["Name"]
    msg := sprintf("Resource '%s' is missing a 'Name' tag. All resources must have a 'Name' tag.", [resource.address])
}

# -------------------------------------------------------------
# Rule 2: Deny resources with a cost greater than 0.05 USD/hour
# -------------------------------------------------------------

instance_prices := {
    "t2.micro": 0.0116,
    "t2.small": 0.023,
    "t2.medium": 0.0464,
    "t2.large": 0.0928,
    "t2.xlarge": 0.1856
}

deny_ec2_cost[msg] if {
    resource := resources[_]
    resource.type == "aws_instance"
    instance_type := resource.change.after.instance_type
    instance_prices[instance_type] != null
    cost := instance_prices[instance_type]
    cost > 0.05
    msg := sprintf("Instance '%s' of type '%s' has a cost of %0.4f USD/hour. Only instances with a cost lower than 0.05 USD/hour are allowed.", [resource.address, instance_type, cost])
}

# -------------------------------------------------------------
# Rule 3: Deny security groups allowing all inbound traffic
# -------------------------------------------------------------

deny_sg_ingress[msg] if {
    resource := resources[_]
    resource.type == "aws_security_group"
    some idx
    ingress_rule := resource.change.after.ingress[idx]
    ingress_rule.from_port == 0
    ingress_rule.to_port == 0
    some j
    ingress_rule.cidr_blocks[j] == "0.0.0.0/0"
    ingress_rule.protocol == "-1"
    msg := sprintf("Security group '%s' allows all inbound traffic from the internet. Only allow inbound traffic from specific IP ranges.", [resource.address])
}

# -------------------------------------------------------------
# Aggregate all violations in one rule
# -------------------------------------------------------------

violations[msg] if {
    deny_missing_name_tag[msg]
}

violations[msg] if {
    deny_ec2_cost[msg]
}

violations[msg] if {
    deny_sg_ingress[msg]
}

# -------------------------------------------------------------
# Rule to count total violations
# -------------------------------------------------------------

violations_count = count({ msg | violations[msg] })
