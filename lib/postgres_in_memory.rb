# We want to limit the impact of varying Postgres Query times on our benchmark tests. 
# This class caches the users and cities tables in memory and returns results from those. It IS NOT an ActiveRecord
# replacement: the only parameter that is read is the LIMIT clause. 
module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      private
        def users
          return @users if @users
          logger.debug "Caching fake users in memory."
          result = exec_no_cache("SELECT  \"users\".* FROM \"users\"",'User Load',[])
          @users = {
            cols: result.fields,
            rows: result.values
          }
          result.clear
          @users
        end

        def cities
          return @cities if @cities
          logger.debug "Caching fake cities in memory."
          result = exec_no_cache("SELECT  \"cities\".* FROM \"cities\"",'City Load',[])
          @cities = {
            cols: result.fields,
            rows: result.values
        }
          result.clear
          @cities
        end

        # Fake I/O Wait
        def io_sleep
          sleep 1/1000.0
        end

        # Returns results from our in-memory store if:
        # * querying the users or cities table
        # * a limit is provided
        def execute_and_clear(sql, name, binds)
          ret = nil
          if sql.include? "SELECT  \"users\".* FROM \"users\"" and sql.include? 'LIMIT'
            logger.debug "Returning in-memory users"
            io_sleep
            count = sql.scan(/LIMIT\s(\d+)/).last.last.to_i
            ret = ActiveRecord::Result.new(users[:cols],users[:rows][0..(count-1)])
          elsif sql.include? "SELECT  \"cities\".* FROM \"cities\"" and sql.include? 'LIMIT'
            logger.debug "Returning in-memory cities"
            io_sleep
            count = sql.scan(/LIMIT\s(\d+)/).last.last.to_i
            ret = ActiveRecord::Result.new(cities[:cols],cities[:rows][0..(count-1)])
          else
            result = without_prepared_statement?(binds) ? exec_no_cache(sql, name, binds) :
                                                          exec_cache(sql, name, binds)
            ret = yield result
            result.clear
          end
          ret
        end
    end
  end
end