module.exports.deliverEmail = (address, subject, html) ->
  server = email.server.connect
    host: process.env['EMAIL_HOST'],
    port: process.env['EMAIL_PORT'],
    user: process.env['EMAIL_USER'],
    password: process.env['EMAIL_PASSWORD']

  headers =
     from:    "Highline <hello@highlineapp.com>"
     to:      address
     subject: subject

  # create the message
  message = email.message.create(headers)
  message.text = html
  message.attach({data:html, alternative: true})
  server.send message, (err, result) ->
    console.log('Email sent to ' + address + ' with error: ', err)

