@description('The name of the Azure Container Registry')
param acrName string = 'crworkithcontainer001'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The name prefix for App Services')
param appServicePrefix string = 'app-container-demo'

@description('The SKU for App Service Plan')
param appServicePlanSku string = 'B1'

@description('The name of Application Insights')
param applicationInsightsName string = 'ai-container-demo'

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
  }
}

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appServicePrefix}-plan'
  location: location
  sku: {
    name: appServicePlanSku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Container Registry (assuming it already exists, just referencing it)
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

// Frontend App Service
resource frontendAppService 'Microsoft.Web/sites@2022-03-01' = {
  name: '${appServicePrefix}-frontend'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/frontend:latest'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistry.properties.loginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistry.name
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }
  }
}

// Backend App Service
resource backendAppService 'Microsoft.Web/sites@2022-03-01' = {
  name: '${appServicePrefix}-backend'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/backend:latest'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistry.properties.loginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistry.name
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }
  }
}

// Outputs
output frontendUrl string = 'https://${frontendAppService.properties.defaultHostName}'
output backendUrl string = 'https://${backendAppService.properties.defaultHostName}'
output applicationInsightsName string = applicationInsights.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer