# Qt Chat Client

A modern desktop chat client built with **C++** and **Qt 6 (Qt Quick / QML)**. It features an asynchronous network architecture using raw TCP sockets (`QTcpSocket`) and a JSON-based protocol to communicate with a dedicated backend server.

---

## 🚀 Tech Stack

* **Language:** C++17
* **Framework:** Qt 6 (Qt Quick, QML, Qt Network)
* **Build System:** CMake
* **Architecture:** Client-Server model (TCP / JSON serialization)

---

## 🛠️ Getting Started & Quick Start

To run this application locally, you need to run both the backend server and this client.

### 1. Build and Run the Server
Clone and launch the companion server repository (`cpp-chat-server`):
```bash
git clone https://github.com/fl1ker1337ri-spec/cpp-chat-server.git
cd cpp-chat-server
mkdir build && cd build
cmake ..
cmake --build .
# Run the server executable
./cpp-chat-server
```
### 2. Build and Run the Client
Clone, build, and run this client repository:

```bash
git clone https://github.com/fl1ker1337ri-spec/qt-chat-client.git
cd qt-chat-client
mkdir build && cd build
cmake ..
cmake --build .
# Run the client executable
./qt-chat-client
```
### 📸 Screenshots
### Login / Registration View:
<img width="795" height="596" alt="image" src="https://github.com/user-attachments/assets/a6311f95-2ac8-4f92-a030-ac01dd328b83" />

---

### Chat Interface:
<img width="795" height="622" alt="image" src="https://github.com/user-attachments/assets/8481cfc2-322d-4a23-bc01-6b4c5f34bbf6" />

---

### Chat: 
<img width="1232" height="599" alt="image" src="https://github.com/user-attachments/assets/0f7dfb87-79ec-4866-8d0a-0c9fa0588100" />

---

