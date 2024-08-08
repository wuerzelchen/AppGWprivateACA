locals {
  backend_address_pool_name       = "${azurerm_resource_group.rg.name}-beap"
  frontend_port_name              = "${azurerm_resource_group.rg.name}-feport"
  frontend_ip_configuration_name  = "${azurerm_resource_group.rg.name}-feip"
  http_setting_name               = "${azurerm_resource_group.rg.name}-be-htst"
  listener_name                   = "${azurerm_resource_group.rg.name}-httplstn"
  request_routing_rule_name       = "${azurerm_resource_group.rg.name}-rqrt"
  redirect_configuration_name     = "${azurerm_resource_group.rg.name}-rdrcfg"
  private_link_configuration_name = "${azurerm_resource_group.rg.name}-plcfg"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "myAppGateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "myIPConfig"
    subnet_id = azurerm_subnet.subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = [azurerm_container_app.my_app.latest_revision_fqdn]
  }

  backend_http_settings {
    name                                = local.http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
  tags = var.tags
}

resource "azurerm_public_ip" "public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
