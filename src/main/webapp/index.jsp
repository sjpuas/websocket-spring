<!DOCTYPE html>
<html>
<head>
    <title>Chat</title>
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">


    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
    <script src="//cdn.jsdelivr.net/sockjs/0.3.4/sockjs.min.js"></script>

    <style>
        .contentDiv {
            width:100%;
            height:400px;
            border-color: #dddddd;
            border-width: thin;
            border-style: solid;
            border-radius: 4px;
            display: block;
            padding:5px;
            overflow: auto;
        }

        .username {
            font-weight: bold;
            color: #555599;
        }

    </style>

</head>
<body>
<div class="container">
    <div class="row">
        <div class="col-xs-9">
            <h1>Chat room</h1>
        </div>

    </div>
    <div class="row">
        <div class="col-xs-9">
            <div><h3>Chat</h3></div>
            <div class="contentDiv" id="chatBox">
                <!--           <div><span class="username">hsilomedus : </span><span>whass uuup?</span></div> -->
            </div>
        </div>
        <div class="col-xs-3">
            <div><h3>Users</h3></div>
            <div class="contentDiv" id="nicknamesBox">
                <!--           <div class="username">hsilomedus</div> -->
            </div>
        </div>
    </div>
    <div class="row" style="margin-top:10px;">
        <div class="col-xs-7"><input type="text" id="txtMessage" class="form-control" placeholder="Type your message here."/></div>
        <div class="col-xs-2"><button id="btnSend" class="btn btn-primary" style="width:100%;">Send</button></div>
    </div>
</div>

<div class="modal fade" id="login_modal">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">Enter your nickname</h4>
            </div>
            <div class="modal-body">
                <div>Please enter your desired nickname:</div>
                <div style="margin-top:5px;"><input type="text" id="nickname" class="form-control" style="width:200px;" placeholder="Nickname..." /> </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="btnLogin">Login</button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">

    var socket;
    var registered = false;

    function startClient() {
        socket = new SockJS("http://" +document.domain + ":8080/websocket-spring/chat");
        socket.onopen = function() {
            var nickname = $("#nickname").val();
            socket.send(nickname);
        };

        socket.onmessage = function(a) {
            var message = JSON.parse(a.data);
            if (message.addUser) {
                var d = document.createElement('div');
                $(d).addClass("username user").text(message.addUser).attr("data-user", message.addUser).appendTo("#nicknamesBox");
            } else if (message.removeUser) {
                $(".user[data-user="+message.removeUser+"]").remove();
            } else if (message.message) {
                var d = document.createElement('div');
                var suser = document.createElement('span');
                var smessage = document.createElement('span');

                $(suser).addClass("username").text(message.nickname+" : ").appendTo($(d));
                $(smessage).text(message.message).appendTo($(d));
                $(d).appendTo("#chatBox");
                $("#chatBox").scrollTop($("#chatBox")[0].scrollHeight);
            }

        };

        socket.onclose = function() { document.write("Closed socket."); };
        socket.onerror = function() { document.write("Error during transfer."); };

        $('#txtMessage').keyup(function(e){
            if (e.keyCode == 13) {
                sendMessage();
            }
        });
        $("#btnSend").click(function() {
            sendMessage();
        });

    }

    function sendMessage() {
        if ($("#txtMessage").val()) {
            socket.send($("#txtMessage").val());
            $("#txtMessage").val("");
        }
    }


    $(document).ready(function() {
        $('#login_modal').modal({keyboard:false, backdrop:'static'});
        $('#btnLogin').click(function() {
            if ($("#nickname").val()) {
                $('#login_modal').modal('hide');
                startClient();
            }
        });

    });



</script>

</body>
</html>
