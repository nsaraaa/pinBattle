package com.yourproject.servlets;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.*;
import com.yourproject.util.DatabaseUtil;
import com.yourproject.util.JsonFileUtil;
import org.json.JSONArray;
import org.json.JSONObject;
import java.util.List;

@WebServlet(name = "GetImagesServlet", urlPatterns = {"/GetImagesServlet"})
public class GetImagesServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String sessionId = request.getParameter("sessionId");
        
        if (sessionId == null || sessionId.trim().isEmpty()) {
            sendError(response, "Session ID is required");
            return;
        }

        try {
            JSONArray images = fetchImages(sessionId);
            
            // If database fetch fails or returns no results, try JSON backup
            if (images.length() == 0) {
                List<JsonFileUtil.ImageData> backupImages = JsonFileUtil.loadImagesFromJson(sessionId);
                if (!backupImages.isEmpty()) {
                    images = new JSONArray();
                    for (JsonFileUtil.ImageData img : backupImages) {
                        JSONObject image = new JSONObject();
                        image.put("url", img.getUrl());
                        image.put("description", img.getDescription());
                        image.put("username", img.getUsername());
                        images.put(image);
                    }
                }
            }
            
            response.setContentType("application/json");
            response.getWriter().write(images.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, e.getMessage());
        }
    }
    
    private JSONArray fetchImages(String sessionId) throws SQLException {
        String sql = "SELECT si.image_url, si.description, u.username " +
                    "FROM selected_images si " +
                    "JOIN users u ON si.user_id = u.user_id " +
                    "WHERE si.session_id = ? " +
                    "ORDER BY u.username, si.selected_at";
        
        JSONArray images = new JSONArray();
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, sessionId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                JSONObject image = new JSONObject();
                image.put("url", rs.getString("image_url"));
                image.put("description", rs.getString("description"));
                image.put("username", rs.getString("username"));
                images.put(image);
            }
        }
        
        return images;
    }
    
    private void sendError(HttpServletResponse response, String message) throws IOException {
        JSONObject error = new JSONObject();
        error.put("error", message);
        
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.setContentType("application/json");
        response.getWriter().write(error.toString());
    }
}