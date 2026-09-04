module Show
  def render_detail
    proposal = current
    return render_list if proposal.nil?

    total = visible_proposals.size
    div(class: 'detail-wrap') do
      div(class: 'bar') do
        button(class: 'btn btn-primary btn-sm', onclick: :back_to_list) do
          '« Return to Proposals'
        end
        div(class: 'bar-sub') { "#{state.index + 1} / #{total}" }
        button(class: 'btn btn-default btn-sm', onclick: ->(*_a) { show_at(state.index - 1) }) do
          'Previous Proposal'
        end
        button(class: 'btn btn-primary btn-sm', onclick: ->(*_a) { show_at(state.index + 1) }) do
          'Next Proposal'
        end
      end

      div(class: 'page-header') do
        h1(class: 'proposal-title') { proposal.title }
      end

      div(class: 'proposal-info-bar') do
        render_meta_item('Speaker', proposal.name)
        render_meta_item('Format', proposal.format_label)
        render_links(proposal)
        ''
      end

      div(class: 'proposal-contents') do
        render_proposal_section('Abstract', proposal.abstract)
        h2(class: 'fieldset-legend') { 'For Review Committee' }
        render_proposal_section('Details', proposal.details)
        render_proposal_section('Pitch', proposal.pitch)
        render_proposal_section('Demo details', proposal.demo)
        render_proposal_section('Speaker Bio', proposal.bio)
        ''
      end

      render_rating(proposal) unless own?(proposal)
      render_others(proposal)
    end
  end

  def render_meta_item(label, value)
    return '' if value.nil? || value.empty?
    div(class: 'proposal-meta-item') do
      div(class: 'info-item-heading') { label }
      div(class: 'info-item-value') { value }
    end
  end

  def render_proposal_section(label, text)
    return '' if text.nil? || text.empty?

    div(class: 'proposal-section') do
      h3(class: 'control-label') { label }
      div(class: 'markdown') { render_body(text) }
    end
  end

  def render_rating(proposal)
    div(class: 'rate') do
      div(class: 'rate-row') do
        div(class: 'rate-label') { 'Rating' }
        input(type: 'number', class: 'rate-score', min: '1', max: '5', step: '0.1',
              oninput: :on_score_input)
      end
      textarea(class: 'rate-comment', placeholder: 'Comment (optional)') { '' }
      div(class: 'rate-foot') do
        button(class: 'btn btn-primary', onclick: :save_rating) do
          state.busy ? 'Saving…' : 'Save'
        end
        div(class: 'rate-note') do
          @ratings.rated?(proposal.row) ? 'Saving again replaces your rating.' : ''
        end
      end
    end
  end

  def render_others(proposal)
    div(class: 'others') do
      if own?(proposal) || @ratings.rated?(proposal.row)
        render_rating_list(proposal)
      else
        div(class: 'others-none') { 'Ratings are shown once you save your own.' }
      end
    end
  end

  # 自分のプロポーザルでは点数だけ見せ、コメントは伏せる。
  def render_rating_list(proposal)
    rating_count = @ratings.count(proposal.row)
    return div(class: 'others-none') { 'No Ratings' } if rating_count == 0

    div(class: 'others-head') do
      "Average rating: #{@ratings.average_text(proposal.row)} (#{rating_count})"
    end
    @ratings.entries(proposal.row).each do |who, value|
      div(class: 'others-row') do
        span(class: 'others-who') { short_name(who) }
        span(class: 'others-score') { value[0] }
        span(class: 'others-comment') { own?(proposal) ? '' : value[1] }
      end
    end
    ''
  end

  def short_name(email)
    email.split('@')[0].to_s
  end

  def render_links(proposal)
    return '' if proposal.github.empty? && proposal.x_account.empty?

    div(class: 'proposal-meta-item') do
      div(class: 'info-item-heading') { 'Links' }
      div(class: 'info-item-value') do
        render_account('GitHub', 'https://github.com/', proposal.github)
        render_account('X', 'https://x.com/', proposal.x_account)
        ''
      end
    end
  end

  def render_account(label, base, handle)
    return '' if handle.empty?

    a(class: 'account-link', href: account_url(base, handle)) { "#{label}: #{handle}" }
  end

  def account_url(base, handle)
    return handle if handle.start_with?('http')

    "#{base}#{handle.sub('@', '')}"
  end
end
