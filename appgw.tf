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
    name = "frontendPort"
    port = 80
  }

  request_routing_rule {
    name                       = "example-rule"
    rule_type                  = "Basic"
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "backendPool"
    backend_http_settings_name = "httpSettings"
    priority                   = 1
  }

  frontend_ip_configuration {
    name                            = "frontendConfig"
    public_ip_address_id            = azurerm_public_ip.public_ip.id
    private_link_configuration_name = "myPrivateLinkConfig"
  }

  private_link_configuration {
    name = "myPrivateLinkConfig"
    ip_configuration {
      name                          = "myPrivateLinkIPConfig"
      primary                       = true
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = azurerm_subnet.acasubnet.id
    }
  }

  backend_address_pool {
    name  = "backendPool"
    fqdns = [azurerm_container_app.my_app.latest_revision_fqdn]
  }

  backend_http_settings {
    name                                = "httpSettings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "frontendConfig"
    frontend_port_name             = "frontendPort"
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
