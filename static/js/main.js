if (typeof(window.console) == "undefined") { console = {}; console.log = console.warn = console.error = function(a) {}; }

// thanks for http://d.hatena.ne.jp/sugyan/20110720/1311146296
$(function () {
      var preview = $('#preview');
      preview.css({
        height: $(window).height() - preview.offset().top - 5,
        overflow: 'auto'
      });

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
});
