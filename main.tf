resource "azurerm_resource_group" "rg" {
  name     = "appgwtest"
  location = "West Europe"
  tags     = var.tags
}
