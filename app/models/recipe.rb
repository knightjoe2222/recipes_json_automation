class Recipe < ApplicationRecord
	def self.import_pictures
    	# **********************************************
		# *** Update or verify the following values. ***
		# **********************************************
		
		# Replace the accessKey string value with your valid access key.
		accessKey = "961bc5b2bb8e48c3885cb603219907b7"

		uri = URI('https://api.cognitive.microsoft.com/bing/v7.0/images/search')

		file = File.read('public/temp.json')
		js = JSON.parse(file)
		i = 0
		puts "Picking up where left off..."
		#puts JSON.pretty_generate(js)

		js["recipes"].each { |k, v|
			break if i >= 10
			#puts "Key=#{k}\n Value=#{v}"
			next if (js["recipes"][k]['imageURL'] != "")
			
			term = js["recipes"][k]["title"].downcase.gsub(/[^a-z0-9\s]/i, '')

			uri.query = URI.encode_www_form({
			    # Request parameters
			    'q' => term,
			    'count' => '2',
			    'offset' => '0',
			    'mkt' => 'en-us',
			    'safeSearch' => 'Moderate'
			})

			request = Net::HTTP::Get.new(uri.request_uri)
			# Request headers
			request['Ocp-Apim-Subscription-Key'] = accessKey
			
			response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
			    http.request(request)
			end

			newobj = JSON.parse(response.body)

			begin
				thumbnail = newobj["value"][0]["thumbnailUrl"].chomp('&pid=Api')
				js["recipes"][k]["imageURL"] = thumbnail
				puts "Added imageURL to #{k}"
				i = i + 1
			rescue
				puts "Bad server response at #{k}... skipping for now"
			end
			
		}
		puts "Writing new file.. (final)."
		File.open("public/temp.json","w") do |f|
		  f.write(JSON.pretty_generate(js))
		end	
		puts "New file successfully built"
    end

end
