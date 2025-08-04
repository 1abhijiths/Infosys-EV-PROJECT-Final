
Infosys Global Hackathon 2025 - EcoRoute EV
When the World is your Client
     

Code for a cause. Build for the world.
Welcome to the project repository for EcoRoute EV, our solution for the Infosys Global Hackathon 2025! This project is designed to create a professional, well-documented solution that addresses humanity's greatest challenges through the lens of UN's Sustainable Development Goals (SDGs).
This #TechForGood initiative brings together tech enthusiasts, students, and industry professionals to create open-source, cloud-native solutions that make a meaningful impact on society and the environment.

Table of Contents
🎯 Project Overview

SDG Challenge Addressed

Our Solution

Impact Statement

⚙️ Technical Implementation

Technology Stack

System Architecture

🚀 Solution Components

Working Prototype

Technical Documentation

Impact Analysis

📖 Getting Started

Prerequisites

Installation

Usage

🤝 Contributing

👥 Contributors

🙏 Acknowledgments

🎯 Project Overview
SDG Challenge Addressed
🎯 SDG 7: Affordable and Clean Energy, SDG 11: Sustainable Cities and Communities, and SDG 13: Climate Action

Our project directly addresses three critical Sustainable Development Goals:

SDG 7 (Affordable and Clean Energy): We promote the use of charging stations powered by renewable energy sources, making clean energy more visible and accessible for transportation.

SDG 11 (Sustainable Cities and Communities): By simplifying the EV ownership experience, we encourage the adoption of electric vehicles, which is fundamental to reducing urban air and noise pollution and creating sustainable, resilient city infrastructure.

SDG 13 (Climate Action): The core mission of our app is to combat climate change by facilitating a transition to electric mobility. We provide users with tangible metrics on their reduced carbon footprint (CO_2 saved), directly engaging them in climate action.

Our Solution
🚀 EcoRoute EV is a sustainable mobility application designed to help electric vehicle (EV) users find, use, and review charging stations. Our platform goes beyond simple discovery by integrating a unique "SDG Mode" that allows users to prioritize stations based on their use of renewable energy, community impact, and overall contribution to a sustainable future.

Impact Statement
Detail the potential social, economic, or environmental impact of your solution.

🎯 Target Beneficiaries: Electric vehicle drivers (both cars and scooters) in urban and suburban areas, aiming to reach over 100,000 users in our first year.

📊 Expected Outcomes: 30% increase in the utilization of renewable energy charging stations, 50% reduction in "range anxiety" for new EV users, and a collective saving of over 1,000 metric tons of CO_2 annually.

📈 Measurable Impact Metrics: Total CO_2 saved (in kg), total renewable energy used for charging (in kWh), number of "Sustainable Trips" completed, station ratings, and user engagement with community features.

🌱 Long-term Sustainability Vision: To become the standard platform for sustainable EV routing, integrating with municipal transport systems, energy grids, and corporate sustainability programs to accelerate the global transition to clean transportation.

⚙️ Technical Implementation
Technology Stack
Category	Technologies	Purpose
🌐 Backend	Node.js (Express)	Manages API requests, user data, station information, and business logic.
⚡ Frontend	Flutter, Material Design	Cross-platform mobile application (iOS/Android) with a clean, responsive UI.
🗺️ Mapping	Flutter Map, OpenStreetMap	Provides interactive maps, route visualization, and custom station markers.
📊 Databases	PostgreSQL, Redis	Storing relational data (users, stations, reviews) and caching real-time data (availability).

Export to Sheets
System Architecture
Architecture Overview: Our system is built with a simplified, robust monolithic backend server that is easy to develop, deploy, and maintain for local development.

🖥️ User Interface Layer: A Flutter-based mobile application built with the flutter_map package to render interactive map tiles from OpenStreetMap. It handles user interactions, trip planning inputs, and visualization.

⚡ Backend Server: A monolithic server using Node.js (Express) handles all API requests. It contains the logic for user authentication, CRUD operations for stations and reviews, and geocoding services.

🧠 Scoring & Routing Engine: A core module within the backend that uses heuristic algorithms to implement the search prioritization logic. It calculates scores for "Fastest Service," "Shortest Detour," "Highest Rated," and "Greenest Energy" based on a weighted combination of station attributes.

