# Azure IoT Operations on Ubuntu (20/22/24.04) - Quick Start - Test Settings

* Install Azure CLI in your Machine

```bash {"id":"01J9P2GSRJCXT6MXXXQWGVCHC7"}
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

* Login to Azure CLI and select the target subscription

```bash {"id":"01J9P2GSRJCXT6MXXXR04QN41S"}
az login
```

* Set environment variables for the rest of the setup. Replace values in <> with valid values or names of your choice. CLUSTER_NAME needs to be lower case. A new cluster and resource group are created in your Azure subscription based on the names you provide:

```bash {"id":"01J9P2GSRJCXT6MXXXR1KRG7SW"}
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

```bash {"id":"01J9P2GSRJCXT6MXXXR49NGRH1"}
az account set -s $SUBSCRIPTION_ID
```

* Register the required resource providers in your subscription:

```bash {"id":"01J9P2GSRJCXT6MXXXR6BEKQP4"}
az provider register -n "Microsoft.ExtendedLocation"
az provider register -n "Microsoft.Kubernetes"
az provider register -n "Microsoft.KubernetesConfiguration"
az provider register -n "Microsoft.DeviceRegistry"
az provider register -n "Microsoft.IoTOperations"
```

* Deploy an Ubuntu 24.04/22.04/20.04 VM on a Resource Group (recommended SKU Standard_D4s class)

```bash {"id":"01J9P2GSRJCXT6MXXXR9V8GY67"}
az vm create -g $RESOURCE_GROUP -n $VM_NAME --image Ubuntu2204 --admin-username "azureuser" --generate-ssh-keys --size Standard_D4s_v3 --location $LOCATION --ssh-key-name $VM_NAME 
```

* Connect to the machine via SSH/Bastion (if Bastion, use Bastion Developer)

```bash {"id":"01J9P2HAKKQQTJBJXHZG2C630T"}
ssh azureuser@<VM_IP_ADDRESS>
```

* Run the following commands to ensure the system is up to date.

```bash {"id":"01J9P2NX1C9PW880E979592EBD"}
sudo apt update && sudo apt upgrade 
```

* Run this command from https://docs.k3s.io/quick-start to install K3s
   * Take a look at https://docs.k3s.io/advanced#configuring-an-http-proxy to install if you are behind a proxy

```bash {"id":"01J9P2PSZWRZCP5KD3MHSNP0ZM"}
curl -sfL https://get.k3s.io | sh -
```

* Create a K3s configuration yaml file in .kube/config

```bash {"id":"01J9P3163GWYQVNSVK59G148M7"}
mkdir ~/.kube
sudo KUBECONFIG=~/.kube/config:/etc/rancher/k3s/k3s.yaml kubectl config view --flatten > ~/.kube/merged
mv ~/.kube/merged ~/.kube/config
chmod  0600 ~/.kube/config
export KUBECONFIG=~/.kube/config
#switch to k3s context
kubectl config use-context default
```

* Run the following commands to increase the [user watch/instance limits](https://www.suse.com/support/kb/doc/?id=000020048) and the file descriptor limit:

```bash {"id":"01J9P34K8YC7TEG9XEZ9YBPNGQ"}
echo fs.inotify.max_user_instances=8192 | sudo tee -a /etc/sysctl.conf
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
echo fs.file-max = 100000 | sudo tee -a /etc/sysctl.conf

sudo sysctl -p
```

* Install Azure CLI in the AIO VM

```bash {"id":"01J9P2GSRJCXT6MXXXQWGVCHC7"}
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

* Login to Azure CLI and select the target subscription

```bash {"id":"01J9P2GSRJCXT6MXXXR04QN41S"}
az login
```

* Set environment variables for the rest of the setup. Use the same values as in the Host machine setup.

```bash {"id":"01J9P2GSRJCXT6MXXXR1KRG7SW"}
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

```bash {"id":"01J9P2GSRJCXT6MXXXR49NGRH1"}
az account set -s $SUBSCRIPTION_ID
```

Use the [az connectedk8 connect](https://learn.microsoft.com/en-us/cli/azure/connectedk8s#az-connectedk8s-connect) command to Arc-enable your Kubernetes cluster and manage it in the resource group you created in the previous step:

```bash {"id":"01J9P35Z635FFWQD8P07N5BARE"}
az connectedk8s connect -n $CLUSTER_NAME -l $LOCATION -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID
```

* Run the following commands to facilitate kubectl commands.

```bash {"id":"01J9PF3XC9GYQH3R3GYQJ30158"}
if ! grep -q "# Kubernetes config" ~/.bashrc; then
        cat <<EOF >>~/.bashrc

# Kubernetes config
if command -v kubectl &> /dev/null; then
    alias k=$(command -v kubectl)
    source <(kubectl completion bash)
    source <(kubectl completion bash | sed s/kubectl/k/g)

    alias kcd='kubectl config set-context $(kubectl config current-context) --namespace '
    #export KUBE_EDITOR='code --wait'
    export KUBE_EDITOR='nano'
fi
EOF
fi
```

* Install K9s for a better Kubernetes management experience.

```bash {"id":"01J9PFDQX0AP229B4Q68ZAW13K"}
if ! command -v k9s &>/dev/null; then
    sudo snap install k9s
    #bug in installer
    sudo ln -s /snap/k9s/current/bin/k9s /usr/bin
fi
```