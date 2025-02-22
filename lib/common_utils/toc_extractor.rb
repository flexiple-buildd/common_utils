require 'nokogiri'

class TOCExtractor
  def self.extract_toc_from_string(data, update_icons = false)
    doc = Nokogiri::HTML.fragment(data)
    add_ids_to_headings(doc)
    add_classes_to_li(doc) if update_icons
    remove_toc_from_content(doc)
    toc = extract_toc_from_headings(doc)
    { content: doc.to_html, table_of_contents: toc }
  rescue StandardError => e
    puts "Error processing content: #{e.message}"
    { content: data, table_of_contents: [] }
  end

  private

  def self.extract_toc_from_headings(doc)
    toc_items = []
    current_parent = nil
    hrefs = {}

    doc.css('h2, h3').each do |heading|
      heading_id = heading['id'] || generate_heading_id(heading)
      toc_item = create_toc_item(heading, heading_id, hrefs)

      if heading.name == 'h2'
        current_parent = toc_item
        toc_items << current_parent
      elsif heading.name == 'h3' && current_parent
        current_parent[:sub_items] << toc_item
      end
    end

    toc_items
  end

  def self.create_toc_item(heading, heading_id, hrefs)
    href = "##{heading_id}"
    count_of_href = hrefs[href] || 0
    if count_of_href > 0
      href = "#{href}-#{count_of_href}"
      heading['id'] = "#{heading_id}-#{count_of_href}"
    end
    hrefs[href] = count_of_href + 1
    { text: heading.text.strip, href: href, sub_items: [] }
  end

  def self.remove_toc_from_content(doc)
    toc_heading = doc.at_css('h4')
    return unless toc_heading && toc_heading.text.strip.downcase.include?('table of contents')

    toc_heading.next_element.remove
    toc_heading.remove
  end

  def self.add_ids_to_headings(doc)
    doc.css('h2, h3').each do |heading|
      heading['id'] ||= generate_heading_id(heading)
    end
  end


  def self.add_classes_to_li(doc)
    doc.css('li').each do |li|
      unless li['class']&.include?('icon')
        li['class'] = li['class'] ? "#{li['class']} icon" : 'icon'
      end
    end
    doc.css('h2, h3, h4').each do |heading|
      if heading.text.downcase.include?('pros')
        next_element = heading.next_element
        if next_element && next_element.name == 'ul'
          next_element.css('li').each do |li|
            unless li['class']&.include?('pros-li')
              li['class'] = li['class'] ? "#{li['class']} pros-li" : 'pros-li'
            end
          end
        end
      end
      if heading.text.downcase.include?('cons')
        next_element = heading.next_element
        if next_element && next_element.name == 'ul'
          next_element.css('li').each do |li|
            unless li['class']&.include?('cons-li')
                li['class'] = li['class'] ? "#{li['class']} cons-li" : 'cons-li'
            end
          end
        end
      end
    end
  end

  def self.generate_heading_id(heading)
    "#{heading.name}-" + heading.text.parameterize
  end
end
