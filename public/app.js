import _ from 'lodash';
import $ from 'jquery';
import 'bootstrap';

$(function() {
  $('#exampleModalLong').on('show.bs.modal', function(event) {
    var button = $(event.relatedTarget)
    var modal = $(this)
    modal.find('.modal-title').html(_.join(['hi', 'there'], ' '))
    modal.find('.modal-title').html(button.data("title"))
    modal.find('.modal-body').html(
      `
      <a href="${button.data('url')}" target="_blank">read more</a>
      <br>
      ${button.data("body")}
      `
    )
  })

  var timeout = setTimeout(hideFlash, 2000)

  function hideFlash() {
    $('.flash').addClass('d-none');
    clearTimeout(timeout);
  }
})
