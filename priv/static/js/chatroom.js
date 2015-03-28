$(function(){
    function pageLoad(){

        var p = window.location.href.split("?");
        var user = (p[1].split("="))[1];
        initWebSocket();
        var friend = "";
        console.log(user);

        
        $.get( "http://localhost:8080/hello/" + user + "/1", function( data ) {
          console.log(data);
          addFriends(data);
        });


        var websocket;
        var friend = "";
        //initWebSocket("erlang chatroom is open for business!!");
        
        function initWebSocket() { 
            websocket = new WebSocket("ws://localhost:8080/ws?user="+user); 
            websocket.onopen = function(evt) { onOpen(evt) }; 
            websocket.onclose = function(evt) { onClose(evt) }; 
            websocket.onmessage = function(evt) { onMessage(evt) }; 
            websocket.onerror = function(evt) { onError(evt) }; 
        }  

        function onOpen(evt) {  console.log("CONNECTED"); /*doSend(user + "||" + friend + "||start chatting."); */}  
        function onClose(evt) { console.log("DISCONNECTED"); }  
        function onError(evt) { console.log("ERROR:" + evt.data); }  
        function doSend(message) { console.log("SENT: " + message);  websocket.send(message); }
        function onMessage(evt) {console.log("Message: " + evt.data); addWsChatMessage(evt.data);}


//"shaila***2015-03-11 07:02pm||hey you how it is going?|||gina***2015-03-11 07:03pm||fine, how about you? |||shaila***2015-03-11 07:04pm***i am doing homework. can you believe it? "
        function addWsChatMessage(Msg){
            console.log(Msg);
            var Div = '<div class="chat-message">'+
                    '<div class="sender pull-left">'+
                        '<div class="icon">'+
                            '<img src="light-blue-2/img/2.jpg" class="img-circle" alt="">'+
                        '</div>'+
                        '<div class="time">'+
                            new Date() +
                        '</div>'+
                    '</div>'+
                    '<div class="chat-message-body">'+
                        '<span class="arrow"></span>'+
                        '<div class="sender"><a href="#">' + friend + '</a></div>'+
                        '<div class="bubble green"><p>'+
                            Msg +
                        '</p></div>'+
                    '</div>'+
                '</div>';
                $("#chat-messages").append(Div);

        }

        function addChatMessage(data){
            //shaila**2015-03-11 07:02pm**hey you how it is going?|||gina**2015-03-11 07:03pm**fine, how about you? |||shaila**2015-03-11 07:04pm**i am doing homework. can you believe it? 
            //var strr = "shaila**2015-03-11 07:02pm**hey you how it is going?|||gina**2015-03-11 07:03pm**fine, how about you? |||shaila**2015-03-11 07:04pm**i am doing homework. can you believe it? ";
            var strArr = data.split("|||");
            var len = strArr.length;
            for (var i=0; i<len; i++){
                var mStr = strArr[i];
                var mS = mStr.split("**");
                var frm = mS[0];
                var msgTime = mS[1];
                var Msg = mS[2];
                var Div = '<div class="chat-message">'+
                    '<div class="sender pull-left">'+
                        '<div class="icon">'+
                            '<img src="light-blue-2/img/2.jpg" class="img-circle" alt="">'+
                        '</div>'+
                        '<div class="time">'+
                            msgTime +
                        '</div>'+
                    '</div>'+
                    '<div class="chat-message-body">'+
                        '<span class="arrow"></span>'+
                        '<div class="sender"><a href="#">' + frm + '</a></div>'+
                        '<div class="bubble green"><p>'+
                            Msg +
                        '</p></div>'+
                    '</div>'+
                '</div>';
                $("#chat-messages").append(Div);
            }
        }

//var strr = "shaila**2015-03-11 07:02pm**hey you how it is going?|||gina**2015-03-11 07:03pm**fine, how about you?";
/*[{<<"shaila-gina">>,2,
  {{2015,3,11},{19,21,7}},
  {messages,[{"shaila",
              {{2015,3,11},{19,2,49}},
              "hey you how it is going?"},
             {"gina",{{2015,3,11},{19,3,49}},"fine, how about you? "},
             {"shaila",
              {{2015,3,11},{19,4,59}},
              "i am doing homework. can you believe it? "}]}}]*/

        function saveChatMessage(){
            var newM = d3.select("#new-message").node().value; 
            console.log(newM);
            //var User = '<<"shaila-gina">>';
            //$.post("http://localhost:8080/hello/shaila-gina/2/shaila/gina", {M:newM});
            //initWebSocket();
            //doSend(newM);
        }

        //<<"gina: March 2, 18:46:1||marcus: March 4, 10:46:2||jack: March 5, 11:46:3">>
        function addFriends(data){
            var frs = data.split("||");
            for (var i=0; i<frs.length; i++){
                var frii = frs[i];
                var fris = frii.split("-");
                var fri = fris[0];
                var onoff = fris[1];
                console.log("fri: " +fri);
                //var fris = fri.split(";");
                //console.log("fris: " +fris);
                var fDiv = '<li id=\"' + fri + '\" >'+
                    '<img src="light-blue-2/img/' + i + '.jpg" alt="" class="pull-left img-circle"/>'+
                    '<div id=' + i + '-' + fri + ' class="news-item-info">'+
                        '<div class="name"><a href="#">' + fri + '-' + onoff + '</a></div>'+
                        '<div class="time">' + (new Date()).toDateString() +'</div>'+
                    '</div>'+
                '</li>';
                console.log(fDiv);
                $("#friends-list").append(fDiv);
            }
        }

        $( "#friends-list" ).on( "click", "li", function() {
            //console.log( $( this ).text() );
            console.log("calling friend " + this.id);
            friend = this.id;
            /*$.get( "http://localhost:8080/hello/" + user + "/2", function( data ) {
                console.log(data);
                addChatMessage(data);
            });*/
            doSend(user + "||" + friend + "||" + "enter chatting");
        });
        
        
        $("#notification-link").click(function(){
            if ( $(window).width() > 767){
                $("#settings").popover('show');
                $(document).on("click", close);
                return false;
            }
        });

        $("#new-message-btn").click(function(){
            var newM = d3.select("#new-message").node().value; 
            console.log("new message button,sending: " + newM);
            doSend(user + "||" + friend + "||"  + newM);
            //saveChatMessage();
        });
   

        $("#feed").slimscroll({
            height: 'auto',
            size: '5px',
            alwaysVisible: true,
            railVisible: true
        });

        $("#chat-messages").slimscroll({
            height: '340px',
            size: '5px',
            alwaysVisible: true,
            railVisible: true
        });

        $('.widget').widgster();
    }

    pageLoad();

    PjaxApp.onPageLoad(pageLoad);
});

