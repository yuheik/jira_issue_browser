require 'rest-client'
require 'json'

class ApiCallerRestClient
  def self.call(url, id, password, method, payload)
    begin
      response = RestClient::Request.new(:method     => method,
                                         :url        => url,
                                         :user       => id,
                                         :password   => password,
                                         :proxy      => nil,
                                         :verify_ssl => false,
                                         :payload    => payload,
                                         :headers    => { :content_type => "application/json;charset=UTF-8" }
                                        ).execute
    rescue RestClient::ExceptionWithResponse => e
      puts "Error: (#{e.message} with #{e.response})"
      puts "Failed: #{e.backtrace}"
      # puts e
    end

    # dump(response)
  end

  def self.dump(response)
    abort if response.class != RestClient::Response

    puts "Dump Response --"
    puts "code:       #{response.code}"
    puts "body:       #{response.body}"
    puts "headers:    #{JSON.pretty_generate(response.headers)}"
    puts "cookies:    #{JSON.pretty_generate(response.cookies)}"
    puts "cookie_jar: #{response.cookie_jar.inspect}"
    puts "request:    #{response.request.inspect}"
    puts "history:    #{response.history}"
  end
end
