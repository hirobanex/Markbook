if (typeof(window.console) == "undefined") { console = {}; console.log = console.warn = console.error = function(a) {}; }

// thanks for http://d.hatena.ne.jp/sugyan/20110720/1311146296
$(function () {
  function set_memo_data(res) {
    var id = $('#id').val();

    if (!id) {
      var preview_url = $('#preview_request').attr('data-url');
      var l = Location.parse(preview_url);
      l = l.params({id: res.id});
      $('#preview_request').attr('data-url',l.href);

      var to_html_url = $('#to_html').attr('href');
      var l = Location.parse(to_html_url);
      l = l.params({id: res.id});
      $('to_html').attr('href',l.href);

      $('#id').attr('value',res.id);  
    }

    if (id == res.id) {
      $('#preview').html(res.html);
      $('#title_preview').text(res.title);
      $('#str_cnt').text(res.str_cnt);
      $('#created_at').text(res.created_at);
      $('#updated_at').text(res.updated_at);
    }
    return false;
  }
  function preview_post (title,body) {
    var id   = $('#id').val();
    $.ajax({
      url: '/preview',
      type: 'POST',
      data: {
        id: id,
        title: title,
        body: body,
      },
      success: function (res) {
        set_memo_data(res);
      }
    });
  };

  $('button.editable').click(function () {
      var target = $('fieldset');
        if (target.attr('disabled')) {
      target.removeAttr('disabled');
      }else{
        target.attr('disabled',1);
      }
  });

  $('.preview_request').click(function () {
    var target = $(this);
    w=window.open(target.attr('data-url'),'','scrollbars=yes,Width=1200,Height=700');
    w.focus();
  });
  
  if (location.pathname == '/by_one_screen') {
    var preview = $('#preview');
    preview.css({
        height: $(window).height() - preview.offset().top - 5,
        overflow: 'auto'
    });

    $('textarea').focus().keyup(function () {
        var body   = $(this).val();
        var title   = $('#title').val();
        preview_post(title,body);
    });

    $('#title').focus().keyup(function () {
        var title   = $(this).val();
        var body   = $('textarea').val();
        preview_post(title,body);
    });

    if ($('#init').attr('value') == 0) {
        var title   = $('#title').val();
        var body   = $('textarea').val();
        preview_post(title,body);
        $('#init').attr('value',1);
    }
  }

  if (location.pathname == '/') {
    $('button.delete').click(function () {
        var target = $(this);

        target.button('loading');
        
        var target_id = target.attr('data-id');

        $.ajax({
        type: 'POST',
        url: target.attr('data-url'),
        data: {
            id   : target_id,
        },
        success: function(data) {
            if (data.alert) {
            var json = data.alert;

            var len = data.alert.length;

            var modal_body = target.parent().parent().children('div.modal-body');

            for(var i=0; i<len; i++){
                modal_body.append('<div class="alert alert-danger">'+json[i].message+'</div>');
                target.button('fail');
            }

            return false;
            }
            target.button('complete');

            $('#delete-modal-'+target_id).modal('hide');

            $("li#id-"+target_id).hide();
        },
        error: function() {
            alert("失敗しました");

            target.button('reset');
        },
        dataType: 'json'
        });
        return false;
    });
  }

  function log(msg) {
  }

  function websocket_send(title,body) {
    var id   = $('#id').val();
    ws.send(JSON.stringify({
      "id": id,
      "title": title,
      "body": body,
    }));
    return false;
  }

  if (location.pathname == '/edit' || location.pathname == '/view') {
      var hostport = $(document.body).data('host_port');
      var ws = new WebSocket('ws://' + hostport + '/preview_by_websocket');
      ws.onopen = function () {
        $('#websocket-info-label').removeClass('label-danger').addClass('label-success').text('connected');
      };
      ws.onclose = function (ev) {
        $('#websocket-info-label').removeClass('label-danger').addClass('label-danger').text('closed');
      };
      ws.onmessage = function (ev) {
          var res = JSON.parse(ev.data);
          set_memo_data(res);
      };
      ws.onerror = function (ev) {
          console.log(ev);
          log('error: ' + ev.data);
      };
      $('textarea').focus().keyup(function () {
          var body   = $(this).val();
          var title  = $('#title').val();

          websocket_send(title,body);
      });
      $('#title').focus().keyup(function () {
          var title  = $(this).val();
          var body   = $('textarea').val();

          websocket_send(title,body);
      });
  }

  $('#created_at,#updated_at').each(function(){
    var epoch = $(this).text();
    datetime = (new Date(epoch*1000)).strftime('%Y-%m-%dT%H:%M:%S');
    $(this).text(datetime);
  });

});




