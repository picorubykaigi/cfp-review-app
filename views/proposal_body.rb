module ProposalBody
  def render_body(text)
    MarkdownParser.new(text).blocks.each { |block| render_body_block(block) }
  end

  def render_body_block(block)
    case block[0]
    when :heading   then render_body_heading(block[1], block[2])
    when :paragraph then div(class: 'md-paragraph') { render_body_inline(block[1]) }
    when :list      then render_body_list(block[1], block[2])
    when :quote     then div(class: 'md-quote') { render_body_inline(block[1]) }
    else div(class: 'md-pre') { block[1] }
    end
  end

  def render_body_heading(level, nodes)
    case level
    when 1 then h1(class: 'md-heading') { render_body_inline(nodes) }
    when 2 then h2(class: 'md-heading') { render_body_inline(nodes) }
    when 3 then h3(class: 'md-heading') { render_body_inline(nodes) }
    when 4 then h4(class: 'md-heading') { render_body_inline(nodes) }
    when 5 then h5(class: 'md-heading') { render_body_inline(nodes) }
    else h6(class: 'md-heading') { render_body_inline(nodes) }
    end
  end

  def render_body_list(ordered, items)
    if ordered
      ol { render_body_list_items(items) }
    else
      ul { render_body_list_items(items) }
    end
  end

  def render_body_list_items(items)
    items.each { |item| li { render_body_list_item(item) } }
  end

  def render_body_list_item(item)
    render_body_inline(item[1])
    item[2].each { |nested| render_body_block(nested) }
  end

  def render_body_inline(nodes)
    nodes.each { |node| render_body_node(node) }
  end

  def render_body_node(node)
    case node[0]
    when :text   then span { node[1] }
    when :link   then a(href: node[2]) { node[1] }
    when :code   then span(class: 'md-code') { node[1] }
    else span(class: 'md-strong') { node[1] }
    end
  end
end
