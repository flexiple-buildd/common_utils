require 'nokogiri'

class TOCExtractor
  def self.extract_toc_from_string(data)
    doc = Nokogiri::HTML.fragment(data)
    add_ids_to_headings(doc)
    toc = extract_toc_from_headings(doc)
    remove_toc_from_content(doc)
    { content: doc.to_html, table_of_contents: toc }
  rescue StandardError => e
    puts "Error processing content: #{e.message}"
    { content: data, table_of_contents: [] }
  end

  private

  def self.extract_toc_from_headings(doc)
    toc_items = []
    current_parent = nil

    doc.css('h2, h3').each do |heading|
      heading_id = heading['id'] || generate_heading_id(heading.text)
      if heading.name == 'h2'
        current_parent = { text: heading.text.strip, href: "##{heading_id}", sub_items: [] }
        toc_items << current_parent
      elsif heading.name == 'h3' && current_parent
        sub_item = { text: heading.text.strip, href: "##{heading_id}" }
        current_parent[:sub_items] << sub_item
      end
    end

    toc_items
  end

  def self.remove_toc_from_content(doc)
    toc_heading = doc.at_css('h4')
    return unless toc_heading && toc_heading.text.strip.downcase == 'table of contents'

    toc_heading.next_element.remove
    toc_heading.remove
  end

  def self.add_ids_to_headings(doc)
    doc.css('h2, h3').each do |heading|
      heading['id'] ||= generate_heading_id(heading.text)
    end
  end

  def self.generate_heading_id(text)
    text.downcase.strip.gsub(/\s+/, '-')
  end
end
