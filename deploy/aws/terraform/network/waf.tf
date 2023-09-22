resource "aws_wafv2_web_acl" "om_api_waf" {
  #checkov:skip=CKV2_AWS_31: "Investigation needed before enabling logging for WAF"
  name        = local.waf_name
  description = "Web Application Firewall"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  #Rule 1
  rule {
    name     = "Rate-Limit"
    priority = 1

    action {
      dynamic "count" {
        for_each = var.rate-limit-default-action == "count" ? [""] : []
        content {}
      }

      dynamic "block" {
        for_each = var.rate-limit-default-action == "block" ? [""] : []
        content {}
      }
    }

    statement {
      rate_based_statement {
        limit              = var.rate-limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      metric_name                = "Rate-Limit"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  #Rule 2
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 2
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
        excluded_rule {
          name = "SizeRestrictions_BODY"
        }
        excluded_rule {
          name = "GenericRFI_BODY"
        }
      }
    }
    override_action {
      none {
      }
    }

    visibility_config {
      metric_name                = "AWSManagedRulesCommonRuleSet"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  #Rule 3
  rule {
    name     = "API-Particular-Region-Only"
    priority = 3
    action {
      allow {}
    }

    statement {
      geo_match_statement {
        country_codes = var.ld-api-country-codes
      }
    }

    visibility_config {
      metric_name                = "API-Particular-Region-Only"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  #Rule 4
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  #General logging
  visibility_config {
    metric_name                = "waf-metrics"
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
  }
  tags = var.default-tags
}

#Associate the application load balancer (ALB) with the web appication firewall (WAF)
resource "aws_wafv2_web_acl_association" "waf-alb-association" {
  resource_arn = aws_lb.load-balancer.arn
  web_acl_arn  = aws_wafv2_web_acl.om_api_waf.arn
}
