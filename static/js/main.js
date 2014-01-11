if (typeof(window.console) == "undefined") { console = {}; console.log = console.warn = console.error = function(a) {}; }

// thanks for http://d.hatena.ne.jp/sugyan/20110720/1311146296
$(function () {
  var preview = $('#preview');
  if (location.pathname == '/by_one_screen') {
    preview.css({
        height: $(window).height() - preview.offset().top - 5,
        overflow: 'auto'
    });
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
        preview.html(res.html);
        $('#title_preview').text(res.title);
        $('#str_cnt').text(res.str_cnt);
        $('#created_at').text(res.created_at);
        $('#updated_at').text(res.updated_at);
        $('#id').attr('value',res.id);
      }
    });
  };

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

  $('button.editable').click(function () {
    var target = $('fieldset');
    if (target.attr('disabled')) {
      target.removeAttr('disabled');
    }else{
      target.attr('disabled',1);
    }
  });

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
});
