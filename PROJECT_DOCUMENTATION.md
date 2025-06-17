# Image Selection Game - Technical Documentation

## 1. Frontend Technologies

### HTML
- `game.jsp`: Main game interface with image selection grid
- `vote.html`: Voting page to display selected images
- `index.html`: Landing page for game sessions
- Uses semantic HTML5 elements for better structure and accessibility

### CSS
- Custom styling in `css/styles.css` and `css/voteStyle.css`
- Modern CSS features:
  - CSS Variables (custom properties)
  - Flexbox and Grid layouts
  - Media queries for responsive design
  - CSS animations and transitions
  - Modern card-based design

### JavaScript
- Client-side game logic in `game.jsp`
- Image selection and submission handling
- Session storage management
- DOM manipulation
- Event handling
- Async/await for API calls
- Modern ES6+ features

## 2. Backend Technologies

### Java Servlets
1. `VoteServlet.java`:
   - Handles image submission
   - Processes POST requests
   - Implements error handling
   - Manages database operations

2. `UnsplashServlet.java`:
   - Fetches images from Unsplash API
   - Handles image search functionality
   - Returns JSON responses

3. `GetImagesServlet.java`:
   - Retrieves stored images
   - Manages image data retrieval
   - Handles session-based image loading

### REST APIs
1. Image Submission API:
   ```java
   @WebServlet("/VoteServlet")
   POST /VoteServlet
   Request Body: JSON with sessionId, username, selectedImages
   Response: JSON with success status and redirect URL
   ```

2. Image Retrieval API:
   ```java
   @WebServlet("/GetImagesServlet")
   GET /GetImagesServlet
   Parameters: sessionId
   Response: JSON array of images
   ```

3. Unsplash Integration API:
   ```java
   @WebServlet("/UnsplashServlet")
   GET /UnsplashServlet
   Parameters: query
   Response: JSON array of Unsplash images
   ```

## 3. Database Integration

### SQL Implementation
1. Database Schema:
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

2. Database Operations:
   - Image storage
   - User data management
   - Session tracking
   - CRUD operations through `DatabaseUtil.java`

## 4. Session Management

### JSP and Session Handling
1. Session Implementation:
   - Uses `HttpSession` for user session management
   - Session persistence across page reloads
   - Session-based image storage

2. JSP Features:
   - Dynamic content generation
   - Session attribute access
   - Server-side logic integration
   - JSTL usage for conditional rendering

## 5. CRUD Operations

### Create
- Image submission through `VoteServlet`
- User registration
- Session creation

### Read
- Image retrieval via `GetImagesServlet`
- User data fetching
- Session data access

### Update
- Image description updates
- User profile modifications
- Session state updates

### Delete
- Image removal
- Session cleanup
- User data removal

## 6. Security Features

1. Input Validation:
   - Server-side validation in servlets
   - Client-side validation in JavaScript
   - SQL injection prevention

2. Error Handling:
   - Comprehensive error logging
   - User-friendly error messages
   - Graceful failure handling

## 7. Additional Features

1. Backup System:
   - JSON file backup for image data
   - Session storage fallback
   - Data persistence across sessions

2. Real-time Updates:
   - Timer functionality
   - Dynamic image loading
   - Live selection updates

3. Responsive Design:
   - Mobile-friendly layouts
   - Adaptive image grids
   - Flexible UI components

## 8. Project Structure

```
project/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/yourproject/
│       │       ├── servlets/
│       │       ├── util/
│       │       └── model/
│       ├── webapp/
│       │   ├── WEB-INF/
│       │   ├── css/
│       │   ├── js/
│       │   └── *.jsp
│       └── resources/
└── pom.xml
```

This documentation provides a comprehensive overview of how the project implements the required technologies and concepts. Each section demonstrates the practical application of the specified requirements in a real-world web application context. 