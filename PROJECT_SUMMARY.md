# Image Selection Game - Project Summary

## Project Overview
The Image Selection Game is a web-based multiplayer application where users can participate in themed image selection sessions. Players are presented with a collection of images from Unsplash API, select images that match a given theme, and can view other players' selections. The application demonstrates a complete CRUD implementation with real-time updates and session management.

## Technologies Used

### Frontend
- **HTML5**: Semantic markup for game interface and voting pages
- **CSS3**: 
  - Modern responsive design using Flexbox and Grid
  - CSS Variables for theme consistency
  - Media queries for cross-device compatibility
- **JavaScript**:
  - ES6+ features for modern functionality
  - Async/await for API communication
  - DOM manipulation for dynamic updates
  - Session Storage for client-side data persistence

### Backend
- **Java Servlets**: Core server-side logic implementation
- **JSP**: Dynamic page rendering and session management
- **REST APIs**: Stateless communication between client and server
- **SQL Database**: Persistent storage of user data and image selections

## System Architecture / Flow

### User Flow
1. **Session Initialization**
   - User joins a game session
   - Server creates unique session ID
   - JSP maintains session state

2. **Game Play**
   - User receives theme and timer
   - Real-time image search via Unsplash API
   - Image selection with client-side validation
   - Automatic submission on timer completion

3. **Data Management**
   - Selected images stored in database
   - JSON backup for data redundancy
   - Session-based image retrieval

4. **Voting Phase**
   - Display of all participants' selections
   - Real-time updates of new submissions
   - Session persistence across page reloads

## Key Features Implemented

### CRUD Operations
1. **Create**
   - New game sessions
   - Image selections
   - User profiles

2. **Read**
   - Image retrieval from Unsplash
   - Player selections
   - Session data

3. **Update**
   - Image descriptions
   - Session states
   - User preferences

4. **Delete**
   - Session cleanup
   - Invalid selections
   - Expired data

### Security Features
- Input validation on both client and server
- SQL injection prevention
- Session hijacking protection
- Error handling and logging

## REST and Session Handling

### REST API Implementation
1. **Image Management**
   ```java
   @WebServlet("/VoteServlet")
   POST /VoteServlet
   - Handles image submission
   - Returns JSON response with status
   ```

2. **Data Retrieval**
   ```java
   @WebServlet("/GetImagesServlet")
   GET /GetImagesServlet
   - Fetches session images
   - Returns JSON array of selections
   ```

### Session Management
1. **Server-side**
   - `HttpSession` for user state
   - Session timeout handling
   - Cross-page session persistence

2. **Client-side**
   - Session Storage for temporary data
   - Local Storage for preferences
   - Session ID management through URL parameters

## Technical Highlights

### Database Schema
```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(255)
);

CREATE TABLE selected_images (
    id INT PRIMARY KEY,
    session_id VARCHAR(255),
    user_id INT,
    image_url VARCHAR(255),
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### Error Handling
- Comprehensive logging system
- Graceful failure recovery
- User-friendly error messages
- Transaction management

## Conclusion
The Image Selection Game successfully implements all required technologies while maintaining a clean, modular architecture. The application demonstrates:
- Full CRUD functionality
- Secure session management
- RESTful API design
- Responsive frontend
- Robust error handling
- Scalable database design

The project serves as a practical example of modern web application development, combining traditional Java technologies with contemporary frontend practices. 