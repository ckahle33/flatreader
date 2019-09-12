document.addEventListener("DOMContentLoaded", function() {

    // MicroModal.init();
      // onShow: modal => {
      //   let button = modal.find('button')
      //   modal.find('.modal-title').html(button.data("title"))
      //   modal.find('.modal-body').html(
      //     `
      //     <a href="${button.data('url')}" target="_blank">read more</a>
      //     <br>
      //     ${button.data("body")}
      //     `
      //   )
      // }

    // const choices = new Choices(document.getElementById("source_tags"))


})



// Pure.css layout code
(function (window, document) {

    var layout   = document.getElementById('layout'),
        menu     = document.getElementById('menu'),
        menuLink = document.getElementById('menuLink'),
        content  = document.getElementById('main');

    function toggleClass(element, className) {
        var classes = element.className.split(/\s+/),
            length = classes.length,
            i = 0;

        for(; i < length; i++) {
          if (classes[i] === className) {
            classes.splice(i, 1);
            break;
          }
        }
        // The className is not found
        if (length === classes.length) {
            classes.push(className);
        }

        element.className = classes.join(' ');
    }

    function toggleAll(e) {
        var active = 'active';

        e.preventDefault();
        toggleClass(layout, active);
        toggleClass(menu, active);
        toggleClass(menuLink, active);
    }

    menuLink.onclick = function (e) {
        toggleAll(e);
    };

    content.onclick = function(e) {
        if (menu.className.indexOf('active') !== -1) {
            toggleAll(e);
        }
    };

}(this, this.document));
