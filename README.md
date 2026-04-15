# DevOps Full-Stack Experiment

> A complete DevOps project demonstrating Docker containerization, CI/CD automation, and AWS cloud deployment for a React application.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Part 1: Docker Multi-Stage Build](#part-1-docker-multi-stage-build)
- [Part 2: CI/CD Pipeline with GitHub Actions](#part-2-cicd-pipeline-with-github-actions)
- [Part 3: AWS Deployment with Load Balancing](#part-3-aws-deployment-with-load-balancing)
- [Complete Deployment Workflow](#complete-deployment-workflow)

---

## Project Overview

This project covers three core DevOps practices as one unified experiment:

| Part | Topic | Key Technologies |
|------|-------|-----------------|
| **1** | Containerization | Docker, Nginx, Multi-stage builds |
| **2** | CI/CD Automation | GitHub Actions, GHCR |
| **3** | Cloud Deployment | AWS ECS, ALB, Terraform, Auto-scaling |

---

## Project Structure

```
devops-fullstack-experiment/
├── public/index.html                  # React HTML entry
├── src/
│   ├── App.js                         # Main React component
│   ├── App.css                        # App styles
│   ├── App.test.js                    # Unit tests (for CI)
│   ├── index.js                       # React entry point
│   ├── index.css                      # Global styles
│   └── setupTests.js                  # Test configuration
├── package.json                       # Dependencies & scripts
│
├── Dockerfile                         # Part 1: Multi-stage build
├── nginx.conf                         # Part 1: Nginx configuration
├── .dockerignore                      # Part 1: Docker build exclusions
├── .env.example                       # Environment variable template
│
├── .github/workflows/
│   ├── ci-cd.yml                      # Part 2: Main CI/CD pipeline
│   └── test.yml                       # Part 2: PR test workflow
│
├── terraform/
│   ├── main.tf                        # Part 3: Provider config
│   ├── variables.tf                   # Part 3: Input variables
│   ├── outputs.tf                     # Part 3: Output values
│   ├── vpc.tf                         # Part 3: VPC + Subnets
│   ├── ecs.tf                         # Part 3: ECS Fargate
│   ├── alb.tf                         # Part 3: Load Balancer
│   ├── autoscaling.tf                 # Part 3: Auto-scaling
│   └── terraform.tfvars               # Part 3: Variable values
│
├── .gitignore                         # Git exclusions
└── README.md                          # This file
```

---

## Prerequisites

| Tool | Version | Installation |
|------|---------|-------------|
| **Node.js** | 18+ | https://nodejs.org |
| **Docker Desktop** | 20.10+ | https://docker.com/products/docker-desktop |
| **Git** | Latest | https://git-scm.com |
| **GitHub Account** | — | https://github.com |
| **AWS CLI** | Latest | https://aws.amazon.com/cli (Part 3 only) |
| **Terraform** | 1.5+ | https://terraform.io (Part 3 only) |
| **VS Code** | Latest | https://code.visualstudio.com |

---

## Part 1: Docker Multi-Stage Build

### Aim
To containerize a React application using Docker multi-stage builds for optimized production deployment.

### Objectives
1. Create Dockerfile with build stage
2. Configure production-ready Nginx server
3. Optimize image size (target: under 100MB)
4. Handle environment variables
5. Build and run Docker container

### How Multi-Stage Build Works

```
┌─────────────────────────────────┐
│  STAGE 1: BUILD (node:18-alpine)│
│                                 │
│  1. Copy package.json           │
│  2. npm ci (install deps)       │
│  3. Copy source code            │
│  4. npm run build               │
│  5. Output: /app/build/         │
└──────────────┬──────────────────┘
               │ COPY build files only
               ▼
┌─────────────────────────────────┐
│  STAGE 2: PROD (nginx:alpine)  │
│                                 │
│  1. Copy nginx.conf             │
│  2. Copy /app/build → nginx     │
│  3. Expose port 8080            │
│  4. Serve static files          │
│                                 │
│  Final image size: ~40-80MB     │
│  (Node.js is NOT included!)    │
└─────────────────────────────────┘
```

### Key Files Explained

#### Dockerfile
- **Stage 1 (build):** Uses `node:18-alpine` as base, installs dependencies with `npm ci`, builds the React app with `npm run build`
- **Stage 2 (production):** Uses `nginx:alpine` (~40MB), copies ONLY the built static files from Stage 1, configures health check
- **Why multi-stage?** Without it, the image would include Node.js, node_modules, source code (~1GB+). Multi-stage discards everything except the built files.

#### nginx.conf
- **Port 8080:** Nginx listens for HTTP requests on port 8080
- **Gzip:** Compresses JS, CSS, HTML, JSON, SVG files before sending (reduces size by ~70%)
- **Caching:** Static assets cached by browser for 1 year (React uses content hashes in filenames)
- **SPA Fallback:** All routes redirect to index.html (required for React Router)
- **Security Headers:** X-Frame-Options, X-Content-Type-Options, etc.

#### .dockerignore
- Prevents large/unnecessary files from being sent to Docker during build
- Excludes: node_modules, .git, terraform/, .github/, .env files

### Step-by-Step Execution

```bash
# Step 1: Navigate to project directory
cd devops-fullstack-experiment

# Step 2: Install dependencies (to test locally first)
npm install

# Step 3: Run locally to verify it works
npm start
# → Opens http://localhost:3000

# Step 4: Run tests
npm test
# → All tests should pass

# Step 5: Build Docker image
docker build -t devops-experiment:latest .
# → This runs both stages of the Dockerfile

# Step 6: Verify image size
docker images devops-experiment
# → Should show size < 100MB

# Step 7: Run the container
docker run -d -p 8080:8080 --name devops-app devops-experiment:latest
# -d = run in background (detached mode)
# -p 8080:8080 = map host port 8080 to container port 8080
# --name = give the container a name

# Step 8: Test in browser
# Open: http://localhost:8080

# Step 9: Verify gzip compression
curl -H "Accept-Encoding: gzip" -I http://localhost:8080
# → Look for "Content-Encoding: gzip" in response

# Step 10: Check container health
docker ps
# → Status should show "healthy"

# Step 11: View container logs
docker logs devops-app

# Step 12: Stop and remove container (when done)
docker stop devops-app
docker rm devops-app
```

### Expected Output
- ✅ Production-ready Docker image under 100MB
- ✅ React application served via Nginx on port 8080
- ✅ Gzip compression enabled
- ✅ Proper caching headers for static assets

---

## Part 2: CI/CD Pipeline with GitHub Actions

### Aim
To implement an automated CI/CD pipeline for React applications using GitHub Actions.

### Objectives
1. Configure GitHub Actions workflow
2. Implement testing stage
3. Set up Docker build and push
4. Deploy to GitHub Packages (GHCR)
5. Add deployment notifications

### Pipeline Architecture

```
┌──────────────────────────────────────────────────────┐
│                    TRIGGERS                          │
│  Push to main ──► ci-cd.yml                         │
│  Pull Request ──► test.yml                          │
└──────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────┐
│              ci-cd.yml PIPELINE                      │
│                                                      │
│  ┌──────────┐    ┌─────────────┐    ┌──────────┐    │
│  │  🧪 TEST │───►│ 🐳 BUILD &  │───►│ 📢 NOTIFY│    │
│  │          │    │    PUSH     │    │          │    │
│  │ npm test │    │ docker build│    │  Slack   │    │
│  │          │    │ push to GHCR│    │          │    │
│  └──────────┘    └─────────────┘    └──────────┘    │
│  (if fail→stop)  (needs: test)   (needs: build)     │
└──────────────────────────────────────────────────────┘
```

### Key Files Explained

#### .github/workflows/ci-cd.yml
This is the **main pipeline** that runs on every push to `main`:

1. **Test Job:**
   - Checks out code from GitHub
   - Sets up Node.js 18
   - Installs dependencies with `npm ci`
   - Runs `npm test` — if tests fail, pipeline stops

2. **Build-and-Push Job** (only runs if tests pass):
   - Sets up Docker Buildx (advanced builder)
   - Logs into GitHub Container Registry (GHCR)
   - Builds Docker image using our multi-stage Dockerfile
   - Tags image with `latest` AND the commit SHA (e.g., `abc1234`)
   - Pushes both tags to GHCR
   - Uses GitHub Actions cache for faster builds

3. **Notify Job** (only runs if build succeeds):
   - Sends a Slack message with deployment details
   - Includes: image URL, commit SHA, author, commit message

#### .github/workflows/test.yml
This is the **PR testing workflow**:
- Runs ONLY on pull requests targeting `main`
- Runs tests + build check (ensures code compiles)
- Shows ✅ or ❌ on the PR

### Step-by-Step Execution

```bash
# Step 1: Create a GitHub repository
# Go to github.com → New Repository → Name it "devops-fullstack-experiment"

# Step 2: Initialize git and push
cd devops-fullstack-experiment
git init
git add .
git commit -m "Initial commit: React app with Docker, CI/CD, and Terraform"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/devops-fullstack-experiment.git
git push -u origin main

# Step 3: Watch the pipeline run
# Go to GitHub → your repo → "Actions" tab
# You should see "CI/CD Pipeline" running with 3 jobs

# Step 4: Test the PR workflow
git checkout -b feature/test-pr
echo "// test change" >> src/App.js
git add .
git commit -m "test: PR workflow trigger"
git push origin feature/test-pr
# → Create a Pull Request on GitHub
# → "PR Tests" workflow will run automatically

# Step 5: Check the container registry
# Go to GitHub → your profile → "Packages" tab
# → You'll see the Docker image with "latest" and SHA tags

# Step 6: (Optional) Set up Slack notifications
# Create a Slack webhook URL and add it as a GitHub secret:
# Repository → Settings → Secrets → New → Name: SLACK_WEBHOOK_URL
```

### Expected Output
- ✅ Automated testing on PR creation
- ✅ Docker image built and pushed to GitHub Container Registry
- ✅ Slack notifications on successful deployment
- ✅ Image tagged with both "latest" and commit SHA

---

## Part 3: AWS Deployment with Load Balancing

### Aim
To deploy a full-stack application on AWS with load balancing and auto-scaling.

### Objectives
1. Configure AWS infrastructure (VPC, EC2, ALB)
2. Set up auto-scaling group
3. Deploy Docker containers to ECS
4. Configure application load balancer
5. Implement CI/CD pipeline

### AWS Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                     │
│                                                              │
│  ┌─────────────────────┐      ┌─────────────────────┐        │
│  │  Public Subnet 1    │      │  Public Subnet 2    │        │
│  │  (10.0.1.0/24)      │      │  (10.0.2.0/24)      │        │
│  │  AZ: us-east-1a     │      │  AZ: us-east-1b     │        │
│  │                     │      │                     │        │
│  │  ┌───────────────┐  │      │  ┌───────────────┐  │        │
│  │  │  ECS Task     │  │      │  │  ECS Task     │  │        │
│  │  │  (Container)  │  │      │  │  (Container)  │  │        │
│  │  │  Port 8080    │  │      │  │  Port 8080    │  │        │
│  │  └───────┬───────┘  │      │  └───────┬───────┘  │        │
│  └──────────┼──────────┘      └──────────┼──────────┘        │
│             │                            │                   │
│             └────────────┬───────────────┘                   │
│                          │                                   │
│              ┌───────────▼────────────┐                      │
│              │  Application Load      │                      │
│              │  Balancer (ALB)        │                      │
│              │  Port 80               │                      │
│              └───────────┬────────────┘                      │
│                          │                                   │
│              ┌───────────▼────────────┐                      │
│              │  Internet Gateway      │                      │
│              └───────────┬────────────┘                      │
└──────────────────────────┼───────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │   Internet  │
                    │   (Users)   │
                    └─────────────┘

Auto-Scaling: 2-4 tasks based on CPU utilization
  - Scale UP:   CPU > 70% for 2 minutes → add 1 task
  - Scale DOWN: CPU < 30% for 5 minutes → remove 1 task
```

### Key Files Explained

#### terraform/vpc.tf — Network Infrastructure
- **VPC (10.0.0.0/16):** Your private network with 65,536 IP addresses
- **2 Public Subnets:** In different Availability Zones for redundancy
- **Internet Gateway:** Connects VPC to the internet
- **Route Table:** Routes internet traffic through the gateway

#### terraform/ecs.tf — Container Service
- **ECS Cluster:** Logical grouping for containerized applications
- **Task Definition:** Specifies container image, CPU (256), memory (512MB), port (8080)
- **ECS Service:** Ensures 2 tasks are always running, replaces crashed tasks
- **IAM Roles:** Permissions for pulling Docker images and writing logs
- **Security Group:** Only allows traffic from the ALB on port 8080

#### terraform/alb.tf — Load Balancer
- **ALB:** Distributes incoming traffic across ECS tasks
- **Target Group:** Health-checks each task (hits `/` every 30 seconds)
- **Listener:** Receives traffic on port 80, forwards to target group
- **Security Group:** Allows HTTP (80) and HTTPS (443) from anywhere

#### terraform/autoscaling.tf — Auto-Scaling
- **Min 2 tasks:** Always running for high availability
- **Max 4 tasks:** Upper limit during high traffic
- **Scale Up:** When CPU > 70% for 2 consecutive minutes, add 1 task
- **Scale Down:** When CPU < 30% for 5 consecutive minutes, remove 1 task
- **CloudWatch Alarms:** Monitor CPU and trigger scaling policies

### Step-by-Step Execution

```bash
# Step 1: Install Terraform
# Download from: https://terraform.io/downloads
# Add to PATH

# Step 2: Configure AWS CLI
aws configure
# → Enter your AWS Access Key ID
# → Enter your AWS Secret Access Key
# → Region: us-east-1
# → Output format: json

# Step 3: Update terraform.tfvars
# Edit terraform/terraform.tfvars
# Change "your-username" to your actual GitHub username

# Step 4: Initialize Terraform
cd terraform
terraform init
# → Downloads AWS provider plugin

# Step 5: Preview changes (DRY RUN — creates nothing)
terraform plan
# → Shows exactly what resources will be created
# → Review the output carefully

# Step 6: Apply changes (CREATES REAL AWS RESOURCES)
terraform apply
# → Type "yes" to confirm
# → Wait 3-5 minutes for resources to be created
# → Output shows the ALB DNS name

# Step 7: Access the application
# Copy the alb_dns_name from the output
# Open in browser: http://<alb-dns-name>

# Step 8: Verify auto-scaling
# Check AWS Console → ECS → Clusters → devops-experiment-cluster
# You should see 2 running tasks

# Step 9: IMPORTANT — Clean up (avoid charges!)
terraform destroy
# → Type "yes" to confirm
# → All AWS resources are deleted
```

### Deployment Workflow
1. `terraform apply` to provision infrastructure
2. Push code to GitHub to trigger pipeline
3. CI/CD pipeline builds and deploys Docker image
4. ALB distributes traffic across ECS tasks
5. Auto-scaling adjusts capacity based on CPU load

### Expected Output
- ✅ Highly available application across 2 AZs
- ✅ Load-balanced traffic with auto-scaling (2–4 instances)
- ✅ Zero-downtime deployments
- ✅ Infrastructure as Code (IaC) management

---

## Complete Deployment Workflow

```
Developer Machine                GitHub                    AWS
      │                            │                        │
      │  git push                  │                        │
      ├───────────────────────────►│                        │
      │                            │  CI/CD triggers        │
      │                            ├──── Test ────►         │
      │                            ├──── Build ───►         │
      │                            ├──── Push to GHCR ─►    │
      │                            │                        │
      │                            │  terraform apply       │
      │                            │ ──────────────────────►│
      │                            │                        │ VPC created
      │                            │                        │ ECS cluster up
      │                            │                        │ ALB configured
      │                            │                        │ Auto-scaling set
      │                            │                        │
      │                      ◄─────┤──── Slack Notify ─────│
      │                            │                        │
      │  Access via ALB DNS        │                        │
      ├────────────────────────────┼───────────────────────►│
      │                            │                        │ Traffic distributed
      │  ◄─── App Response ───────┼────────────────────────┤
```

---

## Quick Reference Commands

```bash
# ── React ──
npm install          # Install dependencies
npm start            # Run locally (port 3000)
npm test             # Run tests
npm run build        # Production build

# ── Docker ──
docker build -t devops-experiment .          # Build image
docker images devops-experiment              # Check size
docker run -d -p 8080:8080 devops-experiment # Run container
docker ps                                    # List running containers
docker stop <container-id>                   # Stop container
docker logs <container-id>                   # View logs

# ── Terraform ──
cd terraform
terraform init       # Initialize
terraform plan       # Preview changes
terraform apply      # Create resources
terraform destroy    # Delete all resources

# ── Git ──
git init
git add .
git commit -m "message"
git push origin main
```
