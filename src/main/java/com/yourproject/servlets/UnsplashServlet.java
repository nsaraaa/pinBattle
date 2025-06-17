
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;



public class UnsplashServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String API_KEY = "6ZoMWYMB6_ep4ckIfU3gQIim-lVj0-LtY6AHe3OdIV8";

    private static final int NUMBER_OF_IMAGES = 100;
    
   

    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        
        System.out.println("Entering doGet method...");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            System.out.println("Attempting to connect to Unsplash API...");
            
            // Get search query if exists
            String query = request.getParameter("query");
            String apiUrl;
            
            // If there's a search query, use the search endpoint
            if (query != null && !query.trim().isEmpty()) {
                System.out.println("Search query: " + query);
                apiUrl = "https://api.unsplash.com/search/photos?query=" + 
                         URLEncoder.encode(query.trim(), "UTF-8") + 
                         "&per_page=" + NUMBER_OF_IMAGES + "&client_id=" + API_KEY;
            } else {
                // Otherwise get random images
                System.out.println("No query, getting random images");
                apiUrl = "https://api.unsplash.com/photos/random?count=" + NUMBER_OF_IMAGES + "&client_id=" + API_KEY;
            }
            
            System.out.println("API URL: " + apiUrl);

            URL url = new URL(apiUrl);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("Accept", "application/json");

            // Add timeout settings
            connection.setConnectTimeout(10000); // 10 seconds
            connection.setReadTimeout(15000);    // 15 seconds

            System.out.println("Establishing connection...");
            
            int responseCode = connection.getResponseCode();
            System.out.println("Response Code: " + responseCode);

            if (responseCode == HttpURLConnection.HTTP_OK) {
                // Read the response
                BufferedReader reader = new BufferedReader(
                        new InputStreamReader(connection.getInputStream()));
                StringBuilder responseBody = new StringBuilder();
                String line;

                while ((line = reader.readLine()) != null) {
                    responseBody.append(line);
                }
                reader.close();

                // Parse JSON response
                JSONArray unsplashImages;
                if (query != null && !query.trim().isEmpty()) {
                    // For search results, the array is in the "results" property
                    unsplashImages = new JSONObject(responseBody.toString()).getJSONArray("results");
                    System.out.println("Search returned " + unsplashImages.length() + " images");
                } else {
                    // For random images, it's directly the array
                    unsplashImages = new JSONArray(responseBody.toString());
                    System.out.println("Random query returned " + unsplashImages.length() + " images");
                }

                // Create our response JSON
                JSONObject ourResponse = new JSONObject();
                JSONArray imagesArray = new JSONArray();

                // Extract relevant information for each image
                for (int i = 0; i < unsplashImages.length(); i++) {
                    JSONObject unsplashImage = unsplashImages.getJSONObject(i);

                    JSONObject imageObj = new JSONObject();
                    imageObj.put("url", unsplashImage.getJSONObject("urls").getString("regular"));

                    // Get description or alt_description
                    String description = unsplashImage.optString("description");
                    if (description == null || description.isEmpty()) {
                        description = unsplashImage.optString("alt_description", "Unsplash Image");
                    }
                    imageObj.put("description", description);

                    // Add user attribution
                    JSONObject user = unsplashImage.getJSONObject("user");
                    String username = user.getString("name");
                    imageObj.put("user", username);

                    imagesArray.put(imageObj);
                }

                ourResponse.put("images", imagesArray);

                // Send the response
                System.out.println("Sending response with " + imagesArray.length() + " images");
                out.print(ourResponse.toString());

            } else {
                // Handle error
                System.err.println("Error from Unsplash API: " + responseCode);
                String errorStream = readErrorStream(connection);
                System.err.println("Error details: " + errorStream);
                
                JSONObject errorResponse = new JSONObject();
                errorResponse.put("error", "Unsplash API returned status code: " + responseCode);
                errorResponse.put("details", errorStream);
                out.print(errorResponse.toString());
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }

        } catch (Exception e) {
            // Handle exceptions
            System.err.println("Exception occurred:");
            e.printStackTrace();
            
            // Create fallback response with some default images
            JSONObject fallbackResponse = new JSONObject();
            JSONArray fallbackImagesArray = new JSONArray();
            
            // // Add fallback images
            // for (int i = 0; i < FALLBACK_IMAGES.length; i++) {
            //     JSONObject imageObj = new JSONObject();
            //     imageObj.put("url", FALLBACK_IMAGES[i]);
            //     imageObj.put("description", "Fallback Image " + (i+1));
            //     imageObj.put("user", "Unsplash");
            //     fallbackImagesArray.put(imageObj);
            // }
            
            fallbackResponse.put("images", fallbackImagesArray);
            
            // Send fallback response instead of error
            System.out.println("Sending fallback response with " + fallbackImagesArray.length() + " images");
            out.print(fallbackResponse.toString());
            
            // Still set 200 status since we're providing fallback content
            response.setStatus(HttpServletResponse.SC_OK);
        } finally {
            out.flush();
        }
    }

    private String readErrorStream(HttpURLConnection connection) {
        try {
            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(connection.getErrorStream()));
            StringBuilder responseBody = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                responseBody.append(line);
            }
            reader.close();
            return responseBody.toString();
        } catch (Exception e) {
            return "Could not read error stream: " + e.getMessage();
        }
    }
}