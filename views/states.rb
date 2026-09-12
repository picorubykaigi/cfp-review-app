module StatesView
  def render_state_filter
    select(class: 'f-state', onchange: :on_filter_state) do
      option(value: '') { 'All' }
      States::ALL.each { |value| option(value: value) { States.label_of(value) } }
      ''
    end
  end

  def render_state_label(row)
    span(class: "label #{@states.label_class(row)} label-compact") { @states.label(row) }
  end

  def render_state_header(proposal)
    div(class: 'state-header') do
      div(class: 'info-item-heading') { 'Status' }
      render_state_label(proposal.row)
      div(class: 'state-buttons') { render_full_state_buttons(proposal.row) }
      ''
    end
  end

  def render_state_buttons(row)
    if @states.submitted?(row)
      render_state_button('Accept', row, States::SOFT_ACCEPTED, 'btn-success')
      render_state_button('Waitlist', row, States::SOFT_WAITLISTED, 'btn-warning')
      render_state_button('Reject', row, States::SOFT_REJECTED, 'btn-danger')
    elsif @states.soft?(row)
      render_state_button('Reset Status', row, States::SUBMITTED, 'btn-default')
    end
    ''
  end

  def render_full_state_buttons(row)
    render_state_buttons(row)
    if @states.soft?(row)
      render_state_button('Finalize State', row, @states.final_of(row), 'btn-warning')
    elsif @states.finalized?(row)
      render_state_button('Hard Reset', row, States::SUBMITTED, 'btn-danger')
    end
    ''
  end

  def render_state_button(label, row, new_state, style)
    button(class: "btn btn-xs #{style}", onclick: ->(*_event) { set_state(row, new_state) }) { label }
  end
end
