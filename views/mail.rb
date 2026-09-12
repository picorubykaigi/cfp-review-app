module MailView
  def render_mail
    div(class: 'mail-wrap') do
      div(class: 'bar') do
        button(class: 'btn btn-primary btn-sm', onclick: :back_to_list) do
          '« Return to Proposals'
        end
        div(class: 'bar-title') { 'Mail' }
      end
      render_mail_picker
      render_mail_table
    end
  end

  def render_mail_picker
    div(class: 'mail-field') do
      div(class: 'info-item-heading') { 'Status' }
      select(class: 'mail-state', onchange: :on_mail_state) do
        MailTemplate::STATES.each { |value| option(value: value) { States.label_of(value) } }
        ''
      end
    end
  end

  def render_mail_table
    if mail_text.empty?
      render_missing_template
    else
      render_recipients
    end
  end

  def render_missing_template
    path = MailTemplate::PATHS[state.mail_state]
    div(class: 'mail-none') { "#{path} がありません。#{path}.sample をコピーしてください。" }
  end

  def render_recipients
    list = mail_proposals
    if list.empty?
      div(class: 'mail-none') { '対象がいません。' }
    else
      render_mail_list(list)
      render_mail_preview
    end
  end

  def render_mail_list(list)
    div(class: 'table-scroll') do
      table(class: 'datatable') do
        thead do
          tr(class: 'head-row') do
            th { 'Speakers' }
            th { 'Talk Title' }
            th { 'Session Format' }
            th { 'Email' }
            th(class: 'actions') { 'Copy' }
          end
        end
        tbody { list.each { |proposal| render_mail_row(proposal) } }
      end
    end
  end

  def render_mail_row(proposal)
    open = ->(*_event) { preview_mail(proposal.row) }
    tr(class: state.mail_row == proposal.row ? 'proposal sel' : 'proposal') do
      td(class: 'c-speaker', onclick: open) { proposal.name }
      td(class: 'c-title', onclick: open) { proposal.title }
      td(class: 'c-format', onclick: open) { proposal.format_label }
      td(class: 'c-email', onclick: open) { proposal.email }
      td(class: 'c-actions') { div(class: 'state-buttons') { render_copy_buttons(proposal) } }
    end
  end

  def render_copy_buttons(proposal)
    mail = mail_for(proposal)
    render_copy_button('宛先', proposal.email)
    render_copy_button('件名', mail.subject)
    render_copy_button('本文', mail.body)
    ''
  end

  def render_copy_button(label, text)
    button(class: 'btn btn-xs btn-default', onclick: ->(*_event) { copy(label, text) }) { label }
  end

  def render_mail_preview
    proposal = previewed
    if proposal.nil?
      ''
    else
      render_preview_of(mail_for(proposal))
    end
  end

  def render_preview_of(mail)
    div(class: 'mail-preview') do
      div(class: 'info-item-heading') { 'Preview' }
      div(class: 'mail-subject') { mail.subject }
      div(class: 'mail-text') { mail.body }
    end
  end
end
