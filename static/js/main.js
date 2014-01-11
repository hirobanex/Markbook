if (typeof(window.console) == "undefined") { console = {}; console.log = console.warn = console.error = function(a) {}; }

// thanks for http://d.hatena.ne.jp/sugyan/20110720/1311146296
$(function () {
  function set_memo_data(res) {
    $('#preview').html(res.html);
    $('#title_preview').text(res.title);
    $('#str_cnt').text(res.str_cnt);
    $('#created_at').text(res.created_at);
    $('#updated_at').text(res.updated_at);
    $('#id').attr('value',res.id);
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
      $('#websocket-info').text(msg);
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
          log('connected');
      };
      ws.onclose = function (ev) {
          log('closed');
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

});




