require "net/http"
require "json"
require "csv"

def get_user_data(user_name)
  puts "Please wait while we get your data..."
  res = Net::HTTP.get_response("teamtreehouse.com", "/#{user_name}.json")
  user_data = JSON.parse(res.body)
  puts "Data retrieved!"
  return user_data
end

def print_user_summary(user_data)
  puts "-" * 40
  puts "Category".ljust(30) + "Points".rjust(10)
  puts "-" * 40
  user_data_sorted = user_data["points"].sort_by do |category, points| 
    points
  end
  user_data_sorted.reverse!
  user_data_sorted.each do |category|
    if category[0] != "total"
      puts category[0].ljust(30) + category[1].to_s.rjust(10)
    end
  end
  puts "-" * 40
  puts "Total".ljust(30) + user_data["points"]["total"].to_s.rjust(10)
end

def print_user_badges(user_data)
  puts "-" * 70
  puts "Badge Name".ljust(60) + "Date".ljust(10)
  puts "-" * 70
  user_data["badges"].each do |badge|
    puts badge["name"].slice(0, 60).ljust(60) + badge["earned_date"].slice(0, 10).split("-").join("/").ljust(10)
  end
  puts "-" * 70
end

def export_summary(user_data)
  header = []
  row = []
  user_data["points"].delete("total")
  user_data["points"].each_key do |key|
    header << key
  end
  user_data["points"].each_value do |value|
    row << value
  end
  CSV.open("summary_#{user_data["name"].downcase.split.join("_")}.csv", "wb") do |csv|
    csv << header
    csv << row
  end
  if File.exist?("summary_#{user_data["name"].downcase.split.join("_")}.csv")
    puts "\nFile successfully save!"
  else
    puts "\nThe files did not save, try again."
  end
end

def export_badge_data(user_data)
  header = []
  rows = []
  user_data["badges"][0].each_key do |key|
    header << key
  end
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
    rows << row
  end
  CSV.open("badges_#{user_data["name"].downcase.split.join("_")}.csv", "wb") do |csv|
    csv << header
    rows.each do |row|
      csv << row  
    end
  end
  if File.exist?("badges_#{user_data["name"].downcase.split.join("_")}.csv")
    puts "\nFile successfully save!"
  else
    puts "\nThe files did not save, try again."
  end
end

print "Please enter your TeamTreehouse profile name: "
user_name = gets.chomp
user = get_user_data(user_name)

loop do
  puts "\nWhat would you like to do?"
  puts "(a) Print out the user summary..."
  puts "(b) Print out the badge names & dates..."
  puts "(c) Export the user summary..."
  puts "(d) Export all badge details..."
  print "Please select one of the options above: (a, b, c, d) "
  selection = gets.chomp
  
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