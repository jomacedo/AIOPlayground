# Azure IoT Operations on Ubuntu (20/22/24.04) - Quick Start

* Install Azure CLI
```bash
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```
* Login to Azure CLI and select the target subscription
```bash
az login
```
* Set environment variables for the rest of the setup. Replace values in <> with valid values or names of your choice. CLUSTER_NAME needs to be lower case. A new cluster and resource group are created in your Azure subscription based on the names you provide:
```bash
# Id of the subscription where your resource group and Arc-enabled cluster will be created
export SUBSCRIPTION_ID=<SUBSCRIPTION_ID>

# Azure region where the created resource group will be located
# Currently supported regions: "eastus", "eastus2", "westus", "westus2", "westus3", "westeurope", or "northeurope"
export LOCATION="northeurope"

# Name of the resource group created to host the VM. It will also hold the Arc-enabled cluster and Azure IoT Operations resources
export RESOURCE_GROUP=<NEW_RESOURCE_GROUP_NAME>

# Name of the VM to create in your resource group
export VM_NAME=<NEW_VM_NAME>

# Name of the Arc-enabled cluster to create in your resource group
export CLUSTER_NAME=<NEW_CLUSTER_NAME> # lower case
```
* Set the Azure subscription context for all commands:
```bash
az account set -s $SUBSCRIPTION_ID
```
* Register the required resource providers in your subscription:
```bash
az provider register -n "Microsoft.ExtendedLocation"
az provider register -n "Microsoft.Kubernetes"
az provider register -n "Microsoft.KubernetesConfiguration"
az provider register -n "Microsoft.DeviceRegistry"
az provider register -n "Microsoft.IoTOperations"
```
* Deploy an Ubuntu 24.04/22.04/20.04 VM on a Resource Group (recommended SKU Standard_D4s class) 
```bash
az vm create -g $RESOURCE_GROUP -n $VM_NAME --image "UbuntuLTS" --admin-username "azureuser" --generate-ssh-keys --size Standard_D4s_v3 --location $LOCATION --ssh-key-name $VM_NAME 
```