💾 Data Storage & Management: PostgreSQL serves as our primary database for persistent data. Redis is used for high-speed caching of station availability and user sessions to ensure a real-time experience.

🔗 External Integrations: We integrate with the OpenStreetMap Nominatim API for geocoding and various open charging network APIs (e.g., Open Charge Map) for real-time station data.

🚀 Solution Components
Working Prototype
🌐 Live Demo: N/A (Local Development Only)

📱 Demo Credentials (if authentication required):

Username: demouser@ecoroute.app

Password: Sustainable!2025

Description of Prototype:

✅ Core Functionality: Users can input a start and destination, select their vehicle type, and search for charging stations. The "SDG Mode" toggle allows filtering for renewable energy stations. Users can view station details and user reviews.

🎨 User Interface: Clean, modern UI based on Material Design with a dynamic gradient background and intuitive map-based navigation powered by OpenStreetMap.

⚡ Performance: The app features lazy loading of station data and efficient list rendering to handle thousands of data points smoothly.

🎥 Demo Video: https://youtube.com/watch?v=demo_video_link (Placeholder)

Technical Documentation
Document Type	Description	Link
🏗️ System Architecture	Detailed technical design of our monolithic server and database schema.	Architecture Doc
📡 API Documentation	All RESTful endpoints, request/response formats, and examples.	API Docs
🚀 Deployment Guide	Step-by-step setup instructions for running the project locally.	Deploy Guide
👤 User Manual	A guide on how to use all features of the EcoRoute EV app.	User Guide
💻 Developer Guide	Guide for contributing to the codebase and development setup.	Dev Guide

Export to Sheets
Impact Analysis
📊 Measurable Impact:

Quantitative Metrics

🌍 Environmental Impact: Tracked metrics within the app, such as Total CO_2 Saved, Renewable Energy Used, and Sustainable Trips Completed.

📈 User Adoption: Target of 10,000+ active users in the pilot phase.

⏱️ Efficiency Gains: 25% reduction in time spent searching for a compatible and available charger.

Qualitative Benefits

🌱 Environment: Directly promotes the use of clean energy and helps users quantify their positive environmental impact.

👥 Social: Builds a community of environmentally-conscious EV drivers, reduces "range anxiety," and makes sustainable choices easier for everyone.

Use Cases & Applications

🎯 Primary Use Case: An EV driver plans a long-distance trip and uses EcoRoute EV to find the optimal charging stops, prioritizing stations with the highest rating and renewable energy sources.

🔄 Secondary Use Cases:

Fleet Management: Logistics companies use the app to plan charging schedules for their electric delivery fleets, prioritizing cost and speed.

Urban Planning: Municipalities analyze anonymized data to identify "charging deserts" and plan new public infrastructure.

🚀 Future Applications:

Smart Grid Integration: Partner with utility providers to offer smart charging, where vehicles charge during off-peak hours or when renewable energy generation is high.

Reward Programs: Gamify sustainable choices by offering users rewards or badges for using green energy stations.

📖 Getting Started
Prerequisites
💻 System Requirements: macOS, Windows 10+, or Linux. 8GB RAM minimum.

🛠️ Required Software:

Flutter SDK (v3.0 or higher)

Node.js (v18.0 or higher)

Git

Installation
Bash

# 1. Clone the Repository
git clone https://github.com/Infosys-Global-Hackathon/EcoRouteEV.git
cd EcoRouteEV

# 2. Install Backend Dependencies
cd server
npm install

# 3. Install Frontend Dependencies
cd ../client
flutter pub get

# 4. Configure Environment
# In the `server` directory, copy .env.example to .env
cp .env.example .env
# Edit .env with your database and API keys

# 5. Start the Backend Server
cd ../server
npm start

# 6. Run the Flutter App in a separate terminal
cd ../client
flutter run
Usage
Accessing the Application: The Flutter application will be available on your connected device or emulator. The backend API will be running locally at http://localhost:3000.

Key Features to Explore:

Trip Planner: On the home screen, enter a start and destination.

SDG Mode: Use the toggle in the app bar to filter for green stations.

Station Details: Tap a station marker on the map to view comprehensive details, including reviews and renewable energy status.
