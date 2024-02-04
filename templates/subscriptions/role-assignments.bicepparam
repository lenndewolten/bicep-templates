using 'role-assignments.bicep'

var myPrinicpalId = '488c3017-5222-4e08-9c1f-10e13bd1a764'

// ACR
var acrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
var acrPushRole = '8311e382-0749-4cb8-b61a-304f252e45ec'

// Storage Account
var storageAccountContributorRole = '17d1049b-9a84-46fb-8f53-869881c3d3ab'
var blobDataOwnerRole = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
var queueDataContributorRole = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var tableDataContributorRole = '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
var storageFileDataPrivilegedContributor = '69566ab7-960f-475b-8e7c-b3118f30c6bd'

param roleAssignments = [
  {
    roleDefinitionId: acrPullRole
    principalId: myPrinicpalId
    principalType: 'User'
  }
  {
    roleDefinitionId: acrPushRole
    principalId: myPrinicpalId
    principalType: 'User'
  }
  {
    roleDefinitionId: storageAccountContributorRole
    principalId: myPrinicpalId
    principalType: 'User'
  }
  {
    roleDefinitionId: blobDataOwnerRole
    principalId: myPrinicpalId
    principalType: 'User'
  }
  {
    roleDefinitionId: queueDataContributorRole
    principalId: myPrinicpalId
    principalType: 'User'
  }
  {
    roleDefinitionId: tableDataContributorRole
    principalId: myPrinicpalId
    principalType: 'User'
  }
  {
    roleDefinitionId: storageFileDataPrivilegedContributor
    principalId: myPrinicpalId
    principalType: 'User'
  }
]
