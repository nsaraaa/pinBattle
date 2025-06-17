import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

@ServerEndpoint("/lobby-updates")
public class LobbyWebSocket {
    private static final Set<Session> sessions = Collections.synchronizedSet(new HashSet<>());

    @OnOpen
    public void onOpen(Session session) {
        sessions.add(session);
    }

    @OnClose
    public void onClose(Session session) {
        sessions.remove(session);
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        sessions.remove(session);
        throwable.printStackTrace();
    }

    
    @OnMessage
    public void onMessage(String message, Session session) {
        
        if ("heartbeat".equals(message)) {
            // Respond to heartbeat check
            try {
                session.getBasicRemote().sendText("heartbeat-ack");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        
    }

    public static void notifyGameUpdate(int sessionId) {
        synchronized (sessions) {
            for (Session session : sessions) {
                if (session.isOpen()) {
                    try {
                        session.getBasicRemote().sendText("update:" + sessionId);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}