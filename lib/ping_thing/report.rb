module PingThing
  class Report
    def initialize
      @urls = {}
    end

    def add(origin, dest)
      url = @urls[dest] ||= {
        status: visit(origin, dest),
        destination: dest,
        origins: []
      }
      url[:origins] << origin
    end

    def visit(origin, dest)
      status = Faraday.head(dest).status.to_s
      log_visit(origin, dest, status)
      status
    end

    def log_visit(origin, dest, status)
      print "#{dest}".colorize(:blue) + ' => '
      if success?(status)
        puts status.colorize(:green)
      else
        puts "#{status.colorize(:red)} => from: #{origin.colorize(:cyan)}"
      end
    end

    def success?(status)
      status =~ /[23]\d{2}/
    end

    def successes
      @urls.values.map do |url|
        url if success?(url[:status])
      end.compact
    end

    def failures
      @urls.values.map do |url|
        url unless success?(url[:status])
      end.compact
    end

    def display
      puts
      puts "#{@urls.count} total links hit"
      puts "+ #{successes.count} successful responses".colorize(:green)
      puts "- #{failures.count} unsuccessful responses".colorize(:red)
      display_failures if failures.count > 0
    end

    def display_failures
      puts 'Failures:'.colorize(:red)
      puts
      failures.each_with_index do |(failure), i|
        puts "#{i + 1}) => #{failure.to_s.colorize(:red)}"
        puts
      end
    end
  end
end
