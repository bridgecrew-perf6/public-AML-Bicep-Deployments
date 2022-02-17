// Copyright (c) 2021 Microsoft
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// REQUIRED PARAMS
@description('Location of the Resource Group')
param location string

// OPTIONAL PARAMS
@description('The tags to apply to the container registry')
param tags object = {}

@description('The name of the container registry to be deployed')
param containerRegistryName string

@allowed([
  'Basic'
  'Classic'
  'Premium'
  'Standard'
])
@description('The SKU of the container registry')
param containerRegistrySku string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: containerRegistrySku
  }
  tags: tags
  properties: {
    adminUserEnabled: true
  }
}

output acrId string = containerRegistry.id
