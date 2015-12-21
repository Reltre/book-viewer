require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require 'pry'

helpers do
  def in_paragraphs(chapter)
    chapter.split("\n\n").map do |paragraph|
      "<p>#{paragraph}</p>"
    end.join
  end
end

not_found do
  redirect '/'
end

before do
  @contents = File.read("data/toc.txt").split("\n")
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  @content_subhead = "Table of Contents"

  erb :home
end

get "/chapters/:number" do
  @content_subhead = "Chapter #{params[:number]}"

  @title = @contents[params[:number].to_i - 1]
  @chapter = File.read("data/chp#{params[:number]}.txt")
  erb :chapter
end

get "/search" do
  query = params[:query]
  @query_matches = {}
  @contents.each_with_index do |title, index|
    url_string = "/chapters/#{index + 1}"
    chapter = File.read("data/chp#{index + 1}.txt")
    match = nil
    match = chapter.match(/(?<=[\?\.\!\;]).+#{query}.+(?=[\?\.\!\;])/) if query
    if match
      match = "#{match[0]}..."
      @query_matches["#{title}"] = {
                        matched_query: match,
                        url: url_string
                      }
    end
  end
  erb :search
end
