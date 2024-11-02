## Used Mandrill templates

All Mailers derived from `MandrillMailer` will also include `Resque::Mailer` - so, will be send asynchronously.
When you need to send a mail right away (for testing/debugging) you can do so by using the bang variant of the method (e.g: `MyMailer.send_this_mail!`)

List of Mailers and which Templates the use:

* `InvitationMailer`
  - beta_invitation
  - beta_download
