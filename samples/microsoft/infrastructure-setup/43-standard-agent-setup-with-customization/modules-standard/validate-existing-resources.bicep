// @description('Resource ID of the AI Service Account. ')
// param aiServiceAccountResourceId string

@description('Resource ID of the AI Search Service.')
param aiSearchResourceId string

@description('Resource ID of the Azure Storage Account.')
param azureStorageAccountResourceId string

@description('ResourceId of Cosmos DB Account')
param azureCosmosDBAccountResourceId string

@description('Resource ID of the existing Azure OpenAI Resource.')
param existingAoaiResourceId string = ''

// Check if existing resources have been passed in
var storagePassedIn = azureStorageAccountResourceId != ''
var searchPassedIn = aiSearchResourceId != ''
var cosmosPassedIn = azureCosmosDBAccountResourceId != ''
var aoaiPassedIn = existingAoaiResourceId != ''

var storageParts = split(azureStorageAccountResourceId, '/')
var azureStorageSubscriptionId = storagePassedIn && length(storageParts) > 2 ? storageParts[2] : subscription().subscriptionId
var azureStorageResourceGroupName = storagePassedIn && length(storageParts) > 4 ? storageParts[4] : resourceGroup().name

var acsParts = split(aiSearchResourceId, '/')
var aiSearchServiceSubscriptionId = searchPassedIn && length(acsParts) > 2 ? acsParts[2] : subscription().subscriptionId
var aiSearchServiceResourceGroupName = searchPassedIn && length(acsParts) > 4 ? acsParts[4] : resourceGroup().name

var cosmosParts = split(azureCosmosDBAccountResourceId, '/')
var cosmosDBSubscriptionId = cosmosPassedIn && length(cosmosParts) > 2 ? cosmosParts[2] : subscription().subscriptionId
var cosmosDBResourceGroupName = cosmosPassedIn && length(cosmosParts) > 4 ? cosmosParts[4] : resourceGroup().name

// If the existing AI OpenAI resource ID is passed in, extract the subscription ID, resource group name, and name
var existingAoaiResourceIdParts = split(existingAoaiResourceId, '/')
var aoaiSubscriptionId = aoaiPassedIn ? existingAoaiResourceIdParts[2] : subscription().subscriptionId
var aoaiResourceGroupName = aoaiPassedIn ? existingAoaiResourceIdParts[4] : resourceGroup().name


// Validate AI Search
resource aiSearch 'Microsoft.Search/searchServices@2024-06-01-preview' existing = if (searchPassedIn) {
  name: last(split(aiSearchResourceId, '/'))
  scope: resourceGroup(aiSearchServiceSubscriptionId, aiSearchServiceResourceGroupName)
}

// Validate Cosmos DB Account
resource cosmosDBAccount 'Microsoft.DocumentDB/databaseAccounts@2024-12-01-preview' existing = if (cosmosPassedIn) {
  name: last(split(azureCosmosDBAccountResourceId, '/'))
  scope: resourceGroup(cosmosDBSubscriptionId,cosmosDBResourceGroupName)
}

// Validate Storage Account
resource azureStorageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' existing = if (storagePassedIn) {
  name: last(split(azureStorageAccountResourceId, '/'))
  scope: resourceGroup(azureStorageSubscriptionId,azureStorageResourceGroupName)
}

// Validate existing Azure OpenAI resource if passed in
resource existingAoaiResource 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = if (aoaiPassedIn) {
  name: last(split(existingAoaiResourceId, '/'))
  scope: resourceGroup(aoaiSubscriptionId, aoaiResourceGroupName)
}

// output aiServiceExists bool = aiServicesPassedIn && (aiServiceAccount.name == aiServiceParts[8])
output aiSearchExists bool = searchPassedIn && (aiSearch.name == acsParts[8])
output cosmosDBExists bool = cosmosPassedIn && (cosmosDBAccount.name == cosmosParts[8])
output azureStorageExists bool = storagePassedIn && (azureStorageAccount.name == storageParts[8])
output aoaiExists bool = aoaiPassedIn && (existingAoaiResource.name == existingAoaiResourceIdParts[8])

output aiSearchServiceSubscriptionId string = aiSearchServiceSubscriptionId
output aiSearchServiceResourceGroupName string = aiSearchServiceResourceGroupName

output cosmosDBSubscriptionId string = cosmosDBSubscriptionId
output cosmosDBResourceGroupName string = cosmosDBResourceGroupName

output azureStorageSubscriptionId string = azureStorageSubscriptionId
output azureStorageResourceGroupName string = azureStorageResourceGroupName

output aoaiSubscriptionId string = aoaiSubscriptionId
output aoaiResourceGroupName string = aoaiResourceGroupName
