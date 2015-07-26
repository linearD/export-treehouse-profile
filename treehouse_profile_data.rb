require "net/http"
require "json"
require "csv"

# get the profile JSON data and parse into a ruby hash
def get_user_data(user_name)
  puts "Please wait was your profile data is retrieved"
  response = Net::HTTP.get_response("teamtreehouse.com", "/#{user_name}.json")
  user_data = JSON.parse(response.body)
  puts "Data retrieved!"
  return user_data
end

# option to print the profile summary into the terminal
def print_user_summary(user_data)
  
  puts "-" * 40
  puts "Category".ljust(30) + "Points".rjust(10)
  puts "-" * 40
  
  # sort the categories by points earned
  user_data_sorted = user_data["points"].sort_by do |category, points| 
    points
  end
  
  # make sure the highest points are at the top
  user_data_sorted.reverse! 

  # loop through and display the categories and poinst excluding 'total'
  user_data_sorted.each do |category|
    if category[0] != "total"
      puts category[0].ljust(30) + category[1].to_s.rjust(10)
    end
  end 

  # display the total
  puts "-" * 40
  puts "Total".ljust(30) + user_data["points"]["total"].to_s.rjust(10)
end

# option to print all the earned badges
def print_user_badges(user_data)
  puts "-" * 70
  puts "Badge Name".ljust(60) + "Date".ljust(10)
  puts "-" * 70

  # loop through all badges and format the date into something readable
  user_data["badges"].each do |badge|
    puts badge["name"].slice(0, 60).ljust(60) + badge["earned_date"].slice(0, 10).split("-").join("/").ljust(10)
  end

  puts "-" * 70
end

# export the profile summary into CSV file in the same directory
def export_summary(user_data)
  header = []
  row = []

  # chose to remove the 'total' key in the hash, figured end user will want to use own calculation on the CSV file when downloaded
  user_data["points"].delete("total")

  # put the hash keys into an array to form the header line
  user_data["points"].each_key do |key|
    header << key
  end

  # put the values in an array to form the first line
  user_data["points"].each_value do |value|
    row << value
  end

  # create the CSV file
  CSV.open("summary_#{user_data["name"].downcase.split.join("_")}.csv", "wb") do |csv|

    # add the arrays into the file to create the header and first row
    csv << header
    csv << row
  end

  # unless something went wrong, show that the data exported correctly
  if File.exist?("summary_#{user_data["name"].downcase.split.join("_")}.csv")
    puts "\nFile successfully save!"
  else
    puts "\nThe files did not save, try again."
  end
end

# option to export all the profile badges
def export_badge_data(user_data)
  header = []
  rows = []

  # grab the first badge in order to get all the info need to create the header row
  user_data["badges"][0].each_key do |key|
    header << key
  end

  # loop through all the badges and push the values into their own array
  user_data["badges"].each do |badge|
    row = []
    badge.each_value do |val|
      if val.to_s[val.to_s.length-1] == "Z"
        row << val.slice(0, 10).split("-").join("/")
      elsif val.class == Array
        row << val.length
      else
        row << val
      end
    end

    # push the new row array (row in CSV file) into the main rows array;
    rows << row
  end

  # create the CSV file
  CSV.open("badges_#{user_data["name"].downcase.split.join("_")}.csv", "wb") do |csv|

    # add the header
    csv << header

    # loop through the rows array and push inot the CSV file
    rows.each do |row|
      csv << row  
    end
  end

  # unless something went wrong, 
  if File.exist?("badges_#{user_data["name"].downcase.split.join("_")}.csv")
    puts "\nFile successfully save!"
  else
    puts "\nThe files did not save, try again."
  end
end

# get the prfile name
print "Please enter your TeamTreehouse profile name: "
user_name = gets.chomp
user = get_user_data(user_name)

# ask the user what they woulk like to do with their profile data
loop do
  puts "\nWhat would you like to do?"
  puts "(a) Print out the user summary..."
  puts "(b) Print out the badge names & dates..."
  puts "(c) Export the user summary..."
  puts "(d) Export all badge details..."
  print "Please select one of the options above: (a, b, c, d) "
  selection = gets.chomp
  
  # run the methods according to the users response
  case selection
    when "a"
      print_user_summary(user)
    when "b"
      print_user_badges(user)
    when "c"
      export_summary(user)
    when "d"
      export_badge_data(user)
    else
      puts "You didn't selected anything?!"
  end
  
  print "\nDo you want to select another option? (y/n) "
  answer = gets.chomp
  
  if answer != "y"
    puts "Goodbye, have a nice day!"
    break
  end
end