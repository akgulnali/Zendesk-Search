require 'json'

collection_names = ["Users", "Tickets", "Organizations"]

def print_options
  puts ""
  puts "\t Select search options:"
  puts "\t * Press 1 to search Zendesk"
  puts "\t * Press 2 to view a list of searchable fields"
  puts "\t * Type 'options' to list valid commands"
  puts "\t * Type 'quit' to exit"
  puts ""
end

def load_records # Load all records from all JSON files.
  begin
    all_records = {}
    # Finding all JSON files in given directory.
    Dir["JSON Files/*.json"].each do |json_file|
      file_name = File.basename(json_file, ".*").capitalize
      records = JSON.parse(File.read(json_file))
      all_records[file_name] = records
    end
    return all_records
  rescue Exception => e
    puts "Exception occurred: #{e}"
  end
end

all_records = load_records()

loop do
  puts "====================== Welcome To Zendesk Search ======================"
  puts "Press 'Enter' to continue, Type 'quit to exit at any time."
  print "Your command: "
  choice = STDIN.gets.chomp # Helps to get user input from command line.
  case choice
  when ""
    loop do
      print_options()
      print "Your command: "
      search_choice = STDIN.gets.chomp
      case search_choice
      when "1"
        puts ""
        puts "\t Please choose a number to make search in the collections listed below:"
        # Print out all collection names with index number.
        collection_names.each_with_index do |collection, index|
          puts "\t * Press #{index+1} for #{collection}"
        end
        puts ""
        collection_number = -1
        loop do
          print "Your command: "
          collection_number = STDIN.gets.chomp.to_i-1
          if collection_number > collection_names.length - 1 || collection_number == -1
            puts "Please enter a number between 1 to 3"
          else
            break
          end
        end
        search_term = nil
        loop do
          print "Please enter search term: "
          search_term = STDIN.gets.chomp
          if search_term == "--options"
            # Print out all filed names in the selected collection.
            puts all_records[collection_names[collection_number]][0].keys
          elsif !(all_records[collection_names[collection_number]][0].keys).include?(search_term)
            puts "Invalid search_term. Please type valid search term. (Type '--options' to list all search terms)"
          else
            break
          end
        end
        print "Please enter search value: "
        search_value = STDIN.gets.chomp
        # Searching given term inside the selected collection.
        found_records = all_records[collection_names[collection_number]].find_all do |h|
          if h[search_term].class == Array
            # Searching given term in array if field contains an array.
            h[search_term].find do |a|
              a.to_s == search_value 
            end
          else
            h[search_term].to_s == search_value
          end
        end
        puts "Searching in "+collection_names[collection_number]+"'s '"+search_term+"' column with a value of '"+search_value+"'"
        if found_records.size == 0
          puts "No results found." 
        else
          # Finds the longest field name length.
          longest_key = found_records[0].keys.max_by(&:length)
          found_records.each do |record|
            # Print out found record in a proper format.
            puts "-----------------------------------------------------------------------------------------------------------------"
            record.each { |key, value| printf "%-#{longest_key.length+20}s %s\n", key, value }
          end
        end
      when "2"
        # Print out all filed names in all collections.
        all_records.each_with_index do |record, index|
          puts "-----------------------------------------------------------"
          puts "Search #{collection_names[index]} with "
          puts all_records[collection_names[index]][0].keys
        end
      when "options"
        print_options()
      when "quit"
        puts "Thank you for using Zendesk Search."
        exit 0
      else
        puts "Invalid command! Please type a valid command."
      end
    end
  when "options"
    print_options()
  when "quit"
    puts "Thank you for using Zendesk Search."
    exit 0
  else
    puts "Invalid command! Please type a valid command. (You can type 'options' to list all valid commands)"
  end
end

