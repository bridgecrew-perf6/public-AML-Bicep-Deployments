# AML Bicep Deployment

## Introduction
This repo is a template for deploying Azure Machine Learning workspaces in an automated fashion using GitHub Actions. Please see general information regarding Bicep and ARM templates [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep).

## Personalization
Users will see the following two user-defined variables in `main.bicep`:

1. `teamID` to allow a quick-turn capability for deploying multiple AML workspaces in the same Azure Resource Group, and 
   
2. `needVNet` for defining whether the AML resources should be set within a VNet.

## GitHub Actions
This template is intended to be used with GitHub Actions. General instructions for setting up the necessary Action secrets can be found [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-github-actions?tabs=CLI).

One should be sure to place the `deploy.yml` file into a `.github/workflows` directory to queue up the GitHub Actions.

## Suggestions
In order to ensure resources are approved before deployment, this repo is set to only run the Action on a push to the `main` branch. For security purposes, it is suggested that groups allow updates to the `main` branch only through pull requests and have all resource deployments completed through such a pull request.
