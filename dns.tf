resource "azurerm_private_dns_zone" "dnszone" {
  name                = join(".", slice(split(".", azurerm_container_app.my_app.latest_revision_fqdn), 1, length(split(".", azurerm_container_app.my_app.latest_revision_fqdn))))
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_container_app.my_app]
  tags                = var.tags
}

resource "azurerm_private_dns_a_record" "example_star" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.dnszone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.aca_env.static_ip_address] # Replace with your static IP
}

resource "azurerm_private_dns_a_record" "example_at" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.dnszone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.aca_env.static_ip_address] # Replace with your static IP
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "my-custom-vnet-pdns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnszone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id # Replace with your VNet ID
}
