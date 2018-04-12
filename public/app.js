$(()=> {
  console.log("hi")
  $('#exampleModalLong').on('show.bs.modal', function(event) {
    var button = $(event.relatedTarget)
    console.log(button.data("url"))
    var modal = $(this)
    modal.find('.modal-title').html(button.data("title"))
    modal.find('.modal-body').html(
      `
      <a href="${button.data('url')}" target="_blank">read more</a>
      <br>
      ${button.data("body")}
      `
    )
  })
})
