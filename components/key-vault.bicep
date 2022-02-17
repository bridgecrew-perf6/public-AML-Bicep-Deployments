// Copyright (c) 2021 Microsoft
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// REQUIRED 
@description('Location of the Resource Group')
param location string

@description('Name of the key vault.')
param keyVaultName string

@description('Tags for key vault, will also be populated on networking components.')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties:{
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
  }
}

output keyVaultId string = keyVault.id
