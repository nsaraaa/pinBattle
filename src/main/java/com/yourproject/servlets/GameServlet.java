package com.yourproject.servlets;

import com.yourproject.dao.GameDao;
import com.yourproject.model.GameSession;
import com.yourproject.model.User;
import com.yourproject.util.DatabaseUtil;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "GameServlet", urlPatterns = {"/lobby", "/create-game", "/join-game", "/start-game"})
public class GameServlet extends HttpServlet {
    private GameDao gameDao = new GameDao();
    private static final String LAST_GAME_COOKIE = "lastGameId";
    private static final String THEME_PREFERENCE_COOKIE = "themePreference";
    private static final int COOKIE_MAX_AGE = 30 * 24 * 60 * 60; // 30 days

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Get user's theme preference from cookie
        Cookie[] cookies = request.getCookies();
        String themePreference = null;
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (THEME_PREFERENCE_COOKIE.equals(cookie.getName())) {
                    themePreference = cookie.getValue();
                    break;
                }
            }
        }
        request.setAttribute("themePreference", themePreference);

        List<GameSession> availableGames = gameDao.getAvailableSessions();
        request.setAttribute("games", availableGames);
        
        // Check if this is an AJAX request for just the games table
        if (request.getServletPath().equals("/game-tables")) {
            request.getRequestDispatcher("game-tables.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("lobby.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession httpSession = request.getSession(false);
        if (httpSession == null || httpSession.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) httpSession.getAttribute("user");
        String path = request.getServletPath();

        if ("/create-game".equals(path)) {
            String theme = request.getParameter("theme");
            int maxPlayers = Integer.parseInt(request.getParameter("maxPlayers"));
            
            // Save theme preference in cookie
            Cookie themeCookie = new Cookie(THEME_PREFERENCE_COOKIE, theme);
            themeCookie.setMaxAge(COOKIE_MAX_AGE);
            themeCookie.setPath("/");
            response.addCookie(themeCookie);
            
            GameSession newGame = new GameSession();
            newGame.setTheme(theme);
            newGame.setMaxPlayers(maxPlayers);
            newGame.setCreatorId(user.getUserId());
            
            if (gameDao.createGameSession(newGame)) {
                response.sendRedirect("lobby");
            } else {
                request.setAttribute("error", "Failed to create game");
                doGet(request, response);
            }
        } else if ("/join-game".equals(path)) {
            try {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                String theme = request.getParameter("theme");
                
                // Save last joined game in cookie
                Cookie lastGameCookie = new Cookie(LAST_GAME_COOKIE, String.valueOf(sessionId));
                lastGameCookie.setMaxAge(COOKIE_MAX_AGE);
                lastGameCookie.setPath("/");
                response.addCookie(lastGameCookie);
                
                // Check if user is already in a game
                String checkCurrentGameSql = "SELECT session_id FROM game_participants WHERE user_id = ?";
                try (Connection conn = DatabaseUtil.getConnection();
                     PreparedStatement stmt = conn.prepareStatement(checkCurrentGameSql)) {
                    stmt.setInt(1, user.getUserId());
                    ResultSet rs = stmt.executeQuery();
                    if (rs.next()) {
                        // User is already in a game, redirect to game.jsp
                        response.sendRedirect("game.jsp?sessionId=" + sessionId + "&theme=" + URLEncoder.encode(theme, "UTF-8"));
                        return;
                    }
                }
                
                if (gameDao.joinGameSession(sessionId, user.getUserId())) {
                    response.sendRedirect("game.jsp?sessionId=" + sessionId + "&theme=" + URLEncoder.encode(theme, "UTF-8"));
                } else {
                    request.setAttribute("error", "Unable to join game. The game might be full or no longer available.");
                    doGet(request, response);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid game session ID");
                doGet(request, response);
            } catch (SQLException e) {
                request.setAttribute("error", "Database error occurred");
                doGet(request, response);
            }
        } else if ("/start-game".equals(path)) {
            try {
                int sessionId = Integer.parseInt(request.getParameter("sessionId"));
                String theme = request.getParameter("theme");
                int maxPlayers = Integer.parseInt(request.getParameter("maxPlayers"));
                int currentPlayers = Integer.parseInt(request.getParameter("currentPlayers"));
                
                // Save last started game in cookie
                Cookie lastGameCookie = new Cookie(LAST_GAME_COOKIE, String.valueOf(sessionId));
                lastGameCookie.setMaxAge(COOKIE_MAX_AGE);
                lastGameCookie.setPath("/");
                response.addCookie(lastGameCookie);
                
                // Verify user is the creator
                GameSession game = gameDao.getGameSession(sessionId);
                if (game == null || game.getCreatorId() != user.getUserId()) {
                    request.setAttribute("error", "Only the game creator can start the game");
                    doGet(request, response);
                    return;
                }
                
                // Verify minimum players
                if (currentPlayers < 2) {
                    request.setAttribute("error", "You need at least 2 players to start");
                    doGet(request, response);
                    return;
                }
                
                // Start the game
                if (gameDao.updateGameStatus(sessionId, "in_progress")) {
                    // Redirect to game page with all necessary parameters
                    String redirectUrl = String.format(
                        "game.jsp?sessionId=%d&theme=%s&maxPlayers=%d&currentPlayers=%d",
                        sessionId,
                        URLEncoder.encode(theme, "UTF-8"),
                        maxPlayers,
                        currentPlayers
                    );
                    response.sendRedirect(redirectUrl);
                } else {
                    request.setAttribute("error", "Failed to start game");
                    doGet(request, response);
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid game parameters");
                doGet(request, response);
            }
        }
    }

 