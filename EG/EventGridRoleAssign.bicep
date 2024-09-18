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

// Role assignment for EventGrid TopicSpaces Publisher role
resource roleAssignmentTopicS 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(egNamespace.id, aioExtension.id, '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  scope: egNamespace
  properties: {
     // ID for EventGrid TopicSpaces Publisher role is a12b0b94-b317-4dcd-84a8-502ce99884c6
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'a12b0b94-b317-4dcd-84a8-502ce99884c6') 
    principalId: aioExtension.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Role assignment for EventGrid TopicSpaces Subscriber role
resource roleAssignmentDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(egNamespace.id, aioExtension.id, '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  scope: egNamespace
  properties: {
     // ID for EventGrid TopicSpaces Subscriber role is 4b0f2fd7-60b4-4eca-896f-4435034f8bf5
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '4b0f2fd7-60b4-4eca-896f-4435034f8bf5') 
    principalId: aioExtension.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
