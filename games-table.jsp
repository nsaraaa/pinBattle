<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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