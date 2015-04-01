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
                    '<div class="bubble green"><p>'+
                        Msg +
                    '</p></div>'+                   
                '</div>';
                $("#chat-messages").append(Div);

        }

        function addChatMessage(data){
            var len = data.length;
            var Div = "";
            //var data = dat.sort(function(a,b) {
            //    return a[0]-b[0]
            //});
            for (var i= 0; i< len; i++){
                var row = data[i];

                console.log("row:" + row);   
                var frm = row[1];
                var to = row[2];
                var msgTime = row[0]; 
                var time = moment(msgTime, "YYYY-MM-DD H:m:s").fromNow(); 
                console.log(time);                              
                var Msg = row[3];
                var Div = "";
                //console.log("Frm:" + frm + ", user:" + user + ", msg:" + Msg);
                if(frm === user){
                    Div = '<div class="chat-message">'+ '<div class="bubble bubble-alt tooltips">' + time + '</div>' +                     
                            '<div class="bubble bubble-alt yellow">'+
                                '<p>'+ Msg + '</p>' +
                            '</div>'+                  
                        '</div>';
                }
                else{
                    Div = '<div class="chat-message">'+ '<div class="bubble tooltips">' + time + '</div>' +                 
                            '<div class="bubble green"><p>'+
                                Msg +
                            '</p></div>'+
                        '</div>';
                }

                $("#chat-messages").append(Div);
            }
        }

        function showTypedMessag(Msg){     
               console.log("show typed message");     
                Div = '<div class="chat-message">'+                       
                        '<div class="bubble bubble-alt yellow">'+
                            '<p>'+ Msg + '</p>' +
                        '</div>'+                  
                    '</div>';               
                $("#chat-messages").append(Div);           
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
                var offcolor = onoff === "off" ? ' class=\"off\" ' : '';

                //var fris = fri.split(";");
                //console.log("fris: " +fris);
                var fDiv = '<li id=\"' + fri + '\"' + offcolor  + '>'+
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

        var clickedlist = []; $('#1-gina')
        $( "#friends-list" ).on( "click", "li", function() {
            if(clickedlist.length>0){
                for (var i=0; i<clickedlist.length; i++){
                    var idd = clickedlist[i];
                    $("#" + idd).toggleClass('unclicked');
                }
                clickedlist = [];

            }
            clickedlist.push(this.id);
            console.log("calling friend " + this.id);
            $(this).toggleClass('clicked');
            friend = this.id;
            $.get( "http://localhost:8080/hello/" + user +  "/" + friend + "/2", function( data ) {
                addChatMessage(data);
            });
            //doSend(user + "||" + friend + "||" + "enter chatting");
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
            showTypedMessag(newM);
            $("#new-message").val("");
            doSend(user + "||" + friend + "||"  + newM);         
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

