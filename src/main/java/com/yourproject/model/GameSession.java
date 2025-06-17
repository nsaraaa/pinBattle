// src/main/java/com/yourproject/model/GameSession.java
package com.yourproject.model;

import java.sql.Timestamp;

public class GameSession {
    private int sessionId;
    private String theme;
    private int creatorId;
    private int maxPlayers;
    private int currentPlayers;
    private String status;
    private Timestamp createdAt;
    private Timestamp startedAt;
    private Timestamp endedAt;
    
    // Getters and Setters
    public int getSessionId() { return sessionId; }
    public void setSessionId(int sessionId) { this.sessionId = sessionId; }
    
    public String getTheme() { return theme; }
    public void setTheme(String theme) { this.theme = theme; }
    
    public int getCreatorId() { return creatorId; }
    public void setCreatorId(int creatorId) { this.creatorId = creatorId; }
    
    public int getMaxPlayers() { return maxPlayers; }
    public void setMaxPlayers(int maxPlayers) { this.maxPlayers = maxPlayers; }
    
    public int getCurrentPlayers() { return currentPlayers; }
    public void setCurrentPlayers(int currentPlayers) { this.currentPlayers = currentPlayers; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    
    public Timestamp getStartedAt() { return startedAt; }
    public void setStartedAt(Timestamp startedAt) { this.startedAt = startedAt; }
    
    public Timestamp getEndedAt() { return endedAt; }
    public void setEndedAt(Timestamp endedAt) { this.endedAt = endedAt; }
}