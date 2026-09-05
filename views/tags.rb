module TagsView
  def render_tag_labels(list)
    list.each { |tag| span(class: 'label label-success label-compact tag-label') { tag } }
  end

  def render_tag_item(proposal)
    div(class: 'proposal-meta-item tag-item') do
      div(class: 'info-item-heading') { 'Reviewer Tags' }
      if state.tag_edit == proposal.row
        render_tag_editor(proposal)
      else
        render_tag_view(proposal)
      end
    end
  end

  def render_tag_view(proposal)
    list = @tags.of(proposal.row)
    div(class: 'info-item-value') do
      list.empty? ? span(class: 'tag-none') { 'None' } : render_tag_labels(list)
      button(class: 'btn btn-default btn-sm btn-icon', onclick: :edit_tags) { '✎' }
    end
  end

  def render_tag_editor(proposal)
    div(class: 'info-item-value') do
      div(class: 'tag-edit') do
        input(type: 'text', class: 'tag-input', placeholder: 'カンマ区切り',
              value: @tags.text(proposal.row))
        button(class: 'btn btn-success btn-sm btn-icon', onclick: :save_tags) { '✓' }
        button(class: 'btn btn-danger btn-sm btn-icon', onclick: :cancel_tags) { '✕' }
      end
      render_tag_suggestions(proposal)
    end
  end

  def render_tag_suggestions(proposal)
    list = @tags.of(proposal.row)
    rest = @tags.all.reject { |tag| list.include?(tag) }
    return '' if rest.empty?

    div(class: 'tag-suggest') do
      rest.each do |tag|
        button(class: 'btn btn-default btn-sm tag-suggest-item',
               onclick: ->(*_a) { pick_tag(tag) }) { tag }
      end
    end
  end
end
