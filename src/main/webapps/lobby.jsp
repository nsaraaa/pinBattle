<%-- webapp/lobby.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>Game Lobby</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .welcome { font-size: 1.2em; }
        .logout-btn { background: #d9534f; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; }
        .logout-btn:hover { background: #c9302c; }
        .panel { background: white; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); padding: 20px; margin-bottom: 20px; }
        .panel-title { margin-top: 0; color: #333; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        .create-game-form { display: grid; grid-template-columns: 1fr 1fr auto; gap: 10px; }
        .form-input { padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        .form-btn { background: #5cb85c; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .form-btn:hover { background: #4cae4c; }
        .games-list { width: 100%; border-collapse: collapse; }
        .games-list th, .games-list td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #ddd; }
        .games-list th { background-color: #f8f9fa; }
        .games-list tr:hover { background-color: #f5f5f5; }
        .join-btn { background: #337ab7; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; }
        .join-btn:hover { background: #286090; }
        .error { color: #d9534f; margin-bottom: 15px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="welcome">
                Welcome, ${sessionScope.user.username}!
            </div>
            <form action="login" method="post">
                <button type="submit" class="logout-btn">Logout</button>
            </form>
        </div>

        <div class="panel">
            <h2 class="panel-title">Create New Game</h2>
            <form action="create-game" method="post" class="create-game-form">
                <input type="text" name="theme" class="form-input" placeholder="Game theme (e.g. Fantasy, Future)" required>
                <select name="maxPlayers" class="form-input" required>
                    <option value="2">2 Players</option>
                    <option value="3">3 Players</option>
                    <option value="4" selected>4 Players</option>
                    <option value="5">5 Players</option>
                    <option value="6">6 Players</option>
                </select>
                <button type="submit" class="form-btn">Create Game</button>
            </form>
        </div>

        <div class="panel">
            <h2 class="panel-title">Available Games</h2>
            
            <c:if test="${not empty requestScope.error}">
                <div class="error">${requestScope.error}</div>
            </c:if>
            
            <c:choose>
                <c:when test="${empty requestScope.games}">
                    <p>No available games at the moment. Create one!</p>
                </c:when>
                <c:otherwise>
                    <table class="games-list">
                        <thead>
                            <tr>
                                <th>Theme</th>
                                <th>Creator</th>
                                <th>Players</th>
                                <th>Created</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requestScope.games}" var="game">
                                <tr>
                                    <td>${game.theme}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${game.creatorId == sessionScope.user.userId}">
                                                You
                                            </c:when>
                                            <c:otherwise>
                                                Player ${game.creatorId}
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${game.currentPlayers}/${game.maxPlayers}</td>
                                    <td>${game.createdAt}</td>
                                    <td>
                                        <form action="join-game" method="post" style="display: inline;">
                                            <input type="hidden" name="sessionId" value="${game.sessionId}">
                                            <button type="submit" class="join-btn">
                                                <c:choose>
                                                    <c:when test="${game.creatorId == sessionScope.user.userId}">
                                                        Start
                                                    </c:when>
                                                    <c:otherwise>
                                                        Join
                                                    </c:otherwise>
                                                </c:choose>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>


    <%--  Real-time Updates (Optional) --%>
<script>
// Refresh lobby every 5 seconds
setInterval(function() {
    fetch(window.location.href)
        .then(response => response.text())
        .then(html => {
            const parser = new DOMParser();
            const newDoc = parser.parseFromString(html, 'text/html');
            const newTable = newDoc.querySelector('.games-list');
            if (newTable) {
                document.querySelector('.games-list').innerHTML = newTable.innerHTML;
            }
        });
}, 5000);
</script>
</body>
</html>