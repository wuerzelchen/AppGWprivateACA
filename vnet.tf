resource "azurerm_virtual_network" "vnet" {
  name                = "appGW-VNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                                          = "AppGWSubnet"
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = ["10.0.1.0/24"]
  private_link_service_network_policies_enabled = false
}

resource "azurerm_subnet" "acasubnet" {
  name                                          = "ACASubnet"
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = ["10.0.2.0/23"]
  private_link_service_network_policies_enabled = false
}
