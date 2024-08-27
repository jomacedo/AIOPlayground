@description('Location for cloud resources')
param aioExtensionName string = 'aio'
param clusterName string = 'clusterName'
param eventGridNamespaceName string = 'default'

resource connectedCluster 'Microsoft.Kubernetes/connectedClusters@2021-10-01' existing = {
  name: clusterName
}

resource aioExtension 'Microsoft.KubernetesConfiguration/extensions@2022-11-01' existing = {
  name: aioExtensionName
  scope: connectedCluster
}

resource egNamespace 'Microsoft.EventGrid/namespaces@2024-06-01-preview' existing = {
  name: eventGridNamespaceName
}

// Role assignment for Event Grid Data Contributor role
resource roleAssignmentDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(egNamespace.id, aioExtension.id, '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  scope: egNamespace
  properties: {
     // ID for Event Grid Data Contributor role is 1d8c3fe3-8864-474b-8749-01e3783e8157
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '1d8c3fe3-8864-474b-8749-01e3783e8157') 
    principalId: aioExtension.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
