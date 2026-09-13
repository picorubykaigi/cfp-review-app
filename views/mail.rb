class Mail < Funicular::Component
  def initialize_state
    { status: States::ACCEPTED, preview_row: 0 }
  end

  def render
    div(class: 'mail-wrap') do
      render_header
      render_picker
      render_body
    end
  end

  private

  def proposals = props[:proposals]
  def states = props[:states]
  def mails = props[:mails]
  def recipients = proposals.in_state(state.status, states)

  def mail_for(proposal)
    MailTemplate.new(mails.subject_of(state.status), mails.body_of(state.status), proposal)
  end

  def previewed
    found = nil
    recipients.each { |proposal| found = proposal if proposal.row == state.preview_row }
    found
  end

  def on_status(*_event)
    element = JS.document.querySelector('.mail-state')
    patch(status: element.nil? ? state.status : element[:value].to_s, preview_row: 0)
  end

  def copy(label, body)
    JS.global[:navigator][:clipboard].writeText(body)
    props[:on_flash].call("#{label}をコピーしました")
  rescue => error
    props[:on_flash].call("コピー: #{error.class} #{error.message}")
  end

  def render_header
    div(class: 'bar') do
      button(class: 'btn btn-primary btn-sm', onclick: ->(*_event) { props[:on_back].call }) do
        '« Return to Proposals'
      end
      div(class: 'bar-title') { 'Mail' }
    end
  end

  def render_picker
    div(class: 'mail-field') do
      div(class: 'info-item-heading') { 'Status' }
      select(class: 'mail-state', onchange: :on_status) do
        MailTemplate::STATES.each { |value| option(value: value) { States.label_of(value) } }
        ''
      end
    end
  end

  def render_body
    if mails.exists?(state.status)
      render_recipients
    else
      render_missing_template
    end
  end

  def render_missing_template
    div(class: 'mail-none') do
      "Mails タブに #{States.label_of(state.status)} の行がありません。"
    end
  end

  def render_recipients
    list = recipients
    if list.empty?
      div(class: 'mail-none') { '対象がいません。' }
    else
      render_list(list)
      render_preview
    end
  end

  def render_list(list)
    div(class: 'table-scroll') do
      table(class: 'datatable') do
        thead { render_head }
        tbody { list.each { |proposal| render_row(proposal) } }
      end
    end
  end

  def render_head
    tr(class: 'head-row') do
      th { 'Speakers' }
      th { 'Talk Title' }
      th { 'Session Format' }
      th { 'Email' }
      th(class: 'actions') { 'Copy' }
    end
  end

  def render_row(proposal)
    open = ->(*_event) { patch(preview_row: proposal.row) }
    tr(class: state.preview_row == proposal.row ? 'proposal sel' : 'proposal') do
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

  def render_copy_button(label, body)
    button(class: 'btn btn-xs btn-default', onclick: ->(*_event) { copy(label, body) }) { label }
  end

  def render_preview
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
