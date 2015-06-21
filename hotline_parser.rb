module HotlineParser

	ALL_PRICES = []

	class ElementParser

		def initialize(host, elem)
			@host, @elem = host, elem
		end

		def parse_element
			@name = @elem.css('.title-box').text.strip

			url_attr = @elem.css('.img-box.pic-tooltip')[0].attributes['hltip'].value
			img_uri = URI.join(@host, url_attr).to_s
			basename_img = File.basename(img_uri)

			unless File.exist?('images/' + basename_img)
				File.open('images/' + basename_img,'wb'){ |f| f.write(open(img_uri).read) }
			end

			@price = @elem.css('.orng')[0].children[0].text.gsub(/[[:space:]]/,'')[/\d+/].to_i
			if @elem.css('.orng')[0].children[1]
				@min_max = @elem.css('.orng')[0].children[1].text.split('-').map{|pr| pr.gsub(/[[:space:]]/,'')[/\d+/]}
			else
				@min_max = nil
			end

			print_prices
			ALL_PRICES << @price
		end

		private
			def print_prices
				if @min_max
					puts "Position: #{@name}, price is: #{@price} uah\nCheapest price: #{@min_max[0]}, most expensive: #{@min_max[1]}\n\n"
				else
					puts "Position: #{@name}, price is: #{@price} uah\n\n"
				end
			end

	end

	class PageParser

		def initialize(url, host)
			unless url.is_a?(String) && host.is_a?(String)
				raise 'Wrong url or host type, only String allowed'
			end
			@url, @host = url, host
		end

		def parse
			threads = []

			Dir.mkdir('images') unless Dir.exist?('images')

			html_doc = Nokogiri::HTML(open(@url))
			page_catalog = html_doc.css('ul.catalog.clearfix').css('li')

			puts "Found #{page_catalog.count} goods\n\n"

			page_catalog.each do |elem|
				threads << Thread.new(elem) do |elem_in_thr|
					ElementParser.new(@host, elem_in_thr).parse_element
				end
			end
			threads.each {|thr| thr.join }

			puts "Average price from page: #{(ALL_PRICES.reduce(:+).to_f / ALL_PRICES.size).round(2)}"
		end

	end

end
