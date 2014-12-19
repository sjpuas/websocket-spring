<%--
  Created by IntelliJ IDEA.
  User: sjpuas
  Date: 19-12-14
  Time: 02:24 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <script src="//cdn.jsdelivr.net/sockjs/0.3.4/sockjs.min.js"></script>
</head>
<body>
<script>
    var count = 0;
    var socket = new SockJS("http://" + document.domain + ":8080/websocket-spring/chat");
    socket.onopen = function () {
        var nickname = 'nickname_' + (new Date().getTime());
        socket.send(nickname);
    };

    socket.onmessage = function (a) {
        var message = JSON.parse(a.data);
        console.info(message);
        socket.send('random message count:' + (count++));
    };

    socket.onclose = function () {
        console.info("Closed socket.");
    };
    socket.onerror = function () {
        console.info("Error during transfer.");
    };


</script>
</body>
</html>
