# Setup Instructions

## Azure Resource Setup

### 1. Create Service Principal with OIDC

```bash
# Set variables
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="rg-container-demo"
APP_NAME="github-actions-workwithcontainers"

# Create Service Principal
az ad sp create-for-rbac \
  --name $APP_NAME \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --json-auth
```

### 2. Configure OIDC in Azure

```bash
# Get the Application ID from the previous command
APPLICATION_ID="your-app-id"
REPOSITORY="yuriemori-org/work-with-containers"

# Configure OIDC
az ad app federated-credential create \
  --id $APPLICATION_ID \
  --parameters '{
    "name": "github-actions",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:'$REPOSITORY':ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### 3. GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

- `AZURE_CLIENT_ID`: Application (client) ID from step 1
- `AZURE_TENANT_ID`: Directory (tenant) ID
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID

### 4. Deploy Infrastructure

```bash
# Deploy using Azure CLI
az deployment group create \
  --resource-group rg-container-demo \
  --template-file bicep/main.bicep \
  --parameters @bicep/main.parameters.json
```

## Local Development

### Prerequisites
- Node.js 18+
- .NET 8 SDK
- Docker

### Frontend
```bash
cd frontend
npm install
npm run dev
# Access at http://localhost:3000
```

### Backend
```bash
cd backend
dotnet run
# Access at http://localhost:5000
```

## Container Testing

### Build Images Locally
```bash
# Frontend
cd frontend
docker build -t frontend-local .
docker run -p 3000:3000 frontend-local

# Backend
cd backend
docker build -t backend-local .
docker run -p 8080:80 backend-local
```