module Index
  def render_list
    rows = visible_proposals
    div(class: 'list-wrap') do
      div(class: 'bar') do
        div(class: 'bar-title') { 'CFP Review App' }
        div(class: 'bar-sub') { "#{rows.size} proposals" }
        button(class: 'btn btn-default btn-sm', onclick: :reset_sort) { 'Reset Sort' }
      end
      div(class: 'table-scroll') do
        table(class: 'datatable proposal-list') do
          thead do
            tr(class: 'filter-row') do
              th { '' }
              th { '' }
              th { '' }
              th { input(type: 'text', class: 'f-speaker', oninput: :on_filter_speaker) }
              th { input(type: 'text', class: 'f-title', oninput: :on_filter_title) }
              th { input(type: 'text', class: 'f-format', oninput: :on_filter_format) }
              ''
            end
            tr(class: 'head-row') do
              render_sortable_header('score', 'Score')
              render_sortable_header('ratings', 'Ratings')
              render_sortable_header('standard_deviation', 'Standard Deviation')
              render_sortable_header('speaker', 'Speakers')
              render_sortable_header('title', 'Talk Title')
              render_sortable_header('format', 'Session Format')
              ''
            end
          end
          tbody do
            rows.each_with_index { |proposal, index| render_row(proposal, index) }
            ''
          end
        end
      end
    end
  end

  def render_sortable_header(key, label)
    th(class: 'sortable', onclick: ->(*_a) { sort_by_column(key) }) do
      "#{label}#{@table.marker(key)}"
    end
  end

  def render_row(proposal, index)
    rating_count = @ratings.count(proposal.row)
    scores_visible = @ratings.rated?(proposal.row) || own?(proposal)
    tr(class: index == state.index ? 'proposal sel' : 'proposal',
       onclick: ->(*_a) { open_at(index) }) do
      td(class: 'c-num') { scores_visible ? @ratings.average_text(proposal.row) : '' }
      td(class: 'c-num') { rating_count == 0 ? '' : rating_count.to_s }
      td(class: 'c-num') do
        scores_visible ? @ratings.standard_deviation_text(proposal.row) : ''
      end
      td(class: 'c-speaker') { proposal.name }
      td(class: 'c-title') { proposal.title }
      td(class: 'c-format') { proposal.format_label }
      ''
    end
  end
end
