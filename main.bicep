// Copyright (c) 2021 Microsoft
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

@description('Tags to apply to all created resources')
param tags object = json(loadTextContent('tags.json'))

@description('A name to be used as the base name for the created resources')
param resourceGroupName string

@description('Location of the Resource Group')
param location string = resourceGroup().location

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)

// VARIABLES SET BY THE USER
// Unique Team ID
var teamID = 'Demo' 

// Is a VNet required?
var needVNet = false

// Container Registry SKU
// Allowed values: 'Basic', 'Classic', 'Premium', 'Standard'
var crSku = 'Premium'

// Storage SKU
// Allowed values: 'Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 
//                 'Standard_ZRS', 'Premium_LRS', 'Premium_ZRS', 
//                 'Standard_GZRS', 'Standard_RAGZRS'
var storageSkuName = 'Standard_LRS'

// VNET
module vnet 'components/vnet.bicep' = if(needVNet) {
  name: 'vnet-deployment'
  params:{
    location: location
    // VNET Settings
    vnetName: '${teamID}-vnet-${resourceGroupName}-${uniqueSuffix}'
    addressPrefixes: [
      '10.100.0.0/16'
    ]
    // Subnet Settings
    subnetName: 'aml-subnet'
    subnetPrefix: '10.100.1.0/24'   
    // Tags
    tags: tags
  }
}

// Container Registry in VNet
module acrvnet 'components/container-registry-vnet.bicep' = if(needVNet) {
  name: 'acrvnet-deployment'
  params: {
    location: location
    containerRegistryName: '${teamID}cr${resourceGroupName}${uniqueSuffix}'
    vnet: needVNet ? vnet.outputs.details : {}
    containerRegistrySku: crSku
    tags: tags
  }
}

// Container Registry
module acr 'components/container-registry.bicep' = if(!needVNet) {
  name: 'acr-deployment'
  params: {
    location: location
    containerRegistryName: '${teamID}cr${resourceGroupName}${uniqueSuffix}'
    containerRegistrySku: crSku
    tags: tags
  }
}

// Application Insights
module ai 'components/app-insights.bicep' = {
  name: 'ai-deployment'
  params:{
    location: location
    applicationInsightsName: '${teamID}-ai-${resourceGroupName}-${uniqueSuffix}'
    tags: tags
  }
}

// Storage
// No resourceGroupN here.
// Hard-coded the storageAccountName for ease here.
module storagevnet 'components/storage-vnet.bicep' = if(needVNet) {
  name: 'storage-deployment'
  params:{
    location: location
    storageAccountName: toLower('${teamID}sa${resourceGroupName}${uniqueSuffix}')
    vnet: needVNet ? vnet.outputs.details : {}
    tags: tags
    storageSkuName: storageSkuName
  }
}

// Storage
module storage 'components/storage.bicep' = if(!needVNet) {
  name: 'storage-vnet-deployment'
  params:{
    location: location
    storageAccountName: toLower('${teamID}sa${resourceGroupName}${uniqueSuffix}')
    tags: tags
    storageSkuName: storageSkuName
  }
}

// Key Vault with VNet
module keyvaultvnet 'components/key-vault-vnet.bicep' = if(needVNet) {
  name: 'keyvault-vnet-deployment'
  params:{
    location: location
    keyVaultName: '${teamID}-kv-${resourceGroupName}-${uniqueSuffix}'
    vnet: needVNet ? vnet.outputs.details : {}
    tags: tags
  }
}

// Key Vault
module keyvault 'components/key-vault.bicep' = if(!needVNet) {
  name: 'keyvault-deployment'
  params:{
    location: location
    keyVaultName: '${teamID}-kv-${resourceGroupName}-${uniqueSuffix}'
    tags: tags
  }
}

// ML Workspace with VNet
module workspacevnet 'components/ml-workspace-vnet.bicep' = if(needVNet) {
  name: 'ml-workspace-vnet-deployment'
  params:{
    location: location
    workspaceName: '${teamID}-ws-${resourceGroupName}-${uniqueSuffix}${teamID}'
    storageId: needVNet ? storagevnet.outputs.storageAccountId : ''
    appInsightsId: ai.outputs.appInsightsId
    containerRegistryId: needVNet ? acrvnet.outputs.acrId : ''
    keyVaultId: needVNet ? keyvaultvnet.outputs.keyVaultId : ''
    vnet: needVNet ? vnet.outputs.details : {}
    tags: tags
  }
}

// ML Workspace
module workspace 'components/ml-workspace.bicep' = if(!needVNet) {
  name: 'ml-workspace-deployment'
  params:{
    location: location
    workspaceName: '${teamID}-ws-${resourceGroupName}-${uniqueSuffix}${teamID}'
    storageId: !needVNet ? storage.outputs.storageAccountId : ''
    appInsightsId: ai.outputs.appInsightsId
    containerRegistryId: !needVNet ? acr.outputs.acrId : ''
    keyVaultId: !needVNet ? keyvault.outputs.keyVaultId : ''
    tags: tags
  }
}

output workspaceName string = (needVNet) ? workspacevnet.outputs.name : workspace.outputs.name
output workspaceId string = (needVNet) ? workspacevnet.outputs.id : workspace.outputs.id
