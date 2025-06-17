package com.yourproject.util;

import org.json.JSONArray;
import org.json.JSONObject;
import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;

public class JsonFileUtil {
    private static final String BACKUP_DIR = "image_backups";
    private static final String FILE_EXTENSION = ".json";

    static {
        // Create backup directory if it doesn't exist
        try {
            Files.createDirectories(Paths.get(BACKUP_DIR));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void saveImagesToJson(String sessionId, List<ImageData> images) {
        try {
            JSONArray jsonArray = new JSONArray();
            for (ImageData img : images) {
                JSONObject json = new JSONObject();
                json.put("url", img.getUrl());
                json.put("description", img.getDescription());
                json.put("username", img.getUsername());
                json.put("timestamp", img.getTimestamp());
                jsonArray.put(json);
            }

            String filePath = getFilePath(sessionId);
            Files.write(Paths.get(filePath), jsonArray.toString(2).getBytes());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static List<ImageData> loadImagesFromJson(String sessionId) {
        List<ImageData> images = new ArrayList<>();
        try {
            String filePath = getFilePath(sessionId);
            if (!Files.exists(Paths.get(filePath))) {
                return images;
            }

            String content = new String(Files.readAllBytes(Paths.get(filePath)));
            JSONArray jsonArray = new JSONArray(content);

            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject json = jsonArray.getJSONObject(i);
                ImageData img = new ImageData();
                img.setUrl(json.getString("url"));
                img.setDescription(json.getString("description"));
                img.setUsername(json.getString("username"));
                img.setTimestamp(json.getString("timestamp"));
                images.add(img);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return images;
    }

    private static String getFilePath(String sessionId) {
        return BACKUP_DIR + File.separator + "session_" + sessionId + FILE_EXTENSION;
    }

    public static class ImageData {
        private String url;
        private String description;
        private String username;
        private String timestamp;

        public String getUrl() { return url; }
        public void setUrl(String url) { this.url = url; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public String getUsername() { return username; }
        public void setUsername(String username) { this.username = username; }
        public String getTimestamp() { return timestamp; }
        public void setTimestamp(String timestamp) { this.timestamp = timestamp; }
    }
} 