// src/main/java/com/yourproject/dao/GameDao.java
package com.yourproject.dao;

import com.yourproject.model.GameSession;
import com.yourproject.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GameDao {
    public List<GameSession> getAvailableSessions() {
        List<GameSession> sessions = new ArrayList<>();
        String sql = "SELECT * FROM game_sessions WHERE status = 'waiting'";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                GameSession session = new GameSession();
                session.setSessionId(rs.getInt("session_id"));
                session.setTheme(rs.getString("theme"));
                session.setCreatorId(rs.getInt("creator_id"));
                session.setMaxPlayers(rs.getInt("max_players"));
                session.setCurrentPlayers(rs.getInt("current_players"));
                session.setStatus(rs.getString("status"));
                session.setCreatedAt(rs.getTimestamp("created_at"));
                sessions.add(session);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return sessions;
    }

    public boolean createGameSession(GameSession session) {
        String sql = "INSERT INTO game_sessions (theme, creator_id, max_players) VALUES (?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, session.getTheme());
            stmt.setInt(2, session.getCreatorId());
            stmt.setInt(3, session.getMaxPlayers());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows == 0) {
                return false;
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    session.setSessionId(generatedKeys.getInt(1));
                }
            }
            
            // Add creator as first participant
            return joinGameSession(session.getSessionId(), session.getCreatorId());
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean joinGameSession(int sessionId, int userId) {
        String checkSql = "SELECT current_players, max_players, status, creator_id FROM game_sessions WHERE session_id = ?";
        String checkParticipantSql = "SELECT COUNT(*) FROM game_participants WHERE session_id = ? AND user_id = ?";
        String insertSql = "INSERT INTO game_participants (session_id, user_id) VALUES (?, ?)";
        String updateSql = "UPDATE game_sessions SET current_players = current_players + 1 WHERE session_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection()) {
            conn.setAutoCommit(false); // Start transaction
            
            try {
                // Check if game exists and has space
                try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                    checkStmt.setInt(1, sessionId);
                    ResultSet rs = checkStmt.executeQuery();
                    
                    if (!rs.next()) {
                        conn.rollback();
                        return false; // Game doesn't exist
                    }
                    
                    int currentPlayers = rs.getInt("current_players");
                    int maxPlayers = rs.getInt("max_players");
                    String status = rs.getString("status");
                    int creatorId = rs.getInt("creator_id");
                    
                    if (!"waiting".equals(status)) {
                        conn.rollback();
                        return false; // Game is not in waiting state
                    }
                    
                    if (currentPlayers >= maxPlayers) {
                        conn.rollback();
                        return false; // Game is full
                    }
                }
                
                // Check if user is already in the game
                try (PreparedStatement checkParticipantStmt = conn.prepareStatement(checkParticipantSql)) {
                    checkParticipantStmt.setInt(1, sessionId);
                    checkParticipantStmt.setInt(2, userId);
                    ResultSet rs = checkParticipantStmt.executeQuery();
                    
                    if (rs.next() && rs.getInt(1) > 0) {
                        conn.rollback();
                        return false; // User is already in the game
                    }
                }
                
                // Add participant
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setInt(1, sessionId);
                    insertStmt.setInt(2, userId);
                    insertStmt.executeUpdate();
                }
                
                // Update player count
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setInt(1, sessionId);
                    updateStmt.executeUpdate();
                }
                
                conn.commit(); // Commit transaction
                return true;
                
            } catch (SQLException e) {
                conn.rollback(); // Rollback on error
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true); // Reset auto-commit
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    // Add these to your GameDao class
public boolean isUserInGame(int sessionId, int userId) {
    String sql = "SELECT 1 FROM game_participants WHERE session_id = ? AND user_id = ?";
    try (Connection conn = DatabaseUtil.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, sessionId);
        stmt.setInt(2, userId);
        ResultSet rs = stmt.executeQuery();
        return rs.next();
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

public GameSession getGameSession(int sessionId) {
    String sql = "SELECT * FROM game_sessions WHERE session_id = ?";
    try (Connection conn = DatabaseUtil.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setInt(1, sessionId);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            GameSession session = new GameSession();
            session.setSessionId(rs.getInt("session_id"));
            session.setTheme(rs.getString("theme"));
            session.setCreatorId(rs.getInt("creator_id"));
            session.setMaxPlayers(rs.getInt("max_players"));
            session.setCurrentPlayers(rs.getInt("current_players"));
            session.setStatus(rs.getString("status"));
            return session;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

public boolean updateGameStatus(int sessionId, String status) {
    String sql = "UPDATE game_sessions SET status = ? WHERE session_id = ?";
    try (Connection conn = DatabaseUtil.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setString(1, status);
        stmt.setInt(2, sessionId);
        return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}
}