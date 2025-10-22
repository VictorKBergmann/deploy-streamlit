# Streamlit Deployer
A production-ready boilerplate for deploying any Python Streamlit application to AWS EC2 using a fully automated CI/CD pipeline.

This repository is designed to be a "template" for your own projects. It uses Terraform for Infrastructure as Code (IaC), Docker for containerization, and GitHub Actions for continuous deployment.

The example app downloads a dataset from Kaggle and displays the row count, serving as a template for handling data apps with external API secrets.

## Core Features
- Application: Python Streamlit (example uses pandas and kaggle)
- Containerization: Docker & Docker Hub
- Infrastructure (IaC): Terraform
- Cloud Provider: AWS (using a t2.micro EC2 instance to stay in the Free Tier)
- CI/CD: GitHub Actions
- Secret Management: Handles API keys (e.g., Kaggle) securely via GitHub Secrets and injects them into the running container at runtime.

## Architecture Diagram
This diagram shows the end-to-end workflow, from pushing code to a live application.

```mermaid
flowchart TD
    subgraph GitHub
        A[1. Developer pushes to 'main'] --> B{GitHub Actions};
    end

    subgraph "Job 1: Build & Push"
        B --> C[Build Docker Image];
        C --> D[Push to Docker Hub];
    end

    subgraph "Job 2: Deploy"
        D -- triggers --> E{GitHub Actions};
        E --> F[Run Terraform Apply];
        F --> G[SSH into EC2];
    end

    subgraph "AWS EC2 Instance"
        G --> H[Pull image from Docker Hub];
        H --> I[Stop old container];
        I --> J[Run new container w/ Secrets];
        J --> K[Streamlit App @ Port 8501];
    end

    L[User] -->|Browser| M(http://ec2-ip:8501);
    K -.-> M;

    style AWS EC2 Instance fill:#FF9900,stroke:#333
    style GitHub fill:#181717,stroke:#fff,color:#fff
    style D fill:#0db7ed,stroke:#333
```
# Getting Started: Replicating This Project
Follow these steps to get your own version of this project running.

Prerequisites
Accounts:
- GitHub Account
- AWS Account (with billing enabled)
- Docker Hub Account
- Kaggle Account (for this specific demo)

Local Tools:
- Terraform CLI
- AWS CLI (configured with your credentials)
- Docker Desktop (for local testing)

### Step 1: Fork & Clone
Fork this repository to your own GitHub account and clone it to your local machine.
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
```

### Step 2: Local Test (Optional, but Recommended)
You can run the entire stack locally before deploying.

Create .env file: Create a file named .env in the root of the project. This is ignored by git and holds your local secrets.

```bash
# .env
KAGGLE_USERNAME=your_kaggle_username
KAGGLE_KEY=your_kaggle_api_key
Test with Docker: Build and run the container. The --env-file flag injects your local secrets.
```

```bash
# Build the image
docker build -t olist-app .

# Run the image
docker run --rm -p 8501:8501 --env-file .env olist-app
```

Open http://localhost:8501 in your browser. The app should load and (on first run) download the Kaggle data.

### Step 3: Provision Infrastructure with Terraform
1. Create AWS Key Pair: Go to the AWS EC2 Console, navigate to "Key Pairs", and create a new key pair named deployer-key. Download the .pem file and save it to a secure location (e.g., ~/.ssh/deployer-key.pem).
2. Run Terraform: Navigate to the infra/ directory and run:

```bash
cd infra
terraform init
terraform apply
```
- Terraform will ask for confirmation. Type yes.
- This will create the t2.micro EC2 instance and a Security Group that opens port 22 (SSH) and 8501 (Streamlit).
- At the end, Terraform will output the public_ip of your new server. Copy this IP address.
Note: The ami in infra/main.tf is for an Ubuntu 22.04 LTS in us-east-1. If you use a different region, you will need to find the correct AMI ID.

### Step 4: Configure GitHub Secrets
This is the most crucial step. Go to your forked repository's Settings > Secrets and variables > Actions and add the following Repository secrets:
- AWS_ACCESS_KEY_ID: Your AWS IAM user access key.
- AWS_SECRET_ACCESS_KEY: Your AWS IAM user secret key.
- DOCKERHUB_USERNAME: Your Docker Hub username.
- DOCKERHUB_TOKEN: A Docker Hub Access Token.
- EC2_PUBLIC_IP: The IP address you copied from the terraform apply output.
- EC2_USERNAME: ubuntu (this is the default user for the Ubuntu AMI).
- EC2_SSH_KEY: The entire content of your deployer-key.pem file. Open the file, copy everything (including -----BEGIN RSA PRIVATE KEY-----...).
- KAGGLE_USERNAME: Your Kaggle username.
- KAGGLE_KEY: Your Kaggle API key.

### Step 5: Update Workflow & Deploy
1. Create Docker Hub Repo: Create a new public repository on Docker Hub (e.g., my-username/olist-app).
2. Update Workflow File: Open .github/workflows/deploy.yml and update the tags: line to point to your new Docker Hub repository:

```YAML
# ... inside deploy.yml
      - name: Build and Push
        uses: docker/build-push-action@v4
        with:
          # ...
          # MUST UPDATE THIS LINE:
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/olist-app:latest # Change 'olist-app' if needed
```
3. Push to Deploy: Commit and push your changes to the main branch.

```bash
git add .
git commit -m "Configure CI/CD for deployment"
git push origin main
```
Go to the "Actions" tab in your GitHub repo. You will see the pipeline running. When it's finished, your app will be live!

Access it at: http://[YOUR_EC2_PUBLIC_IP]:8501