class MandrillMailer < ActionMailer::Base
  include Resque::Mailer

  default from: MailerConfig.config['noreply']

  protected


    ##
    # creates a smtp mail using Mandrill's SMTP API
    #   http://help.mandrill.com/entries/21688056-using-smtp-headers-to-customize-your-messages
    #
    # @param [String] The X-MC-Template template_name|block_name
    #                 template_name is the name of the stored template.
    #                 block_name is the name of the mc:edit region where the body of the SMTP
    #                 generated message will be placed. Optional and defaults to "main".
    # @param [Hash] Any "MergeVars" and additional headers to send to Mandrill.
    #
    # @example
    #   chimp_headers 'welcome_mail', {:username => 'Bart', : 'X-MC-Track' => "opens, clicks_htmlonly"}
    def chimp_headers template, data
      h = {}
      data.delete_if { |k, v|
        if k.to_s.downcase.start_with? 'x-mc-'
          h[k] = v
          true
        end
      }
      headers(h)
      headers['X-MC-MergeVars'] = data.to_json
      headers['X-MC-Template'] = template
    end

end