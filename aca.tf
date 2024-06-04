resource "azurerm_container_app" "my_app" {
  name                         = "backend1"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  revision_mode                = "Single"

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = "myapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      memory = "0.5Gi"
      cpu    = 0.25
    }
  }
}

resource "azurerm_container_app_environment" "aca_env" {
  name                           = "myContainerAppEnv"
  location                       = azurerm_resource_group.rg.location
  resource_group_name            = azurerm_resource_group.rg.name
  internal_load_balancer_enabled = true
  infrastructure_subnet_id       = azurerm_subnet.acasubnet.id
}


