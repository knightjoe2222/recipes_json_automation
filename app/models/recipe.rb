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
    def self.generate_recipe_obj
    	Recipe.delete_all
    	file = File.read('public/recipes.json')
    	recipe = Recipe.new(id: 0, title: file)
    	recipe.save
    end
	def self.import_pictures_to_database
    	# **********************************************
		# *** Update or verify the following values. ***
		# **********************************************
		
		# Replace the accessKey string value with your valid access key.
		accessKey = "961bc5b2bb8e48c3885cb603219907b7"

		uri = URI('https://api.cognitive.microsoft.com/bing/v7.0/images/search')
		recipe = Recipe.find(0)
		js = JSON.parse(recipe.title)
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
		puts "Updating database.. (final)."
		recipe.update_attributes(title: JSON.generate(js))
		puts "Recipe object successfully updated"
    end

    def self.generate
		file = File.read('public/ingredients_and_recipes.json')
		js = JSON.parse(file)
		i = 0
		js['ingredients'].each{ |k, v|
			break if i >= 10
			
			ingname = v["name"].gsub(/[^a-zA-Z0-9\-]/,"").downcase
			puts "Filtered ingredient name: " + ingname
			js['recipes'].each{ |k, v|
				v['cookingIngredients'].each{ |k, v|
					listedname = ""
				}
			}
			i = i+1
		}
    end

    def self.convert
    	file = File.read('public/somewhat_completed.json');
		old = JSON.parse(file);
		file = File.read('public/recipes.json');
		newjs = JSON.parse(file);
		i = 0
		old['recipes'].each{ |k, v|
			break if i >= 420
			if (v['imageURL'] != "")
				newjs["recipes"][k]["imageURL"] = v['imageURL']
			end
			i = i+1
		}
		puts "Writing new file.. (final)."
		File.open("public/recipes.json","w") do |f|
		  f.write(JSON.pretty_generate(newjs))
		end
    end
end