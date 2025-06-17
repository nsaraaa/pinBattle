<%-- webapp/lobby.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Game Lobby - Image Selection Game</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="css/lobbyStyle.css" rel="stylesheet">
    <style>
     
    </style>
</head>
<body>
    <!-- Floating particles -->
    <div class="particle"></div>
    <div class="particle"></div>
    <div class="particle"></div>

    <!-- Connection status indicator -->
    <div class="connection-status connected" id="connectionStatus">
        <i class="fas fa-circle"></i> Connected
    </div>

    <div class="container">
        <div class="header">
            <div class="welcome">
                <i class="fas fa-gamepad"></i>
                Welcome, ${sessionScope.user.username}!
            </div>
            <form action="login" method="post">
                <button type="submit" class="logout-btn">
                    <i class="fas fa-sign-out-alt"></i>
                    Logout
                </button>
            </form>
        </div>

        <div class="panel">
            <h2 class="panel-title">
                <i class="fas fa-plus-circle"></i>
                Create New Game
            </h2>
            <form action="create-game" method="post" class="create-game-form">
                <input type="text" name="theme" class="form-input" 
                    placeholder="Enter game theme (e.g. Fantasy, Future, Nature)" 
                    value="${requestScope.themePreference}"
                    required>
                <select name="maxPlayers" class="form-input" required>
                    <option value="2">2 Players</option>
                    <option value="3">3 Players</option>
                    <option value="4" selected>4 Players</option>
                    <option value="5">5 Players</option>
                    <option value="6">6 Players</option>
                </select>
                <button type="submit" class="form-btn">
                    <i class="fas fa-rocket"></i>
                    Create Game
                </button>
            </form>
        </div>

        <div class="panel">
            <h2 class="panel-title">
                <i class="fas fa-list"></i>
                Available Games
            </h2>
            <c:if test="${not empty error}">
                <div class="error">
                    <i class="fas fa-exclamation-triangle"></i>
                    ${error}
                </div>
            </c:if>
            <table class="games-list">
                <thead>
                    <tr>
                        <th><i class="fas fa-tag"></i> Theme</th>
                        <th><i class="fas fa-user"></i> Creator</th>
                        <th><i class="fas fa-users"></i> Players</th>
                        <th><i class="fas fa-info-circle"></i> Status</th>
                        <th><i class="fas fa-bolt"></i> Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${requestScope.games}" var="game">
                        <tr>
                            <td><strong>${game.theme}</strong></td>
                            <td>
                                <c:choose>
                                    <c:when test="${game.creatorId == sessionScope.user.userId}">
                                        <i class="fas fa-crown" style="color: var(--gold-accent);"></i> You
                                    </c:when>
                                    <c:otherwise>
                                        Player ${game.creatorId}
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="player-count">${game.currentPlayers}/${game.maxPlayers}</span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${game.status == 'waiting'}">
                                        <span class="status-waiting">
                                            <i class="fas fa-clock"></i>
                                            Waiting for players
                                        </span>
                                    </c:when>
                                    <c:when test="${game.status == 'in_progress'}">
                                        <span class="status-progress">
                                            <i class="fas fa-play"></i>
                                            In Progress
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        ${game.status}
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                   <c:when test="${game.creatorId == sessionScope.user.userId}">
                                        <form action="start-game" method="post" style="display: inline;">
                                            <input type="hidden" name="sessionId" value="${game.sessionId}">
                                            <input type="hidden" name="theme" value="${game.theme}">
                                            <input type="hidden" name="maxPlayers" value="${game.maxPlayers}">
                                            <input type="hidden" name="currentPlayers" value="${game.currentPlayers}">
                                            <button type="submit" class="join-btn" ${game.currentPlayers < 2 ? 'disabled' : ''}>
                                                <c:choose>
                                                    <c:when test="${game.currentPlayers >= 2}">
                                                        <i class="fas fa-play"></i>
                                                        Start Game
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="fas fa-hourglass-half"></i>
                                                        Wait for Players
                                                    </c:otherwise>
                                                </c:choose>
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:when test="${game.status == 'waiting' && game.currentPlayers < game.maxPlayers}">
                                        <form action="join-game" method="post" style="display: inline;">
                                            <input type="hidden" name="sessionId" value="${game.sessionId}">
                                            <input type="hidden" name="theme" value="${game.theme}">
                                            <button type="submit" class="join-btn">
                                                <i class="fas fa-sign-in-alt"></i>
                                                Join Game
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="join-btn" disabled>
                                            <c:choose>
                                                <c:when test="${game.status == 'in_progress'}">
                                                    <i class="fas fa-play"></i>
                                                    Game Started
                                                </c:when>
                                                <c:when test="${game.currentPlayers >= game.maxPlayers}">
                                                    <i class="fas fa-users"></i>
                                                    Game Full
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fas fa-ban"></i>
                                                    Unavailable
                                                </c:otherwise>
                                            </c:choose>
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        // Enhanced WebSocket connection with status indicator
        const connectionStatus = document.getElementById('connectionStatus');
        const socket = new WebSocket("ws://" + window.location.host + "${pageContext.request.contextPath}/lobby-updates");

        // Function to fetch and update games
        function fetchGames() {
            fetch('lobby')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.text();
                })
                .then(html => {
                    const parser = new DOMParser();
                    const newDoc = parser.parseFromString(html, 'text/html');
                    const newTable = newDoc.querySelector('.games-list');
                    if (newTable) {
                        const currentTable = document.querySelector('.games-list');
                        if (currentTable) {
                            currentTable.innerHTML = newTable.innerHTML;
                        }
                    }
                })
                .catch(error => {
                    console.error('Error loading games:', error);
                });
        }

        // Initial fetch when page loads
        document.addEventListener('DOMContentLoaded', function() {
            fetchGames();
            // Set up periodic refresh every 5 seconds
            setInterval(fetchGames, 5000);
        });

        socket.onopen = function() {
            connectionStatus.className = 'connection-status connected';
            connectionStatus.innerHTML = '<i class="fas fa-circle"></i> Connected';
        };

        socket.onclose = function() {
            connectionStatus.className = 'connection-status disconnected';
            connectionStatus.innerHTML = '<i class="fas fa-circle"></i> Disconnected';
        };

        socket.onerror = function() {
            connectionStatus.className = 'connection-status disconnected';
            connectionStatus.innerHTML = '<i class="fas fa-exclamation-triangle"></i> Connection Error';
        };

        socket.onmessage = function(event) {
            const message = event.data;
            if (message.startsWith("update")) {
                fetchGames();
            }
        };

        // Enhanced connection monitoring
        let heartbeatInterval;
        
        function startHeartbeat() {
            heartbeatInterval = setInterval(() => {
                if (socket.readyState === WebSocket.OPEN) {
                    socket.send('ping');
                } else {
                    connectionStatus.className = 'connection-status disconnected';
                    connectionStatus.innerHTML = '<i class="fas fa-circle"></i> Reconnecting...';
                    
                    // Attempt to reconnect
                    setTimeout(() => {
                        if (socket.readyState !== WebSocket.OPEN) {
                            window.location.reload();
                        }
                    }, 5000);
                }
            }, 10000);
        }

        startHeartbeat();

        // Enhanced form interactions
        document.addEventListener('DOMContentLoaded', function() {
            const forms = document.querySelectorAll('form');
            const buttons = document.querySelectorAll('button[type="submit"]');

            // Add loading states to form submissions
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    const submitBtn = form.querySelector('button[type="submit"]');
                    if (submitBtn && !submitBtn.disabled) {
                        submitBtn.classList.add('loading');
                        submitBtn.disabled = true;
                        
                        // Re-enable after a delay to prevent stuck states
                        setTimeout(() => {
                            submitBtn.classList.remove('loading');
                            submitBtn.disabled = false;
                        }, 5000);
                    }
                });
            });

            // Enhanced table interactions
            const tableRows = document.querySelectorAll('.games-list tbody tr');
            tableRows.forEach(row => {
                row.addEventListener('mouseenter', function() {
                    this.style.transform = 'scale(1.01)';
                    this.style.zIndex = '1';
                });
                
                row.addEventListener('mouseleave', function() {
                    this.style.transform = 'scale(1)';
                    this.style.zIndex = 'auto';
                });
            });

            // Auto-focus on theme input
            const themeInput = document.querySelector('input[name="theme"]');
            if (themeInput) {
                themeInput.focus();
            }

            // Add theme suggestions
            const themeInputs = ['Fantasy Adventure', 'Sci-Fi Future', 'Nature & Wildlife', 'Space Exploration', 'Medieval Times', 'Ocean Depths'];
            let suggestionIndex = 0;
            
            if (themeInput) {
                themeInput.addEventListener('focus', function() {
                    if (!this.value) {
                        this.placeholder = themeInputs[suggestionIndex % themeInputs.length];
                        suggestionIndex++;
                    }
                });
            }
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Alt + N for new game focus
            if (e.altKey && e.key === 'n') {
                e.preventDefault();
                const themeInput = document.querySelector('input[name="theme"]');
                if (themeInput) themeInput.focus();
            }
            
            // Escape to clear focused elements
            if (e.key === 'Escape') {
                document.activeElement.blur();
            }
        });

        // Cleanup on page unload
        window.addEventListener('beforeunload', function() {
            if (heartbeatInterval) {
                clearInterval(heartbeatInterval);
            }
            if (socket.readyState === WebSocket.OPEN) {
                socket.close();
            }
        });
    </script>
</body>
</html>