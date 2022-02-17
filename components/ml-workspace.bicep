// Copyright (c) 2021 Microsoft
// 
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

param appInsightsId string
param storageId string
param keyVaultId string
param containerRegistryId string

@description('The name of the AML Workspace')
param workspaceName string

@description('Location of the Resource Group')
param location string = resourceGroup().location

@description('Tags for AML Workspace, will also be populated on networking components.')
param tags object

resource machineLearningWorkspace 'Microsoft.MachineLearningServices/workspaces@2020-09-01-preview' = {
  name: workspaceName
  location: location
  sku:{
    name: 'basic'
    tier: 'basic'
  }
  properties:{
    friendlyName: workspaceName
    storageAccount: storageId
    keyVault: keyVaultId
    containerRegistry: containerRegistryId
    applicationInsights: appInsightsId
    hbiWorkspace: true
  }
  tags: tags
  identity:{
    type: 'SystemAssigned'
  }
}

output id string = machineLearningWorkspace.id
output name string = machineLearningWorkspace.name
