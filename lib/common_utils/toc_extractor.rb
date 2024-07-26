require 'nokogiri'

class TOCExtractor
  def self.extract_toc_from_string(data)
    doc = Nokogiri::HTML.fragment(data)
    add_ids_to_headings(doc)
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
    hrefs = []

    doc.css('h2, h3').each do |heading|
      heading_id = heading['id'] || generate_heading_id(heading.text)
      if heading.name == 'h2'
        current_parent = { text: heading.text.strip, href: "##{heading_id}", sub_items: [] }
        toc_items << current_parent
        countOfHref = hrefs.count(current_parent[:href])
        if(countOfHref > 0)
          current_parent[:href] = "#{current_parent[:href]}-#{countOfHref}"
          heading['id'] = "#{heading_id}-#{countOfHref}"
        else
          hrefs << current_parent[:href]
        end
      elsif heading.name == 'h3' && current_parent
        sub_item = { text: heading.text.strip, href: "##{heading_id}" }
        if hrefs.count(sub_item[:href]) > 0
          sub_item[:href] = "#{sub_item[:href]}-#{hrefs.count(sub_item[:href])}"
          heading['id'] = "#{heading_id}-#{hrefs.count(sub_item[:href])}"
        else
          hrefs << sub_item[:href]
        end
        current_parent[:sub_items] << sub_item
        hrefs << sub_item[:href]
      end
    end

    toc_items
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

  def self.generate_heading_id(heading)
    "#{heading.name}-" + heading.text.parameterize
  end
end
