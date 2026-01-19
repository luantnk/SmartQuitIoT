# SmartQuitIoT

<p align="center">
  <img src="images/logo.png" alt="SmartQuitIoT Logo" width="300" />
</p>

<p align="center">
  <strong>Smart Smoking Cessation Platform with IoT Device Support</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Project-FA25SE084-blue?style=for-the-badge" alt="Project Code" />
  <img src="https://img.shields.io/badge/Group-GFA25SE97-green?style=for-the-badge" alt="Group Code" />
  <img src="https://img.shields.io/badge/FPT-University-orange?style=for-the-badge" alt="FPT University" />
</p>

---

## Table of Contents

- [Introduction](#introduction)
- [Key Features & Scope](#key-features--scope)
- [Technology Stack](#technology-stack)
- [System Architecture & Design](#system-architecture--design)
- [Team Members & Supervisors](#team-members--supervisors)
- [Project Resources](#project-resources)

---

## Introduction

**SmartQuitIoT** is an intelligent smoking cessation support platform designed to bridge the gap between personal willpower and data-driven healthcare. By integrating **Artificial Intelligence (AI)** with **IoT wearable devices**, the system continuously monitors biometric indicators (heart rate, SpO₂, step count, sleep duration) to generate evidence-based, personalized quit plans.

### Vision

Create a world where anyone can access professional, personalized support to quit smoking through AI coaches and human experts to improve adherence to quit plans and track measurable health progress.

### Solution Architecture

The solution consists of two main interfaces backed by a robust backend:

- **Mobile Application (Member)**: A personal companion for users to track habits, sync IoT data, receive AI advice, and chat with coaches.
- **Web Portal (Coach & Admin)**: A management dashboard for coaches to monitor member health data, manage video call appointments and for admins to manage the system.

---

## Key Features & Scope

### Member (Mobile App)

- **Personalized AI Plans**: Generate quit plans and missions based on user metrics and smoking history
- **IoT Integration**: Sync health data (Heart rate, SpO₂, Steps, Sleep duration) from smart watch via 3rd party software.
- **Tracking & Analytics**: Log daily smoking diaries, track expenditures, and visualize health recovery timelines
- **Consultation**: Chat with AI Assistant or book appointments/chat directly with human Coaches
- **Gamification**: Earn achievements, view leaderboards, and receive motivational notifications

### Coach (Web Portal)

- **Member Monitoring**: View member profiles and analyzed health data to provide accurate advice
- **Consultation**: Conduct online chat consultations and manage appointment schedules

### Admin (Web Portal)

- **System Management**: Manage Members, Coaches, Community Posts, and News
- **Configuration**: Manage Membership packages, Achievement criteria, and System Pass conditions
- **Analytics**: View overall system reports and dashboards

---

## 🛠️ Technology Stack

### Frontend
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

### Backend (Core Service)
![Java](https://img.shields.io/badge/Java_21-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot_3.5.6-6DB33F?style=for-the-badge&logo=spring-boot&logoColor=white)
![Spring Security](https://img.shields.io/badge/Spring_Security-6DB33F?style=for-the-badge&logo=spring-security&logoColor=white)
![Spring Data JPA](https://img.shields.io/badge/Spring_Data_JPA-6DB33F?style=for-the-badge&logo=spring&logoColor=white)
![Spring Cloud](https://img.shields.io/badge/Spring_Cloud-6DB33F?style=for-the-badge&logo=spring&logoColor=white)
![Spring AI](https://img.shields.io/badge/Spring_AI-6DB33F?style=for-the-badge&logo=spring&logoColor=white)
![WebSocket](https://img.shields.io/badge/WebSocket-010101?style=for-the-badge&logo=socket.io&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-C71A36?style=for-the-badge&logo=apache-maven&logoColor=white)
![Resilience4j](https://img.shields.io/badge/Resilience4j-00ADD8?style=for-the-badge&logo=&logoColor=white)

### AI
![Python](https://img.shields.io/badge/Python_3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Uvicorn](https://img.shields.io/badge/Uvicorn-2C2D72?style=for-the-badge&logo=gunicorn&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-EE4C2C?style=for-the-badge&logo=pytorch&logoColor=white)
![Transformers](https://img.shields.io/badge/Transformers-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black)
![ONNX](https://img.shields.io/badge/ONNX-005CED?style=for-the-badge&logo=onnx&logoColor=white)
![NumPy](https://img.shields.io/badge/NumPy-013243?style=for-the-badge&logo=numpy&logoColor=white)
![Pydantic](https://img.shields.io/badge/Pydantic-E92063?style=for-the-badge&logo=pydantic&logoColor=white)

### Database & Caching
![MariaDB](https://img.shields.io/badge/MariaDB_12.1.2-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![Redis](https://img.shields.io/badge/Redis_8.4.0-DC382D?style=for-the-badge&logo=redis&logoColor=white)
![Elasticsearch](https://img.shields.io/badge/Elasticsearch_9.2.3-005571?style=for-the-badge&logo=elasticsearch&logoColor=white)

### Message Broker
![RabbitMQ](https://img.shields.io/badge/RabbitMQ_4.2.2-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white)
![AMQP](https://img.shields.io/badge/AMQP-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white)

### AI Models & Integration
![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)
![Google Gemini](https://img.shields.io/badge/Google_Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white)
![Hugging Face](https://img.shields.io/badge/Hugging_Face-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black)

**Pre-trained Models:**
- `unitary/toxic-bert` - Toxic content detection
- `Falconsai/nsfw_image_detection` - NSFW image classification
- `openai/whisper-small` - Speech-to-Text
- `microsoft/speecht5_tts` - Text-to-Speech
- `microsoft/speecht5_hifigan` - Audio vocoder

**Custom ONNX Models:**
- Success Prediction Model - Quit plan success probability
- Craving Time Model - Peak craving forecasting (96 time slots/day)

### Development Tools & IDEs
![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![IntelliJ IDEA](https://img.shields.io/badge/IntelliJ_IDEA-000000?style=for-the-badge&logo=intellij-idea&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)

### Design & Modeling
![DrawIO](https://img.shields.io/badge/DrawIO-F08705?style=for-the-badge&logo=diagrams.net&logoColor=white)
![Visual Paradigm](https://img.shields.io/badge/Visual_Paradigm-0078D7?style=for-the-badge&logo=&logoColor=white)

### Testing & Quality Assurance
![JUnit5](https://img.shields.io/badge/JUnit_5-25A162?style=for-the-badge&logo=junit5&logoColor=white)
![Mockito](https://img.shields.io/badge/Mockito-C5D928?style=for-the-badge&logo=&logoColor=black)
![Pytest](https://img.shields.io/badge/Pytest-0A9EDC?style=for-the-badge&logo=pytest&logoColor=white)
![Black](https://img.shields.io/badge/Black-000000?style=for-the-badge&logo=python&logoColor=white)
![Flake8](https://img.shields.io/badge/Flake8-3776AB?style=for-the-badge&logo=python&logoColor=white)

### DevOps & Infrastructure
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Podman](https://img.shields.io/badge/Podman-892CA0?style=for-the-badge&logo=podman&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![GitHub Container Registry](https://img.shields.io/badge/GHCR-2088FF?style=for-the-badge&logo=github&logoColor=white)
![CodeQL](https://img.shields.io/badge/CodeQL-2C3E50?style=for-the-badge&logo=github&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-1904DA?style=for-the-badge&logo=aqua&logoColor=white)
![Dependabot](https://img.shields.io/badge/Dependabot-025E8C?style=for-the-badge&logo=dependabot&logoColor=white)
![VPS](https://img.shields.io/badge/VPS-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)

### Monitoring & Observability
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![Loki](https://img.shields.io/badge/Loki-F46800?style=for-the-badge&logo=grafana&logoColor=white)
![Micrometer](https://img.shields.io/badge/Micrometer-6DB33F?style=for-the-badge&logo=spring&logoColor=white)

### Third-Party Integrations
![PayOS](https://img.shields.io/badge/PayOS-0066FF?style=for-the-badge&logo=&logoColor=white)
![Agora](https://img.shields.io/badge/Agora-099DFD?style=for-the-badge&logo=agora&logoColor=white)
![Brevo](https://img.shields.io/badge/Brevo-0B996E?style=for-the-badge&logo=sendinblue&logoColor=white)
![Google OAuth2](https://img.shields.io/badge/Google_OAuth2-4285F4?style=for-the-badge&logo=google&logoColor=white)
![Mailpit](https://img.shields.io/badge/Mailpit-00A4EF?style=for-the-badge&logo=mail.ru&logoColor=white)

### Technology Overview Table

| **Category** | **Technology** | **Purpose** |
|--------------|----------------|-------------|
| **Frontend (Mobile)** | Flutter | Cross-platform mobile application development |
| **Frontend (Web)** | React JS | Interactive web dashboard for Admins and Coaches |
| **Backend (Core)** | Java 21 / Spring Boot 3.5.6 | Core business logic and RESTful API services |
| **Backend (AI Service)** | Python 3.10+ / FastAPI | AI microservice for ML predictions and content moderation |
| **Database** | MariaDB 12.1.2 | Primary relational database management system |
| **Cache Layer** | Redis 8.4.0 | Session management and response caching |
| **Search Engine** | Elasticsearch 9.2.3 | Full-text search for posts, news, and content |
| **Message Broker** | RabbitMQ 4.2.2 | Event-driven async communication between services |
| **ML Framework** | PyTorch + Transformers | Model training and NLP/audio processing |
| **ML Runtime** | ONNX Runtime | Optimized inference for custom trained models |
| **LLM Integration** | OpenAI GPT / Google Gemini | AI-powered personalized quit plans and chatbot |
| **Real-time Communication** | Spring WebSocket + Agora | In-app messaging and video consultations |
| **Testing** | JUnit 5, Mockito, Pytest | Comprehensive unit and integration testing |
| **Code Quality** | Black, Flake8, CodeQL | Automated formatting and security analysis |
| **CI/CD** | GitHub Actions | Automated testing, building, security scanning, and deployment |
| **Containerization** | Docker, Podman | Application containerization and orchestration |
| **Monitoring** | Prometheus, Grafana, Loki | Metrics collection, visualization, and log aggregation |
| **Security Scanning** | Trivy, CodeQL | Vulnerability detection and static analysis |
| **Payment Gateway** | PayOS | Vietnamese payment processing |
| **Email Service** | Mailpit | Transactional and notification emails |
| **Build Tools** | Maven (Java), pip (Python) | Dependency management and build automation |
| **Design Tools** | DrawIO, Visual Paradigm | System architecture and database modeling |
| **Deployment** | Self-hosted VPS | Production environment hosting |

---

### Microservices Architecture

**Backend Core Service (Port 8080)**
- RESTful API endpoints
- Business logic processing
- Database operations (MariaDB)
- User authentication & authorization
- Real-time WebSocket connections
- Integration with third-party services (PayOS, Agora, Brevo)
- Message publishing to RabbitMQ
- OpenAI/Gemini integration for conversational AI

**AI Microservice (Port 8000)**
- Machine learning model inference
- Content moderation (text toxicity, NSFW detection)
- Speech-to-Text / Text-to-Speech processing
- Custom ONNX model predictions:
  - Quit success probability
  - Peak craving time forecasting
- Diary sentiment analysis
- Weekly health summary generation
- Visual report generation
- Model training and retraining endpoints

---

### AI Models & Capabilities

#### Content Moderation
- **Text Classification**: `unitary/toxic-bert` - Detects toxic, profane, or harmful text
- **NSFW Detection**: `Falconsai/nsfw_image_detection` - Image content safety classification
- **Video Moderation**: Frame-by-frame NSFW detection for uploaded videos

#### Audio Processing
- **Speech-to-Text**: `openai/whisper-small` - Accurate voice transcription for diary entries
- **Text-to-Speech**: `microsoft/speecht5_tts` + `speecht5_hifigan` - Natural voice synthesis

#### Custom Trained Models (ONNX)
- **Success Prediction Model**: Predicts quit plan success probability based on:
  - User demographics (age, gender)
  - Smoking history (FTND score, cigarettes/day, years smoking)
  - Health metrics (heart rate, SpO2, sleep quality)
  - Behavioral data (mood, anxiety levels)
  
- **Peak Craving Time Model**: Forecasts craving intensity across 96 daily time slots (15-min intervals):
  - Input features: hour, day of week, user profile, current mood/anxiety
  - Output: Craving risk score (0-10) for each 15-minute interval
  - Enables proactive intervention notifications

#### LLM-Powered Features
- Personalized quit plan generation
- AI coaching conversations with context memory
- Sentiment analysis of daily diary entries
- Weekly progress summaries for coaches
- Real-time intervention messages for high-risk periods

---

### CI/CD Pipeline Features

#### Automated Workflows
**Java Backend Pipeline:**
- ✅ Maven build and compilation
- ✅ JUnit unit tests with Surefire reports
- ✅ Docker image build and push to GHCR
- ✅ Semantic versioning with Git tags
- ✅ Automated deployment to VPS

**Python AI Service Pipeline:**
- ✅ Dependency installation with pip caching
- ✅ Black code formatting validation
- ✅ Pytest unit test execution
- ✅ System dependency installation (OpenCV, ML libs)
- ✅ Docker multi-stage build optimization
- ✅ Trivy security vulnerability scanning
- ✅ Discord notifications for build status

**Security & Maintenance:**
- Weekly CodeQL static analysis
- Weekly Dependabot dependency updates
- Automated Black formatting on push
- Container image security scanning with severity thresholds

#### Quality Gates
- All tests must pass before Docker build
- Critical/High severity vulnerabilities block deployment
- Code formatting validation prevents unformatted code merges
- Health checks ensure service availability before traffic routing

#### Deployment Strategy
- Multi-stage Docker builds for minimal image size
- Layer caching with GitHub Actions cache
- Semantic versioning (major.minor.patch)
- Health check integration with service dependencies
- Zero-downtime deployment with health probes
---

## System Architecture & Design

###  Database Design

The system utilizes a relational database to manage users, health logs, quit plans, and IoT data.

<p align="center">
  <img src="./images/erd.png" alt="Database ERD" width="800" />
  <br/>
  <em>Entity Relationship Diagram</em>
</p>

### Architecture Diagram

SmartQuitIoT follows a client-server architecture with real-time capabilities for chat and IoT synchronization.

<p align="center">
  <img src="./images/architect-diagram.png" alt="System Architecture" width="800" />
  <br/>
  <em>System Architecture Overview</em>
</p>

### Screen Flow 

<p align="center">
  <img src="./images/member.png" alt="User Flow" width="800" />
  <br/>
  <em>Member Screen Flow Diagram</em>
</p>


<p align="center">
  <img src="./images/coach.png" alt="User Flow" width="800" />
  <br/>
  <em>Coach Screen Flow Diagram</em>
</p>

<p align="center">
  <img src="./images/admin.png" alt="User Flow" width="800" />
  <br/>
  <em>Admin Screen Flow Diagram</em>
</p>


### Use Case

<p align="center">
  <img src="./images/use-case.png" alt="User Flow" width="800" />
  <br/>
  <em>Use Case Diagram</em>
</p>

---

## Team Members & Supervisors

### Group **GFA25SE97**

| **Name** | **Role** | **Student ID** | **Email** |
|----------|----------|----------------|-----------|
| Nguyen Hai Linh | Leader | SE170530 | linhnhse170530@fpt.edu.vn |
| Thi Minh Dat | Member | SE170508 | dattmse170508@fpt.edu.vn |
| Nguyen Ha Viet Anh | Member | SE172136 | anhnhvse172136@fpt.edu.vn |
| Tran Ngoc Kinh Luan | Member | SE184059 | luantnkse184059@fpt.edu.vn |

### Supervisor

**Do Tan Nhan**  
nhandt35@fe.edu.vn

---

## Project Resources

<p>
  <a href="https://github.com/your-repo-link">
    <img src="https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" />
  </a>
  <a href="https://drive.google.com/your-drive-link">
    <img src="https://img.shields.io/badge/Google_Drive-Documentation-4285F4?style=for-the-badge&logo=google-drive&logoColor=white" alt="Google Drive" />
  </a>
  <a href="your-excel-link">
    <img src="https://img.shields.io/badge/Excel-Project_Schedule-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white" alt="Excel" />
  </a>
</p>

---

<p align="center">
  <sub>© 2025 SmartQuitIoT - FPT University Capstone Project</sub>
</p>