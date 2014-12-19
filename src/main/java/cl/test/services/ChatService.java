package cl.test.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Created by sjpuas on 19-12-14.
 */
@Service
public class ChatService {

    private static final Logger log = LoggerFactory.getLogger(ChatService.class);

    private Set<WebSocketSession> conns = java.util.Collections.synchronizedSet(new HashSet<WebSocketSession>());
    private Map<WebSocketSession, String> nickNames = new ConcurrentHashMap<>();

    public void registerOpenConnection(WebSocketSession session) {
        conns.add(session);
    }

    public void registerCloseConnection(WebSocketSession session) {
        String nick = nickNames.get(session);
        conns.remove(session);
        nickNames.remove(session);
        if (nick != null) {
            String messageToSend = "{\"removeUser\":\"" + nick + "\"}";
            for (WebSocketSession sock : conns) {
                try {
                    sock.sendMessage(new TextMessage(messageToSend));
                } catch (IOException e) {
                    log.error("IO exception when sending remove user message");
                }
            }
        }
    }

    public void processMessage(WebSocketSession session, String message) {
        if (!nickNames.containsKey(session)) {
            //No nickname has been assigned by now
            //the first message is the nickname
            //escape the " character first
            message = message.replace("\"", "\\\"");

            //broadcast all the nicknames to him
            for (String nick : nickNames.values()) {
                try {
                    session.sendMessage(new TextMessage("{\"addUser\":\"" + nick + "\"}"));
                } catch (IOException e) {
                    log.error("Error when sending addUser message");
                }
            }

            //Register the nickname with the
            nickNames.put(session, message);

            //broadcast him to everyone now
            String messageToSend = "{\"addUser\":\"" + message + "\"}";
            for (WebSocketSession sock : conns) {
                try {
                    sock.sendMessage(new TextMessage(messageToSend));
                } catch (IOException e) {
                    log.error("Error when sending broadcast addUser message");
                }
            }
        } else {
            //Broadcast the message
            String messageToSend = "{\"nickname\":\"" + nickNames.get(session)
                    + "\", \"message\":\"" + message.replace("\"", "\\\"") + "\"}";
            for (WebSocketSession sock : conns) {
                try {
                    sock.sendMessage(new TextMessage(messageToSend));
                } catch (IOException e) {
                    log.error("Error when sending message message");
                }
            }
        }
    }


}
