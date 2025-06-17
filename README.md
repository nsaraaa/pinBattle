# PinBattle - Image Selection Game

A web-based multiplayer application where users can participate in themed image selection sessions. Players are presented with a collection of images from Unsplash API, select images that match a given theme, and can view other players' selections.

## Features

- **Real-time Multiplayer**: Join game sessions and interact with other players
- **Dynamic Image Selection**: Search and select images from Unsplash API
- **Theme-based Gameplay**: Match images to given themes
- **Voting System**: View and vote on other players' selections
- **Session Management**: Persistent game sessions with real-time updates
- **Responsive Design**: Works seamlessly across all devices

##  Technologies

### Frontend
- HTML5
- CSS3 (Flexbox, Grid, CSS Variables)
- JavaScript (ES6+)
- JSP for dynamic content

### Backend
- Java Servlets
- REST APIs
- SQL Database
- Session Management

## Getting Started

### Prerequisites
- Java JDK 8 or higher
- Apache Tomcat server
- MySQL Database
- Modern web browser

### Installation

1. Clone the repository
```bash
git clone https://github.com/nsaraaa/pinBattle.git
```

2. Set up the database
```sql
create database pinBattle;
use pinBattle;

CREATE TABLE user_selections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(50) NOT NULL,
    username VARCHAR(100) NOT NULL,
    image_url TEXT NOT NULL,
    image_description TEXT,
    selection_order INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_session_username (session_id, username)
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE game_sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    theme VARCHAR(100) NOT NULL,
    creator_id INT NOT NULL,
    max_players INT DEFAULT 4,
    current_players INT DEFAULT 1,
    status ENUM('waiting', 'in_progress', 'completed') DEFAULT 'waiting',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP NULL,
    ended_at TIMESTAMP NULL,
    FOREIGN KEY (creator_id) REFERENCES users(user_id)
);


CREATE TABLE game_participants (
    participant_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    score DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (session_id) REFERENCES game_sessions(session_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY (session_id, user_id)
);

CREATE TABLE selected_images (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    description TEXT,
    selected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    votes INT DEFAULT 0,
    FOREIGN KEY (session_id) REFERENCES game_sessions(session_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

3. Configure your database connection in `WEB-INF/web.xml`

4. Deploy the application to your Tomcat server

5. Access the application at `http://localhost:8080/web`

## How to Play

1. Register or login to your account
2. Join or create a new game session
3. Wait for the theme to be announced
4. Search and select images that match the theme
5. Submit your selections before the timer runs out
6. View and vote on other players' selections

## Security Features

- Input validation on both client and server
- SQL injection prevention
- Session hijacking protection
- Comprehensive error handling and logging

## API Documentation

### Image Management
```java
@WebServlet("/VoteServlet")
POST /VoteServlet
- Handles image submission
- Returns JSON response with status
```

### Data Retrieval
```java
@WebServlet("/GetImagesServlet")
GET /GetImagesServlet
- Fetches session images
- Returns JSON array of selections
```

##  Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License 

##  Authors

- Sara Noor
  
##  Acknowledgments

- Unsplash API for providing image content
- All contributors who have helped shape this project
