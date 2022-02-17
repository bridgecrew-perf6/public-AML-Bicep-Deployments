// Copyright (c) 2021 Microsoft
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// REQUIRED PARAMS
@description('VNet object - with schema {name: "[vnet-name]", id: "[vnet-id], subnet: {name: "[subnet-name]", id: "[subnet-id]"}}')
param vnet object

@description('Location of the Resource Group')
param location string

// OPTIONAL PARAMS
@description('The name of the storage account')
param storageAccountName string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
@description('The SKU to use for the Storage Account')
param storageSkuName string

@description('The tags to apply to the container registry')
param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  kind: 'StorageV2'
  location: location
  tags: tags
  name: storageAccountName
  sku: {
    name: storageSkuName
  }
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules:[
        {
          id: vnet.subnet.id
        }
      ]
    }
    allowBlobPublicAccess: false
  }
}

module privateLink 'storage-private-link.bicep' = {
  name: '${deployment().name}-PrivateLink'
  params:{
    location: location
    baseResource: {
      name: storageAccount.name
      id: storageAccount.id
    }
    tags: tags
    vnet: vnet
    groups: [
      {
        name: 'blob'
        uri: 'privatelink.blob.${environment().suffixes.storage}'
      }
      {
        name: 'file'
        uri: 'privatelink.file.${environment().suffixes.storage}'
      }
    ]
  }
}

output storageAccountId string = storageAccount.id
