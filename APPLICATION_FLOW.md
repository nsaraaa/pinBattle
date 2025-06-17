# Image Selection Game - Application Flow

## 1. Initial Entry Flow
```
User → index.html
     ↓
Join Game Session
     ↓
Create New Session/Join Existing
     ↓
Redirect to game.jsp with sessionId
```

## 2. Game Session Flow
```
game.jsp
  ↓
Load Theme & Timer
  ↓
Fetch Images from Unsplash API
  ↓
User Interaction Loop:
  ├─→ Search Images
  │    ↓
  │    Update Image Grid
  │    ↓
  │    Back to User Interaction
  │
  ├─→ Select Images (up to 5)
  │    ↓
  │    Update Selection Count
  │    ↓
  │    Store in Session Storage
  │    ↓
  │    Back to User Interaction
  │
  └─→ Timer Expires
       ↓
       Auto-submit if images selected
```

## 3. Image Submission Flow
```
Submit Selection
  ↓
Collect Selected Images
  ↓
Prepare Submission Data:
  ├─→ Session ID
  ├─→ Username
  ├─→ Selected Images
  └─→ Timestamp
  ↓
Store in Session Storage
  ↓
Send to VoteServlet
  ↓
Server Processing:
  ├─→ Validate Data
  ├─→ Save to Database
  └─→ Create JSON Backup
  ↓
Redirect to vote.html
```

## 4. Voting Page Flow
```
vote.html
  ↓
Load Session Data:
  ├─→ Get Session ID from URL
  ├─→ Retrieve from Session Storage
  └─→ Filter by Session ID
  ↓
Display Images:
  ├─→ Group by User
  ├─→ Show Image Cards
  └─→ Display User Info
  ↓
User Options:
  ├─→ Return Home
  └─→ Join New Game
```

## 5. Data Flow Between Components

### Client-Side Storage
```
Session Storage
  ├─→ Store: Selected Images
  ├─→ Store: Game State
  └─→ Store: User Submissions
```

### Server-Side Storage
```
Database
  ├─→ Store: User Data
  ├─→ Store: Image Selections
  └─→ Store: Session Info

JSON Backup
  ├─→ Backup: Image Data
  └─→ Backup: Session Data
```

### API Interactions
```
Unsplash API
  ├─→ Fetch: Initial Images
  └─→ Search: Theme-based Images

VoteServlet
  ├─→ Receive: Image Submissions
  └─→ Send: Success/Error Response

GetImagesServlet
  ├─→ Retrieve: Stored Images
  └─→ Send: Image Data
```

## 6. Error Handling Flow
```
Error Detection
  ↓
Error Type:
  ├─→ Validation Error
  │    ↓
  │    Show User Message
  │    ↓
  │    Allow Retry
  │
  ├─→ Network Error
  │    ↓
  │    Show Error Message
  │    ↓
  │    Enable Retry Option
  │
  └─→ Server Error
       ↓
       Log Error
       ↓
       Show Generic Message
```

## 7. Session Management Flow
```
Session Creation
  ↓
Session Tracking:
  ├─→ URL Parameters
  ├─→ Session Storage
  └─→ Server Sessions
  ↓
Session Validation
  ↓
Session Cleanup
```

## 8. Security Flow
```
Request Received
  ↓
Security Checks:
  ├─→ Input Validation
  ├─→ Session Validation
  └─→ Data Sanitization
  ↓
Process Request
  ↓
Response with Security Headers
```

This flow diagram shows how different components of the application interact and how data flows between them. Each major section represents a different phase of the application's operation, from initial entry to final voting display. 