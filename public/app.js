import _ from 'lodash';
import MicroModal from 'micromodal';
import 'selectize/dist/js/standalone/selectize.min.js';


document.addEventListener("DOMContentLoaded",function(){
  MicroModal.init({
    onShow: modal => {
      let button = modal.find('button')
      modal.find('.modal-title').html(button.data("title"))
      modal.find('.modal-body').html(
        `
        <a href="${button.data('url')}" target="_blank">read more</a>
        <br>
        ${button.data("body")}
        `
      )

    document.getElementById("source_tags").selectize({
      delimiter: ',',
      persist: false,
      create: function(input) {
          return {
              value: input,
              text: input
          }
      }
    })
  });

  var timeout = setTimeout(hideFlash, 2000)

  function hideFlash() {
    document.querySelector('.flash').classList.add('d-none');
    clearTimeout(timeout);
  }

})
