package com.yourproject.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.*;
import com.yourproject.util.DatabaseUtil;
import com.yourproject.util.JsonFileUtil;
import org.json.JSONObject;
import org.json.JSONArray;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet(name = "VoteServlet", urlPatterns = {"/VoteServlet"})
public class VoteServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(VoteServlet.class.getName());
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        JSONObject responseJson = new JSONObject();
        
        try {
            logger.info("Received POST request to VoteServlet");
            
            // Read JSON data from request
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                sb.append(line);
            }
            
            String requestBody = sb.toString();
            logger.info("Request body: " + requestBody);
            
            if (requestBody.isEmpty()) {
                throw new IllegalArgumentException("No data received");
            }
            
            JSONObject jsonData = new JSONObject(requestBody);
            
            // Validate required fields
            if (!jsonData.has("sessionId") || !jsonData.has("username") || !jsonData.has("selectedImages")) {
                String error = "Missing required fields. Required: sessionId, username, selectedImages";
                logger.warning(error);
                throw new IllegalArgumentException(error);
            }
            
            // Extract data from JSON
            String sessionId = jsonData.getString("sessionId");
            String username = jsonData.getString("username");
            JSONArray selectedImages = jsonData.getJSONArray("selectedImages");
            
            // Set session cookie
            Cookie sessionCookie = new Cookie("sessionId", sessionId);
            sessionCookie.setMaxAge(3600); // 1 hour
            sessionCookie.setPath("/");
            response.addCookie(sessionCookie);
            
            logger.info("Processing request for session: " + sessionId + ", user: " + username + 
                       ", images count: " + selectedImages.length());
            
            if (selectedImages.length() == 0) {
                throw new IllegalArgumentException("No images selected");
            }
            
            // Save images to database
            boolean dbSuccess = saveSelectedImages(sessionId, username, selectedImages);
            logger.info("Database save result: " + dbSuccess);
            
            // Save images to JSON file as backup
            List<JsonFileUtil.ImageData> imageDataList = new ArrayList<>();
            for (int i = 0; i < selectedImages.length(); i++) {
                JSONObject img = selectedImages.getJSONObject(i);
                if (!img.has("url") || !img.has("description")) {
                    throw new IllegalArgumentException("Invalid image data format");
                }
                
                JsonFileUtil.ImageData imageData = new JsonFileUtil.ImageData();
                imageData.setUrl(img.getString("url"));
                imageData.setDescription(img.getString("description"));
                imageData.setUsername(username);
                imageData.setTimestamp(jsonData.getString("timestamp"));
                imageDataList.add(imageData);
            }
            JsonFileUtil.saveImagesToJson(sessionId, imageDataList);
            logger.info("JSON backup saved successfully");
            
            // Prepare success response
            responseJson.put("success", true);
            responseJson.put("redirectUrl", "vote.html?sessionId=" + sessionId);
            logger.info("Sending success response: " + responseJson.toString());
            
        } catch (IllegalArgumentException e) {
            logger.warning("Validation error: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            responseJson.put("success", false);
            responseJson.put("error", e.getMessage());
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error processing request", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            responseJson.put("success", false);
            responseJson.put("error", "Internal server error: " + e.getMessage());
        }
        
        response.getWriter().write(responseJson.toString());
    }
    
    private boolean saveSelectedImages(String sessionId, String username, JSONArray images) throws SQLException {
        String sql = "INSERT INTO selected_images (session_id, user_id, image_url, description) " +
                     "VALUES (?, (SELECT user_id FROM users WHERE username = ?), ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            for (int i = 0; i < images.length(); i++) {
                JSONObject img = images.getJSONObject(i);
                stmt.setString(1, sessionId);
                stmt.setString(2, username);
                stmt.setString(3, img.getString("url"));
                stmt.setString(4, img.getString("description"));
                stmt.addBatch();
            }
            
            stmt.executeBatch();
            return true;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error while saving images", e);
            throw e;
        }
    }
}